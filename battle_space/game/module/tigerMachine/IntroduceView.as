package game.module.tigerMachine
{
	import MornUI.PeopleFallOff.PeopleFallOffUI;
	import MornUI.tigerMachine.IntroduceViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	
	public class IntroduceView extends BaseDialog
	{
		public function IntroduceView()
		{
			super();
		}
		override public function createUI():void
		{
			super.createUI();
			this.closeOnBlank = true;
			isModel = true;
			addChild(view); 
			view.x1.text = GameLanguage.getLangByKey("L_A_86152");
			view.x2.text = GameLanguage.getLangByKey("L_A_86153");
			view.x3.text = GameLanguage.getLangByKey("L_A_86154");
			view.x4.text = GameLanguage.getLangByKey("L_A_86155");
		}
		public function get view():IntroduceViewUI{
			if(!_view)
			{
				_view ||= new IntroduceViewUI;
			}
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,this.close);
		}
		override public function removeEvent():void
		{
			super.removeEvent();
			view.btn_close.off(Event.CLICK,this,this.close);
		}
	}
}