package game.module.mainScene.guest
{
	/**
	* GuestHomeView 访问别人
	* author:huhaiming
	* InvasionScene.as 2017-4-24 上午10:49:41
	* version 1.0
	*
	*/	
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.BaseScene;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBFog;
	import game.global.event.Signal;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainScene.ArticleData;
	import game.module.mainScene.BaseArticle;
	import game.module.mainScene.BuildPosData;
	import game.module.mainScene.HomeData;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class GuestHomeView extends BaseScene
	{
		///建筑层
		public var buildingLayer:Sprite;
		
		//显示区域
		private var _scrollRect:Rectangle;
		
		private var _data:Object;
		private var _selectedBuilds:Array = [];
		
		/***/
		public function GuestHomeView()
		{
			isResDispose = false;
			m_bCanDrag = true;
		}
		
		override protected function loadMap():void{
			super.loadMap();
			m_sprMap.width = HomeScene.SizeX*HomeScene.CellW;
			m_sprMap.height = HomeScene.SizeY*HomeScene.CellH;
			loadMapCell();
			loadMapCallBack();
		}
		
		protected function loadMapCallBack():void{
			super.onMapLoaded();
			this._scrollRect = new Rectangle(0,0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			this.scrollRect = _scrollRect;
			this.initBuilding()
		}
		
		private var _imgs:Array = [];
		private function loadMapCell():void{
			var url:String;
			var id:Number;
			var img:Image;
			for(var i:int=0; i<HomeScene.SizeY; i++){
				for(var j:int=0; j<HomeScene.SizeX; j++){
					id = i*HomeScene.SizeX + j;
					if(id < 9){
						url = "0"+(id+1)
					}else{
						url = (id+1) + "";
					}
					url = ResourceManager.instance.setResURL("scene/main/mainscene_"+url+".jpg");
					
					img = _imgs[id];
					if(!img){
						img = new Image();
						img.scale(1.25, 1.25);
						_imgs[id] = img;
						m_sprMap.addChildAt(img,0);
						img.pos(j*HomeScene.CellW, i*HomeScene.CellH);
					}
					img.skin = url;
					img.name = url;
				}
			}
		}
		
		private var _nowFogid:int=-1;
		private var _fogImgs:Array = [];
		private var _fogContainer:Sprite;
		private function initMap(fogId:*):void{
			if(!fogId){
				fogId = "1"
			}
			//if(_nowFogid != fogId){
			_nowFogid = fogId;
			var fogInfo:Object = DBFog.getFogInfo(fogId);
			var tmp:Array = (fogInfo.coord_4+"").split(",");
			HomeData.intance.curColumn = parseInt(tmp[0]);
			HomeData.intance.curRow = parseInt(tmp[1]);
			for(var i:int=0; i<8; i++){
				var img:Image = _fogImgs[i];
				if(i > parseInt(_nowFogid)){
					if(!_fogContainer){
						_fogContainer = new Sprite();
						m_sprMap.addChild(_fogContainer);
						_fogContainer.cacheAsBitmap = true;
					}
					if(!img){
						img = new Image(ResourceManager.instance.setResURL("scene/fog/"+i+".png"));
						//img.scale(1.66667, 1.66667);
						img.scale(2, 2);
						_fogImgs[i] = img;
					}else{
						img.skin = "";
						img.skin = ResourceManager.instance.setResURL("scene/fog/"+i+".png")
					}
					img.name = img.skin;
					this._fogContainer.addChild(img);
					var posArr:Array = BuildPosData.getFogPos(i)
					img.pos(posArr[0], posArr[1]);
				}else{
					if(img){
						Loader.clearRes(img.skin);
						img.removeSelf();
						delete _fogImgs[i];
					}
				}
			}
		}
		
		//初始化建筑
		private function initBuilding():void{
			var bitem:BaseArticle
			for(var i:String in _buildItemList){
				bitem = _buildItemList[i]
				bitem.removeSelf()
			}
			this._buildItemList = [];
			
			//初始化
			var info:Object;
			for(i in this._data.build_info.building){
				info = this._data.build_info.building[i];
				bitem = this.createBuilding(info["id"],info["level"],i);
				setBuildPos(bitem, new Point(info["xpos"], info["ypos"]));
			}
			
			SortingFun();
		}
		
		//获取建筑
		private function getBuilding(bid:String):BaseArticle{
			if(!bid){
				return null;
			}
			var bitem:BaseArticle
			for(var i:String in _buildItemList){
				bitem = _buildItemList[i]
				if(bitem.data.id == bid){
					return bitem;
				}
			}
			return null
		}
		
		//根据信息生成建筑数据
		private function createBuilding(id:Number, lv:Number, bid:String = "-1", infoArr:Object=null):BaseArticle{
			var bitem:BaseArticle;
			var bdData:ArticleData;
			if(!bitem){
				bitem = new BaseArticle();
				bdData = new ArticleData();
				var bdVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(id,lv);
				bdData.buildId = "B"+id;
				bdData.level = lv;
				bdData.id = bid;
				bdData.model_w = bdVo.model_w;
				bdData.model_h = bdVo.model_h;
			}else{
				bdData = bitem.data;
			}
			bitem.update(bdData);
			this._buildItemList.push(bitem);
			return bitem;
		}
		
		
		
		protected var _buildItemList:Array = [];
		private function setBuildPos(bitem:BaseArticle,p:Point=null,isPreview:Boolean = false):void{
			if(!p){
				p = HomeData.intance.getNewBuildingPoint(bitem.data);
			}
			bitem.showPoint = bitem.realPoint =  p;
		}
		
		/**
		 * 删除建筑
		 * @param id 建筑的私有ID
		 * */
		private function delBuildingById(id:String):void{
			var bitem:BaseArticle
			for(var i:Number=0; i<this._buildItemList.length; i++){
				bitem = this._buildItemList[i];
				if(bitem.data.id == id){
					this._buildItemList.splice(i,1);
					bitem.removeSelf();
					break;
				}
			}
		}
		
		
		private function SortingFun():void
		{
			this._buildItemList.sort(HomeData.intance.sortFun);
			for (var i:int = 0; i < _buildItemList.length; i++) 
			{
				this.buildingLayer.addChild(_buildItemList[i]);
			}
		}
		
		
		//多点问题
		private var lastDistance:Number = 0;
		private function onMouseUp(e:Event=null):void{
			Laya.stage.off(Event.MOUSE_MOVE, this, onMouseMove);
		}
		private function onMouseDown(e:Event=null):void
		{
			var touches:Array = e.touches;
			
			if(touches && touches.length == 2)
			{
				lastDistance = getDistance(touches);
				
				Laya.stage.on(Event.MOUSE_MOVE, this, onMouseMove);
			}
		}
		private function onMouseMove(e:Event=null):void
		{
			var distance:Number = getDistance(e.touches);
			
			//判断当前距离与上次距离变化，确定是放大还是缩小
			const factor:Number = 0.001;
			var del:Number = (distance - lastDistance) * factor;
			doScale(del);
			
			lastDistance = distance;
		}
		/**计算两个触摸点之间的距离*/
		private function getDistance(points:Array):Number
		{
			var distance:Number = 0;
			if (points && points.length == 2)
			{
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}
		
		
		
		/***/
		private function onScale(e:Event):void{
			var deltaScale:Number = e.delta/30;
			doScale(deltaScale);
		}
		
		private function doScale(deltaScale:Number):void{
			var scale:Number = m_sprMap.scaleX;
			scale += deltaScale;
			if(scale > 1){
				scale = 1;
			}else if(scale < 0.5){
				scale = 0.5;
			}
			
			m_sprMap.scaleX = m_sprMap.scaleY = scale;
			
			this.showDragRegion();
			m_sprMap.stopDrag();
			if(scale != 1){
				if(m_sprMap.x < dragRegion.x){
					m_sprMap.x = dragRegion.x;
				}else if(m_sprMap.x > dragRegion.x+dragRegion.width){
					m_sprMap.x = dragRegion.x+dragRegion.width
				}
				if(m_sprMap.y<dragRegion.y){
					m_sprMap.y = dragRegion.y;
				}else if(m_sprMap.y > dragRegion.y+dragRegion.height){
					m_sprMap.y = dragRegion.y+dragRegion.height
				}
			}
		}
		
		
		override public function initScence():void
		{
			this._loadSceneResCom=false;
			this.m_SceneResource="HomeScene";
			super.initScence();
			
			
			buildingLayer = new Sprite();
			this.m_sprMap.addChild(buildingLayer);
			doScale(-0.5);
		}
		
		override protected function onLoaded():void
		{
			addEvent();
		}
		
		/**覆盖这个方法，达到重用的效果*/
		override public function show(...args):void{
			this._data = args[0];
			trace("_data.......................",_data)
			if(!m_sprMap){
				initScence();
				this.loadMap();
			}else{
				onStageResize();
				initBuilding();
				loadMapCell();
			}
			initMap(_data.fog);
			super.show();
			XFacade.instance.closeModule(MainView)
			XFacade.instance.showModule(GuestMenuView, _data);
		}
		
		override public function close():void{
			super.close();
			for(var i:int=0; i<_imgs.length; i++){
				_imgs[i].skin = "";
			}
			for(var i:int=0; i<_fogImgs.length; i++){
				if(_fogImgs[i]){
					Laya.loader.clearRes(_fogImgs[i].skin);
					_fogImgs[i].skin = "";
				}
			}
			var item:BaseArticle;
			for(i=0; i<_buildItemList.length; i++){
				item = _buildItemList[i];
				item.releaseSkin();
			}
			this._data = null;
		}
		
		override public function onStageResize():void
		{
			if(!_scrollRect.width != LayerManager.instence.stageWidth || _scrollRect.height != LayerManager.instence.stageHeight){
				this.scrollRect = new Rectangle(0,0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			}
		}
		
		override public function onStartDrag(e:Event=null):void
		{
			//鼠标按下开始拖拽(设置了拖动区域和超界弹回的滑动效果)
			if(isDrag)
			{
				showDragRegion();
				m_sprMap.startDrag(dragRegion,true, 0, 300,null, true);
			}
		}
		
		override public function init():void{
			//just do nothing.
		}
		
		override public function addEvent():void{
			this.on(Event.MOUSE_WHEEL, this, this.onScale);
			Laya.stage.on(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
			addDragEvent();
		}
		
		
		public override function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.MOUSE_WHEEL, this, this.onScale);
			Laya.stage.off(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
		}
		
		/**
		 * 
		 * 静态逻辑,访问------------------------------------------
		 * @param uid 用户ID
		 * @param handdler 访问成功回调
		 **/
		private static var _handdler:Handler;
		public static function visit(uid:String, handdler:Handler=null):void{
			_handdler = handdler;
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.IN_getHomeByUid), null, onResult);
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ERROR), null, onErr);
			WebSocketNetService.instance.sendData(ServiceConst.IN_getHomeByUid, [uid]);
		}
		
		private static function onResult(...args):void{
			if(_handdler){
				_handdler.run();
			}
			_handdler = null;
			SceneManager.intance.setCurrentScene(SceneType.S_GUEST, false, 1, args[1]);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_getHomeByUid), null, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), null, onErr);
		}
		
		private static function onErr(...args):void{
			_handdler = null;
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_getHomeByUid), null, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), null, onErr);
			var cmd:Number = args[1];
			var errStr:String = args[2]
			switch(cmd){
				case SceneType.S_GUEST:
					XTip.showTip(GameLanguage.getLangByKey(errStr));
					break;
			}
		}
	}
}

