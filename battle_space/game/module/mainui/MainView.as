package game.module.mainui
{
	import MornUI.mainView.MainViewUI;
	
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBInvasion;
	import game.global.data.DBItem;
	import game.global.data.DBRoleLevel;
	import game.global.data.bag.ItemData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.global.vo.friend.FriendInfoVo;
	import game.global.vo.mission.MissionStateVo;
	import game.global.vo.mission.MissionVo;
	import game.module.camp.CampData;
	import game.module.camp.CampView;
	import game.module.chatNew.LiaotianView;
	import game.module.mainScene.BaseArticle;
	import game.module.mainScene.HomeData;
	import game.module.mainScene.HomeScene;
	import game.module.mainScene.HomeSceneUtil;
	import game.module.tips.ResourceTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.debug.view.nodeInfo.ToolPanel;
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.net.URL;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.TextArea;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * MainView
	 * author:huhaiming
	 * MainView.as 2017-3-6 下午4:22:05
	 * version 1.0
	 *
	 */
	public class MainView extends BaseView
	{
		private var _ani:Animation;
		private var _brCom:BrCom;
		/**显示模式，显示所有UI*/
		public static const MODE_ALL:int=0;
		/**显示模式-只显示左上角的人物信息*/
		public static const MODE_ONLY_INFO:int=1;
		/**常量-back按钮点击*/
		public static const BACK:String="m_back";

		private var isgetMailServer:Boolean;
		private var hasFriendMsg:Boolean = false;


		private var _btnIcon:Image;

		private var _mainMissionArr:Vector.<MissionStateVo>=new Vector.<MissionStateVo>();
		private var _curretMissionVo:MissionVo;
		private var _curretMissionState:MissionStateVo;

		private var _mRewardImg:Vector.<Image>=new Vector.<Image>();
		private var _mRewardNum:Vector.<TextArea>=new Vector.<TextArea>();

		private var m_newServerMail:int=0;
		private var m_newStstemMail:int=0;
		//针对页游的特殊修改
		private var _dScale:Number = 1;
		
		private var _actCombBox:ActCombinationBox;
		/**新聊天窗口是否显示中*/
		public static var isChatNewViewShow:Boolean = false;
		/**公会聊天信息*/
		private var gonghuiChatList:Array = [];
		/**世界聊天信息*/
		private var worldChatList:Array = [];
		/**接受好友消息*/
		private var friendsNewChatUidList:Array = [];

		private var expImg:Image;

		private var expTxt:TextArea;

		private static var aniFrame:int = 75;
		/**消息预览数组*/
		private var chat_preview_info:Array = [];
		
		
		public function MainView()
		{
			super();
			this.name="MainView";

		}

		/**更新信息*/
		public function update():void
		{
			if (User.getInstance().sceneInfo.getBuildingNum(DBBuilding.B_PROTECT) > 0)
			{
				this.view.otherBtn.visible=true;
				if (!User.getInstance().sceneInfo.base_rob_info)
				{
					User.getInstance().sceneInfo.base_rob_info={};
					User.getInstance().sceneInfo.base_rob_info.search_number=0;
				}
			}
			else
			{
				this.view.otherBtn.visible=false;
			}
			if (User.getInstance().sceneInfo.base_rob_info)
			{
				var price:String=DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
				if (price)
				{
					this.view.searchIcon.visible=true;
					this.view.searchPrice.text=price.split("=")[1] + "";
					ItemUtil.formatIcon(this.view.searchIcon, price)
				}
				else
				{
					this.view.searchIcon.visible=false
					var str:String=GameLanguage.getLangByKey("L_A_49009");
					str=str.replace(/{(\d+)}/, DBInvasion.getFreeBuyTime() - User.getInstance().sceneInfo.base_rob_info.search_number);
					this.view.searchPrice.text=str;
				}
			}
			
			if (User.getInstance().level >= 18)
			{
				if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD)>=1)
				{
					if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD)==1&&
						User.getInstance().sceneInfo.hasBuildingInQueue(DBBuilding.B_GUILD))
					{
						this.view.armyGroupBtn.visible = false;
						
					}else
					{
						this.view.armyGroupBtn.visible = true;
					}
					
				}else
				{
					this.view.armyGroupBtn.visible = false;
					
				}
			}
			else
			{
				this.view.armyGroupBtn.visible = false;
			}
		}

		//布局
		override public function onStageResize():void
		{
			this.view.leftDownBox.y=LayerManager.instence.stageHeight - this.view.leftDownBox.height*_dScale;

			this.view.leftMidBox.y=(LayerManager.instence.stageHeight - this.view.leftMidBox.height*_dScale) / 2 + 20;
			this.view.rightMidBox.x=LayerManager.instence.stageWidth - this.view.rightMidBox.width*_dScale;
			this.view.rightMidBox.y=(LayerManager.instence.stageHeight - this.view.leftMidBox.height*_dScale) / 2;
			this.view.buildArea.x=LayerManager.instence.stageWidth - this.view.buildArea.width*_dScale;
			this.view.buildArea.y=this.view.rightMidBox.y+this.view.rightMidBox.height*_dScale - this.view.buildArea.height*_dScale - 45;
			this.view.rightDownBox.x=LayerManager.instence.stageWidth - this.view.rightDownBox.width*_dScale;
			this.view.rightDownBox.y=LayerManager.instence.stageHeight - this.view.rightDownBox.height*_dScale;
			if(Math.abs(view.rightMidBox.x - this.view.missionArea.x) > 20){
				this.view.missionArea.x = LayerManager.instence.stageWidth - this.view.missionArea.width*_dScale;
			}
			
			view.dom_more_box.height = view.dom_more_bg.height = LayerManager.instence.stageHeight 
		}

		/**初始化界面*/
		override public function createUI():void
		{
			this._view=new MainViewUI();
			this._view.mouseThrough=true;
			this.mouseThrough=true;
			this.addChild(_view);
			GameConfigManager.intance.initMissionData();
			GameConfigManager.intance.getGuildInitData();
			isgetMailServer=false;
			_ani=new Animation();
			_ani.loadAtlas("appRes/atlas/mainUi/effect.json");
			_ani.interval=100;
			_ani.autoPlay=true;
			_ani.scale(0.9, 0.9);
			_ani.pos(16, -5);
			_ani.scrollRect=new Rectangle(0, 0, 160, 96);
			view.MainChatImage.visible=false;
			view.btn_more.getChildAt(0).visible = false;
			view.otherBtn.visible=false;
			view.missionTips.visible = false;
			
			expImg = new Image();
			expImg.skin = "common/icons/exp.png";
			expImg.y = 45;
			expImg.x=30;
			view.missionDes.addChild(expImg);
			
			expTxt = new Text();
			expTxt.font="BigNoodleToo";
			expTxt.color="#ffffff";
			expTxt.height=20;
			expTxt.fontSize=18;
			expTxt.text="";
			expTxt.x = expImg.x+expImg.width;
			expTxt.y = expImg.y+8;
			view.missionDes.addChild(expTxt);
			
			
			for (var i:int=0; i < 3; i++)
			{
				_mRewardImg[i]=new Image();
				_mRewardImg[i].name="n_" + i;
				_mRewardImg[i].skin="";
				_mRewardImg[i].width=_mRewardImg[i].height=50;
				_mRewardImg[i].x=30 + 80 * i;
				_mRewardImg[i].y=70;
				_mRewardImg[i].on(Event.CLICK, this, showIconTips);
				view.missionDes.addChild(_mRewardImg[i]);

				_mRewardNum[i]=new TextArea();
				_mRewardNum[i].font="Futura";
				_mRewardNum[i].fontSize=14;
				_mRewardNum[i].color="#ffffff";
				_mRewardNum[i].text="";
				_mRewardNum[i].height=20;
				_mRewardNum[i].mouseEnabled=false;
				_mRewardNum[i].x=_mRewardImg[i].x + 37;
				_mRewardNum[i].y=_mRewardImg[i].y + 20;
				view.missionDes.addChild(_mRewardNum[i]);
			}

			//trace("btnIcon:", view.goBtn.skin);
			view.goBtn.skin="mainUi/mission/btn_1.png";
			_btnIcon=new Image();
			_btnIcon.skin="appRes/icon/failureIcon/icon_unfinish.png";
			_btnIcon.mouseEnabled=false;
			view.openMissionBtn.addChild(_btnIcon);

			//this.view.actTips.visible=false;
			view.openMissionBtn.visible=false;
			view.missionArea.x = view.rightMidBox.x - 350; // 685;
			view.missionTitle.visible = true;
			showMissionDes();
			
			UIRegisteredMgr.AddUI(this.view.backBtn, "Scence_backToMenu");
			UIRegisteredMgr.AddUI(this.view.copyBtn, "Scence_goToFight");


			BtnDecorate.decorate(view.constructBtn, "mainUi/icon_construction.png");
			BtnDecorate.decorate(view.packBtn, "mainUi/icon_inventory.png", -2);

			view.copyBtn.addChildAt(_ani, view.copyBtn.getChildIndex(view.copyBtn.text));

			view.constructBtn['clickSound']=ResourceManager.getSoundUrl("ui_construction_click", 'uiSound')
			view.packBtn['clickSound']=ResourceManager.getSoundUrl("ui_pack_click", 'uiSound')
			view.otherBtn['clickSound']=ResourceManager.getSoundUrl("ui_invade", 'uiSound')
			view.copyBtn['clickSound']=ResourceManager.getSoundUrl("ui_transport_click", 'uiSound');
			
			//针对web的修改
			if(GameSetting.IsRelease){
				_dScale = 0.8;
				this.view.leftUpBox.scaleX = this.view.leftUpBox.scaleY = _dScale;
				this.view.leftMidBox.scaleX = this.view.leftMidBox.scaleY = _dScale;
				this.view.leftDownBox.scaleX = this.view.leftDownBox.scaleY = _dScale;
				
				this.view.rightMidBox.scaleX = this.view.rightMidBox.scaleY = _dScale;
				this.view.missionArea.scaleX = this.view.missionArea.scaleY = _dScale;
				this.view.rightDownBox.scaleX = this.view.rightDownBox.scaleY = _dScale;
				this.view.buildArea.scaleX = this.view.buildArea.scaleY = _dScale;
			}
			
			this.view.cacheBox.cacheAsBitmap=true;
			this.view.otherBtn.cacheAsBitmap=true;
			
			// 绑定账户的按钮 
			view.btn_account.visible = GameSetting.isApp;
		}
		
		private function showIconTips(e:Event):void
		{
			var index:int=e.target.name.split("_")[1];
			var rewardArr:Array=_curretMissionVo.reward.split(";");
			if (index < rewardArr.length)
			{
				ItemTips.showTip(rewardArr[index].split("=")[0]);
			}
		}
		
		public function UpdateWater():void
		{
			var user:User=GlobalRoleDataManger.instance.user;
			this.view.waterTF.text=XUtils.formatResWith(user.water);
		}
		
		private function hideMissionDes():void
		{
			view.missionDesTF.visible=false;
			//view.goBtn.visible = false;
			view.missionTitle.visible = false;
			view.hideMissionBtn.visible=false;
			view.openMissionBtn.visible=true;
			expImg.visible = expTxt.visible = false;
			for (var i:int=0; i < 3; i++)
			{
				_mRewardImg[i].visible=false;
				_mRewardNum[i].visible=false;
			}
		}
		
		public function showMissionDes():void
		{
			view.missionDesTF.visible=true;
			//view.goBtn.visible = true;
			expImg.visible = expTxt.visible = true;
			view.hideMissionBtn.visible=true;
			view.openMissionBtn.visible = false;
			
			for (var i:int=0; i < 3; i++)
			{
				_mRewardImg[i].visible=true;
				_mRewardNum[i].visible=true;
			}
		}
		
		override public function show(... args):void
		{
			super.show();
			onChangePro();
			//WebSocketNetService.instance.sendData(10109)
			User.getInstance().isInMainView = true;
			showBuildArea();
			
			
			if (!_actCombBox)
			{
				/**
				 * 活动整合区域
				 */
				_actCombBox = new ActCombinationBox();
				_actCombBox.x = 150;
				_actCombBox.y = 48;
				view.leftUpBox.addChild(_actCombBox);
			}
			
			this.view.guildHelpBtn.visible = false;
			
			var mode:Number=args[0];
			if (mode)
			{ //只显示左上角信息模式
				User.getInstance().isInMainView=false;
				this.view.leftDownBox.visible=false;
				this.view.backBtn.visible=true;
				this.view.copyBtn.visible=false;
				this.view.otherBtn.visible = false;
				this.view.armyGroupBtn.visible = false;
				this.view.leftMidBox.visible=false;
				this.view.rightMidBox.visible=false;
				this.view.missionArea.visible=false;
				this.view.buildArea.visible=false;
				_actCombBox.visible = false;
				this.view.boxVip.visible = false;
				
				return;
			}
			else
			{ //全UI模式
				if (!User.getInstance().isInGuilding)
				{
					User.getInstance().checkHasNextGuide();
				}
				this.view.leftDownBox.visible=true;
				this.view.backBtn.visible=false;
				this.view.copyBtn.visible=true;
				this.view.leftMidBox.visible=true;
				this.view.rightMidBox.visible=true;
				this.view.missionArea.visible=true;
				this.view.buildArea.visible=true;
				_actCombBox.visible = true;
				this.view.boxVip.visible = true;
				
				if (User.getInstance().level >= 18)
				{
					if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD)>=1)
					{
						if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD)==1&&
							User.getInstance().sceneInfo.hasBuildingInQueue(DBBuilding.B_GUILD))
						{
							this.view.armyGroupBtn.visible = false;

						}else
						{
							this.view.armyGroupBtn.visible = true;
						}
											
					}else
					{
						this.view.armyGroupBtn.visible = false;

					}
				}
				else
				{
					this.view.armyGroupBtn.visible = false;
				}
				
				
				if (User.getInstance().sceneInfo.getBuildingNum(DBBuilding.B_PROTECT) > 0)
				{
					this.view.otherBtn.visible=true;
				}
				//公会建筑物帮助暂时取消
				/*if (User.getInstance().guildID != "" )
				{
					WebSocketNetService.instance.sendData(ServiceConst.BUILDING_HELP_INIT);
				}*/
			}

			view.goBtn.visible=false;
			Laya.timer.once(500, this, function()
			{
				WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["main"]);
				WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["daily"]);
				WebSocketNetService.instance.sendData(ServiceConst.OPEN_VIP_VIEW);
				//WebSocketNetService.instance.sendData(ServiceConst.GET_ACTIVITY_LIST);
			});

			this.view.redot.visible=DBBuildingUpgrade.check();
			this.view.chargeBtn.visible=DBBuilding.isChargeOn;

			//重新绑定语言
			this.view.constructBtn.label=GameLanguage.getLangByKey(this.view.constructBtn.label);
			this.view.backBtn.label=GameLanguage.getLangByKey(this.view.backBtn.label);
			this.view.packBtn.label=GameLanguage.getLangByKey(this.view.packBtn.label);
			this.view.copyBtn.label=GameLanguage.getLangByKey(this.view.copyBtn.label);
			this.view.searchLabel.text=GameLanguage.getLangByKey(this.view.searchLabel.text);
			view.missionTitle.text = GameLanguage.getLangByKey("L_A_118");
			view.warLabel.text = GameLanguage.getLangByKey(view.warLabel.text);
			onStageResize();
			updateBuildArea()
			//view.inviteBtn.visible = !GameSetting.isApp;
			
			initLiaotianView();
		}
		
		public function initLiaotianView():void {
			// 聊天
			XFacade.instance.openModule(ModuleName.LiaotianView, {
				tabs: [LiaotianView.WORLD_CHAT, LiaotianView.GUILD_CHAT, LiaotianView.FRIEND_CHAT],
				isHome: true
			});
		}
		
		private function updateBuildArea():void 
		{
			var vo:SceneVo = User.getInstance().sceneInfo;
			view.canBuild0.visible = true;//第一个队列，默认可以建造
			view.noBuild0.visible = false;
			view.buildImg0.visible = false;
			view.buildImg0.skin = "";
			view.canBuild1.visible = false;//第二个队列以后默认不能建造
			view.noBuild1.visible = true;
			view.buildImg1.visible = false;
			view.buildImg1.skin = "";
			view.box1.off(Event.CLICK,this,onFocus);
			view.box0.off(Event.CLICK,this,onFocus);
			view.box1.off(Event.CLICK,this,onBuy);
			view.openBuildBtn.skin = "mainUi/buildingQueue/btn_2.png";//默认空闲状态
			view.hideBuildBtn.skin = "mainUi/buildingQueue/btn_2.png";//默认空闲状态
			view.red0.visible = false;
			view.red0.visible = false;
			view.green0.visible = true;
			view.red1.visible = false;
			view.green1.visible = true;
			for(var i:int=0;i<vo.queue.length;i++)
			{
				var buildName:String = "buildImg"+i;
				
				var imgName:String = "buildImg"+i;
				var boxName:String = "box"+i;
				var canName:String = "canBuild"+i;
				var noCanName:String = "noBuild"+i;
				var redName:String = "red"+i;
				var greenName:String = "green"+i;
				if(vo.queue[i].length>0)
				{
					view.openBuildBtn.skin = "mainUi/buildingQueue/btn_1.png";
					view.hideBuildBtn.skin = "mainUi/buildingQueue/btn_1.png";
					view[canName].visible = false;
					view[noCanName].visible = false;
					view[redName].visible = true;
					view[greenName].visible = false;
					var id:String = vo.queue[i][0];
					//trace("后端建筑id:"+id);
					var bid:String = vo.building[id]["id"];
					//trace("建筑bid:"+bid);
					view[buildName].visible = true;
				
					view[imgName].skin = URL.formatURL("appRes/building/"+bid+".png");
					
					view[imgName].visible = true;
					var lv:Number = vo.building[id]["level"];
					//trace("建筑lv:"+lv);
					var bvo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv("B"+bid, lv);
					var total:Number = bvo.CD*1000;
					//trace("总时间:"+total);
					var leftTime:Number = vo.queue[i][1]*1000-TimeUtil.now;
					//trace("剩余建造时间:"+leftTime);
					
					var interval:int = parseInt(total/aniFrame);
					//trace("动画每帧时间:"+interval);
					var leftFrame:int = parseInt(leftTime/interval);
					if(leftTime%interval>0)
					{
						leftFrame++;
					}
					//trace("剩余帧数:"+leftFrame);
					var beginFrame:int = aniFrame-leftFrame<0?0:aniFrame-leftFrame;
					//trace("起始帧数:"+beginFrame);
					
					
					var cd:Animation = (view[boxName] as Box).getChildByName("ani");
					
					if(!cd)
					{
						var cd:Animation = new Animation();
						cd.name = "ani";
						view[boxName].addChild(cd);
					}
//					trace("cd.name:"+cd.name);
					cd.loadAtlas("appRes/atlas/mainUi/buildingQueueEff.json",new Handler(this,playAni,[cd,beginFrame]));
					cd.interval = interval;
					view[boxName].on(Event.CLICK,this,onFocus,[bid,id]);
				}else
				{
					view[redName].visible = false;
					view[greenName].visible = true;
					view[canName].visible = true;
					view[noCanName].visible = false;
					view[buildName].visible = false;
					view[imgName].visible = false;
					view[buildName].skin = "";
					view[boxName].off(Event.CLICK,this,onFocus);
					var cd:Animation = (view[boxName] as Box).getChildByName("ani");
					if(cd)
					{
						cd.clear();
						cd.removeSelf();
					}
				}
			}
			if(vo.queue.length<2)
			{
				view.box1.on(Event.CLICK,this,onBuy);
			}else
			{
				view.box1.off(Event.CLICK,this,onBuy);
			}
		}
		
		/**
		 * 
		 * @param id 后端的建筑id
		 * @param bid 表里的建筑id
		 * 
		 */
		private function onFocus(bid:String,id:String):void
		{
			// TODO Auto Generated method stub
			trace("聚焦的建筑id:"+bid);
			trace("聚焦的后端建筑id"+id);
			var sp:Sprite=HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(bid+"",id);
//			HomeScene(ModuleManager.intance.getModule(HomeScene)).selectedBuilding = sp;
			
			HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(sp);
		}
		
		private function onBuy():void
		{
			trace("购买队列");
			
			var costObj:Object = GameConfigManager.buildingQueue_vos;
			var costStr:String = costObj["2"]["queue_cost"];
			var costArr:Array = costStr.split("=");
//			var vo:SceneVo = User.getInstance().sceneInfo;
//			vo.queue = args[1][0];
			var item:ItemData = new ItemData();
			item.iid = costArr[0];
			item.inum =  Number(costArr[1]);
			ConsumeHelp.Consume([item],Handler.create(this,buyQueue),GameLanguage.getLangByKey("L_A_33029"));
		}
		
		private function buyQueue():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.B_OPEN);
		}
		
		private function playAni(cd:Animation,beginFrame:int):void
		{
			cd.play(beginFrame,false);
		}
		
		override public function close():void
		{
			super.close();
			User.getInstance().isInMainView=false;
			LiaotianView.hide();
		}

		private function onClick(event:Event):void
		{
			trace("enter:" + event.target.name);
			switch (event.target)
			{
				// 打开更多小icon
				case view.btn_more:
					view.dom_more_box.visible = true;
					var red_point:Node = view.btn_more.getChildAt(0);
					red_point.visible = false;
					Signal.intance.event(NewerGuildeEvent.OPEN_SET_NOTE);
					break;
				
				case view.btn_close:
				case view.dom_more_bg:
					view.dom_more_box.visible = false;
					
					break;
				case this.view.constructBtn:
					XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD, _curretMissionVo && _curretMissionVo.id]);

					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.HANK_CLICK);
						Laya.timer.once(500, this, function()
						{
							Signal.intance.event(NewerGuildeEvent.OPEN_CONTRIBUTE_LIST);
						});
					}
					break;
				case this.view.copyBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);

					/*Laya.timer.once(500, this, function() {
							XFacade.instance.openModule(ModuleName.FunctionGuideView, 2);
							} );*/

					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.HANK_CLICK);

					}
					break;
				case this.view.armyGroupBtn:
					if (User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(HomeData.MAIN_BTNJUNTUAN);
//						XFacade.instance.openModule("ArmyGroupMapView");
////						XFacade.instance.openModule(ModuleName.NewArmyGroupView);
//						XFacade.instance.closeModule(MainMenuView);
					}
					break;
				case this.view.chargeBtn:
				case this.view.bmVip:
//					if(GameSetting.IsRelease)
//					{
//						XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//					}
//					else
//					{
					XFacade.instance.openModule(ModuleName.ChargeView);
//					}

					//XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD, -1]);
					break;
				case this.view.taskBtn:
					XFacade.instance.closeModule(MainMenuView);
					XFacade.instance.openModule(ModuleName.MissionMainView);
					break;
				case this.view.backBtn:
					if (User.getInstance().guideStep > 290 && User.getInstance().guideStep < 300 && !User.getInstance().hasFinishGuide)
					{
						return;
					}
					Signal.intance.event(BACK);
					//trace("User.getInstance().guideStep",User.getInstance().guideStep)
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.HANK_CLICK);
						Laya.timer.once(500, this, function()
						{
							Signal.intance.event(NewerGuildeEvent.START_LOTTLE_GUIDE);
						});
					}
					break;
				case this.view.packBtn:
					XFacade.instance.closeModule(MainMenuView);
					XFacade.instance.openModule(ModuleName.BagPanel);
//					DataLoading.instance.show();
//					XTip.showTip("helloBag"); 
//					XFacade.instance.openModule(ModuleName.DiscountShop);
					break;
				case this.view.otherBtn:
					//
					var vo:SceneVo = User.getInstance().sceneInfo;
					var ifIqueue:Boolean = vo.hasBuildingInQueue(Number(DBBuilding.B_PROTECT));
					if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT)==1&&ifIqueue)
					{
						trace("基地互动建筑在建造中");
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_152"));
						return;
					}
					var price:String=DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
					var arr:Array=price.split("=")

					var data:ItemData=new ItemData;
					data.iid=arr[0];
					data.inum=arr[1];
					ConsumeHelp.Consume([data], Handler.create(this, onConsum));

					function onConsum():void
					{
						XFacade.instance.openModule("InvasionView");
					}
					break;
				
				case this.view.settingBtn:
					XFacade.instance.closeModule(MainMenuView);
					XFacade.instance.openModule(ModuleName.SetPanel, [0]);
					break;
				
				case this.view.btn_account:
					XFacade.instance.closeModule(MainMenuView);
					XFacade.instance.openModule(ModuleName.SetPanel, [1]);
					break;
				
				case this.view.btn_exchange:
					XFacade.instance.openModule(ModuleName.SetPanel, [2]);
					break;
				
				case this.view.MailBtn:
					XFacade.instance.closeModule(MainMenuView);
					var l_friendVo:FriendInfoVo=new FriendInfoVo();
					view.MainChatImage.visible=false;
					view.btn_more.getChildAt(0).visible = false;
					//Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT),this,onResult);
					l_friendVo.newServersNum=m_newServerMail;
					l_friendVo.newStstemNum=m_newStstemMail;
					XFacade.instance.openModule(ModuleName.FriendMainView, [l_friendVo, hasFriendMsg]);
					hasFriendMsg = false;
					m_newServerMail=0;
					m_newStstemMail=0;
					break;
				
				/*case this.view.groupBtn:
					//公会。。。。。。。。。。。。
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) == 0)
					{
						XTip.showTip("您还未建造公会");
						return;
					}
					if(User.getInstance().guildID != "")
					{
						XFacade.instance.openModule(ModuleName.GuildMainView);
					}
					else
					{
						XFacade.instance.openModule(ModuleName.CreateGuildView);
					}
					break;*/
				/*case this.view.battleBtn:
					XFacade.instance.openModule("ReplayView");
					//战报
					break;*/
				case this.view.guildHelpBtn:
					//XFacade.instance.openModule(ModuleName.BuildHelpView);
					break;
//				case this.view.btn_levelgift:
//					XFacade.instance.openModule(ModuleName.LevelGiftView);
//					break;
				/*case this.view.activityBtn:
					XFacade.instance.closeModule(MainMenuView);
					//活动
					this.view.actTips.visible=false;
					XFacade.instance.openModule(ModuleName.ActivityMainView);
					break;*/
				case view.openMissionBtn:
					view.openMissionBtn.visible = false;
					view.missionTitle.visible = true;
					Tween.to(view.missionArea, {x: view.rightMidBox.x - 350*_dScale}, 250, Ease.linearNone, Handler.create(this, showMissionDes));
					//Tween.to(view.missionArea, { x:685 }, 250, Ease.linearNone, Handler.create(this,showMissionDes));
					break;
				case view.hideMissionBtn:
					view.hideMissionBtn.visible=false;
					Tween.to(view.missionArea, {x: view.rightMidBox.x - 5}, 250, Ease.linearNone, Handler.create(this, hideMissionDes));
					//Tween.to(view.missionArea, { x:1030 }, 250, Ease.linearNone, Handler.create(this,hideMissionDes));
					break;
				case view.openBuildBtn:
					view.openBuildBtn.visible = false;
					Tween.to(view.buildArea, {x: Laya.stage.width - view.buildArea.width*_dScale}, 250, Ease.linearNone, Handler.create(this, showBuildArea));
					break;
				case view.hideBuildBtn:
					view.hideBuildBtn.visible=false;
					Tween.to(view.buildArea, {x: Laya.stage.width - 29}, 250, Ease.linearNone, Handler.create(this, hideBuildArea));
					break;
				case view.goBtn: 
					XFacade.instance.closeModule(MainMenuView);
					Laya.timer.once(250, this, goBtnHandler);
					//goBtnHandler();

					break;
				case view.expIcon:
					XTipManager.showTip(User.getInstance(), UserTip, false);
					break;
				case view.goldIcon:
				case view.goldTF:
					var info:Object={};
					info.name="L_A_34"
					info.des="L_A_35"
					info.icon="jczy4"
					info.max=view.goldBar.name;
					info.output=User.getInstance().sceneInfo.getOutPut(DBItem.GOLD);
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.steelIcon:
				case view.steelTF:
					info={};
					info.name="L_A_36"
					info.des="L_A_37"
					info.icon="jczy3"
					info.max=view.steelBar.name;
					info.output=User.getInstance().sceneInfo.getOutPut(DBItem.STEEL);
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.stoneIcon:
				case view.stoneTF:
					info={};
					info.name="L_A_38"
					info.des="L_A_39"
					info.icon="jczy2"
					info.max=view.stoneBar.name;
					info.output=User.getInstance().sceneInfo.getOutPut(DBItem.STONE);
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.foodIcon:
				case view.foodTF:
					info={};
					info.name="L_A_40"
					info.des="L_A_41"
					info.icon="jczy5"
					info.max=view.foodBar.name;
					info.output=User.getInstance().sceneInfo.getOutPut(DBItem.FOOD);
					XTipManager.showTip(info, ResourceTip);

					//trace("Send a msg to srv to delete user------------vvvery dangerous");
					//XAlert.showAlert("Only for developer, guys don't do that,plz!",Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData,[10109]))
					//WebSocketNetService.instance.sendData(10109-danger)
					break;
				case view.waterIcon:
				case view.waterTF:
					info={};
					info.name="L_A_42"
					info.des="L_A_43"
					info.max=User.getInstance().water + "";
					info.icon="jczy1"
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.breadIcon:
				case view.breadTF:
					info={};
					info.name="L_A_420021"
					info.des="L_A_420021"
					info.max=view.breadBar.name;
					trace("view.breadBar.name:"+view.breadBar.name);
					info.icon="jczy6"
					info.output=User.getInstance().sceneInfo.getOutPut(DBItem.BREAD);
					XTipManager.showTip(info, ResourceTip);
					break;
				//帮助按钮
				case view.helpBtn:
					XFacade.instance.openModule(ModuleName.PlayerHelpView, "20");
					break;
				
				// 新聊天
				case view.dom_chatNew:
				case view.dom_chat_preview:
					var worlds = worldChatList.concat();
					var gonghuis = gonghuiChatList.concat();
					var friendsChat = friendsNewChatUidList.concat();
					worldChatList.length = 0;
					gonghuiChatList.length = 0;
					friendsNewChatUidList.length = 0;
					var _this = this;
					view.dom_chatNew.getChildAt(0).visible = false;
					
					chat_preview_info.length = 0;
					renderChatPreviewBox(chat_preview_info);
					
					var liaotianView:LiaotianView = XFacade.instance.getView(LiaotianView);
					liaotianView.closeHandler();
					
					break;
				
				default:
					
					break;
			}
		}
		
		private function hideBuildArea():void
		{
			// TODO Auto Generated method stub
			view.hideBuildBtn.visible=false;
			view.openBuildBtn.visible = true;
		}
		
		private function showBuildArea():void
		{
			view.hideBuildBtn.visible=true;
			view.openBuildBtn.visible = false;
		}
		
		private function goBtnHandler():void
		{
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.CLICK_GO_BTN);
			}

			if (_curretMissionState.state == "0")
			{
				linkTo(_curretMissionVo.gongneng)
				return;
			}
			WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD, ['main', _curretMissionVo.id]);
			
//			if (_curretMissionVo.id == "219")
//			{
//				Signal.intance.event(ActCombinationBox.OPEN_FIRST_CHARGE);
//			}
		}
		
		public function updateTime():void
		{
			this.view.timeTF.text=TimeUtil.getUTC();
		}

		public function linkTo(id:*):void
		{
			var sp:Sprite;
			trace("linkTo::",id)
			switch (id)
				//switch("3")
			{
				case "1": //建造
					if (parseInt(_curretMissionVo.canshu2) >= 2&&_curretMissionVo.requirement==1)
					{
						sp=HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(_curretMissionVo.canshu1);
						HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(sp);
					}
					else
					{
						XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD, _curretMissionVo.canshu1]);
					}
					break;
				case "2": //主线副本
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);
					break;
				case "3": //训练兵种
					if (_curretMissionVo.requirement == "1" || 
						_curretMissionVo.requirement == "2" || 
						_curretMissionVo.requirement == "5" || 
						_curretMissionVo.requirement == "6" ||
						_curretMissionVo.requirement == "13" ||
						_curretMissionVo.requirement == "14"
					){
						
						XFacade.instance.openModule("CampView", CampView);
						//XFacade.instance.openModule("UnitInfoView", [{id:_curretMissionVo.canshu1}]);
						XFacade.instance.openModule(ModuleName.NewUnitInfoView, [_curretMissionVo.canshu1]);
					}
					else if (_curretMissionVo.requirement == "11" || 
						_curretMissionVo.requirement == "12")
					{
						XFacade.instance.openModule("CampView", CampView);
					}
					else
					{
						XFacade.instance.openModule("LevelUpView");
					}

					//XFacade.instance.openModule("UnitInfoView", [item.id, getIds(item.id)]);
					break;
				case "4": //人物等级
					//无跳转
					break;
				case "5": //宝箱
					/*XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.ChestsView);*/
//					WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD_INFO,[]);
//					XFacade.instance.openModule("ChestsMainView");
					break;
				case "6": //基地互动
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57009"));
						return;
					}
					sp=HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_PROTECT);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(sp);
					break;
				case "7": //训练营
					XFacade.instance.openModule("TrainView");
					break;
				case "8": //资源建筑
					break;
				case "9": //怪物入侵
					HomeScene(ModuleManager.intance.getModule(HomeScene)).focus();
					break;
				case "10": //击杀BOSS
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP, true, 1, [1]);
					break;
				case "11": //好友
					break;
				case "12": //基因副本
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP, true, 1, [1, 1]);
					break;
				case "13": //基因系统
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GENE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57010"));
						return;
					}
					XFacade.instance.openModule("GeneView");
					break;
				case "14": //武器副本
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP, true, 1, [1]);
					/*SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);
					XFacade.instance.openModule(ModuleName.EquipFightInfoView,0);*/
					break;
				case "15": //酒馆洗练
				case "16": //酒馆强化
					//无跳转
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_HOTRL) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57011"));
						return;
					}
					XFacade.instance.openModule(ModuleName.EquipMainView);
					break;
				case "17": //公会
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57012"));
						return;
					}
					
					if (User.getInstance().guildID=="")
					{
						XFacade.instance.openModule(ModuleName.CreateGuildView);
					}
					else 
					{
						XFacade.instance.openModule(ModuleName.GuildMainView);
					}
					break;
				case "18": //超市
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_STORE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57013"));
						return;
					}
//					XFacade.instance.openModule("StoreView");
					XFacade.instance.openModule("StoreView",[0,0]);
					break;
				case "19": //兵书副本
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					break;
				case "20": //雷达站
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					break;
				case "21": //运镖
					//WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETTRANSPORTTYPE, []);
					XFacade.instance.openModule(ModuleName.TrainLoadingView);
					break;
				case "22": //遗迹
					XFacade.instance.openModule("LevelUpView");
					break;
				case "23":
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				case "24":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_ARENA) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57015"));
						return;
					}
					XFacade.instance.openModule(ModuleName.ArenaMainView);
					break;
				case "25":
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP, true, 1, [2]);
					break;
				case "28":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_MINE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57021"));
						return;
					}
					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				case "29":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					XFacade.instance.openModule(ModuleName.MilitartHouseView);
					break;
				case "30":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				case "31":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PVP) == 0)
					{
						XTip.showTip("no pvp building");
						return;
					}
					XFacade.instance.openModule(ModuleName.PvpMainPanel);
					break;
				case "34":
					XFacade.instance.openModule(ModuleName.SetPlayerNameView);
					break;
				
				// 军团
				case "32":
					var juntuan_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
					var needBaseLv = Number(juntuan_data["72"].value);
					if (User.getInstance().level < needBaseLv) {
						var text = GameLanguage.getLangByKey("L_A_170").replace("{0}", needBaseLv); 
						return XTip.showTip(text);
					}
					var buildInfo:Array = juntuan_data["74"].value.split("=");
					if (User.getInstance().sceneInfo.getBuildingLv(buildInfo[0]) < buildInfo[1]) {
						return XTip.showTip("L_A_21039");
					}
					
					XFacade.instance.openModule(ModuleName.ArmyGroupMapView);
					
					break;
				default:
					break;
			}
		}

		private function onChangePro(... args):void
		{
			var user:User=User.getInstance();
			var tf:*
			if (args.length)
			{ //加入动画
				switch (args[0])
				{
					case DBItem.STEEL:
						tf=this.view.steelTF
						break;
					case DBItem.STONE:
						tf=this.view.stoneTF
						break;
					case DBItem.WATER:
						tf=this.view.waterTF
						break;
					case DBItem.GOLD:
						tf=this.view.goldTF;
						break;
					case DBItem.FOOD:
						tf=this.view.foodTF;
						break;
					case DBItem.BREAD:
						tf=this.view.breadTF;
						break;
				}
			}
			else
			{
				this.view.nameTF.text=user.name + "";
				this.view.foodTF.text=XUtils.formatResWith(user.food);
				this.view.steelTF.text=XUtils.formatResWith(user.steel);
				this.view.goldTF.text=XUtils.formatResWith(user.gold);
				this.view.stoneTF.text=XUtils.formatResWith(user.stone);
				this.view.waterTF.text=XUtils.formatResWith(user.water);
				//trace("user.bread:"+user.bread);
				//trace("user.KPI:"+user.KPI);
				this.view.breadTF.text = XUtils.formatResWith(user.bread);
				this.view.lvTF.text = GameLanguage.getLangByKey("L_A_73") + (user.level || 1);
				this.view.KPITF.text = user.KPI;
				
				//
				this.view.expBar.value=user.exp / DBRoleLevel.getLvExp(user.level);
			}
			this.view.goldBar.value=user.gold / user.sceneInfo.getResCap(DBItem.GOLD);
			this.view.goldBar.name=user.gold + "/" + user.sceneInfo.getResCap(DBItem.GOLD)
			if (this.view.goldBar.value >= 1)
			{
				this.view.goldTF.color="#ff6600";
			}
			else
			{
				this.view.goldTF.color="#ffffff";
			}

			this.view.steelBar.value=user.steel / user.sceneInfo.getResCap(DBItem.STEEL);
			this.view.steelBar.name=user.steel + "/" + user.sceneInfo.getResCap(DBItem.STEEL)
			if (this.view.steelBar.value >= 1)
			{
				this.view.steelTF.color="#ff6600";
			}
			else
			{
				this.view.steelTF.color="#ffffff";
			}

			this.view.stoneBar.value=user.stone / user.sceneInfo.getResCap(DBItem.STONE);
			this.view.stoneBar.name=user.stone + "/" + user.sceneInfo.getResCap(DBItem.STONE)
			if (this.view.stoneBar.value >= 1)
			{
				this.view.stoneTF.color="#ff6600";
			}
			else
			{
				this.view.stoneTF.color="#ffffff";
			}

			this.view.foodBar.value=user.food / user.sceneInfo.getResCap(DBItem.FOOD);
			this.view.foodBar.name=user.food + "/" + user.sceneInfo.getResCap(DBItem.FOOD);
			if (this.view.foodBar.value >= 1)
			{
				this.view.foodTF.color="#ff6600";
			}
			else
			{
				this.view.foodTF.color="#ffffff";
			}
			this.view.breadBar.value=user.bread / user.sceneInfo.getResCap(DBItem.BREAD);
			this.view.breadBar.name=user.bread + "/" + user.sceneInfo.getResCap(DBItem.BREAD);
			if (this.view.breadBar.value >= 1)
			{
				this.view.breadTF.color="#ff6600";
			}
			else
			{
				this.view.breadTF.color="#ffffff";
			}
			this.view.redot.visible=DBBuildingUpgrade.check();

			if (tf)
			{
				XUtils.showTxtFlash(tf);
				tf.text=XUtils.formatResWith(user.getResNumByItem([args[0]]));

			}
			view.tfVip.text = "VIP"+user.VIP_LV;
			//修改建筑状态
			Laya.timer.clear(HomeSceneUtil, HomeSceneUtil.checkUp);
			Laya.timer.once(200, HomeSceneUtil, HomeSceneUtil.checkUp);
			//HomeSceneUtil.checkUp();
		}

		private function onResult(cmd:int, ... args):void
		{
			// TODO Auto Generated method stub
			//trace("T_OnResultMainView", args);
			switch (cmd)
			{
				case ServiceConst.DRAW_CARD_INFO:
//					var l_drawCardVo:DrawCardVo=new DrawCardVo();
//					var l_info:Object=args[1];
//					l_drawCardVo.first_prop_10=l_info.first_prop_10;
//					l_drawCardVo.first_water_10=l_info.first_water_10;
//					l_drawCardVo.prop_1_card=l_info.prop_1_card;
//					l_drawCardVo.water_1_card=l_info.water_1_card;
//					l_drawCardVo.use_level=l_info.use_level;
//					XFacade.instance.openModule("ChestsMainView");
					break;
				case ServiceConst.FRIEND_GETNAIL:
					if (isgetMailServer == true)
					{
						return;
					}
					view.MainChatImage.visible=false;
					view.btn_more.getChildAt(0).visible = false;
					Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETNAIL), this, onResult);
					var l_friendVo:FriendInfoVo=new FriendInfoVo();
					var l_info:Object=args[1];
					l_friendVo.setMailInfo(l_info);
					l_friendVo.newServersNum=m_newServerMail;
					l_friendVo.newStstemNum=m_newStstemMail;
					isgetMailServer=true;
					XFacade.instance.openModule(ModuleName.FriendMainView, l_friendVo);
					m_newServerMail=0;
					m_newStstemMail=0;
					break;
				case ServiceConst.MISSION_INIT_DATA:
					var mData:Object=args[1].list;


					switch (args[1].type)
					{
						case "main":
							for (var md:String in mData)
							{
								var stateData:MissionStateVo=new MissionStateVo();
								stateData.id=md;
								stateData.state=parseInt(mData[md][0]);
								stateData.currentInfo=mData[md][1][1] ? mData[md][1][1] : [];

								updateMissionArr(stateData);
							}
							refreshCurrentMission();
							break;
						case "daily":
							view.missionTips.visible=false;
							for (var d:String in mData)
							{
								if (parseInt(mData[d][0]) == 1)
								{
									view.missionTips.visible=true;
								}
							}
							break;
						default:
							break;
					}
					break;
				case ServiceConst.GET_MISSION_PROGRESS:

					var updataArr:Array=args[1];
					var len:int=updataArr ? updataArr.length : 0;
					for (var i:int=0; i < len; i++)
					{
						//trace("updataArr[", i, "]: ", updataArr[i]);
						var upDataInfo:MissionStateVo=new MissionStateVo();
						upDataInfo.id=updataArr[i].task_id;
						upDataInfo.state=parseInt(updataArr[i].task_info[0]);
						upDataInfo.currentInfo=updataArr[i].task_info[1][1] ? updataArr[i].task_info[1][1] : [];
						if (!GameConfigManager.missionInfo[upDataInfo.id])
						{
							XTip.showTip("任务:" + upDataInfo.id + "更新失败");
							return;
						}
						switch (GameConfigManager.missionInfo[upDataInfo.id].type)
						{
							case "1":
								updateMissionArr(upDataInfo);
								refreshCurrentMission();
								break;
							case "2":
								//trace("主场景更新每日任务：", args[1]);
								break;
							default:
								break;
						}
					}
					break;
				case ServiceConst.GET_MISSION_REWARD:
					if (!User.getInstance().hasFinishGuide)
					{
						return;
					}
					var ar:Array=[];
					var list:Array=args[1];
					len=list.length;
					for (i=0; i < len; i++)
					{
						var itemD:ItemData=new ItemData();
						itemD.iid=list[i][0];
						itemD.inum=list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					break;
				case ServiceConst.TRAN_GETTRANSPORTTYPE:
//					var l_info:Object=args[1];
//					var l_data:TransportBaseInfo=new TransportBaseInfo();
//					l_data.status=l_info.status;
//					l_data.endTime=l_info.endTime;
//					if(l_data.status==0)
//					{
//						XFacade.instance.openModule("EscortMainView",l_data);
//					}
//					else
//					{
//						XFacade.instance.openModule("PlunderMainView",l_data);
//					}
					break;
				//收到私聊消息
				case ServiceConst.FRIEND_GETCHAT:
					if (isChatNewViewShow) return;
					
					addChatPreview(getChatPreviewText("L_A_3035", args[2], args[3]));
					
					if (friendsNewChatUidList.indexOf(args[1]) == -1) {
						friendsNewChatUidList.push(args[1]);
					}
					
					break;
				
				//推送消息,有人加你好友
				case ServiceConst.FRIEND_GETREQUEST:
				//某人通过你的好友请求
				case ServiceConst.FRIEND_GETREQUESTAPPLY:
					if (isChatNewViewShow) return;
					
					addChatPreview(getChatPreviewText("L_A_3035", args[2]));
					
					break;
				
				case ServiceConst.FRIEND_NEWMAIL:
					var l_type:int=args[1];
					if (l_type == 1)
					{
						m_newServerMail++;
					}
					else
					{
						m_newStstemMail++;
					}
					view.MainChatImage.visible=true;
					view.btn_more.getChildAt(0).visible = true;
					break;
				case ServiceConst.BUILDING_HELP_INIT:
					/*view.guildHelpBtn.visible = false;
					for (var id in args[1].help_build_list)
					{
						view.guildHelpBtn.visible = true;
					}*/
					
					break;
				case ServiceConst.BUILDING_HELP_BOARD:
					/*if (User.getInstance().isInMainView)
					{
						view.guildHelpBtn.visible = true;
					}*/
					break;
				
				// 世界聊天·接受  
				case ServiceConst.WORLD_CHAT_RECEIVE:
					if (isChatNewViewShow) return;
					
					addChatPreview(getChatPreviewText("L_A_20823", args[1].name, args[1].word));
					
					worldChatList.push(args);
					
					break;
				
				// 收到公会聊天
				case ServiceConst.GET_GUILD_TALK:
					if (isChatNewViewShow) return;
					
					if (args[1] == "legionwar") {
						return;
					}
					addChatPreview(getChatPreviewText("L_A_20824", args[3], args[4]));
					
					gonghuiChatList.push(args);
					
					break;
				case ServiceConst.B_OPEN:
					var vo:SceneVo = User.getInstance().sceneInfo;
					vo.queue = args[1][0];
					updateBuildArea();
					break;
				case ServiceConst.OPEN_VIP_VIEW:
					view.vipRedTip.visible = false;
					var vState:Object = args[1].userVipInfo.reward_status;
					for (i = 0; i < User.getInstance().VIP_LV; i++ )	
					{
						if (vState[i+1] == 1)
						{
							view.vipRedTip.visible = true;
							return;
						}
					}
					break;
				default:
					break;
			}
		}
		
		/**添加聊天预览文案*/
		private function addChatPreview(msg):String {
			chat_preview_info.push(msg);
			
			renderChatPreviewBox(chat_preview_info);
		}
		
		/**获取聊天预览文案*/
		private function getChatPreviewText(title, name, content = ""):String {
			var msg:String = "[" + GameLanguage.getLangByKey(title) + "] " + name + ": " + content; 
			return ToolFunc.getActiveStr(msg, 18);
		}
		
		/**渲染聊天预览*/
		private function renderChatPreviewBox(data:Array):String {
			if (!data || data.length == 0) {
				view.dom_chat_preview.visible = false;
				view.dom_chatNew.getChildAt(0).visible = false;
				return;
			}
			view.dom_chatNew.getChildAt(0).visible = true;
			view.dom_chat_preview.visible = true;
			switch (data.length) {
				case 1:
					view.dom_chat_bg.height = 57;
					view.dom_chat_preview.y = 209;
					break;
				case 2:
					view.dom_chat_bg.height = 71;
					view.dom_chat_preview.y = 203;
					break;
				
				default:
					if (!view.dom_chat_content.mask) {
						var sp:Sprite = new Sprite();
						sp.graphics.drawRect(0, 0, view.dom_chat_preview.width, 55, "#000");
						view.dom_chat_content.mask = sp;
					}
				
					view.dom_chat_bg.height = 80;
					view.dom_chat_preview.y = 198;
					break;
			}
			data = data.slice(0, 3);
			view.dom_chat_content.destroyChildren();
			data.forEach(function(item:String) {
				var label:Label = new Label(item);
				label.color = "#f9d797";
				label.font = "Futura";
				label.fontSize = 20;
				view.dom_chat_content.addChild(label);
			});
		}

		public function updateChatImage():void
		{
			view.MainChatImage.visible=false;
			view.btn_more.getChildAt(0).visible = false;
		}

		private function updateMissionArr(stateVo:MissionStateVo):void
		{
			var len:int=_mainMissionArr.length;
			var uIndex:int=0;
			for (var i:int=0; i < len; i++)
			{
				if (_mainMissionArr[i].id == stateVo.id)
				{
					break;
				}
				uIndex++;
			}

			if (uIndex == len)
			{
				_mainMissionArr.push(stateVo)
			}
			else
			{
				_mainMissionArr[uIndex]=stateVo;
				if (_mainMissionArr[uIndex].state == 2)
				{
					_mainMissionArr.splice(uIndex, 1);
				}
			}
		}
		/**更新主界面的KPI战力*/
		private function onUpdataKPI():void
		{
			this.view.KPITF.text = User.getInstance().KPI;;
		}

		private function refreshCurrentMission():void
		{
			view.missionDesTF.text="";
			for (var i:int=0; i < 3; i++)
			{
				_mRewardImg[i].skin="";
				_mRewardNum[i].text="";
				_mRewardImg[i].visible=false;
			}
			view.goBtn.visible=false;
			if (_mainMissionArr.length == 0)
			{

				_btnIcon.skin="appRes/icon/failureIcon/icon_unfinish.png";
				return;
			}

			_curretMissionState=_mainMissionArr[0];
			_curretMissionVo=GameConfigManager.missionInfo[_curretMissionState.id];
			trace("_curretMissionVo:"+JSON.stringify(_curretMissionVo));
			if (!_curretMissionVo)
			{
				view.missionDesTF.text = _curretMissionState.id;
				return;
			}
			
			if(_curretMissionVo.task_exp=="0")
			{
				expImg.visible = expTxt.visible = false;
			}else
			{
				expImg.visible = expTxt.visible = true;
				expTxt.text = _curretMissionVo.task_exp;
			}
			
			view.missionDesTF.text=translateMissionDes();

			view.goBtn.visible=true;
			switch (_curretMissionVo.gongneng)
			{

				case "4": //人物等级
				//case "6"://基地互动
				case "8": //资源建筑
				//case "9"://怪物入侵
				//case "10"://击杀BOSS
				case "11": //好友
					//case "23":
					view.goBtn.visible=false;
					break;
				default:
					break;
			}

			_btnIcon.skin="appRes/icon/failureIcon/icon_unfinish.png";
			view.goBtn.label = GameLanguage.getLangByKey("L_A_32003");
			
			if (_curretMissionState.state == 1)
			{
				_btnIcon.skin="appRes/icon/failureIcon/icon_finish.png";
				view.goBtn.label = GameLanguage.getLangByKey("L_A_32004");
				view.goBtn.skin = "common/buttons/mission_btn.png";
				view.goBtn.visible=true;
				view.goBtn['clickSound']=ResourceManager.getSoundUrl("ui_collect_resource", 'uiSound')
			}
			else
			{
				view.goBtn.skin = "mainUi/mission/btn_1.png";
				view.goBtn['clickSound']=ResourceManager.getSoundUrl("ui_common_click", 'uiSound')
			}

			var rewardArr:Array=_curretMissionVo.reward.split(";");
			var len:int=rewardArr.length;
			
			for (var j:int=0; j < 3; j++)
			{
				if (j < len)
				{
					_mRewardImg[j].skin=GameConfigManager.getItemImgPath(rewardArr[j].split("=")[0]);
					_mRewardImg[j].visible=!view.openMissionBtn.visible;

					_mRewardNum[j].text="x" + rewardArr[j].split("=")[1];
				}
				else
				{
					_mRewardImg[j].skin="";
					_mRewardImg[j].visible=false;

					_mRewardNum[j].text="";
				}
			}
		}

		private function translateMissionDes():String
		{
			//trace("_curretMissionVo.id: ", _curretMissionVo.id);
			var orignDes:String=GameLanguage.getLangByKey(_curretMissionVo.describe);
			/*if (!_missionData.canshu1)
			{
				trace("middDatas:", _missionData);
				return;
			}*/

			var params:Array=[_curretMissionVo.canshu1, _curretMissionVo.canshu2, _curretMissionVo.canshu3, _curretMissionVo.canshu4, _curretMissionVo.canshu5];
			var paramsType:Array=_curretMissionVo.canshu_type.split("|");

			for (var i:int=0; i < paramsType.length; i++)
			{
				var replaceStr:String="";
				switch (parseInt(paramsType[i]))
				{
					case 1:
						replaceStr=params[i];
						break;
					case 2:
						replaceStr=GameLanguage.getLangByKey(DBBuilding.getBuildingById(params[i]).name);
						break;
					case 3:
						replaceStr=GameLanguage.getLangByKey(GameConfigManager.unit_dic[params[i]].name);
						break;
					case 4:
						replaceStr=GameLanguage.getLangByKey(GameConfigManager.items_dic[params[i]].name);
						break;
					case 5:
						break;
					default:
						break;
				}
				orignDes=orignDes.replace("{" + i + "}", replaceStr);
			}
			return orignDes;
		}
		
		/*private function hideHelpBtn():void
		{
			view.guildHelpBtn.visible = false;
		}*/

		public override function destroy(destroyChild:Boolean=true):void
		{
			UIRegisteredMgr.DelUi("Scence_goToFight");
			UIRegisteredMgr.DelUi("Scence_backToMenu");
			super.destroy(destroyChild);
		}

		override public function addEvent():void
		{
			this.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_INFO), this, onResult, [ServiceConst.DRAW_CARD_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, onResult, [ServiceConst.MISSION_INIT_DATA]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD), this, onResult, [ServiceConst.GET_MISSION_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_PROGRESS), this, onResult, [ServiceConst.GET_MISSION_PROGRESS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE), this, onResult, [ServiceConst.TRAN_GETTRANSPORTTYPE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_INIT), this, onResult, [ServiceConst.BUILDING_HELP_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_BOARD), this, onResult, [ServiceConst.BUILDING_HELP_BOARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, onResult, [ServiceConst.OPEN_VIP_VIEW]);

			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_NEWMAIL), this, onResult, [ServiceConst.FRIEND_NEWMAIL]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onResult, [ServiceConst.GET_GUILD_TALK]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_CHAT_RECEIVE), this, onResult, [ServiceConst.WORLD_CHAT_RECEIVE]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT), this, onResult, [ServiceConst.FRIEND_GETCHAT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUESTAPPLY), this, onResult, [ServiceConst.FRIEND_GETREQUESTAPPLY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST), this, onResult, [ServiceConst.FRIEND_GETREQUEST]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.B_OPEN), this, onResult, [ServiceConst.B_OPEN]);
			Signal.intance.on(User.PRO_CHANGED, this, this.onChangePro);
			Signal.intance.on(HomeScene.ARTICLE_UPDATE, this, this.onArticleTimeover);
			//Signal.intance.on(BuildHelpView.NO_HELP, this, hideHelpBtn);
			Signal.intance.on(CampData.UPDATE, this, this.onUpdataKPI);
		}
		
		private function onArticleTimeover():void
		{
			trace("更新建筑队列状态");
			updateBuildArea();
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_INFO), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETNAIL), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_PROGRESS), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_INIT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_BOARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_NEWMAIL), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_CHAT_RECEIVE), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUESTAPPLY), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST), this, onResult);
			
			Signal.intance.off(User.PRO_CHANGED, this, this.onChangePro);
			Signal.intance.off(HomeScene.ARTICLE_TIMEOVER, this, this.onArticleTimeover);
			Signal.intance.off(CampData.UPDATE, this, this.onUpdataKPI);
			//Signal.intance.off(User.NO_HELP, this, this.hideHelpBtn);
		}

		public function get view():MainViewUI
		{
			return this._view as MainViewUI;
		}
	}
}
