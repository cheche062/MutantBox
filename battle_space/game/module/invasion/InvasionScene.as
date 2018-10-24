package game.module.invasion
{
	/**
	 * InvasionScene 基地互动主场景
	 * author:huhaiming
	 * InvasionScene.as 2017-4-24 上午10:49:41
	 * version 1.0
	 *
	 */
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.BaseScene;
	import game.common.baseScene.SceneType;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBFog;
	import game.global.event.Signal;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainScene.ArticleData;
	import game.module.mainScene.BuildPosData;
	import game.module.mainScene.HomeData;
	import game.module.mainScene.HomeScene;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	
	public class InvasionScene extends BaseScene
	{
		///建筑层
		public var buildingLayer:Sprite;
		
		//显示区域
		private var _scrollRect:Rectangle;
		
		//
		private var _circleAni:Animation;
		
		private var _data:Object;
		/**鼠标的检测索引*/
		private var _mouseIndex:int;
		private var _selectedBuilds:Array = [];
		//所有箭塔
		private var _towers:Array = [];
		
		/***/
		public function InvasionScene()
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
					url = ResourceManager.instance.setResURL("scene\\main\\mainscene_"+url+".jpg");
					
					img = _imgs[id];
					if(!img){
						img = new Image();
						img.scale(1.25,1.25);
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
						img = new Image(ResourceManager.instance.setResURL("scene\\fog\\"+i+".png"));
						//img.scale(1.66667, 1.66667);
						img.scale(2, 2);
						_fogImgs[i] = img;
					}else{
						img.skin = "";
						img.skin = ResourceManager.instance.setResURL("scene\\fog\\"+i+".png")
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
			var bitem:InvasionBuilding
			for(var i:String in _buildItemList){
				bitem = _buildItemList[i]
				bitem.removeSelf()
			}
			this._buildItemList = [];
			_towers = []
			
			//初始化
			var info:Object;
			for(i in this._data.build_info.building){
				info = this._data.build_info.building[i];
				bitem = this.createBuilding(info["id"],info["level"],i);
				setBuildPos(bitem, new Point(parseInt(info["xpos"]), parseInt(info["ypos"])));
			}
			
			//格式化资源
			for(i in this._data.build_rob_res){
				bitem = getBuilding(i);
				if(bitem){
					if(_data.build_rob_res[i].substitute == ""){
						_data.build_rob_res[i].substitute = 0;
					}
					bitem.showDB(_data.build_rob_res[i].attacker_get_res);
				}
			}
			
			SortingFun();
		}
		
		//获取建筑
		private function getBuilding(bid:String):InvasionBuilding{
			if(!bid){
				return null;
			}
			var bitem:InvasionBuilding
			for(var i:String in _buildItemList){
				bitem = _buildItemList[i]
				if(bitem.data.id == bid){
					return bitem;
				}
			}
			return null
		}
		
		//根据信息生成建筑数据
		private function createBuilding(id:Number, lv:Number, bid:String = "-1", infoArr:Object=null):InvasionBuilding{
			var bitem:InvasionBuilding;
			var bdData:ArticleData;
			if(!bitem){
				bitem = new InvasionBuilding();
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
			if(bitem.isTower){
				_towers.push(bitem);
			}
			return bitem;
		}
		
		
		
		protected var _buildItemList:Array = [];
		private function setBuildPos(bitem:InvasionBuilding,p:Point=null,isPreview:Boolean = false):void{
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
			var bitem:InvasionBuilding
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
			buildingLayer && buildingLayer.addChild(_circleAni)
		}
		
		private var _fightStr:String;
		private function onFight():void{
			/**先检查对方是否驻防*/
			var ids:Array = []
			for(var i:String in _selectedBuilds){
				ids.push(_selectedBuilds[i].data.id);
			}
			var str:String = "";
			str = ids.join("-");
			str+=":"+this._data.role_info.base.uid;
			_fightStr = str;
			
			WebSocketNetService.instance.sendData(ServiceConst.checkFight,[str]);
		}
		
		private function onResult(...args):void{
			var data:Object = args[1];
			if(data.defender_arm == 1){
				//人口限制
				var lv:int = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT);
				var bVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_PROTECT, lv);
				var num:Number = (bVo.buldng_capacty+"").split("|")[0];
				FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_PLUNDER, [_fightStr,num],Handler.create(this, this.onFightOver));
			}else{
				XFacade.instance.showModule(InvasionResultView,data);
			}
		}
		
		private function onFightOver():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		private function onClosing(d:*):void{
			if(d is InvasionMenuView || d is InvasionResultView){
				//this.close();
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			}
		}

		
		private function checkHit():void{
			if(_mouseIndex % 5 ==0){
				doCheck();
			}
			_mouseIndex++;
		}
		
		private function doCheck():void{
			for(var i:int = 0; i<_selectedBuilds.length; i++){
				InvasionBuilding(this._selectedBuilds[i]).isSelect = false;
				InvasionBuilding(this._selectedBuilds[i]).hideTowerTip();
			}
			_selectedBuilds = [];
			var build:InvasionBuilding
			for(i=0; i<this._buildItemList.length; i++){
				build = this._buildItemList[i]
				//trace("checkHit---------------------->>");
				if(checkHitPoint(_circleAni,build)){
					_selectedBuilds.push(build);
					build.showTowerTip();
					build.isSelect = true;
				}
			}
			//trace("_buildItemList======================>>",_selectedBuilds)
			//计算总计的资源
			var substitute:int = 0;
			var resObj:Object = {};
			var str:String;
			var arr:Array;
			for(i=0; i<_selectedBuilds.length; i++){
				build = _selectedBuilds[i];
				if(this._data.build_rob_res[build.data.id]){
					str = this._data.build_rob_res[build.data.id]["attacker_get_res"];
					arr = str.split("=");
					if(resObj[arr[0]]){
						resObj[arr[0]] = parseInt(resObj[arr[0]])+parseInt(arr[1]);
					}else{
						resObj[arr[0]] = arr[1]
					}
					//substitute += parseInt(this._data.build_rob_res[build.data.id]["attacker_get_res"]);
				}
			}
			var view:InvasionMenuView = XFacade.instance.getView(InvasionMenuView) as InvasionMenuView;
			view.showSubstitue(resObj)
				
			//计算箭塔影响范围==================================
			for(i=0; i<_selectedBuilds.length; i++){
				build = _selectedBuilds[i];
				//检测不是箭塔的东西
				if(_towers.indexOf(build) == -1){
					for(var j:int=0; j<_towers.length; j++){
						if(checkHitPoint(_towers[j],build)){
							_selectedBuilds.push(_towers[j]);
							_towers[j].showTowerTip();
							_towers[j].isSelect = true;
						}
					}
				}
			}
		}
		
		/**检测功能函数*/
		private function checkHitPoint(build:*,targetBuild:InvasionBuilding):Boolean{
			var dx:Number = targetBuild.data.showPoint.x;
			var dy:Number = targetBuild.data.showPoint.y;
			var w:Number = targetBuild.data.model_w;
			var h:Number = targetBuild.data.model_h;
			var arr:Array = [new Point(dx,dy),new Point(dx,dy-h),new Point(dx-w,dy),new Point(dx-w,dy-h)];
			var p:Point;
			for(var i:int=0;i <arr.length; i++){
				p = arr[i];
				p = HomeData.intance.getPointPos(p.x,p.y);
				p = m_sprMap.localToGlobal(p);
				if(build.hitTestPoint(p.x,p.y)){
					return true;
				}
			}
			return false;
		}
		
		//绘制蒙板区域
		private function drawMask():void{
			if(!_circleAni){
				_circleAni = new Animation();
				_circleAni.loadAtlas("appRes\\atlas\\invasion\\effects.json", Handler.create(this,onAniLoaded));
				_circleAni.scaleX = _circleAni.scaleY  = 1.99999;
				_circleAni.size(1024,1024);
				var tmp:Array = [514,656,614,644,691,623,754,587,798,514,754,435,691,400,614,379,514,367,430,374,344,394,282,426,225,513,282,596,344,626,430,647];
				for(var i:int=0; i<tmp.length; i++){
					tmp[i] = Math.floor(tmp[i]/2);
				}
				var imgHitArea:HitArea = new HitArea();
				imgHitArea.hit.drawPoly(0,0,tmp,"#f8ffff");
				/*var sp:Sprite = new Sprite();
				_circleAni.addChild(sp);
				sp.graphics.drawPoly(0,0,tmp,"#f8ffff");*/
				_circleAni.hitArea = imgHitArea;
			}
			_circleAni.play();
			buildingLayer.addChild(_circleAni);
			_circleAni.pos((m_sprMap.width-_circleAni.width)/2, (m_sprMap.height-_circleAni.height)/2);
			_circleAni.mouseEnabled = true;
		}
		
		private function onAniLoaded():void{
			_circleAni.pos((m_sprMap.width-_circleAni.width)/2, (m_sprMap.height-_circleAni.height)/2);
		}
		
		//多点问题
		private function onMouseUp(e:Event=null):void{ 
			//Laya.stage.off(Event.MOUSE_MOVE, this, onMouseMove);
			//碰撞检测相关代码；
			Laya.stage.off(Event.MOUSE_MOVE, this, this.checkHit);
			if(_mouseIndex > 0){
				doCheck();
				_mouseIndex = 0;
			}
			_circleAni.stopDrag();
		}
		private function onMouseDown(e:Event=null):void
		{
			_mouseIndex = 0;
			Laya.stage.on(Event.MOUSE_MOVE, this, checkHit);
		}
		/*private function onMouseMove(e:Event=null):void
		{
			var distance:Number = getDistance(e.touches);
			
			//判断当前距离与上次距离变化，确定是放大还是缩小
			const factor:Number = 0.001;
			var del:Number = (distance - lastDistance) * factor;
			doScale(del);
			
			lastDistance = distance;
		}*/
		/**计算两个触摸点之间的距离*/
		/*private function getDistance(points:Array):Number
		{
			var distance:Number = 0;
			if (points && points.length == 2)
			{
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}*/
		
		
		
		/***/
		/*private function onScale(e:Event):void{
			var deltaScale:Number = e.delta/30;
			doScale(deltaScale);
		}*/
		
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
		
		override public function onStartDrag(e:Event=null):void
		{
			if(_circleAni.hitTestPoint(stage.mouseX, stage.mouseY)){
				_circleAni.startDrag();
			}else{
				//鼠标按下开始拖拽(设置了拖动区域和超界弹回的滑动效果)
				if(isDrag)
				{
					showDragRegion();
					m_sprMap.startDrag(dragRegion, false,0,300,null, true);
				}
			}
			
		}
		
		/**覆盖这个方法，达到重用的效果*/
		override public function show(...args):void{
			this._data = args[0];
			if(!m_sprMap){
				initScence();
				this.loadMap();
			}else{
				loadMapCell();
				onStageResize();
				initBuilding();
			}
			initMap(_data.fog)
			super.show();
			XFacade.instance.openModule("InvasionMenuView", this._data);
			//画区域 
			drawMask();
			initMapPosition();
			doCheck();
		}
		
		override public function close():void{
			super.close();
			this._data = null;
			_circleAni.stop();
			_circleAni.destroy(true);
			Laya.loader.clearRes("appRes\\atlas\\invasion\\effects.json");
			for(var i:int=0; i<_imgs.length; i++){
				Laya.loader.clearRes(_imgs[i].skin);
				_imgs[i].skin = "";
			}
			for(var i:int=0; i<_fogImgs.length; i++){
				if(_fogImgs[i]){
					Laya.loader.clearRes(_fogImgs[i].skin);
					_fogImgs[i].skin = "";
				}
			}
			
			var item:InvasionBuilding
			for(i=0; i<_buildItemList.length; i++){
				item = _buildItemList[i];
				item.releaseSkin();
			}
			
			_circleAni = null;
			_selectedBuilds = [];
			_fightStr = "";
			XFacade.instance.closeModule(InvasionMenuView);
		}
		
		override public function onStageResize():void
		{
			if(!_scrollRect.width != LayerManager.instence.stageWidth || _scrollRect.height != LayerManager.instence.stageHeight){
				this.scrollRect = new Rectangle(0,0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			}
		}
		
		override public function init():void{
			//just do nothing.
		}
		
		override public function addEvent():void{
			Signal.intance.on(Event.CLOSE, this, this.onClosing);
			Signal.intance.on(InvasionMenuView.FIGHT, this, this.onFight)
			
			Laya.stage.on(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.checkFight), this, this.onResult);
			addDragEvent();
		}
		
		
		public override function removeEvent():void
		{
			Signal.intance.off(Event.CLOSE, this, this.onClosing);
			Signal.intance.off(InvasionMenuView.FIGHT, this, this.onFight)
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.checkFight), this, this.onResult);
			super.removeEvent();
			Laya.stage.off(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
			Laya.stage.off(Event.MOUSE_MOVE, this, this.checkHit);
		}
	}
}