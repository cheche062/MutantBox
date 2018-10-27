package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.FightTeamsitemUI;
	
	/**
	 * ArmyTeamsItem
	 * author:huhaiming
	 * ArmyTeamsItem.as 2017-11-27 下午6:07:47
	 * version 1.0
	 *
	 */
	public class ArmyTeamsItem extends FightTeamsitemUI
	{
		public function ArmyTeamsItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			if(value){
				this.nameTF.text = value[1]+"";
				this.brTF.text = value[0]+"";
				this.clubTF.text = value[3]+"";
				this.lvTF.text = value[2]+"";
			}
		}
	}
}