package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBGeneRequire
	 * author:huhaiming
	 * DBGeneRequire.as 2017-6-29 下午6:40:46
	 * version 1.0
	 *
	 */
	public class DBGeneRequire
	{
		private static var _data:Object;
		public function DBGeneRequire()
		{
		}
		
		/***/
		public static function check(geneId:*, unitId:*):Boolean{
			if(unitId){
				var str:String = (data[geneId] && data[geneId].unit_id);
				if(str){
					return str.indexOf(unitId) != -1
				}
				return true;
			}
			return true
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/gene_require.json");
			}
			return _data;
		}
	}
}