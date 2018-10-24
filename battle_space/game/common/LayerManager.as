package game.common
{
	
	import game.common.base.IBaseView;
	import game.module.chatNew.LiaotianView;
	import game.module.mainui.MainMenuView;
	import game.module.mainui.MainView;
	
	import laya.display.Sprite;
	import laya.utils.Browser;
	
	
	public class LayerManager
	{
		private static var _instance:LayerManager;		
		
		private var m_sprSceneLayer:Sprite ;//场景层		
		private var m_sprFixUILayer:Sprite ;//ui层		
		private var m_sprPanelLayer:Sprite ;//panel层		
		private var m_sprPopLayer:Sprite ;//弹出信息层				
		private var _m_sprTipLayer:Sprite ;//提示信息层		
		private var m_sprGuideLayer:Sprite ;//引导信息层		
		private var m_sprTopLayer:Sprite ;//顶层
		
		public static const M_SCENE:int = 1;
		public static const M_FIX:int = 2;
		public static const M_PANEL:int = 3;
		public static const M_POP:int = 4;
		public static const M_TIP:int = 5;
		public static const M_GUIDE:int = 7;
		public static const M_TOP:int = 6;
		
		//LEFTUP////////////////UP////////////////RIGHTUP////
		/////////////////////////////////////////////////////
		//LEFT////////////////CENTER/////////////////RIGHT///
		/////////////////////////////////////////////////////
		//LEFTDOWN////////////DOWN/////////////RIGHTDOWN/////
		public static const UP:int = 0x00000001;
		public static const DOWN:int = 0x00000010;
		public static const LEFT:int = 0x00000100;
		public static const RIGHT:int = 0x00001000;
		public static const CENTER:int = 0x00010000;
		
		public static const LEFTUP:int = LEFT | UP;
		public static const RIGHTUP:int = RIGHT | UP;
		public static const LEFTDOWN:int = LEFT | DOWN;
		public static const RIGHTDOWN:int = RIGHT | DOWN;
		public static const CENTERLEFT:int = CENTER | LEFT;
		public static const CENTERRIGHT:int = CENTER | RIGHT;
		public static const MOVE:int = -1;
		
		public function LayerManager()
		{
			if(_instance){				
				throw new Error("LayerManager是单例,不可new.");
			}
			//init();
			_instance = this;
		}


		public function get m_sprTipLayer():Sprite
		{
			return _m_sprTipLayer;
		}

		public function set m_sprTipLayer(value:Sprite):void
		{
			_m_sprTipLayer = value;
		}

		public static function get instence():LayerManager
		{
			if(_instance)return _instance;
			_instance = new LayerManager();
			return _instance;
		}
		/**
		 * 初始化 
		 * 
		 */		
		public function init():void
		{			
			/**场景层*/
			m_sprSceneLayer = new Sprite();
			Laya.stage.addChild(m_sprSceneLayer);
			/**ui层*/
			m_sprFixUILayer = new Sprite();
			Laya.stage.addChild(m_sprFixUILayer);
			/**窗口层*/
			m_sprPanelLayer = new Sprite();
			Laya.stage.addChild(m_sprPanelLayer);
			/**弹出框*/
			m_sprPopLayer = new Sprite();
			m_sprPopLayer.mouseThrough = true;
			Laya.stage.addChild(m_sprPopLayer);
			/**Tips*/
			m_sprTipLayer = new Sprite();
			Laya.stage.addChild(m_sprTipLayer);
			/**引导层*/
			m_sprGuideLayer = new Sprite();
			Laya.stage.addChild(m_sprGuideLayer);
			
			/**顶层*/
			m_sprTopLayer = new Sprite();
			Laya.stage.addChild(m_sprTopLayer);
		}
		
		/**判定是否在主界面层*/
		public function get isOnlyMain():Boolean{
			var i:int = 0;
			var obj:Sprite;
			if(m_sprTopLayer.numChildren){
				for(i=0; i<m_sprTopLayer.numChildren; i++){
					obj = m_sprTopLayer.getChildAt(i) as Sprite;
					if(obj && obj.displayedInStage && obj.visible){
						return false;
					}
				}
			}else if(m_sprTipLayer.numChildren){
				for(i=0; i<m_sprTipLayer.numChildren; i++){
					obj = m_sprTipLayer.getChildAt(i) as Sprite;
					if(obj && obj.displayedInStage && obj.visible){
						return false;
					}
				}
			}else if(m_sprPopLayer.numChildren){
				for(i=0; i<m_sprPopLayer.numChildren; i++){
					obj = m_sprPopLayer.getChildAt(i) as Sprite;
					if(obj && obj.displayedInStage && obj.visible && !(obj is MainMenuView) && !(obj is LiaotianView)){
						return false;
					}
				}
			}else if(m_sprPanelLayer.numChildren){
				obj = m_sprPanelLayer.getChildAt(m_sprPanelLayer.numChildren-1)
				if(obj is MainView){
					//doNothing
				}else{
					//trace("4444444444444444444444",obj)
					return false;
				}
			}
			return true;
		}
		
		/**
		 *  添加面板到层并且设置位置
		 * @param view 面板
		 * @param layerType 层类型
		 * @param postTpye 位置类型
		 * 
		 */		
		public function addToLayerAndSet(view:IBaseView,layerType:int=M_PANEL,postTpye:int=CENTER):void
		{
			addToLayer(view as Sprite,view.m_iLayerType);
			setPosition(view as Sprite,postTpye);
		}
		
		/**
		 *  添加面板到
		 * @param view 面板
		 * @param layerType 层类型
		 * 
		 */	
		public function addToLayer(view:Sprite,layerType:int=M_PANEL):void
		{
			switch(layerType)
			{
				case LayerManager.M_SCENE:
					this.m_sprSceneLayer.addChild(view);
					break;
				case LayerManager.M_FIX:
					this.m_sprFixUILayer.addChild(view);
					break;
				case LayerManager.M_PANEL:
					this.m_sprPanelLayer.addChild(view);
					break;				
				case LayerManager.M_POP:
					this.m_sprPopLayer.addChild(view);
					break;	
				case LayerManager.M_TIP:
					this.m_sprTipLayer.addChild(view);
					break;
				case LayerManager.M_GUIDE:
					this.m_sprGuideLayer.addChild(view);
					break;
				case LayerManager.M_TOP:
					this.m_sprTopLayer.addChild(view);
					break;
			}
		}
		
		/**
		 *获取舞台宽度 ,是否需要特殊处理？
		 * @return 
		 * 
		 */		
		public function get stageWidth():int
		{
			var swidth:int = Laya.stage.width;
			return swidth;
		}
		
		/**
		 * 
		 * 获取舞台高度,是否需要特殊处理？
		 * @return 
		 * 
		 */
		public function get stageHeight():int
		{
			var sheight:int = Laya.stage.height;
			return sheight;
		}
		
		public var m_iStageWidth:Number;
		public var m_iStageHeight:Number;
		
		/**
		 * 设置面板位置 
		 * @param view 面板
		 * @param postTpye 位置类型
		 * @param offsetX 偏移x
		 * @param offsetY 偏移y
		 * @param anchorX 锚点X是否居中
		 * @param anchorY 锚点y是否居中
		 * 
		 */		
		public function setPosition(view:Sprite,postTpye:int, offsetX:int=0, offsetY:int=0):void
		{
			if(Browser.onPC)
			{
				var _posWidth:Number=Browser.clientWidth;
				var _posHeight:Number=Browser.clientHeight;
				if(_posWidth>Laya.stage.width){
					_posWidth=Laya.stage.width;
				}
				if(_posHeight>Laya.stage.height){
					_posHeight=Laya.stage.height;
				}
			}else
			{
				_posWidth = Laya.stage.width;
				_posHeight = Laya.stage.height;
			}
			m_iStageWidth = _posWidth;
			m_iStageHeight = _posHeight;
			
			switch (postTpye)
			{
				case UP:
					view.x = (_posWidth - view.width)/2;
					view.y = 0;
					break;
				case DOWN:
					view.x = (_posWidth - view.width)/2;
					view.y = _posHeight - view.height;
					break;
				case LEFT:
					view.x = 0;
					view.y =  (_posHeight - view.height)/2;
					break;
				case RIGHT:
					view.x = _posWidth - view.width;
					view.y =  (_posHeight - view.height)/2;
					break;
				case LEFTUP:
					view.x = 0;
					view.y = 0;
					break;
				case RIGHTUP:
					view.x = _posWidth - view.width ;
					view.y = 0;
					break;
				case LEFTDOWN:
					view.x = 0;
					view.y = _posHeight - view.height;
					break;
				case RIGHTDOWN:
					view.x = _posWidth - view.width ;
					view.y = _posHeight - view.height;
					break;
				case CENTERLEFT:
					view.x = _posWidth/2 - view.width;
					view.y =  (_posHeight - view.height)/2;
					break;
				case CENTERRIGHT:
					view.x = _posWidth/2;
					view.y =  (_posHeight - view.height)/2;
					break;
				case CENTER:
					view.x = (_posWidth - view.width)/2;					
					view.y = (_posHeight - view.height)/2;
					break;
				default:
					break;
			}			
			view.x += offsetX;
			view.y += offsetY;
		}
		
		public static var DesignWidth:int = 1136;
		public static var DesignHeight:int = 640;
		/**获取最合适比例*/
		public static function get fixScale():Number{
			var scaleX:int = Laya.stage.width/DesignWidth;
			var scaleY:int = Laya.stage.height/DesignHeight;
			return Math.max(scaleX, scaleY);
		}
	}
}