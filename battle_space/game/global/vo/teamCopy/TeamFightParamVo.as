package game.global.vo.teamCopy
{
	public class TeamFightParamVo
	{
		public var freeRefreshTime:int;
		public var freeBattleTime:int;
		public var masterRewardTime:int;
		public var guildRewardTime:int;
		public var chatMax:int;
		public function TeamFightParamVo()
		{
		}
		
		public function getRewardTime():int
		{
			return parseInt(masterRewardTime);
		}
		
		public function getRewardMax():int
		{
			return parseInt(guildRewardTime);
			
		}
	}
}