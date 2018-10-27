package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBFightEffect
	 * author:huhaiming
	 * DBFightEffect.as 2017-5-16 下午7:15:47
	 * version 1.0
	 *
	 */
	public class DBFightEffect
	{
		private static var _data:Object;
		public function DBFightEffect()
		{
		}
		
		public static function getEffectInfo(effectId:*):Object{
			return data[effectId]
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/fight_effect.json");
			}
			return _data;
		}
	}
}