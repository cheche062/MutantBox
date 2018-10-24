/***
 *作者：罗维
 */
package game.common
{
	import game.module.bag.cell.BaseItemCell;
	
	import laya.ui.List;
	import laya.ui.Tab;
	
	public class RewardList extends List
	{
		public function RewardList()
		{
			super();
			this.repeatY = 1;
			this.itemRender = BaseItemCell;
			this.itemWidth = BaseItemCell.itemWidth;
			this.itemHeight = BaseItemCell.itemHeight;
			this.spaceX = 10;
			this.selectEnable = false;
			
		}
		
		private var _itemWidth:Number;
		public function get itemWidth():Number
		{
			return _itemWidth;
		}

		public function set itemWidth(value:Number):void
		{
			_itemWidth = value;
		}
		
		private var _itemHeight:Number;
		public function get itemHeight():Number
		{
			return _itemHeight;
		}
		
		public function set itemHeight(value:Number):void
		{
			_itemHeight = value;
		}

		public override function set array(value:Array):void
		{
			_array = [];
			this.repeatX = value.length;
			
			this.width = (this.repeatX - 1) * (itemWidth + spaceX) + itemWidth;
			this.height = itemHeight;
				
//			if(_array != value)
				super.array = value;
				
		
		}
		
		public override function set repeatX(value:int):void{
			if(_repeatX != value)
			{
				super.repeatX = value;
			}
		}
	
		public override function set width(value:Number):void{
			if(_width != value)
			{
				super.width = value;
			}
		}
		
		public override function set height(value:Number):void{
			if(_height != value)
			{
				super.height = value;
			}
		}
		
	

	}
}