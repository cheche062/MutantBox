package game.global.vo.relic
{
	public class TransportPriceVo
	{
		public var attempts:int;
		public var price:String;
		
		public function TransportPriceVo()
		{
		}
		
		public function getPrice():int
		{
			var l_arr:Array=price.split("=");
			return l_arr[1];	
		}
		
		public function getItemId():int
		{
			var l_arr:Array=price.split("=");
			return l_arr[0];
		}
	}
}