/***
 *作者：罗维
 */
package game.global.fighting.manager
{
	
	
	import game.global.data.fightUnit.fightUnitData;
	import game.module.fighting.scene.FightingScene;
	
	import laya.maths.Point;

	public class FightingSceneManager
	{
		/***
		 *全局配置表控制器 
		 */
		private static var _instance:FightingSceneManager;
		
		
		public function FightingSceneManager()
		{
			if(_instance){				
				throw new Error("FightingSceneManager是单例,不可new.");
			}
			_instance = this;
		}
		
		public static function get rowRightPointKey():Object
		{
			if(!_rowRightPointKey)
			{
				_rowRightPointKey = {};
				_rowRightPointKey[0] = 0;
				var ban:Number = (FightingScene.squareRow - 1) / 2;
				var z:int = 1;
				for (var i:int = 1; i <= ban; i++) 
				{
					_rowRightPointKey[0 - i] = z;
					z++;
					_rowRightPointKey[i] = z;
					z++;
				}
			}
			
			
			return _rowRightPointKey;
		}

		
		public static function gerPointIndex(n:Number,ns:Object):int{
			for (var k:* in ns) 
			{
				if(Number(ns[k]) == n)
					return Number(k);
			}
			return -1;
		}
		
		public static function get rowLeftPointKey():Object
		{
			if(!_rowLeftPointKey)
			{
				_rowLeftPointKey = {};
				_rowLeftPointKey[0] = 0;
				var ban:Number = (FightingScene.squareRow - 1) / 2;
				var z:int = 1;
				for (var i:int = 1; i <= ban; i++) 
				{
					_rowLeftPointKey[i] = z;
					z++;
					_rowLeftPointKey[0 - i] = z;
					z++;
				}
			}
			
			return _rowLeftPointKey;
		}

		public static function get intance():FightingSceneManager
		{
			if(_instance)
				return _instance;
			_instance = new FightingSceneManager();
			return _instance;
		}
		
		private var _init:Boolean;
		public function init():void
		{
			if(!_init)
			{
				mainMapMatrix;
				
				ininTile();
			}
		}
		
		
		public function copyTileMapData():Object
		{
			var obj:Object = {};
			for(var key:* in tileMapData)
			{
				obj[key] = tileMapData[key];
			}
			return obj;
		}
		
		public var tilePointList:Object = {};
		public var tilePointKeyV1:Object = {};
		public var tilePointKeyV2:Object = {};
		public var tilePointKeyV3:Object = {};
		public var tileMapData:Object = {};
		
		private static var _rowLeftPointKey:Object;
		private static var _rowRightPointKey:Object;
		
		public function ininTile():void{
			for (var i:int = 0; i < FightingScene.squareColumn * 2 + 1; i++) 
			{
				for (var j:int = 0; j < FightingScene.squareRow; j++) 
				{
					var pi:Point = new Point();
					pi.x =  (i + j) * FightingScene.tileW / 2;
//					pi.y =  0 - (i - j - FightingScene.squareColumn * 2  + 1) * FightingScene.tileH / 2 ;
					pi.y =  0 - (i - j - FightingScene.squareColumn * 2 ) * FightingScene.tileH / 2  - FightingScene.tileH;
					
					
					//坐标第一次换算

					//坐标第一次换算
					var ban:int = Math.ceil(FightingScene.squareRow / 2);
					var jN:int = j;
					var iN:int = i;
					jN ++ ;
					iN ++ ;
//					jN = jN <= ban  ? 0 - jN + ban : jN - 1; 
					jN -= ban;
					jN = rowRightPointKey[jN];
					iN = iN <= FightingScene.squareColumn + 1 ? FightingScene.squareColumn + 1 - iN :
						iN - FightingScene.squareColumn - 1;
					
					
					if((i >= 0 && i < FightingScene.squareColumn) || (i >= FightingScene.squareColumn && i <= FightingScene.squareColumn * 2) )
					{
						var key:String = (i >= 0 && i < FightingScene.squareColumn) ? "1" : "2";
						key += iN;
						key += jN;
						key = "point_" + key;
						tilePointList[key] = pi;
						
//						pi.y -= (FightingScene.tileH/2);
						var tilePoint:Point = getTilePoint(FightingScene.tileW, FightingScene.tileH, pi.x + FightingScene.tileW/2, pi.y + FightingScene.tileH/2);
						tilePointKeyV3[tilePoint.x + "_"+tilePoint.y] = key;
						tileMapData[key] = 2;
						if(isAddTitle(j,i)){
							tileMapData[key] = 0;
						}
						tilePointKeyV1[key] = new Point(i,j);
						tilePointKeyV2[i+"_"+j] = key;
						
					}
				}
			}
		}
		
		protected function isAddTitle(j:int , i:int):Boolean{
//			return true;
			//第一排不要放 楚河汉界不要放  最后一排不要放
//						return true;
			if( i == 0 || i == FightingScene.squareColumn || i == FightingScene.squareColumn * 2)
				return false;
			if( i == 1 || i == FightingScene.squareColumn * 2 - 1)
			{
				if( j == 1 || j == FightingScene.squareRow - 2)
					return false;
			}
			if( j == 0 || j == FightingScene.squareRow - 1)
				return false;
			return true;
		}
		
		
		//矩阵集合
		private var _mainMapMatrix:Array;
		public var maxX:uint;
		public var maxY:uint;
		public var mapWidth:uint;
		public var mapHeight:uint;
		public var tilePixelWidth:uint;
		public var tilePixelHeight:uint;
		public function get mainMapMatrix():Array{
			if(!_mainMapMatrix){
				
				var i:int = 0;
				var j:int = 0;
				var minX:int=0;
				var minY:int=0;
				var pointAr:Array = [];	
				var ar:Array;
				var wHalfTile:uint = Math.round(tilePixelWidth/2);
				var hHalfTile:uint = Math.round(tilePixelHeight/2); 
				
				for (i = 0; i<mapHeight; i++)
				{
					ar = [];
					pointAr.push(ar);
					for (j= 0; j<mapWidth; j++)
					{
						var showX:Number = j * tilePixelWidth + (i&1) * wHalfTile + wHalfTile ;
						var showY:Number = i * hHalfTile + hHalfTile  ;
						var N:uint=Math.round(showX/tilePixelWidth - showY/tilePixelHeight);
						N = 0 - N;
						var M:uint =Math.round(showX/tilePixelWidth + showY/tilePixelHeight);
						minX = Math.min(minX,N);
						minY = Math.min(minY,M);
						//						ar.push([N,M]);
						ar.push(new Point(N,M));
					}
				}
				
				for (i = 0; i<mapHeight; i++)
				{
					ar = pointAr[i];
					for (j= 0; j<mapWidth; j++)
					{
						ar[j].x = ar[j].x - minX + 1;
						ar[j].y = ar[j].y - minY + 1;
						
						maxX = Math.max(ar[j].x,maxX); 
						maxY = Math.max(ar[j].y,maxY); 
					}
				}
				
				_mainMapMatrix = pointAr;
			}
			return _mainMapMatrix;
		}
		
		
		public function getNewUnitPoint(uData:fightUnitData , mapTileList:Object):String{
			
//			return "110";
			var pPr:Array = [0,1,2,3,4];
			if(uData.unitVo.isBadItem)
				return getNewUnitPoint2([1,2,3],pPr,uData.direction,mapTileList);
			else
			{
				switch(uData.unitVo.defense_type)
				{
					case 1:  //重甲
					{
						return getNewUnitPoint2([1,2,3],pPr,uData.direction,mapTileList);
						break;
					}
					case 2:  //中甲
					{
						return getNewUnitPoint2([2,1,3],pPr,uData.direction,mapTileList);
						break;
					}	
					default:
					{
						return getNewUnitPoint2([3,2,1],pPr,uData.direction,mapTileList);
						break;
					}
				}
			
			}
			return null;
		}
		
		public function getNewUnitPoint2(par1:Array,par2:Array,direction:Number,mapTileList:Object):String{
			
			var ks:Array = [];
			for (var i:int = 0; i < par1.length; i++) 
			{
				for (var j:int = 0; j < par2.length; j++) 
				{
					ks.push(
						"point_"+direction+""+par1[i]+""+par2[j]
					);
				}
			}
			
			for (var k:int = 0; k < ks.length; k++) 
			{
				var key:String = ks[k];
				if(mapTileList.hasOwnProperty(key))
				{
					if(mapTileList[key] == 0)
						return key;
				}
			}
			return null;
		}
		
		
		
		public function getTilePoint(tileWidth:int, tileHeight:int, px:int, py:int):Point
		{
			var xtile:int = 0;	//网格的x坐标
			var ytile:int = 0;	//网格的y坐标
			
			var cx:int, cy:int, rx:int, ry:int;
			
			
			cx = Math.floor(px / tileWidth) * tileWidth + tileWidth/2;	//计算出当前X所在的以tileWidth为宽的矩形的中心的X坐标
			cy = Math.floor(py / tileHeight) * tileHeight + tileHeight/2;//计算出当前Y所在的以tileHeight为高的矩形的中心的Y坐标
			
			rx = (px - cx) * tileHeight/2;
			ry = (py - cy) * tileWidth/2;
			
			if (Math.abs(rx)+Math.abs(ry) <= tileWidth * tileHeight/4)
			{
				//xtile = int(pixelPoint.x / tileWidth) * 2;
				xtile = Math.floor(px / tileWidth);
				ytile = Math.floor(py / tileHeight) * 2;
			}
			else
			{
				px = px - tileWidth/2;
				//xtile = int(pixelPoint.x / tileWidth) * 2 + 1;
				xtile = Math.floor(px / tileWidth) + 1;
				
				py = py - tileHeight/2;
				ytile = Math.floor(py / tileHeight) * 2 + 1;
			}
			
			return new Point(xtile - (ytile&1), ytile);
		}
		
	}
}