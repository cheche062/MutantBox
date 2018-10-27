package game.module.arena
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import MornUI.arena.ArenaFreeWinUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaFreeWin extends BaseDialog
	{
		
		private var _itemContainer:ItemContainer;
		
		public function ArenaFreeWin()
		{
			super();
		
		}
		
		override public function show(... args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			view.newLv.text = args[0][1];
			
			var dRank:int = (parseInt(User.getInstance().arenaRank) > 0?User.getInstance().arenaRank:ArenaMainView.RANK_MAX_NUM) - parseInt(args[0][1]);
			if ( dRank<= 0)
			{
				view.upLv.text = "(    0)";
			}
			else
			{
				view.upLv.text = "(    " + dRank + ")";
			}
			User.getInstance().arenaRank = parseInt(args[0][1]);
			_itemContainer.setData("12", args[0][2]);
		
		}
		
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.confirmBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new ArenaFreeWinUI();
			this.addChild(_view);
			_itemContainer = new ItemContainer();
			_itemContainer.x = 310;
			_itemContainer.y = 100;
			_itemContainer.setData("12");
			view.addChild(_itemContainer);
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():ArenaFreeWinUI
		{
			return _view;
		}
	
	}

}