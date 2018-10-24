package game.global.data.bag
{
	import MornUI.fightingChapter.itemCellUIUI;
	
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;

	public class ItemCell3 extends ItemCell
	{
		public static const itemWidth:Number = 63;
		public static const itemHeight:Number = 63;
		
		public function ItemCell3()
		{
			super();
			size(itemWidth,itemHeight);
		}
		
		
	
		
		protected override function init():void
		{
			var ui:itemCellUIUI = new itemCellUIUI();
			addChild(ui);
			_bg = ui.bg;
			_flag = new Image();
			_itemIcon = ui.itemIcon;
			_itemNumLal = ui.itemNumLal;
			_itemNumLal.stroke = 1;
			_itemNumLal.fontSize = 20;
//			_itemIcon.width = 10;
		}
		
		
		public override function set selected(value:Boolean):void{
			
		}
	}
}