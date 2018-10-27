package game.global.vo
{
	import game.module.bag.mgr.ItemManager;

	public class StageChapterRewardVo
	{
		public var point_condition:Number;
		public var chapter_reward:String;
		
		//isJY
		public var isJY:Boolean = false;
		public var cid:Number = 0;
		public var index:Number = 0;
		
		
		public function StageChapterRewardVo()
		{
		}
		
		private var _chapterReward:Array;
		public function get chapterReward():Array
		{
			if(!_chapterReward)
			{
				_chapterReward = ItemManager.StringToReward(chapter_reward);
			}
			return _chapterReward;
		}
		
		
	}
}