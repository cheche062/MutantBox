package game.module.worldBoss 
{
	import MornUI.worldBoss.WorldBossFightViewUI;
	
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Handler;
	
	/**
	 * 世界BOSS
	 * @author hejianbo
	 * 2018-04-10 14:05:26
	 */
	public class WorldBossFightView extends BaseView
	{
		/**切图宽度*/
		public static const SizeX:int=4;
		public static const SizeY:int=4;
		public static const CellW:int=575;
		public static const CellH:int = 310;
		/***水平单位半格的差*/
		public static const DISSX:int = 59;
		/***垂直单位半格的差*/
		public static const DISSY:int = 103;
		/**
		 * 棋盘格子容器
		 */
		private var m_pieceObj:Object;
		/**主体可拖动战场*/
		private var m_sprMap:Sprite;
		
		/**npc队伍*/
		private var npcArmyPosList:Array = [];
		/**他人·所有队伍——在地图上的全部信息*/
		private var otherArmyPosList:Array = [];
		/**我方·所有队伍——在地图上的位置信息(活着 & 死了)*/
		private var myArmyPosList:Array = [];
		/**底部我的队伍编号的数据array*/
		private var myBottomTeamArray:Array = [];
		
		/**死亡信息暂存本地*/
		private var dieInfoCollection:Array = [];
		
		/**设置当前的队伍编号*/
		private var _curTeamNumber:String = "";
		/**飞机是否正在飞行*/
		private var isFlying:Boolean = false;
		
		/**事件-关闭*/
		public static const CLOSE:String="worldBoss_close";
		/**我方移动*/
		public static const CHANGE_INDEX:String = "CHANGE_INDEX";
		/**起始点index*/
		public static var START_POINT:String = "5_2";
		
		/**bossId*/
		private var BOSSID = "";
		/**此次我要添加的队伍编号*/
		private var addTeam = "";
		/**用户的信息数据*/
		private var userInfo:Object;
		
		/**行动力·移动消耗*/
		private static var MUSCLE_MOVE_COST = 5;
		/**行动力·初始值*/
		public static var MUSCLE_INIT = 100;
		/**行动力·杀敌消耗*/
		private static var MUSCLE_BATTLE_COST = 20;
		/**每秒恢复行动力*/
		private static var MUSCLE_RECOVER = 1;
		/**购买行动力价格*/
		private static var MUSCLE_BUY = "";
		/**开启预设部队消耗*/
		private static var OPEN_PRESET = "";
		/**部队死亡复活价格*/
		private static var LIVE_RECOVER = "";
				
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		/**首次购买行动力*/
		private var isFirstBuyMuscle:Boolean = true;
		/**首次购买立即复活*/
		private var isFirstBuyLive:Boolean = true;
		
		/**npc军团的控制器*/
		private var npcArmyCtrl:NpcArmyCtrl;
		
		public function WorldBossFightView()
		{
			super();
		}
		
		override public function createUI():void
		{
			console.clear();
			Laya.Stat.show()
				
			m_sprMap=new Sprite();
			m_sprMap.width=SizeX * CellW;
			m_sprMap.height=SizeY * CellH;
			m_sprMap.mouseEnabled=true;
			m_sprMap.pivot(m_sprMap.width / 2, m_sprMap.height / 2);
			m_sprMap.pos(Laya.stage.width / 2, Laya.stage.height / 2);
			
			//背景地图
			var box = WorldBossShareTask.createMapImages();
			m_sprMap.addChild(box);
			
			//格子对象容器
			var result = WorldBossShareTask.createM_pieceContainer();
			var box2 = result.box;
			m_pieceObj = result.obj;
			box2.pos((m_sprMap.width - box2.width) / 2, (m_sprMap.height - box2.height) / 2)
			m_sprMap.addChild(box2);
			
			this.addChild(m_sprMap);
			this.addChild(view);
			
			initConfiguration();
		}
		
		override public function show(... args):void
		{
			window.boss = this;
			super.show();
			switchWorldBossScene();
			onStageResize();
			startActionTick();
			initTeamList();
			npcArmyCtrl = new NpcArmyCtrl(view.dom_bossList);
			
			//参数
			var param = args[0];
			BOSSID = param[2];
			// 暂未开始     倒计时
			if (param[0] == 1) {
				isAlreadyStarted(false);
				clearTimerHandler = ToolFunc.limitHandler(param[1], function(time) {
					var detailTime = TimeUtil.toDetailTime(time);
					view.dom_time.text = TimeUtil.timeToText(detailTime);
				}, function() {
					trace('倒计时结束：：：');
				});
				
				//已经预设过
				if (BOSSID) {
					isAlreadyPreseted(true);
					// 获取我已经部的阵
//					sendData(ServiceConst.BOSS_GET_MYTEAM, BOSSID);
					
					// 未预设过
				} else {
					isAlreadyPreseted(false);
				}
				
			//已经开始
			} else if (param[0] == 2) {
				isAlreadyStarted(true);
				//进入战场
				sendData(ServiceConst.BOSS_ENTER_BATTLE_FIELD);
			}
		}
		
		/**初始化配置参数*/
		private function initConfiguration():void {
			var result = ResourceManager.instance.getResByURL("config/p_boss/p_boss_param.json");
			MUSCLE_RECOVER = Number(result["4"].value);
			MUSCLE_INIT = Number(result["5"].value);
			MUSCLE_MOVE_COST = Number(result["6"].value);
			MUSCLE_BATTLE_COST = Number(result["7"].value);
			MUSCLE_BUY = result["8"].value;
			LIVE_RECOVER = result["11"].value;
			START_POINT = result["22"].value;
//			trace('【配置参数】', result);
		}
		
		/**是否已开始*/
		private function isAlreadyStarted(bool:Boolean):void {
			view.dom_mask_box.visible = !bool;
			view.dom_tips.visible = !bool;
		}
		
		/**是否已预设*/
		private function isAlreadyPreseted(bool:Boolean):void {
			view.dom_tips.visible = !bool;
			// 交换层级
			var teamIndex = view.getChildIndex(view.dom_teamList);
			var maskIndex = view.getChildIndex(view.dom_mask_box);
			var hightIndex = Math.max(teamIndex, maskIndex);
			// 将谁的层级调高点
			var dom = bool ? view.dom_teamList : view.dom_mask_box;
			view.addChildAt(dom, hightIndex);
		}
		
		/**获取地图所有活着的队伍*/
		private function get allArmyPosList():Array {
			// 将核心id队数据放置最后
			myArmyPosList = myArmyPosList.sort(function(a:WorldBossInfoVo) {
				return a.team == curTeamNumber ? 1 : -1;
			});
			return [].concat(otherArmyPosList, myArmyPosList);
		}
		
		/**初始化我的队伍列表*/
		private function initTeamList():void {
			view.dom_teamList.itemRender = ArmyTeam;
			myBottomTeamArray.length = 0;
			for (var i = 0; i < 5; i++) {
				var data:ArmyTeamDataVo = new ArmyTeamDataVo();
				data.team = String(i + 1);
				myBottomTeamArray[i] = data;
			}
			reFreshTeamListView(myBottomTeamArray);
		}
		
		/**刷新队伍tab选项列表*/
		private function reFreshTeamListView(data):void {
			if (data) {
				view.dom_teamList.array = data;
			} else {
				for (var i = 0; i < 5; i++) {
					setBottomItemView(i + 1);
				}
			}
		}
		
		/**更新底部单个数据  team: 队伍编号*/
		private function renewalBottomItemData(team):void {
			var data:ArmyTeamDataVo = myBottomTeamArray[team - 1];
			var posInfo:WorldBossInfoVo = getMyInfoByTeamNumber(team);
			if (posInfo) {
				data.updateDataTeam(posInfo);
				data.hasData = true;
				data.isStartPoint = (posInfo.index == START_POINT);
				data.isSelected = (data.team == curTeamNumber);
			} else {
				data.reset();
			}
			
			return data;
		}
		
		/**设置更新底部单个视图*/
		private function setBottomItemView(team):void {
			if (!team || team == "0") return;
			var newData:ArmyTeamDataVo = renewalBottomItemData(team);
			newData.clearTimeCountHandler();
			// 开启复活倒计时
			if (newData.isDied && newData.time > 0) {
				newData.timeCountHandler = ToolFunc.limitHandler(newData.time, function(time) {
					newData.time = time;
					view.dom_teamList.changeItem(Number(team) - 1, newData);
//					trace('%c 【boss 倒计时】：', 'color: gray', time);
				}, function() {
//					trace('%c ======boss 倒计时结束=====：', 'color: red');
					// 复活则重新获取起始点数据 
					sendData(ServiceConst.BOSS_POS_INFO, [BOSSID, START_POINT]);
				}, false);
			} else {
				view.dom_teamList.changeItem(Number(team) - 1, newData);
			}
		}
		
		/**移动改变index   新的索引index   是否是敌人*/
		private function myMoveHandler(...args):void {
			if (isFlying) return;
			
			var newIndex = args[0];
			var isEnemy = args[1];
			// 找出该队数据
			var info:WorldBossInfoVo = getMyInfoByTeamNumber();
			//扣10点行动力
			var muscle = info.muscle - MUSCLE_BATTLE_COST;
			if (muscle < 0) {
				return XTip.showTip('前端判断  行动力不足');
			};
			// 判断移动还是发起战斗
			if (isEnemy) {
				var result = ResourceManager.instance.getResByURL("config/p_boss/p_boss_consume.json");
				// 大本营等级
				var myLv = User.getInstance().sceneInfo.getBaseLv();
				var targetValue = ToolFunc.getTargetItemData(result, 'level', myLv);
				var cost_food = Number(targetValue["cost"].split("=")[1]);
				if (userInfo["useableFood"] > cost_food) {
					sendData(ServiceConst.BOSS_FIGHT, [BOSSID, info.team_id, newIndex]);
					
				} else XTip.showTip('前端判断  粮草不足');
					
			// 移动格子
			} else sendData(ServiceConst.BOSS_MOVE, [BOSSID, info.team_id, newIndex]);
		}
		
		/**设置用户信息*/
		private function setUserInfo(data):void {
			userInfo = ToolFunc.copyDataSource(userInfo, data);
		}
		
		/**渲染用户信息*/
		private function renderUserInfo():void {
			userInfo["useableFood"] = User.getInstance().food - Number(userInfo["foodProtection"]);
			view.dom_killNum.text = userInfo["kill"];
			view.dom_food.text = XUtils.formatResWith(userInfo["useableFood"]);
		}
		
		/**初始化渲染所有部队飞机*/
		private function initRenderAllUsers(users):void {
			// 所有玩家队伍
			users.forEach(function(item:Object) {
				var info:WorldBossInfoVo = new WorldBossInfoVo();
				info.initDataTransform(item);
				// 将我的队伍 与 他人队伍进行区分
				if (info.isMyTeam) myArmyPosList.push(info);
				else otherArmyPosList.push(info);
			});
			logMyTeam()
			// 将数据以pos为键渲染
			var pos_datas = {};
			allArmyPosList.forEach(function(item:WorldBossInfoVo) {
				if (pos_datas[item.index]) {
					var data = pos_datas[item.index];
					if (ToolFunc.isArray(data)) data.push(item);
					else pos_datas[item.index] = [data, item];
					
				} else pos_datas[item.index] = item;
			});
			for (var key in pos_datas) {
				var chess:WorldBossChess = m_pieceObj[key];
				var data:WorldBossInfoVo = null;
				if (!ToolFunc.isArray(pos_datas[key])) {
					data = pos_datas[key];
				} else {
					var dataArr:Array = pos_datas[key];
					var lastInfo:WorldBossInfoVo = dataArr[dataArr.length - 1];
					data = ToolFunc.extendDeep(lastInfo);
					data.updateData({"collect": dataArr.length});
				}
				chess && chess.updateView(data);
			}
		}
		
		private function logMyTeam():void {
			var teamArray = myArmyPosList.map(function(item:WorldBossInfoVo){
				return item.team_id;
			})
			trace('%c 【boss数据我的队伍id】：', 'color: red', teamArray);
		}
		
		/**渲染所有的npc队伍*/
		private function initRenderAllNpcs(npc):void {
			npcArmyPosList.length = 0;
			var npc_List = npcArmyCtrl.npc_List;
			var npcIdNameMap = npcArmyCtrl.npcIdNameMap;
			for (var key in npc_List) {
				var item = npc_List[key];
				var info:WorldBossInfoVo = new WorldBossInfoVo();
				var collect = (npc[key] && npc[key].length) || 0;
				
				info.updataNpc(key, collect, item["npcId"], npcIdNameMap[item["npcId"]]);
				npcArmyPosList.push(info);
			}
			npcArmyPosList.forEach(function(item:WorldBossInfoVo) {
				renderNpcView(item);
			});
		}
		
		/**渲染npc队伍视图*/
		private function renderNpcView(info:WorldBossInfoVo):void {
			var chess:WorldBossChess = m_pieceObj[info.index];
			if (info.collect > 0) chess && chess.updateView(info);
			else chess && chess.npcForceRemovePeoplePlane();
		}
		
		/**渲染对应格子上的数据   bool   false:表示将原先的核心格子层级还原  */
		private function renderIndexData(index, bool = true):void {
			if (!index) return;
			//是否核心的id
			var _id = bool ? curTeamNumber : "000";
			var dataArr:Array = allArmyPosList.filter(function(item:WorldBossInfoVo, i) {
				return item.index == index;
			});
			var chess:WorldBossChess = m_pieceObj[index];
			var lastInfo:WorldBossInfoVo = dataArr[dataArr.length - 1];
			
			//如果有数据
			if (lastInfo) {
				var data:WorldBossInfoVo = ToolFunc.extendDeep(lastInfo);
				data.updateData({"collect": dataArr.length});
				// 是否是当前操作中的棋子
				var isOperateChess:Boolean = (data.team == _id);
				chess && chess.updateView(data, isOperateChess);
			} else {
				chess && chess.removePeoplePlane();
			}
		}
		
		/**计算飞行的目的坐标*/
		private function getTargetPos(oldIndex:String, newIndex:String):Object {
			var newArr = newIndex.split("_");
			var oldArr = oldIndex.split("_");
			var x = (newArr[1] - oldArr[1]) * DISSX;
			var y = (newArr[0] - oldArr[0]) * DISSY;
			return {x: x, y: y};
		}
		
		/**设置我    当前操作的队伍team 编号*/
		private function set curTeamNumber(value:String):void {
//			if (_curTeamID == value) return;
			//新信息
			var new_info:WorldBossInfoVo = getMyInfoByTeamNumber(value);
			var newIndex = (new_info && new_info.index) || "";
			updateRoundPieceState(curIndex, newIndex);
			
			_curTeamNumber = value;
			// 操作队伍编号改变则需要及时更新当前的队伍的行动力
			updateMuscleText();
			// 自动玩按钮状态切换
			if (new_info) toggleBtnAutoSkin(new_info.auto);
			// 设置撤退按钮的坐标位置
//			setRetreatPositon(Number(_curTeamNumber));
		}
		private function get curTeamNumber():String {
			return _curTeamNumber;
		}
		
		/**获取当前的index*/
		private function get curIndex():String {
			var info:WorldBossInfoVo = getMyInfoByTeamNumber();
			return (info && info.index) || "";
		}
		
		/**切换自动玩按钮的皮肤*/
		private function toggleBtnAutoSkin(isAuto:Number):void {
			view.btn_auto.skin = isAuto == 0 ? "worldBoss/btn_7.png" : "worldBoss/btn_8.png";
		}
		
		/**设置撤退按钮的坐标位置*/
		private function setRetreatPositon(num:Number):void {
			view.btn_retreat.visible = !!num;
			view.btn_retreat.x = 63 + (num - 1) * 90;
		}
		
		/**查找我方队伍数据——通过team编号找到该条数据*/
		private function getMyInfoByTeamNumber(number):WorldBossInfoVo {
			var _num = (number === undefined) ? curTeamNumber : number;
			var info:WorldBossInfoVo = ToolFunc.find(myArmyPosList, function(item:WorldBossInfoVo) {
				return item.team == _num;
			});
			return info;
		}
		
		/**恢复老的 && 更新新的 一圈可点击*/
		private function updateRoundPieceState(oldIndex, newIndex):void {
			var old_pieceList:Array = getRoundPiecesList(oldIndex);
			var new_pieceList:Array = getRoundPiecesList(newIndex);
			old_pieceList = old_pieceList.filter(function(item, index) {
				return new_pieceList.indexOf(item) == -1;
			})
			// 还原老的
			setPieceListState(old_pieceList, false);
			//设置新的周边格子为可移动
			setPieceListState(new_pieceList, true);
		}
		
		/**批量修改格子激活状态*/
		private function setPieceListState(list, value):void {
			list.forEach(function(item:String, index:int) {
				var chess:WorldBossChess = m_pieceObj[item];
				if (chess) chess.isActivate = value;
			});
		}
		
		/**获取周边6个格子id索引*/
		private function getRoundPiecesList(value):Array {
			if (!value) return [];
			var h_r:Array = value.split("_");
			var lineNum = Number(h_r[0]);
			var rowNum = Number(h_r[1]);
			return [
				(lineNum - 1) + '_' + (rowNum - 1),
				(lineNum - 1) + '_' + (rowNum + 1),
				(lineNum) + '_' + (rowNum - 2),
				(lineNum) + '_' + (rowNum + 2),
				(lineNum + 1) + '_' + (rowNum - 1),
				(lineNum + 1) + '_' + (rowNum + 1)
			];
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target) {
				// 撤退
				case view.btn_retreat:
					//当前数据					
					var info:WorldBossInfoVo = getMyInfoByTeamNumber();
					if (!info) return;
					// 回到起点
					sendData(ServiceConst.BOSS_MOVE, [BOSSID, info.team_id, START_POINT]);
					
					break;
				
				//设置粮草
				case view.btn_setfood:
					var callback = function(num) {
						sendData(ServiceConst.BOSS_FOOD_PROTECT, [num]);
					}
					XFacade.instance.openModule("WorldBossSetFood", callback);
					
					break;
				
				// 关闭
				case view.btn_close:
					sendData(ServiceConst.BOSS_LEAVE_BATTLE_FIELD, [BOSSID]);
					onClose();
					break;
				
				// 开启预设
				case view.btn_preset:
					sendData(ServiceConst.BOSS_START_PRESET);
					trace('预设');
					
					break;
				
				// 购买行动力
				case view.btn_addAction:
					//当前数据			
					var info:WorldBossInfoVo = getMyInfoByTeamNumber();
					if (!info) return;
					if (info.muscle < MUSCLE_INIT) {
						if (!isFirstBuyMuscle) {
							return sendData(ServiceConst.BOSS_BUY_ACTION, [BOSSID, info.team_id]);
						}
						var text = "确认购买行动力？";
						var priceArr:Array = MUSCLE_BUY.split("=");
						XFacade.instance.openModule("ItemAlertView", [text, priceArr[0], priceArr[1], function(){
							sendData(ServiceConst.BOSS_BUY_ACTION, [BOSSID, info.team_id]);
							isFirstBuyMuscle = false;
						}]);
						
					} else XTip.showTip('前端判断  行动力已达上限');
					
					break;
				
				// 排行榜
				case view.btn_book:
					XFacade.instance.openModule("WorldBossRankView", [BOSSID]);
					
					break;
				
				// 自动玩
				case view.btn_auto:
					//当前数据	
					var info:WorldBossInfoVo = getMyInfoByTeamNumber();
					if (info) {
						var auto = info.auto == 0 ? 1 : 0;
						sendData(ServiceConst.BOSS_AUTO, [BOSSID, info.team_id, auto]);
						
					} else XTip.showTip('前端判断  请选择一个队伍');
					
					break;
				
				case view.btn_help:
					var msg:String = GameLanguage.getLangByKey("L_A_85023");
					XTipManager.showTip(msg);
					
					break;
				
				default:
					break;
			}
		}
		
		/**tab切换   队伍team*/
		private function tabHandler(e:Event):void {
			if (isFlying) return;
			var _selectedIndex = view.dom_teamList.selectedIndex;
			var team = String(_selectedIndex + 1);
			var teamData:ArmyTeamDataVo = ToolFunc.find(myBottomTeamArray, function(item:ArmyTeamDataVo){
				return item.team == team;
			});
			var info:WorldBossInfoVo = ToolFunc.find(myArmyPosList, function(item:WorldBossInfoVo){
				return item.team == team;
			});
			trace(team, 'click');
			
			/**根据该数据目前的状态  ——> 添加数据  or 切换操作team队伍  or 立即复活*/
			switch (true){
				//添加数据
				case (!teamData.hasData):
					// 去上兵
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_WORLD_BOSS, [BOSSID, team], 
						Handler.create(this, switchWorldBossScene, null, false));
					
					addTeam = team;
					this.visible = false;
					
					break;
				
				// 删除队伍  || 切换操作team队伍
				case (teamData.hasData && !teamData.isDied):
					// 删除队伍
					if (e.target.name == "btn_close") {
						//请求撤退
						sendData(ServiceConst.BOSS_EXIT_PRESET, [BOSSID, info.team_id]);
						
					//切换队伍
					} else {
						var lastTeamNum = curTeamNumber;
						// 需要首先将原先的格子重新渲染，让其层级下去
						renderIndexData(curIndex, false);
						curTeamNumber = team;
						renderIndexData(curIndex);
						// 只更新上次队伍 和  这次新队伍的编号视图
						setBottomItemView(lastTeamNum);
						setBottomItemView(curTeamNumber);
					}
					
					break;
				
				// 复活队伍
				case (teamData.hasData && teamData.isDied):
					if (!isFirstBuyLive) {
						return sendData(ServiceConst.BOSS_REVIVE, [BOSSID, info.team_id]);
					}
					var text = "确认立即复活？";
					var priceArr:Array = LIVE_RECOVER.split("=");
					XFacade.instance.openModule("ItemAlertView", [text, priceArr[0], priceArr[1], function(){
						sendData(ServiceConst.BOSS_REVIVE, [BOSSID, info.team_id]);
						isFirstBuyLive = false;
					}]);
					
					break;
			}
		}
		
		/**开启行动力恢复循环执行器*/
		private function startActionTick():void {
			//首先执行一下
			actionTickHandler();
			// 开启行动力时钟
			Laya.timer.loop(1000, this, actionTickHandler);
		}
		
		/**行动力递增*/
		private function actionTickHandler():void {
			myArmyPosList.forEach(function(item:WorldBossInfoVo) {
				if (!item.isDied && item.muscle < MUSCLE_INIT) {
					item.muscle = item.muscle + MUSCLE_RECOVER;
					// 对应的底部tab
					setBottomItemView(item.team);
				}
			});
			
			updateMuscleText();
		}
		
		/**更新行动力文本*/
		private function updateMuscleText():void {
			//更新当前team的行动力
			var info:WorldBossInfoVo = getMyInfoByTeamNumber();
			var text = (info && info.muscle) || "";
			view.apLabel.text = text ? (text + "/" + MUSCLE_INIT) : text;
		}
		
		/**切换世界boss场景*/
		private function switchWorldBossScene():void {
			this.visible = true;
			if (SceneManager.intance.m_sceneCurrent) {
				SceneManager.intance.m_sceneCurrent.close();
				SceneManager.intance.m_sceneCurrent = null;
			}
		}
		
		/**添加新部队*/
		private function addNewArmy(data):void {
			// 新数据
			var info:WorldBossInfoVo = new WorldBossInfoVo();
			info.initDataTransform(data);
			var isMyTeam:Boolean = info.isMyTeam;
			// 增加我方数据
			if (isMyTeam) {
				info.team = addTeam;
				myArmyPosList = myArmyPosList.concat(info);
				logMyTeam()
				renderIndexData(curIndex, false);
				var lastTeamNum = curTeamNumber;
				curTeamNumber = info.team;
				renderIndexData(curIndex);
				
				setBottomItemView(lastTeamNum);
				setBottomItemView(curTeamNumber);
				
				//增加其他玩家数据
			} else {
				otherArmyPosList = otherArmyPosList.concat(info);
				renderIndexData(info.index);
			}
		}
		
		/**移动部队*/
		private function moveArmy(existInfo:WorldBossInfoVo, data):void {
			var oldIndex = data["old_map_pos"];
			var newIndex = data["map_pos"];
			var isMyTeam:Boolean = existInfo.isMyTeam;
			var chess:WorldBossChess = m_pieceObj[oldIndex];
			// 更新该移动的数据
			existInfo.initDataTransform(data);
			// 此处同时更新底部的tab
			if (isMyTeam) setBottomItemView(existInfo.team);
			updateMuscleText();
			
			// 渲染老格子的数据
			renderIndexData(oldIndex);
			
			// 一样则不需要移动
			if (oldIndex == newIndex) return;
			
			// 该队伍是我当前操作的队伍时（别人队伍team为'0'）
			if (curTeamNumber && existInfo.team == curTeamNumber) isFlying = true;
			var targetPos = getTargetPos(oldIndex, newIndex);
			//首先做完飞行的移动动画
			function yiDongEnd() {
				if (curTeamNumber && existInfo.team == curTeamNumber) {
					isFlying = false;
					// 激活的格子更新
					updateRoundPieceState(oldIndex, newIndex);
				}
				// 渲染新格子的数据
				renderIndexData(newIndex);
			};
			//飞行
			chess.fly(existInfo, targetPos, yiDongEnd.bind(this));						
		}
		
		/**我们正义方战斗动画*/
		private function ourArmyBattle(ourBattleInfo):void {
			// 我方阵营数据
			var ourInfo:WorldBossInfoVo = ToolFunc.find(allArmyPosList, function(item:WorldBossInfoVo) {
				return item.team_id == ourBattleInfo[7];
			});
			var old_pos = ourInfo.index;
			var isMyTeam = ourInfo.isMyTeam;
			var chess:WorldBossChess = m_pieceObj[ourInfo.index];
			if (curTeamNumber && ourInfo.team == curTeamNumber) isFlying = true;
			// 我的队伍且没死(那就是我杀敌了)
			if (isMyTeam && ourBattleInfo[0]) {
				// 仅更新数据并未渲染（+1）
				setUserInfo({"kill": userInfo["kill"] + 1});
			}
			
			// 死没死
			var isDied:Boolean = (ourBattleInfo[0] == 0); 
			// 存活情况更新    
			var liveFunc = function() {
				if (curTeamNumber && ourInfo.team == curTeamNumber) isFlying = false;
				ourInfo.updataBlood(ourBattleInfo[1], ourBattleInfo[2]);
//				// 将该格子数据重新渲染
				renderIndexData(old_pos);
			};
			
			// 死亡情况更新    
			var dieFunc = function() {
				var _i = ToolFunc.findIndex(dieInfoCollection, function(item:WorldBossInfoVo){
					return item.team_id == ourInfo.team_id;
				});
				// 取出死亡数据
				var dieInfo = dieInfoCollection.splice(_i, 1)[0];
				// 是否需要重置操作队伍
				if (curTeamNumber && ourInfo.team == curTeamNumber) {
					isFlying = false;
					curTeamNumber = "";
				}
				
				ourInfo.initDataTransform(dieInfo);
				setBottomItemView(ourInfo.team);
				// 死后必然回到起始点
				renderIndexData(START_POINT);
				// 将该格子数据重新渲染
				renderIndexData(old_pos);
			};
			
			// 同步执行版
			function synchFunc() {
				renderUserInfo();
				if (!isDied) {
					liveFunc();
					return;
				}
				dieFunc();
			}
			
			// 异步回调版
			function ourCallBack() {
				trace('我的队伍---战斗----结束')
				// 更新我的杀敌数量以及剩余粮草
				renderUserInfo();
				// 没死
				if (!isDied) {
					liveFunc();
					return;
				}
				var dieCB = function() {
					trace('我的队伍---死亡----结束')
					dieFunc();
				};
				trace('我的队伍---死亡----开始')
				// 死亡动画
				chess.die(dieCB.bind(this));
			};
			
			trace('我的队伍---战斗----开始')
			
			// 减血需要立刻更新一下
			ourInfo.updataBlood(ourBattleInfo[1], ourBattleInfo[2]);
			// 将该格子数据重新渲染
			renderIndexData(old_pos);
			// 战斗动画    （异步版，同步版，失血量）
			chess.fight(ourCallBack.bind(this), synchFunc.bind(this), ourBattleInfo[1]);
		}
		
		/**npc战斗动画*/
		private function npcArmyBattle(npcBattleInfo, npcs):void {
			var npcInfo:WorldBossInfoVo = ToolFunc.find(npcArmyPosList, function(item:WorldBossInfoVo) {
				return item.index == npcBattleInfo[8];
			});
			var npcChess:WorldBossChess = m_pieceObj[npcInfo.index];
			function npcCallBack() {
				trace('npc队伍---战斗----结束')
				// 没死
				if (npcBattleInfo[0]) {
					npcInfo.updateNpcAfterBattle(npcBattleInfo[1], npcBattleInfo[2], npcBattleInfo[3], npcs[npcInfo.index]);
					renderNpcView(npcInfo);
					
					return;
				}
				//死亡情况
				var dieCB = function() {
					trace('npc队伍---死亡----结束')
					// 取对应的npc新的数量
					var _restNum = npcs[npcInfo.index] || 0;
					// 换成新的数据  耗血为0 战斗起始的血量也传满血量，为了该方法里计算正确
					npcInfo.updateNpcAfterBattle(0, npcBattleInfo[3], npcBattleInfo[3], _restNum);
					renderNpcView(npcInfo);
					
					npcArmyCtrl.changeBossItemView(npcInfo);
				}
				trace('npc队伍---死亡----开始')
				// 死亡动画
				npcChess.die(dieCB.bind(this));
			}
			
			trace('npc队伍---战斗----开始');
			npcInfo.updateNpcAfterBattle(npcBattleInfo[1], npcBattleInfo[2], npcBattleInfo[3]);
			renderNpcView(npcInfo);
			// 战斗动画
			npcChess.fight(npcCallBack.bind(this), null, npcBattleInfo[1]);
		}
		
		/**请求回来的数据处理*/
		private function onServerResult(...args):void{
			var cmd = args[0];
			trace('%c 【boss数据】：', 'color: green', cmd, args);

			switch(cmd) {
				// 开启预设布阵
				case ServiceConst.BOSS_START_PRESET:
				
					
					break;
				
				// 设置粮草保护
				case ServiceConst.BOSS_FOOD_PROTECT:
					setUserInfo({"foodProtection": Number(args[1]["foodProtection"])});
					renderUserInfo();
					
					break;
				
				// 粮草不足
				case ServiceConst.BOSS_SERVER_FOOD_LESS:
					XTip.showTip(args[1]["msg"]);
					break;
					
				// 进入战场
				case ServiceConst.BOSS_ENTER_BATTLE_FIELD:
					var result = args[1];
					BOSSID = result["bossId"];
					
					initRenderAllNpcs(result["npc"]);
					npcArmyCtrl.renderView(npcArmyPosList);
					
					initRenderAllUsers(result["users"]);
					
					// 设置用户信息与渲染用户信息分开的原因：  有时渲染数据需要稍后
					setUserInfo(result["userInfo"]);
					renderUserInfo();
					
					// 有我的部队   // 获取我已经部的阵
					if (myArmyPosList.length > 0) sendData(ServiceConst.BOSS_GET_MYTEAM, BOSSID);
					
					break;
				
				// 离开战场
				case ServiceConst.BOSS_LEAVE_BATTLE_FIELD:
					
					
					break;
				
				/** 获取我方布阵列表*/
				// team_id : ["46000", 2000, 4273, "2"]   皮肤id , 布阵中战力最大的单位（用于取头像）, 布阵总战力 ,  我的队伍编号
				case ServiceConst.BOSS_GET_MYTEAM:
					var data = args[1];
					// 通过team_id对应到写入队伍编号
					myArmyPosList.forEach(function(item:WorldBossInfoVo) {
						var _d = data[item.team_id];
						if (_d) {
							item.team = _d[3];
							renderIndexData(item.index);
						};
					});
					logMyTeam()
					reFreshTeamListView();
					
					break;
				
				/** 保存布阵 （该情况被包含在移动中处理）*/
//				case ServiceConst.BOSS_SAVE_PRESET:
//					break;
				
				/** 撤退布阵*/ 
				case ServiceConst.BOSS_EXIT_PRESET:
					var lastTeamNum = curTeamNumber;
					curTeamNumber = "";
					myArmyPosList = myArmyPosList.filter(function(item:WorldBossInfoVo) {
						return item.team_id != args[1];
					});
					logMyTeam()
					//该格子数据重新渲染（撤退必然在起点）
					renderIndexData(START_POINT, false);
					setBottomItemView(lastTeamNum);
					
					break;
				
				/**队伍移动    包含数据更新旧有数据   和    增加新数据*/
				case ServiceConst.BOSS_SERVER_MOVE:
					var data = args[1];
					// 已存在的数据（判断有没有   存在则更新它  不存在则添加新数据）
					var existInfo:WorldBossInfoVo = ToolFunc.find(allArmyPosList, function(item:WorldBossInfoVo) {
						return item.team_id == data["team_id"];
					});
					//如果没有则添加数据
					if (!existInfo) addNewArmy(data);
					//有该数据则更新这条数据
					else moveArmy(existInfo, data);
					
					break;
				
				/**队伍数量变化*/
				case ServiceConst.BOSS_SERVER_TEAM_CHANGE:
					var num = Number(args[1]);
					var currentUsersNum = allArmyPosList.length;
					// 判断是多了还是少了 (变多则不处理，已经交由移动中处理)
					if (currentUsersNum < num) return;
					
					// 获取起始点的坐标  队伍信息  (变少则必定是在起始点撤退的)
					sendData(ServiceConst.BOSS_POS_INFO, [BOSSID, START_POINT]);
					
					break;
				
				/**地图格子信息*/
				case ServiceConst.BOSS_POS_INFO:
					var map_pos = args[1]["map_pos"];
					var users = args[1]["users"];
					var npc = args[1]["npc"];
					var userObj = ToolFunc.arrayToJson('team_id', users);
					
					// 只处理少了 其他玩家队伍情况
					otherArmyPosList = otherArmyPosList.filter(function(item:WorldBossInfoVo) {
						if (item.index !== map_pos) return true;
						var info = userObj[item.team_id]; 
						return !!info;
					});
					
					// 复活的情况 
					if (map_pos == START_POINT) {
						myArmyPosList.forEach(function(item:WorldBossInfoVo) {
							// 找到该条新数据源
							var data = userObj[item.team_id]; 
							if (data) {
								item.initDataTransform(data);
								setBottomItemView(item.team);
							}
						});
					}
					
					renderIndexData(map_pos);
					logMyTeam()
					break;
				
				/**战斗*/
				case ServiceConst.BOSS_SERVER_FIGHT:
					// 战报： 0：攻击方 （我方） 	1： 防守方 （npc）
					//[0:是否存活（0 死了，1 存活）, 1:失血量, 2:初始血量, 3:总血量, 4:玩家昵称, 5:uid,  6:战斗消耗, 7:team_id,  8:map_pos ]
					var battleInfo = args[1];
					var friendTeams = args[2];
					var npcs = args[3];
					
					ourArmyBattle(battleInfo[0]);
					npcArmyBattle(battleInfo[1], npcs);
					
					break;
				
				/**推送——队伍死亡  (死亡队伍信息暂存本地)*/
				case ServiceConst.BOSS_SERVER_DIED:
					dieInfoCollection.push(args[1]);
					
					break;
				
				/**队伍立即复活*/
				case ServiceConst.BOSS_REVIVE:
					var data = args[1];
					var info:WorldBossInfoVo = ToolFunc.find(myArmyPosList, function(item:WorldBossInfoVo) {
						return item.team_id == data["team_id"];
					});
					info.initDataTransform(data["team_info"]);
					logMyTeam()
					
					var lastTeamNum = curTeamNumber;
					curTeamNumber = info.team;
					renderIndexData(info.index);
					
					setBottomItemView(lastTeamNum);
					setBottomItemView(curTeamNumber);
					
					break;
				
				/**购买行动力*/
				case ServiceConst.BOSS_BUY_ACTION:
					var data = args[1];
					var info:WorldBossInfoVo = ToolFunc.find(myArmyPosList, function(item:WorldBossInfoVo) {
						return item.team_id == data["team_id"];
					});
					if (info) {
						info.muscle = data["muscle"];
						setBottomItemView(info.team);
						updateMuscleText();
					}
					
					break;
				
				/**自动玩*/
				case ServiceConst.BOSS_AUTO:
					var posInfo:WorldBossInfoVo = getMyInfoByTeamNumber();
					if (posInfo && args[1][0]) {
						posInfo.auto = posInfo.auto == 0 ? 1 : 0;
						toggleBtnAutoSkin(posInfo.auto);
						setBottomItemView(posInfo.team);
					}
					
					break;
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(CLOSE, this, onClose);
			view.dom_teamList.on(Event.CLICK, this, tabHandler);
			
			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);			
			Laya.stage.on(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.on(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.on(Event.FOCUS, this, onActive, [Event.FOCUS]);
			Laya.stage.on(Event.RESIZE, this, onStageResize);
			
			m_sprMap.on(Event.DRAG_START, this, onDragStart);
			m_sprMap.on(Event.DRAG_END, this, onDragEnd);			
			m_sprMap.on(Event.MOUSE_DOWN, this, mapStarDropHandler);
			m_sprMap.on(Event.MOUSE_UP, this, mapStopDropHandler);
			this.on(Event.MOUSE_WHEEL, this, onScale);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_START_PRESET), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_ENTER_BATTLE_FIELD), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_LEAVE_BATTLE_FIELD), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_GET_MYTEAM), this, onServerResult);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SAVE_PRESET), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_EXIT_PRESET), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_MOVE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_TEAM_CHANGE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_POS_INFO), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_FIGHT), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_REVIVE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_DIED), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_BUY_ACTION), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_AUTO), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_FOOD_PROTECT), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_FOOD_LESS), this, onServerResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(CHANGE_INDEX, this, myMoveHandler);
		}
		
	/************************************************************************************************************************/	
		override public function onStageResize():void
		{
			this.size(Laya.stage.width, Laya.stage.height);
			view.size(this.width, this.height);
			view.dom_mask.size(this.width, this.height);
			
			/*if(GameSetting.isIPhoneX){
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
			view.joinBtn.y = Laya.stage.height - 100;*/
			
		}
		
		private function mapStarDropHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			//trace("mapStarDropHandler:", e.target);
			var str:String;
//			switch (e.target)
//			{
//				
////				default:
////					break;
//			}
			
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
			for (var index in m_pieceObj)
			{
				var p:Point = new Point(m_pieceObj[index].x, m_pieceObj[index].y);
				p = m_sprMap.localToGlobal(p);
				
				var isOutScreen:Boolean = (p.x < -300 || p.y < -150 || p.x > Laya.stage.width - 200 || p.y > Laya.stage.height)
				m_pieceObj[index].visible = !isOutScreen;
			}
		}
		
		private function onScale(e:Event):void
		{
			var deltaScale:Number=e.delta / 30;
			doScale(deltaScale);
		}

		private function doScale(deltaScale:Number):void
		{
			var scale:Number=m_sprMap.scaleX;
			scale+=deltaScale;
			if (scale > 1) scale=1;
			
			if (scale < 0.72) scale=0.72;

			m_sprMap.scaleX = m_sprMap.scaleY = scale;
			
			showDragRegion();
			
			m_sprMap.stopDrag();
			
			if (scale != 1) {
				m_sprMap.x = ToolFunc.getAmongValue(m_sprMap.x, dragRegion.x, dragRegion.x + dragRegion.width);
				m_sprMap.y = ToolFunc.getAmongValue(m_sprMap.y, dragRegion.y, dragRegion.y + dragRegion.height);
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
		
		private function onActive():void
		{
			trace("世界BOSS获取焦点")
		}
		
		//多点问题
		private var lastDistance:Number = 0;
		
		private function onMouseUp(e:Event=null):void {
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

		private function onDragStart():void {
			// TODO Auto Generated method stub
			showObject();
		}

		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(CLOSE, this, onClose);
			view.dom_teamList.off(Event.CLICK, this, tabHandler);
			
			Laya.stage.off(Event.MOUSE_UP, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, onMouseUp);
			Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
			
			m_sprMap.off(Event.DRAG_START, this, onDragStart);
			m_sprMap.off(Event.DRAG_END, this, onDragEnd);
			m_sprMap.off(Event.MOUSE_DOWN, this, mapStarDropHandler);
			m_sprMap.off(Event.MOUSE_UP, this, mapStopDropHandler);
			this.off(Event.MOUSE_WHEEL, this, onScale);
			Laya.stage.off(Event.FOCUS, this, onActive);
			Laya.stage.off(Event.RESIZE, this, onStageResize);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_START_PRESET), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_ENTER_BATTLE_FIELD), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_LEAVE_BATTLE_FIELD), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_GET_MYTEAM), this, onServerResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SAVE_PRESET), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_EXIT_PRESET), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_MOVE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_TEAM_CHANGE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_POS_INFO), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_FIGHT), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_REVIVE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_DIED), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_BUY_ACTION), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_AUTO), this, onServerResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			Signal.intance.off(CHANGE_INDEX, this, myMoveHandler);
		}
		
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		/**重置*/
		private function reset():void {
			// 重置npc队伍
			initRenderAllNpcs([]);
			npcArmyPosList.length = 0;
			npcArmyCtrl.reset();
			npcArmyCtrl = null;
			
			// 重置我的队伍 & 别人队伍
			allArmyPosList.map(function(item:WorldBossInfoVo) {
				return item.index;
			}).forEach(function(item:WorldBossInfoVo) {
				var chess:WorldBossChess = m_pieceObj[item.index];
				chess && chess.removePeoplePlane();
			});
			otherArmyPosList.length = 0;
			myArmyPosList.length = 0;
			
			WorldBossChess.recoverPool();
			
			// 重置底部tab队伍
			reFreshTeamListView();
			myBottomTeamArray.length = 0;
			view.dom_teamList.array = [];
			
			dieInfoCollection.length = 0;
			// 清除行动力的自增
			Laya.timer.clear(this, actionTickHandler);
			
			// 清除开场倒计时
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
		}
		
		override public function close():void {
			super.close();
			
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		private function onClose():void {
			reset();
			
			close();
			
//			XFacade.instance.disposeView(this);
//			this.destroy();
		}
		
		public function get view():WorldBossFightViewUI {
			_view = _view || new WorldBossFightViewUI();
			
			return _view;
		}
	}
}