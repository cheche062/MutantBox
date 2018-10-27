package game.module.mainScene
{
	import game.common.SceneManager;
	
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.resource.Texture;
	import laya.ui.Button;
	
	public class GridSprite extends Sprite
	{
		protected var gridLineLayer:Sprite;		//网格线层
		protected var maskLayer:Sprite;	//迷雾层
		
		protected var wHalfTile:int;	//网格象素宽的一半
		protected var hHalfTile:int;	//网格象素高的一半
		private var _mapData:Object;
		private var _curW:Number;
		private var _curH:Number;
		//一次性参数
		private var _param:Array;
		
		public function GridSprite()
		{
			super();
			this.alpha = 0.3;
		}
		
		/**初始化参数*/
		public function initParam(mapWidth:int, mapHeight:int,curW:Number,curH:Number, tilePixelWidth:int, tilePixelHeight:int,
								  beginX:int = 0 , beginY:int = 0):void{
			_param = [mapWidth, mapHeight, curW, curH, tilePixelWidth, tilePixelHeight, beginX, beginY];
		}
		
		/**
		 * 画网格
		 * disArea -- 是否显示可视区域
		 */
		public function drawGrid(mapWidth:int, mapHeight:int,curW:Number,curH:Number, tilePixelWidth:int, tilePixelHeight:int,
								 beginX:int = 0 , beginY:int = 0):void
		{
			//curW = curH = 10;
			_curW = curW;
			_curH = curH;
			trace("------------------",mapWidth,mapHeight, curW, curH);
			this._mapData = HomeData.intance.copyMap();
			
			this.wHalfTile = Math.floor(tilePixelWidth/2);
			this.hHalfTile = Math.floor(tilePixelHeight/2);
			
			if(!this.gridLineLayer){
				this.gridLineLayer = new Sprite();
				
				this.addChild(this.gridLineLayer);
			}else{
				this.gridLineLayer.graphics.clear();
			}
			
			var dblMapWidth:int = mapWidth*2 + 1;
			var dblMapHeight:int = mapHeight + 1;
			var goPoint:Point = new Point();
			var toPoint:Point = new Point();
			var newX:int = 1880;
			var newY:int = 400;
//			for(var i:int=mapWidth-curW; i<=mapWidth; i++){
//				var arr:Array = getYArr(mapWidth-i,curH);
//				for(var j:int=0; j<arr.length; j++){
//					goPoint.x = beginX+arr[j]*wHalfTile + i*wHalfTile;
//					goPoint.y = beginY+arr[j]*hHalfTile - i*hHalfTile;
//					
//					toPoint.x = beginX+(arr[j+1])*wHalfTile + i*wHalfTile;
//					toPoint.y = beginY+(arr[j+1])*hHalfTile - i*hHalfTile;
//					this.gridLineLayer.graphics.drawLine(goPoint.x,goPoint.y,toPoint.x, toPoint.y ,"#ffffff", 1 );
//					j++;
//				}
//			}
			//新的算法尝试
			for(var i:int=0; i<=curW; i++){
				var arr:Array = getYArr(i,curH);
				for(var j:int=0; j<arr.length; j++){
					goPoint.x = newX+arr[j]*wHalfTile - i*wHalfTile;
					goPoint.y = newY+arr[j]*hHalfTile + i*hHalfTile;
					
					toPoint.x = newX+(arr[j+1])*wHalfTile - i*wHalfTile;
					toPoint.y = newY+(arr[j+1])*hHalfTile + i*hHalfTile;
					this.gridLineLayer.graphics.drawLine(goPoint.x,goPoint.y,toPoint.x, toPoint.y ,"#ffffff", 1 );
					j++;
				}
			}
//			for(i=0; i<=curH; i++){
//				arr = getXArr(i,curW);
//				for(j=0; j<arr.length; j++){
//					goPoint.x = beginX+(i+(mapWidth-arr[j]))*wHalfTile;
//					goPoint.y = beginY+(i-(mapWidth-arr[j]))*hHalfTile
//					
//					toPoint.x = beginX+(i+(mapWidth-arr[j+1]))*wHalfTile;
//					toPoint.y = beginY+(i-(mapWidth-arr[j+1]))*hHalfTile;
//					this.gridLineLayer.graphics.drawLine(goPoint.x,goPoint.y,toPoint.x, toPoint.y ,"#ffffff", 1 );
//				
//					j++;
//				}
//			}
			for(i=0; i<=curH; i++){
				arr = getXArr(i,curW);
				for(j=0; j<arr.length; j++){
					goPoint.x = newX-arr[j]*wHalfTile+i*wHalfTile;
					goPoint.y = newY+arr[j]*hHalfTile+i*hHalfTile;
					
					toPoint.x = newX-arr[j+1]*wHalfTile+i*wHalfTile;
					toPoint.y = newY+arr[j+1]*hHalfTile+i*hHalfTile;
					this.gridLineLayer.graphics.drawLine(goPoint.x,goPoint.y,toPoint.x, toPoint.y ,"#ffffff", 1 );
					
					j++;
				}
			}
			this.gridLineLayer.cacheAsBitmap = true;
			this._mapData = null
		}
		
		/**
		 * 确定x坐标，找一个能画的Y轴起点坐标
		 * @param x
		 * @param maxY
		 * @return 
		 * 
		 */
		private function getYArr(x:int, maxY:Number):Array{
			var key:String;
			var key2:String;
			var arr:Array = [];
			var n:int=0;
			for(var i:int=0;i<=maxY; i++){
				key = (x-1)+"_"+i;
				key2 = x+"_"+i;
				if(x < 1){
					key = key2;
				}else if(x == _curW){
					key2 = key;
				}
				if((!_mapData[key] || !_mapData[key2])&& n == 0){//找开始点
					arr.push(i);
					n = 1; 
				}else if(_mapData[key] && _mapData[key2] && n == 1 && arr.length){//找结束点
					arr.push(i);
					n = 0;
				}
			}
			if(arr.length%2 != 0){
				arr.push(maxY);
			}
			trace(x,"getYArr==============",maxY,arr);
			return arr;
		}
		
		//
		/**
		 * 确定Y坐标，找一个能画的x轴起点坐标
		 * @param y
		 * @param maxX
		 * @return 
		 * 
		 */
		private function getXArr(y:int, maxX:Number):Array{
			var key:String;
			var key2:String;
			var arr:Array = [];
			var n:int=0;
			for(var i:int=0;i<=maxX; i++){
				key = i+"_"+(y-1);
				key2 = i+"_"+y;
				if(y < 1){
					key = key2;
				}else if(y == _curH){
					key2 = key;
				}
				if((!_mapData[key] || !_mapData[key2]) && n == 0){//找开始点
					arr.push(i);
					n = 1;
				}else if(_mapData[key] && _mapData[key2] && n == 1 && arr.length){//找结束点
					arr.push(i);
					n = 0;
				}
			}
			if(arr.length%2 != 0){
				arr.push(maxX);
			}
//			trace(y,maxX,"getXArr==============",arr);
			return arr;
		}
		
		
		
		public function showGrid(v:Boolean):void{
			if(v && _param){
				this.drawGrid.apply(this,_param);
				_param = null;
			}
			if(gridLineLayer){
				this.gridLineLayer.visible = v;
			}
		}
		
		/**画迷雾*/
		private const STEP:int = 4;
		public function drawMask(dw:Number, dh:Number,mapWidth:Number,mapHeight:Number):void{
			if(!maskLayer){
				maskLayer = new Sprite();
				new Button
				this.addChild(maskLayer);
			}else{
				maskLayer.graphics.clear();
			}
			var tex:Texture = Loader.getRes("mainUi\/brick.png");
			
			for(var i:int=0; i<mapWidth-1; i=i+STEP){
				for(var j:int=0; j<mapHeight-1; j=j+STEP){
					//如果不在有效区域内，则画迷雾
					if(i < dw && j < dh){
						//donothing
					}else{
						var p:Point = getPointPos(i, j);
						maskLayer.graphics.drawTexture(tex,p.x-tex.sourceWidth/2, p.y)
					}
				}
			}
		}
		
		private function getPointPos(xp:Number, yp:Number):Point{
			var pIdxs:Array = [xp, yp]
			var tileW:Number = HomeData.tileW;
			var tileH:Number = HomeData.tileH;
			var originP:Point = new Point();
			originP.x = HomeData.tileColumn * tileW /2 + HomeData.OffsetX;
			originP.y = 0 + HomeData.OffsetY - HomeData.tileColumn*tileH/2;
			return new Point(originP.x + (pIdxs[1] - pIdxs[0]) * tileW/2, originP.y + (pIdxs[0] + pIdxs[1]) * tileH/2);
		}
	}
}