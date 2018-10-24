package game.common
{

	/**
	 * 
	 * @author hejianbo
	 * 
	 */
	public class CreateStore
	{
		/**监察器*/
		private var watcher:Object = {};
		/**状态数据*/
		private var state:Object;
		
		public function CreateStore(data)
		{
			state = data;
		}
		
		/**
		 * 订阅
		 * @param key 订阅的字段
		 * @param fn 订阅的回调函数
		 * 
		 */
		public function subscribe(key:String, fn:Function):void {
			if (typeof key !== "string") throw ('key is not a string');
			if (typeof fn !== "function") throw ('fn is not a function');
			if (watcher[key]) {
				var data = watcher[key];
				if (ToolFunc.isArray(data)) data.push(fn);
				else watcher[key] = [data, fn];
				
			} else watcher[key] = fn;
		}
		
		/**发布数据变化*/
		public function dispatch(obj:Object):void {
			for (var key in obj) {
				if (!state.hasOwnProperty(key)) break;
				state[key] = obj[key];
				var list:* = watcher[key]; 
				if (typeof list == "function") {
					list(obj[key]);
				} else {
					list.forEach(function(item) {
						item(obj[key]);
					});
				}
			}
		}
		
		public function getState():*{
			return state;
		}
		
		public function clear():void {
			watcher = {};
		}
	}
}