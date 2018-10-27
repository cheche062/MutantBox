package game.global.vo
{
	import flash.utils.Dictionary;

	public class LevelGiftVo extends Object
	{
		public var lv:String;
		public var reward:String;
		/**
		 *奖励的领取状态:0不能领，1可以领，2已经领 
		 */
		public var status:Boolean;
		public function LevelGiftVo(data:Object)
		{
			super();
		}
	}
}