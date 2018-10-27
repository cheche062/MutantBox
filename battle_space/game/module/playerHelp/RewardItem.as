package game.module.playerHelp
{
	import MornUI.playerHelp.rewardItemUI;
	
	public class RewardItem extends rewardItemUI
	{
		public function RewardItem()
		{
			super();
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			super.dataSource = value;
			
			var _scale = 0.5;
			var dom_info = this.getChildByName("dom_info");
			var dom_icon = this.getChildByName("dom_icon");
			var dom_num = this.getChildByName("dom_num");
			
			dom_icon.size(80*0.5, 80*0.5);
			dom_icon.x = dom_info.width + dom_icon.width / 2;
			dom_num.x = dom_icon.x + dom_icon.width / 2 - 8;
			
			this.width = dom_num.x + dom_num.width;
			
		}
	}
}