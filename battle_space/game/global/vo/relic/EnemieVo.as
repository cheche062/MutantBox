package game.global.vo.relic
{
	public class EnemieVo
	{
		public var Uid:String;
		public var userName:String;
		public var userLevel:String;
		public var getItem:Array;
		public var Plan:int;
		public var Vehicle:int;
		public var startTime:Number;
		public var endTime:Number;
		public var isSelf:Boolean;
		public var nowTime:int;
		public var lostItems:Array;
		public var vipItems:Array;
		public var plunderTimes:int;
		public var totalPower:int=0;
		public function EnemieVo()
		{
		}
	}
}