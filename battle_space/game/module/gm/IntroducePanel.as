package game.module.gm
{
	import MornUI.panels.IntroduceViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	public class IntroducePanel extends BaseDialog
	{
		public function IntroducePanel()
		{
			super();
			closeOnBlank = true;
		}
		
		
		public function get view():IntroduceViewUI{
			if(!_view)
				_view = new IntroduceViewUI();
			return _view as IntroduceViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			view.htmlDiv.font = XFacade.FT_Futura;
			view.htmlDiv.fontSize = 18;
			view.htmlDiv.color = '#addfff';
			view.p1.vScrollBar.sizeGrid = "6,0,6,0";
			view.p1.scrollTo();
			
		}
		
		
		override public function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var st:String = args[0];
			
			view.htmlDiv.width = view.p1.width - 15;
			view.htmlDiv.text = st;
			view.p1.scrollTo();
		}
		
		
		override public function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
		}
		
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
	}
}