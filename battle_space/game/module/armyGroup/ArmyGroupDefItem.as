package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import MornUI.armyGroup.ArmyGroupDefItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupDefItem  extends BaseView
	{
		
		public function ArmyGroupDefItem() 
		{
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			
			view.lvTxt.text = value[2];
			view.nameTxt.text = value[1];
			view.BRTxt.text = value[0];
			
		}
		
		override public function createUI():void
		{
			this._view = new ArmyGroupDefItemUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			
		}
		
		override public function addEvent():void{
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
		}
		
		private function get view():ArmyGroupDefItemUI{
			return _view;
		}
		
	}

}