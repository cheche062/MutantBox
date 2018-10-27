package game.module.tips.itemTip
{
	import laya.display.Sprite;

	public class ItemTipPanel2 extends ItemTipPanel
	{
		public function ItemTipPanel2()
		{
			super();
		}
		
		protected override function initBg():void{
			super.initBg();
			bgImg.scaleX = -1;
			cmb.x = 30;
		}
		
		public override function size(width:Number, height:Number):Sprite{
			var rt:Sprite =  super.size(width, height);
			bgImg.x = bgImg.width;
			return rt;
		}
		
	}
}