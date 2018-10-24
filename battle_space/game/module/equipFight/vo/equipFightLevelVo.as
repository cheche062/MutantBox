package game.module.equipFight.vo
{
	import game.module.bag.mgr.ItemManager;
	
	import laya.maths.Point;

	public class equipFightLevelVo
	{
		public var id:Number = 0;
		public var chapter_id:Number = 0;
		public var name:String;
		public var icon:String;
		public var coordinate:String;
		public var preview:String;
		
		
		private var _cPoint:Point;
		private var _showReward:Array;
		public function equipFightLevelVo()
		{
		}

		public function get cPoint():Point
		{
			if(!_cPoint)
			{
				_cPoint = new Point();
				var ar:Array = coordinate.split(",");
				_cPoint.x = Number(ar[0]);
				_cPoint.y = Number(ar[1]);
			}
			return _cPoint;
		}
		
		
		public function get showReward():Array
		{
			if(!_showReward)
			{
				_showReward = ItemManager.StringToReward(preview);
			}
			return _showReward;
		}

	}
}