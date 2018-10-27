package game.global.data
{
	import game.common.ResourceManager;
	import game.common.XUtils;

	/**
	 * DBGeneList 基因列表
	 * author:huhaiming
	 * DBGeneList.as 2017-3-28 下午5:13:57
	 * version 1.0
	 *
	 */
	public class DBGeneList
	{
		private static var _data:Object;
		/**最大等级*/
		public static var MAX_LV:int = 20;
		public function DBGeneList()
		{
		}
		
		/**获取基因信息*/
		public static function getGeneInfo(gid:Number):Object{
			for(var i:String in data){
				if(data[i].gene_item == gid){
					return data[i];
				}
			}
			return null;
		}
		
		/**
		 * 根据道具关联信息获取基因信息
		 * */
		public static function getGeneInfoByItemId(itemId:Number, lv:Number):Object{
			for(var i:String in data){
				if(data[i].type == itemId && data[i].level == lv){
					return data[i];
				}
			}
			return null;
		}
		
		/**更具道具ID/基因类型(type)获取基因的最高等级*/
		public static function getGeneMaxLv(itemId:Number):int{
			var lv:int = 1;
			for(var i:String in data){
				if(data[i].type == itemId){
					lv = Math.max(lv, data[i].level);
				}
			}
			return lv;
		}
		
		/**解析数据包*/
		public static function parsePro(proStr:String):Object{
			if(!proStr){
				return null;
			}
			var obj:Object = new Object();
			var list:Array = proStr.split(";");
			for(var i:int=0; i<list.length; i++){
				var tmp:Array = list[i].split("=");
				obj[XUtils.getProKey(tmp[0])] = parseFloat(tmp[1]);
			}
			return obj;
		}
		
		/**根据总经验和当前经验计算等级和经验*/
		public static function getLvInfo(lv:int, itemId:*, exp:Number):Object{
			var curInfo:Object = getGeneInfoByItemId(itemId, lv);
			while(exp >= curInfo.exp){
				if(lv < MAX_LV){
					lv ++;
					exp -= curInfo.exp
					curInfo = getGeneInfoByItemId(itemId, lv);
				}else{
					break;
				}
			}
			return {exp:exp,info:curInfo};
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/gene_list.json");
			}
			return _data;
		}
	}
}