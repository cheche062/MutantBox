package game.module.armyGroup.fight 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import MornUI.armyGroupFight.ArmyWarnTipsUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyWarnTips extends BaseView 
	{
		
		private var _tipsData:Object;
		private var _isActivity:Boolean;
		
		public function ArmyWarnTips() 
		{
			super();
			
		}
		
		override public function createUI():void{
			_view = new ArmyWarnTipsUI();			
			this.addChild(_view);
			this.y = Laya.stage.height;
			this.x = Laya.stage.width-view.width;
			
			this.view.closeBtn.on(Event.CLICK, this, onClickHander);
			this.view.confirmBtn.on(Event.CLICK, this, onClickHander);
		}
		
		public function hideTips():void
		{
			this.visible = false;
			_isActivity = false;
		}
		
		private function onClickHander(e:Event):void
		{
			if (!_isActivity)
			{
				return;
			}
			
			switch(e.target)
			{
				case view.closeBtn:
					closeHandler();
					break;
				case view.confirmBtn:
					dealWarning();
					break;
				default:
					break;
			}
		}
		
		private function closeHandler():void {
			_isActivity = false;
			Tween.to(this, { y:Laya.stage.height}, 500,Ease.linearNone,new Handler(this,hideTips));
			
			clearTimer(this, closeHandler);
		}
		
		private function dealWarning():void
		{
			switch(_tipsData.type)
			{
				case 1:
					XFacade.instance.openModule(ModuleName.ArmyFightSetFood);
					break;
				case 2:
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_85019"),1, GameConfigManager.ArmyGroupBaseParam.rebornPrice, function()
																	{
																		WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_REBORN_TEAM, [_tipsData.tid]);
																	}]);
					break;
				default:
					break;
			}
			
			closeHandler();
		}
		
		public function showTips(data:Object):void
		{
			_tipsData = data;
			
			switch(_tipsData.type)
			{
				case 1:
					view.wTipsTxt.text = GameLanguage.getLangByKey("L_A_20999");
					break;
				case 2:
					
					view.wTipsTxt.text = GameLanguage.getLangByKey("L_A_21001");
					break;
				default:
					break;
			}
			_isActivity = true;
			this.visible = true;
			this.y = Laya.stage.height;
			Tween.to(this, { y:Laya.stage.height - this._view.height }, 500);
			
			timerOnce(5000, this, closeHandler);
			
		}
		
		public function get isActivity():Boolean 
		{
			return _isActivity;
		}
		
		private function get view():ArmyWarnTipsUI{
			return _view;
		}
	}

}