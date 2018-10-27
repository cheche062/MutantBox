package game.module.friend
{
	import MornUI.friend.FriendRequestCellUI;
	import MornUI.friend.MailCellUI;
	
	import game.global.vo.friend.FriendVo;
	import game.global.vo.friend.MailInfoVo;
	
	import laya.ui.Box;
	
	public class FriendRequestCell extends Box
	{
		private var m_ui:FriendRequestCellUI;
		private var m_data:FriendVo;
		
		
		public function FriendRequestCell(p_ui:FriendRequestCellUI)
		{
			super();
			m_ui=p_ui;
			init();
		}
		
		/**
		 * 初始化
		 */
		private function initUI()
		{
			if(m_data!=null)
			{
				m_ui.NameText.text=m_data.name;
				m_ui.RefuseBtn.name="RefuseBtn_"+m_data.uid;
				m_ui.AgreeBtn.name="AgreeBtn_"+m_data.uid;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			initUI();
		}
		
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new FriendRequestCellUI();
				this.addChild(m_ui);
			}
		}
		
	}
}