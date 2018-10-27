package game.common
{
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.common.base.IBaseView;
	import game.global.ModuleName;
	import game.global.event.GameEvent;
	import game.global.event.Signal;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainView;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.ClassUtils;
	import laya.utils.Handler;

	public class ModuleManager
	{				
		private static var _instance:ModuleManager;
		/**模块信息记录*/
		public var viewsInfo:Array = [];
		/**回收执行间隔-毫秒*/
		public static const RECOVER_INTERVAL:int = 60*1000; 
//		public static const RECOVER_INTERVAL:int = 10*1000; 
		/**实例回收时间-毫秒*/
		public static const RECOVER_TIME:int = 5*60*1000/*5*60*100*/;
//		public static const RECOVER_TIME:int = 60*1000/*5*60*100*/;
		/**最大安全内存值-超过将强行开始回收掉实例*/
		public static const MAX_MEMO_SIZE:int = 200*1024*1024;
		public function ModuleManager()
		{
			if(_instance){
				throw new Error("ModuleManager,不可new.");
			}
			_instance = this;
		}
		
		/**
		 * 打开一个模块
		 * @param moduleName 模块名称
		 * @param data 数据;
		 */
		public function openModule(moduleName:String,data:*=null):void
		{
			Signal.intance.event(GameEvent.EVENT_OPEN_MODULE, [moduleName,data]);
		}
		
		/**
		 * 初始化  
		 * 
		 */		
		public function init():void
		{
			Signal.intance.on(GameEvent.EVENT_OPEN_MODULE,this, onModulePanel);
			Laya.stage.on(Event.RESIZE, this, this.onResize);
		}
		
		/**
		 * 打开面板 
		 * @return 
		 */		
		private function onModulePanel(name:String,data:*=null):void
		{
			if(ModuleName.maxPanelNames.indexOf(name) != -1){
				BufferView.instance.show();
			}
				
			ResourceManager.instance.load(name,Handler.create(this, onLoaded,[name,data]));
		}
		
		
		private function onLoaded(className:*,data:*=null):void {
			var compClass:* = ClassUtils.getClass(className);
			if (compClass){
				showModule(compClass,data);
			}else{
				trace("[error] Undefined class:", compClass);
			}
			
			if(ModuleName.maxPanelNames.indexOf(className) != -1){
				BufferView.instance.close();
			}
			
		}
		
		/**
		 * 打开一个实例，不需要加载资源的那种使用这个方法
		 * @param compClass 类型
		 * @param data 数据
		 */
		public function showModule(compClass:Class,data:*=null):*{
			var baseView:IBaseView ;
			baseView = this.getModule(compClass)
			LayerManager.instence.addToLayer(baseView as Sprite,baseView.m_iLayerType);
			if(baseView is BaseView || baseView is BaseDialog){
				LayerManager.instence.setPosition(baseView as Sprite,baseView.m_iPositionType);
			}
			baseView.show(data)
			Signal.intance.event(GameEvent.EVENT_MODULE_ADDED,baseView);
			return baseView;
		}
		
		/**
		 * 获取一个实例,必须实现了IBaseViewjieko
		 * @param compClass 类型
		 */
		public function getModule(compClass:Class):IBaseView{
			var tmp:Object;
			for(var i:String in this.viewsInfo){
				tmp = this.viewsInfo[i];
				if(tmp && tmp.view is compClass){
					tmp.time = Browser.now();
					//排到队列后面去
					this.viewsInfo.splice(parseInt(i),1);
					this.viewsInfo.push(tmp);
					return tmp.view;
				}
			}
			//没找到缓存的实例对象
			var baseView:IBaseView = new  compClass();
			this.viewsInfo.push({time:Browser.now(), view:baseView});
			return baseView;
		}
		
		/**
		 * 判断是否有该类型实例
		 * @param compClass 类型
		 */
		public function hasModule(compClass:Class):Boolean {
			var tmp:Object;
			for(var i:String in this.viewsInfo){
				tmp = this.viewsInfo[i];
				if(tmp && tmp.view is compClass){
					return true
				}
			}
			
			return false;
		}
		
		/**
		 * 销毁一个实例
		 * @param view 实例对象
		 * */
		public function disposeModule(view:IBaseView):void{
			var tmp:Object;
			for(var i:String in this.viewsInfo){
				tmp = this.viewsInfo[i];
				if(tmp && tmp.view == view){
					view.dispose();
					//需要销毁加载资源========
					trace("disposeModule::",view);
					this.viewsInfo.splice(i,1);
					break;
				}
			}
		}
		
		/**回收*/
		public function recover():void{
			//trace("recover----------------------------------------->");
			var tmp:Object;
			var view:*;
			var time:Number = Browser.now();
			
			for(var i:int=0; i<this.viewsInfo.length; i++){
				tmp = this.viewsInfo[i];
				view= tmp?tmp.view:null;
				if(view && !view.displayedInStage){
					if(time - tmp.time > ModuleManager.RECOVER_TIME){
						if(view is HomeScene  || view is MainView){
							//特例，不处理
						}else{
							view.dispose();
							this.viewsInfo.splice(i,1);
						}
					}
				}
			}
			//如果内存超标，销毁最早生成的东西------------------
			if(laya.resource.ResourceManager.systemResourceManager.memorySize > MAX_MEMO_SIZE){
				for(i=0; i<this.viewsInfo.length; i++){
					tmp = this.viewsInfo[i];
					view= tmp?tmp.view:null; 
					if(view && !view.displayedInStage){
						if(view is HomeScene || view is MainView){//需要写个函数来支撑
							//特例，不处理
						}else{
							trace("强制回收：：：：：：：：：：：：：：：：",view,"累计资源值:::::::::",laya.resource.ResourceManager.systemResourceManager.memorySize);
							view.dispose();
							this.viewsInfo.splice(i,1);
							break;
						}
					}
				}
			}
		}
		
		
		/**
		 * 关闭所有的对话框。
		 */
		public function closeAll():void {
			var tmp:Object;
			var view:*;
			for(var i:String in this.viewsInfo){
				tmp = this.viewsInfo[i];
				view= tmp?tmp.view:null;
				if(view && view is BaseDialog && view.displayedInStage){
					view.close();
				}
			}
		}
		
		/**重新布局*/
		public function onResize():void{
			var tmp:Object;
			var view:IBaseView;
			for(var i:String in this.viewsInfo){
				tmp = this.viewsInfo[i];
				view= tmp?tmp.view:null;
				if(view  && (view as Sprite).displayedInStage){
					view.onStageResize();
				}
			}
		} 
		
		
		
		public static function get intance():ModuleManager{
			if(!_instance){
				_instance = new ModuleManager;
			}
			return _instance;
		}
	}
}