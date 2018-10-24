package game.global.vo.worldBoss
{
	import game.module.bag.mgr.ItemManager;

	public class BossRankVo
	{
		public var down:String;
		public var up:String;
		public var reward:String;
		private var m_rewardArr:Array;
		public function BossRankVo()
		{
		}
		
		public function rankTile():String{
			var downT:String = getT(down);
			var upT:String  = getT(up);
			if(downT == upT)return downT;
			return downT + " - " + upT;
		}
		
		private function getT(s:*):String{
			if(s.indexOf("*") == -1)
			{
				if(s==1)
				{
					return s+"st";
				}
				else if(s==2)
				{
					return s+"nd";
				}
				else if(s==3)
				{
					return s+"rd";
				}
				return s + "th";
			}
			var ar:Array = s.split("*");
			return Number(ar[0]) * 100 + "%";
		}
		
		public function getDown():int
		{
			return int(down);
		}
		
		
		public function getUp():int
		{
			
			return int(up);
		}
		
		public function getRewardList():Array
		{
//			m_rewardArr=new Array();
//			var l_arr:Array=reward.split(";");
//			for(var i:int=0;i<l_arr.length;i++)
//			{
//				var l_str:String=l_arr[i];
//				var l_rewardArr:Array=l_str.split("=");
//				var l_vo:RewardVo=new RewardVo();
//				l_vo.id=l_rewardArr[0];
//				l_vo.num=l_rewardArr[1];
//				m_rewardArr.push(l_vo);
//			}
			
			
			if(!m_rewardArr)
			{
				m_rewardArr = ItemManager.StringToReward(reward);
			}
			return m_rewardArr;
		}
		
	}
}