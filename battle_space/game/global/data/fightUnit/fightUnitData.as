/***
 *作者：罗维
 */
package game.global.data.fightUnit
{
	import game.global.GameConfigManager;
	import game.global.vo.FightUnitVo;
	import game.global.vo.SkillVo;

	public class fightUnitData
	{
		public var unitId:uint;
		public var maxHp:uint;
		public var hp:uint;
		public var direction:uint = 1;   //1 朝上 2朝下
		public var skin:String;
		public var wyid:String = "";
		private var _showPointID:String; 
		public static var allModel:String;
		
		public var buffList:Array = [];
		
		
		public function fightUnitData()
		{
		}
		
		public function get unitVo():FightUnitVo{
			var vo:FightUnitVo = GameConfigManager.unit_dic[unitId];
			if(allModel)
				vo.model = allModel;
			return vo;
		}
		
		public function get showPointID():String
		{
			return _showPointID;
		}
		
		public function set showPointID(value:String):void
		{
			_showPointID = value;
		}
		
		
		private var _selectSkill:SkillVo;
		public function get selectSkill():SkillVo
		{
			if(!_selectSkill)
			{
//				_selectSkill = skillVos[skillVos.length - 1];
				_selectSkill = unitVo.skillVos[0];
			}
			return _selectSkill;
		}
		
		public function set selectSkill(value:SkillVo):void
		{
			_selectSkill = value;
		}
		
		private var _skillVos:Array;
		public function get skillVos():Array{
			if(!_skillVos)
			{
				_skillVos = unitVo.skillVos;
			}
			return _skillVos;
		}
		
		public function set skillVos(v:Array):void{
			//trace("设置技能",v);
			_skillVos = v;
		}
		
	}
}