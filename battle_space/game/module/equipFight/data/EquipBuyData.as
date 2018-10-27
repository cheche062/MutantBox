package game.module.equipFight.data
{
	import game.global.data.bag.ItemData;

	public class EquipBuyData
	{
		public var sell_id:Number;
		public var item:String;
		public var maxNum:Number;
		public var num:Number;
		public var price:String;
		
		public function EquipBuyData()
		{
		}
		
		private var _itemD:ItemData;

		public function get itemD():ItemData
		{
			if(!_itemD)
			{
				if(item)
				{
					var ar:Array = item.split("=");
					_itemD = new ItemData();
					_itemD.iid = Number(ar[0]);
					_itemD.inum = Number(ar[1]);
				}
			}
			return _itemD;
		}
		
		public function get priceNum():Number{
			
			if(price)
			{
				var ar:Array = price.split("=");
				return Number(ar[1]);
			}
			return 0;
		}
		
		public var state:Number = 0;

	}
}