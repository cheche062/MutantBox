package game.common.baseScene
{
	import game.common.BufferView;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.base.IBaseView;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	public class BaseScene extends Sprite implements IBaseView
	{
		/**底图*/
		public var m_sprMap:Sprite;
		/**  * ui层次类型 父类  */			
		protected var _m_iLayerType:int = LayerManager.M_SCENE;
		/**底图URL*/
		public var m_strMapURL:String;
		private var m_rectDragRegion:Rectangle;
		public var m_bCanDrag:Boolean = true;
		public var toScene:String = "";
		
		/**记录从哪个场景过来的*/
		public var fromScene:String;
		/**
		 *  是否已经释放
		 */
		protected var isDispose:Boolean = false;
		/**
		 *  是否有父类来消失loading（如果要自己模块消失，则设为false）
		 */
		protected var isHideLoading:Boolean = true;
		
		/**
		 * 是否将场景资源释放掉 
		 */
		public var isResDispose  :Boolean = true;
		
		
		public function BaseScene(URL:String='',isCanDrag:Boolean = true)
		{
			//没办法重新使用=========
			super();
			this.m_strMapURL = URL;
			this.m_bCanDrag = isCanDrag;
			init();
			Laya.stage.on(Event.RESIZE,this,onStageResize);
		}
		
		
		public function onStageResize():void
		{
//			trace(Browser.clientWidth);
//			trace(Laya.stage.width);
		}
		
		public function init():void
		{
			initScence();
			this.loadMap();
		}
		
		/**
		 * 显示
		 * @param  
		 */
		public function show(...args):void{
			addEvent();
		}
		 
		public function close():void{
			this.removeSelf();
			removeEvent();
		}
		
		public function initScence():void
		{
			this.m_sprMap = new Sprite();
			this.addChild(m_sprMap);
			m_sprMap.mouseEnabled = true;
		}
		
		
		public function reLoadMap(m_strMapURL:String):void
		{
			m_strMapURL = ResourceManager.instance.setResURL(m_strMapURL);
			this.m_sprMap.loadImage(m_strMapURL);
		}
		
		/**
		 * 场景先加载背景，再加载资源 
		 * 
		 */
		protected function loadMap():void{
			_loadBgImgCom=false;
			if(m_strMapURL && m_strMapURL != ""){
				m_strMapURL = ResourceManager.instance.setResURL(m_strMapURL);
				this.m_sprMap.loadImage(m_strMapURL,0,0,0,0, Handler.create(this, onMapLoaded));
			}else
				onMapLoaded();
			
		}
		/**
		 * 加载完背景加载配置资源 
		 */
		protected function onMapLoaded(_e:*=null):void{
			if(isDispose){
				trace("<<< BaseScene.onMapLoaded() className: " + this["constructor"].name + " ==== name: " + this.name );
				return;
			}
			trace("<<< onMapLoaded" );
			initMapPosition();
			loadSceneResource(); 
		}
		/**
		 * 切换背景图时
		 */
		protected function onMapChanged(_e:*=null):void{
		
			initMapPosition();
		}
		/**
		 * 加载资源 
		 * 
		 */
		protected function loadSceneResource():void{
			trace("m_SceneResource:"+m_SceneResource);
			if(m_SceneResource){
				BufferView.instance.show();
				ResourceManager.instance.load(m_SceneResource,Handler.create(this,_onLoaded));
			}else
				_onLoaded();
			
		}
		private function _onLoaded(_e:*=null):void{
			if(isDispose){//界面销毁不再加载
				trace("<<<< BaseScene._onLoaded() isDispose:true className: " + this["constructor"].name + " ==== name: " + this.name );
				return;
			}
//			trace("2222222222222222222");
//			initMapPosition();
			onLoaded();
			updateData();
			if(m_bCanDrag)
			{
				addDragEvent();
			}
			if(isHideLoading)
			{
				hideBufferView();
			}
					
		}
		
		protected function hideBufferView():void
		{
			BufferView.instance.close();
		}
		
		/**
		 * 资源都加载完成 
		 */
		protected function onLoaded():void{
			
		}
		/**
		 * 更新数据（第一次打开或再打开界面时会调用）
		 */
		protected function updateData():void{
			
		}
		/**
		 * 再打开当前界面时调用
		 */
		public function open():void{
			updateData();
		}
		protected var m_SceneResource:String="";
		
		private var _newHandler:Handler;
		
		protected var _loadSceneResCom:Boolean=true;
		
		protected var _loadBgImgCom:Boolean=false;
		
		public function addDragEvent():void
		{
			m_sprMap.on(Event.DRAG_START, this, onDragStart);
			m_sprMap.on(Event.DRAG_END, this, onDragEnd);
			m_sprMap.on(Event.MOUSE_DOWN, this, onStartDrag);
//			m_sprMap.on(Event.DRAG_MOVE,this,onDraging);
		}
		public function addEvent():void
		{
		}
		
		public function removeEvent():void
		{
			m_sprMap.off(Event.DRAG_START, this, onDragStart);
			m_sprMap.off(Event.DRAG_END, this, onDragEnd);
			m_sprMap.off(Event.MOUSE_DOWN, this, onStartDrag);
//			m_sprMap.off(Event.DRAG_MOVE, this, onDraging);
			Laya.stage.off(Event.RESIZE,this,onStageResize);
		}
		
		/**
		 * 更换地图
		 * */
		public var changUrl:String;
		public function changMap(url:*):void{
			url = "icon/sceneBg/" + url + ".jpg";
			changUrl = ResourceManager.instance.setResURL(url);
//			m_sprMap.loadImage(url);
			Laya.loader.load(changUrl, new Handler(this, loadImgComplete));
		}
		
		public function loadImgComplete():void{
			if(isDispose){
				trace("<<< BaseScene.loadImgComplete() className: " + this["constructor"].name + " ==== name: " + this.name );
				return;
			}
			var texture:Texture = Laya.loader.getRes(changUrl);
			m_sprMap.texture = texture;
//			trace("更换地图");
		}
		
		protected function initMapPosition():void{
			m_sprMap.pivot(m_sprMap.width/2, m_sprMap.height/2);
			m_sprMap.x = Laya.stage.width/2;
			m_sprMap.y = Laya.stage.height/2;
		}
		
		public function onDragStart(e:Event=null):void 
		{
//			trace("on Map DRAG_START");
		}
		public function onDragEnd(e:Event=null):void
		{
			//trace("on Map DRAG_END");
		}
		public function onStartDrag(e:Event=null):void
		{
			//鼠标按下开始拖拽(设置了拖动区域和超界弹回的滑动效果)
//			trace("11111111111111");
			if(isDrag)
			{
				showDragRegion();
				m_sprMap.startDrag(dragRegion,true, 0);
			}
		}
		
		
		public function get isDrag():Boolean{
			return true;
		}
		
		
		public  var dragRegion:Rectangle;
		
		protected function showDragRegion():void
		{
			var dragWidthLimit:int = m_sprMap.width * m_sprMap.scaleX - Laya.stage.width;
			var dragHeightLimit:int =  m_sprMap.height * m_sprMap.scaleY - Laya.stage.height;
			dragRegion = new Rectangle(Laya.stage.width - dragWidthLimit >> 1, Laya.stage.height - dragHeightLimit >> 1, dragWidthLimit, dragHeightLimit);
		}
		/**
		 * 销毁
		 * 
		 */		
		public function dispose():void
		{
			trace("<<< BaseScene.dispose() className: " + this["constructor"].name + " ==== name: " + this.name );
			isDispose = true;
		//	SceneLoadMgr.instance.dispose();
			this.m_sprMap.destroy(true);
			this.m_sprMap.removeSelf();
			this.removeEvent();
			this.removeSelf();
			
			
			if(isResDispose){
				if(m_strMapURL && m_strMapURL!="")
					Laya.loader.clearRes(m_strMapURL,true);
				var urlArr:Array =ResourceManager.instance.m_objModuleReource[m_SceneResource];
				for(var a:* in urlArr){
					Laya.loader.clearRes(urlArr[a].url,true);
				}
			}
			
			this.destroy();
		}
		
		public function set  m_iLayerType(v:int):void{
			this._m_iLayerType = v;
		}
		
		public function get  m_iLayerType():int{
			return this._m_iLayerType
		}
		
		/**这个属性没被使用*/
		public function get m_iPositionType():int{
			return 0;
		}
		
		
	}
}