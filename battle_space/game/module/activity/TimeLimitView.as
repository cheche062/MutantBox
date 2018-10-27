package game.module.activity 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.module.activity.ActivityMainView;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.NewGifts.TimeLimitViewUI;
	import game.common.ResourceManager;
	import game.global.GameConfigManager;
	
	import game.global.util.TimeUtil;
	import game.common.ToolFunc;
	
	/**
	 * ...
	 * @author ...苏宇
	 */
	public class TimeLimitView extends BaseView 
	{
		private var _currentCharge:int = 0;
		private var _packIndex:int = 0;
		
//		private var _itemContainerVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var reSx:Array = [0, 460, 430, 400, 370, 340, 310];
		
		private var rewardList:Array = [];
		private var _actProcess:Array = [];
		private var maxIndex:int = 1;
		
		private var clearTimerHandler:Function;
		
		private var refTime:int = 0;
		
		public function TimeLimitView() 
		{
			super();
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			_packIndex = 0;
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.btnLeft:
					_packIndex--;
					if (_packIndex < 0)
					{
						_packIndex = 0;
					}
					refreshReward();
					break;
				case view.btnRight:
					_packIndex++;
					if (_packIndex >= maxIndex)
					{
						_packIndex = maxIndex-1;
					}
					refreshReward();
					break;
				case view.btnBuy1:
					WebSocketNetService.instance.sendData(ServiceConst.GIFT_TIME_LIMIT_BUY, rewardList[_packIndex].id);
					break;
				default:
					break;
			}
			
		}
		
		private function doClearTimerHandler():void {
			clearTimerHandler && clearTimerHandler();
			clearTimerHandler = null;
		}
		
		private function refreshReward():void
		{
//			var list:Array = rewardList[_packIndex].item.split(";")
			var len:int = rewardList.length;
			
			// 获取配置表数据
			var data = ResourceManager.instance.getResByURL("config/activity/limited_recharge.json");
			var currData = data[rewardList[_packIndex].id];
			//道具str转换成图标
			view.hbox_BoxList.x=290;
			view.hbox_BoxList.destroyChildren();
			ToolFunc.createRewardsDoms(currData.reward).forEach(function(item) {
				view.hbox_BoxList.addChild(item);
				view.hbox_BoxList.x-=42;
			});
			//折扣价格
			var oldCostArray:Array = currData.old_cost.split("=");
			view.imgIcon_1.skin = GameConfigManager.getItemImgPath(oldCostArray[0]);
			view.lbCostNum_1.text = oldCostArray[1]+'';
			
			var newCostArray:Array = currData.cost.split("=");
			view.imgIcon_2.skin = GameConfigManager.getItemImgPath(newCostArray[0]);
			view.lbCostNum_2.text = newCostArray[1]+'';
			view.lbDiscountText.text = (100-currData.discount) + '% OFF';
			
			setBtnBuyType();
		}
		
		/**设置购买按钮状态*/
		private function setBtnBuyType():void{
			//购买按钮的状态修改,购买次数为0为可以改买
			if(rewardList[_packIndex] && rewardList[_packIndex].data.buytimes == 0 )
			{
				view.btnBuy1.disabled = false;
				view.btnBuy1.label = GameLanguage.getLangByKey("L_A_56016");//购买
				view.imgBox1.skin = 'armyGroup/reward_1.png';
			}
			else
			{
				view.btnBuy1.disabled = true;
				view.btnBuy1.label = GameLanguage.getLangByKey("L_A_56022");//已购买
				view.imgBox1.skin = 'armyGroup/reward_1_open.png';
			}
			if(refTime<=0){
				view.btnBuy1.disabled = true;
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("限时礼包：", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GIFT_TIME_LIMIT:
									
					rewardList = [];
					
					for(var key in args[1]) 
					{
						rewardList.push({id:key,data:args[1][key]});
					}
					maxIndex = rewardList.length;
					//礼包时间管理
					var countdown = rewardList[_packIndex].data.seconds;
					clearTimerHandler = ToolFunc.limitHandler(countdown, function(time) {
						var detailTime = TimeUtil.toDetailTime(time);
						refTime = time;
						view.lbCountdown.text = TimeUtil.timeToText(detailTime);
					}, function() {
						refTime = 0;
						view.lbCountdown.text = "00:00:00";
						clearTimerHandler = null;
						trace('倒计时结束：：：');
						//刷新抽卡
						setBtnBuyType();
					}, false);
					
					refreshReward();
					break;
				case ServiceConst.GIFT_TIME_LIMIT_BUY:
					var buyId:Number = args[1];// rewardList[_packIndex].reward.split(";")
					// 获取配置表数据
					var data = ResourceManager.instance.getResByURL("config/activity/limited_recharge.json");
					var currData = data[buyId];
					ToolFunc.showRewardsHandler(currData.reward);
					
					WebSocketNetService.instance.sendData(ServiceConst.GIFT_TIME_LIMIT, ActivityMainView.CURRENT_ACT_ID);
					break;
				default:
					break;
			}
		}
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.GIFT_TIME_LIMIT, ActivityMainView.CURRENT_ACT_ID);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GIFT_TIME_LIMIT), this, serviceResultHandler, [ServiceConst.GIFT_TIME_LIMIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GIFT_TIME_LIMIT_BUY), this, serviceResultHandler, [ServiceConst.GIFT_TIME_LIMIT_BUY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GIFT_TIME_LIMIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GIFT_TIME_LIMIT_BUY), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			doClearTimerHandler();
		}
		
		override public function show(...args):void{
			super.show();
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new TimeLimitViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		private function get view():TimeLimitViewUI{
			return _view;
		}
		
	}

}