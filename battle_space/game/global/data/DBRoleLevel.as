package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBRoleLevel 角色升级经验数据表.
	 * author:huhaiming
	 * DBRoleLevel.as 2017-3-13 下午5:09:46
	 * version 1.0
	 *
	 */
	public class DBRoleLevel
	{
		private static var _db:Object;
		public function DBRoleLevel()
		{
		}
		
		/**获取升级经验*/
		public static function getLvExp(lv:Number):Number{
			var info:Object = db[lv];
			if(info){
				return info.need_exp;
			}
			return 0;
		}
		
		/***/
		private static function get db():Object{
			if(!_db){
				_db = ResourceManager.instance.getResByURL("config/building_character_level.json");
			}
			return _db;
		}
	}
}