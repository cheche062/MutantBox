package game.module.friend
{
	import game.global.GameSetting;
	import MornUI.friend.FriendMainViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.friend.ChatVo;
	import game.global.vo.friend.FriendInfoVo;
	import game.global.vo.friend.FriendVo;
	import game.global.vo.friend.MailInfoVo;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class FriendMainView extends BaseDialog
	{
		private var m_stage:int;
		private var m_friendVo:FriendInfoVo;
		
		private var m_mailType:int;
		private var m_selectCell:int;
		private var m_first:Boolean;
		//好友管理的状态
		private var m_friendType:int;
		
		//好友请求状态
		private var m_friendApplyType:int;
		
		//我发送的消息
		private var m_chatVo:ChatVo;
		//
		private var m_mailVo:MailInfoVo;
		
		private var m_mailPage:int;
		
		private var m_maxMailNum:int;
		private var m_selectFriendId:String;
		
		private var hasNewMsg:Boolean = false;
		
		public function FriendMainView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new FriendMainViewUI();
			this.addChild(_view);
			this.closeOnBlank=true;
		}
		
		override public function show(...args):void
		{
			
			trace("好友界面UI：", args);
			
			super.show(args);
			AnimationUtil.flowIn(this);
			m_friendVo = args[0][0];
			
			m_mailType=1;
			view.FriendText.visible=true;
			view.SetBtn.visible=true;
			view.FriendNum.visible=true;
			initUI();
			
			if (Boolean(args[0][1]))
			{
				hasNewMsg = true;
			}
			view.FriendInfo.inviteBtn.visible = !GameSetting.isApp;
		}
		/**
		 * 初始化
		 */
		private function initUI()
		{
			this.view.ChatInfo.TextInPutText.text="";
			m_first=true;
			m_selectCell=-1;
			m_mailPage=1;
			m_friendType=1;
			m_stage=0;
			GameConfigManager.intance.getConfigMessage();
			setBtnType(1);
			m_mailType=1;
			setMailBtnType();
			
			// 不需要请求好友列表了
//			WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
			initBtnRetor();
		}
		
		private function initBtnRetor():void
		{
			var l_num:int=m_friendVo.getFriendRequstRedot();
			if(l_num>0)
			{
				this.view.FriendRedot.visible=true;
				this.view.FriendRedotText.text=l_num.toString();
			}
			else
			{
				this.view.FriendRedot.visible=false;
			}
			if(m_friendVo.newServersNum>0)
			{
				this.view.ServerRedot.visible=true;
			}
			else
			{
				this.view.ServerRedot.visible=false;
			}
			if(m_friendVo.newStstemNum>0)
			{
				this.view.StstemRedot.visible=true;
			}
			else
			{
				this.view.StstemRedot.visible=false;
			}
			
			this.view.MailRedot.visible = m_friendVo.getMailRedot();
			this.view.ChatRedot.visible=hasNewMsg||m_friendVo.getChatRedot();
		}
		
		
		/**
		 * 切换状态
		 */
		private function setBtnType(p_type:int)
		{
			if(p_type!=m_stage)
			{
				m_stage=p_type;
				switch(m_stage)
				{
					case 1:			//邮件
						this.view.CharBtn.selected=false;
						this.view.MailBtn.selected=true;
						this.view.FriiendBtn.selected=false;
						m_mailType=1;
						setMailBtnType();
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETNAIL,[1,30,m_mailType]);
						m_first=false;
						break;
					case 2:			//聊天
						this.view.CharBtn.selected=true;
						this.view.MailBtn.selected=false;
						this.view.FriiendBtn.selected=false;
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
						break;
					case 3:			//好友
						this.view.CharBtn.selected=false;
						this.view.MailBtn.selected=false;
						this.view.FriiendBtn.selected=true;
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
						break;
				}
				setStateUI();
			}
		}
		/**
		 * 切换界面状态
		 */
		private function setStateUI():void
		{
			switch(m_stage)
			{
				case 1:
					this.view.MailBox.visible=true;
					this.view.MainInfo.visible=true;
					this.view.FriendBox.visible=false;
					this.view.FriendInfo.visible=false;
					this.view.ChatInfo.visible=false;
					setMailList();
					break;
				case 2:
					this.view.MainInfo.visible=false;
					this.view.FriendBox.visible=true;
					this.view.FriendInfo.visible=false;
					this.view.MailBox.visible=false;
					this.view.ChatInfo.visible=true;
					m_friendVo.clearChatNum();
					//setFriendList();
					break;
				case 3:
					this.view.FriendBox.visible=true;
					this.view.MailBox.visible=false;
					this.view.MainInfo.visible=false;
					this.view.FriendInfo.visible=true;
					this.view.ChatInfo.visible=false;
					//setFriendList();
					break;
			}
		}
		
		/**
		 * 邮件列表
		 */
		public function setMailList():void
		{
			if(m_friendVo.MailInfoList.length>0)
			{
				this.view.MailList.visible=true;
				this.view.MailList.itemRender=MailCell;
				this.view.MailList.selectEnable = true;
				this.view.MailList.selectHandler=new Handler(this, onSelect);
				this.view.MailList.renderHandler = new Handler(this, updateItem);
				this.view.MailList.array=m_friendVo.MailInfoList;
				this.view.MainInfo.visible=false;
				this.view.MailList.scrollBar.value=0;
				onSelect(0);
			}
			else
			{
				this.view.MainInfo.ReceiveBtn.visible=false;
				this.view.MainInfo.ReceiveText.visible=false;
				this.view.MainInfo.visible=false;
				this.view.MailList.visible=false;
			}
		}
		
		/**
		 * 刷新邮件列表
		 * 判断到最后一个了就获取下一列
		 */
		private function updateItem(p_cell:MailCell,p_index:int):void
		{
			if(m_selectCell==p_index)
			{
				onSelect(m_selectCell);
			}
			var max=30*m_mailPage;
			if(p_index==(m_friendVo.MailInfoList.length-1)&&m_friendVo.MailInfoList.length>=max)
			{
				m_mailPage++;
				WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETNAIL,[m_mailPage,30,m_mailType]);
			}
			// TODO Auto Generated method stub
		}
		
		/**
		 * 选择列表控件
		 * 
		 */
		private function onSelect(p_index:int):void
		{
			if(m_stage==1)
			{
				var l_cell:MailCell=this.view.MailList.getCell(m_selectCell);
				var l_vo:MailInfoVo=this.view.MailList.getItem(m_selectCell);
				this.view.SetBtn.visible=true;
				this.view.OkBtn.visible=false;
				this.view.MaxFriendText.visible=false;
				this.view.FriendText.visible=true;
				this.view.FriendNum.visible=true;
				if(l_cell!=null && l_vo)
				{
					if(l_vo.state==1)
					{
						l_vo.state=2;
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_READMAIL,[l_vo.key]);
					}
					l_cell.setSelectType(false,l_vo);
				}
				m_selectCell=p_index;
				var l_cell1 =this.view.MailList.getCell(m_selectCell);
				var l_vo1=this.view.MailList.getItem(m_selectCell);
				if(l_vo1.state==1)
				{
					l_vo1.state=2;
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_READMAIL,[l_vo1.key]);
				}
				if(l_cell1!=null  && l_vo)
				{
					l_cell1.setSelectType(true,l_vo1);
				}
				m_mailVo=l_vo1;
				var item:MailInfoView=new MailInfoView(this.view.MainInfo,l_vo1);
				this.view.MainInfo.visible=true;
			}
			else
			{
				var l_cell:MailCell=this.view.FriendList.getCell(m_selectCell);
				var l_friendVO:FriendVo=this.view.FriendList.getItem(m_selectCell);
				if(l_cell!=null&&l_friendVO!=null)
				{
					l_cell.setSelectType(false,l_friendVO);
				}
				m_selectCell=p_index;
				l_cell=this.view.FriendList.getCell(m_selectCell);
				l_friendVO=this.view.FriendList.getItem(m_selectCell);
				if(l_cell!=null&&l_friendVO!=null)
				{
					l_cell.setSelectType(true,l_friendVO);
				}
				m_selectFriendId=l_friendVO.uid;
				WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GATCHATLIST,[l_friendVO.uid]);
			}
			// TODO Auto Generated method stub
		}		
		
		
		/**
		 * 好友列表
		 */
		public function setFriendList():void
		{
			if(m_friendType==1)
			{
				this.view.FriendNum.text=m_friendVo.getonlinenum().toString()+"/"+m_friendVo.FriendList.length.toString();
				this.view.MaxFriendText.visible=false;
				this.view.OkBtn.visible=false;
				this.view.FriendNum.visible=true;
			}
			else
			{
				this.view.MaxFriendText.text="Max("+m_friendVo.FriendList.length.toString()+"/"+GameConfigManager.messageConfig.friendMax+")";
				this.view.FriendText.visible=false;
				this.view.FriendNum.visible=false;
				this.view.MaxFriendText.visible=true;
			}
			if(m_friendVo.FriendList.length>0)
			{
				this.view.FriendList.visible=true;
				this.view.FriendList.itemRender=MailCell;
				this.view.FriendList.selectEnable = true;
				this.view.FriendList.vScrollBarSkin = "";
				this.view.FriendList.selectHandler=new Handler(this, onSelect);
				this.view.FriendList.renderHandler = new Handler(this, updateItem);
				this.view.FriendList.array=m_friendVo.FriendList;
				if(m_stage!=1)
				{
					onSelect(0);
				}
			}
			else
			{
				this.view.FriendList.visible=false;
				this.view.ChatInfo.ChatList.visible=false;
			}
		}
		
		/**
		 * 请求列表
		 */
		public function setRequestList(p_type:int):void
		{
			m_friendApplyType=p_type;
			var arr:Array=new Array();
			if(m_friendApplyType==1)
			{
				arr=m_friendVo.RequestFriendList;
			}
			else
			{
				arr.push(m_friendVo.ApplyFriendList);
			}
			
			if(arr.length>0)
			{
				this.view.FriendInfo.RequestList.visible=true;
				this.view.FriendInfo.RequestList.itemRender=FriendRequestCell;
				this.view.FriendInfo.RequestList.vScrollBarSkin = "";
				this.view.FriendInfo.RequestList.selectEnable = true;
				this.view.FriendInfo.RequestList.selectHandler=new Handler(this, onRequestSelect);
				this.view.FriendInfo.RequestList.array=arr;	
			}
			else
			{
				this.view.FriendInfo.RequestList.visible=false;
			}
		}
		
		private function onRequestSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			
		}		
		
		/**
		 * 添加监听
		 */
		override public function addEvent():void
		{
			super.addEvent();
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETNAIL),this,onResult,[ServiceConst.FRIEND_GETNAIL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_READMAIL),this,onResult,[ServiceConst.FRIEND_READMAIL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETATTACHMENT),this,onResult,[ServiceConst.FRIEND_GETATTACHMENT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_TAKEALL),this,onResult,[ServiceConst.FRIEND_TAKEALL]);
			
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST),this,onResult,[ServiceConst.FRIEND_GETREQUEST]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEARCHFRIEND),this,onResult,[ServiceConst.FRIEND_SEARCHFRIEND]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_APPLYFRIEND),this,onResult,[ServiceConst.FRIEND_APPLYFRIEND]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST),this,onResult,[ServiceConst.FRIEND_GETFRIENDLIST]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND),this,onResult,[ServiceConst.FRIEND_MANAGEFRIEND]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SENDCHAT),this,onResult,[ServiceConst.FRIEND_SENDCHAT]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT),this,onResult,[ServiceConst.FRIEND_GETCHAT]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_DELETEFRIEND),this,onResult,[ServiceConst.FRIEND_DELETEFRIEND]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GATCHATLIST),this,onResult,[ServiceConst.FRIEND_GATCHATLIST]);
			
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		
		/**
		 * 接受服务器消息
		 */
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd){
				case ServiceConst.FRIEND_GETNAIL:
					var l_info:Object=args[1];
					if(parseInt(l_info.mail_type)==m_mailType)
					{
						if(m_mailPage==1)
						{
							m_friendVo.setMailInfo(l_info);
							this.view.MailList.scrollTo(1);
							this.view.MailList.scrollBar.value=0;
							setMailList();
						}
						else
						{
							m_friendVo.addMailInfo(l_info);
							this.view.MailList.array=m_friendVo.MailInfoList;
							this.view.MailList.scrollTo(30*(m_mailPage-1));
						}
					}
					break;
				case ServiceConst.FRIEND_GETREQUEST:
					var l_uid:String=args[1];
					var l_playerName:String=args[2];
					var l_vo:FriendVo=new FriendVo();
					l_vo.uid=l_uid;
					l_vo.name=l_playerName;
					m_friendVo.RequestFriendList.push(l_vo);
					if(m_stage==3)
					{
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					}
					break;
				case ServiceConst.FRIEND_READMAIL:
//					
					break;
				case ServiceConst.FRIEND_GETREQUESTAPPLY:
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					break;
				case ServiceConst.FRIEND_GETATTACHMENT:
					var l_obj:Object=args[1];
					this.view.MailList.refresh();
					var item:MailInfoView=new MailInfoView(this.view.MainInfo,m_mailVo);
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[m_mailVo.getItemList()]);
					break;
				case ServiceConst.FRIEND_SEARCHFRIEND:
					var l_info:Object=args[1];
					m_friendVo.ApplyFriendList=new FriendVo();
					m_friendVo.ApplyFriendList.name=l_info.name;
					m_friendVo.ApplyFriendList.uid=l_info.uid;
					setRequestList(2);
					break;
				case ServiceConst.FRIEND_APPLYFRIEND:
					setRequestList(1);
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					break;
				case ServiceConst.FRIEND_GETFRIENDLIST:
					var l_info:Object=args[1];
					m_friendVo.setFriendList(l_info);
					if(m_friendType==2)
					{
						m_friendType=2;
						this.m_friendVo.setFriendSetType(m_friendType);
					}
					setFriendList();
					if(m_stage==3)
					{
						setRequestList(1);	
					}
					break;
				case ServiceConst.FRIEND_MANAGEFRIEND:
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					break;
				case ServiceConst.FRIEND_SENDCHAT:
					m_friendVo.ChatList.push(m_chatVo);
					var item:ChatInfoView=new ChatInfoView(this.view.ChatInfo,m_friendVo.ChatList);
					break;
				case ServiceConst.FRIEND_GATCHATLIST:
					var l_info:Object=args[1];
					var l_friendVO:FriendVo=this.view.FriendList.getItem(m_selectCell);
					m_friendVo.setChatList(l_info,l_friendVO);
					if(m_friendVo!=null)
					{
						var item:ChatInfoView=new ChatInfoView(this.view.ChatInfo,m_friendVo.ChatList);
					}
					break
				case ServiceConst.FRIEND_GETCHAT:
					var l_info:Object=args[1];
					var l_vo:ChatVo=new ChatVo();
					l_vo.uid=args[1];
					l_vo.name=args[2];
					l_vo.msg=args[3];
					l_vo.time=args[4];
					m_friendVo.ChatList.push(l_vo);
					m_friendVo.addChatList();
					this.view.ChatRedot.visible=true;
					var item:ChatInfoView=new ChatInfoView(this.view.ChatInfo,m_friendVo.ChatList);
					break;
				case ServiceConst.FRIEND_DELETEFRIEND:
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					m_friendType=2;
					this.m_friendVo.setFriendSetType(m_friendType);
					break;
				case ServiceConst.FRIEND_TAKEALL:
					var l_info:Object=args[1];
					var l_arr:Array=new Array();
					for (var i:String in l_info) 
					{
						var l_itemData:ItemData=new ItemData();
						l_itemData.iid=parseInt(i);
						l_itemData.inum=l_info[i];
						l_arr.push(l_itemData);
					}
					if(l_arr.length>0)
					{
						XFacade.instance.openModule(ModuleName.ShowRewardPanel,[l_arr]);
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETNAIL,[m_mailPage,GameConfigManager.messageConfig.mailNum,m_mailType]);
					break;
			}
			initBtnRetor();
		}
		
		/**
		 * 移除监听
		 */
		override public function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETNAIL),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_READMAIL),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETATTACHMENT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_TAKEALL),this,onResult);
			
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEARCHFRIEND),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_APPLYFRIEND),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SENDCHAT),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_DELETEFRIEND),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GATCHATLIST),this,onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		/**
		 * 按钮事件
		 */
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					(XFacade.instance.getView(MainView) as MainView).updateChatImage();
					this.close();
					break;
				case this.view.CharBtn:
					hasNewMsg = false;
					setBtnType(2);
					break;
				case this.view.MailBtn:
					setBtnType(1);
					break;
				case this.view.FriiendBtn:
					setBtnType(3);
					break;
				case this.view.OkBtn:
					m_friendType=1;
					this.m_friendVo.setFriendSetType(m_friendType);
					this.view.SetBtn.visible=true;
					this.view.OkBtn.visible=false;
					this.view.MaxFriendText.visible=false;
					this.view.FriendText.visible=true;
					this.view.FriendNum.visible=true;
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETFRIENDLIST,[""]);
					break;
				case this.view.SetBtn:
					m_friendType=2;
					this.m_friendVo.setFriendSetType(m_friendType);
					this.view.SetBtn.visible=false;
					this.view.OkBtn.visible=true;
					this.view.MaxFriendText.visible=true;
					this.view.FriendText.visible=false;
					this.view.FriendNum.visible=false;
					setFriendList();
					break;
				case this.view.ServersBtn:
					m_mailType=1;
					m_mailPage=1;
					m_friendVo.newServersNum=0;
					this.view.ServerRedot.visible=false;
					setMailBtnType();
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETNAIL,[1,30,m_mailType]);
					break;
				case this.view.StstemBtn:
					m_mailType=2;
					m_mailPage=1;
					m_friendVo.newStstemNum=0;
					this.view.StstemRedot.visible=false;
					setMailBtnType();
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETNAIL,[1,30,m_mailType]);
					break;
				case this.view.MainInfo.ReceiveBtn:
					if(m_mailVo!=null)
					{
						m_mailVo.state=3;
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_GETATTACHMENT,[m_mailVo.key]);
					}
					break;
				case this.view.FriendInfo.SearchBtn:
					if(this.view.FriendInfo.TextInPutText.text!="")
					{
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_SEARCHFRIEND,[this.view.FriendInfo.TextInPutText.text]);
						this.view.FriendInfo.TextInPutText.text="";
					}
					//WebSocketNetService.instance.sendData(ServiceConst.FRIEND_APPLYFRIEND,[m_friendVo.ApplyFriendList.uid]);
					break;
				case this.view.ChatInfo.SendBtn:
					if(this.view.ChatInfo.TextInPutText.text!=""&&this.view.FriendList.array!=null)
					{
						var l_friendVO:FriendVo=this.view.FriendList.getItem(m_selectCell);
						m_chatVo=new ChatVo();
						m_chatVo.uid=User.getInstance().uid;
						m_chatVo.msg=this.view.ChatInfo.TextInPutText.text;
						m_chatVo.name=User.getInstance().name;
						m_chatVo.time=new Date().getTime();
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_SENDCHAT,[l_friendVO.uid,this.view.ChatInfo.TextInPutText.text]);
						this.view.ChatInfo.TextInPutText.text="";
					}
					break;
				case this.view.TakeAllBtn:
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_TAKEALL,[m_mailType]);
					break;
				case this.view.FriendInfo.inviteBtn:
					XFacade.instance.openModule(ModuleName.InviteFriendsView);
					break;
				default:
				{
					if(e.target.name.indexOf("AgreeBtn")!=-1)
					{
						var l_uid:String=getUid(e.target.name);
						if(m_friendApplyType==1)
						{
							WebSocketNetService.instance.sendData(ServiceConst.FRIEND_MANAGEFRIEND,[l_uid,1]);
						}
						else
						{
							if(m_friendVo.hasFriendById(l_uid)==false)
							{
								WebSocketNetService.instance.sendData(ServiceConst.FRIEND_APPLYFRIEND,[l_uid]);
							}
							else
							{
								AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_3015"),0,function(v:uint):void{
								});
							}
						}
					}
					if(e.target.name.indexOf("RefuseBtn")!=-1)
					{
						var l_uid:String=getUid(e.target.name);
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_MANAGEFRIEND,[l_uid,2]);
					}
					if(e.target.name.indexOf("DeleteFriend")!=-1)
					{
						var l_uid:String=getUid(e.target.name);
						if(l_uid==m_selectFriendId)
						{
							this.view.ChatInfo.ChatList.visible=false;
						}
						WebSocketNetService.instance.sendData(ServiceConst.FRIEND_DELETEFRIEND,[l_uid]);
					}
					break;
				}
			}
		}
		/**
		 * 获取uid
		 */
		private function getUid(p_str:String):String
		{
			var l_arr:Array=p_str.split("_");
			return l_arr[1];
		}
		
		
		/**
		 * 选择邮件种类
		 */
		private function setMailBtnType()
		{
			if(m_mailType==1)
			{
				this.view.ServersBtn.selected=true;
				this.view.StstemBtn.selected=false;
			}
			else
			{
				this.view.ServersBtn.selected=false;
				this.view.StstemBtn.selected=true;
			}	
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function get view():FriendMainViewUI{
			return _view as FriendMainViewUI;
		}
	}
}