package game.module.advance
{
	import MornUI.advance.AdvanceItemNewUI;
	
	/**
	 * 战况升阶  子项 
	 * @author mutantbox
	 * 
	 */
	public class AdvanceItemNew extends AdvanceItemNewUI
	{
		public function AdvanceItemNew()
		{
			super();
		}
		
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			dom_viewStack.selectedIndex = value["isLock"] ? 1 : 0;
			
			dom_icon_left.skin = dom_icon_right.skin = dom_icon_lock.skin = value["icon"];
			dom_level_left.text = "Lvl." + value["level"];
			dom_level_right.text = "Lvl." + (value["level"] + 1);
			
			dom_add_left.text = value["addTxt"];
			dom_add_right.text = value["addTxtNext"];
			
			dom_next.visible = !value["isMax"];
			dom_max.visible = value["isMax"];
			
			dom_msg.text = value["msg"];
			
			super.dataSource = value;
		}
	}
}