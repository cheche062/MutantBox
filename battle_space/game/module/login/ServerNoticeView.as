package game.module.login
{
	import MornUI.login.ServerNoticeViewUI;
	import MornUI.relic.EscortMainViewUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	
	public class ServerNoticeView extends BaseDialog
	{
		private var m_data:Object;
		
		public function ServerNoticeView()
		{
			super();
			this._m_iLayerType = LayerManager.M_TOP;
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new ServerNoticeViewUI();
			this.addChild(_view);
			
		}
		
		override public function show(...args):void
		{
			m_data=args[0];
			super.show();
			initUI();
		}
		
		private function initUI():void
		{
			var str:String=m_data["en"];
			trace("m_data"+str);
			view.InfoText.text=str;
		}
		
		override public function addEvent():void
		{
			
		}
		
		override public function removeEvent():void
		{
			
		}
		
		private function get view():ServerNoticeViewUI
		{
			return _view as ServerNoticeViewUI;
		}
		
	}
}