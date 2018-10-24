package game.global.data
{
	import game.common.XUtils;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	
	import laya.display.Stage;
	
	public class ItemCostCell extends ItemCell
	{
		public function ItemCostCell()
		{
			super();
		}
		
		override public function set data(value:ItemData):void{
			super.data = value;
			if(value && value.vo){
				
				bindNum();
			}
		}
		
		public override function bindNum():void{
			var max:int=BagManager.instance.getItemNumByID(data.iid);
			if(max>=data.inum)
			{
				_itemNumLal.color="#ffffff";
			}
			else
			{
				_itemNumLal.color="#ff7d7d";
			}
			
			_itemNumLal.align = Stage.ALIGN_RIGHT;
			if(data.isShowMax==true)
			{
				_itemNumLal.text = XUtils.formatResWith(max)+"/"+XUtils.formatResWith(data.inum);
			}
			else
			{
				_itemNumLal.text = XUtils.formatResWith(data.inum);
			}
		}
	}
}