package game.module.armyGroup.newArmyGroup
{
	import MornUI.armyGroup.newArmyGroup.ArmyRankItemUI;
	
	import game.common.XUtils;
	
	public class ArmyRankItem extends ArmyRankItemUI
	{
		public function ArmyRankItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_rank.text = value.rank;
			dom_name.text = value.nickname;
			dom_group.text = value.guildname || "-";
			dom_kill.text = value.killnum;
			
			dom_rewards.destroyChildren();
			
			value.rewards.split(";").forEach(function(item) {
				var data = item.split("=");
				var child:RewardsItem = new RewardsItem();
				child.dataSource = {id: data[0], num: "x" + XUtils.formatResWith(data[1])};
				dom_rewards.addChild(child);
				
				
			})
			
			super.dataSource = value;
		}
	}
}