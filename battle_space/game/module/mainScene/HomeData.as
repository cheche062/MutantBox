package game.module.mainScene
{
	/**
	 * 主场景数据
	 */
	import game.common.ResourceManager;
	
	import laya.maths.Point;
	import laya.maths.Rectangle;

	public class HomeData
	{
		//public static const tileW:Number = 116;  //网格宽度
		//public static const tileH:Number = 58;  //网格高度
		/**打开主界面国战地图*/
		public static const MAIN_BTNJUNTUAN:String = "main_btnJuntuan";
		/**
		 * 网格宽度
		 */
		public static const tileW:Number = 100;  //
		/**网格高度
		 * 
		 */
		public static const tileH:Number = 50;  //
		
		/**
		 * 网格横向数量
		 */
		public static const tileColumn:uint = 48; 
		/**
		 * 网格纵向数量
		 */
		public static const tileRow:uint = 49; 
		
		//地图偏移量
		//public static const OffsetX:Number = -900//1740;
		//地图偏移量Y
		//public static const OffsetY:Number  = 1380//348;//
		
		/**地图数据*/
		public var mapTileData:Object = {};
		
		/**
		 * 网格横向数量-w
		 */
		public var curColumn:uint = 48; 
		/**
		 * 网格纵向数量-h
		 */
		public var curRow:uint = 49;  
		/***
		 *全局配置表控制器 
		 */
		private static var _instance:HomeData;
		
		
		public function HomeData()
		{
			if(_instance){				
				throw new Error("HomeSceneManager是单例,不可new.");
			}
			_instance = this;
		}
		
		
		//地图偏移量
		private static var _OffsetX:Number = -280//1740;
		//地图偏移量Y
		private static var _OffsetY:Number  = 1640//348;//
		public static function get OffsetX():Number{
			return BuildPosData.offX;
		}
		public static function get OffsetY():Number{
			return BuildPosData.offY;
		}
			
		public static function get intance():HomeData
		{
			if(!_instance){
				_instance = new HomeData();
			}
			return _instance;
		}
		
		public function resetMapData():void{
			mapTileData = copyMap();
//			trace("块数据:"+JSON.stringify(mapTileData));
		}
		
		public function copyMap():Object{
			var block:Array  = config.block;
			var map:Object = {};
			var key:String = '';
			var idx:int=0;
			while(idx < block.length){
				key = block[idx]+"_"+block[idx+1];
				map[key] = 1;
				idx += 2;
			}
//			trace("map:"+JSON.stringify(map));
			return map;
		}
		
		public function getNewBuildingPoint(bData:ArticleData):Point{
			var w:Number = curColumn
			var h:Number = curRow;
			var pi:Point = new Point();
			//5次随机，然后换遍历算法.
			for(var i:int=0; i<5; i++){
				pi.x = Math.floor(Math.random()*w);
				pi.y = Math.floor(Math.random()*h);
				if(isOk(bData,pi)){
					return pi;
				}
			}
			
			//遍历，从最下边开始
			for (i = w-1; i >-1; i--) 
			{
				for (var j:int = h-1; j >-1; j--) 
				{
					pi.x = i
					pi.y = j
					if(isOk(bData,pi)){
						return pi;
					}
				}
				
			}
			return null;
		}
		
		public function isOk(bData:ArticleData, pi:Point):Boolean{
			var w:Number = curColumn
			var h:Number = curRow;
			//越界判定
			if(pi.x<0 || pi.x >= w || pi.y <0 || pi.y>= h){
				return false;
			}
			var pAr:Array = [];
			var sizeX:Number = bData.model_w;
			var sizeY:Number = bData.model_h;
			//再次越界判定
			if(pi.x-sizeX<-1 || pi.y -sizeY <-1){
				return false;
			}
			for(var i:int=0; i<sizeX; i++){
				for(var j:int=0; j<sizeY; j++){
					pAr.push(new Point(pi.x-i,pi.y-j));
				}
			}
			
			
			for (i = 0; i < pAr.length; i++) 
			{
				var key:String = pAr[i].x + "_" + pAr[i].y;
				if(mapTileData[key] > 0){
					return false;
				}
					
			}
			return true;
		}
		
		//排序算法
		public function sortFun(target:BaseArticle , item:BaseArticle ):int{
			/*var tarY:Number = target.showPoint.y-target.data.model_h;
			var itemY:Number = item.showPoint.y-item.data.model_h
			if (tarY > itemY) {
				return 1;
			}else if (tarY < itemY) {
				return -1;
			}else{
				var tarX:Number = target.showPoint.x-target.data.model_w;
				var itemX:Number = item.showPoint.x-item.data.model_w
				if(tarX < itemX){
					return -1
				}else if(tarX > itemX){
					return 1
				}
			}
			return 0;*/
			
			var p1:Point = HomeData.intance.getPointPos(target.showPoint.x-target.data.model_w,target.showPoint.y-target.data.model_h);
			var p2:Point = HomeData.intance.getPointPos(item.showPoint.x-item.data.model_w,item.showPoint.y-item.data.model_h);
			if(p1.y > p2.y){
				return 1;
			}else if(p1.y < p2.y){
				return -1
			}else{
				if(p1.x < p2.x){
					return 1;
				}else if(p1.x>p2.x){
					return -1;
				}
			}
			return 0;
		}
		
		/**
		 * 修改怪物入侵中怪物的站位
		 * @param x
		 * @parma y
		 * @parma r
		 * @param v 1/-1,-1表示移除
		 * */
		public function addMonsterBlock(x:int, y:int, r:int, v:Number=1):Array{
			//r = r + 1;//需要+1，不然会小一格;
			var pList:Array = [];
			for(var i:int=0; i<r; i++){
				for(var j:int=0;j<r-Math.floor(i*.5); j++){
					pList.push([x+i, y+j]);
					pList.push([x+i, y-j]);
					
					pList.push([x-i, y+j]);
					pList.push([x-i, y-j]);
				}
			}
			pList = deleteRepeat(pList);
			//
			var xp:Number;
			var yp:Number;
			var key:String;
			for(i=pList.length-1; i>-1; i--){
				xp = pList[i][0];
				yp = pList[i][1];
				if(checkPoint(xp, yp)){
					key = xp + "_" + yp;
					if(mapTileData[key] > 0){
						mapTileData[key] = parseInt(mapTileData[key]) + v
					}else{
						mapTileData[key] = v;
					}
					if(v == -1){
						trace(key,"---------------------------",mapTileData[key]);
					}
					if(mapTileData[key] <= 0 ){
						delete mapTileData[key]
					}
				}
			}
			return pList;
		}
		
		//功能函数，删除重复的
		private function deleteRepeat(arr:Array):Array{
			var tempArr:Array;
			for(var i:int=0; i<arr.length; i++){
				tempArr = arr[i];
				for(var j:uint=i+1; j<arr.length; j++){
					if(tempArr[0] == arr[j][0] && tempArr[1] == arr[j][1]){
						arr.splice(j,1);
						j--;
					}
				}
			}
			return arr;
		}
		
		
		/**
		 *修改障碍数据
		 */
		public function modifyData(bd:BaseArticle,value:int = 1):void
		{
			//trace(bd.data.buildId+"=============================================",value)
			/*if(value == -1){
				trace("v=============================================",value)
			}*/
			var i:int = 0;
			var key:String;
			
			for(i=bd.data.showPoint.x; i>bd.data.showPoint.x-bd.data.model_w; i--){
				for(var j:int=bd.data.showPoint.y;j> bd.data.showPoint.y-bd.data.model_h; j--){
					key = i+"_"+j;
					if(mapTileData[key]){
						mapTileData[key] = parseInt(mapTileData[key]) + value;
					}else{
						mapTileData[key] = value
					}
					if(parseInt(mapTileData[key]) == 0){
						delete mapTileData[key]
					}
				}
			}
			//trace(mapTileData);
			return;
		}
		
		/**判定点是否越界*/
		public function checkPoint(x:Number, y:Number):Boolean{
			//越界判定
			if(x<0 || x >= HomeData.tileColumn || y <0 || y>= HomeData.tileRow){
				return false;
			}
			return true
		}
		
		/**判断两个建筑是否有交集*/
		public function checkCross(nbuild:BaseArticle, target:BaseArticle):Boolean{
			var rect:Rectangle = new Rectangle(nbuild.data.showPoint.x-nbuild.data.model_w,nbuild.data.showPoint.y-nbuild.data.model_h,
				nbuild.data.model_w-0.1,nbuild.data.model_h-0.1);
			var rect2:Rectangle = new Rectangle(target.data.realPoint.x-target.data.model_w,target.data.realPoint.y-target.data.model_h,
				target.data.model_w-0.1,target.data.model_h-0.1);
			//trace(rect.intersection(rect2),"xxxxxxxxxxxxxxxxxxxxrect")
			return rect.intersection(rect2) != null;
		}
		
		
		/**
		 * 获取能够交换的建筑
		 * 算法思路：1，获取与build站位点重合的点,2:判定站位大的建筑是否能放下；3，如果可以，返回这个建筑，否则返回空
		 */
		public function getExchangeBuild(build:BaseArticle, buildList:Array):BaseArticle{
			var tmp:BaseArticle
			var target:BaseArticle
			var result:int;
			for(var i:int=0; i<buildList.length; i++){
				tmp = buildList[i];
				if(tmp != build && tmp.data.type == ArticleData.TYPE_BUILDING){
					result = coincide(build, tmp)
					if(result > 0){
						target = tmp;
						break;
					}
				}
			}
			if(result == 0){
				return null;
			}
			//判定是否能放得下----------------
			//重新设定算法,1，先放交换的建筑（target）,如果能放得下（判定build是否能方向[能-返回target/不能-返回null]）如果放不下，返回null,前提：build的站位数据已经清楚掉了
			//判定target情况
			//判定target情况,如果能放下--
			if(isOk(target.data, build.realPoint)){
				//暂时扔掉target站位数据
				modifyData(target, -1);
				//判断build是否能放下
				if(isOk(build.data, target.realPoint)){
					modifyData(target, 1);
					return target;
				}else{
					modifyData(target, 1);
					return null;
				}
			}
			return null;
		}
		
		
		
		/**
		 *判断两个建筑站位是否重合
		 * 算法：如果建筑的规格小，则
		 * @return 0不重合，1重合build1是小建筑，2，重合build2是小建筑
		 */
		private function coincide(build1:BaseArticle , build2:BaseArticle):int{
			var result:int = 0;
			
			if(build1.data.model_w <= build2.data.model_w && build1.data.model_h<= build2.data.model_h){
				result = 1;
				//判定坐标问题---如果小建筑的x/y大于大建筑的x/y，则可以判定不重合；
				if(build1.data.showPoint.x > build2.data.realPoint.x || 
					build1.data.showPoint.y > build2.data.realPoint.y){
					return 0;
				}
				//判定站位问题===================
				if(build1.data.showPoint.x -  build1.data.model_w < build2.data.realPoint.x -  build2.data.model_w || 
					build1.data.showPoint.y -  build1.data.model_h < build2.data.realPoint.y -  build2.data.model_h){
					return 0
				}
			}else if(build1.data.model_w >= build2.data.model_w && build1.data.model_h>= build2.data.model_h){
				result = 2;
				if(build1.data.showPoint.x < build2.data.realPoint.x || 
					build1.data.showPoint.y < build2.data.realPoint.y){
					return 0;
				}
				//判定站位问题===================
				if(build1.data.showPoint.x -  build1.data.model_w > build2.data.realPoint.x -  build2.data.model_w || 
					build1.data.showPoint.y -  build1.data.model_h > build2.data.realPoint.y -  build2.data.model_h){
					return 0
				}
			}
			return result;
		}
		
		
		/**
		 * 根据屏幕象素坐标取得网格的坐标
		 * tileWidth  tile的象素宽
		 * tileHeight tile的象素高
		 * px 象素坐标x
		 * py 象素坐标x
		 * return 网格坐标的点
		 */
		public function getTilePoint(tileWidth:int, tileHeight:int, px:int, py:int, offsetX:Number, offsetY:Number):Point
		{
			var xtile:int = 0;	//网格的x坐标
			var ytile:int = 0;	//网格的y坐标
			
			//N=int(x/TileW - y/TileH)
			//M=int(x/TileW + y/TileH)
			
			/**
			int getGx(int x, int y)   
			{  
				return (int) (0.5f * (y / (CHIP_H >> 1) + x / (CHIP_W >> 1)));   
			}  
			
			int getGy(int x, int y)   
			{  
				return (int) (0.5f * (y / (CHIP_H >> 1) - x / (CHIP_W >> 1)));   
			} 
			 */
			//xtile = Math.floor((px - offsetX) / tileWidth - (py-offsetY)/tileHeight);
			//ytile = Math.floor((px - offsetX) / tileWidth + (py-offsetY)/tileHeight);
			
			var dx:Number = px - offsetX
			var dy:Number = py - offsetY
			var N:Number =HomeData.tileColumn - 1 - Math.floor(dx/tileWidth - dy/tileHeight)
			var M:Number =Math.floor(dx/tileWidth + dy/tileHeight)
			
			//trace("xtile::ytile",N,M);
			return new Point(N,M);
		}
		
		/**根据点位推算坐标*/
		private var originP:Point;
		public function getPointPos(x:int,y:int):Point{
			var tileW:Number = HomeData.tileW;
			var tileH:Number = HomeData.tileH;
			var newX:int = 1880;
			var newY:int = 400;
			var pIdxs:Array = [x, y];
			if(!originP){
				originP = new Point();
				originP.x = HomeData.tileColumn * tileW /2 + HomeData.OffsetX;
				originP.y = 0 + HomeData.OffsetY - HomeData.tileColumn*tileH/2;
			}
			//this.x = originP.x + (pIdxs[1] - pIdxs[0]) * tileW/2;
			//this.y = originP.y + (pIdxs[0] + pIdxs[1]) * tileH/2 + tileH;
//			trace("originP:"+originP.x+","+originP.y);
			return new Point(originP.x + (pIdxs[1] - pIdxs[0]) * tileW/2,originP.y + (pIdxs[0] + pIdxs[1]) * tileH/2 + tileH)
		}
		
		/**主场景配置数据*/
		private static var _config:Object;
		public static function get config():Object{
			if(!_config){
				_config = ResourceManager.instance.getResByURL("staticConfig/HomeSceneConfig.json"); 
			}
//			trace("地图数据:"+JSON.stringify(_config));
			return _config;
		}
	}
}