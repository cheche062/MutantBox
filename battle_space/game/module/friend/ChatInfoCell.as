package game.module.friend
{
	import MornUI.friend.ChatInfoCellUI;
	
	import game.global.vo.User;
	import game.global.vo.friend.ChatVo;
	
	import laya.ui.Box;
	
	public class ChatInfoCell extends Box
	{
		private var m_ui:ChatInfoCellUI;
		private var m_data:ChatVo;
		private var m_height:Number=0;
		public function ChatInfoCell(p_ui:ChatInfoCellUI)
		{
			super();
			this.m_ui = p_ui;
			init();
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			initUI();
		}
		
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			if(m_data!=null)
			{
				if(User.getInstance().uid.toString()==m_data.uid)
				{
					m_ui.chatText.color="#add3ff"
					m_ui.NameText.color="#add3ff";
				}
				else
				{
					m_ui.chatText.color="#f8cf40"
					m_ui.NameText.color="#f8cf40";
				}
				m_ui.NameText.text=m_data.name;
				m_ui.chatText.text=m_data.msg;
			}
			m_height=m_ui.chatText.textHeight+m_ui.NameText.textHeight+10;
		}
		
		override public function get height():Number{
			return 78;
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new ChatInfoCellUI();
				this.addChild(m_ui);
			}
		}
	}
}