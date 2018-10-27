package game.module.tips.itemTip.base
{
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class BaseItemTipPanel extends BaseItemTip
	{
		protected var bgImg:Image = new Image();
		protected var cmb:Sprite = new Sprite();
		
		
		public function BaseItemTipPanel()
		{
			super();
			initBg();
			super.addChild(cmb);
		}
		
		protected function initBg():void{
			super.addChild(bgImg);
			bgImg.skin = "common/bg9.png";
			bgImg.sizeGrid = "80,0,100,0";
		}
		
		public override function size(width:Number, height:Number):Sprite{
			bgImg.size(width,height);
			return super.size(width, height);
		}
		
		public override function addChild(node:Node):Node
		{
			return cmb.addChild(node);
		}
		public override function addChildAt(node:Node, index:int):Node
		{
			return cmb.addChildAt(node,index);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BaseItemTipPanel");
			bgImg = null;
			cmb = null;
			super.destroy(destroyChild);
		}
	}
}