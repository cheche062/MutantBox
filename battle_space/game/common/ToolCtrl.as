package game.common
{
	import game.global.util.TimeUtil;
	
	import laya.utils.Browser;

	/**
	 * 工具控制处理
	 * @author hejianbo
	 * 
	 */
	public class ToolCtrl
	{
		public function ToolCtrl()
		{
		}
		
		/**
		 * 
		* 添加页面切换监听 
		 * @param timeOutCallBack  超时的回调
		 * @param time 超时时间
		 * @return 移除监听执行器
		 * 
		 */
		public static function visibleChangeListen(timeOutCallBack:Function, time:Number = 30):Function {
			var hidden = "hidden",
				state = "visibilityState",
				visibilityChange = "visibilitychange";
			var window = Browser.window;
			var document = window.document;
			if (typeof document.hidden !== "undefined") {
				visibilityChange = "visibilitychange";
				state = "visibilityState";
			} else if (typeof document.mozHidden !== "undefined") {
				visibilityChange = "mozvisibilitychange";
				state = "mozVisibilityState";
			} else if (typeof document.msHidden !== "undefined") {
				visibilityChange = "msvisibilitychange";
				state = "msVisibilityState";
			} else if (typeof document.webkitHidden !== "undefined") {
				visibilityChange = "webkitvisibilitychange";
				state = "webkitVisibilityState";
			}
			
			document.addEventListener(visibilityChange, visibleChangeFun);
			//开始时间
			var timeStart:Number = 0;
			function visibleChangeFun() {
				// 当前页面 锁屏或者 最小化
				if (document[state] == hidden) {
					timeStart = new Date().getTime();
					
					trace('隐藏页面');
				} else {
					var diffTime = Math.floor((new Date().getTime() - timeStart) / 1000);
					if (diffTime > time) {
						timeOutCallBack();
					}
					trace('显示页面', diffTime);
				}
			}
			
			return function() {
				document.removeEventListener(visibilityChange, visibleChangeFun);
			}
		}
		
	}
}