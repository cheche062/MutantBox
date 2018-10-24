package game.global.vo.relic
{
	
	import game.global.GameConfigManager;

	public class TransportBaseInfo
	{
		//运镖初始化
		public var planList:Array;
		public var vehicleList:Array;
		public var plan:int;
		public var vehicle:int;
		public var transTimes:int;
		public var flushTimes:int;
		public var status:int;
		public var endTime:Number;
		public var canUseVehicle:Array;
		public var todayBoughtTimes:int;
		public var totalBoughtTimes2:int;
		public var freePlan:int;
		public var totalPower:int=0;
		public var totalBoughtTimes1:int=0;
		public var freePlanSelectedTimes:int=0;
		//运镖抢夺
		public var fightTimes:int;
		public var PlanId:int;
		public var VehicleId:int;
		public var nowTime:Number;
		public var startTime:Number;
		public var plunderTimes:int;
		public var lostItems:Array;
		public var rewards:Array;
		public var Enemies:Array;
		public var vipRewards:Array;
		
		public var myPlan:TransportPlanInfoVo;
		public var isLog:Boolean=false;
		
		public var isAnimation=true;
		public var state:int=0;
		public function TransportBaseInfo()
		{
		}
		
		public function setPlanList(p_obj:Object):void
		{
			planList=new Array();
			myPlan=null;
			for (var i:int = 0; i < GameConfigManager.TransportPlanList.length; i++) 
			{
				var l_vo:TransportPlanVo=GameConfigManager.TransportPlanList[i];
				var l_tranVo:TransportPlanInfoVo=new TransportPlanInfoVo();
				var l_status:int=p_obj[l_vo.id];
				if(l_status!=undefined&&l_status!=null)
				{
					l_tranVo.baseVo=l_vo;
					l_tranVo.status=l_status;
					if(freePlan==l_vo.id)
					{
						l_tranVo.isFree=1;
					}
					if(plan==l_vo.id)
					{
						myPlan=l_tranVo;
						l_tranVo.status=3;
					}
					
					planList.push(l_tranVo);
				}
			}
			planList.sort(sortPlanHandler);
			
			
		}
		
		
		private function sortPlanHandler(p_a:TransportPlanInfoVo,p_b:TransportPlanInfoVo)
		{
			if(p_a.baseVo.type==1)
			{
				return -1;
			}
			if(p_b.baseVo.type==1)
			{
				return 1;
			}
			
			return 0;
		}
		
		
		
		/**
		 * 
		 */
		public function setEnemieList(p_obj:Object):void
		{
			Enemies=new Array();
			for (var i:int = 0; i < p_obj.length; i++) 
			{
				var l_EnemieVo:EnemieVo=new EnemieVo();
				var l_obj:Object=p_obj[i];
				l_EnemieVo.Uid=l_obj.uid;
				l_EnemieVo.userName=l_obj.userName;
				l_EnemieVo.userLevel=l_obj.userLevel;
				l_EnemieVo.getItem=l_obj.getItem;
				l_EnemieVo.Plan=l_obj.Plan;
				l_EnemieVo.Vehicle=l_obj.vehicle;
				l_EnemieVo.startTime=l_obj.startTime;
				l_EnemieVo.endTime=l_obj.endTime;
				l_EnemieVo.totalPower=l_obj.totalPower;
				l_EnemieVo.isSelf=false;
				Enemies.push(l_EnemieVo);
			}
		}
		
		public function getISUseVehicle(p_level:int):void
		{
			canUseVehicle=new Array();
			for (var i:int = 0; i < GameConfigManager.TransportVehicleList.length; i++) 
			{
				var l_vo:TransportVehicleVo=GameConfigManager.TransportVehicleList[i];
				var l_infoVo:TransportVehicleInfo=new TransportVehicleInfo();
				var l_isUse:Boolean;
				var maxLevel:int=l_vo.level.split("|")[1];
				var minLevel:int=l_vo.level.split("|")[0];
				
				if(p_level<=maxLevel&&p_level>=minLevel)
				{
					l_infoVo.baseVo=l_vo;
					canUseVehicle.push(l_infoVo);
				}
				if(l_infoVo.baseVo!=null)
				{
					if(vehicleList[l_infoVo.baseVo.id]!=null&&vehicleList[l_infoVo.baseVo.id]!=undefined)
					{
						l_infoVo.status=1
						if(l_infoVo.baseVo.id==vehicle)
						{
							l_infoVo.status=2;
						}
					}
					
					for (var j:int = 0; j < 3; j++) 
					{
						if(l_infoVo.baseVo.id==vehicleList[j])
						{
							l_infoVo.status=1;
							if(l_infoVo.baseVo.id==vehicle)
							{ 
								l_infoVo.status=2;
							}
							break;
						}	
					}
				}
			}
		}
		
	}
}