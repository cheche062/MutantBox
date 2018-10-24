package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	import laya.events.Event;
	import MornUI.armyGroup.ArmyNpcItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyNpcItem extends BaseView 
	{
		
		private var _index:int = 0;
		
		
		public function ArmyNpcItem(i:int) 
		{
			super();
			_index = i;
		}
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			
			view.headImg.skin = UnitPicUtil.getUintPic(GameConfigManager.ArmyGroupNpcList[value.budui_id].apper, UnitPicUtil.ICON_SKEW);
			
		}
		
		override public function createUI():void
		{
			this._view = new ArmyNpcItemUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			view.lightImg.visible = false;
			
			addEvent();
		}
		
		private function onClickHandler(e:Event):void 
		{
			Signal.intance.event("selectNpc", [_index]);
		}
		
		
		override public function addEvent():void{
			
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			
		}
		
		private function get view():ArmyNpcItemUI{
			return _view;
		}
		
		public function set lightShow(value:Boolean):void 
		{
			view.lightImg.visible = value;
		}
		
		
	}

}