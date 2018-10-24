package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBShield
	 * author:huhaiming
	 * DBShield.as 2017-4-27 下午5:17:49
	 * version 1.0
	 *
	 */
	public class DBShield
	{
		private static var _data:Object;
		private static var _list:Array;
		public function DBShield()
		{
		}
		
		public static function getShieldList():Array{
			if(!_list){
				_list = []
				for(var i:int=0; i<999; i++){
					if(data[i+1]){
						_list[i] = data[i+1];
					}else{
						break;
					}
				}
			}
			return _list;
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/base_shield.json"); 
			}
			return _data;
		}
	}
}