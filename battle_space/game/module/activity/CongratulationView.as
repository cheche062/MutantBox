package game.module.activity
{
	import MornUI.congratulation.congratulationViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	
	/**
	 * 领取奖励后的弹出框 
	 * @author hejianbo
	 * 
	 */
	public class CongratulationView extends BaseDialog
	{
		public function CongratulationView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void
		{
			this.addChild(view);
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			createItems(args[0][0]);
		}
		
		private function createItems(str:String):void {
			var list:Array = str.split(";");
			view.dom_box.destroyChildren();
			
			var _w = 0;
			list.forEach(function(item) {
				// 添加小icon
				var arr = item.split("=");
				var child:ItemContainer = new ItemContainer();
				child.setData(arr[0], arr[1]);
				_w += child.width;
				view.dom_box.addChild(child);
			});
			
			view.dom_box.x = (view.width - _w) / 2;
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.btn_close:
					close();
					break;
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, onClick);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, onClick);
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		private function get view():congratulationViewUI
		{
			_view = _view || new congratulationViewUI();
			return _view;
		}
	}
}