/***
 *作者：罗维
 */
package game.global.vo
{
	public class BuildingVo
	{
		public var building_id:String;
		public var name:String = "";
		public var c_name:String;
		public var dec_s:String
		public var rank:uint;
		public var building_type:uint;
		public var initial_building:uint;
		public var upgrade:uint;
		public var destroy:uint;
		public var level_limit:uint;
		public var building_describe:String;
		
		public function BuildingVo()
		{
			super();
		}
	}
}