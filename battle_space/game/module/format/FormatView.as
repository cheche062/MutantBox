package game.module.format
{
	import MornUI.format.FormatViewUI;
	import MornUI.tigerMachine.TigerMachineUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	public class FormatView extends BaseDialog
	{
		public function FormatView()
		{
			super();
		}
		override public function createUI():void
		{
			this.addChild(view);
			this.closeOnBlank = true;
		}
		public function get view():FormatViewUI{
			_view = _view || new FormatViewUI();
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btnClose.on(Event.CLICK,onClose);
		}
		
		override public function close():void
		{
			// TODO Auto Generated method stub
		
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			// TODO Auto Generated method stub
			super.close();
		}
		
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
			view.btnClose.off(Event.CLICK,onClose);
		}
		
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args);
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
		
	}
}