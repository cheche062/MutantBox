package game.module.fighting.sData
{
	import game.global.GameConfigManager;
	import game.global.vo.StageChapterRewardVo;
	import game.global.vo.StageChapterVo;

	//章节数据
	public class stageChapetrData
	{
		public var isInit:Boolean = false;
		public var id:Number = 0;
		public var type:Number = 1;  // 1主线  2精英
		private var _integral:Number = 0 ;  //积分
		private var _rewardState:Array = [];  //领奖状态
		private var _rewardGetState:Array; //可领奖状态
		public var levelList:Array = [];
		
		public var dayTimer:Number = 0; //数据获取日期，跨天算过期
		
		
		public function stageChapetrData()
		{
			
		}
		

		public function get rewardGetState():Array
		{
			if(!_rewardGetState)
			{
				_rewardGetState = [];
				var dic:Object = type == 1 ? GameConfigManager.stage_chapter_dic : GameConfigManager.stage_chapter_jy_dic;
				
				var vo:StageChapterVo = dic[id];
				var ar:Array = vo.chapterRewardList;
				for (var i:int = 0; i < ar.length; i++) 
				{
					_rewardGetState.push(0);
				}
			}
			
			return _rewardGetState;
		}

		public function set rewardState(value:Array):void
		{
			for (var i:int = 0; i < value.length; i++) 
			{
				var v:Number = Number(value);
				if(_rewardState.length <= i)
				{
					_rewardState.push(0);
				}
				_rewardState[i] = v;
			}
			_rewardState = value;
			analysisData();
		}

		public function get integral():Number
		{
			return _integral;
		}

		public function set integral(value:Number):void
		{
			_integral = value;
			analysisData();
		}

		public function get isThrough():Boolean{
			for (var i:int = 0; i < levelList.length; i++) 
			{
				var cdata:stageLevelData = levelList[i];
				if(!cdata.star)
					return false;
			}
			return true;
		}
		
		private function analysisData():void
		{
			rewardGetState;
			var dic:Object = type == 1 ? GameConfigManager.stage_chapter_dic : GameConfigManager.stage_chapter_jy_dic;
			
			var vo:StageChapterVo = dic[id];
			var ar:Array = vo.chapterRewardList;
			for (var i:int = 0; i < ar.length; i++) 
			{
				var svo:StageChapterRewardVo = ar[i];
				if(svo.point_condition > _integral)
				{
					rewardGetState[i] = 0;
				}
				else{
					if(_rewardState.length > i)
					{
						rewardGetState[i] = _rewardState[i] + 1;
					}else
					{
						rewardGetState[i] = 0;
					}
				}
			}
			
		}
		
		
	}
}