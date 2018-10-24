package game.module.TeamCopy
{
	import MornUI.relic.TrainLogCellUI;
	import MornUI.teamcopy.TeamCopyChatCellUI;
	
	import game.global.vo.User;
	import game.global.vo.teamCopy.TeamCopyChatVo;
	
	import laya.ui.Box;
	
	public class TeamCopyChatCell extends Box
	{
		private var m_data:TeamCopyChatVo;
		public var m_ui:TeamCopyChatCellUI;
		public function TeamCopyChatCell()
		{
			super();
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
			var l_color:String="#ffffff";
			if(m_data.uid==User.getInstance().uid)
			{
				l_color="#ffffff";
			}
			else
			{
				l_color="#add3ff";
			}
			m_ui.NameText.color=l_color;
			m_ui.InfoText.color=l_color;
			m_ui.NameText.text=m_data.user_name+":";
			m_ui.InfoText.text=m_data.msg;
			
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new TeamCopyChatCellUI();
				this.addChild(m_ui);
			}
		}
	}
}