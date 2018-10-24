package game.module.kapai
{
	import MornUI.kapai.DrawCardViewUI;
	
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	
	/**
	 * 卡牌大师   抽卡抽奖
	 * @author hejainbo
	 * 
	 */
	public class DrawCardView extends DrawCardViewUI
	{
		/**抽卡类型  1绿   2蓝  3紫*/
		private var _card_type:int = 0;
		private const LIGHT_POS_X:Array = [174, 336, 497];
		
		/**卡牌大师   抽卡抽奖*/
		public function DrawCardView()
		{
			super();
		}
		
		public function init():void {
			
			this.on(Event.CLICK, this, onClick);
		}
		
		public function update(data:KapaiDataVo):void {
			
			this.dom_score.text = String(data.score);
			
			card_type = card_type || 1;
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				// 买一次
				case this.btn_one:
					// 绿色卡  且有免费次数
					if (card_type == 1 && Number(KapaiView.state.free_draw_num) > 0) {
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_DRAW_CARD, [KapaiView.state.id, card_type, 1]);//发消息
					 
					} else {
						var costArr:Array = getDrawCardCost(card_type);	
						var text = GameLanguage.getLangByKey("L_A_87055");
						XFacade.instance.openModule("ItemAlertView", [text, 1, costArr[0], function(){
							WebSocketNetService.instance.sendData(ServiceConst.KAPAI_DRAW_CARD, [KapaiView.state.id, card_type, 1]);//发消息
						}]);
					}
					
					break;
				
				case this.btn_ten:
					var costArr:Array = getDrawCardCost(card_type);					
					var text = GameLanguage.getLangByKey("L_A_87055");
					XFacade.instance.openModule("ItemAlertView", [text, 1, costArr[1], function(){
						WebSocketNetService.instance.sendData(ServiceConst.KAPAI_DRAW_CARD, [KapaiView.state.id, card_type, 10]);//发消息
					}]);
					break;
				
				case this.dom_green:
					card_type = 1;
					break;
				case this.dom_blue:
					card_type = 2;
					break;
				case this.dom_purple:
					card_type = 3;
					break;
			}
		}
		
		private function get card_type():int {
			return _card_type;
		}
		
		private function set card_type(value:int):void {
			_card_type = value;
			this.dom_light.x = LIGHT_POS_X[_card_type - 1];
			
			// 绿色档位
			if (_card_type == 1) {
				var free_draw_num = KapaiView.state.free_draw_num;
				dom_attempts.text = free_draw_num;
				dom_viewStack.selectedIndex = free_draw_num == 0 ? 1 : 0;
			} else {
				dom_viewStack.selectedIndex = 1;
			}
			
			var costArr:Array = getDrawCardCost(_card_type);
			dom_one_cost.text = String(costArr[0]);
			dom_ten_old.text = String(costArr[0] * 10);
			dom_ten_new.text = String(costArr[1]);
			
		}
		
		/**抽卡的花费 [20, 200] 抽1次花费   抽10次花费*/
		private function getDrawCardCost(type:int):Array {
			var card_param = KapaiView.state.card_param;
			var id1 = "";
			var id2 = "";
			switch (type) {
				case 1:
					id1 = 2;
					id2 = 5;
					break;
				case 2:
					id1 = 3;
					id2 = 6;
					break;
				case 3:
					id1 = 4;
					id2 = 7;
					break;
			}
			
			return [
				ToolFunc.getTargetItemData(card_param, "id", id1)["value"].split("=")[1],
				ToolFunc.getTargetItemData(card_param, "id", id2)["value"].split("=")[1]
			];
		}
		
		
		public function reset():void {
			this.off(Event.CLICK, this, onClick);
		}
		
	}
}