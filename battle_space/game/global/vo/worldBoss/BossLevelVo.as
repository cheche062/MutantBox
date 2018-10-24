package game.global.vo.worldBoss
{
	import game.global.GameLanguage;
	import game.global.data.bag.ItemData;
	import game.module.bag.mgr.ItemManager;

	public class BossLevelVo
	{
		public var id:int;
		public var name:String;
		public var npc_id:int;
		public var cost:String;
		public var battle_group:String;
		public var aid_group:int;
		public var reward:String;
		public var time:int;
		public var random_reward1:String;
		public var sell_item:String;
		public var condition:String;
		public var des1:String;
		public var des2:String;
		private var m_rewardArr:Array;
		private var m_randomReward:Array;
		private var m_sellItemArr:Array;
		
		private var m_localRewardArr:Array;
		private var m_randomBossRewardArr:Array;
		
		
		public function BossLevelVo()
		{
		}
		
		public function getRewardArr():Array
		{
			
			m_rewardArr=new Array();
			var l_arr:Array=reward.split(";");
			for(var i:int=0;i<l_arr.length;i++)
			{
				var l_str:String=l_arr[i];
				var l_rewardArr:Array=l_str.split("=");
				var l_rewardVo:ItemData=new ItemData();
				l_rewardVo.iid=l_rewardArr[0];
				l_rewardVo.inum=l_rewardArr[1];
				m_rewardArr.push(l_rewardVo);
			}
			if(l_arr.length==0)
			{
				var l_str:String=reward;
				var l_rewardArr:Array=l_str.split("=");
				var l_rewardVo:ItemData=new ItemData();
				l_rewardVo.iid=l_rewardArr[0];
				l_rewardVo.inum=l_rewardArr[1];
				m_rewardArr.push(l_rewardVo);
			}
			return m_rewardArr;
		} 
		
		public function getTypeIcon():String
		{
			var l_arr:Array=condition.split(":");
			if(l_arr[0]==7||l_arr[0]==9)
			{
				return "common/icons/a_"+l_arr[1]+".png";
			}
			else if(l_arr[0]==8||l_arr[0]==10)
			{
				return "common/icons/b_"+l_arr[1]+".png";
			}
			
		}
		
		public function getSolderTypeArr():Array
		{
			var l_arr:Array=condition.split(":");
			return l_arr;
		}
		
		
		
		
		public function getTypeText():String
		{
			var l_arr:Array=condition.split(":");
			if(l_arr[0]==7||l_arr[0]==8)
			{
				return GameLanguage.getLangByKey("L_A_46050");
			}
			else if(l_arr[0]==9||l_arr[0]==10)
			{
				return GameLanguage.getLangByKey("L_A_46051");
			}
			return "没有配表";
		}
		
		public function getLocalRewardArr():Array
		{
			if(!m_localRewardArr)
			{
				m_localRewardArr = ItemManager.StringToReward(reward);
			}
			return m_localRewardArr;
		}
		
		public function getRandomBossRewardArr():Array
		{
			if(!m_randomBossRewardArr)
			{
				m_randomBossRewardArr = ItemManager.StringToReward(random_reward1);
			}
			return m_randomBossRewardArr;	
		}
		
		public function getRandomRewardArr():Array
		{
			
			m_randomReward=new Array();
			if(random_reward1!=null)
			{
				var l_arr:Array=random_reward1.split(";");
				for(var i:int=0;i<l_arr.length;i++)
				{
					var l_str:String=l_arr[i];
					var l_rewardArr:Array=l_str.split("=");
					var l_rewardVo:ItemData=new ItemData();
					l_rewardVo.iid=l_rewardArr[0];
					l_rewardVo.inum=l_rewardArr[1];
					m_randomReward.push(l_rewardVo);
				}
			}
			
			return m_randomReward;
		}
		
		public function getSellArr():Array
		{
			m_sellItemArr=new Array();
			m_sellItemArr=sell_item.split("|");
			
			return m_sellItemArr;
		}
		
		
	}
}