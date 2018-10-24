package game.common
{
	public class UIRegisteredMgr
	{
		/**
		 *全局的UI注册器
		 *注意回收 
		 */
		private static var uiList:Object  = {};
		public function UIRegisteredMgr()
		{
		}
		
		public static function AddUI(ui:*,key:String):void{
			uiList[key] = ui;
			//trace("add key: ", key);
		}
		
		public static function getTargetUI(key:String):*
		{
			return uiList[key]
		}
		
		public static function DelUi(key:String):void
		{
			//trace("del key: ", key);
			delete uiList[key];
		}
		
	}
}