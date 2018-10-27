package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightHelpViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	
	/**
	 * ArmyHelpCom
	 * author:huhaiming
	 * ArmyHelpCom.as 2017-12-5 下午12:17:41
	 * version 1.0
	 *
	 */
	internal class ArmyHelpCom extends BaseDialog
	{
		public function ArmyHelpCom()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			
			super.show(args);
			var msg:String = args[0];
			
			view.htmlDiv.width = view.p1.width - 15;
			var str:String = GameLanguage.getLangByKey(msg);
			str = str.replace(/##/g, "<br/>");
			view.htmlDiv.innerHTML = str;
			//			view.size( view.htmlDiv.contextWidth , view.htmlDiv.contextHeight);
			view.htmlDiv.height = view.htmlDiv.contextHeight;
			view.p1.scrollTo();
			
			AnimationUtil.popIn(this);
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		override public function addEvent():void{
			super.addEvent();
			view.btnClose.on(Event.CLICK,this,close);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.btnClose.off(Event.CLICK,this,close);
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			view.htmlDiv.style.fontFamily = XFacade.FT_Futura;
			view.htmlDiv.style.fontSize = 18;
			view.htmlDiv.style.color = '#addfff';
			view.p1.vScrollBar.sizeGrid = "6,0,6,0";
			view.p1.scrollTo();
		}
		
		private function get view():ArmyFightHelpViewUI{
			if(!_view){
				_view = new ArmyFightHelpViewUI();
			}
			return _view;
		}
	}
}