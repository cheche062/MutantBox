package game.module.bag.cell
{
	import MornUI.ItemCells.RewardCell1UI;
	import MornUI.fightingChapter.itemCellUIUI;
	
	import game.global.GameConfigManager;
	
	import laya.ui.Image;

	public class RewardCellMin extends BaseItemCell
	{
		
		public static const itemWidth:Number = 100;
		public static const itemHeight:Number = 30;
		public function RewardCellMin()
		{
			super();
			this.showTip = true;
		}
		
		public override function bindIcon():void{
			var url:String = GameConfigManager.getItemImgPath(this.data.iid);
			_itemIcon.graphics.clear();
			_itemIcon.loadImage(url);
		}
		
		
		protected override function init():void
		{
			var ui:RewardCell1UI = new RewardCell1UI();
			addChild(ui);
			_itemIcon = ui.itemIcon;
			_itemNumLal = ui.numText;
			_itemNumLal.stroke = 1;
		}
	}
}