package  game.common
{
	import game.App;
	import game.common.ModuleManager;
	import game.common.base.IBaseView;
	
	import laya.display.Sprite;
	
	/**
	 * XFacade 门面模式，合并底层比较重要的功能
	 * author:huhaiming
	 * XFacade.as 2017-3-1 上午10:28:15
	 * version 1.0
	 * 预计还需要组合：tip功能;
	 */
	public class XFacade
	{
		/**单例*/
		private static var _instance:XFacade;
		/**常量-字体*/
		public static const FT_BigNoodleToo:String = "BigNoodleToo"
		/**常量-字体*/
		public static const FT_Futura:String = "Futura"
		//FuturaStd
		
		//管理层引用
		public var app:App;
		public function XFacade()
		{
			if(_instance){
				throw new Error("XFacade is singleton");
			}
			_instance = this;
		}
		
		/**
		 * 门面模式初始化
		 */
		public function init(appClass:Class,gameName:String=""):void{
			LayerManager.instence.init();
			//功能模块管理器
			ModuleManager.intance.init();
			//todo：本地数据保存,
			Laya.timer.loop(ModuleManager.RECOVER_INTERVAL, ModuleManager.intance, ModuleManager.intance.recover);
			
			
			app = new appClass();
			app.start();
		}
		
		/**
		 * 打开一个模块,需要加载资源的模块
		 * @param moduleName 模块名称
		 * @param data 数据;
		 */
		public function openModule(moduleName:String,data:*=null):void{
			ModuleManager.intance.openModule(moduleName,data);
		}
		
		/**
		 * 关闭一个模块
		 * @param moduleName 类型
		 * @param data 数据;
		 */
		public function closeModule(type:Class):void{
			if (ModuleManager.intance.hasModule(type)) {
				var view:* = ModuleManager.intance.getModule(type)
				if(view.displayedInStage){
					ModuleManager.intance.getModule(type).close();
				}
			}
		}
		
		/**
		 * 显示一个模块,不需要加载资源的模块
		 * @param type 类型
		 * @param data 数据;
		 */
		public function showModule(type:Class,data:*=null):void{
			ModuleManager.intance.showModule(type,data);
		}
		
		/**
		 * 根据类型获取一个窗体实例;
		 * @param type 类型，实现IBaseView接口的类型（非已存在的基础类型如BaseView,BaseDialog）;
		 * */
		public function getView(type:Class):*{
			return ModuleManager.intance.getModule(type);
		}
		
		/**
		 * 销毁一个实例，确定短时间内不在重用
		 * @param view 
		 * */
		public function disposeView(view:IBaseView):void{
			ModuleManager.intance.disposeModule(view)
		}
		
		
		/***/
		public static function get instance():XFacade{
			if(!XFacade._instance){
				XFacade._instance = new XFacade();
			}
			return XFacade._instance;
		}
	}
}