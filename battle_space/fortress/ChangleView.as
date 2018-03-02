package game.module.fortress
{
	import MornUI.fortress.changleViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	public class ChangleView extends BaseDialog
	{
		public function ChangleView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			view.dom_number.text = args[0];
			
			trace("【扫荡成功弹窗】", args);
			
		}
		
		override public function createUI():void{
			this.addChild(view);
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_confirm:
					close();
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():changleViewUI{
			_view = _view || new changleViewUI();
			return _view;
			
		}
	}
}