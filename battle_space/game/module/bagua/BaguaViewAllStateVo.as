package game.module.bagua
{
	public class BaguaViewAllStateVo
	{
		/**目前的buffs*/
		public var buffs:Array = [];
		
		/**已领的阶段奖励*/
		public var getedStep:Array = [];
		
		/**大本营等级*/
		public var hqLevel:int = 0;
		
		/**关卡npc & 奖励*/
		public var levels:Object = {};
		/*
		{
			pass: 0, 是否通关
			rewards: "2=10;3=10" 奖励品
			team: [1445, 1445, 1446, 1449, 1447, 1448, 1447] // npc 敌人  相同的需要归纳起来
		}
		*/
		
		/**重置次数*/
		public var resetTimes:int = 0;
		
		/**各关卡存活人数*/
		public var usedUnits:Object = {};
		
		public function BaguaViewAllStateVo()
		{
		}
		
		// 处理各关卡存活人数
		public function usedUnitsHandler():Array{
			// 存活人数及关卡处理
			var id_arr:Array = [];
			for (var key:String in usedUnits) {
				id_arr.push(usedUnits[key]);
			}
			
			return id_arr;
		}
		
		
	}
}