package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightRankItemUI;
	
	/**
	 * ArmyFightRankItem
	 * author:huhaiming
	 * ArmyFightRankItem.as 2017-11-27 下午6:42:21
	 * version 1.0
	 *
	 */
	public class ArmyFightRankItem extends ArmyFightRankItemUI
	{
		public function ArmyFightRankItem()
		{
			super();
		}
		
		
		/**
		 *rank_kill_rank
		 * 
		 * */
		override public function set dataSource(value:*): void{
			var data:Object = value;
			if(data)
			{
				dom_rank.text = value.rank;
				dom_name.text = value.nickname;
				dom_group.text = value.guildname;
				dom_kill.text = value.killnum;
			}
		}

		
	}
}