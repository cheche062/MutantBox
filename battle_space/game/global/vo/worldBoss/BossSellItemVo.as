package game.global.vo.worldBoss
{
	public class BossSellItemVo
	{
		public var sell_id:int;
		public var item:String;
		public var price:String;
		
		public function BossSellItemVo()
		{
		}
		
		public function sellPrice():int
		{
			var l_arr:Array=price.split("=");
			return parseInt(l_arr[1]);
		}
		
		public function getCostItemId():int
		{
			var l_arr:Array=price.split("=");
			return parseInt(l_arr[0]);	
		}
		
		
		public function getItemId():int
		{
			var l_arr:Array=item.split("=");
			return parseInt(l_arr[0]);
		}
		
	}
}