package game.module.kapai
{
	import MornUI.kapai.CardItemUI;
	
	import game.common.ToolFunc;
	
	/**
	 * 卡牌大师   兑换单个牌
	 * @author mutantbox
	 * 
	 */
	public class SwapCardItem extends CardItemUI
	{
		public function SwapCardItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			value = ToolFunc.copyDataSource(this.dataSource, value);
			
			var child = dom_box.getChildAt(0);
			if (child) {
				child.init(value["id"]);
			} else {
				dom_box.addChild(new Card(value["id"]));
			}
			
			dom_light.visible = value["isSelected"];
			dom_text.text = value["num"];
			
			dom_box.gray = value["num"] == 0;
			
			super.dataSource = value;
		}
		
		
		
	}
}