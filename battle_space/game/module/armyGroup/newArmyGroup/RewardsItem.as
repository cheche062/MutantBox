package game.module.armyGroup.newArmyGroup
{
	import MornUI.componets.RewardsItemUI;
	
	import game.common.ItemTips;
	import game.common.ToolFunc;
	import game.global.GameConfigManager;
	
	import laya.events.Event;
	
	/**
	 * 排行榜奖励子项 
	 * @author mutantbox
	 * 
	 */
	public class RewardsItem extends RewardsItemUI
	{
		public function RewardsItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			
			dom_icon.skin = GameConfigManager.getItemImgPath(value.id);
			dom_num.text = value.num;
			
			dom_icon.offAll();
			dom_icon.on(Event.CLICK, this, showHandler, [value.id]);
			
			super.dataSource = value;
		}
		
		private function showHandler(id):void {
			ItemTips.showTip(id);
		}
	}
}