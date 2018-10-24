package game.global.vo.relic
{
	public class TransportPrice1Vo
	{
		public var attempts:int;
		public var price:String;
		public function TransportPrice1Vo()
		{
		}
		
		public function getPrice():int
		{
			var l_arr:Array=price.split("=");
			return l_arr[1];	
		}
		
	}
}