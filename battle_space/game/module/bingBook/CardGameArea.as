package game.module.bingBook 
{
	import game.global.event.BingBookEvent;
	import game.global.event.Signal;
	import laya.display.Sprite;
	import laya.ui.Image;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CardGameArea extends Sprite 
	{
		
		private var _cardVec:Vector.<GameCard> = new Vector.<GameCard>(18);
		
		private var _cardInfo:Array = [];
		
		private var _curCard:GameCard;
		private var _sCard:GameCard;
		
		private var _isCheck:Boolean = false;
		
		public function CardGameArea() 
		{
			super();
			this.width = 736;
			this.height = 358;
			
			for (var i:int = 0; i < 18; i++) 
			{
				_cardVec[i] = new GameCard();
				_cardVec[i].x = (i % 6) * 121;
				_cardVec[i].y = parseInt(i / 6) * 121;
				_cardVec[i].on(BingBookEvent.SELECT_CARD, this, this.selectCardHandler,[_cardVec[i]]);
				this.addChild(_cardVec[i]);
				
				_cardInfo[i] = parseInt(i / 2) + 1;
				
			}
			
		}
		
		public function startGame():void
		{
			var c1, c2, t:int = 0;
			for (var i:int = 0; i < 1000; i++) 
			{
				c1 = parseInt(Math.random() * 100)%18;
				c2 = parseInt(Math.random() * 100)%18;
				t = _cardInfo[c1];
				_cardInfo[c1] = _cardInfo[c2];
				_cardInfo[c2] = t;
			}
			
			for (i = 0; i < 18; i++) 
			{
				_cardVec[i].setCardData(_cardInfo[i]);
			}
			
			//timer.once(2000,this,closeAllCard);
			
		}
		
		private function closeAllCard():void
		{
			for (var i:int = 0; i < 18; i++) 
			{
				_cardVec[i].closeCard();
			}
			_isCheck = false;
		}
		
		
		private function selectCardHandler(...args):void 
		{
			if (_isCheck)
			{
				return;
			}
			
			_sCard = args[0] as GameCard;
			
			
			if (_curCard == _sCard)
			{
				return;
			}
			
			Signal.intance.event(BingBookEvent.SELECT_CARD,[]);
			
			_sCard.openCard();
			
			
			if (!_curCard)
			{
				_curCard = _sCard;
				return;
			}
			_isCheck = true;
			timer.once(500,this,checkAnswer);
			
			
		}
		
		private function checkAnswer():void
		{
			if (_curCard.cardID == _sCard.cardID)
			{
				_curCard.isLock = _sCard.isLock = true;
				Signal.intance.event(BingBookEvent.CARD_BINGO);
			}
			else
			{
				_curCard.closeCard();
				_sCard.closeCard();
				
			}
			_curCard = null;
			_isCheck = false;
		}
		
	}

}