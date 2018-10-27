package game.global.vo.guild 
{
	/**
	 * ...
	 * @author ...
	 */
	public class GuildBossVo 
	{
		public var id:String = "";
		public var name:String = "";
		public var icon:String = "";
		public var open_r:String = "";
		public var mftz:int = "";
		public var level:Number = 0;
		public var lx:String = "";
		public var cxsj:Number = 0;
		public var mftz:Number = 0;
		public var cost:String = "";
		public var exp:Number = 0;
		public var show_reward:String = "";
		public var reward:String = "";
		public var ranking_reward:String = "";
		public var state:int = 0;
		public var type:String = "";
		public var fightTimes:int = 0;
		public var openTime:int = 0;
		
		
		public function GuildBossVo() 
		{
			
		}
		
		public function clone():GuildBossVo
		{
			var vo:GuildBossVo = new GuildBossVo();
			for(var key:* in vo)
			{
				vo[key] = this[key];
			}
			return vo;
		}
	}

}