package game.module.TeamCopy
{
	import MornUI.teamcopy.TeamCopyRoomViewUI;
	import MornUI.teamcopy.TeamCopySearchViewUI;
	
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	
	import laya.events.Event;
	
	public class TeamCopySearchView extends BaseView
	{
		public function TeamCopySearchView()
		{
			super();
		}
		
		/**初始化UI*/
		override public function createUI():void
		{
			GameConfigManager.intance.InitTeamCopyParam();
			this._view = new TeamCopySearchViewUI();
			this._view.mouseThrough = true;
			this.mouseThrough = true;
			this.addChild(_view);
			
		}
		
		override public function show(...args):void
		{
//			m_teamCopyRoomVo=args[0];
			super.show();
			initUI();
			
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			timer.loop(1000,this,updateTimeHandler);
		}		
		
		private function updateTimeHandler():void
		{
			// TODO Auto Generated method stub
			
		}		
		
		override public function addEvent():void
		{
			this.on(Event.CLICK, this, this.onClickHandler);
		}
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case view.CloseBtn:
				{
					this.close();
					break;
				}
				case view.ChanelBtn:
				{
					
					break;
				}
				default:
				{
					break;
				}
			}
		}		
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClickHandler);
		}
		
		
		
		private function get view():TeamCopySearchViewUI
		{
			return this._view as TeamCopySearchViewUI;		
		}
	}
}