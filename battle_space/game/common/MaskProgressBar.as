/***
 *作者：罗维
 */
package game.common
{
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.ui.ProgressBar;
	import laya.utils.Tween;
	
	public class MaskProgressBar extends ProgressBar implements IHpProgressBar
	{
		private var _maskSp:Sprite = new Sprite();
		private var _maskSp2:Sprite = new Sprite();
		
		public function MaskProgressBar(skin:String=null)
		{
			super(skin);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			_bar.mask = _maskSp;
			_maskSp.cacheAsBitmap = true;
			
			_bg.mask = _maskSp2;
			_maskSp2.cacheAsBitmap = true;
		}
		
		

		override public function size(width:Number, height:Number):Sprite{
			
			//trace("size-----",height);
			_bar.size(width,height);
			_bg.size(width,height);
			return super.size(width,height);
		}
		
		private var _leftValue:Number;
		public function get leftValue():Number
		{
			return _leftValue;
		}
		
		public function set leftValue(value:Number):void
		{
			value = Math.floor(value * 100) / 100
			if(_leftValue != value)
			{
				//trace("leftValue:",value);
				_leftValue = value;
				changeValue();
			}
		}
		
		public function setHpValue(v:Number ,mv:Number, hd:Boolean):void
		{
			v ||= 1;
			mv ||= 1;
			if(hd)
			{
				_leftValue = _value;
				_value = v / mv;
//				this.timer.once(800,this,function(v2:Number):void{
//					_leftValue = v2;
//					changeValue();
//				},[_value]);
				Tween.to(this,{leftValue:_value},400);
				
			}else
			{
				_leftValue = _value = v / mv;
			}
			changeValue();
//			value = v;
		}
		
		
		
		
		
		
		protected override function changeValue():void {
//			_bar.scrollRect = new Rectangle(0,0,width * _value,height);
//			_bg.scrollRect = new Rectangle(0,0,width * _leftValue,height); 
			_maskSp.graphics.clear();
			_maskSp.graphics.drawRect(0,0,width * _value, height,"#ffffff");
			
			_maskSp2.graphics.clear();
			_maskSp2.graphics.drawRect(0,0,width * _leftValue, height,"#ffffff");
			
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_maskSp = null;
			_maskSp2 = null;
			super.destroy(destroyChild);
		}
	}
}