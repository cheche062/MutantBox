package game.module.kapai
{
	import MornUI.kapai.CardShowViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	
	import laya.display.Animation;
	import laya.display.Node;
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 抽卡结果展示 
	 * @author mutantbox
	 * 
	 */
	public class CardShowView extends BaseDialog
	{
		/**十张卡牌的坐标*/
		private var tenCardsPosList:Array = [];
		/**中心点坐标*/
		private var initPos:Object = {x: 512, y: 250};
		/**目标点坐标*/
		private var targetPos:Object = {x: 910, y: 250};
		/**卡牌 元素*/
		private var cardsList:Array = [];
		
		
		
		public function CardShowView()
		{
			super();
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			for (var i = 0; i < view.dom_box.numChildren; i++) {
				var child:Node = view.dom_box.getChildAt(i);
				tenCardsPosList.push([child.x, child.y]);
			}
		}
		
		override public function show(... args):void
		{
			super.show();
//			window.cardShow = this;
			var result = args[0][0];
			
			var cards:Array = [];
			for (var id in result) {
				for (var i = 0; i < result[id]; i++) {
					cards.push(id);
				}
			}
			
			view.btn_confirm.visible = true;
			renderCards(cards);
			
			view.btn_confirm.on(Event.CLICK, this, confirmHandler);
		}
		
		private function renderCards(cards:Array):void {
			view.dom_box.destroyChildren();
			cardsList.length = 0;
			
			if (cards.length == 1) {
				var card:Card = new Card(cards[0]);
				card.pos(initPos.x, initPos.y);
				view.dom_box.addChild(card);
				cardsList.push(card);
				
			} else {
				cards.forEach(function(item, index) {
					var card:Card = new Card(item);
					card.pos(tenCardsPosList[index][0], tenCardsPosList[index][1]);
					view.dom_box.addChild(card);
					cardsList.push(card);
				});
			}
		}
		
		/**确定*/
		private function confirmHandler():void {
			view.btn_confirm.visible = false;
			playAnimation();
			for (var i = 0; i < view.dom_box.numChildren; i++) {
				var child:Node = view.dom_box.getChildAt(i);
				tweenCard(child);
			}
		}
		
		private function tweenCard(card:Card):void {
			Tween.to(card, targetPos, 600, Ease.circOut, Handler.create(this, function() {
				card.destroy();
			}));
		}
		
		private function playAnimation():void {
			var roleAni:Animation = new Animation();
			var url = "appRes/effects/chouka.json";
			roleAni.pos(730, 170);
			roleAni.loadAtlas(url, Handler.create(null, function(){
				roleAni.once(Event.COMPLETE, this, function() {
					roleAni.destroy();
					close();
				});
				roleAni.play();
			}));
			view.addChild(roleAni);
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
			
			view.btn_confirm.off(Event.CLICK, this, confirmHandler);
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view():CardShowViewUI
		{
			_view = _view || new CardShowViewUI();
			return _view;
		}
		
		
	}
}