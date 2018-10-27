package game.module.TeamCopy
{
	import MornUI.teamcopy.TeamCopyRoomViewUI;
	
	import game.common.DataLoading;
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnitStar;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.event.Signal;
	import game.global.event.TeamCopyEvent;
	import game.global.util.TimeUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.global.vo.teamCopy.TeamCopyChatVo;
	import game.global.vo.teamCopy.TeamCopyRoomVo;
	import game.global.vo.teamCopy.TeamCopySoldierVo;
	import game.global.vo.teamCopy.TeamCopyUnitVo;
	import game.global.vo.teamCopy.TeamFightLevelVo;
	import game.global.vo.teamCopy.TeamFightUnitVo;
	import game.module.camp.CampData;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 *  两个邀请好友的按钮界面
	 * @author mutantbox
	 * 
	 */
	public class TeamCopyRoomView extends BaseView
	{
		private var m_teamCopyUnitVo:TeamCopyUnitVo;
		private var m_teamCopyRoomVo:TeamCopyRoomVo;
		private var m_selectIndex:int;
		private var m_selectHero:Boolean;
		private var m_chatList:Array;
		private var m_maxy:int;
		private var m_chatCellList:Array;
		private var m_index:int;
		private var isgoNextWin:Boolean;
		private var m_chat:TeamCopyChatVo;
		
		/**邀请好友按钮防高频率点击（左边一个按钮）*/
		private var clearLimitInviteFunc:Function = null;
		
		public function TeamCopyRoomView()
		{
			super();
//			_m_iLayerType = LayerManager.M_TOP;
		}
		
		/**初始化UI*/
		override public function createUI():void
		{
			GameConfigManager.intance.InitTeamCopyParam();
			this._view = new TeamCopyRoomViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			m_teamCopyRoomVo=args[0];
			m_chatList=new Array();
			m_chatCellList=new Array();
			isgoNextWin=false;
			super.show();
			onStageResize();
			m_maxy=0;
			WebSocketNetService.instance.sendData(ServiceConst.C_INFO,[]);
		}
		
		private function initUI():void
		{
			view.RestrictionsText.text=GameLanguage.getLangByKey("L_A_14016");
			view.LevelRequipText.text=GameLanguage.getLangByKey("L_A_14015");
			view.TitleText.text=GameLanguage.getLangByKey("L_A_490");
			view.ChatPanel.selected=true;
			view.ChatPanel.vScrollBarSkin="";
			m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
			var levelVo:TeamFightLevelVo=m_teamCopyRoomVo.getLevelVo();
			view.LevelText.text=levelVo.xsdj;
			view.RestrictionsUseText.text=GameLanguage.getLangByKey(levelVo.rq_text1);
			view.RewardList.itemRender=ItemCell3;
			view.SoldierList.itemRender=ItemCell3;
			view.RewardList.array=levelVo.getRewardList();
			view.SoldierList.array=levelVo.getGuildRewardList();
			view.RoomNumText.text=m_teamCopyRoomVo.room_id;
			view.ChatText.maxChars=GameConfigManager.teamFightParamVo.chatMax;
			if(levelVo.double==1)
			{
				view.DoubleImage.visible=true;
			}
			else
			{
				view.DoubleImage.visible=false;
			}
			this.view.SelectSoldierList.itemRender=TeamCopySoldierCell;
			this.view.SelectSoldierList.hScrollBarSkin="";
			this.view.SelectSoldierList.selectEnable=true;
			if(m_teamCopyRoomVo.isMaster==true)
			{
				this.view.StartBtn.visible=true;
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(-1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
			else
			{
				this.view.StartBtn.visible=false;
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
			
			view.SelectTab.selectedIndex=0;
			this.view.SelectSoldierList.selectHandler=new Handler(this,onSelectSoldierHandler);
			if(m_teamCopyRoomVo.isMaster==true)
			{
				var l_str:String="";
				l_str=GameLanguage.getLangByKey("L_A_34089");
				l_str+=","+GameLanguage.getLangByKey("L_A_34076");
				l_str+=","+GameLanguage.getLangByKey("L_A_34077");
				l_str+=","+GameLanguage.getLangByKey("L_A_34078");
				l_str+=","+GameLanguage.getLangByKey("L_A_34079");
				l_str+=","+GameLanguage.getLangByKey("L_A_34080");
	
				view.SelectTab.labels=l_str;
			}
			else
			{
				var l_str:String="";
				l_str=GameLanguage.getLangByKey("L_A_34089");
				l_str+=","+GameLanguage.getLangByKey("L_A_34077");
				l_str+=","+GameLanguage.getLangByKey("L_A_34078");
				l_str+=","+GameLanguage.getLangByKey("L_A_34079");
				l_str+=","+GameLanguage.getLangByKey("L_A_34080");
				view.SelectTab.labels=l_str;
			}
			view.SelectTab.selectHandler=new Handler(this, onHeroSelect); 
			this.view.SelectSoldierBox.visible=false;
			initList();
		}
		
		private function onSelectSoldierHandler(p_index:int):void
		{
			// TODO Auto Generated method stub
			var l_object:TeamFightUnitVo;
			l_object=this.view.SelectSoldierList.getItem(p_index);
			if(l_object)
			{
				var l_vo:TeamCopySoldierVo=new TeamCopySoldierVo();
				l_vo.unitId=l_object.baseInfo.unitId;
				var vo:Object;
				vo = DBUnitStar.getStarData(l_object.baseInfo.starId);
				l_vo.starLevel=l_object.baseInfo.starId;
				l_vo.level=l_object.baseInfo.level;
				l_vo.isOwn=true;
				var fightvo:FightUnitVo=GameConfigManager.unit_json[l_object.id];
				var rebornTime:int = l_object.baseInfo.cdTime*1000 - TimeUtil.now;
				
				if(l_object.conform==false)
				{
					XTip.showTip(GameLanguage.getLangByKey("L_A_14049"));
				}
				else if(l_object.num<=0&&fightvo.unit_type==2)
				{
					XTip.showTip(GameLanguage.getLangByKey("L_A_14048"));
				}
				else if(l_object.baseInfo.used!=0&&fightvo.unit_type==1)
				{
					XTip.showTip("英雄正在其他地方使用");
				}
				else if(rebornTime>0)
				{
//					XTip.showTip("英雄已死亡需要复活");
				}
				else
				{
					if(hasHero(l_vo)==true)
					{
						XTip.showTip("L_A_162");
					}
					else
					{
						m_teamCopyRoomVo.setSoldier(m_selectIndex,l_vo);
						this.view.SelectSoldierBox.visible=false;
					}
					initList();
				}
				
			}
			this.view.SelectSoldierList.selectedIndex=-1;
		}

		private function hasHero(p_vo:TeamCopySoldierVo):void
		{
			m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
			var fightvo1:FightUnitVo=GameConfigManager.unit_json[p_vo.unitId];
			for (var i:int = 0; i < m_teamCopyUnitVo.unit_list.length; i++) 
			{
				var l_vo:TeamCopySoldierVo=m_teamCopyUnitVo.unit_list[i];
				if(l_vo!=null)
				{
					var fightvo:FightUnitVo=GameConfigManager.unit_json[l_vo.unitId];
					if(fightvo.unit_type==1  &&fightvo1.unit_type==1)
					{
						return true;
					}
					
				}
			}
			return false;
		}
		
		
		
		private function onHeroSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
			var levelVo:TeamFightLevelVo=m_teamCopyRoomVo.getLevelVo();
			m_selectHero=true;
			m_index=p_index;
			if(p_index==0)
			{
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(-1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
			else if(p_index==1)
			{
				if(m_teamCopyRoomVo.isMaster==true)
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
				else
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
			}
			else if(p_index==2)
			{
				if(m_teamCopyRoomVo.isMaster==true)
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
				else
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,2,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
			}
			else if(p_index==3)
			{
				if(m_teamCopyRoomVo.isMaster==true)
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,2,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
				else
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,3,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
			}
			else if(p_index==4)
			{
				if(m_teamCopyRoomVo.isMaster==true)
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,3,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
				else
				{
					this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,4,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
				}
			}
			else
			{
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,4,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
		}
		
		private function initList():void
		{
			m_teamCopyRoomVo.setSort();
			view.TeamList.itemRender=TeamCopyCell;
			view.TeamList.array=m_teamCopyRoomVo.teamList;
			view.TeamList.refresh();
			var levelVo:TeamFightLevelVo=m_teamCopyRoomVo.getLevelVo();
			m_selectHero=false;
			if(m_teamCopyRoomVo.isMaster==true) {
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(-1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
			else
			{
				this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
			}
			view.SelectTab.selectedIndex=0;
		}
		
		override public function onStageResize():void{
			if(GameSetting.isIPhoneX){
				this.view.TitleText.x = (Laya.stage.width-this.view.TitleText.width)/2;
				this.view.bgBar.width = Laya.stage.width;
				this.view.CloseBtn.x = Laya.stage.width - this.view.CloseBtn.width;
				this.view.bgUnit.width = Laya.stage.width;
				this.view.SelectSoldierList.width = (Laya.stage.width-5)/this.view.SelectSoldierList.scaleX;
				this.view.width = Laya.stage.width;
			}
			
			var dw:Number;
			var dy:Number = this.view.contentBox.height*this.view.contentBox.scaleY;
			this.view.contentBox.y = (Laya.stage.height-dy)/2+10;
			this.view.height = Laya.stage.height;
			this.view.rightBox.x = Laya.stage.width - this.view.rightBox.width;
				
			this.view.SelectSoldierBox.y = Laya.stage.height - this.view.SelectSoldierBox.height;
			
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
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_UNITCELL,this,onSelectHeroCell);
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_READY,this,onReadyHandler);
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_UN_UNITCELL,this,onUnSelectHeroCell);
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_BOOT,this,onBootHander);
			Signal.intance.on(TeamCopyEvent.TEAMCOPY_CLICK_AUTO,this,onAutoHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIGHTING_ARMY_CD_CONST),this,onResult,[ServiceConst.FIGHTING_ARMY_CD_CONST]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult,[ServiceConst.C_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_BATTLEROOMDISSOLVE),this,onResult,[ServiceConst.TEAMCOPY_BATTLEROOMDISSOLVE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_EXPELPLAYER),this,onResult,[ServiceConst.TEAMCOPY_EXPELPLAYER]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERCHATINFO),this,onResult,[ServiceConst.TEAMCOPY_PLAYERCHATINFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERREADY),this,onResult,[ServiceConst.TEAMCOPY_PLAYERREADY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_UPDATEROOM),this,onResult,[ServiceConst.TEAMCOPY_UPDATEROOM]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_BATTLEFIELDREPORT),this,onResult,[ServiceConst.TEAMCOPY_BATTLEFIELDREPORT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_LEAVE),this,onResult,[ServiceConst.TEAMCOPY_LEAVE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_ROOMCHAT),this,onResult,[ServiceConst.TEAMCOPY_ROOMCHAT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_INVITE),this,onResult,[ServiceConst.TEAMCOPY_INVITE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_STARTFIGHT),this,onResult,[ServiceConst.TEAMCOPY_STARTFIGHT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERENTERINTO),this,onResult,[ServiceConst.TEAMCOPY_PLAYERENTERINTO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERLEAVE),this,onResult,[ServiceConst.TEAMCOPY_PLAYERLEAVE]);
			
			
		}
		
		private function onAutoHandler(p_data:TeamCopyUnitVo):void
		{
			var levelVo:TeamFightLevelVo=m_teamCopyRoomVo.getLevelVo();
			m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
			m_teamCopyUnitVo.unit_list=new Array();
			var l_arr:Array=new Array();
			// TODO Auto Generated method stub
			for (var i:int = 0; i < 3; i++) 
			{
				m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
				var l_vo:TeamCopySoldierVo;
				var vo:Object=new Object();
				var l_object:Object=CampData.autoBattleHandler((i+1),levelVo.rq_second1,l_arr,m_teamCopyRoomVo.isMaster);
				//上阵限制
				if(!m_teamCopyRoomVo.checkCanUp(l_object)){
					for(var j=0; j<5; j++){
						l_object=CampData.autoBattleHandler((i+1),levelVo.rq_second1,l_arr,m_teamCopyRoomVo.isMaster,j+1);
						if(m_teamCopyRoomVo.checkCanUp(l_object)){
							break;
						}
					}
				}
				if(l_object)
				{
					l_vo=new TeamCopySoldierVo();
					vo = DBUnitStar.getStarData(l_object.starId);
					l_vo.unitId=l_object.unitId;
					l_vo.starLevel=l_object.starId;
					l_vo.level=l_object.level;
					l_vo.isOwn=true;
					l_arr.push(l_vo);
					m_teamCopyRoomVo.setSoldier(i,l_vo);
				}
				
			}
			initList();
		}
		
		private function onBootHander(p_data:TeamCopyUnitVo):void
		{
			// TODO Auto Generated method stub
			WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_EXPELPLAYER,[m_teamCopyRoomVo.room_id,p_data.uid]);
			var l_TeamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
			m_teamCopyRoomVo.LeaveTeamList(p_data.uid);
			initList();
		}
		
		private function onUnSelectHeroCell(p_index:int):void
		{
			// TODO Auto Generated method stub
			m_selectIndex=p_index;
			m_teamCopyRoomVo.setSoldier(m_selectIndex,null);
			initList();
		}		
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_BATTLEROOMDISSOLVE),this,onResult);
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_AUTO,this,onAutoHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FIGHTING_ARMY_CD_CONST),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_LEAVE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_ROOMCHAT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_STARTFIGHT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_INVITE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERENTERINTO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERLEAVE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_UPDATEROOM),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_BATTLEFIELDREPORT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERCHATINFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_PLAYERREADY),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TEAMCOPY_EXPELPLAYER),this,onResult);
			
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_UNITCELL,this,onSelectHeroCell);
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_READY,this,onReadyHandler);
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_UN_UNITCELL,this,onUnSelectHeroCell);
			Signal.intance.off(TeamCopyEvent.TEAMCOPY_CLICK_BOOT,this,onBootHander);
		}
		
		private function onSelectHeroCell(p_index:int):void
		{
			m_selectIndex=p_index;
			// TODO Auto Generated method stub
			this.view.SelectSoldierBox.visible=true;
			this.view.SelectSoldierList.mouseEnabled=true;
		}
		
		private function onReadyHandler(p_data:TeamCopyUnitVo):void
		{
			// TODO Auto Generated method stub
			if(p_data.state==0)
			{
				var l_soldierStr:String="";
				for(var i:int=0;i<p_data.unit_list.length;i++)
				{
					if(l_soldierStr==""&&p_data.unit_list[i]!=null)
					{
						l_soldierStr+=p_data.unit_list[i].unitId;
					}
					else if(p_data.unit_list[i]!=null)
					{
						l_soldierStr+="-"+p_data.unit_list[i].unitId;
					}
				}
				WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_UPDATEROOM,[m_teamCopyRoomVo.room_id,1,l_soldierStr]);
			}
			else
			{
				WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_UPDATEROOM,[m_teamCopyRoomVo.room_id,0]);
			}
		}
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case view.CloseBtn:
				{
					WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_LEAVE,[m_teamCopyRoomVo.room_id]);
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					isgoNextWin=true;
					this.close();
					break;
				}
				case view.SendBtn:
				{
					if(view.ChatText.text!=""&&view.ChatText.text!=" ")
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_ROOMCHAT,[m_teamCopyRoomVo.room_id,view.ChatText.text]);
						m_chat=new TeamCopyChatVo();
						m_chat.uid=User.getInstance().uid;
						m_chat.user_name=User.getInstance().name;
						m_chat.msg=view.ChatText.text;
						
					}
					else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_14051"));
					}
					break;
				}
				
				//左边邀请按钮
				case view.InviteBtn:
				{
					//取消必须首先加入公会的限制
//					if(User.getInstance().guildID)
//					{
//						WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_INVITE, [m_teamCopyRoomVo.room_id]);
//					}
//					else
//					{
//						XTip.showTip(GameLanguage.getLangByKey("L_A_14047"));
//					}
					
					
					WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_INVITE, [m_teamCopyRoomVo.room_id]);
					break;
				}
				
				//邀请游戏内好友
				case view.btn_inviteGame:
				{
					XFacade.instance.openModule(ModuleName.InviteGameFriends);
					
					break;
				
				}
				case view.StartBtn:
				{
					DataLoading.instance.show();
					WebSocketNetService.instance.sendData(ServiceConst.TEAMCOPY_STARTFIGHT,[m_teamCopyRoomVo.room_id]);
					break;
				}
				case view.SelectSoldierBox:
				{
					this.view.SelectSoldierBox.visible=false;
					this.view.SelectSoldierList.selectedIndex=-1;
					break;
				}
				default:
				{
//					if(m_selectHero==false)
//					{
//						this.view.SelectSoldierBox.visible=false;
//					}
//					m_selectHero=false;
					break;
				}
			}
		}		
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.C_INFO:
				{
					var l_c_info:Object=args[1];
					//更新数据源,不能删
					initUI();
//					trace("后端兵营数据:"+JSON.stringify(l_c_info));
					CampData.update(l_c_info);
					break;
				}
				case ServiceConst.TEAMCOPY_STARTFIGHT:
				{
					
					break;
				}
				
				case ServiceConst.TEAMCOPY_ROOMCHAT:
				{
					initChatPanel(m_chat);
					view.ChatText.text="";
					break;
				}
				case ServiceConst.TEAMCOPY_INVITE:
				{
					XTip.showTip(GameLanguage.getLangByKey("L_A_84452"));
					
					//开启限制频繁发送的限制 15秒
					view.InviteBtn.disabled = true;
					clearLimitInviteFunc = ToolFunc.limitHandler(15, function(time){
						view.InviteBtn.label = time + 's';
					}, function(){
						view.InviteBtn.disabled = false;
						view.InviteBtn.label = GameLanguage.getLangByKey("L_A_14053");;
					})
					
					break;
				}
				case ServiceConst.TEAMCOPY_UPDATEROOM:
				{
						var l_obj:Object=args[1];
						m_teamCopyRoomVo=new TeamCopyRoomVo();
						m_teamCopyRoomVo.stage_id=l_obj.base_info.stage_id;
						m_teamCopyRoomVo.room_id=l_obj.base_info.room_id;
						m_teamCopyRoomVo.room_level=l_obj.base_info.room_level;
						m_teamCopyRoomVo.room_list_id=l_obj.base_info.room_list_id;
						var isMaster:Boolean=false;
						var l_useObj:Object=l_obj[User.getInstance().uid];
						m_teamCopyRoomVo.isMaster=isMaster;
						if(l_useObj.master==1)
						{
							isMaster=true;
							m_teamCopyRoomVo.isMaster=true;
						}

						for each (var i:Object in l_obj) 
						{
							var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
							if(i.unit_list!=undefined)
							{
								l_teamCopyUnitVo.master=i.master;
								l_teamCopyUnitVo.state=i.state;
								l_teamCopyUnitVo.level=i.level;
								l_teamCopyUnitVo.user_name=i.user_name;
								l_teamCopyUnitVo.userIsMaster=isMaster;
								l_teamCopyUnitVo.uid=parseInt(i.uid);
								l_teamCopyUnitVo.seTeamSoldier(i.unit_list);
								m_teamCopyRoomVo.teamList.push(l_teamCopyUnitVo);
							}
						}
						initUI();
					break;
				}
				case ServiceConst.TEAMCOPY_BATTLEFIELDREPORT:
				{
					DataLoading.instance.close();
					var obj:Object = {};
					obj.back =  function():void
					{
//						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
						XFacade.instance.openModule(ModuleName.TeamCopyMainView);
						isgoNextWin=true;
					}
					FightingManager.intance.showFightReport(args[1],args[2],Handler.create(obj,obj.back));
					this.close();
					break;
				}
				case ServiceConst.TEAMCOPY_PLAYERENTERINTO:
				{
					var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
					var l_obj:Object=args[4];
					l_teamCopyUnitVo.userIsMaster=m_teamCopyRoomVo.isMaster;
					l_teamCopyUnitVo.roomId=m_teamCopyRoomVo.room_id;
					l_teamCopyUnitVo.user_name=l_obj.user_name;
					l_teamCopyUnitVo.master=l_obj.master;
					l_teamCopyUnitVo.state=l_obj.state;
					l_teamCopyUnitVo.uid=l_obj.uid;
					l_teamCopyUnitVo.seTeamSoldier(l_obj.unit_list);
					l_teamCopyUnitVo.level=l_obj.level;
					m_teamCopyRoomVo.teamList.push(l_teamCopyUnitVo);
					initList();
					break;
				}
				case ServiceConst.TEAMCOPY_PLAYERLEAVE:
				{
					var l_uid:Number=parseInt(args[1]);
					if(l_uid==User.getInstance().uid)
					{
						XFacade.instance.openModule(ModuleName.TeamCopyMainView);
						isgoNextWin=true;
						close();
					}
					else
					{
						var l_TeamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
						m_teamCopyRoomVo.LeaveTeamList(parseInt(args[1]));
						initList();
					}
					
					break;
				}
				case ServiceConst.TEAMCOPY_BATTLEROOMDISSOLVE:
				{
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					isgoNextWin=true;
					this.close();	
					break;
				}
				case ServiceConst.TEAMCOPY_PLAYERCHATINFO:
				{
//					var l_obj:Object=args[3];
					
					var l_chatVo:TeamCopyChatVo=new TeamCopyChatVo();
					l_chatVo.uid=args[1];
					l_chatVo.user_name=args[2];
					l_chatVo.msg=args[3];
					initChatPanel(l_chatVo);

					break;
				}
				case ServiceConst.TEAMCOPY_PLAYERREADY:
				{
					var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
					var l_obj:Object=args[4];
					l_teamCopyUnitVo.roomId=m_teamCopyRoomVo.room_id;
					l_teamCopyUnitVo.userIsMaster=m_teamCopyRoomVo.isMaster;
					l_teamCopyUnitVo.user_name=l_obj.user_name;
					l_teamCopyUnitVo.master=l_obj.master;
					l_teamCopyUnitVo.state=l_obj.state;
					l_teamCopyUnitVo.uid=l_obj.uid;
					
//					l_teamCopyUnitVo.unit_list=l_obj.unit_list;
					l_teamCopyUnitVo.seTeamSoldier(l_obj.unit_list);
					l_teamCopyUnitVo.level=l_obj.level;
					m_teamCopyRoomVo.updateTeamList(l_teamCopyUnitVo);
					initList();
					break;
				}
				case ServiceConst.TEAMCOPY_EXPELPLAYER:
				{
					
					break;
				}
				case ServiceConst.FIGHTING_ARMY_CD_CONST:
				{
					trace("FIGHTING_ARMY_CD_CONST");
					m_teamCopyUnitVo=m_teamCopyRoomVo.getTeamCopyUnitVo();
					var levelVo:TeamFightLevelVo=m_teamCopyRoomVo.getLevelVo();
					if(m_index==0)
					{
						this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(-1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
					}
					else if(m_index==1)
					{
						if(m_teamCopyRoomVo.isMaster==true)
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(1,-1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
						else
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
					}
					else if(m_index==2)
					{
						if(m_teamCopyRoomVo.isMaster==true)
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,1,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
						else
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,2,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
					}
					else if(m_index==3)
					{
						if(m_teamCopyRoomVo.isMaster==true)
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,2,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
						else
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,3,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
					}
					else if(m_index==4)
					{
						if(m_teamCopyRoomVo.isMaster==true)
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,3,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
						else
						{
							this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,4,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
						}
					}
					else
					{
						this.view.SelectSoldierList.array=CampData.getTeamFightUnitList(2,4,levelVo.rq_second1,m_teamCopyUnitVo.unit_list);
					}
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function initChatPanel(p_chatVo:TeamCopyChatVo):void
		{
			m_chatList.push(p_chatVo);
			var l_cell:TeamCopyChatCell;
			l_cell=new TeamCopyChatCell();
			view.ChatPanel.addChild(l_cell);
			l_cell.dataSource=p_chatVo;
			l_cell.y=m_maxy;
			m_chatCellList.push(l_cell);
			m_maxy+=l_cell.m_ui.InfoText.textHeight+30;
			view.ChatPanel.refresh();
			if(m_maxy>view.ChatPanel.height)
			{
				view.ChatPanel.scrollTo(0,m_maxy);
			}			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void
		{
			for (var i:int = 0; i < m_chatCellList.length; i++) 
			{
				view.ChatPanel.removeChild(m_chatCellList[i]);
			}
			m_chatCellList=new Array();
			
			//清除定时器
			if (clearLimitInviteFunc) {
				clearLimitInviteFunc();
				clearLimitInviteFunc = null;
			}
			
			super.close();
		}
				
		override public function dispose():void
		{
			if(isgoNextWin==false)
			{
				super.dispose();
			}
		}
		
		private function get view():TeamCopyRoomViewUI
		{
			return this._view as TeamCopyRoomViewUI;		
		}
	}
}