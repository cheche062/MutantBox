package game.module.mainui
{
	import game.common.ToolFunc;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;

	/**
	 * SceneVo 场景数据包
	 * author:huhaiming
	 * SceneVo.as 2017-3-10 下午2:32:20
	 * version 1.0
	 *
	 */
	public class SceneVo
	{
		/**
		 * 10101
	    {
	        "queue":[["2_pzvZ",1488187895,0],[]],
	        "trash":[],
	        "building":{"1_abcd":[37,31,1,1],"2_pzvZ":[1,2,3,0]}}], 
	        "isError":false,
	        "commandId":10101
	    }
		queue 建造队列
		trash  已经铲除的障碍物
		building  建筑列表  37,31,1,1   x坐标 y坐标  建筑id   等级
		 * 
		 * */
		/**建造队列*/
		public var queue:Array=[];
		/**已经铲除的障碍物*/
		public var trash:Array;
		/**建筑列表*/
		public var building:Object;
		/**区块等级*/
		public var fog:Number; 
		/**基地互动次数信息*/
		public var base_rob_info:Object;
		
		public function SceneVo()
		{
			
		}
		
		/**赋值*/
		public function updateValue(info:Object):void{
			for(var i:String in info){
				if(this.hasOwnProperty(i)){
					this[i] = info[i];
				}
			}
		}
		
		/**更新建筑等级*/
		public function updateBuildLv(id:String, lv:int):void{
			building[id] && (building[id]["level"] = lv);
		}
		public function hasBuildingInQueue(Bid:Number):Boolean
		{
		
				for(var i:int=0;i<queue.length;i++)
				{
					if(queue[i].length>0)
					{
						var id:String = queue[i][0];
						
						trace("后端建筑id:"+id);
//						trace("building:"+JSON.stringify(building));
						var bid:Number =Number( building[id]["id"]);
						if(bid==Bid)
						{
							return true;
						}
					}
					
				}
			return false;
		}
		/**销毁建筑数据*/
		public function ruin(bid:String):void{
			delete building[bid];
		}
		
		/**获取队列列表*/
		public function getQueueId(bid:String):*{
			for(var i:Number=0; i<this.queue.length; i++){
				if(this.queue[i][0] == bid){
					return i;
				}
			}
			return 0;
		}
		
		/**获取资源最大容量*/
		public function getResCap(type:int):Number{
			var arr:Array;
			var cap:Number = DBBuilding.getBasicCap(type);
			switch(type){
				case DBItem.GOLD:
					arr = [/*DBBuilding.B_GOLD_F,*/ DBBuilding.B_GOLD_S];
					break;
				case DBItem.STEEL:
					arr = [/*DBBuilding.B_STEEL_F,*/DBBuilding.B_STEEL_S];
					break;
				case DBItem.STONE:
					arr = [/*DBBuilding.B_STONE_F,*/DBBuilding.B_STONE_S];
					break;
				case DBItem.FOOD:
					arr = [/*DBBuilding.B_FOOD_F, */DBBuilding.B_FOOD_S];
					break;
				case DBItem.BREAD:
					arr = [/*DBBuilding.B_FOOD_F, */DBBuilding.B_BREAD_K];
					break;
			}
			for(var i:String in building){
				if(arr.indexOf(building[i].id+"") != -1){
					var db:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(building[i].id, building[i].level);
					if(db){
						cap += parseInt(db.buldng_capacty.split("=")[1]);
					}
				}
			}
			return cap; 
		}
		
		/**获取资源总生产率*/
		public function getOutPut(type:int):Number{
			var arr:Array;
			var output:Number = 0;
			switch(type){
				case DBItem.GOLD:
					arr = [DBBuilding.B_GOLD_F];
					break;
				case DBItem.STEEL:
					arr = [DBBuilding.B_STEEL_F];
					break;
				case DBItem.STONE:
					arr = [DBBuilding.B_STONE_F];
					break;
				case DBItem.FOOD:
					arr = [DBBuilding.B_FOOD_F];
					break;
				case DBItem.BREAD:
					arr = [DBBuilding.B_BREAD_C];
					break;
			}
			for(var i:String in building){
				if(arr.indexOf(building[i].id+"") != -1){
					var db:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(building[i].id, building[i].level);
					if(db){
						output += parseInt(db.buldng_output.split("=")[1]);
					}
				}
			}
			return output;
		}
		
		/**
		 * 获取队列剩余时间,单位分钟
		 * @param bid 如果等于-1，取列表第一个值
		 * */
		public function getQueueTime(bid:String="-1"):Number{
			var time:Number = 0;
			if(bid == "-1"){
				time =  Math.ceil((this.queue[0][1]*1000 - TimeUtil.now)/ (60*1000));
			}else{
				for(var i:Number=0; i<this.queue.length; i++){
					if(this.queue[i][0] == bid){
						time =  Math.ceil((this.queue[i][1]*1000 - TimeUtil.now)/ (60*1000));
						break;
					}
				}
			}
			return Math.max(0,time);
		}
		
		/**
		 * 获取建筑物时候可以帮助
		 * @param	bid
		 * @return
		 */
		public function getCanHelp(bid:String = "-1"):Boolean
		{
			if (User.getInstance().guildID == "")
			{
				return false
			}
			
			for (var i:Number = 0; i < this.queue.length; i++)
			{
				if (this.queue[i][0] == bid && this.queue[i][5] == 0)
				{
					return true;
				}
			}
			return false
		}
		
		
		public function setHelp(bid:String = "-1"):void
		{
			for (var i:Number = 0; i < this.queue.length; i++)
			{
				if (this.queue[i][0] == bid )
				{
					this.queue[i][5] = 1;
				}
			}
		}
		
		public function updateBuildQueue(bid:String = "-1",arr:Array=null):void
		{
			for (var i:Number = 0; i < this.queue.length; i++)
			{
				if (this.queue[i][0] == bid )
				{
					this.queue[i] = arr;
				}
			}
		}
		
		/**
		 * 根据建筑ID获取队列剩余时间
		 * @param id，建筑ID
		 * */
		public function getTimeByBid(id:String):Number{
			var info:Object = getBuildingInfo(id);
			if(info){
				return getQueueTime(info.uid)
			}
			return 0;
		}
		
		/***/
		public function isQueueFull():Boolean{
			for(var i:String in queue){
				if(!queue[i] || queue[i].length == 0){
					return false
				}
			}
			return true;
		}
		
		/**获取大本营等级*/
		public function getBaseLv():Number{
			for(var i:String in building){
				if(building[i] && building[i]["id"] == DBBuilding.B_BASE){
					return  building[i]["level"];
					break;
				}
			}
			return 1;
		}
		
		/**获取建筑物信息*/
		public function getBuildingInfo(bid:String):Object{
			bid = bid.replace("B","");
			for(var i:String in building){
				if(building[i] && building[i]["id"] == bid){
					//绑定唯一ID
					building[i].uid = i;
					return building[i];
				}
			}
			return null;
		}
		
		/**获取建筑等级*/
		public function getBuildingLv(bid:String):Number{
			bid = bid.replace("B","");
			for(var i:String in building){
				if(building[i] && building[i]["id"] == bid){
					return building[i]["level"];
				}
			}
			return 0
		}
		
		/**
		 * 根据建筑获取建筑数量
		 * @param bid 建筑id
		 * */
		public function getBuildingNum(bid:String):Number{
			bid = bid.replace("B","");
			var num:Number = 0;
			for(var i:String in building){
				if(building[i] && building[i]["id"] == bid){
					num ++;
				}
			}
			return num;
		}
		
		/**是否有某id的建筑物*/
		public function hasBuilding(bid:String):Boolean {
			return ToolFunc.objectValues(building).some(function(item) {
				return item["id"] == bid;
			});
		}
	}
}