/***
 *作者：罗维
 */
package game.global.vo
{
	import game.module.bag.mgr.ItemManager;
	
	import laya.maths.Point;

	public class GeneLevelVo
	{
		public var id:Number;
		public var name:String;
		public var type:Number;
		public var level_down:Number;
		public var level_up:Number;
		public var zxjl:String;
		public var rq_text1:String;
		public var rq_icon:String;
//		public var icon:String;
//		public var cost:String;
//		public var exp:Number;
//		public var battle_group:String;
//		public var aid_group:String;
//		public var show_reward:String;
//		public var character_level:Number;
//		public var stage_coordinate:String;
		
		public function GeneLevelVo()
		{
		}

		
		
		private var _showReward:Array;
		
		
		public function get showReward():Array
		{
			if(!_showReward)
			{
				_showReward = ItemManager.StringToReward(zxjl);
			}
			return _showReward;
		}
		
		private var _rqIcons:Array;
		public function get rqIcons():Array
		{
			if(!_rqIcons)
			{
				_rqIcons = rq_icon.split("|");
			}
			return _rqIcons;
		}


	}
}