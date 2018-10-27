package game.global.data
{
	import game.common.ResourceManager;
	import game.global.vo.User;

	/**
	 * DBBuildNum 建筑数量限制
	 * author:huhaiming
	 * DBBuildNum.as 2017-3-15 上午9:51:29
	 * version 1.0
	 *
	 */
	public class DBBuildingNum
	{
		private static var _data:Object
		public static const MAX_LV:int = 17;
		public function DBBuildingNum()
		{
		}
		
		/**
		 * 获取建筑的最大数量
		 * @param bId 建筑id
		 * @param baseLv 大本营等级
		 * */
		public static function getBuildingMax(bId:*):Number{
			if((bId+"").replace("B") == DBBuilding.B_BASE){
				return 1;
			}
			return getBuildingNum(bId, MAX_LV);
		}
		
		/**获取下级大本营新增的建筑列表*/
		public static function getNewBuingList(baseLv:int):Array{
			var arr:Array = [];
			var info:Object = data[baseLv];
			var nextInfo:Object = data[baseLv+1];
			if(nextInfo){
				//先找开始能建的;
				for(var i:String in nextInfo){
					if(nextInfo[i] == 1 && info[i] == 0 && i != "B1"){
						arr.push(i);
					}
				}
				//找数量增加的;
				for(var i:String in nextInfo){
					if(info[i] != 0 && nextInfo[i] > info[i] && i != "B1"){
						arr.push(i);
					}
				}
			}
			return arr;
		}
		
		
		/**
		 * 获取当前大本营等级下建筑的数量限制
		 * @param bId 建筑id
		 * @param baseLv 大本营等级
		 * */
		public static function getBuildingNum(bId:*, baseLv:Number):Number{
			if((bId+"").replace("B") == DBBuilding.B_BASE){
				return 1;
			}
			var info:Object = data[baseLv];
			if(info){
				if((bId+"").indexOf("B") == -1){
					bId = "B"+bId;
				}
				return info[bId];
			}
			return 0
		}
		
		/**
		 *根据建筑数量获取大本营等级
		 */
		public static function getBaseLv(bid:*, bnum:int):int{
			for(var i:int=1; i<=MAX_LV; i++){
				if(getBuildingNum(bid, i) >= bnum){
					return i;
				}
			}
			return 0;
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/building_num.json");
			}
			return _data;
		}
	}
}