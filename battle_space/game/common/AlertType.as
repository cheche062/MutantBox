package game.common
{
	public class AlertType
	{
		public static const YES			:uint = 1;
		public static const NO			:uint = 2;
		public static const SURE			:uint = 4;
		public static const CANCEL		:uint = 8;
		public static const CLOSE			:uint = 16;
		public static const RETURN_YES	:uint = 1;
		public static const RETURN_NO		:uint = 2;
		public static const RETURN_NONE	:uint = 3;
		
		public static const BASEALERTVIEW	:String = "BaseAlertView";
		public static const BAGSELLALERT:String = "BagSellAlert";
		
		
//		public static const EnduranceOutTipView:String = "EnduranceOutTipView";
//		public static const GUILDQUITVIEW:String = "GuildQuitView";
		
		public function AlertType()
		{
		}
	}
}