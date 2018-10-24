package game.global.vo.worldBoss
{
	public class BossBuyVo
	{
		public var down:int;
		public var up:int;
		public var price:String;
		public function BossBuyVo()
		{
		}
		
		public function getPrice():Number
		{
			var l_arr:Array=price.split("=");
			return l_arr[1];
		}
	}
}