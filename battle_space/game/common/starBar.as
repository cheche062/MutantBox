/***
 *作者：罗维
 */
package game.common
{
	import laya.display.Sprite;
	import laya.ui.Image;

	public class starBar extends Sprite
	{
		protected var m_imgUrl1:String;
		protected var m_imgUrl2:String;
		protected var m_imgW:Number;
		protected var m_imgH:Number;
		protected var m_starSpacing:Number;
		protected var m_starHSpacing:Number;
		protected var m_maxStar:Number;
		//决定是否分行显示,-1不分
		private var _sizeX:Number = -1;
		
		
		public function starBar(_imgUrl1:String = "common/sectorBar/progress1_1.png",
								_imgUrl2:String = "common/sectorBar/progress1.png",
								_imgW:Number = 16 , _imgH:Number = 18, _starSpacing:Number = -8,_maxStar:Number = 10, sizeX:Number=-1 , _starHSpacing:Number = -7
		)
		{
			super();
			m_imgUrl1 = _imgUrl1;
			m_imgUrl2 = _imgUrl2;
			m_imgW = _imgW;
			m_imgH = _imgH;
			m_starSpacing = _starSpacing;
			m_maxStar = _maxStar;
			_sizeX = sizeX;
			m_starHSpacing = _starHSpacing;
			barValue = 0;
		}
		
		private var _barValue:Number = -1;

		public function get maxStar():Number
		{
			return m_maxStar;
		}

		public function set maxStar(value:Number):void
		{
			if(m_maxStar != value){
				m_maxStar = value;
				changeValue();
			}
		}

		public function get barValue():Number
		{
			return _barValue;
		}

		public function set barValue(value:Number):void
		{
			if(_barValue != value){
				_barValue = value;
				changeValue();
			}
		}
		
		
		public function changeValue():void{
			this.graphics.clear();
			var xSize:Number = _sizeX;
			if(xSize == -1){
				xSize =  m_maxStar;
			}
			var maxWW:Number = 0;
			var maxHH:Number = 0;
			for (var i:int = 0; i < m_maxStar; i++) 
			{
				var opx:Number = i%xSize * (m_imgW + m_starSpacing);
				var opy:Number = Math.floor(i/xSize)*(m_imgH + m_starHSpacing);
				var opImg:String = i < _barValue ? m_imgUrl1 : m_imgUrl2;
				this.loadImage(opImg,opx,opy);
			}
			var hang:Number = Math.ceil(m_maxStar / xSize);
			this.size( (m_imgW + m_starSpacing) * (xSize - 1) + m_imgW , 
					   (m_imgH + m_starHSpacing) * (hang - 1) + m_imgH
			);
		}

	}
}