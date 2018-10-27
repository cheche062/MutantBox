package game.global.vo.teamCopy
{
	public class TeamFightUnitVo
	{
		/**单位ID*/
		public var id:*;
		/**showNumber 是否显示数字*/
		public var sn:Boolean = false;
		/**showUp 是否显示升级效果*/
		public var su:Boolean = false;
		/**showEdit是否显示编辑效果*/
		public var se:Boolean = false;
		/**hideState显示状态*/
		public var hs:Boolean = false;
		/**显示数量*/
		public var num:int = 0;
		
		/**是否无法使用的类型*/
		public var conform:Boolean = false;
		public var herouse:int=0;
		public var baseInfo:Object;
		
		public function TeamFightUnitVo()
		{
		}
	}
}