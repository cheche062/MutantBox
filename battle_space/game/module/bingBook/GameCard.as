package game.module.bingBook 
{
	import game.global.event.BingBookEvent;
	import game.global.event.Signal;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	/**
	 * ...
	 * @author ...
	 */
	public class GameCard extends Sprite
	{
		
		private var _cardImg:Image;
		
		private var _cardID:int = 0;
		
		private var _isLock:Boolean = false;
		
		public function GameCard() 
		{
			_cardImg = new Image();
			_cardImg.skin = "appRes/bingBook/" + cardID + ".png";
			
			this.addChild(_cardImg);
			
			this._cardImg.on(Event.CLICK, this, this.selectCard);
		}
		
		private function selectCard():void 
		{
			if (!_isLock)
			{
				this.event(BingBookEvent.SELECT_CARD, [cardID]);
				
				//Signal.intance.event();
			}
		}
		
		public function setCardData(id:int = null):void
		{
			if (id)
			{
				cardID = id;
				_isLock = false;
				_cardImg.skin = "appRes/bingBook/0.png";
			}
			
			//_cardImg.skin = "appRes/bingBook/" + cardID + ".png";
		}
		
		public function openCard():void
		{
			Tween.to(_cardImg, { width:0,x:53 }, 200, Ease.linearNone,new Handler(this,turnFace));
		}
		
		private function turnFace():void
		{
			_cardImg.skin = "appRes/bingBook/" + cardID + ".png";
			Tween.to(_cardImg, { width:106,x:0 }, 200, Ease.linearNone);
		}
		
		public function closeCard():void
		{
			Tween.to(_cardImg, { width:0,x:53 }, 200, Ease.linearNone,new Handler(this,turnBack));
		}
		
		private function turnBack():void
		{
			_cardImg.skin = "appRes/bingBook/0.png";
			Tween.to(_cardImg, { width:106,x:0 }, 200, Ease.linearNone);
		}
		
		
		public function get cardID():int 
		{
			return _cardID;
		}
		
		public function set cardID(value:int):void 
		{
			_cardID = value;
		}
		
		public function get isLock():Boolean 
		{
			return _isLock;
		}
		
		public function set isLock(value:Boolean):void 
		{
			_isLock = value;
		}
		
	}

}