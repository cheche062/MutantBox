package game.module.chests
{
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	
	import laya.display.Animation;
	import laya.utils.Tween;
	
	public class DrawCardItemCell extends ItemCell
	{
		private var m_drawCardEffect:Animation;
		
		public function DrawCardItemCell()
		{
			super();
			this._bg.x = this._bg.y = -10;
		}
		
		override public function set data(value:ItemData):void{
			super.data = value;
			
			if (value && value.vo) {
				
				this._bg.skin = "common/ch_icon_bg_"+value.vo.quality+".png";
				this._flag.skin = "common/item_bar"+(value.vo.quality-1)+".png";
			}else{
				this._bg.skin = "common/ch_icon_bg_1.png";
				this._flag.skin = "";
			}
		}
		
		private function initUI():void
		{
			
			
		}
		
		public function setDrawCell():void
		{
			this.alpha=0;
			Tween.to(this, { alpha : 1 }, 1000);
		}
		
		private function setDrawCardEffect():void
		{
			
		}
		
		private function onEffectHandler():void
		{
			// TODO Auto Generated method stub
			trace("onEffectHandler");
			m_drawCardEffect.visible=false;
//			m_drawCardEffect.clear();
		}		
		
		private function setAlpha():void
		{
			
			
		}
	}
}