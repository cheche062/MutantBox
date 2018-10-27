package game.global.vo.relic
{
	public class TransportVehicleVo
	{
		public var id:int;
		public var name:String;
		public var tupian:String;
		public var level:String;
		public var rate:int;
		public var members:int;
		public var help_members:int;
		public var reduce_time:int;
		public var price:String;
		
		public function TransportVehicleVo()
		{
		}
		
		public function getPrice():int
		{
			var l_arr:Array=price.split("=");
			
			return l_arr[1];
		}
		
		
	}
}