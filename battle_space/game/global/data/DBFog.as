package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBFog 迷雾配置
	 * author:huhaiming
	 * DBFog.as 2017-4-11 上午10:26:48
	 * version 1.0
	 *
	 */
	public class DBFog
	{
		private static var _data:Object;
		public function DBFog()
		{
			
		}
		
		/**获取迷雾信息*/
		public static function getFogInfo(fogId:String):Object{
			return data[fogId];
		}
		
		/***/
		public static function get maxFogId():Number{
			return 9;
			var max:Number = 0;
			for(var i:String in data){
				max = Math.max(max, parseInt(i));
			}
			return max
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/fog_area.json");
			}
			return _data;
		}
	}
}