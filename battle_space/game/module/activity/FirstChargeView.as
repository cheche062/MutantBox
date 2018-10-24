package game.module.activity 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.display.Animation;
	import laya.events.Event;
	import MornUI.acitivity.FirstChargeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FirstChargeView extends BaseDialog 
	{
		private var _currentCharge:int = 0;
		private var _actInfo:Object;
		private var _curSelect:int = 0;
		
		private var _reEffect:Animation;
		
		private var _itemContainerVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		//private var reSx:Array = [0, 273, 227, 181, 135];
		private var reSx:Array = [0, 555, 515, 475, 435, 395];
		
		private var _actID:int = 0;
		
		public function FirstChargeView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.getBtn:
					if (view.getBtn.label == GameLanguage.getLangByKey("L_A_56021"))
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.FIRST_CHARGE_GET_REWARD);
					}
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
			
		}
		
		private function refreshState():void
		{
			view.getBtn.disabled = false;
			switch(_actInfo.status)
			{
				case 0:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_56021");//立刻充值
					break;
				case 1:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_56018");//领取
					break;
				case 2:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_32005");//已领
					view.getBtn.disabled = true;
					break;
				default:
					break;
			}
		}
		
		private function displayReward(index:int):void
		{
			
//			XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
			XFacade.instance.openModule(ModuleName.CongratulationView, [_actInfo.config.reward]);
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.FIRST_CHARGE_INIT:
					_actInfo = args[1];
					refreshReward();
					refreshState();
					break;
				case ServiceConst.FIRST_CHARGE_GET_REWARD:
					WebSocketNetService.instance.sendData(ServiceConst.FIRST_CHARGE_INIT);
					WebSocketNetService.instance.sendData(ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE);
					displayReward(0);
					break;
				default:
					break;
			}
		}
		
		private function refreshReward():void
		{
			var list:Array = _actInfo.config.reward.split(";");
			var len:int = list.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (!_itemContainerVec[i])
				{
					_itemContainerVec[i] = new ItemContainer();
					_itemContainerVec[i].y = 310;
					//_itemContainerVec[i].scaleX = _itemContainerVec[i].scaleY = 0.8;
					view.addChild(_itemContainerVec[i]);
				}
				
				_itemContainerVec[i].x = (reSx[len] - 85 + 85 * i)-260;
				_itemContainerVec[i].setData(list[i].split("=")[0], list[i].split("=")[1]);
				_itemContainerVec[i].visible = true;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			_actID = args[0];
			WebSocketNetService.instance.sendData(ServiceConst.FIRST_CHARGE_INIT);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new FirstChargeViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			this.closeOnBlank = true;
			
			view.getBtn.label = GameLanguage.getLangByKey("L_A_56021");
			
			_reEffect = new Animation();
			_reEffect.x = -27;
			_reEffect.y = 185;
			_reEffect.loadAtlas("appRes/atlas/effects/fcEffect.json");
			_reEffect.play();
			_reEffect.interval = 100;
			/*_reEffect.stop();
			_reEffect.loop = false;		*/	
			view.addChild(_reEffect);
			
			//addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIRST_CHARGE_INIT), this, serviceResultHandler, [ServiceConst.FIRST_CHARGE_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIRST_CHARGE_GET_REWARD), this, serviceResultHandler, [ServiceConst.FIRST_CHARGE_GET_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FIRST_CHARGE_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FIRST_CHARGE_GET_REWARD), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		private function get view():FirstChargeViewUI{
			return _view;
		}
	}

}