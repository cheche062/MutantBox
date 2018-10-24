package game.module.kapai
{
	import game.common.ToolFunc;

	public class KapaiDataVo
	{
		/**
		 * 卡牌大师数据
		 * 
		 */
		/**活动id*/
		public var id:int;
		/**活动结束时间*/
		public var end_date_time:int;
		/**奖励兑换列表*/
		public var card_exchange:Object = null;
		/**卡牌 参数*/
		public var card_param:Object = null;
		/**卡牌 排行*/
		public var card_rank:Object = null;
		
		/**卡牌点数*/
		public var card_point:int = 0;
		/**我的卡牌*/
		public var cards:Object = null;
		/**我的分数   · 排名用*/
		public var score:int = 0;
		
		/**每日 兑换 领取记录*/
		public var day_reward_log:Object;
		/**活动期间内的领取记录*/
		public var reward_log:Object;
		/**合并  领取的记录*/
		public var reward_log_total:Object;
		/**免费抽取次数*/
		public var free_draw_num:int = 0;
		
		/**排行榜*/
		public var list:Array;
		/**我的名次*/
		public var myrank:int = 0;
		/**我的得分*/
		public var myscore:int = 0;
		/**是否领取过排行榜奖励*/
		public var status:int = 0;
		
		
		public function KapaiDataVo()
		{
			
		}
		
		/**初始化数据*/ 
		public function init(data:Object):void {
			extendData(data);
			extendData(data["config"]);
			extendData(data["user_status"]);
			reward_log_total = ToolFunc.copyDataSourceList(day_reward_log, reward_log); 
			extendData(data["basic"]);
		}
		
		private function extendData(data:Object):void {
			for (var key in data) {
				if (this.hasOwnProperty(key)) {
					this[key] = data[key];
				}
			}
		}
		
		/**抽卡   更新数据*/
		public function drawCard(data:Object):void {
			//  绿色档  且 单抽
			if (data.type == 1 && data.num == 1) {
				free_draw_num =  (free_draw_num - 1 < 0) ? 0 : free_draw_num - 1;
			}
			// 合并卡牌
			for (var key in data.cards) {
				if (key in cards) {
					cards[key] = Number(cards[key]) +  Number(data.cards[key]);
				} else {
					cards[key] = data.cards[key];
				}
			}
			score = Number(score)+ Number(data.score);
		}
		
		/**卡牌兑换点数*/
		public function cardToPoint(data:Object):void {
			card_point = data["card_point"];
			cards[data["cardId"]] = data["num"];
		}
		
		/**点数兑换卡牌*/
		public function pointToCard(data:Object):void {
			card_point = data["card_point"];
			cards[data["cardId"]] = data["num"];
		}
		
		/**兑换奖励数据更新*/
		public function rewardUpdate(data:Object):void {
			// 更新卡牌数
			for (var key in data["cards_update"]) {
				cards[key] = data["cards_update"][key];
			}
			extendData(data["user_status"]);
			reward_log_total = ToolFunc.copyDataSourceList(day_reward_log, reward_log);
		}
		
		/**排行榜   数据更新*/
		public function rankUpdate(data:Object):void {
			extendData(data);
			score = data["myscore"];
		}
		
		/**排行榜   领取奖励*/
		public function getRankReward(data:Object):void {
			status = 1;
		}
		
		
		
		
	}
}