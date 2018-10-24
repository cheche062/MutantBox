package game.global.data
{
	import game.common.ResourceManager;
	import game.global.vo.BuildingVo;
	import game.global.vo.VoHasTool;

	/**
	 * DBBuilding 建筑信息源数据
	 * author:huhaiming
	 * DBBuilding.as 2017-3-13 下午5:26:06
	 * version 1.0
	 *
	 */
	public class DBBuilding
	{
		/**常量-建筑ID-基地*/
		public static const B_BASE:String = "1";
		/**常量-建筑ID-石材厂*/
		public static const B_STONE_F:String = "2";
		/**常量-建筑ID-钢材厂*/
		public static const B_STEEL_F:String = "3";
		/**常量-建筑ID-黄金厂*/
		public static const B_GOLD_F:String = "4";
		/**常量-建筑ID-食物厂*/
		public static const B_FOOD_F:String = "5";
		/**常量-建筑ID-石材仓库*/
		public static const B_STONE_S:String = "6";
		/**常量-建筑ID-钢材仓库*/
		public static const B_STEEL_S:String = "7";
		/**常量-建筑ID-黄金仓库*/
		public static const B_GOLD_S:String = "8";
		/**常量-建筑ID-食物仓库*/
		public static const B_FOOD_S:String = "9";
		/**常量-建筑ID-兵营*/
		public static const B_CAMP:String = "10";
		/**常量-建筑-宝箱*/
		public static const B_BOX:String = "11"
		/**常量-建筑ID-训练场*/
		public static const B_TRAIN:String = "12";
		/**常量-建筑ID-运镖*/
		public static const	B_TRANSPORT:String = "13";
		/**常量-建筑ID-基地互动*/
		public static const B_PROTECT:String = "14";
		/**常量-建筑ID-公会*/
		public static const B_GUILD:String = "16";
		/**常量-建筑ID-基因*/
		public static const B_GENE:String = "17";
		/**常量-建筑ID-雷达站*/
		public static const B_RADIO:String = "18";
		/**常量-建筑ID-商店*/
		public static const	B_STORE:String = "19";
		/**常量-建筑类型-装饰型*/
		public static const TYPE_DEC:int = 4;
		/**常量-建筑类型-生产型*/
		public static const TYPE_FARM:int = 3;
		/**常量-建筑类型-防御行*/
		public static const TYPE_DEFEND:int = 2;
		/**常量-建筑类型-功能*/
		public static const TYPE_FUN:int = 1;
		/**遗迹*/
		public static const B_RELIC:String="13";
		/**酒馆**/
		public static const B_HOTRL:String = "15";
		/**矿场**/
		public static const B_MINE:String = "20";
		/**常量-建筑ID-面包厂*/
		public static const B_BREAD_C:String = "24";
		/**常量-建筑ID-面包仓库*/
		public static const B_BREAD_K:String = "25";
		/**
		 * 竞技场
		 */
		public static const B_ARENA:String = "21";
		/**PVP*/
		public static const B_PVP:String = "22";
		/**组队副本*/
		public static const B_TEAMCOPY:String="23";
		
		public static const WALL_1:String = "B202";
		public static const WALL_2:String = "B203"
		/***/
		private static var _buildingList_json:Object;
		/**建筑初始容量*/
		private static var _cap:Object;
		/***/
		public function DBBuilding()
		{
			
			/*1	大本营
			2	石材厂
			3	钢材厂
			4	黄金厂
			5	食物厂
			6	石材仓库
			7	钢材仓库
			8	黄金仓库
			9	食物仓库
			10	兵营
			11	宝箱
			12	训练营
			13	运镖
			14	基地互动
			15	旅馆
			16	工会
			17	基因室
			18	雷达站
			19	商店
			21  竞技场
			100	机枪塔
			101	迫击炮
			102	瞭望塔
			103	防空火箭
			104	自动机枪塔
			105	电磁塔
			106	巨炮
			107	地图炮*/

		}
		
		/**
		 * 根据类型获取建筑配置信息，不包括大本营
		 * @param type 建筑类型 -1表示获取所有列表
		 * @return 数据列表
		 * */
		public static function getBuildListByType(type:Number = -1):Array{
			var arr:Array = [];
			for(var i:String in buildingList_json){
				if(type == -1 || buildingList_json[i].building_type == type){
					arr.push(buildingList_json[i]);
				}
			}
			arr.sort(sortFun);
			return arr;
			
			function sortFun(a:*, b:*):Number{
				return a.rank > b.rank ? 1 : -1
			}
		}
		
		/**
		 * 根据ID获取建筑信息
		 * {"level_limit":"15","rank":"1","building_describe":"310000","building_type":"1","initial_building":"1","building_id":"1","upgrade":"1","c_name":"大本营","destroy":"0","name":"300000"}
		 * @param id 建筑ID
		 * */
		public static function getBuildingById(id:String):Object{
			id = (id+"").replace("B", "");
			for(var i:String in buildingList_json){
				if(buildingList_json[i].building_id == id){
					return buildingList_json[i]
				}
			}
			return null;
		}
		
		/***/
		public static function getBasicCap(type:int):int{
			return cap[type]
		}
		
		/***/
		private static function get cap():Object{
			if(!_cap){
				var obj:Object = ResourceManager.instance.getResByURL("config/global_param.json");
				//2=22000;3=20000;4=23000;5=50000
				var str:String = obj[7].value;
				var arr:Array = str.split(";");
				_cap = {};
				var tmp:Array;
				for(var i:int=0; i<arr.length; i++){
					tmp = (arr[i]+"").split("=");
					_cap[tmp[0]] = parseInt(tmp[1]);
				}
			}
			return _cap;
		}
		
		/***/
		public static function get isChargeOn():Boolean{
			var obj:Object = ResourceManager.instance.getResByURL("config/global_param.json");
			return obj[12] && parseInt(obj[12].value) == 1
		}
		
		private static function get buildingList_json():Object{
			if(!_buildingList_json){
				_buildingList_json = ResourceManager.instance.getResByURL("config/building_list.json");
			}
			return _buildingList_json;
		}
	}
}