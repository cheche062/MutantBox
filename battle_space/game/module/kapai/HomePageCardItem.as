package game.module.kapai
{
	import MornUI.kapai.SwapCardItemUI;
	
	import game.common.ToolFunc;
	
	/**
	 * 主页的单个卡牌 
	 * @author mutantbox
	 * 
	 */
	internal class HomePageCardItem extends SwapCardItemUI
	{
		public function HomePageCardItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			value = ToolFunc.copyDataSource(this.dataSource, value);
			
			var isEnough:Boolean = value["user_num"] >= value["num"];
			
			var child = dom_box.getChildAt(0);
			if (child) {
				child.init(value["id"]);
			} else {
				dom_box.addChild(new Card(value["id"]));
			}
			
			dom_text.text = value["user_num"] + '/' + value["num"];
			dom_text.color = isEnough? "green" : "red";
			dom_btn.visible = value["isSwapShow"];
			dom_btn.label = isEnough? "L_A_87039" : "L_A_87038";
			
			super.dataSource = value;
		}
	}
}