package game.global.vo.relic
{
	import game.module.bag.mgr.ItemManager;

	public class TransportPlanVo
	{
		public var id:int;
		public var level:int;
		public var name:String;
		public var type:int;
		public var cost:String;
		public var time:int;
		public var reward:String;
		public var rate:int;
		private var m_rewardArr:Array;
		public function TransportPlanVo()
		{
		}
		
		public function getRewardNum():int
		{
			var l_arr:Array=reward.split("=");
			return l_arr[1];
		}
		
		public function getRewardList():Array
		{
			if(!m_rewardArr)
			{
				m_rewardArr = ItemManager.StringToReward(reward);
			}
			return m_rewardArr;
		}
		
		
		public function getCostNum():int
		{
			var l_arr:Array=cost.split("=");
			return l_arr[1];
			
		}
		
	}
}