package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBSkill2 被动技能数据字典
	 * author:huhaiming
	 * DBSkill2.as 2017-5-26 下午2:31:31
	 * version 1.0
	 *
	 */
	public class DBSkill2
	{
		private static var _data:Object;
		public function DBSkill2()
		{
		}
		
		/**获取技能信息*/
		public static function getSkillInfo(skillId:*):*{
			return data[skillId]
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/unit_skill2.json"); 
			}
			return _data;
		}
	}
}