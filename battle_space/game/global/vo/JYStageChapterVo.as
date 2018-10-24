package game.global.vo
{
	import game.global.GameConfigManager;

	public class JYStageChapterVo extends StageChapterVo
	{
		public function JYStageChapterVo()
		{
			super();
		}
		
		
		public override function get levelList():Array{
			if(!_levelList)
			{
				_levelList = [];
				var ar:Array = GameConfigManager.stage_level_jy_arr;
				for (var i:int = 0; i < ar.length; i++) 
				{
					var slVo:StageLevelVo = ar[i];
					if(slVo.chapter_id == chapter_id)
						_levelList.push(slVo);
				}
				
			}
			return _levelList;
		}

	}
}