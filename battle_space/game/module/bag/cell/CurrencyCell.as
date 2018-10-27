package game.module.bag.cell
{
	import MornUI.ItemCells.RewardCell1UI;
	import MornUI.panels.CurrencyCellUI;
	
	import game.common.XUtils;
	import game.global.GameConfigManager;

	public class CurrencyCell extends BaseItemCell
	{
		
		public static const itemWidth:Number = 220;
		public static const itemHeight:Number = 100;
		public function CurrencyCell()
		{
			super();
		}
		
		public override function bindIcon():void{
			var url:String = GameConfigManager.getItemImgPath(this.data.iid);
			_itemIcon.graphics.clear();
			_itemIcon.loadImage(url);
		}
		
		public override function bindNum():void{
			_itemNumLal.text = "x" + data.inum;
		}
		
		
		protected override function init():void
		{
			var ui:CurrencyCellUI = new CurrencyCellUI();
			addChild(ui);
			_itemIcon = ui.itemIMG;
			_itemNumLal = ui.itemNUM;
			_itemNumLal.stroke = 1;
			size(ui.width,ui.height);
		}
	}
}