package game.global.vo.relic
{
	public class TransportPlanpriceVo
	{
		public var attempts:int;
		public var price:String;
		public function TransportPlanpriceVo()
		{
		}
		
		public function getPrice():int
		{
			var l_arr:Array=price.split("=");
			return l_arr[1];	
		}
	}
}