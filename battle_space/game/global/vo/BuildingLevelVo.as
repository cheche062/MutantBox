/***
 *作者：罗维
 */
package game.global.vo
{
	import laya.maths.Point;

	public class BuildingLevelVo extends ArticleVo
	{
		public var building_upgrade_id:String;
		public var building_id:String;
		public var level:uint;
		public var HQ_level:uint;
		public var character_level:uint;
		public var cost1:String;
		public var cost2:String;
		public var cost_param:uint;
		public var param1:String;
		public var CD:uint;
		public var get_exp:uint;
		public var ornot:uint;
		
		public var buldng_stats:String;
		public var building_skill:String;
		public var buldng_capacty:String;	
		public var buldng_output:String;
		
		
		public var BuildEff:String;
		
		public var LevelEff:String;
		public var MoveEff:String;
		public var DestoryEff:String;
		
		
		
		public function BuildingLevelVo()
		{
		}


	}
}