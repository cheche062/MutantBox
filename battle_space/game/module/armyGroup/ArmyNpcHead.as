package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	import MornUI.armyGroup.ArmyNpcHeadUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyNpcHead extends BaseView 
	{
		
		public function ArmyNpcHead() 
		{
			super();
			
		}
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			
			view.headImg.skin = UnitPicUtil.getUintPic(GameConfigManager.ArmyGroupNpcList[value.budui_id].apper, UnitPicUtil.ICON);
		}
		
		override public function createUI():void
		{
			this._view = new ArmyNpcHeadUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			view.headImg.width = view.headImg.height = 40;
		}
		
		override public function addEvent():void{
			
			super.addEvent();
			
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
			
		}
		
		private function get view():ArmyNpcHeadUI{
			return _view;
		}
		
		public function set lightShow(value:Boolean):void 
		{
			view.lightImg.visible = value;
		}
	}

}