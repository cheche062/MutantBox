/***
 *作者：罗维
 */
package game.global.vo
{
	import game.global.GameLanguage;
	import game.global.data.bag.ItemData;
	import game.module.bag.mgr.ItemManager;
	
	import laya.maths.Point;

	public class StageLevelVo
	{
		public var id:Number = 0;
		public var chapter_id:Number = 0;
		public var stage_name:String;
		public var stage_name_a:String;
		
		public var stage_icon:String;
		
		public var stage_coordinate:String;
		
		public var random_reward:String;  //扫荡奖励 	
		public var stage_cost:String; //扫荡消耗
		public var challenge_times:Number = 0;  //总次数
		
		private var _stageReward:Array;  
		private var _stageReward2:Array;
		private var _randomReward:Array;
		
		private var _requirementList:Array;
		private var _stageCost:Array;
		
		
		private var maxRequirement:Number = 3;
		public function StageLevelVo()
		{
			for (var i:int = 1; i <= maxRequirement; i++) 
			{
				this["rq"+i] = null;  //条件
				this["rq_text"+i] = null;  //条件描述
				this["text_canshu"+i] = null;  //描述参数
				this["points"+i] = 0;  //积分
				this["reward"+i] = null;  //奖励
				this["show_reward"+i] = null;  //扫荡奖励
			}
			
		}
		private var _cPoint:Point;

		public function get requirementList():Array
		{
			if(!_requirementList)
			{
				_requirementList = [];
				
				for (var i:int = 1; i <= maxRequirement; i++) 
				{
					if(this["rq"+i])
					{
						var vo:requirementVo = new requirementVo();
						vo.rq = this["rq"+i];
						vo.rq_text = this["rq_text"+i];
						vo.text_canshu = this["text_canshu"+i];
						vo.points = this["points"+i];
						vo.reward = this["reward"+i];
						vo.show_reward = this["show_reward"+i];
						_requirementList.push(vo);
					}
				}
			}
			return _requirementList;
		}
		
		public function get stageCost():Array
		{
			if(!_stageCost)
			{
				_stageCost = ItemManager.StringToReward(stage_cost);
			}
			return _stageCost;
		}
		
//		public function getStar(obj:Object):Number{
//			var n:Number = 0;
//			for (var i:int = 0; i < requirementList.length; i++) 
//			{
//				var vo:requirementVo = requirementList[i];
//				var key:String = "condition"+(i+1);
//				if(Number(obj[key]) == 1)
//				{
//					n += vo.points;
//				}
//			}
//			return n;
//		}
		
		
		public function get maxStar():Array{
			var n:Number = 0;
			for (var i:int = 0; i < requirementList.length; i++) 
			{
				var vo:requirementVo = requirementList[i];
				n += vo.points;
			}
			return n;
			
		}

		public function get cPoint():Point
		{
			if(!_cPoint)
			{
				_cPoint = new Point();
				var ar:Array = stage_coordinate.split(",");
				_cPoint.x = Number(ar[0]);
				_cPoint.y = Number(ar[1]);
			}
			return _cPoint;
		}

		public function get randomReward():Array
		{
			if(!_randomReward)
			{
				_randomReward = ItemManager.StringToReward(random_reward);
			}
			return _randomReward;
		}

		
		
	}
}