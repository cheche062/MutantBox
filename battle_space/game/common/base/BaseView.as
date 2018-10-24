package game.common.base
{	
	import game.common.DataLoading;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.UnpackMgr;
	import game.global.event.Signal;
	import game.module.commonGuide.CommonGuideView;
	import game.module.commonGuide.FunctionGuideView;
	import game.module.mainui.MainMenuView;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.View;
	
	
	////////////////////////////////////////////////////////////////////////////
	//// 
	//// UI的基类
	////
	////////////////////////////////////////////////////////////////////////////
	public class BaseView extends Box implements IBaseView
	{
		/**
		 * 主显示view 
		 */
		protected var _view:View;
		/**  * ui层次类型 父类  */			
		protected var _m_iLayerType:int = LayerManager.M_PANEL;
		/**  * ui坐标位置类型  */			
		protected var _m_iPositionType:int = LayerManager.LEFTUP;
		/**  * UI名称  */		
		public var m_strName:String;
		
		public function BaseView()
		{
			super();	
		}
		/**
		 * 初始化 （因为ui还没有加载好，不要在这个方法中处理界面元素之类的操作）
		 * (子类可重写方法，子类不需要调用 super)
		 */	
		public function init():void
		{	
		}
		
		/**
		 * 底层在加入到舞台之后调用
		 * @param 
		 */
		public function show():void{
			addEvent();
		}
		
		/**
		 * 
		 */
		public function close():void {
			
			event(Event.CLOSE, this);//触发模块管理，清除缓存
			
			removeEvent();
			this.removeSelf();
			
			if (!(this is DataLoading) &&
				!(this is FunctionGuideView) &&
				!(this is MainView) &&
				!(this is MainMenuView) &&
				!(this is CommonGuideView))
			{
				//trace("发送关闭事件:",this);
				Laya.timer.once(500,this,function(){
					Signal.intance.event(Event.CLOSE, this);
				})
			}
			
		}
		
		/**
		 * <p>创建并添加控件子节点。会在资源及基础数据加载完成后调用</p>
		 * @internal 子类可在此函数内创建并添加子节点。
		 * (子类可重写方法，子类不需要调用 super)
		 */
		public function createUI():void {
			
		}
		
		public function onStageResize():void
		{
			//内部布局逻辑，对齐方式改由LayerManager控制
		}
		
		/**层级设定*/
		public function set m_iLayerType(v:int):void{
			this._m_iLayerType = v;
		}
		
		/**层级设定*/
		public function get  m_iLayerType():int{
			return this._m_iLayerType
		}
		
		/**ui坐标位置类型*/
		public function set m_iPositionType(v:int):void{
			this._m_iPositionType =v;
		}
		
		/**ui坐标位置类型*/
		public function get m_iPositionType():int{
			return this._m_iPositionType
		}
		
		
		/** 
		 * <p>预初始化。</p>
		 * @internal 子类可在此函数内设置、修改属性默认值
		 * （因为ui还没有加载好，不要在这个方法中处理界面元素之类的操作）
		 */
		override protected function preinitialize():void {
			//Laya.stage.on(Event.RESIZE,this,onStageResize);
			super.preinitialize();
			init();
		}
		
		/**
		 * <p>控件初始化。</p>
		 * @internal 在此子对象已被创建，可以对子对象进行修改。
		 */
		override protected function initialize():void {
			super.initialize();
			//initData();
			createUI();
			//if(!(this is BaseDialog))
				//addEvent();
		}
		
		
		/**
		 * 添加事件要用BaseView 的 addMapEvent方法添加,
		 * 添加事件的对象会在释放游戏的时候自动释放，
		 * 也可手动调用removeAllMapEvent移除UI上所有事件
		 * 所有的事件要 在这个方法内添加，方便统一管理 
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function addEvent():void
		{
			
		}
		/**
		 *  移除事件
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function removeEvent():void
		{
			
		}
		
		/**
		 * 关闭界面  销毁对象
		 * 
		 */	
		public function dispose():void
		{
			trace("<<< BaseView.dispose() className: " + this["constructor"].name + " ==== name: " + this.name + " ==== m_strName: " + this.m_strName    );
			removeEvent();
			
			var urlArr:Array=[];
			if(this.m_strName && this.m_strName!=""){
				urlArr =ResourceManager.instance.m_objModuleReource[this.m_strName];
			}else{
				urlArr =ResourceManager.instance.m_objModuleReource[this["constructor"].name];
			}
			trace("urlArr================================>",urlArr);
			
			for(var a:* in urlArr){
				Laya.loader.clearRes(urlArr[a].url/*,true*/);
			}
			clearUnpackRes();
		
			this.destroy();
		}
		
		
		protected function clearUnpackRes():void{
			if(_view){
				//删除不再UI列表中的资源
				for(var i:String in _view._childs){
					if(_view._childs[i] is Image && UnpackMgr.instance.check(_view._childs[i].skin)){
						Laya.loader.clearRes(_view._childs[i].skin);
					}
				}
				//_view.destroy();
				_view = null;
			}
		}
		
		protected function sendData(cmdId:int, data:Array = null):void{
			if(data == null)
				data = [];
			WebSocketNetService.instance.sendData(cmdId, data);//发消息
		}
		
		public function logColor(data):void {
			trace('%c 【数据】：', 'color: green', data);
		}
	}
}