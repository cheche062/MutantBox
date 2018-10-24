/***
 *作者：罗维
 */
package game.global
{
	import laya.net.LocalStorage;

	public class GameLanguage
	{
//		public static var LANGNAME:String = "English";
		
		public function GameLanguage()
		{
		}
		
		public static var lang:Object = {};
		
		public static function set langID(value:Number):void
		{
			
			_langID = value;
			LocalStorage.setItem("langID",_langID);
			
			GameSetting.reloadGame();
		}

		public static function getLangByKey(key:*):String{
			if(lang.hasOwnProperty(key)){
				var str:String = lang[key];
				return str.replace(/##/g, "\n");;
			}
			return key;
		}
		
		private static var _langID:* = null;
		public static function get langID():Number{
//			return 1;
			if(_langID == null)
			{
				var _langIDSTR:String = LocalStorage.getItem("langID");
				if(_langIDSTR)
					_langID = Number(_langIDSTR);
				
				if(!_langID)_langID = 1;
			}
			
			return _langID;
		}
	}
}