package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBUnitStar 升星数据
	 * author:huhaiming
	 * DBUnitStar.as 2017-3-23 上午10:02:27
	 * version 1.0
	 */
	public class DBUnitStar
	{
		private static var _data:Object;
		public function DBUnitStar()
		{
		}
		
		public static function getStarData(starId:String):Object{
			return data[starId];
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/unit_soldier_star.json"); 
			}
			return _data;
		}
	}
}