package game.module.playerHelp
{
	import MornUI.playerHelp.contentItemUI;
	
	/**
	 *  panel子项，一张图片&一段文字为一个组
	 * @author mutantbox
	 * 
	 */
	public class ContentItem extends contentItemUI
	{
		/**
		 * 
		 * @param txt 文案
		 * @param url 图片
		 * 
		 */
		public function ContentItem(txt:String, url:String)
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
			var _height = 0;
			if (url) {
				dom_img.skin = url;
				dom_img.y = _height;
				_height += dom_img.height;
			}
			
			if (txt) {
				dom_txt.text = txt;
				
				// 并排
				if (/icon/.test(url)) {
					dom_txt.x = dom_img.width + 15;
					dom_txt.y = 0;
					_height = Math.max(_height, dom_txt.height);
					
				} else {
					_height += 15;
					dom_txt.x = 0;
					dom_txt.y = _height;
					_height += dom_txt.height;
				}
			}
			
			this.height = _height;
		}
	}
}