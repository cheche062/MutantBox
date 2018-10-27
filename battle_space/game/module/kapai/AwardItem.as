package game.module.kapai
{
	import MornUI.kapai.AwardItemUI;
	
	import game.common.ToolFunc;
	import game.global.data.DBItem;
	import game.module.bingBook.ItemContainer;
	
	/**
	 * 左侧奖励列表的tab子项 
	 * @author hejianbo
	 * 
	 */
	internal class AwardItem extends AwardItemUI
	{
		public function AwardItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			value = ToolFunc.copyDataSource(this.dataSource, value);
			
			dom_btn.selected = value["isSelected"];
			dom_dot.visible = value["isRedShow"];
			
			// 添加小icon
			if (this.dom_box.numChildren == 0) {
				ToolFunc.rewardsDataHandler(value["reward"], function(id, num){
					var child:ItemContainer = new ItemContainer();
					var info = DBItem.getItemData(id);
					if (info) {
						// 名称
						dom_btn.label = info["name"];
					}
					child.setData(id, num);
					child.scale(0.7, 0.7);
					dom_box.addChild(child);
				});
			}
			
			
			
			super.dataSource = value;
		}
		
	}
}