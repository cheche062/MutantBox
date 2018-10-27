package game.module.friend
{
	import MornUI.friend.MailCellUI;
	
	import game.global.vo.friend.FriendVo;
	import game.global.vo.friend.MailInfoVo;
	
	import laya.ui.Box;
	
	public class MailCell extends Box
	{
		private var m_ui:MailCellUI;
		private var m_mailData:MailInfoVo;
		private var m_type:int;
		private var m_select:Boolean;
		private var m_friendVo:FriendVo;
		
		public function MailCell(p_ui:MailCellUI)
		{
			super();
			this.m_ui = p_ui;
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(value!=null){
				m_type=value.type;
				if(m_type==0)
				{
					m_mailData=value;
				}
				else
				{
					m_friendVo=value;
				}
				m_select=false;
				initUI();
			}
		}
		
		/**
		 * 初始化
		 */
		private function initUI():void
		{
			// TODO Auto Generated method stub
			if(m_type==0)
			{
				if(m_mailData!=null)
				{
					this.m_ui.HeadLineText.text=m_mailData.title;
					var l_date:Date=new Date(m_mailData.send_time*1000);
					this.m_ui.TimeText.text=l_date.getFullYear()+" - "+(parseInt(l_date.getMonth())+1)+" - "+l_date.getUTCDate();
					this.m_ui.FriendImage.visible=false;
					this.m_ui.DeleteFriend.visible=false;
					this.m_ui.FriendNameText.visible=false;
					this.m_ui.TimeText.color="#add3ff";
					this.m_ui.HeadLineText.color="#add3ff";
					if(m_mailData.state==3 || m_mailData.state==2)
					{
						this.m_ui.MailImage.visible=true;
						this.m_ui.MailImage.skin="friend/icon_mail.png";
					}
					else if(m_mailData.state==1)
					{
						this.m_ui.MailImage.skin="friend/icon_mail_2.png";
						this.m_ui.MailImage.visible=true;
					}
				}
			}
			else
			{
				this.m_ui.FriendNameText.text=m_friendVo.name;
				this.m_ui.MailImage.visible=false;
				this.m_ui.HeadLineText.visible=false;
				this.m_ui.TimeText.visible=false;
				if(m_type==1)
				{
					this.m_ui.DeleteFriend.visible=false;	
				}
				else
				{
					this.m_ui.DeleteFriend.visible=true;
					this.m_ui.DeleteFriend.name="DeleteFriend_"+m_friendVo.uid;
				}
				this.m_ui.FriendNameText.color="#add3ff";
				if(m_friendVo.onLine==1)
				{
					this.m_ui.FriendImage.skin="friend/icon_online.png";	
				}
				else
				{
					this.m_ui.FriendImage.skin="friend/icon_offline.png";
				}
			}
			this.m_ui.BgImage.skin="common/bg5.png";
		}
		
		/**
		 * 设置选择状态
		 */
		public function setSelectType(p_select:Boolean,value:*):void
		{
			m_type=value.type;
			if(m_type==0)
			{
				m_mailData=value;
			}
			else
			{
				m_friendVo=value;
			}
			if(m_select!=p_select)
			{
				m_select=p_select;
				
				if(m_select)
				{
					if(m_type==0)
					{
						//m_mailData.state=2;
						this.m_ui.BgImage.skin="common/bg5_2.png";
						this.m_ui.MailImage.skin="friend/icon_mail_1.png";
						this.m_ui.MailImage.visible=true;
						this.m_ui.TimeText.color="#84ff7a";
						this.m_ui.HeadLineText.color="#84ff7a";
					}
					else
					{
						this.m_ui.FriendNameText.color="#f8cf40";
						if(m_friendVo.onLine==true)
						{
							this.m_ui.FriendImage.skin="friend/icon_online_1.png";
						}
						else
						{
							this.m_ui.FriendImage.skin="friend/icon_offline.png";
						}
						this.m_ui.BgImage.skin="common/bg5_1.png";
					}
				}
				else
				{
					initUI();
				}
				
			}
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new MailCellUI();
				this.addChild(m_ui);
			}
		}
		
	}
}