package game.module.mainui
{
	import laya.ui.Button;
	import laya.ui.Image;

	/**
	 * BtnDecorate
	 * author:huhaiming
	 * BtnDecorate.as 2017-3-31 下午1:55:12
	 * version 1.0
	 *
	 */
	public class BtnDecorate
	{
		public function BtnDecorate()
		{
		}
		
		/**
		 * 装饰一个按钮,将一个图片插入到按钮中，注意，只能使用一次。。
		 * @param btn 目标按钮，
		 */
		public static function decorate(btn:Button, iconSkin:String, xPos:Number=0, yPos:Number=0):void{
			var img:Image = new Image();
			img.name = "icon_img";
			btn.addChild(img);
			img.skin = iconSkin;
			img.x = xPos;
			img.y = yPos;
		}
		
		/**设置背景图片*/
		public static function setSkin(btn:Button, iconSkin:String):void {
			var img = btn.getChildByName("icon_img");
			if (img) {
				img.skin = iconSkin;
			}
		}
	}
}