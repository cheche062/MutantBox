package game.global.event
{
	
	import laya.events.EventDispatcher;

	////////////////////////////////////////////////////////////////////////////
	////
	//// 1.增加一个事件监听:on(type:String, caller:*, listener:Function, args:Array = null)
	//// 2.移除一个事件:off(type:String, caller:*, listener:Function, onceOnly:Boolean = false)
	//// 3.监听某个事件一次，监听被触发后会被移除:once(type:String, caller:*, listener:Function, args:Array = null)
	////
	////////////////////////////////////////////////////////////////////////////
	public class Signal extends EventDispatcher
	{
		private static var _instance:Signal
		public static function get intance():Signal{
			if(_instance)return _instance;
			_instance = new Signal;
			return _instance;
		}
	}
}