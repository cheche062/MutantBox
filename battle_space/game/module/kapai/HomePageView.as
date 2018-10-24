package game.module.kapai
{
	import MornUI.kapai.HomePageViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.util.TimeUtil;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	
	/**
	 * 卡牌大师   首页
	 * @author hejainbo
	 * 
	 */
	public class HomePageView extends HomePageViewUI
	{
		/**选中的索引*/
		private var _selected_index:int = -1;
		/**清除定时器*/
		private var clearTimerHandler:Function = null;
		
		
		/**卡牌大师   首页*/
		public function HomePageView()
		{
			super();
		}
		
		public function init():void {
			dom_tabList.itemRender = AwardItem;
			dom_tabList.vScrollBarSkin = "";
			dom_tabList.array = [];
			dom_tabList.selectEnable = true;
			dom_tabList.selectHandler = Handler.create(this, tabHandler, null, false);
			
			dom_contentList.itemRender = HomePageCardItem;
			dom_contentList.array = [];
			dom_contentList.selectEnable = true;
			// 待添加兑换牌的事件
			dom_contentList.on(Event.CLICK, this, swapHandler);
			btn_exchange.on(Event.CLICK, this, exchangeHandler);
				
		}
		
		public function update(data:KapaiDataVo):void {
			dom_points.text = String(data.card_point);
			remainTime(data.end_date_time);
			
			renderTabList(data.card_exchange);
			
			// 由于每次进来  tab list都会被更新，且selectedIndex不变，所以造成没有选中状态
			dom_tabList.selectedIndex = -1;
			dom_tabList.selectedIndex = _selected_index == -1 ? 0 : _selected_index;
		}
		
		/**兑换按钮*/
		private function exchangeHandler():void {
			var _data = dom_tabList.getItem(dom_tabList.selectedIndex);
			
			WebSocketNetService.instance.sendData(ServiceConst.KAPAI_CARD_REWARD, [KapaiView.state.id, _data["id"]]);//发消息
		}
		
		/**分解*/
		private function swapHandler(e:Event):void {
			var _index:int = this.dom_contentList.selectedIndex;
			var _itemData:Object = this.dom_contentList.getItem(_index);
			
			if (e.target.name == 'dom_swap') {
				// 1: 分解     0：合成
				var type = _itemData["user_num"] > _itemData["num"] ? 1 : 0;
				var callBack = function(num) {
					//分解
					if (type == 1) {
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_CARD_NUM, [KapaiView.state.id, _itemData.id, num]);
					} else {
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_NUM_CARD, [KapaiView.state.id, _itemData.id, num]);				
					}
				}
				XFacade.instance.openModule(ModuleName.CardPointView, [_itemData.id, type, callBack]);
			}
		}
		
		private function tabHandler(index:int):void {
			if (index == -1) return;
			var _id = 0;
			// 更新左侧tab的选中与否
			dom_tabList.array.forEach(function(item, i) {
				if (index == i) _id = item["id"];
				var new_isSelected = index == i;
				if (item["isSelected"] !== new_isSelected) {
					item["isSelected"] = new_isSelected;
					dom_tabList.setItem(i, item);
				}
			});
			// 当前奖励的数据
			var dataSource:Object = dom_tabList.getItem(index);
			var remain_times = dataSource["remain_times"];
			// 今日剩余兑换次数
			dom_remain.text = remain_times;
			renderReward(dataSource["reward"]);
			// 是否可兑换  && 今日兑换次数
			btn_exchange.disabled = !dataSource["isRedShow"];
			
			var cardsList:Array = getCardsList(_id);
			renderContentList(cardsList);
			
			_selected_index = index;
		}
		
		/**渲染中间的奖励图标*/
		private function renderReward(reward:String):void {
			dom_reward.removeChildren();
			ToolFunc.rewardsDataHandler(reward, function(id, num){
				var child:ItemContainer = new ItemContainer();
				child.setData(id, num);
				dom_reward.addChild(child);
			});
		}
		
		/**渲染 右侧需求卡牌*/
		private function renderContentList(list:Array):void {
			var card_list = ResourceManager.instance.getResByURL("config/card_list.json");
			// 可兑换的id 列表
			var swapAbledIdList:Array = ToolFunc.objectValues(card_list)
			.filter(function(item:Object){
				return !!item["buy_shard"];
			}).map(function(item){
				return item["id"];
			});
			
			var result:Array = list.map(function(item:Array, index) {
				var user_num = KapaiView.state.cards[item[0]] || 0 // 该牌玩家拥有数量
				var isSwapShow = (swapAbledIdList.indexOf(item[0]) > -1) ? (user_num != item[1]) : false;
				return {
					"id":item[0], //牌id
					"user_num": Number(user_num),
					"num": Number(item[1]), //需要的数量
					"isSwapShow": isSwapShow
				};
			});
			
			this.dom_contentList.array = result; 
		}
		
		/**当前奖励是否可领取*/
		private function isGainAble(id:int):Boolean {
			var cardList:Array = getCardsList(id);
			return cardList.every(function(item:Array) {
				var user_num = KapaiView.state.cards[item[0]] || 0; 
				return user_num >= item[1];
			});
		}
		
		/**通过id来获得需要的卡牌列表   [[id, num, times]...]*/
		private function getCardsList(id:int):Array {
			// 找出该项奖励的具体数据
			var targetObj:Object = ToolFunc.getTargetItemData(KapaiView.state.card_exchange, "id", id);
			// 找出键含有card的所有键值对
			var cardsObj = ToolFunc.filterObj(targetObj, function(value:*, key:String){
				return key.indexOf('card') > -1;
			});
			var cardsList:Array = ToolFunc.objectValues(cardsObj);
			cardsList = cardsList.sort(function(a:String, b:String){
				return a.split("=")[0] - b.split("=")[0];
			});
			cardsList = cardsList.map(function(item){
				var info:Array = item.split('=');
				return [info[0], Number(info[1])];
			});
			return cardsList;
		}

		/**左侧tab渲染*/
		private function renderTabList(data:Object):void {
			var result:Array = ToolFunc.objectValues(data);
			result = result.map(function(item, index){
				var id = item["id"];
				var remain_times = Number(item["num"]) - (KapaiView.state.reward_log_total[id] || 0);
				return {
					"id": id,
					"reward": item["reward"],
					"isSelected": index == _selected_index,
					"isRedShow": isGainAble(item["id"]) && remain_times > 0,
					"remain_times": remain_times
				};
			});
			
			this.dom_tabList.array = result;
		}
		
		/**活动剩余时间*/
		private function remainTime(time):void{
			var diff = Math.floor(time - Math.floor(TimeUtil.now / 1000));
			var _this:HomePageView = this;
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
			
			if (diff > 0) {
				clearTimerHandler = ToolFunc.limitHandler(diff, function(time) {
					var result = TimeUtil.toDetailTime(time);
					_this.dom_time.text = TimeUtil.timeToText(result);
				}, function(time) {
					var result = TimeUtil.toDetailTime(time);
					_this.dom_time.text = TimeUtil.timeToText(result);
					clearTimerHandler = null;
					trace('倒计时结束：：：');
				});
			} else {
				_this.dom_time.text = "00:00:00";
			}
		}
		
		public function reset():void {
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
			if (this.dom_tabList.selectHandler) {
				this.dom_tabList.selectHandler.clear();
				this.dom_tabList.selectHandler = null;
			}
			
			dom_contentList.off(Event.CLICK, this, swapHandler);
			btn_exchange.off(Event.CLICK, this, exchangeHandler);
		}
		
	}
}