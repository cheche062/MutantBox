/***
 *作者：罗维
 */
package game.global.fighting.manager
{
	import laya.utils.Handler;

	public class FightingShowFormatData
	{
		public static const TYPE_REPORT:String ="report";  //战报
		public static const TYPE_SQUAD:String = "squad";  //战斗
		public static const TYPE_PRESET:String = "preset";  //预设阵形
		public static const TYPE_SIMULATION:String = "Simulation";  //模拟战斗
		public static const TYPE_PVP_BUZHEN:String = "pvpbz";  //PVP布阵
		public static const TYPE_GUILD_FIGHT:String = "guildFight";
		public static const TYPE_RADAR:String = "radar";
		public static const TYPE_FORTRESS:String = "fortress";
		public static const RANDOM_CONDITION:String = "random";
		public static const PEOPLE_FALL_OFF:String = "PEOPLE_FALL_OFF";
		public static const CLIMB_TOWER:String = "CLIMB_TOWER";
		public var type:String;
		public var data:*;
		public var complete:Handler;
		public var bgType:Number = 1;
		
		public function FightingShowFormatData()
		{
		}
		
		
		public static function create(_type:String,_data:*,_bgType:Number,_complete:Handler = null):FightingShowFormatData{
			var r:FightingShowFormatData = new FightingShowFormatData();
			r.type = _type;
			r.data = _data;
			r.bgType = _bgType;
			r.complete = _complete;
			return r;
		}
	}
}