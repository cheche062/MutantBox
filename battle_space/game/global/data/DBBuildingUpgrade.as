package game.global.data
{
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.global.vo.VoHasTool;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.SceneVo;

	/**
	 * DBBuildingUpgrade 建筑升级数据原型
	 * author:huhaiming
	 * DBBuildingUpgrade.as 2017-3-13 下午4:16:58
	 * version 1.0
	 *
	 */
	public class DBBuildingUpgrade
	{
		//原始数据
		private static var _db:Object;
		//数据包装
		private static var _vos:Array = [];
		/**属性映射,*/
		private static var PROS:Object = {}
		public function DBBuildingUpgrade()
		{
			
		}
		
		
		/** 
		 * 根据ID,等级，获取建筑升级信息
		 * @param id 建筑id
		 * @param lv 建筑等级
		 */
		public static function getBuildingLv(id:*, lv:Number):BuildingLevelVo{
			id = id+"";
			id = id.replace("B","");
			for(var i:String in vos){
				if(vos[i].building_id == id && vos[i].level == lv){
					return vos[i]
				}
			}
			return null;
		}
		
		/**
		 * 判定是否可以建造/升级
		 * @param id 建筑id
		 * @param lv 建筑等级
		 * */
		public static function checkCanUp(id:Number, lv:Number = 1, needCheckRes:Boolean=false, checkCarch:Boolean=false):Boolean{
			var vo:BuildingLevelVo = getBuildingLv(id+"", (lv || 1));
			if(vo){
				//等级判定
				var user:User = User.getInstance();
				if(vo.character_level > user.level){
					return false;
				}
				
				/**是否达到最大等级*/
				var db:Object = DBBuilding.getBuildingById(id+"");
				if( lv >= db.level_limit ){
//					trace("达到最大等级");
					return false;
				}
				//trace("checkCanUp----------------------------->>",id,lv,db.level_limit);
				
				/**判定材料*/
				/**如果是碎片，并且需要检查，进入材料检验*/
				if(needCheckRes || (checkCarch && vo.ornot == 0)){//
					var arr:Array;
					if(vo.cost1){
						arr = vo.cost1.split("=");
						if(User.getInstance().getResNumByItem(arr[0]) < parseInt(arr[1])){
							return false;
						}
					}
					if(vo.cost2){
						arr = vo.cost2.split("=");
						if(User.getInstance().getResNumByItem(arr[0]) < parseInt(arr[1])){
							return false;
						}
					}
				}
				
				//大本营等级判定,
				var sceneInfo:SceneVo = user.sceneInfo
				var baseLv:Number = sceneInfo.getBaseLv();
				if(baseLv < vo.HQ_level){
//					trace(id,"-----------------大本营等级不足",vo.HQ_level);
					return false;
				}else if(baseLv == vo.HQ_level)//判断大本营是否在队列里
				{
					for(var i:int=0;i<sceneInfo.queue.length;i++)
					{
						if(sceneInfo.queue[i].length>0)
						{
							var hid:String = sceneInfo.queue[i][0];
							//trace("后端建筑id:"+id);
							var bid:String = sceneInfo.building[hid]["id"];
							
							trace("bid--------"+bid);
							if(bid=="1")
							{
								trace("大本营在建筑队列中");
								return false;
							}
						}
					}
				}
			}else{
				return false;
			}
			return true;
		}
		
		public static function isMax(id:Number):Boolean{
			var sceneInfo:SceneVo = User.getInstance().sceneInfo;
			var max:Number = DBBuildingNum.getBuildingNum(id, sceneInfo.getBaseLv());
			var curNum:int = sceneInfo.getBuildingNum(id);
			return curNum >= max;
		}
		
		/**建造的数量是否达到最大的可建造数量*/
		public static function isMaxNum(id:Number):Boolean{
			var sceneInfo:SceneVo = User.getInstance().sceneInfo;
			var max:Number =  DBBuildingNum.getBuildingMax(id);
			var curNum:int = sceneInfo.getBuildingNum(id);
			if(curNum >= max || max == 0){
				return true;
			}
			else{
				return false;
			}
		}
		
		/**是否有能建的建筑*/
		public static function check(type:Number = -1):Boolean{
			var list:Array = DBBuilding.getBuildListByType(type);
			for(var i:int=0; i<list.length; i++){
				if(checkCanUp(list[i].building_id, 0, false, true) && !isMax(list[i].building_id)){
					//trace("checkCanUp(list[i].building_id-----------------------",list[i].building_id);
					return true
				}
			}
			return false;
		}
		
		public static function getUpStr(id:*, lv:Number = 1):Array{
			var vo:BuildingLevelVo = getBuildingLv(id+"", lv);
			var srcList:Array = [];
			if(vo){
				var user:User = User.getInstance();
				var arr:Array;
				var key:*;
				var itemD:ItemData;
				if(vo.cost1){
					arr = vo.cost1.split("=");
					key = arr[0];
					//if(user[key] < parseFloat(arr[1])){
						itemD = new ItemData(); 
						itemD.iid = key;
						itemD.inum = parseFloat(arr[1]);
						srcList.push(itemD);
					//}
				}
				if(vo.cost2){
					arr = vo.cost2.split("=");
					key = arr[0];
					//if(user[key] < parseFloat(arr[1])){
						itemD = new ItemData(); 
						itemD.iid = key;
						itemD.inum = parseFloat(arr[1]);
						srcList.push(itemD);
					//}
				}
			}
			return srcList;
		}
		
		/**获取兵营升级新增unit*/
		public static function getNewUnit(campLv:int):Array{
			var arr:Array = [];
			var info:Object = getBuildingLv(DBBuilding.B_CAMP,campLv+1);
			if(info && info.param1){
				arr = (info.param1+"").split("|");
			}
			return arr;
		}
		
		/**
		 * 解析数据源,使用前数据包必须已经加载
		 * */
		private static function get vos():Object{
			if(!_db){
				//ID指向角色属性
				PROS[DBItem.STEEL] = "steel";
				PROS[DBItem.STONE] = "stone"
				
				_db = ResourceManager.instance.getResByURL("config/building_upgrade.json");
				if(_db)
				{
					var vo:*;
					var c:*; 
					for each (c in _db) 
					{
						vo = VoHasTool.hasVo(BuildingLevelVo,c);
						_vos.push(vo);
					}
				}
			}
			return _vos;
		}
	}
}