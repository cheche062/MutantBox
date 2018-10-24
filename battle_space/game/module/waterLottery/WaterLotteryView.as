package game.module.waterLottery 
{
	import game.common.base.BaseView;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.activity.ActivityMainView;
	import game.net.socket.WebSocketNetService;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.waterLottery.WaterLotteryUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WaterLotteryView extends BaseView 
	{
		
		private var _rollList:Vector.<LotteryRollItem> = new Vector.<LotteryRollItem>(5);
		
		private var _lotteryConfig:Object;
		private var _lotteryTimes:int;
		
		private var _rewardWater:int;
		
		private var _endTime:int;
		private var _leftTime:int;
		
		public function WaterLotteryView(endData:int) 
		{
			super();
			ResourceManager.instance.load(ModuleName.WaterLotteryView, Handler.create(this, resLoader));
			_endTime = endData;
		}
		
		public function resLoader():void
		{
			
			this._view = new WaterLotteryUI();
			this.addChild(_view);
			
			
			var mask:Sprite=new Sprite();
			mask.width = 394;
			mask.height = 222;
			mask.graphics.drawRect(0,0,394,222,'#FF0000');
			view.itemBox.mask=mask;
			
			for (var i:int = 0; i < 5; i++) 
			{
				_rollList[i] = new LotteryRollItem();
				_rollList[i].x = 1 + i * 79;
				view.itemBox.addChild(_rollList[i]);
			}
			
			addEvent();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var id:int = parseInt(e.target.name.split("_")[1]);
			
			switch(e.target)
			{
				case view.startBtn:
					view.startBtn.disabled = true;
					WebSocketNetService.instance.sendData(ServiceConst.WATER_LOTTERY_START,ActivityMainView.CURRENT_ACT_ID);
					break;
				case view.ruleBtn:
					XFacade.instance.openModule(ModuleName.WaterLotteryRuleView);
					break;
				default:
					break;
			}
		}
		
		private function timeCount():void
		{
			_leftTime--;
			view.resetTime.text = GameLanguage.getLangByKey("L_A_84201") + TimeUtil.getTimeCountDownStr(_leftTime);
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.WATER_LOTTERY_INIT:
					//trace("宝石转盘初始haul：", args);
					_lotteryTimes = args[3].shakeTimes;
					_lotteryConfig = args[2];
					
					view.maxGet.text = _lotteryConfig[_lotteryTimes + 1].display;
					
					if (User.getInstance().VIP_LV >= _lotteryConfig[_lotteryTimes + 1].vip_lvl)
					{
						view.startBtn.disabled = false;
						view.needVip.visible = false;
						view.payInfo.visible = true;
						view.price.text = _lotteryConfig[_lotteryTimes + 1].cost.split("=")[1];
					}
					else
					{
						view.startBtn.disabled = true;
						view.needVip.visible = true;
						view.payInfo.visible = false;
						view.needVip.text = "需要VIP等级：" + _lotteryConfig[_lotteryTimes + 1].vip_lvl;
					}
					
					break;
				case ServiceConst.WATER_LOTTERY_START:
					
					for (i = 0; i < 5; i++ )
					{
						if (i < args[2])
						{
							_rollList[i].startRoll((i+1) * 10);
						}
						else
						{
							_rollList[i].startRoll((i+1) * 10+1);
						}
					}
					_rewardWater = args[3].split("=")[1];
					Laya.timer.once(6000, this, showReward);
					
					break;
				default:
					break;
			}
		}
		
		private function showReward():void
		{
			view.startBtn.disabled = false;
			var idata:ItemData = new ItemData();
			idata.iid = 1;
			idata.inum = _rewardWater;
			
			if(view.displayedInStage)
			{
				XFacade.instance.openModule(ModuleName.ShowRewardPanel, [[idata]]);
				WebSocketNetService.instance.sendData(ServiceConst.WATER_LOTTERY_INIT, ActivityMainView.CURRENT_ACT_ID);
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.WATER_LOTTERY_INIT, ActivityMainView.CURRENT_ACT_ID);
			
			_leftTime = _endTime - parseInt(TimeUtil.now / 1000);
			view.startBtn.disabled = false;
			Laya.timer.loop(1000, this, timeCount);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WATER_LOTTERY_INIT), this, serviceResultHandler, [ServiceConst.WATER_LOTTERY_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WATER_LOTTERY_START), this, serviceResultHandler, [ServiceConst.WATER_LOTTERY_START]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		private function removeFromStageEvent():void
		{
			Laya.timer.clear(this, timeCount);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WATER_LOTTERY_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WATER_LOTTERY_START),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		
		
		private function get view():WaterLotteryUI{
			return _view;
		}
	}

}