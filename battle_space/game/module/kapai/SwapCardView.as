package game.module.kapai
{
	import MornUI.kapai.SwapCardViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	
	/**
	 * 卡牌大师   兑换卡牌
	 * @author hejainbo
	 * 
	 */
	public class SwapCardView extends SwapCardViewUI
	{
		/**选中的索引*/
		private var _selected_index:int = -1;
		/**卡牌大师   兑换卡牌*/
		public function SwapCardView()
		{
			super();
			
		}
		
		private function init():void {
			dom_list.itemRender = SwapCardItem;
			dom_list.vScrollBarSkin = "";
			dom_list.array = [];
			dom_list.selectEnable = true;
			dom_list.on(Event.CLICK, this, swapHandler);
			this.on(Event.CLICK, this, onClick);
		}
		
		public function update(data:KapaiDataVo):void {
			renderCardList();
			renderPoints(data.card_point);
			
			if (_selected_index == -1) {
				dom_list.selectedIndex = 0;
			}
		}
		
		public function refreshCards(result):void {
			renderPoints(result["card_point"]);
			
			var targetIndex = ToolFunc.findIndex(dom_list.array, function(item) {
				return item["id"] == result["cardId"];
			});
			var data = ToolFunc.copyDataSource(dom_list.array[targetIndex], {"num": result["num"]});
			dom_list.setItem(targetIndex, data);
		}
		
		private function renderPoints(card_point):void {
			var text = GameLanguage.getLangByKey("L_A_87043");
			dom_points.text = text + card_point;
		}
		
		private function renderCardList():void {
			var card_list:Object = ResourceManager.instance.getResByURL("config/card_list.json");
			
			var result:Array = ToolFunc.objectValues(card_list).map(function(item, index){
				var id = item["id"];
				var num = KapaiView.state.cards[id] || 0;
				return {
					"id": id,
					"isSelected": false,
					"num": num
				};
			});
			
			var hasCards:Array = result.filter(function(item) {
				return item["num"] != 0;
			});
			var hasNoCards:Array = result.filter(function(item) {
				return item["num"] == 0;
			});
			
			dom_list.array = hasCards.concat(hasNoCards);
		}
		
		private function onClick(e:Event):void {
			if (selected_card_id == -1) return;
			switch (e.target) {
				//点数兑换卡牌
				case this.dom_compound:
					var card_list:Object = ResourceManager.instance.getResByURL("config/card_list.json");
					var targetData = ToolFunc.getTargetItemData(card_list, "id", selected_card_id);
					if (!targetData["buy_shard"]) return XTip.showTip(GameLanguage.getLangByKey("L_A_87063"));
					var callBack = function(num) {
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_NUM_CARD, [KapaiView.state.id, selected_card_id, num]);
					}
					XFacade.instance.openModule(ModuleName.CardPointView, [selected_card_id, 0, callBack]);
					break;
				
				// 卡牌兑换点数
				case this.dom_resolve:
					var card_list:Object = ResourceManager.instance.getResByURL("config/card_list.json");
					var targetData = ToolFunc.getTargetItemData(card_list, "id", selected_card_id);
					if (!targetData["buy_shard"]) return XTip.showTip(GameLanguage.getLangByKey("L_A_87063"));
					var callBack = function(num) {
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_CARD_NUM, [KapaiView.state.id, selected_card_id, num]);
					}
					XFacade.instance.openModule(ModuleName.CardPointView, [selected_card_id, 1, callBack]);
					break;
			}
		}
		
		private function swapHandler():void {
			var _index:int = dom_list.selectedIndex;
			
			setChildView(_selected_index, false);
			setChildView(_index, true);
			
			_selected_index = _index;
			
//			"buy_shard"
			
			trace(selected_card_id);
		}
		
		private function setChildView(index, bool):void {
			var oldItem = dom_list.getItem(index);
			if (oldItem) {
				oldItem = ToolFunc.copyDataSource(oldItem, {"isSelected": bool});
				dom_list.setItem(index, oldItem);
			};
		}
		
		/**选中的id*/
		private function get selected_card_id():* {
			var _index:int = dom_list.selectedIndex;
			var item_data = dom_list.getItem(_index);
			
			return (item_data && item_data["id"]) || -1;
		}
		
		
		public function reset():void {
			dom_list.off(Event.CLICK, this, swapHandler);
			this.off(Event.CLICK, this, onClick);
			
		}
		
		
		
		

	}
}