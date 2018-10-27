package game.module.guild
{
	import MornUI.guild.GuildInformationViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.mainScene.guest.GuestHomeView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class GuildeInfoView extends BaseView
	{
		
		//private var JOIN_TYPE:Object = { 1:"anyone can join", 2:"need apply", 3:"no apply" };
		public static var JOIN_TYPE:Object = { 1:"L_A_2583", 2:"L_A_2584", 3:"no apply" };
		
		//1 commander 2 decommander 3 officer 4 elite 5 member
		public static var PLACE_NAME:Object = {
			"1" : "L_A_2537", //会长
			"2" : "L_A_2538", // 副会长
			"3" : "L_A_2539", // 军官
			"4" : "L_A_2700", // 精英 
			"5" : "L_A_2540" // 普通成员
		};
		
		
		private var _donateList:Array = [];
		
		public function GuildeInfoView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case this.view.gIconBtn:
					XFacade.instance.openModule(ModuleName.GuildSetLogoView);
					
					break;
				
				// 退出公会
				case this.view.donateBtn:
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_2527"), 0, function(v:int)
					{
						if (v == AlertType.RETURN_YES)
						{
							WebSocketNetService.instance.sendData(ServiceConst.GUILD_QUIT, []);
						}
					})
					break;
				case this.view.editDesBtn:
					XFacade.instance.openModule(ModuleName.GuildIntroChangeView,{intro:view.gDesTF.text});
					break;
				
				case this.view.changeEnterBtn:
					XFacade.instance.openModule(ModuleName.MutilBtnContainer, 
						{ btnNum:2, lableArray:["ANYONE CAN","NEED APPLY"], service:"changeInterType"} 
					);
					break;
				case this.view.changeEnterLvBtn:
					XFacade.instance.openModule(ModuleName.GuildSetLvView,{nowLv:this.view.gClaimLvTF.text.split(".")[1]});
					break;
				default:
					break;
			}
			
		}
		
		public function addToStageRender():void
		{
			var data:GuildMainStateVo = GuildMainView.state;
			User.getInstance().guildLv = data.level;
			User.getInstance().guildExp = data.exp - GameConfigManager.guild_info_vec[data.level - 1].requirement;
			
			GameConfigManager.setGuildLogoSkin(this.view.gIcon, data.icon);
			this.view.gNameTF.text = data.name;
			this.view.gLvTF.text = GameLanguage.getLangByKey("L_A_73") + data.level;
			
			this.view.gExpTF.text = User.getInstance().guildExp + "/" + GameConfigManager.guild_info_vec[data.level].re_qian;
			this.view.expBar.value = User.getInstance().guildExp/GameConfigManager.guild_info_vec[data.level].re_qian;
			
			this.view.gDesTF.text = data.desc;
			this.view.gMemberTF.text = data.members_count + "/"+GameConfigManager.guild_info_vec[data.level].max_member;
			this.view.gJoinType.text = GameLanguage.getLangByKey(JOIN_TYPE[data.join_type]);
			this.view.gClaimLvTF.text = GameLanguage.getLangByKey("L_A_73") + data.join_limit;
			
			_donateList = [];
			//var len:int = data.donate_rank.length;
			for each(var key in data.member_list)
			{
				_donateList.push( { 
					lv:key.level,
					name:key.name,
					uid:key.uid,
					place:GameLanguage.getLangByKey(PLACE_NAME[key.job]),
					last_login: key.last_login,	//最后登录时间
					donate:key.contribution,
					war_score: key.guild_war_score
				})
			}
			view.memberList.array = _donateList;
			
			var isManage:Boolean = User.getInstance().guildJob == 1 || User.getInstance().guildJob == 2;
			view.changeEnterBtn.visible = isManage;
			view.changeEnterLvBtn.visible = isManage;
			view.editDesBtn.visible = isManage;
			view.gIconBtn.visible = isManage;
		}
		
		private function guildEventHandler(cmd:int,...args):void
		{
			switch(cmd)
			{
				case GuildEvent.CHANGE_JOIN_TYPE:
					this.view.gJoinType.text = GameLanguage.getLangByKey(JOIN_TYPE[args[0]]);
					break;
				case GuildEvent.CHANGE_JOIN_LV:
					this.view.gClaimLvTF.text = GameLanguage.getLangByKey("L_A_73")+args[0];
					break;
				case GuildEvent.CHANGE_GUILD_DESC:
					this.view.gDesTF.text = args[0];
					break;
				case GuildEvent.CHANGE_GUILD_ICON:
					GameConfigManager.setGuildLogoSkin(this.view.gIcon, args[0]);
					
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			this.view.gDesTF.wordWrap = true;
			
			view.memberList.itemRender=GuildMemberItem;
			view.memberList.selectEnable = true;
			
//			UIRegisteredMgr.AddUI(view.ginfoarea,"GuildInfoArea");
//			UIRegisteredMgr.AddUI(view.memberList,"GuildMemberArea");
			
			
			// 进入捐献资金
//			UIRegisteredMgr.AddUI(view.donateBtn, "GuildDonateEnter");
			
			addEvent();
			
		}
		
		public function adjustPlaceHandler(...args):void
		{
			switch(args[0])
			{
				case GameLanguage.getLangByKey("L_A_2541"):
					checkPromoteJob(args[1]);
					break;
				case GameLanguage.getLangByKey("L_A_2542"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_REDUCE, [args[1]]);
					break;
				case GameLanguage.getLangByKey("L_A_2543"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_KICK_OUT_MEMBER, [args[1]]);
					break;
				case GameLanguage.getLangByKey("L_A_2544")://加为好友.
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_APPLYFRIEND, [args[1]]);
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_2618"),1);
					break;
				case GameLanguage.getLangByKey("L_A_2545")://访问基地
					var _view:BaseView = XFacade.instance.getView(GuildMainView);
					_view.close();
					GuestHomeView.visit(args[1]);
					
					break;
				default:
					break;
			}
			
		}
		
		public function checkPromoteJob(uid:String):void
		{
			var place:String=""
			var len:int = _donateList.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (_donateList[i].uid == uid)
				{
					place = _donateList[i].place;
					break;
				}
			}
			
			switch(place)
			{
//				case "普通成员":
				case GameLanguage.getLangByKey("L_A_2540"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_PROMOTE, [uid, "elite"]);
					break;
				
//				case "精英":
				case GameLanguage.getLangByKey("L_A_2700"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_PROMOTE, [uid, "officer"]);
					break;
				
//				case "军官":
				case GameLanguage.getLangByKey("L_A_2539"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_PROMOTE, [uid, "decommander"]);
					break;
				
//				case "副会长":
				case GameLanguage.getLangByKey("L_A_2538"):
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_TRANSFER_LEADER, [uid]);
					break;
				
				default:
					break;
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			
			super.removeEvent();
		}
		
		private function addToStageEvent():void 
		{
			
			Signal.intance.on(GuildEvent.CHANGE_JOIN_TYPE, this, this.guildEventHandler,[GuildEvent.CHANGE_JOIN_TYPE]);
			Signal.intance.on(GuildEvent.CHANGE_JOIN_LV, this, this.guildEventHandler,[GuildEvent.CHANGE_JOIN_LV]);
			Signal.intance.on(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler,[GuildEvent.CHANGE_GUILD_DESC]);
			Signal.intance.on(GuildEvent.CHANGE_GUILD_ICON, this, this.guildEventHandler, [GuildEvent.CHANGE_GUILD_ICON]);
			
			Signal.intance.on(GuildEvent.ADJUSE_MEMBER_JOB, this, this.adjustPlaceHandler);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(GuildEvent.CHANGE_JOIN_TYPE, this, this.guildEventHandler);
			Signal.intance.off(GuildEvent.CHANGE_JOIN_LV, this, this.guildEventHandler);
			Signal.intance.off(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler);
			Signal.intance.off(GuildEvent.CHANGE_GUILD_ICON, this, this.guildEventHandler);
			
			Signal.intance.off(GuildEvent.ADJUSE_MEMBER_JOB, this, this.adjustPlaceHandler);
			
		}
		
		private function get view():GuildInformationViewUI{
			return _view = _view || new GuildInformationViewUI();
		}
	}
}