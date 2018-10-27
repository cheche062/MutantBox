package game.module.armyGroup 
{
	import MornUI.armyGroup.AGBuyProtectUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.armyGroup.newArmyGroup.StarVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AGBuyProtectView extends BaseDialog 
	{
		private var plantData:StarVo
		private var leftTimes:int;
		
		public function AGBuyProtectView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					close();
					break;
				
				case view.itemBuyBtn:
					if (leftTimes == 0) {
						return XTip.showTip("L_A_21025");
					}
					var cost:int = StarVo.getProtectCostByPosition(ArmyGroupMapView._guild_position);
					// "公会资金不足"
					if (ArmyGroupMapView._guild_cash < cost) {
						return XTip.showTip("L_A_921075");
					}
					
					var totalCanUseMoney = StarVo.getPlayerCanUseMoney(ArmyGroupMapView._guild_position);
					if (totalCanUseMoney - ArmyGroupMapView._user_guild_cash_used < cost) {
						return XTip.showTip("L_A_21027");
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_BUY_PROTECTED, [plantData.id]);
					break;
				default:
					break;
			}
		}

		private function serviceResultHandler(... args):void
		{
			var len:int = 0;
			var i:int = 0;
			switch (args[0])
			{
				case ServiceConst.ARMY_GROUP_BUY_PROTECTED:
					XTip.showTip("L_A_21026");
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			plantData = args[0][0];
			var _guild_position = args[0][2];
				
			view.dom_icon.skin = GameConfigManager.getItemImgPath("93201");
			view.dom_num.text = "x" + StarVo.getProtectCostByPosition(_guild_position);
				
			leftTimes = plantData.attempts - plantData.buy_protection_number;
			view.leftTimeTxt.text = GameLanguage.getLangByKey("L_A_21019").replace("{0}", leftTimes);
			
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}

		private function onClose():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}

		override public function createUI():void
		{
			this._view=new AGBuyProtectUI();
			this.addChild(_view);
			this._closeOnBlank = true;
			
		}
		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this, this.serviceResultHandler);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			super.addEvent();
		}


		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);

			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			super.removeEvent();
		}

		private function get view():AGBuyProtectUI
		{
			return _view;
		}
	}

}