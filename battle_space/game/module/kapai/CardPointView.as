package game.module.kapai
{
	import MornUI.kapai.CardPointViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	/**
	 * 卡牌大师   点数和卡牌的兑换框 
	 * @author hejianbo
	 * 
	 */
	public class CardPointView extends BaseDialog
	{
		/**卡牌张数*/
		private var _card_num:int = 0;
		/**卡牌id*/
		private var cardId:int = 0;
		/**功能类型  0:兑换成卡牌     1：兑换成点数*/
		private var effectType:int = 0;
		/**确认后的回调*/
		private var callBack:Function;
		
		public function CardPointView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			var result:Array = args[0];
			
			cardId = result[0];
			effectType = result[1];
			callBack = result[2];
			
			view.dom_img.skin = "appRes/card/" + cardId + ".png";
			view.dom_title_text.text = effectType == 0 ? "L_A_87062" : "L_A_87044";
			view.dom_sure.label = effectType == 0 ? "L_A_87038" : "L_A_87039";
			view.dom_myPoint.text = KapaiView.state.card_point;
			
			card_num = 1;
		}
		
		override public function createUI():void{
			this.addChild(view);
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					close();
					
					break;
				
				// 确定
				case view.dom_sure:
					callBack && callBack(card_num);
					close();
					
					break;
				
				case view.dom_add:
					// 分解的话不能超过已有的数量
					card_num = card_num + 1;
					
					break;
				
				case view.dom_sub:
					card_num = Math.max(1, card_num - 1);
					
					break;
				
			}
		}
		
		private function get card_num():int {
			return _card_num;
		}
		
		private function set card_num(value:int):void{
			_card_num = value;
			
			view.dom_num.text = String(_card_num);
			
			var card_list:Object = ResourceManager.instance.getResByURL("config/card_list.json");
			var targetData:Object = ToolFunc.getTargetItemData(card_list, "id", cardId);
			
			// 组成需要的点数
			var buyNum = targetData["buy_shard"].split("=")[1];
			//分解获得的点数
			var sellNum = targetData["sell_point"].split("=")[1];
			// 组成牌
			if (effectType == 0) {
				var totalNum = Number(buyNum) * _card_num;
				
				view.dom_require.text = totalNum;
				view.dom_sure.disabled = !(Number(KapaiView.state.card_point) >= totalNum);
				
			// 分解成点数
			} else {
				view.dom_require.text = Number(sellNum) * _card_num;
				view.dom_sure.disabled = !(Number(KapaiView.state.cards[cardId] || 0) >= _card_num);
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
			
			callBack = null;
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():CardPointViewUI{
			_view = _view || new CardPointViewUI();
			return _view;
		}
		
	}
}