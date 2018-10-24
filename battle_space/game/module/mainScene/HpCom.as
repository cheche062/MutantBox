package game.module.mainScene
{
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.ui.Image;
	
	/**
	 * HpCom
	 * author:huhaiming
	 * HpCom.as 2017-5-4 下午4:44:19
	 * version 1.0
	 *
	 */
	public class HpCom extends Sprite
	{
		private var _bg:Image;
		private var _bar:Image;
		private var W:Number;
		public function HpCom()
		{
			super();
			init();
		}
		
		/**
		 * param n 0-100
		 * */
		public function update(n:Number):void{
			//this._bar.scrollRect = new Rectangle(0,0, W*n/100,_bar.height);
			this._bar.width = (n > 100)?W:(W * n / 100);
		}
		
		private function init():void{
			this._bg = new Image("mainUi/hpBarBg.png");
			this.addChild(_bg);
			
			this._bar = new Image("mainUi/hpBar.png");
			this.addChild(_bar);
			_bar.pos(2,1);
			W = 105;
		}
	}
}