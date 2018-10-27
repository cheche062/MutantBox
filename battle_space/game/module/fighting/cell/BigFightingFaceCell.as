/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import laya.resource.Texture;
	import laya.ui.Image;

	public class BigFightingFaceCell extends FightingFaceCell
	{
		public function BigFightingFaceCell()
		{
			super();
			
			width = 81;
			height = 78;
		}
		
		protected override function initFaceBg():void
		{
			var img:Image = new Image();
			img.skin = "fightingUI/bg3.png";
			addChild(img);
			super.initFaceBg();
			_bgImg.x = 10;
			_bgImg.y = 8;
//			_faceImg.x = 20;
//			_faceImg.y = -1;
//			_faceImg.scaleX = _faceImg.scaleY = .8;
		}
		
		
		
		protected override function imageLoadeH(tex:Texture):void
		{
			_faceImg.graphics.drawTexture(tex);
			_faceImg.scaleX = _faceImg.scaleY = .8;
			_faceImg.x = 13;
			_faceImg.y = -1;
		}
	}
}