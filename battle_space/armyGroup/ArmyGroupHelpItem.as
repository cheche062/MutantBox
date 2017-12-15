package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupHelpItemUI;
	
	public class ArmyGroupHelpItem extends ArmyGroupHelpItemUI
	{
		public function ArmyGroupHelpItem(txt:String, url:String)
		{
			super();
			
			upadata(txt, url);
		}
		
		/**
		 * 更新信息 
		 * @param txt 文本内容
		 * @param url 图片皮肤
		 * 
		 */
		public function upadata(txt:String, url:String):void{
			dom_txt.text = txt;
			
			dom_img.skin = url;
			dom_img.y = dom_txt.height + 30;
			
			this.height = dom_img.y + dom_img.height;
		}
		
	}
}