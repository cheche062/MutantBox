package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBBuildingAttribute 防御建筑属性
	 * author:huhaiming
	 * DBBuildingAttribute.as 2017-4-18 下午5:23:27
	 * version 1.0
	 *
	 */
	public class DBBuildingAttribute
	{
		//原始数据
		private static var _data:Object;
		public function DBBuildingAttribute()
		{
		}
		
		public static function getAttr(attId:*):Object{
			return data[attId]
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/building_attribute.json");
			}
			return _data;
		}
	}
}