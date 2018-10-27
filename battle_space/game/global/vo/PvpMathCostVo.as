package game.global.vo
{
	import game.module.bag.mgr.ItemManager;

	public class PvpMathCostVo
	{
		public var id:Number = 0;
		public var rank1:Number = 0;
		public var rank2:Number = 0;
		public var down:Number = 0;
		public var up:Number = 0;
		public var price:String;
		
		private var _cost:Array;
		public function PvpMathCostVo()
		{
		}
		
		
		public function get cost():Array
		{
			if(!_cost)
			{
				_cost = ItemManager.StringToReward(price);
			}
			return _cost;
		}
		
		public function coincide(level:Number,matchTimes:Number):Boolean{
			return rank1 <= level && level <= rank2 && matchTimes >= down && matchTimes <= up;
		}
	}
}