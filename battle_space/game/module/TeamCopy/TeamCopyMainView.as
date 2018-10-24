package game.module.TeamCopy
{
	import MornUI.chests.ChestsMainViewUI;
	import MornUI.teamcopy.TeamCopyMainViewUI;
	
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TeamCopyEvent;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.teamCopy.TeamCopyRoomVo;
	import game.global.vo.teamCopy.TeamCopyUnitVo;
	import game.global.vo.teamCopy.TeamCopyVo;
	import game.global.vo.teamCopy.TeamFightBuyVo;
	import game.global.vo.teamCopy.TeamFightLevelVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.Handler;
	
	
	public class TeamCopyMainView extends BaseView
	{
		private var m_teamCopyVo:TeamCopyVo;
		private var m_teamCopyRoomVo:TeamCopyRoomVo;
		
		private var m_joinId:int;
		private var m_RefreshTime:int;
		private var isgoNextWin:Boolean;
		
		
		public function TeamCopyMainView()
		{
			super();
		}
		
		
		override public function show(...args):void
		{
			super.show();
			onStageResize();
			
			isgoNextWin=false;
			m_joinId=0;
			view.RoomRefreshBtn.gray=false;
			view.RoomRefreshBtn.mouseEnabled=true;
			if(args[0]!=null&&args[0]!=undefined)
			{
				m_joinId=args[0];
			}
			else
			{
				m_joinId=0;
			}
			view.IdText.text="";
			WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_INIT,[]);
		}
		
		
		private function initUI():void
		{
			view.RuleText.text=GameLanguage.getLangByKey("L_A_14020");
			view.TiitleText.text=GameLanguage.getLangByKey("L_A_490");
			view.CreationBtn.text.text=GameLanguage.getLangByKey("L_A_14014");
			view.AutoJoinBtn.text.text=GameLanguage.getLangByKey("L_A_14011");
			view.RoomRefreshBtn.text.text=GameLanguage.getLangByKey("L_A_14010");
			view.RestrictionsText.text=GameLanguage.getLangByKey("L_A_14016");
			view.RefreshBtn.text.text=GameLanguage.getLangByKey("L_A_14010");
			view.LevelRequipText.text=GameLanguage.getLangByKey("L_A_14015");
			view.AliaceBonusText.text=GameLanguage.getLangByKey("L_A_14018");
			view.RequireText.text=GameLanguage.getLangByKey("L_A_14012");
			view.TipsImage.visible=false;
			
			view.TipsText.text=GameLanguage.getLangByKey("L_A_14045");
			if(m_joinId!=0)
			{
				WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_JOINROOM,[m_joinId]);	
			}
			initLevel();
			initRoomList();
			timer.loop(5000,this,updateRoomList);
			
		}
		
		private function updateRoomList():void
		{
			// TODO Auto Generated method stub
			var l_str:String="";
			for (var i:int = 0; i < m_teamCopyVo.roomList.length; i++) 
			{
				var l_vo:TeamCopyRoomVo=m_teamCopyVo.roomList[i];
				if(l_str=="")
				{
					l_str+=l_vo.room_id;
				}
				else
				{
					l_str+="-"+l_vo.room_id;
				}
			}
			WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_REFRESHROOMLIST,[l_str]);
		}
		
		private function initLevel():void
		{
			var levelVo:TeamFightLevelVo=m_teamCopyVo.getLevelVo();
			view.LevelText.text=levelVo.xsdj;
			view.RestrictionsUseText.text=GameLanguage.getLangByKey(levelVo.rq_text1);
			view.RewardList.itemRender=ItemCell3;
			view.SoldierList.itemRender=ItemCell3;
			view.RewardList.array=levelVo.getRewardList();
			view.SoldierList.array=levelVo.getGuildRewardList();
			
			var l_vo:TeamFightBuyVo=GameConfigManager.TeamFightBuyList[1];
			var l_arr:Array=l_vo.price.split("=");
			if(GameConfigManager.teamFightParamVo.getRewardTime()<m_teamCopyVo.combat_number)
			{
				view.NumText.text="0/"+GameConfigManager.teamFightParamVo.getRewardTime();
				view.CreationBtn.disabled = true;
			}
			else
			{
				view.NumText.text=GameConfigManager.teamFightParamVo.getRewardTime()-m_teamCopyVo.combat_number+"/"+GameConfigManager.teamFightParamVo.getRewardTime();
			}
			if(levelVo.double==1)
			{
				view.DoubleImage.visible=true;
			}
			else
			{
				view.DoubleImage.visible=false;
			}
		}
		
		private function initRoomList():void
		{
			view.RoomList.itemRender=TeamCopyRoomInfoCell;
			view.RoomList.array=m_teamCopyVo.roomList;
			if(m_teamCopyVo.roomList.length>0)
			{
				view.TipsImage.visible=false;
			}
			else
			{
				view.TipsImage.visible=true;
			}
		}
		
		override public function onStageResize():void{
			var dw:Number = this.view.contentBox.width*this.view.contentBox.scaleX;
			var dy:Number = this.view.contentBox.height*this.view.contentBox.scaleY;
			this.view.contentBox.pos((Laya.stage.width-dw)/2,(Laya.stage.height-dy)/2+20);
			this.view.width = Laya.stage.width;
			this.view.height = Laya.stage.height;
			
			this.view.TiitleText.x = (Laya.stage.width-this.view.TiitleText.width)/2;
			this.view.bgBar.width = Laya.stage.width;
			this.view.CloseBtn.x = Laya.stage.width - this.view.CloseBtn.width;
				
			var delScale:Number = LayerManager.fixScale;
			if(delScale > 1){
				this.view.bg.scale(delScale,delScale);
				dw = view.bg.width*view.bg.scaleX;
				dy = view.bg.height*view.bg.scaleY;
				this.view.bg.pos((Laya.stage.width-dw)/2,(Laya.stage.height-dy)/2);
			}
		}
		
		override public function addEvent():void
		{
			this.on(Event.CLICK, this, this.onClickHandler);
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_JOIN,this,onJoinHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_REFRESHROOMLIST),this,onResult,[ServiceConst.TEAMCOPY_REFRESHROOMLIST]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_INIT),this,onResult,[ServiceConst.TEAMCOPY_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_REFRESH),this,onResult,[ServiceConst.TEAMCOPY_REFRESH]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_CREATEROOM),this,onResult,[ServiceConst.TEAMCOPY_CREATEROOM]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCORY_JOINROOM),this,onResult,[ServiceConst.TEAMCORY_JOINROOM]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCORY_SEARCHROOM),this,onResult,[ServiceConst.TEAMCORY_SEARCHROOM]);
		}
		
		private function onJoinHandler(p_data:TeamCopyRoomVo):void
		{
			// TODO Auto Generated method stub
			if(m_teamCopyVo.combat_number<parseInt(GameConfigManager.teamFightParamVo.masterRewardTime))
			{
				WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_JOINROOM,[p_data.room_id]);
			}
			else
			{
				XTip.showTip(GameLanguage.getLangByKey("L_A_14043"));
//				XFacade.instance.openModule(ModuleName.TeamCopyTipsView,[m_teamCopyVo.combat_number,p_data.room_id]);
			}
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_REFRESHROOMLIST),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_INIT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_REFRESH),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_CREATEROOM),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCORY_JOINROOM),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCORY_SEARCHROOM),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_JOIN,this,onJoinHandler);
		}
		
		/**初始化UI*/
		override public function createUI():void
		{
			super.createUI();
			GameConfigManager.intance.InitTeamCopyParam();
			this._view = new TeamCopyMainViewUI();
			this.addChild(_view);
			view.guideArea.mouseEnabled = false;
			UIRegisteredMgr.AddUI(view.roomInfoArea, "TeamRoomInfoArea");
			UIRegisteredMgr.AddUI(view.timeArea, "TeamFightTimeArea");
			UIRegisteredMgr.AddUI(view.RoomList, "TeamRoomList");
			UIRegisteredMgr.AddUI(view.searchArea, "TeamRoomSearch");
			UIRegisteredMgr.AddUI(view.CloseBtn, "TeamRoomBtnClose");
			if(GameSetting.IsRelease){
				view.contentBox.scale(0.96, 0.96);
			}
		}
		
		/**
		 * 
		 */
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case view.CloseBtn:
				{
					this.close();
					if (SceneManager.intance.currSceneName != SceneType.M_SCENE_HOME) {
						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
					}
					break;
				}
				case view.AutoJoinBtn:
				{
					if(m_teamCopyVo.combat_number<parseInt(GameConfigManager.teamFightParamVo.masterRewardTime))
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_SEARCHROOM,[]);
					}
					else
					{
						XFacade.instance.openModule(ModuleName.TeamCopyTipsView,[m_teamCopyVo.combat_number,""]);
					}
					break;
				}
				case view.CreationBtn:
				{
					var l_vo:TeamFightBuyVo=GameConfigManager.TeamFightBuyList[1];
					var l_arr:Array=l_vo.price.split("=");
					var costNum:int=parseInt(l_arr[1]);
					var maxNum:int=BagManager.instance.getItemNumByID(l_arr[0]);
					if(m_teamCopyVo.combat_number<parseInt(GameConfigManager.teamFightParamVo.masterRewardTime))
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_CREATEROOM,[]);
					}
					else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_14043"));
					}
					break;
				}
				case view.RefreshBtn:
				{
					if(m_teamCopyVo.refresh_number>=GameConfigManager.teamFightParamVo.freeRefreshTime)
					{
						var l_arr:Array=m_teamCopyVo.getRefreshCost(m_teamCopyVo.refresh_number+1);
						var itemD:ItemData=new ItemData();
						itemD.iid=l_arr[0];
						itemD.inum=l_arr[1];
						
						XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_14025"),
							l_arr[0],
							l_arr[1],
							function(){
								if(User.getInstance().water>=itemD.inum)
								{
									WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_REFRESH,[]);
								}
								else
								{
									XFacade.instance.openModule(ModuleName.ChargeView);
								}
						}]);
					}
					else
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_14025"),
							0,
							0,
							function(){									
								WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_REFRESH,[]); }]);
					}
					
					break;
				}
				case view.SearchBtn:
				{
					if(view.IdText.text!="")
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_JOINROOM,[view.IdText.text]);
					}
					break;
				}
				case view.RoomRefreshBtn:
				{
					WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_REFRESHROOMLIST,[]);
					m_RefreshTime=3;
					view.RoomRefreshBtn.mouseEnabled=false;
					this.timer.loop(1000,this,updateRefreshHandler);
					
					break;
				}
				default:
				{
					break;
				}
			}
		}		
		
		private function updateRefreshHandler():void
		{
			// TODO Auto Generated method stub
			if(m_RefreshTime>0)
			{
				view.RoomRefreshBtn.text.text=m_RefreshTime;
				m_RefreshTime--;
				view.RoomRefreshBtn.gray=true;
				view.RoomRefreshBtn.mouseEnabled=false;
			}
			else
			{
				this.timer.clear(this,updateRefreshHandler);
				view.RoomRefreshBtn.gray=false;
				view.RoomRefreshBtn.mouseEnabled=true;
				m_RefreshTime=0;
				view.RoomRefreshBtn.text.text=GameLanguage.getLangByKey("L_A_14010");
			}
		}
		
		private function gotoFightHandler():void
		{
			// TODO Auto Generated method stub
			XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
			WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_CREATEROOM,[]);
		}
		
		private function gotoSendStartBack():void
		{
			// TODO Auto Generated method stub
			
			XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
			
			WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_REFRESH,[]);
		}
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.TEAMCOPY_INIT:
				{
					var l_obj:Object=args[1];
					m_teamCopyVo=new TeamCopyVo();
					m_teamCopyVo.stage_id=l_obj.play_info.stage_id;
					m_teamCopyVo.buy_combat_number=l_obj.play_info.buy_combat_number;
					m_teamCopyVo.combat_number=l_obj.play_info.combat_number;
					m_teamCopyVo.refresh_number=l_obj.play_info.refresh_number;
					m_teamCopyVo.refresh_time=l_obj.play_info.refresh_time;
					m_teamCopyVo.room_id=l_obj.play_info.room_id;
					m_teamCopyVo.room_list_id=l_obj.play_info.room_list_id;
					m_teamCopyVo.setRoomList(l_obj.room_list);
					initUI();
					break;
				}
				case ServiceConst.TEAMCORY_JOINROOM:
				{
					var l_obj:Object=args[1];
					m_teamCopyRoomVo=new TeamCopyRoomVo();
					m_teamCopyRoomVo.stage_id=l_obj.base_info.stage_id;
					m_teamCopyRoomVo.room_id=l_obj.base_info.room_id;
					m_teamCopyRoomVo.room_level=l_obj.base_info.room_level;
					m_teamCopyRoomVo.room_list_id=l_obj.base_info.room_list_id;
					
					var isMaster:Boolean=false;
					if(m_teamCopyRoomVo.room_id==User.getInstance().uid)
					{
						isMaster=true;
					}
					m_teamCopyRoomVo.isMaster=false;
					
					for each (var i:Object in l_obj) 
					{
						var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
						if(i.unit_list!=undefined)
						{
							if(i.uid==User.getInstance().uid&&i.master==1)
							{
								isMaster=true;
								m_teamCopyRoomVo.isMaster=true;
							}
							l_teamCopyUnitVo.master=i.master;
							l_teamCopyUnitVo.state=i.state;
							l_teamCopyUnitVo.level=i.level;
							l_teamCopyUnitVo.uid=parseInt(i.uid);
							l_teamCopyUnitVo.seTeamSoldier(i.unit_list);
							l_teamCopyUnitVo.user_name=i.user_name;
							l_teamCopyUnitVo.userIsMaster=isMaster;
							m_teamCopyRoomVo.teamList.push(l_teamCopyUnitVo);
						}
					}
					XFacade.instance.openModule(ModuleName.TeamCopyRoomView,m_teamCopyRoomVo);
					isgoNextWin=true;
					this.close();
					break;
				}
				case ServiceConst.TEAMCOPY_REFRESH:
				{
					var l_obj:Object=args[1];
					m_teamCopyVo.stage_id=l_obj.stage_id;
					m_teamCopyVo.buy_combat_number=l_obj.buy_combat_number;
					m_teamCopyVo.combat_number=l_obj.combat_number;
					m_teamCopyVo.refresh_number=l_obj.refresh_number;
					m_teamCopyVo.refresh_time=l_obj.refresh_time;
					m_teamCopyVo.room_id=l_obj.room_id;
					m_teamCopyVo.room_list_id=l_obj.room_list_id;
					initUI();
					break;
				}
				case ServiceConst.TEAMCORY_SEARCHROOM:
				{
					var l_obj:Object=args[1];
					m_teamCopyRoomVo=new TeamCopyRoomVo();
					m_teamCopyRoomVo.stage_id=l_obj.base_info.stage_id;
					m_teamCopyRoomVo.room_id=l_obj.base_info.room_id;
					m_teamCopyRoomVo.room_level=l_obj.base_info.room_level;
					m_teamCopyRoomVo.room_list_id=l_obj.base_info.room_list_id;
					
					var isMaster:Boolean=false;
					m_teamCopyRoomVo.isMaster=false;
					
					for each (var i:Object in l_obj) 
					{
						var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
						if(i.unit_list!=undefined)
						{
							if(i.uid==User.getInstance().uid&&i.master==1)
							{
								isMaster=true;
								m_teamCopyRoomVo.isMaster=true;
							}
							l_teamCopyUnitVo.master=i.master;
							l_teamCopyUnitVo.state=i.state;
							l_teamCopyUnitVo.level=i.level;
							l_teamCopyUnitVo.uid=parseInt(i.uid);
							l_teamCopyUnitVo.seTeamSoldier(i.unit_list);
							l_teamCopyUnitVo.user_name=i.user_name;
							l_teamCopyUnitVo.userIsMaster=isMaster;
							m_teamCopyRoomVo.teamList.push(l_teamCopyUnitVo);
						}
					}
					XFacade.instance.openModule(ModuleName.TeamCopyRoomView,m_teamCopyRoomVo);
					isgoNextWin=true;
					this.close();
					break;
				}
				case ServiceConst.TEAMCOPY_REFRESHROOMLIST:
				{
					var l_obj:Object=args[1];
					m_teamCopyVo.setRoomList(l_obj);
					initUI();
					break;
				}
				
				case ServiceConst.TEAMCOPY_CREATEROOM:
				{
					var l_obj:Object=args[1];
					m_teamCopyRoomVo=new TeamCopyRoomVo();
					m_teamCopyRoomVo.stage_id=l_obj.base_info.stage_id;
					m_teamCopyRoomVo.room_id=l_obj.base_info.room_id;
					m_teamCopyRoomVo.room_level=l_obj.base_info.room_level;
					m_teamCopyRoomVo.room_list_id=l_obj.base_info.room_list_id;
					var isMaster:Boolean=false;
					m_teamCopyRoomVo.isMaster=false;
					for each (var i:Object in l_obj) 
					{
						var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
						if(i.unit_list!=undefined)
						{
							if(i.uid==User.getInstance().uid&&i.master==1)
							{
								isMaster=true;
								m_teamCopyRoomVo.isMaster=true;
							}
							l_teamCopyUnitVo.master=i.master;
							l_teamCopyUnitVo.state=i.state;
							l_teamCopyUnitVo.level=i.level;
							l_teamCopyUnitVo.uid=parseInt(i.uid);
							l_teamCopyUnitVo.seTeamSoldier(i.unit_list);
							l_teamCopyUnitVo.user_name=i.user_name;
							l_teamCopyUnitVo.userIsMaster=isMaster;
							m_teamCopyRoomVo.teamList.push(l_teamCopyUnitVo);
						}
					}
					m_joinId=0;
					isgoNextWin=true;
					XFacade.instance.openModule(ModuleName.TeamCopyRoomView,m_teamCopyRoomVo);
					isgoNextWin=true;
					this.close();
					break;
				}
			}
		}
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		
		override public function dispose():void{
			if(isgoNextWin==false)
			{
				super.dispose();
			}
			UIRegisteredMgr.DelUi("TeamRoomInfoArea");
			UIRegisteredMgr.DelUi("TeamFightTimeArea");
			UIRegisteredMgr.DelUi("TeamRoomList");
			UIRegisteredMgr.DelUi("TeamRoomSearch");
			UIRegisteredMgr.DelUi("TeamRoomBtnClose");
		}
		
		override public function close():void
		{
			timer.clearAll(this);
			super.close();
			
		}
		
		
		private function get view():TeamCopyMainViewUI
		{
			return this._view as TeamCopyMainViewUI;		
		}
	}
}