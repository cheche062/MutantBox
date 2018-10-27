/***
 *作者：罗维
 */
package game.global.vo
{
	import game.global.GameConfigManager;
	
	import laya.maths.Point;

	public class StageChapterVo
	{
		public var chapter_id:Number = 0;
		public var chapter_name:String;
		public var chapter_icon:String;
		public var chapter_coordinate:String;
		public var chapter_condition:Number = 0;
		
		
		public var chapter_back:String;
		
		public var c_r:Number = 0;
		
		private var maxRequirement:Number = 3;
		public function StageChapterVo()
		{
			for (var i:int = 1; i <= maxRequirement; i++) 
			{
				this["point_condition"+i] = 0;  //
				this["chapter_reward"+i] = null;  //
			}
			
		}
		
		private var _chapterRewardList:Array;
		public function get chapterRewardList():Array
		{
			if(!_chapterRewardList)
			{
				_chapterRewardList = [];
				
				for (var i:int = 1; i <= maxRequirement; i++) 
				{
					if(this["point_condition"+i])
					{
						var vo:StageChapterRewardVo = new StageChapterRewardVo();
						vo.point_condition = this["point_condition"+i];
						vo.chapter_reward = this["chapter_reward"+i];
						vo.cid = this.chapter_id;
						vo.index = i;
						_chapterRewardList.push(vo);
					}
				}
			}
			return _chapterRewardList;
		}
		
		
		private var _showPoint:Point;
		public function get showPoint():Point{
			if(!_showPoint)
			{
				_showPoint = new Point();
				var ar:Array = chapter_coordinate.split(",");
				_showPoint.x = Number(ar[0]);
				_showPoint.y = Number(ar[1]);
			}
			return _showPoint;
		}
		
		protected var _levelList:Array;
		public function get levelList():Array{
			if(!_levelList)
			{
				_levelList = [];
				var ar:Array = GameConfigManager.stage_level_arr;
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