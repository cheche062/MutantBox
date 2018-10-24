package game.global.vo.tech 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class TechUpdateVo
	{
		public var id:String = "";
		public var tech_id:String = "";
		public var level:String = "";
		public var name:String = "";
		public var des:String = "";
		public var icon:String = "";
		public var tier:String = "";
		public var condition:String = "";
		public var cost:String = "";
		public var cost_reset:String = "";
		public var type:String = "";
		public var effect1:String = "";
		public var effect2:String = "";
		public var param:String = "";
		public var max:String = "";
		
		public function TechUpdateVo() 
		{
			
			
		}
		
		public function clone():TechUpdateVo
		{
			
			var vo:TechUpdateVo = new TechUpdateVo();
			vo.id = id;
			vo.tech_id = tech_id;
			vo.level = level;
			vo.name = name;
			vo.des = des;
			vo.icon = icon;
			vo.tier = tier;
			vo.condition = condition;
			vo.cost = cost;
			vo.cost_reset = cost_reset;
			vo.type = type;
			vo.effect1 = effect1;
			vo.effect2 = effect2;
			vo.param = param;
			vo.max = max;
			
			return vo;
			
		}
		
	}

}