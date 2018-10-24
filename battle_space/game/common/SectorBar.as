/***
 *作者：罗维
 */
package game.common
{
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Component;
	import laya.ui.Image;
	
	/**
	 *这是一个扇形进度条 
	 */
	public class SectorBar extends Component
	{
		protected var barMask:Sprite;
		protected var bgSprite:Sprite;
		protected var topSprite:Sprite;
		public function SectorBar()
		{
			super();
			
			bgSprite = new Sprite();
			this.addChild(bgSprite);
			topSprite = new Sprite();
			this.addChild(topSprite);
			
			
			barMask = new Sprite();
//			barMask.cacheAsBitmap = true;
//			this.addChild(barMask);
			topSprite.mask = barMask;
		
			initBar();
		}
		

		protected function initBar():void{
			this.size(79,79);
			this.barRadius = this.width >> 1;
			var img:Image = new Image();
			img.skin = "common/sectorBar/sectorbar_bg_01.png";
			this.barBg = img;
			
			img = new Image();
			img.skin = "common/sectorBar/sectorbar_top_01.png";
			this.barTop = img;
			
			this.maxSectorCount = 40;
			
		}
		
//		public override function size(width:Number, height:Number):Sprite{
//			barMask.size(width,height);
//			return super.size(width,height);
//		}
		
		protected var _barValue:Number;
		public function get barValue():Number
		{
			return _barValue;
		}
		
		public function set barValue(value:Number):void
		{
			if(_barValue != value)
			{
				_barValue = value;
				barMask.graphics.clear();
				if(!value)return ;
				var scount:Number = Math.floor(maxSectorCount * value);
				var angleNum:Number = Math.floor(360 / maxSectorCount * scount);
				
				barMask.graphics.drawPie(this.width >> 1 , this.height >> 1, barRadius * 1.2, startAngle,startAngle + angleNum,"#ff0000");
			}
		}
		
		
		protected var _barBg:Node;
		public function get barBg():Node
		{
			return _barBg;
		}

		public function set barBg(value:Node):void
		{
			if(_barBg != value)
			{
				if(_barBg)
					_barBg.removeSelf();
				_barBg = value;
				bgSprite.addChild(_barBg);
			}
		}
		
		protected var _barTop:Node;
		public function get barTop():Node
		{
			return _barTop;
		}
		
		public function set barTop(value:Node):void
		{
			if(_barTop != value)
			{
				if(_barTop)
					_barTop.removeSelf();
				_barTop = value;
				topSprite.addChildAt(_barTop,0);
			}
		}
		
		protected var _startAngle:Number = -90;
		public function get startAngle():Number
		{
			return _startAngle;
		}
		
		public function set startAngle(value:Number):void
		{
			_startAngle = value;
		}
		
		
		protected var _maxSectorCount:Number;
		public function get maxSectorCount():Number
		{
			return _maxSectorCount;
		}
		
		public function set maxSectorCount(value:Number):void
		{
			if(_maxSectorCount != value){
				_maxSectorCount = value;
			}
		}
		
		protected var _barRadius:Number;
		public function get barRadius():Number
		{
			return _barRadius;
		}
		
		public function set barRadius(value:Number):void
		{
			_barRadius = value;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			super.destroy();
			
		}
		
		

	}
}