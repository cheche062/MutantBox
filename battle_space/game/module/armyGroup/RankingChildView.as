package game.module.armyGroup
{
	import MornUI.armyGroup.RankingChildViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.armyGroup.newArmyGroup.ArmyRankItem;
	import game.module.armyGroup.newArmyGroup.RewardsItem;
	import game.module.tips.AGCommTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;

	/**
	 * 今日，昨日，总排行榜
	 * @author douchaoyang
	 *
	 */
	public class RankingChildView extends BaseView
	{
		/**今日榜 昨日榜 总榜 */ 
		private var typeArr = [2, 4, 3];
		/**当前页数*/
		private var currentPageNum:int;
		/**有排行的总人数*/
		private var rankMaxNum:int;
		
		public function RankingChildView()
		{
			super();
		}

		override public function show(... args):void
		{
			super.show();
		}

		override public function close():void
		{

		}

		override public function createUI():void
		{
			_view=new RankingChildViewUI();
			this.addChild(_view);
			
			view.dom_list.itemRender = ArmyRankItem;
			view.dom_list.array = null;
			
			addEvent();
		}

		private function addToStageEvent():void
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_RANK), this, onResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_TOTAL_REWARD), this, onResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_YSRANK_REWARD), this, onResultHandler);
			// 为了小红点
			sendData(ServiceConst.ARMY_GROUP_GET_RANK, [4, 1]);
			sendData(ServiceConst.ARMY_GROUP_GET_RANK, [3, 1]);
			
			view.tabCtrl.selectedIndex = -1;
			view.tabCtrl.selectedIndex = 0;
		}

		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_RANK), this, onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_TOTAL_REWARD), this, onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_YSRANK_REWARD), this, onResultHandler);
		}
		
		private function selectHandler(index:int):void {
			if (index == -1) return;
			
			view.dom_viewstack.selectedIndex = index;
			
			currentPageNum = 1;
			sendRankRequest()
		}
		
		private function initRankingData(data:Array = []):void {
			var rank_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_rank.json");
			rank_data = ToolFunc.objectValues(rank_data);
			rank_data = rank_data.slice((currentPageNum - 1) * 5, (currentPageNum - 1) * 5 + 5);
			
			renderList(rank_data, data);
			
		}
		
		/**初始化总榜数据*/
		private function initTotalRankingData(data:Array = []):void {
			var season_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_season_award.json");
			var ranks:Array = [];
			for (var i = 1; i <= 5; i++) {
				ranks.push((currentPageNum - 1) * 5 + i);
			}
			ranks = ranks.map(function(item) {
				var targetData = ToolFunc.getItemDataOfWholeData(item, season_data, "up", "down");
				return {
					"PM": item,
					"JL": targetData["award"]
				}
			}).filter(function(item) {
				return !!item["JL"];
			});
				
			renderList(ranks, data);
		}
		
		private function renderList(tableData, serverData = []):void {
			var result:Array = tableData.map(function(item, index) {
				var userItem = serverData[index];
				return {
					rank: userItem? userItem["rank"] : item["PM"],
					nickname: userItem ? userItem["nickname"] : "-",
					guildname: userItem ? userItem["guildname"] : "-",
					killnum: userItem ? userItem["killnum"] : "-",
					rewards: item["JL"]
				} 
			});
			
			view.dom_list.array = result;
			renderPageComponent()
		}
		
		private function renderPageComponent():void {
			var max = getTotalPageNum();
			view.dom_pageText.text = currentPageNum + "/" + max;
			view.pagePrevBtn.disabled = currentPageNum == 1;
			view.pageNextBtn.disabled = currentPageNum == max;
		}
		
		/**获取最大页数*/
		private function getTotalPageNum():int {
			// 总榜
			if (view.tabCtrl.selectedIndex == 2) {
				var season_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_season_award.json");
				season_data = ToolFunc.objectValues(season_data);
				return Math.ceil(Number(season_data[season_data.length - 2]["down"]) / 5);
				
			} else {
				var rank_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_rank.json");
				return Math.ceil(ToolFunc.objectValues(rank_data).length / 5);
			}
		}
		
		private function sendRankRequest():void {
			var _i = view.tabCtrl.selectedIndex; 
			view.mouseEnabled = false;
			sendData(ServiceConst.ARMY_GROUP_GET_RANK, [typeArr[_i], currentPageNum]);
		}
		
		private function changePage():void {
			if (view.tabCtrl.selectedIndex == 2) {
				initTotalRankingData();
			} else {
				initRankingData();
			}
		}
		
		private function onclickHandler(e:Event):void
		{
			switch (e.target)
			{
				// 如果是点击的上一页
				case view.pagePrevBtn:
					// 上一页的第一个都比最大还要大
					if ((currentPageNum - 1) * 5 - 4 > rankMaxNum) {
						currentPageNum -= 1;
						changePage();
					} else {
						currentPageNum -= 1;
						sendRankRequest();
					}
					
					break;
				// 如果点击的下一页
				case view.pageNextBtn:
					// 当前展示人数还未达到最大
					if (currentPageNum * 5 < rankMaxNum) {
						currentPageNum += 1;
						sendRankRequest();
					} else {
						currentPageNum += 1;
						changePage();
					}
					
					break;
				// 如果点击的是 claim按钮
				case view.claimBtn:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_YSRANK_REWARD);
					break;
				
				case view.btn_get_total:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_TOTAL_REWARD);
					break;
				
				case view.infoBtn1:
				case view.btn_info_total:
					var data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_20975").replace("{0}", data["29"].value), AGCommTip);
					break;
				
				
				default:
					break;
			}
		}
		
		private function createRewards(rewards:String):Array {
			if (!rewards) return [];
			return rewards.split(";").map(function(item) {
				var data = item.split("=");
				var child:RewardsItem = new RewardsItem();
				child.dataSource = {id: data[0], num: "x" + XUtils.formatResWith(data[1])};
				return child;
			})
		}
		
		/**通过表格获取今日 昨日奖励*/
		private function getRankRewards(rank):String {
			var rank_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_rank.json");
			return rank_data[rank] ? rank_data[rank]["JL"] : "";
		}
		
		/**通过表格获取奖励*/
		private function getTotalRewards(rank):String {
			var rank_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_season_award.json");
			var targetData = ToolFunc.getItemDataOfWholeData(rank, rank_data, "up", "down");
			return targetData ? targetData["award"] : "";
		}
		
		private function renderRewardsBox(box:Box, rewards:String):void {
			box.destroyChildren();
			if (rewards != "L_A_20913") {
				var fn = box == view.dom_total_box? getTotalRewards : getRankRewards;
				var childs:Array = createRewards(fn.call(this, rewards));
				childs.forEach(function(item){
					box.addChild(item);
				});
			}
		}
		
		// 请求数据之后的处理函数
		private function onResultHandler(cmd:int, ... args):void
		{
			trace("国战排行榜",args);
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_RANK:
					view.mouseEnabled = true;
					// 今日
					var rankType = args[3];
					var listData = args[0][1];
					
					rankMaxNum = Number(args[0][0]);
						
					if (rankType == 2) {
						initRankingData(listData);
						
						view.tdOwnRank.text = args[1].rank;
						view.tdOwnName.text = args[1].nickname;
						view.tdOwnGroup.text = args[1].guildname;
						view.tdOwnKill.text = args[1].killnum;
						
						renderRewardsBox(view.dom_today_box, args[1].rank);
						
					// 昨日
					} else if (rankType == 4) {
						initRankingData(listData);
						
						view.yestdayRankingNum.text = args[1].rank;
						view.yestdayKillsNum.text = args[1].killnum;
						
						view.redDot.visible = !!args[2];
						view.claimBtn.disabled = args[2] == 0;
						renderRewardsBox(view.dom_yestoday_box, args[1].rank);
						
						//总榜
					} else if (rankType == 3) {
						initTotalRankingData(listData);
						
						view.dom_rank.text = args[1].rank;
						view.dom_kill.text = args[1].killnum;
						
						view.redDot2.visible = !!args[4];
						view.btn_get_total.disabled = args[4] == 0;
						renderRewardsBox(view.dom_total_box, args[1].rank);
					}
					
					
					break;
				
				case ServiceConst.ARMY_GROUP_GET_YSRANK_REWARD:
					ToolFunc.showRewardsHandler(args[0]);
					view.claimBtn.disabled = true;
					break;
				
				case ServiceConst.ARMY_GROUP_GET_TOTAL_REWARD:
					ToolFunc.showRewardsHandler(args[0]);
					
					view.btn_get_total.disabled = true;
					break;
				
				
				default:
					break;
			}
		}


		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
			view.tabCtrl.selectHandler = new Handler(this, selectHandler);
			
			// 点击逻辑
			view.on(Event.CLICK, this, onclickHandler);
		}

		override public function removeEvent():void
		{
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			view.off(Event.CLICK, this, onclickHandler);
			view.tabCtrl.selectHandler.clear();
		}

		private function get view():RankingChildViewUI
		{
			return _view as RankingChildViewUI;
		}
	}
}
