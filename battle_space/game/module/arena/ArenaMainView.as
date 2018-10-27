package game.module.arena
{
	import game.common.XUtils;
	import MornUI.arena.ArenaMainViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.ChallengeEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.module.bingBook.ItemContainer;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author ...
	 */
	public class ArenaMainView extends BaseDialog
	{

		/*private var _challengeView:ArenaChallengeView;
		private var _reportView:ArenaReportView;
		private var _rankView:ArenaRankView;*/

		//private var _maxChgTime:int = 5;

		private var _nowRankIcon:Image;
		private var _nowChgTime:int=0;
		private var _resetTime:int=0;

		private var _remainTime:int = 0;
		
		private var _refreshTimes:int = 0;
		private var _refreshCD:int=0;

		private var _canGetNum:int=0;
		private var _targetID:String="";
		private var _targetRank:String="";

		private var _changeState:int=0;

		private var _dayReward:ItemContainer;
		private var _nowRewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		private var _dayReNumTF:Text;
		
		public static var RANK_MAX_NUM:int = 25700;
		
		public static var NEED_REFRESH_LIST:Boolean = false;
		
		private var _chaItemVec:Vector.<ChallengeItem>=new Vector.<ChallengeItem>(5);

		public function ArenaMainView()
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
		}
		
		private function onClick(e:Event):void
		{
			var str:String="";
			switch (e.target)
			{
				case this.view.delopyBtn:
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SET_JINJICHANG, null, new Handler(this, openArenaView));
					break;
				case this.view.refreshBtn:
					var ppp:int = GameConfigManager.intance.getArenaRefreshPrice(_refreshTimes);
					
					
					if (ppp == 0)
					{
						refreshList();
					}
					else
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_14025"),1, ppp, function()
						{
							refreshList();
						}]);
					}
					
					break;
				case this.view.rewardBtn:
					XFacade.instance.openModule(ModuleName.ArenaDailyRewardView);
					break;
				case this.view.shopBtn:
					XFacade.instance.openModule(ModuleName.ArenaShopView);
					break;
				case this.view.resetBtn:
					var cost:String=GameConfigManager.intance.getArenaResetPrice(_resetTime);

					//str = "购买当前额外次数需要花费" + GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name) + cost.split("=")[1] +"";
					str=GameLanguage.getLangByKey("L_A_57020");
					str=str.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name));
					str=str.replace("{1}", cost.split("=")[1]);


					XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_57020"), cost.split("=")[0], cost.split("=")[1], function()
					{
						if (User.getInstance().water < parseInt(cost.split("=")[1]))
						{
							XFacade.instance.openModule(ModuleName.ChargeView);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.ARENA_RESET_TIME, []);
						}
					}]);

					/*AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
									if (v == AlertType.RETURN_YES)
									{
										if (User.getInstance().water < parseInt(cost.split("=")[1]))
										{
											XFacade.instance.openModule(ModuleName.ChargeView);
										}
										else
										{
											WebSocketNetService.instance.sendData(ServiceConst.ARENA_RESET_TIME, []);
										}
									}
								});*/
					break;

				case this.view.reportTabBtn:
					XFacade.instance.openModule(ModuleName.ArenaReportView);
					break;
				case this.view.rankTabBtn:
					XFacade.instance.openModule(ModuleName.ArenaRankView, [view.fightScoreTF.text, _changeState]);
					break;
				case view.closeBtn:
					close();
					break;
				case view.pTips:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
					break;
				case view.ruleBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_53047"));
					break;
				default:
					break;
			}
		}

		private function openArenaView():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			var obj:Object={};
			obj.fun=function()
			{
				XFacade.instance.openModule(ModuleName.ArenaMainView, true);
			};
			Laya.timer.once(100, obj, obj.fun);

		}

		private function refreshList(isFree:int=0):void
		{
			if (isFree == 0)
			{
				_refreshTimes++;
			}
			
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_REFRESH_CHALLENGE, [isFree]);
			//WebSocketNetService.instance.sendData(ServiceConst.ARENA_INIT, []);
			_refreshCD=10;
			view.refreshBtn.visible=false;
		}

		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ... args):void
		{
			trace("arenaServiecResult: ", args);
			var len:int=0;
			var i:int=0;
			switch (cmd)
			{
				case ServiceConst.ARENA_REFRESH_CHALLENGE:
					
					setChallengeInfo(args[1].enemy);
					//User.getInstance().arenaRank=args[1].arenaUserInfo.rank;
					view.curRankTF.text = parseInt(User.getInstance().arenaRank) > 0?User.getInstance().arenaRank:RANK_MAX_NUM + "+";
					_changeState=args[1].will_advance;
					switch (_changeState)
					{
						case 1:
							view.myState.skin="arena/icon_up.png";
							break
						case 0:
							view.myState.skin="arena/icon_ping.png";
							break;
						case -1:
							view.myState.skin="arena/icon_down.png";
							break;
					}
					break;
				case ServiceConst.ARENA_REST_STATE:
					view.closeArea.visible = true;
					
					User.getInstance().areanCoin=args[1].arena_coin;
					User.getInstance().arenaGroup=parseInt(args[1].mate_id);
					User.getInstance().arenaRank=args[1].rank;

					_nowRankIcon.skin="arena/r" + User.getInstance().arenaGroup + ".png";
					view.remainTF.text=GameLanguage.getLangByKey("L_A_53010") + ": " + "----:----:----";
					//view.pointTF.text = User.getInstance().areanCoin;
					//view.groupLabel.text = GameLanguage.getLangByKey(GameConfigManager.arena_group_vec[User.getInstance().arenaGroup - 1].name);
					view.curRankTF.text = parseInt(args[1].rank) > 0?args[1].rank:RANK_MAX_NUM + "+";

					view.nowImg.skin="arena/r" + args[1].mate_id + ".png";
					view.nextImg.skin="arena/r" + args[1].new_mate_id + ".png";

					if (args[1].mate_id == args[1].new_mate_id)
					{
						view.nextStateTF.text=GameLanguage.getLangByKey("L_A_53050"); //"保持";
						view.myState.skin=view.stateImg.skin="arena/icon_ping.png";
					}
					else if (parseInt(args[1].mate_id) >= parseInt(args[1].new_mate_id))
					{
						view.nextStateTF.text=GameLanguage.getLangByKey("L_A_53051"); //"降级";
						view.myState.skin=view.stateImg.skin="arena/icon_down.png";
					}
					else
					{
						view.nextStateTF.text=GameLanguage.getLangByKey("L_A_53049"); // "晋升";
						view.myState.skin=view.stateImg.skin="arena/icon_up.png";
					}

					_resetTime = parseInt(args[1].startTime) - parseInt(TimeUtil.now / 1000);
					
					if (User.getInstance().arenaRank > 0)
					{
						WebSocketNetService.instance.sendData(ServiceConst.ARENA_REWARD_STATE, [User.getInstance().arenaGroup]);
					}
					else
					{
						showCurReward([]);
					}
					
					break;
				case ServiceConst.ARENA_INIT:

					view.closeArea.visible=false;

					view.reportTabBtn.visible=true;
					view.rankTabBtn.visible=true;

					view.challangeArea.visible=true;
					//view.deloyArea.visible = true;
					view.rankLabel.visible=view.reportLabel.visible=true;

					_changeState=args[1].will_advance;

					User.getInstance().areanCoin=args[1].arena_coin;
					//User.getInstance().areanPoint=args[1].arenaUserStatus.point;
					User.getInstance().arenaRank = args[1].arenaUserInfo.rank;
					
					//view.highRankTF.text = args[1].arenaUserInfo.highest_rank;
					view.fightScoreTF.text=args[1].userStatus.power;
					_resetTime=parseInt(args[1].userStatus.buy_challenge_num_count) + 1;
					_refreshTimes=parseInt(args[1].userStatus.refresh_enemy_count) + 1;
					
					_nowChgTime=args[1].userStatus.challenge_num;
					//vip加成
					/*var vo:VIPVo = VIPVo.getVipInfo();
					_nowChgTime += vo.arena;*/
					
					view.chaTimesTF.text=_nowChgTime;
					//view.pointTF.text = User.getInstance().areanCoin;

					User.getInstance().arenaGroup=parseInt(args[1].arenaUserInfo.mate_id);
					setChallengeInfo(args[1].enemy);

					_nowRankIcon.skin="arena/r" + User.getInstance().arenaGroup + ".png";
					RANK_MAX_NUM = GameConfigManager.arena_group_vec[User.getInstance().arenaGroup - 1].all;
					view.curRankTF.text = parseInt(args[1].arenaUserInfo.rank) > 0?args[1].arenaUserInfo.rank:RANK_MAX_NUM + "+";

					_remainTime=parseInt(args[1].arenaLifeTime) - parseInt(TimeUtil.now / 1000);
					_refreshCD=0;
					if (parseInt(args[1].refreshEnemyCd) > 0)
					{
						_refreshCD=parseInt(args[1].refreshEnemyCd) - parseInt(TimeUtil.now / 1000)
					}
					switch (_changeState)
					{
						case 1:
							view.myState.skin="arena/icon_up.png";
							break
						case 0:
							view.myState.skin="arena/icon_ping.png";
							break;
						case -1:
							view.myState.skin="arena/icon_down.png";
							break;
					}
					
					if (User.getInstance().arenaRank > 0)
					{
						WebSocketNetService.instance.sendData(ServiceConst.ARENA_REWARD_STATE, [User.getInstance().arenaGroup]);
					}
					else
					{
						showCurReward([]);
					}
					break;
				case ServiceConst.ARENA_RESET_TIME:
					_resetTime=parseInt(args[1].userStatus.buy_challenge_num_count) + 1;
					_nowChgTime=args[1].userStatus.challenge_num;
					view.chaTimesTF.text=_nowChgTime;
					break;
				case ServiceConst.ARENA_CHECK_FIGHT:
					if (args[1].isFight)
					{
						FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_JINJICHANG, _targetID, new Handler(this, openArenaView));
						return;
					}
					if (parseInt(args[1].win) == 1)
					{
						XFacade.instance.openModule(ModuleName.ArenaFreeWin, [_targetRank, args[1].rank.newRank, parseInt(args[1]["rewards"][0]["num"])]);
						WebSocketNetService.instance.sendData(ServiceConst.ARENA_INIT, []);
					}
					break;
				case ServiceConst.ARENA_REWARD_STATE:
					
					if (User.getInstance().arenaRank == 0)
					{
						showCurReward([]);
						return;
					}
					
					if(parseInt(args[1].groupConfig.id) == User.getInstance().arenaGroup)
					{
						showCurReward(args[1].rankReward);
					}
					break;
				default:
					break;
			}
		}
		
		private function showCurReward(arr:Array):void
		{
			var len:int = arr.length;
			var i:int = 0;
			var reStr:String = "";
			for (i = 0; i < len; i++) 
			{
				if (User.getInstance().arenaRank <= parseInt(arr[i].up))
				{
					reStr = arr[i].reward;
					break;
				}
			}
			
			len = _nowRewardVec.length;
			for (i = 0; i < len; i++) 
			{
				_nowRewardVec[i].visible = false;
			}
			view.noGiftNotice.visible = true;
			
			if (reStr == "")
			{
				return;
			}
			
			var reArr:Array = reStr.split(";");
			len = reArr.length;
			for (i = 0; i < len; i++) 
			{
				view.noGiftNotice.visible = false;
				if (!_nowRewardVec[i])
				{
					_nowRewardVec[i] = new ItemContainer();
					_nowRewardVec[i].x = 220 - len * 30 + i * 70;
					_nowRewardVec[i].y = 47;
					_nowRewardVec[i].scaleX = _nowRewardVec[i].scaleY = 0.75;
					
					view.dayRewardArea.addChild(_nowRewardVec[i]);
				}
				_nowRewardVec[i].visible = true;
				_nowRewardVec[i].setData(reArr[i].split("=")[0],reArr[i].split("=")[1]);
			}
		}
		
		private function setChallengeInfo(enemy:Array):void
		{
			for (var i:int=0; i < 5; i++)
			{
				if (!enemy[i])
				{
					_chaItemVec[i].visible=false;
				}
				else
				{
					_chaItemVec[i].visible=true;
					_chaItemVec[i].dataSource=enemy[i];
				}
			}
		}

		private function remainTimeCount():void
		{
			if (view.closeArea.visible)
			{
				_resetTime--;

				if (_resetTime <= 1)
				{
					_resetTime=0;
					WebSocketNetService.instance.sendData(ServiceConst.ARENA_INIT, []);
				}
				view.openTimeTF.text=GameLanguage.getLangByKey("L_A_53054").replace("{0}", TimeUtil.getTimeCountDownStr(_resetTime, false));
				return;
			}

			_refreshCD--;
			if (_refreshCD <= 0)
			{
				view.refreshTF.text="";
				_refreshCD=0;
				view.refreshBtn.visible=true;
			}
			else
			{
				view.refreshTF.text=_refreshCD + "s";
				view.refreshBtn.visible=false;
			}

			_remainTime--;
			if (_remainTime <= 0)
			{
				view.remainTF.text="";
				return;
			}
			view.remainTF.text=GameLanguage.getLangByKey("L_A_53010") + ": " + TimeUtil.getTimeCountDownStr(_remainTime, false);
		}

		public function updateCoin():void
		{
			//view.pointTF.text = User.getInstance().areanCoin;
			view.foodTF.text=XUtils.formatResWith(User.getInstance().food);
			view.waterTF.text=XUtils.formatResWith(User.getInstance().water);
		}

		override public function show(... args):void
		{
			super.show();
			//AnimationUtil.flowIn(this);

			view.refreshBtn.visible=false;
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_INIT, []);
			//
			if (args[0] && NEED_REFRESH_LIST)
			{
				refreshList(1);
			}
			NEED_REFRESH_LIST = false;
			updateCoin();
			stageSizeChange();
		}

		override public function close():void
		{
			//AnimationUtil.flowOut(this, onClose);
			onClose();
		}

		private function onClose():void
		{
			super.close();
		}

		override public function dispose():void
		{
			super.dispose();

			UIRegisteredMgr.DelUi("AreaDeployBtn");
			UIRegisteredMgr.DelUi("ChallengeArea");
		}

		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String=args[2];
			if (errStr == "L_A_53046" || errStr == "L_A_907002" || errStr == "L_A_907003")
			{
				view.closeArea.visible=true;
				//view.closeNotice.visible = true;
				view.reportTabBtn.visible=false;
				view.rankTabBtn.visible=false;

				view.challangeArea.visible=false;
				//view.deloyArea.visible = false;

				//view.groupLabel.text = "";
				view.rankLabel.visible=view.reportLabel.visible=false;

				WebSocketNetService.instance.sendData(ServiceConst.ARENA_REST_STATE, []);

				for (var i:int=0; i < 5; i++)
				{
					_chaItemVec[i].visible=false;
				}
			}
			else if (errStr == "L_A_907027")
			{
				refreshList(1);
				XTip.showTip(GameLanguage.getLangByKey(errStr));
			}
			else
			{
				XTip.showTip(GameLanguage.getLangByKey(errStr));
			}
		}

		private function challengeEventHandler(e:ChallengeEvent, ... args):void
		{
			_targetID=args[0];
			_targetRank=args[1];
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_CHECK_FIGHT, [_targetID, _targetRank]);
		}

		protected function stageSizeChange(e:Event=null):void
		{
			view.size(Laya.stage.width, Laya.stage.height);
			var scaleNum:Number=Laya.stage.width / view.arenaBg.width;

			view.arenaBg.scaleX=view.arenaBg.scaleY=scaleNum;
			view.arenaBg.y=(Laya.stage.height - view.arenaBg.height * scaleNum) / 2;

			view.closeArea.x=(Laya.stage.width - 650) / 2;

			if(GameSetting.IsRelease){
				view.challangeArea.scaleX = view.challangeArea.scaleY=0.8;
				view.challangeArea.x=(Laya.stage.width - 800) / 2;
				view.challangeArea.y=(Laya.stage.height - 380) / 2;
				
				if(view.rightTopArea.scaleX > 0.8 ){
					view.rightTopArea.width *= 0.8
				}
				view.rightTopArea.scaleX = view.rightTopArea.scaleY = 0.8;
				view.leftTopArea.scaleX = view.leftTopArea.scaleY = 0.8;
					
				view.titleArea.scaleX = view.titleArea.scaleY = 0.8
				view.titleArea.x=(Laya.stage.width - 810) / 2;
			}else{
				view.challangeArea.x = (Laya.stage.width - 963) / 2;
				view.challangeArea.y=(Laya.stage.height - 380) / 2;
				view.titleArea.x=(Laya.stage.width - 1022) / 2;
			}
			
			//view.deloyArea.x = (Laya.stage.width - view.deloyArea.width) / 2;

			view.dayRewardArea.x=(Laya.stage.width - 440) / 2;
			view.dayRewardArea.y=Laya.stage.height - 120;
			
			view.rightTopArea.x=Laya.stage.width - view.rightTopArea.width;
			view.rightTopArea.y=0;

			view.LeftBottomArea.x=0;
			view.LeftBottomArea.y=Laya.stage.height - view.LeftBottomArea.height;

			view.RightBottomArea.x=Laya.stage.width - view.RightBottomArea.width;
			view.RightBottomArea.y=Laya.stage.height - view.RightBottomArea.height;

		/*_scenceView.remTimeArea.y = Laya.stage.height - 108;
		_scenceView.deployArea.y = Laya.stage.height - 110;
		_scenceView.reciveArea.y = Laya.stage.height - 119;*/
		}

		override public function createUI():void
		{
			this.closeOnBlank=true;

			this._view=new ArenaMainViewUI();
			this.addChild(_view);
			view.refreshTF.text="";

			GameConfigManager.intance.initArenaData();

			for (var i:int=0; i < 5; i++)
			{
				_chaItemVec[i]=new ChallengeItem();
				_chaItemVec[i].x=25 + 183 * i;
				_chaItemVec[i].y=-2;
				view.challangeArea.addChildren(_chaItemVec[i]);
			}

			_nowRankIcon=new Image();
			_nowRankIcon.width=_nowRankIcon.height=90;
			_nowRankIcon.skin="arena/r1.png";
			_nowRankIcon.x=350;
			_nowRankIcon.y=40;
			view.titleArea.addChild(_nowRankIcon);

			view.closeArea.visible = false;
			
			_dayReNumTF=new Text;
			_dayReNumTF.font="Futura";
			_dayReNumTF.size=24;
			_dayReNumTF.color="#ffffff";
			_dayReNumTF.x=155;
			_dayReNumTF.y=85;
			_dayReNumTF.stroke=2;
			_dayReNumTF.strokeColor="#000000";
			_dayReNumTF.text="";
			_dayReNumTF.mouseEnabled=false;
			view.dayRewardArea.addChild(_dayReNumTF);

			UIRegisteredMgr.AddUI(view.delopyBtn, "AreaDeployBtn");

		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Laya.timer.loop(1000, this, this.remainTimeCount);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_REWARD_STATE), this, serviceResultHandler, [ServiceConst.ARENA_REWARD_STATE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_CHECK_FIGHT), this, serviceResultHandler, [ServiceConst.ARENA_CHECK_FIGHT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_INIT), this, serviceResultHandler, [ServiceConst.ARENA_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_RESET_TIME), this, serviceResultHandler, [ServiceConst.ARENA_RESET_TIME]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_REFRESH_CHALLENGE), this, serviceResultHandler, [ServiceConst.ARENA_REFRESH_CHALLENGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_REST_STATE), this, serviceResultHandler, [ServiceConst.ARENA_REST_STATE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			Signal.intance.on(ChallengeEvent.CHALLENGE_PLAYER, this, this.challengeEventHandler, [ChallengeEvent.CHALLENGE_PLAYER]);
			Signal.intance.on(User.PRO_CHANGED, this, updateCoin);

			Laya.stage.on(Event.RESIZE, this, stageSizeChange);

			super.addEvent();
		}

		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			Laya.timer.clear(this, this.remainTimeCount);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_REWARD_STATE), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_CHECK_FIGHT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_RESET_TIME), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_REFRESH_CHALLENGE), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_REST_STATE), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			Signal.intance.off(ChallengeEvent.CHALLENGE_PLAYER, this, this.challengeEventHandler);
			Signal.intance.off(User.PRO_CHANGED, this, updateCoin);

			Laya.stage.off(Event.RESIZE, this, stageSizeChange);


			super.removeEvent();
		}



		private function get view():ArenaMainViewUI
		{
			return _view;
		}

	}

}
