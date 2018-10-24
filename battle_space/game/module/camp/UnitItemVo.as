package game.module.camp
{
	/**
	 * UnitItemVo 单位数据列表数据格式
	 * author:huhaiming
	 * UnitItemVo.as 2017-5-18 上午11:32:41
	 * version 1.0
	 *
	 */
	public class UnitItemVo
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
		public function UnitItemVo()
		{
		}
	}
}