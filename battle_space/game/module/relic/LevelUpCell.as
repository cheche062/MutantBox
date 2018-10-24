package game.module.relic
{
	import MornUI.relic.GoodsCellUI;
	import MornUI.relic.LevelUpCellUI;
	import MornUI.relic.TransportCellUI;
	
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.relic.EnemieVo;
	import game.module.camp.UnitItem;
	
	import laya.ui.Box;
	
	public class LevelUpCell extends UnitItem
	{
		
		
		public function LevelUpCell()
		{
			super();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			super.dataSource=value;
			this.FightingText.visible=true;
			this.FightingImage.visible=true;
			this.FightingBgImage.visible=true;
		}
	}
}