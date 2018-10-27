package game.module.startrek
{
	import MornUI.startrek.StarTrekBoxUI;

	import game.common.base.BaseView;
	import game.global.event.Signal;
	import game.global.event.StarTrekEvent;

	import laya.events.Event;

	/**
	 * 星际迷航盒子模型
	 * @author douchaoyang
	 *
	 */
	public class StarTrekBox extends BaseView
	{
		/**
		 * 家
		 */
		public static const STATE_0:int=0;
		/**
		 * 默认没打开状态
		 */
		public static const STATE_1:int=1;
		/**
		 * 默认可打开状态
		 */
		public static const STATE_2:int=2;
		/**
		 * 不能打开，周围有怪物
		 */
		public static const STATE_3:int=3;
		/**
		 * 已走过
		 */
		public static const STATE_4:int=4;
		/**
		 * 商店
		 */
		public static const STATE_5:int=5;
		/**
		 * buff
		 */
		public static const STATE_6:int=6;
		/**
		 * 奖励
		 */
		public static const STATE_7:int=7;
		/**
		 * 小怪
		 */
		public static const STATE_8:int=8;
		/**
		 * boss
		 */
		public static const STATE_9:int=9;
		private var _iState:int;

		// 后端x,y值
		private var _iX:int;
		private var _iY:int;

		// 事件id
		private var _iEvent:int=-1;

		public function StarTrekBox()
		{
			super();
		}

		override public function createUI():void
		{
			this._view=new StarTrekBoxUI();
			this.addChild(this._view);
			this.addEvent();
		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClickHandler);
			super.addEvent();
		}

		override public function removeEvent():void
		{
			view.on(Event.CLICK, this, this.onClickHandler);
			super.removeEvent();
		}

		private function onClickHandler():void
		{
			Signal.intance.event(StarTrekEvent.IBOXCLICK, [iX, iY]);
		}

		public function get iX():int
		{
			return this._iX;
		}

		public function set iX(value:int):void
		{
			this._iX=value;
		}

		public function get iY():int
		{
			return this._iY;
		}

		public function set iY(value:int):void
		{
			this._iY=value;
		}

		public function get iState():int
		{
			return this._iState;
		}

		public function set iState(value:int):void
		{
			this._iState=value;
			changeStateHandler();
		}

		public function get iEvent():int
		{
			return this._iEvent;
		}

		public function set iEvent(value:int):void
		{
			this._iEvent=value;
		}

		public function set iIcon(value:int):void
		{
			if (value != -1)
			{
				view.comIcon.skin="appRes/icon/mazeIcon/" + value + ".png";
				view.comIcon.zOrder=15;
			}
			else
			{
				view.comIcon.skin="";
				view.comIcon.zOrder=0;
			}
		}

		private function changeStateHandler():void
		{
			for (var i=0; i <= 9; i++)
			{
				view["state" + i].visible=false;
			}
			view["state" + iState].visible=true;
		}

		private function get view():StarTrekBoxUI
		{
			return this._view as StarTrekBoxUI;
		}
	}
}
