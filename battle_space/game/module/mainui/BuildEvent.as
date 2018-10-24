package game.module.mainui
{
	/**
	 * BuildEvent 建筑相关事件常量
	 * author:huhaiming
	 * BuildEvent.as 2017-3-7 下午3:06:56
	 * version 1.0
	 *
	 */
	public class BuildEvent
	{
		/**事件-建筑*/
		public static const BUILD_START:String = "b_start"
		/**事件-确认建筑*/
		public static const BUILD_DONE:String = "b_done";
		/**事件-取消建筑*/
		public static const BUILD_CANCEL:String = "b_cancel";
		/**事件-建筑状态，是否可以建筑*/
		public static const BUILD_RESULT:String = "b_result";
		/**事件-缩放*/
		public static const BUILD_SCALE:String = "b_scale";
		/**事件-加速*/
		public static const BUILD_SPEED:String = "b_speed"
		/**事件-取消当前建筑/升级操作*/
		public static const BUILD_RUIN:String = "b_ruin";
		/**事件-进入建筑面板*/
		public static const BUILD_ENTER:String = "b_enter"
		/***/
		public function BuildEvent()
		{
		}
	}
}