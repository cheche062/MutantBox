package game.module.camp
{
	import MornUI.tips.CampTipUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	/**
	 * CampTip
	 * author:huhaiming
	 * CampTip.as 2018-5-22 下午3:41:04
	 * version 1.0
	 *
	 */
	public class CampTip extends BaseDialog
	{
		public function CampTip()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
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
		
		override public function createUI():void{
			this._view = new CampTipUI();
			this.addChild(_view);
			this.closeOnBlank = true;
		}
		
		private function get view():CampTipUI{
			return this._view;
		}
	}
}