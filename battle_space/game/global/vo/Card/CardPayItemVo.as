package game.global.vo.Card
{
	import game.global.data.bag.ItemData;

	public class CardPayItemVo
	{
		public var id:int;
		public var level:int;
		public var item_id:String;
		public var rate:int;
		public var level_down:String;
		public var level_up:String;
		
		
		public function CardPayItemVo()
		{
		}
		
		
		public function getItemData():ItemData
		{
			var l_itemdata:ItemData=new ItemData();
			var l_arr:Array=item_id.split("=");
			l_itemdata.iid=l_arr[0];
			l_itemdata.inum=l_arr[1];
			return l_itemdata;
		}
	}
}