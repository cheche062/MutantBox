package game.module.kapai
{
	import MornUI.kapai.RankCardViewUI;
	
	import game.common.ToolFunc;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.filters.ColorFilter;
	
	
	/**
	 * 卡牌大师   排行
	 * @author hejainbo
	 * 
	 */
	public class RankCardView extends RankCardViewUI
	{
		/**每页5条数据*/
		private const BASE_PAGE:int = 5;
		/**列表总数据*/
		private var list_total_data:Array = [];
		/**当前页*/
		private var current_page:int = 0;
		/**总页数*/
		private var total_page:int = 0;
		
		
		public function RankCardView()
		{
			super();
			
		}
		
		private function init():void {
			dom_list.itemRender = KapaiRankItem;
			dom_list.array = [];
			
			this.on(Event.CLICK, this, onClick);
		}
		
		// 情况特殊一点，请求数据，   因为每次打开都需要请求后台
		public function update(data:KapaiDataVo):void {
			// 最低上榜分数
			dom_pts.text = ToolFunc.getTargetItemData(data.card_param, "id", "11")["value"];
			
			// 请求排行榜
			WebSocketNetService.instance.sendData(ServiceConst.KAPAI_RANK, [data.id]);
		}
		
		/**刷新排行榜*/
		public function refreshRank(data:KapaiDataVo):void {
			dom_score.text = String(data.myscore);
			
			var card_rank:Array = ToolFunc.objectValues(data.card_rank);
			var limitNum = Number(card_rank[card_rank.length - 1]["up"]);
			
			// 是否上榜
			var isRanking:Boolean = (data.myrank > 0 && data.myrank < limitNum);
			// 是否可领取奖励
			var isAbleReward:Boolean = isRanking && (data.status == 0);
			btn_collect.disabled = !isAbleReward;
			
			var redFilter = makeRedApe(isRanking);
			dom_isRanking.filters = redFilter;
			
			data.list = data.list.slice(0, limitNum);
			// 排序
			var list:Array = data.list.sort(function(a, b) {
				return a["rank"] - b["rank"];
			});
			
			list_total_data = list.map(function(item) {
				var targetData:Object = ToolFunc.getItemDataOfWholeData(item["rank"], data.card_rank, "down", "up");
				return {
					"rank": item["rank"],
					"name": item["user"],
					"score": item["score"],
					"reward": targetData["reward1"]
				};
			});
			
			total_page = Math.ceil(list_total_data.length / BASE_PAGE) || 1;
			current_page = 1;
			updateListData(current_page);
		}
		
		/**赤化*/
		private function makeRedApe(isRanking):* {
			if (isRanking) {
				return null;
			}
			//由 20 个项目（排列成 4 x 5 矩阵）组成的数组，红色
			var redMat =
				[
					1, 0, 0, 0, 0, //R
					0, 0, 0, 0, 0, //G
					0, 0, 0, 0, 0, //B
					0, 0, 0, 1, 0, //A
				];
			
			//创建一个颜色滤镜对象,红色
			var redFilter = new ColorFilter(redMat);
			return [redFilter];
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case btn_left:
					changePageHandler(-1);
					break;
				
				case btn_right:
					changePageHandler(1);
					
					break;
				
				case btn_collect:
					WebSocketNetService.instance.sendData(ServiceConst.KAPAI_RANK_REWARD, [KapaiView.state.id]);
					
					break;
			}
		}
		
		/**换页函数*/
		private function changePageHandler(num:int):void{
			current_page = current_page + num;
			
			if(current_page < 1){
				current_page = 1;
				return;
			}
			if(current_page > total_page){
				current_page = total_page;
				return;
			}
			
			updateListData(current_page);
		}
		
		/**更新数据列表视图*/
		private function updateListData(current_page:int):void{
			// 截取数据
			var startPage = (current_page - 1) * BASE_PAGE;
			var result = list_total_data.slice(startPage, startPage + BASE_PAGE);
			
			dom_page.text = current_page + '/' + total_page;
			dom_list.array = result;
		}
		
		public function reset():void {
			this.off(Event.CLICK, this, onClick);
		}
	}
}