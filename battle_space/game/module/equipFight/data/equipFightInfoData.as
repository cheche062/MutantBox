package game.module.equipFight.data
{
	import game.global.GameConfigManager;
	import game.global.vo.FightUnitVo;

	public class equipFightInfoData
	{
		
		public var heroId:Number;
		public var state:Number = 0;   // 0 未开启 1开启 2全通
		public var voList:Array = [];   //章结list
		private var _vo:FightUnitVo;
		
		public function equipFightInfoData()
		{
		}
		
		

		public function get vo():FightUnitVo
		{
			if(!_vo)
				_vo =  GameConfigManager.unit_dic[heroId];
			return _vo;
		}

	}
}