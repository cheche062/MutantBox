package game.global.vo.unit
{
	public class UnitUpgradeExpVo
	{
		public var level:int;
		public var hero_exp1:int;
		public var hero_exp2:int;
		public var hero_exp3:int;
		public var hero_exp4:int;
		public var hero_exp5:int;
		public var hero_exp6:int;
		public var soldier_exp1:int;
		public var soldier_exp2:int;
		public var soldier_exp3:int;
		public var soldier_exp4:int;
		public var soldier_exp5:int;
		public var soldier_exp6:int;
		
		public function UnitUpgradeExpVo()
		{
		}
		
		public function getHeroExp(p_type:int):int
		{
			switch(p_type)
			{
				case 1:
				{
					return hero_exp1;
				}
				case 2:
				{
					return hero_exp2;
				}
				case 3:
				{
					return hero_exp3;
				}
				case 4:
				{
					return hero_exp4;
				}
				case 5:
				{
					return hero_exp5;
				}
				case 6:
				{
					return hero_exp6;
				}
			}
			
			return 0;
		}
		
		public function getSoldierExp(p_type:int):int
		{
			switch(p_type)
			{
				case 1:
				{
					return soldier_exp1;
				}
				case 2:
				{
					return soldier_exp2;
				}
				case 3:
				{
					return soldier_exp3;
				}
				case 4:
				{
					return soldier_exp4;
				}
				case 5:
				{
					return soldier_exp5;
				}
				case 6:
				{
					return soldier_exp6;
				}
			}
			return 0;
		}
		
	}
}