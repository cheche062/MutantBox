package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBGeneSuit 基因套装数据
	 * author:huhaiming
	 * DBGeneSuit.as 2017-4-5 下午3:52:01
	 * version 1.0
	 *
	 */
	public class DBGeneSuit
	{
		private static var _data:Object;
		public function DBGeneSuit()
		{
		}
		
		/**
		 * 获取套装属性
		 * @param sid 套装id
		 * @param sNum 套装件数
		 * */
		public static function getSuitInfo(sid:String, sNum:Number):String{
			if(sNum < 2){
				return "";
			}else{
				if(data[sid]){
					return data[sid]["attribute"+sNum];
				}
			}
			return ""
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/gene_suit.json");
			}
			return _data;
		}
	}
}