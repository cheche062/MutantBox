package game.global.vo.friend
{
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.User;
	
	import laya.ani.bone.Bone;
	
	import org.hamcrest.mxml.collection.InArray;

	public class FriendInfoVo
	{
		//邮件列表
		public var MailInfoList:Array=new Array();
		//请求好友
		public var ApplyFriendList:FriendVo;
		//好友请求
		public var RequestFriendList:Array=new Array();
		//好友列表
		public var FriendList:Array=new Array();
		//聊天列表
		public var ChatList:Array=new Array();
		private var mailunReadnum:int;
		private var friendRequstNum:int;
		private var chatUnreadNum:int;
		
		private var m_new_mail:Boolean;
		
		public var newServersNum:int;
		
		public var newStstemNum:int;
		
		
		public function FriendInfoVo()
		{
		}
		/**
		 * 
		 */
		public function setFriendList(p_obj:Object):void
		{
			FriendList=new Array();
			RequestFriendList=new Array();
			ChatList=new Array();
			for(var i:int=0;i<p_obj.friend_list.length;i++)
			{
				var l_vo:FriendVo=new FriendVo();
				l_vo.uid=p_obj.friend_list[i].uid;
				l_vo.name=p_obj.friend_list[i].name;
				l_vo.onLine=p_obj.friend_list[i].is_online;
				l_vo.type=1;
				FriendList.push(l_vo);
			}
			for(var i:int=0;i<p_obj.apply_list.length;i++)
			{
				var l_vo:FriendVo=new FriendVo();
				l_vo.uid=p_obj.apply_list[i].uid;
				l_vo.name=p_obj.apply_list[i].name;
				l_vo.type=1;
				RequestFriendList.push(l_vo);
			}
		}
		
		/**
		 * 设置玩家管理状态
		 * @param p_type
		 * 
		 */		
		public function setFriendSetType(p_type:int):void
		{
			for(var i:int=0;i<FriendList.length;i++)
			{
				var l_vo:FriendVo=FriendList[i];
				l_vo.type=p_type;
			}
		}
		
		/**
		 * 玩家聊天信息
		 * @param p_obj
		 * @param p_friendVo
		 * 
		 */		
		public function setChatList(p_obj:Object,p_friendVo:FriendVo):void
		{
			ChatList=new Array();
			var obj:Object=p_obj[0];
			var c:Object;
			for each(c in obj)
			{
				if(c.msg!=undefined)
				{
					var l_vo:ChatVo=new ChatVo();
					l_vo.msg=c.msg;
					l_vo.time=c.time;
					l_vo.uid=c.uid;
					if(l_vo.uid==p_friendVo.uid)
					{
						l_vo.name=p_friendVo.name;
					}
					else
					{
						l_vo.name=User.getInstance().name;
					}
					ChatList.push(l_vo);
				}
			}
		}
		
		/**
		 * 接受好友聊天记录
		 * @param p_obj
		 * @param p_friendVo
		 * 
		 */		
		public function addChatList():void
		{
			chatUnreadNum++;
		}
		
		/**
		 * 
		 * @param p_obj
		 * 
		 */		
		public function setMailInfo(p_obj:Object):void
		{
			var c:Object;
			MailInfoList=new Array();
			for each(c in p_obj.mail_list)
			{
				var l_mailInfoVo:MailInfoVo=new MailInfoVo();
				l_mailInfoVo.key=c.name;
				l_mailInfoVo.title=c["title"];
				if(c["title"].language_id!=undefined&&c["title"].language_id!=null)
				{
					var l_id:String=c["title"].language_id;
					var l_arr:Array=c["title"].paramet;
//					var l_str:String="xxxx{0}xxx{1}";
					l_mailInfoVo.title=StringUtil.substitute(GameLanguage.getLangByKey(l_id),l_arr)
				}
				
				l_mailInfoVo.content=c["content"];
				if(c["content"].language_id!=undefined&&c["content"].language_id!=null)
				{
					var l_id:String=c["content"].language_id;
					var l_arr:Array=c["content"].paramet;
//					var l_str:String="xxxx{0}xxx{1}";
					l_mailInfoVo.content=StringUtil.substitute(GameLanguage.getLangByKey(l_id),l_arr);
				}
				l_mailInfoVo.send_time=c["send_time"];
				l_mailInfoVo.state=c["state"];
				l_mailInfoVo.attachment=c["attachment"];
				l_mailInfoVo.type=0;
				l_mailInfoVo.key=c["mail_id"];
				MailInfoList.push(l_mailInfoVo);
			}
			m_new_mail=p_obj.new_mail;
			
			
			
		}
		
		/**
		 * 增加邮件
		 * @param p_obj
		 * 
		 */		
		public function addMailInfo(p_obj:Object):void
		{
			var c:Object;
			for each(c in p_obj.mail_list)
			{
				var l_mailInfoVo:MailInfoVo=new MailInfoVo();
				l_mailInfoVo.key=c.name;
				l_mailInfoVo.title=c["title"];
				if(c["title"].language_id!=undefined&&c["title"].language_id!=null)
				{
					var l_id:String=c["title"].language_id;
					var l_arr:Array=c["title"].paramet;
//					var l_str:String="xxxx{0}xxx{1}";
					l_mailInfoVo.title=StringUtil.substitute(GameLanguage.getLangByKey(l_id),l_arr)
				}

				l_mailInfoVo.content=c["content"];
				if(c["content"].language_id!=undefined&&c["content"].language_id!=null)
				{
					var l_id:String=c["content"].language_id;
					var l_arr:Array=c["content"].paramet;
					l_mailInfoVo.content=StringUtil.substitute(GameLanguage.getLangByKey(l_id),l_arr)
				}
				l_mailInfoVo.send_time=c["send_time"];
				l_mailInfoVo.state=c["state"];
				l_mailInfoVo.attachment=c["attachment"];
				l_mailInfoVo.type=0;
				l_mailInfoVo.key=c["mail_id"];
				MailInfoList.push(l_mailInfoVo);
			}
		}
		
		
		/**
		 *是否有邮件提示 
		 * @return 
		 * 
		 */		
		public function getMailRedot():Boolean
		{
			return m_new_mail;
		}
		
		/**
		 * 好友请求的数量
		 * @return 
		 * 
		 */		
		public function getFriendRequstRedot():int
		{
			return RequestFriendList.length
		}
		
		/**
		 * 是否有聊天信息
		 * @return 
		 * 
		 */		
		public function getChatRedot():Boolean
		{
			return chatUnreadNum>0;
		}
		
		public function clearChatNum():void
		{
			chatUnreadNum=0;
		}
		
		public function hasFriendById(p_uid:String):Boolean
		{
			for(var i:int=0;i<FriendList.length;i++)
			{
				var l_friendVo:FriendVo=FriendList[i];
				if(l_friendVo.uid==p_uid)
				{
					return true;
				}
			}
			return false;
		}
		
		
		
		
		/**
		 * 好友在线数量
		 */
		public function getonlinenum():int
		{
			var num:int=0;
			for(var i:int=0;i<FriendList.length;i++)
			{
				var l_friendVo:FriendVo=FriendList[i];
				if(l_friendVo.onLine==1)
				{
					num++;
				}
			}
			return num;
		}
		
		
	}
}