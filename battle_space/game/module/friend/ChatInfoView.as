package game.module.friend
{
	import MornUI.friend.ChatInfoViewUI;
	
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class ChatInfoView extends Box
	{
		private var m_ui:ChatInfoViewUI;
		private var m_arr:Array;
		public function ChatInfoView(p_ui:ChatInfoViewUI,p_arr:Array)
		{
			super();
			m_ui=p_ui;
			m_arr=p_arr;
			initUI();
		}
		
		/**
		 *初始化 
		 * 
		 */		
		private function initUI():void
		{
			this.m_ui.mouseEnabled=true;
			this.m_ui.mouseThrough=true;
			if(m_arr.length>0)
			{
				this.m_ui.ChatList.visible=true;
				this.m_ui.ChatList.vScrollBarSkin = "";
				this.m_ui.ChatList.itemRender=ChatInfoCell;
				this.m_ui.ChatList.selectHandler = new Handler(this, onSelect);
				
				this.m_ui.ChatList.selected=true;
				
				this.m_ui.ChatList.array=m_arr;
				this.m_ui.ChatList.refresh();
				this.m_ui.ChatList.scrollTo(m_arr.length);
			}
			else
			{
				this.m_ui.ChatList.visible=false;
			}
			//this.m_ui.ChatList.startIndex=3;
		}
		
		
		public function clearChatList():void
		{
			
			
			
		}
		
		
		
		private function onSelect():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}