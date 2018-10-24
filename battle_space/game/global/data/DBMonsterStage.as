package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBMonsterStage 怪物关卡
	 * author:huhaiming
	 * DBMonsterStage.as 2017-3-31 下午2:51:02
	 * version 1.0
	 *
	 */
	public class DBMonsterStage
	{
		private static var _db:Object;
		public function DBMonsterStage()
		{
		}
		
		/**根据关卡IDid获取信息*/
		public static function getMonsterInfo(stageId:String):Object{
			return db[stageId];
		}
				
		private static function get db():Object{
			if(!_db){
				_db = ResourceManager.instance.getResByURL("config/monster_level.json"); 
			}
			return _db;
		}
	}
}