package game.module.equipFight.data
{
	import game.global.GameConfigManager;
	import game.module.equipFight.vo.equipFightChapterVo;

	public class equipFightChapterData
	{
		
		public var chapterId:Number;
		public var isOpen:Boolean ;   
		
		private var _vo:equipFightChapterVo;
		
		public function equipFightChapterData()
		{
		}

		
		// 0开启  1级别不够 2前置未达成

		public function get vo():equipFightChapterVo
		{
			if(!_vo)
			{
				var list:Array = GameConfigManager.equipFightChapters;
				for (var i:int = 0; i < list.length; i++) 
				{
					var v:equipFightChapterVo = list[i];
					if(v.id == chapterId)
					{
						_vo = v;
						break;
					}
				}
			}
			return _vo;
		}

		public function get state():Number
		{
			return 2;
		}

	}
}