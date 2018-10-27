package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyGroupFightViewUI;
	
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.bag.BagManager;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.armyGroup.ArmyGroupChatView;
	import game.module.armyGroup.ArmyGroupMapView;
	import game.module.armyGroup.newArmyGroup.StarVo;
	import game.module.chatNew.LiaotianView;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * ArmyGroupFightView
	 * author:huhaiming
	 * ArmyGroupFightView.as 2017-11-27 下午4:10:41
	 * version 1.0
	 *
	 */
	public class ArmyGroupFightView extends BaseView
	{
		//队伍信息界面
		private var _teamsCom:ArmyTeamsCom;
		//击杀排行
		private var _rankCom:ArmyFightRankCom;
		//战斗记录
		private var _reportCom:ArmyFightReportCom;
		//选择攻守
		private var _joinCom:ArmyJoinCom;
		//战斗表现
		private var _actCom:ArmyFightCom;
		//结果面板
		private var _resultCom:ArmyFightResultCom;
		//编辑面板
		private var _editCom:ArmyEditCom;
		/**跑马灯*/
		private var _msgCom:ArmyMsgCom;
		/**说明*/
		private var _helpCom:ArmyHelpCom;
		/**消耗提示*/
		private var _consumTip:FoodConsumTip;

		private var _data:Object;
		
		private var _moveArea:Array = [];
		
		private var _warnTipsPool:Vector.<ArmyWarnTips>;
		
		private var m_mapList:Array;
		private var m_sprMap:Sprite;
		
		/**切图宽度*/
		public static const SizeX:int=4;
		public static const SizeY:int=4;
		public static const CellW:int=575;
		public static const CellH:int = 310;
		
		/**
		 * 棋盘格子容器
		 */
		private var m_pieceObj:Object;
		private var m_pieceContainer:Sprite;
		
		private var _bfMotion:Animation;
		private var _blueFlag:Image;
		
		private var _rfMotion:Animation;
		private var _redFlag:Image;
		
		
		private var _quickRebornID:String = "";
		
		/**
		 * 自己队伍在地图上的位置
		 */
		private var _myArmyPos:Object = { };
		
		private var _curTID:String = "";
		private var _curTeamAP:int = 0;
		
		public static var CITY_LV:int = 0;
		/**设置保护粮草*/
		public static var set_food_protect:int = 0;
		private var _kNum:int = 0;
		private var _fightBegin:Boolean = false;
		private var _fightOverCount:int = 900;
		
		

		/**事件-关闭*/
		public static const CLOSE:String="army_close";

		public function ArmyGroupFightView()
		{
			super();
		}

		override public function show(... args):void
		{
			super.show();
			onStageResize();
			
			//actCom.reset();
			_curTID = "";
			ArmyDeployItem.type = "";
			view.teamsList.array = new Array(5);
			
			updateFoodTF();
			
			/*view.attInfo.visible=false;
			view.defendInfo.visible=false;*/
			
			onEnterCity(args[0]);
			//_msgCom.reset();
			
			// 聊天
			XFacade.instance.openModule(ModuleName.LiaotianView, {
				tabs: [LiaotianView.WORLD_CHAT, LiaotianView.GUILD_CHAT, LiaotianView.FRIEND_CHAT]
			});
			LiaotianView.current_module_view = this;
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_INIT_FIGHT_MAP);
		}

		override public function close():void
		{
			_teamsCom && _teamsCom.close();
			_rankCom && _rankCom.close();
			_reportCom && _reportCom.close();
			_joinCom && _joinCom.close();
			this.visible=true;
			_msgCom.reset();
			_fightBegin = false;
			_curTID = "";
			view.joinBtn.visible = false;
			view.teamsList.mouseEnabled = true;
			if(_resultCom){
				Laya.timer.clear(resultCom, resultCom.show);
			}

			//强行关闭布阵界面
			if (SceneManager.intance.m_sceneCurrent)
			{
				SceneManager.intance.m_sceneCurrent.close();
				SceneManager.intance.m_sceneCurrent=null;
			}
			
			for (var p in m_pieceObj)
			{
				m_pieceObj[p].resetState();
			}

			XFacade.instance.closeModule(ArmyGroupChatView);
			XFacade.instance.closeModule(ArmyFightSetFood);
			
			var len:int = _warnTipsPool.length;
			for (var i:int = 0; i < len; i++) 
			{
				_warnTipsPool[i].hideTips();
			}

			super.close();
			
			LiaotianView.hide();
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_LEAVE_CITY, []);
			XFacade.instance.disposeView(this);
			this.destroy();
		}

		private function onClose():void
		{
			this.close();
			
			XFacade.instance.openModule(ModuleName.ArmyGroupMapView);
		}

		private function onClick(e:Event):void
		{
			var ttii:int = 0;
			var tmp:Object = { };
			switch (e.target)
			{
				case view.chatBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupChatView);
					break;
				case view.closeBtn:
					this.onClose();
					break;
				case view.infoBtn:
					teamsCom.show();
					break;
				case view.killBtn:
					rankCom.show();
					break;
				case view.setFoodBtn:
					XFacade.instance.openModule(ModuleName.ArmyFightSetFood, User.getInstance().set_food_protect || 0);
					break;
				case view.helpBtn:
					/*if (!_helpCom)
					{
						_helpCom=new ArmyHelpCom();
					}
					_helpCom.show("L_A_20906");*/
					XFacade.instance.openModule(ModuleName.ArmyGroupHelp,"fight");
					break;
				case view.foodIcon:
					ItemTips.showTip(5);
					break;
				case view.joinBtn:
					view.joinBtn.visible = false;
					joinCom.show(_data);
					break;
				case view.autoBtn:
					//trace("当前队伍id：", _curTID);
					
					if (User.getInstance().level < 9)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_933065"));
						return;
					}
					
					if(_curTID!="")
					{
						ttii = parseInt(_curTID.split("-")[5]) - 1;						
						tmp = view.teamsList.getItem(ttii);
						
						if (tmp.isRetreat)
						{
							return;
						}
						
						if(tmp.isAuto)
						{
							view.autoBtn.skin = "armGroupFight/btn_7.png";
							tmp.isAuto = 0;
							WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SET_AUTO_FIGHT, [_curTID,0]);
						}
						else
						{
							view.autoBtn.skin = "armGroupFight/btn_8.png";
							tmp.isAuto = 1;
							WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SET_AUTO_FIGHT, [_curTID,1]);
						}
						var arr:Array = view.teamsList.array;
						arr[ttii] = tmp;
						view.teamsList.array = arr;
					}
					break;
				case view.escapeBtn:
					
					if(_curTID!="")
					{
						ttii = parseInt(_curTID.split("-")[5]) - 1;						
						tmp = view.teamsList.getItem(ttii);
						
						if (tmp.isAuto)
						{
							XTip.showTip(GameLanguage.getLangByKey("L_A_21002"));
							return;
						}
						WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_RETEAT, _curTID);
						/*if(tmp.isRetreat)
						{
							view.escapeBtn.skin = "armGroupFight/btn_6.png";
							tmp.isRetreat = 0;
							WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GIVEUP_RETEAT, _curTID);
						}
						else
						{
							view.escapeBtn.skin = "armGroupFight/btn_9.png";
							tmp.isRetreat = 1;
							WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_RETEAT, _curTID);
						}*/
						view.escapeBtn.visible = false;
						var ar:Array = view.teamsList.array;
						ar[ttii] = null;
						view.teamsList.array = ar;
					}
					
					break;
				case view.addBtn:
					if (_curTID == "")
					{
						return;
					}
					var iid:String = "";
					var inum:int = 1;
					
					if (BagManager.instance.getItemNumByID(20201>0))
					{
						iid = 20201;
					}
					else
					{
						iid = 1;
						inum = 50;
					}
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_20976"),
																			iid,
																			inum,
																			function(){									
																				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_BUY_AP,_curTID);
																			}]);
					break;
				default:
					break;
			}
		}

		//{"mapId":1,"cityId":2,"cityState":0,"role":0,"killNum":0,"atkNum":0,"defNum":0,"time":1512008209,"startFightTime":0,"fightOverTime":0}]
		private function onEnterCity(data):void
		{
			//trace("onEnterCity==============>>",data);
			if (data)
			{
				_data=data;
				//attackers;
				view.attTF.text=GameLanguage.getLangByKey("L_A_20846") + _data.atkNum;
				view.denTF.text=GameLanguage.getLangByKey("L_A_20847") + _data.defNum;

				var juntuan_city_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
				if (juntuan_city_json)
				{
					view.infoBtn.label=GameLanguage.getLangByKey(juntuan_city_json[_data.cityId].name);
				}

				if (XUtils.isEmpty(data.declareGuild))
				{
					view.homeIcon.skin="";
					view.hNameTF.text = "";
				}
				else
				{
					var info = StarVo.getGuildNameAndIconByGuildId(data.declareGuild[0], 
						{name: data.declareGuild[1], icon: data.declareGuild[2]});
					
					view.hNameTF.text = info[0];
					GameConfigManager.setGuildLogoSkin(view.homeIcon, info[1], 0.7);
					
				}

				if (XUtils.isEmpty(data.defenseGuild))
				{
					view.awayIcon.skin="";
					view.aNameTF.text = "";
				}
				else
				{
					view.aNameTF.text = data.defenseGuild[1]+"";
					GameConfigManager.setGuildLogoSkin(view.awayIcon, data.defenseGuild[2], 0.7);
				}
				
				caculateTime();

				if (_data.role == 0)
				{
					joinCom.show(_data);
					view.teamsList.visible = false;
				}else{
					view.teamsList.visible = true;
					ArmyDeployItem.type = (_data.role == 1?ArmyDeployItem.ATTACK:ArmyDeployItem.DEFEND);
				}
			}

			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_TEAMS, []);
		}

		/**解析战报,数据从服务端接收*/
		private function onFight(... args):void
		{
			trace("战斗数据更新：", args[1]);
			
			_fightOverCount = 900;
			
			var fightData:Object = args[1];
			m_pieceObj[fightData[0][8]].fightDataformat(fightData[0], 3);
			m_pieceObj[fightData[1][8]].fightDataformat(fightData[1], 3);
			
			if ((fightData[0][0] == 0 && _myArmyPos[fightData[1][7]]) ||
				(fightData[1][0] == 0 && _myArmyPos[fightData[0][7]]))
			{
				_kNum++;
				Laya.timer.once(ArmyChesspiece.SHOW_TIME, this, this.afterFight);
			}
			view.killNum.text = _kNum;
		
		}
		
		private function afterFight():void
		{
			if (_curTID)
			{
				showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
			}
			else
			{
				autoSelectTeam();
			}
		}
		
		private function onMapInit(... args):void
		{
			//trace("战斗地图初始化:", args);
			_myArmyPos = { };
			CITY_LV = args[1].city_level
			var myDelArmy:Array = view.teamsList.array;
			var userArmy:Object = args[1].users;
			//trace("userAmry:", userArmy);
			for (var ua in userArmy)
			{
				m_pieceObj[ua].setData(userArmy[ua], false);
				var myLen:int = myDelArmy.length;
				var len:int = userArmy[ua].length;
				for (var i:int = 0; i < myLen; i++) 
				{
					if (!myDelArmy[i])
					{
						continue;
					}
					for (var j:int = 0; j < len; j++) 
					{
						if (myDelArmy[i].tid == userArmy[ua][j].team_id)
						{
							//trace("找到自己的部队:", userArmy[ua][j]);
							_myArmyPos[userArmy[ua][j].team_id] = userArmy[ua][j].map_pos;
							myDelArmy[i].muscle = userArmy[ua][j].muscle;
							myDelArmy[i].isAuto = userArmy[ua][j].auto;
							myDelArmy[i].isRetreat = userArmy[ua][j].backing;
							myDelArmy[i].status = userArmy[ua][j].status;
							myDelArmy[i].rebornTime = userArmy[ua][j].revive_time;
							myDelArmy[i].hp = userArmy[ua][j].hp;
							myDelArmy[i].hp_max = userArmy[ua][j].hp_max;
						}
					}
				}
			}
			
			view.teamsList.array = myDelArmy;
			view.teamsList.refresh();
			
			var npcArmy:Object = args[1].npc;
			for (var npc in npcArmy)
			{
				m_pieceObj[npc].setData(npcArmy[npc]);
			}
			
			_kNum = 0;
			if (args[1].kill_number)
			{
				_kNum = args[1].kill_number;
			}
			
			view.killNum.text = _kNum + "";
			
			//trace("curTID:", _curTID);
			
			if(_curTID=="")
			{
				//trace("自动查找ID");
				autoSelectTeam();
			}
			else
			{
				if (!_myArmyPos[_curTID]) return;
				showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
			}
		}
		
		private function focusBlock(pos:String):void
		{
			showDragRegion();
			
			var ix:Number = parseInt(pos.split("_")[1]) * 59;
			var iy:Number = parseInt(pos.split("_")[0]) * 103;
			
			var targetX:Number=(m_sprMap.width / 2 - ix) * m_sprMap.scaleX + LayerManager.instence.stageWidth / 2;
			var targetY:Number=(m_sprMap.height / 2 - iy) * m_sprMap.scaleY + LayerManager.instence.stageHeight / 2;
			if (targetX < dragRegion.x)
			{
				targetX=dragRegion.x;
			}
			else if (targetX > dragRegion.x + dragRegion.width)
			{
				targetX=dragRegion.x + dragRegion.width
			}
			if (targetY < dragRegion.y)
			{
				targetY=dragRegion.y;
			}
			else if (targetY > dragRegion.y + dragRegion.height)
			{
				targetY=dragRegion.y + dragRegion.height
			}
			Tween.to(m_sprMap, {x: targetX, y: targetY, ease: Ease.linearOut}, 200, null, Handler.create(this, showObject));
		}
		
		private function onTeamDiedUpdate(...args):void
		{
			/*var t:int = ArmyChesspiece.SHOW_TIME+parseInt(Math.random() * 10000) % 1000;
			trace("处理死亡等待动画播完处理:",t);*/
			
			//Laya.timer.once(t, this, dealDiedInfo, [args[1]]);
			dealDiedInfo(args[1]);
		}
		
		private function dealDiedInfo(info:Object):void
		{
			//trace("处理死亡部队信息", info);
			//trace("_curTID", _curTID);
			var isCurTeam:Boolean = false;
			var arr:Array = view.teamsList.array;
			var i:int = 0;
			
			for (i = 0; i < 5; i++ )
			{
				if (!arr[i])
				{
					continue;
				}
				if (arr[i].tid == info.team_id)
				{
					if (_curTID == info.team_id )
					{
						isCurTeam = true;
					}
					findFreeTips({ type:2,tid:info.team_id});
					_quickRebornID = info.team_id
					_myArmyPos[info.team_id] = info.map_pos;
					
					arr[i].isAuto = info.auto;
					arr[i].status = info.status;
					arr[i].rebornTime = info.revive_time;
				}
			}
			view.teamsList.array = arr;
			
			m_pieceObj[info.map_pos].updateData(info);
			
			if (isCurTeam)
			{
				showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
			}
		}
		
		private function onMapUpdate(...args):void
		{
			trace("更新地图信息", args);
			if (_curTID != "" &&  _curTID == args[1].team_id)
			{
				_myArmyPos[_curTID] = args[1].map_pos;
				view.escapeBtn.visible = false;
			}
			else if(_myArmyPos[args[1].team_id])
			{
				_myArmyPos[args[1].team_id] = args[1].map_pos;
			}
			
			m_pieceObj[args[1].old_map_pos].armyMove(args[1].team_id);
			
			
			if (args[1].old_map_pos != args[1].map_pos)
			{
				var aniContainer:Box = new Box();
				aniContainer.anchorX = aniContainer.anchorY = 0.5;
				
				var moveAni:Animation = new Animation();
				m_sprMap.addChild(aniContainer);
				aniContainer.addChild(moveAni)
				
				var sx:int = (parseInt(args[1].old_map_pos.split("_")[1]) * 59);
				var sy:int = (parseInt(args[1].old_map_pos.split("_")[0]) * 103);
				
				var tx:int = (parseInt(args[1].map_pos.split("_")[1]) * 59);
				var ty:int = (parseInt(args[1].map_pos.split("_")[0]) * 103);
				
				//trace("args[1]:", args[1]);
				
				if (args[1].camp == 1)
				{
					key = "gf_attacker";
					
					if (args[1].uid == -1)
					{
						var ngID:int = parseInt(args[1].team_id.split("-")[4]);
						key = GameConfigManager.ArmyGroupNpcList[ngID].inner_apper;
					}
					
					if(sx<tx)
					{
						aniContainer.scaleX = -1;
					}
					else
					{
						aniContainer.scaleX = 1;
					}
					moveAni.loadAtlas("appRes/heroModel/" + key + "/yidong.json", new Handler(this, function() {
								var p:Point = BaseUnit.getAnimationMaxSize("appRes/heroModel/" + key + "/yidong.json");
								if (aniContainer.scaleX == -1)
								{
									moveAni.x = (139 * 0.9 - p.x) / 2 - 125;
								}
								else
								{
									moveAni.x = (139 * 0.9 - p.x) / 2;
								}
								moveAni.y = (155 * 1.2 - p.y) / 2;
						}));
				}
				else
				{
					key = "gf_defender";
					if(sx>tx)
					{
						aniContainer.scaleX = 1;
					}
					else
					{
						aniContainer.scaleX = -1;
					}
					moveAni.loadAtlas("appRes/heroModel/" + key + "/yidong.json", new Handler(this, function() {
								var p:Point = BaseUnit.getAnimationMaxSize("appRes/heroModel/" + key + "/yidong.json");
								if (aniContainer.scaleX == -1)
								{
									moveAni.x = (139 * 0.9 - p.x) / 2 - 125;
								}
								else
								{
									moveAni.x = (139 * 0.9 - p.x) / 2;
								}
								moveAni.y = (155 * 1.2 - p.y) / 2;
						}));
				}
				
				
				aniContainer.x = sx;
				aniContainer.y = sy;
				
				Tween.to(aniContainer, { x:tx, y:ty }, 500, Ease.linearNone, new Handler(this, clearMoveAni,[aniContainer,args[1]]));
			}
			else
			{
				m_pieceObj[args[1].map_pos].updateData(args[1]);
			}
			
			var teamArr:Array = view.teamsList.array;
			var len:int = teamArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (!teamArr[i])
				{
					continue;
				}
				if (teamArr[i].tid == args[1].team_id)
				{
					teamArr[i].muscle = args[1].muscle;
					teamArr[i].hp = args[1].hp;
				}
			}
			
			if (args[1].team_id == _curTID)
			{
				_curTeamAP = args[1].muscle;
			}
			
			view.teamsList.array = teamArr;
			view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
		}
		
		private function clearMoveAni(bb:Box,update:Object):void
		{
			var ani:Animation = bb.removeChildAt(0) as Animation;
			ani.stop();
			ani.clear();
			ani = null;
			
			bb.parent.removeChild(ani);
			
			m_pieceObj[update.map_pos].updateData(update);
			
			if (_curTID != '')
			{
				showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
			}
			
			if (parseInt(update.uid) != -1)
			{
				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_UPDATE_ONE_PIECE,[update.map_pos]);
			}
			
			
			/*if(update.team_id == _curTID)
			{
				showRoundBlock(update.team_id, parseInt(update.map_pos.split("_")[0]), parseInt(update.map_pos.split("_")[1]));
			}*/
		}
		
		private function onMoveOver(cmd:String,...args):void
		{
			view.escapeBtn.visible = false;
			//trace("onMoveOver:", cmd);
			/*var useAp:int = 0;
			switch(cmd)
			{
				case ServiceConst.ARMY_GROUP_FIGHT_MAP_MOVE:
					useAp = GameConfigManager.ArmyGroupBaseParam.moveCost;
					break;
				case ServiceConst.ARMY_GROUP_FIGHT_START:
					useAp = GameConfigManager.ArmyGroupBaseParam.fightCost;
					break;
				default:
					break;
			}
			
			_curTeamAP -= useAp;
			if (_curTeamAP <= 0)
			{
				_curTeamAP = 0;
			}
			view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
			
			var len:int = _moveArea.length;
			for (var i:int = 0; i < len; i++) 
			{
				_moveArea[i].setState();
			}*/
		}
		
		private function onTeamEscape(...args):void
		{
			//trace("部队自动下阵:", args);
			var arr:Array = view.teamsList.array;
			var i:int = 0;
			
			for (i = 0; i < 5; i++ )
			{
				if (!arr[i])
				{
					continue;
				}
				if (arr[i].tid == args[2])
				{
					arr[i] = undefined;
				}
			}
			view.teamsList.array = arr;
			
			if (_curTID == args[2])
			{
				_curTID = "";
				view.apLabel.text = "";
				
				var len:int = _moveArea.length;
				for (i = 0; i < len; i++) 
				{
					_moveArea[i].setState();
				}
				
				refreshTeamSelectState();
			}
			
			Laya.timer.once(750, this, function() { m_pieceObj[args[1]].armyMove(args[2]); } );
			
		}
		
		private function onSetAutoFight(...args):void
		{
			//trace("自动战斗设置完成:", args);
		}
		
		private function onBuyAPOk(...args):void
		{
			var teamArr:Array = view.teamsList.array;
			var len:int = teamArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (!teamArr[i])
				{
					continue;
				}
				if (teamArr[i].tid == args[1].team_id)
				{
					teamArr[i].muscle = args[1].muscle;
				}
			}
			
			if (args[1].team_id == _curTID)
			{
				_curTeamAP = args[1].muscle;
			}
			
			view.teamsList.array = teamArr;
			view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
		}
		
		private function autoSelectTeam():void
		{
			
			if (_curTID != "")
			{
				return;
			}
			
			var ar:Array = view.teamsList.array;
			for (var i:int = 0; i < 5; i++) 
			{
				if (ar[i])
				{
					if (_curTID == "")
					{
						_curTID = ar[i].tid;
						_curTeamAP = ar[i].muscle;
						focusBlock(_myArmyPos[_curTID]);
						showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
						
						view.escapeBtn.visible = false;
						if ((_myArmyPos[_curTID] =="5_2"|| _myArmyPos[_curTID] =="5_34") && ar[i].status != 2)
						{
							view.escapeBtn.visible = true;
							view.escapeBtn.x = 260 + i * 88;
						}
						
						ar[i].isSelect = true;
						
						if (ar[i].isAuto)
						{
							view.autoBtn.skin = "armGroupFight/btn_8.png";
						}
						else
						{
							view.autoBtn.skin = "armGroupFight/btn_7.png";
						}
						
						/*if (ar[i].isRetreat)
						{
							view.escapeBtn.skin = "armGroupFight/btn_9.png";
						}
						else
						{
							view.escapeBtn.skin = "armGroupFight/btn_6.png";
						}*/
					}
					else
					{
						ar[i].isSelect = false;
					}
					
				}
			}
			
			view.teamsList.array = ar;
			
			if (_curTID == "")
			{
				var len:int = _moveArea.length;
				for (i = 0; i < len; i++) 
				{
					_moveArea[i].setState();
				}
				view.autoBtn.skin = "armGroupFight/btn_7.png";
				
			}
		}
		
		private function onGetTeamInfo(... args):void
		{
			var arr:Array = [];
			
			//trace("arr:", arr);
			for (var j=0; j < 5; j++)
			{
				arr[j]=undefined;
			}
			
			for (var i:String in args[1])
			{
				if(args[1][i]){
					args[1][i][3]=i
				}
				var obj:Object = { };
				obj["hid"] = args[1][i][0];
				obj["br"] = args[1][i][0];
				obj["attType"] = args[1][i][2];
				obj["tid"] = args[1][i][3];
				obj["isSelect"] = false;
				arr[parseInt(obj["tid"].split("-")[5])-1] = obj;
				//arr.push(args[1][i])
			}
			
			if (!view || !view.teamsList)
			{
				Laya.timer.once(500, this, function() { 
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_TEAMS, []);
					} );
				return;
			}
			
			view.teamsList.array = arr;
			view.teamsList.refresh();
		}

		private function onTeamUpdate(... args):void
		{
			trace("onTeamUpdate::", args)
			//[35886,[8,"11-1512098113","1001",11258,"No.008",46,"FFF","2"],2]
			//防守数据不一致，第三位不需要。修改数据源,
			/*if (args[2] == 2)
			{
				(args[1] as Array).splice(2, 1);
			}*/
			var arr:Array = view.teamsList.array;
			var teamId:String = args[1][1];
			var id:*= args[1][3];
			var kpi:int = args[1][4];

			for (var i:int=0; i < arr.length; i++)
			{
				if (arr[i] && arr[i].tid == teamId)
				{
					arr[i] = undefined;
					break;
				}
			}
			
			var insetID:int = parseInt(teamId.split("-")[5]) - 1;
			
			var obj:Object = { };
			obj["hid"] = id;
			obj["br"] = kpi;
			obj["tid"] = teamId;
			obj["muscle"] = GameConfigManager.ArmyGroupBaseParam.APInit;
			arr[insetID] = obj;
			
			//trace("当前上阵数据:", arr);
			_myArmyPos[args[1][1]] = args[1][10];
			
			view.escapeBtn.visible = true;
			view.escapeBtn.x = 260 + insetID * 88;
			
			_curTID = teamId;
			_curTeamAP = obj.muscle;
			focusBlock(_myArmyPos[_curTID]);
			showRoundBlock(_curTID, parseInt(_myArmyPos[_curTID].split("_")[0]), parseInt(_myArmyPos[_curTID].split("_")[1]));
			
			for (i = 0; i < 5; i++ )
			{
				if (i == insetID)
				{
					arr[i].isSelect = true;
				}
				else if (arr[i])
				{
					arr[i].isSelect = false;
				}
			}
			
			view.teamsList.array = arr;
			view.teamsList.refresh();
			
			
		}

		private function onMsg(... args):void
		{
			_msgCom.show(args);
		}

		private function onUpdateInfo(... args):void
		{
			if (args[1] == 1)
			{
				this.view.attTF.text="Attacker:" + args[2];
			}
			else if (args[1] == 2)
			{
				view.denTF.text="Defender:" + args[2];
			}
		}
		
		private function onUpdateOneBlock(...args):void
		{
			//trace("更新单个格子数据:", args);
			m_pieceObj[args[1].map_pos].setData(args[1].npc);
			m_pieceObj[args[1].map_pos].setData(args[1].users, false);
		}

		private function onItemClick(e:Event, index:int):void
		{
			//trace("选中队伍e:", e, "index:", index);
			e.stopPropagation();
			if (e.type == Event.CLICK)
			{
				
				//todo 判定是否有数据
				var data:Object = view.teamsList.getItem(index);
				//trace("选中队伍index:", index, "data:", data);
				
				view.autoBtn.skin = "armGroupFight/btn_7.png";
				
				if (!data)
				{
					view.escapeBtn.visible = false;
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SET_ARMY, index+1, Handler.create(this, this.onFightOver, null, false));
					this.visible=false;
					LiaotianView.hide();
					XFacade.instance.getView(ArmyGroupMapView).visible=false;
				}
				else
				{
					_curTID = data.tid;
					_curTeamAP = data["muscle"];
					refreshTeamSelectState(index);
					view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
					
					if (data.isAuto)
					{
						view.autoBtn.skin = "armGroupFight/btn_8.png";
					}
					
					if (data.status == 2)
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_85019"),1, GameConfigManager.ArmyGroupBaseParam.rebornPrice, function()
																	{
																		WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_REBORN_TEAM, [_curTID]);
																	}]);
					}
					
					trace("_curTID:", _curTID);
					trace("_myArmyPos:", _myArmyPos[_curTID]);
					view.escapeBtn.visible = false;
					if ((_myArmyPos[_curTID] =="5_2"|| _myArmyPos[_curTID] =="5_34") && data.status != 2)
					{
						view.escapeBtn.visible = true;
						view.escapeBtn.x = 260 + index * 88;
					}
					
					
					//if(data[2] == 1){//已出战
					if(data.tid){//已出战
						//XTip.showTip("L_A_20930");
						/*trace("_myArmyPos：", _myArmyPos);
						trace("查找队伍ID：", data);*/
						if (_myArmyPos[data.tid])
						{
							//trace("移动到格子", _myArmyPos[data.tid]);
							m_pieceObj[_myArmyPos[data.tid]].findMyArmy(data.tid);
							focusBlock(_myArmyPos[data.tid]);
							showRoundBlock(data.tid, parseInt(_myArmyPos[data.tid].split("_")[0]), parseInt(_myArmyPos[data.tid].split("_")[1]));
						}
						
					}else{
						editCom.show(data, index);
					}
				}
			}
		}
		
		private function onNoFood():void
		{
			findFreeTips( { type:1, tid:_curTID } );
			
			var arr:Array = view.teamsList.array;
			var i:int = 0;
			
			for (i = 0; i < 5; i++ )
			{
				if (!arr[i])
				{
					continue;
				}
				arr[i].isAuto = 0;
			}
			view.autoBtn.skin = "armGroupFight/btn_7.png";
			view.teamsList.array = arr;
			
			// 食物不足打开商店
			XFacade.instance.openModule(ModuleName.StoreView, [2]);
		}
		
		private function findFreeTips(data:Object):void
		{
			var len:int = _warnTipsPool.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				if (!_warnTipsPool[i].isActivity)
				{
					_warnTipsPool[i].showTips(data);
					return;
				}
			}
			
			_warnTipsPool[0].hideTips();
			this.removeChild(_warnTipsPool.shift());
			
			_warnTipsPool.push(new ArmyWarnTips());
			this.addChild(_warnTipsPool[_warnTipsPool.length - 1]);
			_warnTipsPool[_warnTipsPool.length - 1].showTips(data);
			
		}
		
		private function onTeamReborn(...args):void
		{
			//trace("复活信息:", args[1]);
			var arr:Array = view.teamsList.array;
			var i:int = 0;
			
			for (i = 0; i < 5; i++ )
			{
				if (!arr[i])
				{
					continue;
				}
				if (arr[i].tid == args[1].team_id)
				{
					arr[i].status = args[1].team_info.status;
					arr[i].muscle = args[1].team_info.muscle;
					arr[i].hp = args[1].team_info.hp;
					arr[i].rebornTime = 0;
				}
			}
			
			if(args[1].team_id == _curTID)
			{
				view.escapeBtn.visible = true;
			
				view.escapeBtn.x = 260 + (parseInt(args[1].team_id.split("-")[5]) - 1) * 88;
				_curTeamAP = 100;
			}
			view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
			view.teamsList.array = arr;
		}
		
		private function refreshTeamSelectState(chooseIndex:int = -1):void
		{
			var arr:Array = view.teamsList.array;
			var len:int = arr.length;
			var i:int = 0;
			for (i = 0; i < len; i++ )
			{
				if (arr[i])
				{
					arr[i].isSelect = false;
				}
			}
			
			if (chooseIndex != -1)
			{
				if (!arr[chooseIndex])
				{
					/*trace("=================================")
					trace("teamsList:", arr);
					trace("chooseIndex:", chooseIndex);
					trace("=================================")*/
				}
				arr[chooseIndex].isSelect= true;
			}
			
			
			view.teamsList.array = arr;
			view.teamsList.refresh();
		}

		private function onEditTeam(type:String, data:Object):void
		{
			switch (type)
			{
				case ArmyEditCom.EDIT:
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SET_ARMY, data[3], Handler.create(this, this.onFightOver, null, false));
					this.visible=false;
					LiaotianView.hide();
					XFacade.instance.getView(ArmyGroupMapView).visible=false;
					break;
				case ArmyEditCom.DOWN:
					Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_TEAM_DOWN), null, onTeamDown);
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_FIGHT_TEAM_DOWN, [data[3]]);
					break;
			}

			function onTeamDown(... args):void
			{
				if (args[1] == 1)
				{
					var arr:Array=view.teamsList.array;
					for (var i:int=0; i < arr.length; i++)
					{
						if (arr[i] && arr[i].tid == data[3])
						{
							arr.splice(i, 1);
							arr.push(undefined);
							break;
						}
					}
					view.teamsList.array=arr;
					view.teamsList.refresh();
				}
			}
		}
		
		private function onTeamChange():void{
			ArmyDeployItem.type = (_data.role == 1?ArmyDeployItem.ATTACK:ArmyDeployItem.DEFEND);
			view.teamsList.refresh();
			
			view.teamsList.visible = true;
			view.joinBtn.visible = false;
		}
		
		private function onJoinLater():void{
			view.joinBtn.visible = true;
		}
		
		/**军粮信息*/
		private function updateFoodTF():void{
			var num = Math.max(User.getInstance().food - User.getInstance().set_food_protect, 0);
			this.view.foodTF.text = XUtils.formatResWith(num); 
		}
		
		/**设置保护食物*/
		private function onSetFood(...args):void{
			User.getInstance().set_food_protect = Number(args[1]);
			updateFoodTF();
		}

		private function onFightOver():void
		{
			if (SceneManager.intance.m_sceneCurrent)
			{
				SceneManager.intance.m_sceneCurrent.close();
				SceneManager.intance.m_sceneCurrent=null;
			}
			XFacade.instance.getView(ArmyGroupMapView).visible=true;
			this.visible=true;
			LiaotianView.show();
			//XFacade.instance.openModule("ArmyGroupFightView")
		}
		
		public function updateAP():void
		{
			var arr:Array = view.teamsList.array;
			var len:int = 5;
			for (var i:int = 0; i < len; i++) 
			{
				if (arr[i])
				{
					if (parseInt(arr[i].muscle) < GameConfigManager.ArmyGroupBaseParam.APMax)
					{
						arr[i].muscle = parseInt(arr[i].muscle) + parseInt(GameConfigManager.ArmyGroupBaseParam.APReborn+(1+GameConfigManager.vip_info[User.getInstance().VIP_LV].vitality_restore));
						if (parseInt(arr[i].muscle) >= GameConfigManager.ArmyGroupBaseParam.APMax)
						{
							arr[i].muscle = GameConfigManager.ArmyGroupBaseParam.APMax;
						}
					}
				}
			}
			
			if (_curTID!="")
			{
				if (_curTeamAP < GameConfigManager.ArmyGroupBaseParam.APMax)
				{
					_curTeamAP += parseInt(GameConfigManager.ArmyGroupBaseParam.APReborn+(1+GameConfigManager.vip_info[User.getInstance().VIP_LV].vitality_restore));
					if (_curTeamAP >= GameConfigManager.ArmyGroupBaseParam.APMax)
					{
						_curTeamAP = GameConfigManager.ArmyGroupBaseParam.APMax;
					}
				}
				view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
			}
			else
			{
				view.apLabel.text = "";
			}
			
			view.teamsList.array = arr;
			view.teamsList.refresh();
			
			if (_fightBegin)
			{
				//trace("_fightOverCount:", _fightOverCount);
				_fightOverCount--;
				if (_fightOverCount <= 60)
				{
					view.timeLabel.text = "L_A_20851";
					view.timeBg.skin = "armGroupFight/bg11_4.png";
					view.timeTF.text = TimeUtil.getTimeCountDownStr(_fightOverCount, false);
					view.teamBox.visible = true;
				}
				else
				{
					view.teamBox.visible = false;
				}
			}
			
			
		}
		
		private function caculateTime():void
		{
			if (_fightBegin)
			{
				return;
			}
			
			var time:Number;
			//战斗还没开始
			if (_data.startFightTime > _data.time)
			{
				_fightBegin = false;
				view.timeLabel.text = "L_A_20850";
				view.timeBg.skin = "armGroupFight/bg11_3.png";
				time = _data.startFightTime - _data.time;
				view.timeTF.text = TimeUtil.getTimeCountDownStr(time, false);
				Laya.timer.once(1000, this, caculateTime);
				view.teamBox.visible = true;
			}
			else
			{
				_fightOverCount = 900;
				_fightBegin = true;
			}
			
			_data.time+=1;
//			trace("倒计时", view.timeTF.text)
		}

		private function onResult(... args):void
		{
			
			_fightBegin = false;
			
			//Laya.timer.once(5000, actCom, actCom.reset);
			Laya.timer.clear(this, caculateTime);
			args[1].role=_data.role; //传递状态
			
			Laya.timer.once(5000, resultCom, resultCom.show, [args[1]]);
			view.teamsList.mouseEnabled = false;
			//resultCom.show(args[1]);
		}

		/***/
		private function onChange(... args):void
		{
			/*trace("onChange::", args)
			var arr:Array=view.teamsList.array;
			var list:Array=args[1];
			var tmp:Object;
			for (var i=0; i < arr.length; i++)
			{
				tmp=arr[i];
				if (tmp && list.indexOf(tmp[3]) != -1)
				{
					tmp[2]=1;
				}
			}
			view.teamsList.array=arr;
			view.teamsList.refresh();*/
			// [35885,["11-1512037765","11-1512037769","11-1512037772"]]

		}

		private function get teamsCom():ArmyTeamsCom
		{
			if (!_teamsCom)
			{
				_teamsCom=new ArmyTeamsCom();
			}
			return _teamsCom;
		}

		private function get rankCom():ArmyFightRankCom
		{
			if (!_rankCom)
			{
				_rankCom=new ArmyFightRankCom();
			}
			return _rankCom;
		}

		private function get reportCom():ArmyFightReportCom
		{
			if (!_reportCom)
			{
				_reportCom=new ArmyFightReportCom();
			}
			return _reportCom;
		}

		private function get actCom():ArmyFightCom
		{
			if (!_actCom)
			{
				_actCom=new ArmyFightCom(_view);
			}
			return _actCom;
		}

		private function get joinCom():ArmyJoinCom
		{
			if (!_joinCom)
			{
				_joinCom=new ArmyJoinCom();
			}
			return _joinCom;
		}

		private function get resultCom():ArmyFightResultCom
		{
			if (!_resultCom)
			{
				_resultCom=new ArmyFightResultCom();
			}
			return _resultCom;
		}

		private function get editCom():ArmyEditCom
		{
			if (!_editCom)
			{
				_editCom=new ArmyEditCom(this.view.bottomBox, view.teamsList);
			}
			return _editCom;
		}

		override public function onStageResize():void
		{
			this.view.height=Laya.stage.height;
			if(GameSetting.isIPhoneX){
				var delScale:Number = LayerManager.fixScale;
				this.view.bg.scaleX = this.view.bg.scaleY = delScale;
				this.view.bar.x = (Laya.stage.width - this.view.bar.width)/2;
				this.view.closeBtn.x = Laya.stage.width - this.view.closeBtn.width;
				this.view.bgBottom.width = Laya.stage.width;
				this.view.killBtn.x  = Laya.stage.width - this.view.killBtn.width - 20;
				//this.view.teamBox.x = (Laya.stage.width - this.view.teamBox.width) >> 1;
				this.view.armyBox.height = this.view.bg.height;
				//this.view.fightBox.x = (Laya.stage.width - this.view.fightBox.width)>>1;
				this.view.msgBox.x = (Laya.stage.width-this.view.msgBox.width)>>2;
				this.view.rightInfoBox.x = Laya.stage.width-this.view.rightInfoBox.width;
				//this.view.fightBox.y += 40;
				this.view.width = Laya.stage.width;
			}else{
				this.view.armyBox.y=(Laya.stage.height - this.view.armyBox.height) / 2;
			}
			view.joinBtn.y = Laya.stage.height - 100;
			
			this.view.bottomBox.y=Laya.stage.height - this.view.bottomBox.height;
			view.chatBtn.y=LayerManager.instence.stageHeight - view.chatBtn.height >> 1;
		}
		
		private function mapStarDropHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			//trace("mapStarDropHandler:", e.target);
			var str:String;
			switch (e.target)
			{
				
				default:
					break;
			}
			
			showDragRegion();
			m_sprMap.startDrag(dragRegion, true, 0, 200, null, true);
			showObject();
		}
		
		private function changeVisivilityHandler(e:Event):void
		{
			// TODO Auto Generated method stub
		}

		private function mapStopDropHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			m_sprMap.stopDrag();
			showObject();
		}
		public var dragRegion:Rectangle;

		protected function showDragRegion():void
		{
			var dragWidthLimit:int=m_sprMap.width * m_sprMap.scaleX - Laya.stage.width;
			var dragHeightLimit:int=m_sprMap.height * m_sprMap.scaleY - Laya.stage.height;
			dragRegion=new Rectangle(Laya.stage.width - dragWidthLimit >> 1, Laya.stage.height - dragHeightLimit >> 1, dragWidthLimit, dragHeightLimit);
		}
		
		private function showObject():void
		{
			var p:Point;
			for (var index in m_pieceObj)
			{
				p = new Point(m_pieceObj[index].x, m_pieceObj[index].y);
				p = m_sprMap.localToGlobal(p);
				if (p.x < -200 || p.y < -200 || p.x > Laya.stage.width + 50 || p.y > Laya.stage.height + 50)
				{
					m_pieceObj[index].visible = false;
					
				}
				else
				{
					m_pieceObj[index].visible=true;
				}
			}
			
			/*for (var i:int=0; i < _plantVec.length; i++)
			{
				p=new Point(_plantVec[i].x, _plantVec[i].y);
				p=m_sprMap.localToGlobal(p);
				if (p.x < -50 || p.y < -50 || p.x > Laya.stage.width + 50 || p.y > Laya.stage.height + 50)
				{
					_plantVec[i].visible=true;
				}
				else
				{
					_plantVec[i].visible=true;
				}
			}*/
		/*//判定地图是否在显示框中..
		for(i=0; i<_imgs.length; i++){
			p = new Point(_imgs[i].x, _imgs[i].y);
			p = m_sprMap.localToGlobal(p);
			if(p.x < -CellW-120 || p.y < -CellH-120 || p.x > Laya.stage.width+60 || p.y >Laya.stage.height+60){
				_imgs[i].visible = false;
				Loader.clearRes(_imgs[i].name);
				_imgs[i].skin = "";
			}else{
				_imgs[i].visible = true;
				_imgs[i].skin = _imgs[i].name;
			}
		}*/
		}
		
		/***/
		private function onScale(e:Event):void
		{
			var deltaScale:Number=e.delta / 30;
			doScale(deltaScale);
		}

		private function doScale(deltaScale:Number):void
		{
			var scale:Number=m_sprMap.scaleX;
			scale+=deltaScale;
			if (scale > 1)
			{
				scale=1;
			}
			
			if (scale < 0.72)
			{
				scale=0.72;
			}

			m_sprMap.scaleX=m_sprMap.scaleY=scale;
			this.showDragRegion();
			m_sprMap.stopDrag();
			if (scale != 1)
			{
				if (m_sprMap.x < dragRegion.x)
				{
					m_sprMap.x=dragRegion.x;
				}
				else if (m_sprMap.x > dragRegion.x + dragRegion.width)
				{
					m_sprMap.x=dragRegion.x + dragRegion.width
				}
				if (m_sprMap.y < dragRegion.y)
				{
					m_sprMap.y=dragRegion.y;
				}
				else if (m_sprMap.y > dragRegion.y + dragRegion.height)
				{
					m_sprMap.y=dragRegion.y + dragRegion.height
				}
			}
			showObject();
//			for(var i:int=0; i<_plantVec.length; i++){
//				_plantVec[i].doScale(scale)
//			}
		}
		
		private function onDragEnd():void
		{
			// TODO Auto Generated method stub
			showObject();
		}
		
		public function armyGroupEventHandler(cmd:String, ... args):void
		{
			switch (cmd)
			{
				case ArmyGroupEvent.SELECT_MAP_PIECE:
					//trace("选中格子:", args[0]);
					showRoundBlock(args[0].team_id, parseInt(args[1].split("_")[0]), parseInt(args[1].split("_")[1]));
					refreshTeamSelectState(parseInt(args[0].team_id.split("-")[5]) - 1);
					
					_curTID = args[0].team_id;
					_curTeamAP = view.teamsList.getItem(parseInt(args[0].team_id.split("-")[5]) - 1).muscle;
					view.apLabel.text = _curTeamAP + "/" + GameConfigManager.ArmyGroupBaseParam.APMax;
					break;
				case ArmyGroupEvent.CANCEL_SELECT_ARMY:
					/*_curTID = "";
					view.apLabel.text = "";
					var len:int = _moveArea.length;
					for (var i:int = 0; i < len; i++) 
					{
						_moveArea[i].setState();
					}
					refreshTeamSelectState();*/
					break;
				default:
					break;
			}
		}
		
		
		
		private function showRoundBlock(tid:String,sx:int, sy:int):void
		{
			var len:int = _moveArea.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				_moveArea[i].setState();
			}
			
			_moveArea = [];
			if (m_pieceObj[(sx) + "_" + (sy+2)])
			{
				_moveArea.push(m_pieceObj[(sx) + "_" + (sy+2)])
			}
			
			if (m_pieceObj[(sx) + "_" + (sy-2)])
			{
				_moveArea.push(m_pieceObj[(sx) + "_" + (sy-2)])
			}
			
			if (m_pieceObj[(sx + 1) + "_" + (sy + 1)])
			{
				_moveArea.push(m_pieceObj[(sx + 1) + "_" + (sy + 1)]);
			}
			
			if (m_pieceObj[(sx + 1) + "_" + (sy - 1)])
			{
				_moveArea.push(m_pieceObj[(sx + 1) + "_" + (sy - 1)]);
			}
			
			if (m_pieceObj[(sx - 1) + "_" + (sy + 1)])
			{
				_moveArea.push(m_pieceObj[(sx - 1) + "_" + (sy + 1)]);
			}
			
			if (m_pieceObj[(sx - 1) + "_" + (sy - 1)])
			{
				_moveArea.push(m_pieceObj[(sx - 1) + "_" + (sy - 1)]);
			}
			
			len = _moveArea.length;
			for ( i = 0; i < len; i++) 
			{
				_moveArea[i].setState(tid,2,_data.role);
			}
		}
		
		private function onActive():void
		{
			if (!_fightBegin)
			{
				return;
			}
			
			for (var index in m_pieceObj)
			{
				m_pieceObj[index].resetState();
				m_pieceObj[index].updateAnimation();
			}
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_INIT_FIGHT_MAP);
		}
		
		//多点问题
		private var lastDistance:Number = 0;
		private function onMouseUp(e:Event=null):void{
			Laya.stage.off(Event.MOUSE_MOVE, this, onMouseMove);
			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
			showObject();
		}
		private function onMouseDown(e:Event=null):void
		{
			var touches:Array = e.touches;
			
			if(touches && touches.length == 2)
			{
				lastDistance = getDistance(touches);
				
				Laya.stage.on(Event.MOUSE_MOVE, this, onMouseMove);
				Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
			}
		}
		//
		private var _lastDel:Number=0;
		private var key:String;
		private function onMouseMove(e:Event=null):void
		{
			var distance:Number = getDistance(e.touches);
			
			//判断当前距离与上次距离变化，确定是放大还是缩小
			const factor:Number = 0.001;
			var del:Number = (distance - lastDistance) * factor;
			// 特殊处理关于拉伸的问题
			if(_lastDel > 0 && del < -0.2){
				//不进行缩放
			}else{
				doScale(del);
			}
			//
			if(del != 0){
				_lastDel = del;
			}
			lastDistance = distance;
		}
		/**计算两个触摸点之间的距离*/
		private function getDistance(points:Array):Number
		{
			var distance:Number = 0;
			if (points && points.length == 2)
			{
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}

		private function onDragStart():void
		{
			// TODO Auto Generated method stub
			showObject();
		}

		
		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			if (errStr == "L_A_933060" || errStr == "L_A_933057")
			{
				return;
			}
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}

		override public function createUI():void
		{
			
			this.m_sprMap=new Sprite();
			m_sprMap.width=SizeX * CellW;
			m_sprMap.height=SizeY * CellH;
			m_sprMap.mouseEnabled=true;
			this.addChild(m_sprMap);
			
			m_sprMap.pivot(m_sprMap.width / 2, m_sprMap.height / 2);
			m_sprMap.x = Laya.stage.width / 2;
			m_sprMap.y = Laya.stage.height / 2;			
			
			m_mapList = new Array();
			var i:int = 0;
			for (i = 0; i < SizeX * SizeY; i++)
			{
				var image:Image;
				if (i < 9)
				{
					image=new Image(ResourceManager.instance.setResURL("armyGroupMap/AMFightBg_0" + (i + 1) + ".jpg"));
				}
				else
				{
					image=new Image(ResourceManager.instance.setResURL("armyGroupMap/AMFightBg_" + (i + 1) + ".jpg"));
				}
				
				image.width=CellW;
				image.height=CellH;
				image.name="image" + i;
				var yNum:int=parseInt(i / SizeY);
				var xNum:int=parseInt(i % SizeX);
				m_sprMap.addChild(image);
				image.x=CellW * (xNum);
				image.y=CellH * yNum;
				m_mapList.push(image);
			}
			
			
			_blueFlag = new Image(ResourceManager.instance.setResURL("armyGroupMap/lan.png"));
			_blueFlag.x = m_sprMap.width - 150;
			_blueFlag.y = m_sprMap.height / 2 - 265;
			m_sprMap.addChild(_blueFlag);
			
			_bfMotion = new Animation();
			_bfMotion.interval = 100;
			_bfMotion.x = _blueFlag.x+32;
			_bfMotion.y = _blueFlag.y;
			_bfMotion.loadAtlas("appRes/atlas/effects/bFlag.json");
			_bfMotion.play();
			m_sprMap.addChild(_bfMotion);
			
			_redFlag = new Image(ResourceManager.instance.setResURL("armyGroupMap/hong.png"));
			_redFlag.x = 10;
			_redFlag.y = m_sprMap.height / 2 - 200;
			m_sprMap.addChild(_redFlag);
			
			_rfMotion = new Animation();
			_rfMotion.interval = 100;
			_rfMotion.x = _redFlag.x-32;
			_rfMotion.y = _redFlag.y;
			_rfMotion.loadAtlas("appRes/atlas/effects/rFlag.json");
			_rfMotion.play();
			m_sprMap.addChild(_rfMotion);
			
			
			m_pieceContainer = new Sprite();
			m_pieceContainer.x = 140;
			m_pieceContainer.y = 200;
			m_sprMap.addChild(m_pieceContainer);
			m_pieceObj = { };
			var l:int = 0;
			for (var j:int = 0; j < 9; j++) 
			{
				if (j%2==0)
				{
					l = 17;
				}
				else
				{
					l = 16;
				}
				for (var k:int = 0; k < l; k++) 
				{
					var ix:int = j + 1;
					var iy:int = 0;
					var index:String = "";
					if (j%2==0)
					{
						iy = (k + 1) * 2;
					}
					else
					{
						iy = (k + 1) * 2 + 1;
					}
					index = ix + "_" + iy;
					m_pieceObj[index] = new ArmyChesspiece(index);
					m_pieceObj[index].x = (iy-2) * 59;
					m_pieceObj[index].y = (ix-2) * 103;
					m_pieceContainer.addChild(m_pieceObj[index]);
				}
			}
			
			var line = 1;
			for each(var hid in GameConfigManager.ArmyGroupFightMap) {
				//trace("hid:",hid);
				for (var lid in hid) {
					if (hid[lid] != "1" && lid != "H_id" && lid != "type")
					{
						var sIndex:String = "" + line+"_" + lid.substr(1);
						//sIndex.substr
						//trace("sInde:" + sIndex + "     llllid:", hid[lid]);
						if (m_pieceObj[sIndex]) {
							m_pieceObj[sIndex].setInitInfo(hid[lid]);
						}
					}
				}
				line++;
			}
			
			_view=new ArmyGroupFightViewUI();
			this.addChild(_view);
			_view.mouseThrough = true;
			view.killNum.text = "";
			view.apLabel.text = "";
			
			view.bottomBox.mouseThrough = true;
			view.escapeBtn.visible = false;
			
			//view.bg.skin="appRes/scene/groupFight.jpg";
			view.teamsList.itemRender=ArmyDeployItem;
			view.joinBtn.visible = false;
			view.foodIcon.skin = GameConfigManager.getItemImgPath(5);
				
			_msgCom = new ArmyMsgCom(view.msgBox);
			
			_warnTipsPool = new Vector.<ArmyWarnTips>();
			for (i = 0; i < 3;i++ )
			{
				_warnTipsPool[i] = new ArmyWarnTips();
				_warnTipsPool[i].hideTips();
				this.addChild(_warnTipsPool[i]);
			}
			
			// 国战地图聊天隐藏
			view.chatBtn.visible = false;
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(CLOSE, this, this.onClose);
			Signal.intance.on(ArmyEditCom.EDIT, this, this.onEditTeam, [ArmyEditCom.EDIT]);
			Signal.intance.on(ArmyEditCom.DOWN, this, this.onEditTeam, [ArmyEditCom.DOWN]);
			Signal.intance.on(ArmyJoinCom.TEAM_CAHNGE, this, this.onTeamChange);
			Signal.intance.on(ArmyJoinCom.TEAM_WAIT, this, this.onJoinLater);
			Signal.intance.on(User.PRO_CHANGED, this, this.updateFoodTF);
			
			Laya.timer.loop(1000, this, updateAP);
			
			Signal.intance.on(ArmyGroupEvent.SELECT_MAP_PIECE, this, this.armyGroupEventHandler,[ArmyGroupEvent.SELECT_MAP_PIECE]);
			Signal.intance.on(ArmyGroupEvent.CANCEL_SELECT_ARMY, this, this.armyGroupEventHandler,[ArmyGroupEvent.CANCEL_SELECT_ARMY]);
			
			Laya.stage.on(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
			m_sprMap.on(Event.DRAG_START, this, onDragStart);
			m_sprMap.on(Event.DRAG_END, this, onDragEnd);
			this.m_sprMap.on(Event.MOUSE_DOWN, this, this.mapStarDropHandler);
			this.m_sprMap.on(Event.MOUSE_UP, this, this.mapStopDropHandler);
			this.on(Event.VISIBILITY_CHANGE, this, this.changeVisivilityHandler);
			this.on(Event.MOUSE_WHEEL, this, this.onScale);
			
			Laya.stage.on(Event.FOCUS, this, this.onActive, [Event.FOCUS]);
			
			this.view.teamsList.mouseHandler=Handler.create(this, this.onItemClick, null, false);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_INIT_FIGHT_MAP), this, onMapInit);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATE_BLOCK), this, onMapUpdate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAM_DIED), this, onTeamDiedUpdate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_MAP_MOVE), this, onMoveOver);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_START), this, onMoveOver);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_AP), this, onBuyAPOk);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_AUTO_FIGHT), this, onSetAutoFight);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAM_ESCAPE), this, onTeamEscape);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAMS), this, onGetTeamInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_REBORN_TEAM), this, onTeamReborn);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FOOD_EMPTY), this, onNoFood);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_FOOD), this, onSetFood);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_REPORT), this, onFight);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_RESULT), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DEPLOY_UPDATE), this, onTeamUpdate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_LAMP), this, onMsg);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_ARMY_CHANGE), this, onUpdateInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATE_ONE_PIECE), this, onUpdateOneBlock);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(CLOSE, this, this.onClose);
			Signal.intance.off(ArmyEditCom.EDIT, this, this.onEditTeam);
			Signal.intance.off(ArmyEditCom.DOWN, this, this.onEditTeam);
			Signal.intance.off(ArmyJoinCom.TEAM_CAHNGE, this, this.onTeamChange);
			Signal.intance.off(ArmyJoinCom.TEAM_WAIT, this, this.onJoinLater);
			this.view.teamsList.mouseHandler = null
			
			Laya.stage.off(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
			Signal.intance.off(User.PRO_CHANGED, this, this.updateFoodTF);
			
			Laya.timer.clear(this, updateAP);
			
			this.m_sprMap.off(Event.MOUSE_DOWN, this, this.mapStarDropHandler);
			this.m_sprMap.off(Event.MOUSE_UP, this, this.mapStopDropHandler);
			this.off(Event.VISIBILITY_CHANGE, this, this.changeVisivilityHandler);
			m_sprMap.off(Event.DRAG_START, this, onDragStart);
			m_sprMap.off(Event.DRAG_END, this, onDragEnd);
			this.off(Event.MOUSE_WHEEL, this, this.onScale);
			
			Signal.intance.off(ArmyGroupEvent.SELECT_MAP_PIECE, this, armyGroupEventHandler);
			Signal.intance.off(ArmyGroupEvent.CANCEL_SELECT_ARMY, this, armyGroupEventHandler);
			
			Laya.stage.off(Event.FOCUS, this, this.onActive);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_INIT_FIGHT_MAP), this, onMapInit);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATE_BLOCK), this, onMapUpdate);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAM_DIED), this, onTeamDiedUpdate);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_MAP_MOVE), this, onMoveOver);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_START), this, onMoveOver);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_AP), this, onBuyAPOk);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_AUTO_FIGHT), this, onSetAutoFight);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAM_ESCAPE), this, onTeamEscape);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_TEAMS), this, onGetTeamInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_REBORN_TEAM), this, onTeamReborn);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FOOD_EMPTY), this, onNoFood);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_FOOD), this, onSetFood);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_REPORT), this, onFight);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_RESULT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DEPLOY_UPDATE), this, onTeamUpdate);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_LAMP), this, onMsg);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_ARMY_CHANGE), this, onUpdateInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATE_ONE_PIECE), this, onUpdateOneBlock);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}

		public function get view():ArmyGroupFightViewUI
		{
			return this._view
		}
	}
}
