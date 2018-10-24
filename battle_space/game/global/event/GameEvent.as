package game.global.event
{
	////////////////////////////////////////////////////////////////////////////
	//// 
	//// 1.游戏全局事件抛送
	//// 2.模块间事件交互
	//// 3.命名规则 EVENT+模块名（+功能）
	////////////////////////////////////////////////////////////////////////////
	
	public class GameEvent
	{
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
		//
		//	 全局事件
		//
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * app UI持续按一秒钟事件 
		 */		
		public static var MOUSE_HOLDON:String="MOUSE_HOLDON";
		/**
		 * 打开面板消息 
		 */		
		public static var EVENT_OPEN_MODULE:String="EVENT_OPEN_MODULE";
		/**
		 * 已经打开面板,并且添加到舞台，返回面板引用 
		 */		
		public static var EVENT_MODULE_ADDED:String="EVENT_MODULE_ADDED";
		/**
		 * 关闭面板消息 
		 */		
		public static var EVENT_CLOSE_MODULE:String="EVENT_CLOSE_MODULE";
		/**
		 * 加载场景背景完成事件
		 */		
		public static var EVENT_LOADED_SCENE_BG_COM:String="EVENT_LOADED_SCENE_BG_COM";
		
		public static var RECIVE_SUCESS_SERVICE:String = "RECIVE_SUCESS_SERVICE";
		/** *更新在线奖励状态*/
		public static var EVENT_UPDATE_ONLINE:String = "EVENT_UPDATE_ONLINE";
		
		/**
		 * 更新兵种信息
		 */
		public static var UPDATE_UNIT_INFO:String = "UPDATE_UNIT_INFO";
		
		/**
		 * 监测时候可以开启星际迷航
		 */
		public static var CHECK_OPEN_ST:String = "CHECK_OPEN_ST";
		
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
		//
		//	 服务器事件
		//
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * 加载资源完成消息
		 */		
		public static var EVENT_ITEM_UPDATE:String="EVENT_ITEM_UPDATE";
		
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
		//
		//	 模块事件事件
		//
		////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////
	}
}