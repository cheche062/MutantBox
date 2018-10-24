package game.global.vo
{
	import game.module.bag.mgr.ItemManager;

	public class PvpLevelVo
	{
		public var id:Number = 0;
		public var name:String;
		public var icon:String;
		public var down:Number = 0;
		public var up:Number = 0;
		public var reward:String;
		public var unit:String;
		
		
		private var _rewardList:Array;
		private var _hotUnits:Array;
		
		public function PvpLevelVo()
		{
		}
		
		public function get rewardList():Array
		{
			if(!_rewardList && reward)
			{
				_rewardList = ItemManager.StringToReward(reward);
			}
			return _rewardList;
		}
		
		public function get hotUnits():Array
		{
			if(!_hotUnits)
			{
				_hotUnits = [];
//				var ar:Array = unit.split(",");
//				for (var i:int = 0; i < ar.length; i++) 
//				{
//					_hotUnits.push(Number(ar[i]));
//				}
				
			}
			return _hotUnits;
		}
		
		public function coincide(integral:Number):Boolean{
			return integral >= down && integral <= up;
		}
		
		public function get rankIcon():String{
			return "appRes/icon/rankIcon/"+id+".png"
		}
	}
}