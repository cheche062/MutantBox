package game.global.vo
{
	import game.module.bag.mgr.ItemManager;
	import game.module.pvp.PvpManager;

	public class PvpRewardVo
	{
		public var num:Number = 0;
		public var reward:String;
		
		private var _showReward:Array;
		public function PvpRewardVo()
		{
		}

		public function get showReward():Array
		{
			if(!_showReward)
			{
				_showReward = ItemManager.StringToReward(reward);
			}
			
			return _showReward;
		}

		public function set showReward(value:Array):void
		{
			_showReward = value;
		}
		
		public function get state():Number{
			if(Number(PvpManager.intance.userInfo.matchTimes) < num) return 2;  //不能领
			if(PvpManager.intance.getedRewards.indexOf(num) == -1) return 1;  //能领
			return 3; //已领
		}

	}
}