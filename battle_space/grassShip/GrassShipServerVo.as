package game.module.grassShip
{
	/**
	 * 草船借箭服务端数据 
	 * @author mutantbox
	 * 
	 */
	public class GrassShipServerVo
	{
		public var refresh_time;
		
		/**历史最高积分*/
		public var history_max_point;
		/**历史领取记录*/
		public var history_get_log;
		
		/**当日商店道具购买记录  ID=>购买次数*/
		public var day_shop_buy_log;
		/**当日领取记录*/
		public var day_get_log;
		/**当日累计积分*/
		public var day_total_point;
		/**本次积分*/
		public var day_point;
		
		
		/**购买次数*/
		public var day_buy_number;
		/**剩余战斗次数*/
		public var day_combat_number;
		
		public function GrassShipServerVo()
		{
		}
	}
}