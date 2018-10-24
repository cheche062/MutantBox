/***
 *作者：罗维
 */
package game.module.fighting.mgr
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.DataLoading;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.cond.ConditionsManger;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemData;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.data.formatData.FightingFormatData;
	import game.global.data.formatData.ReportFormatData;
	import game.global.data.formatData.SubReportFormatData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingShowFormatData;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.module.equipFight.EquipFightInfoView;
	import game.module.fighting.FightUtil;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.panel.SaoDangRewardView1;
	import game.module.fighting.panel.SaoDangRewardView2;
	import game.module.fighting.scene.FightingScene;
	import game.module.fighting.scene.PveFightingScane;
	import game.module.fighting.view.FightingView;
	import game.module.fighting.view.PvpFightingView;
	import game.module.login.PreLoadingView;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Timer;
	

	public class FightingManager
	{
		private static var _instance:FightingManager;
		
		public static const  FIGHT_VELOCITY_CHANGE:String  = "FIGHT_VELOCITY_CHANGE";
		private static var _velocity:Number = 1;   //战斗速度 
		public static var cacheVelocity:Number = 0;  //缓存战斗速度

		private var m_need:Array ;
		
		///常规战斗
		public static var FIGHTINGTYPE_ORDINARY:Number = 0;
		public static var FIGHTINGTYPE_STAGE:Number = 1;
		public static var FIGHTINGTYPE_GENE:Number = 2;
		public static var FIGHTINGTYPE_BOSS:Number = 3;
		public static var FIGHTINGTYPE_HOME:Number = 4;
		public static var FIGHTINGTYPE_EQUIP:Number = 5;
		public static var FIGHTINGTYPE_PLUNDER:Number = 6;
		public static var FIGHTINGTYPE_ROB:Number = 7;
		public static var FIGHTINGTYPE_GUILDBOSS:Number = 8;
		public static var FIGHTINGTYPE_JINJICHANG:Number = 9;
		public static var FIGHTINGTYPE_KUANGCHANG:Number = 10;
		public static var FIGHTINGTYPE_BINGBOOK:Number = 11;
		public static var FIGHTINGTYPE_JINGYING:Number = 12;
		public static var RANDOM_CONDITION:Number = 13;
		public static var PEOPLE_FALL_OFF:Number = 14;
		//特殊战斗
		public static var FIGHTINGTYPE_SET_HOME:Number = 110;
		public static var FIGHTINGTYPE_SET_ESCORT:Number = 111;
		public static var FIGHTINGTYPE_SET_SELFESCORT:Number = 112;
		public static var FIGHTINGTYPE_SET_JINJICHANG:Number = 113;
		public static var FIGHTINGTYPE_SET_KUANGCHANG:Number = 114;
		public static var FIGHTINGTYPE_SET_ARMY:Number = 115;
		//
		public static var FIGHTINGTYPE_STAR:Number = 116;
		//
		public static var FIGHTINGTYPE_GROUP:Number = 117;
		//战斗，fortress
		public static var FIGHTINGTYPE_FORTRESS:int = 118;
		//战斗，单英雄
		public static var FIGHTINGTYPE_LONEHERO:int = 119;
		/**战斗草船*/
		public static var FIGHTINGTYPE_SHIPWAR:int = 120;
		/**战斗-八卦*/
		public static const FIGHTINGTYPE_BAGUA:int = 121
		/**战斗-华容道*/
		public static const FIGHTINGTYPE_KLOTSKI:int = 122
		/**战斗-帮助页*/
		public static const FIGHTINGTYPE_PLAYER_HELP:int = 123;
		/**战斗-世界boss*/
		public static const FIGHTINGTYPE_WORLD_BOSS:int = 124;
		/**战斗爬塔*/
		public static var FIGHTINGTYPE_PATA:int = 125;
		//PVP 
		public static var FIGHTINGTYPE_PVP:Number = 200;
		//模拟战斗
		public static var FIGHTINGTYPE_SIMULATION:Number = 999;
		
		public function FightingManager()
		{
			if(_instance){				
				throw new Error("FightingManager是单例,不可new.");
			}
			_instance = this;
		}
		
		private var _fightingType:Number;
		private var _backH:Handler;
		private var serverConst:Number;
		private var _data:*;
		/**
		 *发起战斗请求
		 *type 0 普通 1推图 2基因副本 3世界BOSS 4怪物入侵 5武器副本 6掠夺 7劫镖 8公会boss...
		 *    110 基地互动布阵 111 运镖布阵（自己）  112 运镖布阵（他人）
		 *   9999
		 *d 与type对应的数据类型 
		 **/
		public function getSquad(type:Number = 0 , d:* = null , backH:Handler = null):void{
			var showAutoBtn:Boolean = true;
			if(ConditionsManger.cond("0=5")){
				showAutoBtn = false;
			}
			_fightingType = type;
			_data = d;
			_backH = backH;
			trace("设置战斗回调:"+_backH);
			FightingView.showRKMaxNum =  0;
			FightingView.showAutoBtn = showAutoBtn;
			if(_fightingType == FIGHTINGTYPE_STAGE)
			{
				//处理自动战斗相关问题。。
				var arr:Array = FightingStageManger.intance.stageList1;
				if(arr.length){
					for(var i:int=0; i<arr.length; i++){
						var tmp:Array = arr[i].levelList;
						for(var j=0; j<tmp.length; j++){
							if(tmp[j].id == d){
								FightingView.showAutoBtn = (tmp[j].star > 0);
								break;
							}
						}
					}
				}
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_FM;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_JINGYING)
			{
				//处理自动战斗相关问题。。
				var arr:Array = FightingStageManger.intance.stageList2;
				if(arr.length){
					for(var i:int=0; i<arr.length; i++){
						var tmp:Array = arr[i].levelList;
						for(var j=0; j<tmp.length; j++){
							if(tmp[j].id == d){
								FightingView.showAutoBtn = (tmp[j].star > 0);
								break;
							}
						}
					}
				}
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_JY;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_GENE)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_GENE;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_BOSS)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_WORLDBOSS;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else if(_fightingType == FIGHTINGTYPE_HOME)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_HOMEMONSTER;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_EQUIP)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_EQUIP;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else if(_fightingType == FIGHTINGTYPE_PLUNDER)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_HOME;
				//基地互动 特殊处理
				WebSocketNetService.instance.sendData(serverConst,[d[0]]);
				FightingView.showRKMaxNum = Number(d[1]);
			}
			else if(_fightingType == FIGHTINGTYPE_ROB)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_JIEBIAO;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_GUILDBOSS)
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST_GBOSS;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_JINJICHANG)
			{
				serverConst = ServiceConst.ARENA_ENTER_FIGHT;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_KUANGCHANG)
			{
				serverConst = ServiceConst.ENTER_MINE_FIGHT;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_BINGBOOK)
			{
				serverConst = ServiceConst.BINGBOOK_OPENFIGHT;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_SET_HOME)
			{
				serverConst = ServiceConst.FIGHTING_JIDI_BUZHEN;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else if(_fightingType == FIGHTINGTYPE_SET_ESCORT)
			{
				serverConst = ServiceConst.TRAN_ENTEREMBATTLE;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else if(_fightingType == FIGHTINGTYPE_SET_SELFESCORT) 
			{
				serverConst = ServiceConst.TRAN_ENYERFRIENDEMBATTLE;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}
			else if(_fightingType == FIGHTINGTYPE_SET_JINJICHANG)
			{
				serverConst = ServiceConst.ARENA_SET_DEFENCE;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else if(_fightingType == FIGHTINGTYPE_SET_KUANGCHANG)
			{
				serverConst = ServiceConst.SET_MINE_DEFENCE;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}else if(_fightingType == FIGHTINGTYPE_SET_ARMY){
				serverConst = ServiceConst.ARMY_GROUP_DEPLOY;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}else if(_fightingType == FIGHTINGTYPE_STAR){
				serverConst = ServiceConst.STAR_TREK_FIGHT;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_GROUP){
				sendStart(d);
				return;
			}else if(_fightingType == FIGHTINGTYPE_FORTRESS){
				serverConst = ServiceConst.FORTRESS_ENTER_CAMP;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_LONEHERO){
				serverConst = ServiceConst.LONEHERO_ENTER_FIGHT;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_SHIPWAR){
				serverConst = ServiceConst.CAOCHUAN_ENTER_CAMP;
				WebSocketNetService.instance.sendData(serverConst,d);
			}
			else if(_fightingType == FIGHTINGTYPE_PATA){
				serverConst = ServiceConst.PATA_ENTER_BATTLE;
				WebSocketNetService.instance.sendData(serverConst,d);
			}
			
			else if(_fightingType == FIGHTINGTYPE_BAGUA){
				serverConst = ServiceConst.BAGUA_ENTER_CAMP;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_KLOTSKI){
				serverConst = ServiceConst.KLOTSKI_ENTERFIGHT;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_PLAYER_HELP){
				serverConst = ServiceConst.PLAYER_FIGHT_ENTER;
				WebSocketNetService.instance.sendData(serverConst,d);
			}else if(_fightingType == FIGHTINGTYPE_WORLD_BOSS){
				serverConst = ServiceConst.BOSS_ENTER_PRESET;
				WebSocketNetService.instance.sendData(serverConst,d);
			}
			else if(_fightingType == FIGHTINGTYPE_SIMULATION)  //模拟战斗，数据拦截
			{
				serverConst = ServiceConst.SIMULATION_SENDF;
				FightSimulationManger.intance.sendData();
				FightingView.showAutoBtn = false;
			}else if(_fightingType == RANDOM_CONDITION)
			{
				serverConst = ServiceConst.RANDOM_CONDITION_ENTER;
				WebSocketNetService.instance.sendData(serverConst,[d]);
			}else if(_fightingType == PEOPLE_FALL_OFF)
			{
				serverConst = ServiceConst.PEOPLE_FALL_OFF_ENTER;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			else
			{
				serverConst = ServiceConst.FIGHTING_GETSQUAD_CONST;
				WebSocketNetService.instance.sendData(serverConst,[]);
			}
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			Signal.intance.once(ServiceConst.getServerEventKey(serverConst),this,getSquadBack);
		}
		
		//错误处理
		private function onErr(...args):void{
			var cmd:Number = args[1];
			if(cmd == serverConst){
				_backH && _backH.run(args);
				Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
				Signal.intance.off(ServiceConst.getServerEventKey(args[0]),this,getSquadBack);
			}
		}
		
		//战斗请求响应
		private function getSquadBack(... args):void{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			
			var sceneName:String = SceneType.M_SCENE_FIGHT;
			fightingServerID = args[1];
			var fDtype:String = FightingShowFormatData.TYPE_SQUAD;
			
			if(_fightingType == FIGHTINGTYPE_SET_HOME ||
				_fightingType == FIGHTINGTYPE_SET_ESCORT ||
				_fightingType == FIGHTINGTYPE_SET_SELFESCORT ||
				_fightingType == FIGHTINGTYPE_SET_JINJICHANG ||
				_fightingType == FIGHTINGTYPE_SET_KUANGCHANG ||
				_fightingType == FIGHTINGTYPE_WORLD_BOSS
			) {
				fDtype = FightingShowFormatData.TYPE_PRESET;
				if(args.length > 4)
				{
					var ooo:Object = args[4];
					if(ooo.hasOwnProperty("maxPopulation"))
					{
						FightingView.showRKMaxNum = Number(ooo["maxPopulation"]);
					}
				}
			}
			if(_fightingType == PEOPLE_FALL_OFF)
			{
				if(args.length > 4)
				{
					var ooo:Object = args[4];
					if(ooo.hasOwnProperty("maxPopulation"))
					{
						FightingView.showRKMaxNum = Number(ooo["maxPopulation"]);
					}
				}
			}
//			trace("战斗最大占位数据:"+args[4]);
			if(_fightingType == FIGHTINGTYPE_SIMULATION)
			{
				fDtype = FightingShowFormatData.TYPE_SIMULATION;
			}else if(_fightingType == FIGHTINGTYPE_PVP)
			{
				fDtype = FightingShowFormatData.TYPE_PVP_BUZHEN;
				sceneName = SceneType.M_SCENE_FIGHT_PVP;
			}else if(_fightingType == FIGHTINGTYPE_SET_ARMY){
				fDtype = FightingShowFormatData.TYPE_GUILD_FIGHT;
			}else if(_fightingType == FIGHTINGTYPE_BINGBOOK || _fightingType == FIGHTINGTYPE_STAR){
				fDtype = FightingShowFormatData.TYPE_RADAR;
			}else if(_fightingType == FIGHTINGTYPE_FORTRESS){
				fDtype = FightingShowFormatData.TYPE_FORTRESS;
			}else if(_fightingType == RANDOM_CONDITION){
				fDtype = FightingShowFormatData.RANDOM_CONDITION;
			}else if(_fightingType == PEOPLE_FALL_OFF){
				fDtype = FightingShowFormatData.PEOPLE_FALL_OFF;
				// pata || 从home页面跳入战斗页面包括（home页面的怪物入侵）   （纯猜的    只是想共用一下开展后可以有跳过战斗的效果     hejianbo）
			}else if(
				_fightingType == FIGHTINGTYPE_PATA 
				|| _fightingType == FIGHTINGTYPE_HOME
				|| _fightingType == FIGHTINGTYPE_PLUNDER
				|| _fightingType == FIGHTINGTYPE_EQUIP
				|| _fightingType == FIGHTINGTYPE_GENE
				|| _fightingType == FIGHTINGTYPE_JINJICHANG
				|| _fightingType == FIGHTINGTYPE_KUANGCHANG
			) {
				fDtype = FightingShowFormatData.CLIMB_TOWER;
			}
			
			SceneManager.intance.setCurrentScene(sceneName,false,1,FightingShowFormatData.create(
				fDtype,
				args[2],
				Number(args[4]["bgsrc"]),
				_backH
			));
			trace("开战协议:"+JSON.stringify(args[0]));
			trace("战斗请求返回1:"+JSON.stringify(args[1]));
			trace("战斗请求返回2:"+JSON.stringify(args[2]));
			trace("战斗请求返回3:"+JSON.stringify(args[3]));
			trace("战斗请求返回4:"+JSON.stringify(args[4]));
			setMyArmy(args[3]);
			
			_scence = SceneManager.intance.m_sceneCurrent;
			_needFood = args[4]["foodCost"]+"";
			_unitFood = args[4]["unitCost"];
			if(_needFood == "" && args[4]["unitCost"]){
				_needFood = args[4]["unitCost"]+"=0"
			}
			_scence && _scence.bindNeedFood(_needFood,_unitFood);
		}
		
		
		public function get moveFData():FightingFormatData
		{
			return _moveFData;
		}

		public function set moveFData(value:FightingFormatData):void
		{
			_moveFData = value;
		}

		public static function get velocity():Number
		{
			return _velocity;
		}
		
		public static function set velocity(value:Number):void
		{
			if(FightingScene.fightIsPlay && value)  //战斗回合内不显示
			{
				cacheVelocity = value;
				return ;
			}
			
			if(!value)
			{
				if(cacheVelocity){
					velocity = cacheVelocity;
				}
				return ;
			}
			
			if(_velocity != value)
			{
				_velocity = value;
				Signal.intance.event(FIGHT_VELOCITY_CHANGE);
			}
			cacheVelocity = 0;
		}
		
		public function getUnitTypeList():String{
			var arr:Array = ["L_A_44009","L_A_44010"];
			if(_fightingType == FIGHTINGTYPE_EQUIP ||
				_fightingType == FIGHTINGTYPE_BOSS
			)
			{
				arr.push("L_A_44029");
			}
			return arr.join(",");
		}
		
		public function getIsFZ(fData:*):Boolean{
			var uids:Array = [];
			if(fData["initFightArmy"] && fData["initFightArmy"]["2"] && fData["initFightArmy"]["2"]["uid"])
			{
				uids = fData["initFightArmy"]["2"]["uid"];
			}
			var myUid:String = String(GlobalRoleDataManger.instance.userid);
			
			for (var i:int = 0; i < uids.length; i++) 
			{
				var uid:String = String(uids[i]);
				if(uid == myUid)
				{
					return true;
					break;
				}
			}
			return false;
		}
		
		private var _fData:*;
		private var _moveFData:FightingFormatData;
		private var _scence:FightingScene;
		public function hostingFighting(fData:*,scence:FightingScene):void
		{
			//收到数据
			_fData = fData;
			trace("fData:::",fData)
			
			_scence = scence;
			_scence.bindNeedFood(_needFood, _unitFood);
			
			if(fData is FightingFormatData){
				moveFData = fData;
			}else
			{
				if(getIsFZ(fData))  //翻转视角
				{
					fData = flipData(fData);
					var cpD:Object = fData["initFightArmy"]["2"];
					fData["initFightArmy"]["2"] = fData["initFightArmy"]["1"];
					fData["initFightArmy"]["1"] = cpD;
				}
				
				moveFData = new FightingFormatData(fData);
			}
			
			
			
			//布局
			if(!doubtful()){
				removeData();
				return ;
			}
			
			if(moveFData.unitList)
			{
				_scence.fightingView.rankData(moveFData.unitList);
			}else
			{
				trace("没有初始顺序");
				return ;
			}
//			return ;
			
			//战斗
			var t:Timer = new Timer();
			var f:Function= function():void{
				t.clear(this,f);
				t = null;
				if(!forFighting())
				{
					removeData();
					return ;
				}
			}
			t.once(500,this,f);
			
		}
		
		public function get Scence():FightingScene{
			return _scence;
		}
		
		
		private function forFighting():Boolean
		{
			if(!moveFData.reports)
			{
				return false;
			}
			var keyAr:Array = moveFData.reportKeys.concat();
			goFighting(keyAr);
			//逐步战斗
			
			
			return true;
		}
		
		private function goFighting(keyAr:Array):void
		{
			if(isShowResult)
			{
				return ;
			}
			if(!keyAr.length || !moveFData)  //所有步骤进行完
			{
				
				if(_overData)
				{
					XFacade.instance.openModule(ModuleName.FightResultPanel,[_overData,Handler.create(this,fightingResultBack)]);
					_overData = null;
					return ;
				}
				
				
				XFacade.instance.openModule(ModuleName.FightReportOverView,[
					Handler.create(this,fightingResultBack)
				]);
				return ;
			}
			
			var reportKey:* = keyAr.shift();
			var subFData:ReportFormatData = moveFData.reports[reportKey];
//			_scence.fightingView.turn = Number(subFData.reportkey) == 0 ? 1 : subFData.reportkey;
			var subKeyAr:Array = subFData.subKeys.concat();
			toFighing(keyAr,subKeyAr,subFData);
		}
		
		
		private function toFighing(keyAr:Array,subKeyAr:Array,subFData:ReportFormatData):void
		{
			if(!subKeyAr.length)  //所有子步骤进行完
			{
				goFighting(keyAr);
				return ;
			}
			
			var k:* = subKeyAr.shift();
			var fData:SubReportFormatData = subFData.subReport[k];
			_scence.fightingFun(fData,subFData.reportkey, this,dormancy,[keyAr,subKeyAr,subFData]);
		}
		
		private var timer:Timer = new Timer();
		private function dormancy(keyAr:Array,subKeyAr:Array,subFData:Object):void
		{
//			timer.once(3000,this,toFighing,[keyAr,subKeyAr,subFData]);
			toFighing(keyAr,subKeyAr,subFData);
		}
		
		
		
		private function doubtful():Boolean{
			if(!moveFData.leftArmy || !moveFData.rightArmy)
			{
				trace("阵容不全");
				return false;
			}
			addArmy(moveFData.leftArmy);
			addArmy(moveFData.rightArmy , false);
			
			_scence.generateKey();
			return true;
		}
		
		public function addArmy(armyList:Array,isleft:Boolean = true,isUser:Boolean = false):int{
			if(!armyList)return ;
			var kpi:int = 0;
			for (var i:int = 0; i < armyList.length; i++) 
			{
				var am:Object = armyList[i];
				if(armyList[i].power){
					kpi = kpi + parseFloat(armyList[i].power);
				}
				
				var fdata:fightUnitData = new fightUnitData();
				fdata.direction = isleft  ? 1 : 2;
				fdata.unitId = Number(am.unitId);
				fdata.skin = am.skin;
				var maxHp:Number = Number(am.hp);
				var HP:Number = Number(am.restHp);
				fdata.maxHp = maxHp;
				fdata.hp = HP;
				
				if(am.skillId && am.skillId.length)
				{
					fdata.skillVos = getSkillVos(am.skillId);
				}
				
				//					fdata.unitVo.
				var isU:Boolean = (isUser && !fdata.unitVo.isBadItem) || (am.userId == Number(GlobalRoleDataManger.instance.userid));
				_scence.addUnit(fdata,isU && _fightingType,am.pos);
			}
			
			
			//兼容新手引导
			XFacade.instance.closeModule(PreLoadingView);
			return kpi;
		}
		
		
		public function getSkillVos(skillId:String):Array
		{
			var skillids:Array = skillId.split("|");
			var _skillVos:Array = [];
			for (var j:int = 0; j < skillids.length; j++) 
			{
				var skill:SkillVo = GameConfigManager.unit_skill_dic[skillids[j]];
				if(skill)
				{
					_skillVos.push(skill);
				}
			}
			return _skillVos;
		}
		
		
		public function removeData():void
		{
			removeFightingEvent();
			_fData = null;
			moveFData = null;
			_scence = null;
			soldierList = null;
			heroList = null;
			_overData = null;
			dataFlip = false;
			isShowResult = false;
		}
	
		
		//PVP 布阵数据
		public function setPvpSquad(type:Number = 0 , d:Array  , backH:Handler = null , showAutoBtn:Boolean = true):void{
			_fightingType = type;
			_backH = backH;
			FightingView.showRKMaxNum =  0;
			FightingView.showAutoBtn = showAutoBtn;
			this.getSquadBack.apply(this,d);
			
			
		}
		
		private var _needFood:String="";
		private var _unitFood:String;
		
		public function fightOutArmyCd(uuid:Number,t:Number):void{
			FightUtil.outArmyCd(uuid,t,Handler.create(this,fightOutArmyCdBack));
		}
		
		private function fightOutArmyCdBack(uuid:Number):void
		{
			var i:Number;
			var ad:ArmyData;
			if(heroList)
			{
				for (i = 0; i < heroList.length; i++) 
				{
					ad = heroList[i];
					if(ad.unitId == uuid)
						ad.save = 0;
				}
			}
			if(_scence && _scence.fightingView)
				_scence.fightingView.bindSelectUnitViewData();
		}
		
//		public var listData:Array;
		public var heroList:Array = null;
		public var soldierList:Array = null;
		public var itemList:Array = null;
		
		
		public function setMyArmy(eventData:*):void
		{
			var i:Number = 0;
			heroList = [];
			soldierList = [];
			itemList = [];
			var heroData:Array = eventData.hero;
			if(heroData && heroData.length)
			{	
				for (i = 0; i < heroData.length; i++) 
				{
					heroList.push(ArmyData.create(heroData[i]));
//					(heroList[i] as ArmyData).state = i+1;
				}
				heroList.sort(sortCompare);
			}
			var soldierData:Array = eventData.soldier;
			if(soldierData && soldierData.length)
			{	
				for (i = 0; i < soldierData.length; i++) 
				{
					soldierList.push(ArmyData.create(soldierData[i]));
				}
				soldierList.sort(sortCompare);
			}
			var itemData:Array = eventData.prop;
			if(itemData && itemData.length)
			{	
				for (i = 0; i < itemData.length; i++) 
				{
					itemList.push(ArmyData.create(itemData[i]));
				}
				itemList.sort(sortCompare);
			}
			
			if(_scence && _scence.fightingView)
				_scence.fightingView.bindSelectUnitViewData();
		}
		
		private function sortCompare( _d1:ArmyData , _d2:ArmyData ):int
		{
			return _d1.unitId > _d2.unitId ? 1 : -1;
		}
		
		//开打 PVP
		public function sendStartPvp():void{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_USEROK,[fightingServerID]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_USEROK),
				this,sendStartPvpBack);
		}
		
		public function sendStartPvpBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendStartPvpBack);
			if(_scence && _scence.fightingView){
				_scence.fightingView.selectUnitView.fightBtn.disabled = true;
				_scence.fightingView.selectUnitView.m_list.mouseEnabled = false;
			}
			if(_scence)
				_scence.unitLayer.mouseEnabled = false;
		}
		
		private var dataFlip:Boolean; //数据翻转
		public function sendStartPvpAllOkBack(... args):void{
			
			var copyAr:Array = [];
			for (var i:int = 0; i < args.length; i++) 
			{
				copyAr.push(args[i]);
			}
			fightingServerID = copyAr[1];
			if(copyAr.length > 4)
			{
				var rightUids:Array = copyAr[4][2].uid;
				for (var j:int = 0; j < rightUids.length; j++) 
				{
					if(String(rightUids[j]) == String(GlobalRoleDataManger.instance.userid))
					{
						dataFlip = true;
						break;
					}
				}
			}
			
			if(dataFlip)
			{
				copyAr = flipData(copyAr);
				if(copyAr.length > 4)
				{
					var obj:Object = copyAr[4];
					var fzObj:Object = obj[1];
					obj[1] = obj[2];
					obj[2] = fzObj;
				}
			}
			(_scence.fightingView as PvpFightingView).pvpTopView.stop();
			(_scence.fightingView as PvpFightingView).pvpTopView.start2(3,Handler.create(this,bindPvpOpenData,[copyAr]));
			(_scence.fightingView as PvpFightingView).rightTopView1.visible = false;
			if(_scence && _scence.fightingView){
				_scence.fightingView.selectUnitView.fightBtn.disabled = true;
				_scence.fightingView.selectUnitView.m_list.mouseEnabled = false;
			}
			if(_scence)
				_scence.unitLayer.mouseEnabled = false;
			AlertManager.instance().closeAlert();
			
			_scence.fightingView.selectUnitView.m_list.mouseEnabled = true;
			_scence.unitLayer.mouseEnabled = true;
		}
			
		
		private function bindPvpOpenData(copyAr:Array):void
		{
			if(copyAr.length > 4)
			{
				_scence.removerAllUnit();
				
				var obj:Object = copyAr[4];
				if(obj.hasOwnProperty("1"))
					FightingManager.intance.addArmy(obj[1].army,true);
				if(obj.hasOwnProperty("2"))
					FightingManager.intance.addArmy(obj[2].army,false);
			}
			var objStr:String = JSON.stringify(copyAr);
			
			_scence.fightingView.gotoSendStartBackData(copyAr);
		}
		
		//开打
		public function sendStart(data:*=null):void{
			if(!data){
				data = [fightingServerID];
			}

			if(_fightingType == FIGHTINGTYPE_PVP)
			{
				return sendStartPvp();
			}
			
			
			var serverConst:Number;
			if(_fightingType == FIGHTINGTYPE_STAGE)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_FM;
			}
			else if(_fightingType == FIGHTINGTYPE_JINGYING)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_JY;
			}
			else if(_fightingType == FIGHTINGTYPE_GENE)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_GENE;
			}else if(_fightingType == FIGHTINGTYPE_BOSS)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_WORLDBOSS;
			}else if(_fightingType == FIGHTINGTYPE_HOME)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_HOMEMONSTER;
			}
			else if(_fightingType == FIGHTINGTYPE_EQUIP)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_EQUIP;
			}
			else if(_fightingType == FIGHTINGTYPE_PLUNDER)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_HOME;
			}
			else if(_fightingType == FIGHTINGTYPE_ROB)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_JIEBIAO;
			}
			else if(_fightingType == FIGHTINGTYPE_GUILDBOSS)
			{
				serverConst = ServiceConst.FIGHTING_START_CONST_GBOSS;
			}
			else if(_fightingType == FIGHTINGTYPE_JINJICHANG)
			{
				serverConst = ServiceConst.ARENA_START_FIGHT;
			}
			else if(_fightingType == FIGHTINGTYPE_KUANGCHANG)
			{
				serverConst = ServiceConst.START_MINE_FIGHT;
			}
			else if(_fightingType == FIGHTINGTYPE_BINGBOOK)
			{
				serverConst = ServiceConst.BINGBOOK_STARTFIGHT;
			}
			else if(_fightingType == FIGHTINGTYPE_SET_HOME)
			{
				serverConst = ServiceConst.FIGHTING_SENDSQUAD_FY_SAVE_CONST;
			}
			else if(_fightingType == FIGHTINGTYPE_SET_ESCORT || _fightingType == FIGHTINGTYPE_SET_SELFESCORT)
			{
				serverConst = ServiceConst.TRAN_SAVEFORMATION;
			}
			else if(_fightingType == FIGHTINGTYPE_SET_JINJICHANG)
			{
				serverConst = ServiceConst.ARENA_SAVE_DEFENCE;
			}
			else if(_fightingType == FIGHTINGTYPE_SET_KUANGCHANG)
			{
				serverConst = ServiceConst.SAVE_MINE_DEFENCE;
			}else if(_fightingType == FIGHTINGTYPE_SET_ARMY){
				serverConst = ServiceConst.ARMY_GROUP_DEPLOY_SVAE;
			}else if(_fightingType == FIGHTINGTYPE_STAR){
				serverConst = ServiceConst.STAR_TREK_ONFIGHT;
			}else if(_fightingType == FIGHTINGTYPE_GROUP){
				serverConst = ServiceConst.ARMY_GROUP_FIGHT_START;
			}else if(_fightingType == FIGHTINGTYPE_FORTRESS){
				serverConst = ServiceConst.FORTRESS_START_CAMP;
				data = data.concat(_data);
				trace("堡垒战斗==》", data);
			}else if(_fightingType == FIGHTINGTYPE_LONEHERO){
				serverConst = ServiceConst.LONEHERO_ENTER_STAGE_FIGHT;
			}else if(_fightingType == FIGHTINGTYPE_SHIPWAR){
				serverConst = ServiceConst.CAOCHUAN_START_FIGHT;
				data = _data.concat(data);
				trace("草船战斗==》", data);
			}
			else if(_fightingType == FIGHTINGTYPE_PATA){
				serverConst = ServiceConst.PATA_BATTLE;
				trace("爬塔战斗==》", data);
			}
			else if(_fightingType == FIGHTINGTYPE_BAGUA){
				serverConst = ServiceConst.BAGUA_START_FIGHT
			}else if(_fightingType == FIGHTINGTYPE_PLAYER_HELP){    
				serverConst = ServiceConst.PLAYER_FIGHT_START
			}else if(_fightingType == FIGHTINGTYPE_KLOTSKI){
				serverConst = ServiceConst.KLOTSKI_STARTFIGHT
			}else if(_fightingType == RANDOM_CONDITION) {
				serverConst = ServiceConst.RANDOM_CONDITION_FIGHTING;			
			}else if(_fightingType == FIGHTINGTYPE_WORLD_BOSS){
				serverConst = ServiceConst.BOSS_SAVE_PRESET;
				(data as Array).unshift(this._data[0]);
				trace("世界BOSS战==》", data);

			}
			else if(_fightingType == PEOPLE_FALL_OFF)
			{
				serverConst = ServiceConst.PEOPLE_FALL_OFF_FIGHTING;			
			}
			else if(_fightingType == FIGHTINGTYPE_SIMULATION)
			{//新手战斗
				serverConst = ServiceConst.SIMULATION_START;
				Signal.intance.on(
					ServiceConst.getServerEventKey(serverConst),
					this,sendStartBack);
				FightSimulationManger.intance.startData();
				addFightingEvent();
				return ;
			}
			else
			{
				serverConst = ServiceConst.FIGHTING_START_CONST;
			}
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			Signal.intance.on(ServiceConst.getServerEventKey(serverConst),this,sendStartBack);
			
			
			WebSocketNetService.instance.sendData(serverConst, data);
			
			addFightingEvent();
		}
		
		//开打响应
		public function sendStartBack(... args):void{
			Signal.intance.off(ServiceConst.getServerEventKey(args[0]),this,sendStartBack);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			
			
			
			if(_fightingType == FIGHTINGTYPE_SET_HOME
				|| _fightingType == FIGHTINGTYPE_SET_ESCORT 
				|| _fightingType == FIGHTINGTYPE_SET_SELFESCORT
				|| _fightingType == FIGHTINGTYPE_SET_JINJICHANG
				|| _fightingType == FIGHTINGTYPE_SET_KUANGCHANG
				|| _fightingType == FIGHTINGTYPE_SET_ARMY
				|| _fightingType == FIGHTINGTYPE_WORLD_BOSS
			)
			{
				if(_scence.completeHandler)
					_scence.completeHandler.run();
				else
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
				
				return ; 
			}else if(_fightingType == FIGHTINGTYPE_GROUP){
				showFightReportBack(args[1],args.length > 1 ? args[2]:null);
				return;
			}
			
			var copyAr:Array = [];
			for (var i:int = 0; i < args.length; i++) 
			{
				copyAr.push(args[i]);
			}
			trace("开始战斗数据1:"+JSON.stringify(args[0]));
			trace("开始战斗数据2:"+JSON.stringify(args[1]));
			trace("开始战斗数据3:"+JSON.stringify(args[2]));
			trace("开始战斗数据4:"+JSON.stringify(args[3]));
			trace("开始战斗数据5:"+JSON.stringify(args[4]));
			trace("开始战斗数据6:"+JSON.stringify(args[5]));
			_scence.fightingView.gotoSendStartBackData(copyAr);
			
			
			
		}
		
		public function playF(args:Array):void
		{
			var pskills:Object = args[3];
			for(var k:String in pskills)
			{
				var uitem:BaseUnit = _scence.getUnitByPoint(k);
				if(uitem)
				{
					uitem.data.skillVos = getSkillVos(pskills[k].skillId);
				}
			}
			
			this.moveFData = new FightingFormatData(null);
			_scence.beginFighting(moveFData);  //录像 双方阵容
			moveFData.unitList = args[2];
			_scence.fightingView.rankData(moveFData.unitList);
		}
		
		
		public var fightingServerID:String;
		
		
		
		public function sendAttack(ar:Array , winHandler:Handler):void{
			
			if(_fightingType == FIGHTINGTYPE_SIMULATION)
			{
				winHandler.run();
				FightSimulationManger.intance.pushBu();
				_scence.fightingView.stopTimerChange();
				return ;
			}
			if(dataFlip)
				ar = flipData(ar);
			
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_SENDATTACK_CONST,ar);
			_scence.fightingView.stopTimerChange();
			
			var f:Function = function(... args):void{
				Signal.intance.off(
					ServiceConst.getServerEventKey(args[0]),
					this,f);
				var n:* = args[1];
				if(n == 0)
					winHandler.run();
				else
					XTip.showTip(n);
			}
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_SENDATTACK_CONST),
				this,f);
			
		}
		
		
		public function addFightingEvent():void{
			removeFightingEvent();  //避免重复添加
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_SINGLESTEP_CONST),
				this,fightingDataBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_RESULTS_CONST),
				this,fightingDataBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_RESULTS_CONST2),
				this,fightingDataBack2);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.ERROR_FIGHT),
				this,fightingDataBack);
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_FANGQI_BACKDATA),
				this,fightingDataBack2);
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_ALLOK),
				this,sendStartPvpAllOkBack);
		}
		
		public function removeFightingEvent():void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_SINGLESTEP_CONST),
				this,fightingDataBack);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_RESULTS_CONST),
				this,fightingDataBack);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.ERROR_FIGHT),
				this,fightingDataBack);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.PVP_FANGQI_BACKDATA),
				this,fightingDataBack2);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_RESULTS_CONST2),
				this,fightingDataBack2);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.PVP_ALLOK),
				this,sendStartPvpAllOkBack);
		}
		
		public function backFun():void
		{
			if(_fightingType == FIGHTINGTYPE_SET_HOME || _fightingType == FIGHTINGTYPE_SET_ARMY)  //基地互动
			{
				//比对
				if(_scence.isChange)  //发生变化了
				{
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_49017"),0,function(v:uint):void{
						if(v == AlertType.RETURN_YES)
						{
							sendStart();
						}else{
							escapeFun();
						}
					});
					return ;
				}
				
				if((!_scence.mySelectUnitIds || !_scence.mySelectUnitIds.length))
				{
					if(_fightingType == FIGHTINGTYPE_SET_HOME){
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_49047"),0,function(v:uint):void{
							if(v == AlertType.RETURN_YES)
							{
								escapeFun();
							}
						});
					}else{
						escapeFun();
					}
					return ;
				}
			}
			
			if(_fightingType == FIGHTINGTYPE_PVP)  //PVP
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_71012"),0,function(v:uint):void{
					if(v == AlertType.RETURN_YES)
					{
						escapeFun();
					}
				});
				return ;
			}
			
			escapeFun();
		}
		
		public function escapeFun(sendMsg:Boolean = true):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_ESCAPE_BACK_CONST),
				this,fightingDataBack);
			
			if(_scence.fightingView.showType != FightingView.SHOWTYPE_2 && sendMsg)
			{
				if(    _fightingType == FIGHTINGTYPE_SET_HOME
					|| _fightingType == FIGHTINGTYPE_SET_ESCORT 
					|| _fightingType == FIGHTINGTYPE_SET_SELFESCORT
					|| _fightingType == FIGHTINGTYPE_SET_JINJICHANG
					|| _fightingType == FIGHTINGTYPE_SET_KUANGCHANG
					|| _fightingType == FIGHTINGTYPE_SET_ARMY
					|| _fightingType == FIGHTINGTYPE_WORLD_BOSS
				)
				{
					WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_BUZHEN_BACK,[fightingServerID]);
				}
				else if(_fightingType == FIGHTINGTYPE_PVP)  //PVP
				{
					WebSocketNetService.instance.sendData(ServiceConst.PVP_FANGQI,[]);
				}
				else
				{
					WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_KAIZHAN_BACK,[fightingServerID]);
				}	
				
			}else
			{
				if(_overData)  //已经有结算数据了
				{
					XFacade.instance.openModule(ModuleName.FightResultPanel,[_overData,Handler.create(this,fightingResultBack)]);
					_overData = null;
					isShowResult = true;
					return ;
				}
			}
			if(_fightingType == FIGHTINGTYPE_PVP)  //PVP
			{
				return ;
			}
			
			if(_scence.completeHandler){
				_scence.completeHandler.run();
			}
			else{
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME); 
			}
		}
		
		private var isShowResult:Boolean;
		
		private var _winHandler:Handler;
		private var _failureHandler:Handler;
		/**
		 *英雄操作协议
		 *optype 操作类型 1新增 2移动
		 *opUid 操作单位ID
		 *opPoint  操作单位位置
		 *opToPoint 操作目标位置 默认值""
		 *winHandler 成功回调 默认值null
		 *failureHandler 失败回调，默认值null
		 */
		public function unitOperation(optype:int,opUid:int,opPoint:String,opToPoint:String = "", wyid:String = "",winHandler:Handler = null,failureHandler:Handler = null):void{
			
			_winHandler = winHandler;
			_failureHandler = failureHandler;
			var _const:Number = ServiceConst.FIGHTING_SENDSQUAD_CONST;
			if(_fightingType == FIGHTINGTYPE_EQUIP)
				_const = ServiceConst.FIGHTING_SENDSQUAD_EQUIP_CONST;
			if(_fightingType == FIGHTINGTYPE_PVP)
				_const = ServiceConst.FIGHTING_SENDSQUAD_PVP_CONST;
			if(_fightingType == FIGHTINGTYPE_SET_HOME
				|| _fightingType == FIGHTINGTYPE_SET_ESCORT 
				|| _fightingType == FIGHTINGTYPE_SET_SELFESCORT 
				|| _fightingType == FIGHTINGTYPE_SET_JINJICHANG
				|| _fightingType == FIGHTINGTYPE_SET_KUANGCHANG
				|| _fightingType == FIGHTINGTYPE_SET_ARMY
				|| _fightingType == FIGHTINGTYPE_WORLD_BOSS
			)
				_const = ServiceConst.FIGHTING_SENDSQUAD_FY_CONST;
			
			
			
			var b:Boolean = WebSocketNetService.instance.sendData(_const,[optype,fightingServerID,opUid,opPoint,opToPoint,wyid]);
			if(!b)
			{
				if(_failureHandler != null)
					_failureHandler.run();
				XTip.showTip("The operation is too fast ");
				return ;
			}
			DataLoading.instance.show();
			Signal.intance.on(
				ServiceConst.getServerEventKey(_const),
				this,sendSquadBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.ERROR),
				this,errorBack);
		}
		
		private function errorBack(...args):void{
			serverBack(args[1],false,args[2]);
		}
		
		private function serverBack(serverC:Number,isWin:Boolean = false,errorStr:String = null):void
		{
			trace("移除监听",serverC);
			Signal.intance.off(
				ServiceConst.getServerEventKey(serverC),
				this,sendSquadBack);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.ERROR),
				this,errorBack);
			
			DataLoading.instance.close();
			
			
			if(isWin)
			{
				if(_winHandler != null)
					_winHandler.run();
			}else
			{
				if(errorStr)
					XTip.showTip(errorStr);
				if(_failureHandler != null)
					_failureHandler.run();
			}
			_winHandler = _failureHandler = null;
			
		}
		
		
		public function sendSquadBack(... args):void{
			
			var backMsg:String = String(args[1]);
			if(backMsg == "0")
			{
				serverBack(args[0],true);
			}else
			{
				serverBack(args[0],false,backMsg);
			}
//			_winHandler = _failureHandler = null;
			
//			this.moveFData = new FightingFormatData(null);
//			_scence.beginFighting(moveFData);
			
		}
		
		
		//投降协议
		public function sendEscape():void
		{
			var alertStr:String = _fightingType == FIGHTINGTYPE_PVP ? "L_A_71013" : "L_A_4400";
			
			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,alertStr,0,function(v:uint):void{
				if(v == AlertType.RETURN_YES)
				{
					alertEcapeBack();
				}
			});
			
		}
		
		public function alertEcapeBack():void
		{
			if(_overData)  //已经收到结束数据了
			{
				escapeFun(false);
				return ;
			}
			
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_ESCAPE_CONST,[fightingServerID]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_ESCAPE_BACK_CONST),
				this,fightingDataBack);
		}
		
		/**跳过*/
		public function skip():void{
			//DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.FIGHT_SKIP,[fightingServerID]);
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.FIGHT_SKIP),this,onSkipBack);
			
			function onSkipBack(...args):void{
				DataLoading.instance.close();
				if(args[1] == 1){
					if (_scence && _scence.stopAutoFight) {
						_scence.stopAutoFight();
					}
					escapeFun(false);
				}
			}
		}
		
		
		public function parsingFun(fList:Array , isOver:uint , uid:* , rightPos:String):void
		{
			if(!_scence)
				return ;
			
			var ar2:Array = [];
			for (var i:int = 0; i < fList.length; i++) 
			{
				//trace("接收战报回合数", fList[i].round);
				if(_fightingType == FIGHTINGTYPE_SIMULATION && fList[i].round == 1)
				{
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FINISH,[999]);
				}
				
				if (!User.getInstance().hasFinishGuide)
				{
					Signal.intance.event(NewerGuildeEvent.FIGHT_CHANGE_ROUND);
				}
				var subr:SubReportFormatData = new SubReportFormatData(fList[i].report);
				subr.reportkey = fList[i].round;
				ar2.push(
					subr
				);
				
				var red:ReportFormatData = moveFData.reports[fList[i].round];
				if(!red)
				{
					red = moveFData.reports[fList[i].round] = new ReportFormatData(null);
					red.reportkey = fList[i].round;
					moveFData.reportKeys.push(Number(red.reportkey));
					
//					_scence.fightingView.turn = Number(red.reportkey) == 0 ? 1 : red.reportkey;
				}
				var sbkey:Number = red.subKeys.length ? red.subKeys[red.subKeys.length - 1] : 0;
				sbkey ++;
				
				red.subReport[sbkey] = subr;
				red.subKeys.push(sbkey);
				if(Number(red.reportkey) == 0 && sbkey == 1)
				{
					moveFData.unitList = subr.unitList;
					subr.unitList = null;
					_scence.fightingView.rankData(moveFData.unitList);
				}
				
			}
			serverFightingFun(ar2,isOver,uid,rightPos);
		}
		
		public function autoFighting():void{
			trace(1,"托管状态");
			trace(1,Browser.now());
			if(!_scence || !_scence.fightingView || _overData)  //_overData 如果有介绍数据后，也不发送自动
				return;
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_SUTOATTACK_CONST,[fightingServerID]);
			_scence.fightingView.stopTimerChange();
//			_scence.fightingView.rightBottomView.mouseEnabled = false;
			
		}
		
		private function fightingResultBack(v:uint):void
		{
			if(!_scence) return ;
			trace("_scence.completeHandler_________________",_scence.completeHandler)
			if(v == AlertType.RETURN_YES)
			{
				_scence.playback(moveFData);
			}else{
				if(_scence.completeHandler)
				{
					if(_fightingType == FIGHTINGTYPE_FORTRESS){
						_scence.completeHandler.runWith(FightingScene.waveNum)
					}else{
						_scence.completeHandler.run();
					}
					
				}else{
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
				}
			}
		}
		
		private function openOver():void
		{
			if(!_scence) return ;
			if(_fightingType == FIGHTINGTYPE_SIMULATION)
			{
				Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FINISH,[4]);
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
				return ;
			}
			
			if(_overData)
			{
				XFacade.instance.openModule(ModuleName.FightResultPanel,[_overData,Handler.create(this,fightingResultBack)]);
				_overData = null;
				return ;
			}
			
//			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"战斗结束，是否回放？",0,function(v:uint):void{
//				if(v == AlertType.RETURN_YES)
//				{
//					_scence.playback(moveFData);
//				}else{
//					if(_scence.completeHandler)
//					{
//						_scence.completeHandler.run();
//					}
//					else
//						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
//				}
//			});
		}
		
		public function serverFightingFun(fList:Array , isOver:uint , uid:* , rightPos:String):void{
			if(!_scence)
				return ;
			if(!fList.length)
			{
				if(isOver != 0)
				{
//					alert("战斗结束");
					
					Laya.timer.once(100,this,openOver);
					return ;
				}
//				trace(1,"播放结束",uid,_scence.fightingView.leftRank[0].pos);
//				trace(1,Browser.now());
				
				if(uid == GlobalRoleDataManger.instance.userid){
					
					if(_scence.fightingView.autoFighting){
						autoFighting();
						_scence.fightingView.countdown(0,null);
						return ;
					}
					trace(1,"选目标",uid,rightPos);
//					var d:Object = _scence.fightingView.leftRank[0];
//					_scence.useUnit(d.pos,Number(d.unitId));
					_scence.useUnit(rightPos);
					
				}
				if(_fightingType == FIGHTINGTYPE_SIMULATION)
				{
					FightSimulationManger.intance.disEvent();
				}
				
				return ;
			}
			var fData:SubReportFormatData = fList.shift();
			_scence.fightingFun(fData,"",this,serverFightingFun,[fList,isOver,uid,rightPos]);
		}
		
		private function getRightAPos(ar:Array):String{
			if(!ar || !ar.length) return null;
			var obj:Object = ar[ar.length - 1];
			if(obj.report && obj.report.unitList)
			{
				var ar:Array = obj.report.unitList;
				if(ar[0] is Object)
					return ar[0]["pos"];
				var unitObj:Object = SubReportFormatData.formatUnit(ar[0]);
				return unitObj.pos;
			}
			return null;
		}
		
		private var _overData:FightingResultsData;
		public function fightingDataBack(... args):void{
			
			if(_scence && _scence.fightingView && _scence.fightingView.dataPool)
			{
				var copyAr:Array = [];
				for (var i:int = 0; i < args.length; i++) 
				{
					copyAr.push(args[i]);
				}
				//trace("缓存数据战斗数据",copyAr);
				_scence.fightingView.dataPool.push(copyAr);
				return;
			}
			
			switch(args[0])
			{
				case ServiceConst.FIGHTING_SINGLESTEP_CONST:
				{
					var argAr:Array = [];
					for (var j:int = 0; j < args.length; j++) 
					{
						argAr.push(args[j]);
					}
					//是否翻转
					if(dataFlip)
						argAr = flipData(argAr);
					var rightPos:String = getRightAPos(argAr[1]);
					trace(1,"下次手动出手位置是:",rightPos);
					parsingFun(argAr[1],argAr[2],argAr[3],rightPos );
					
					//特殊材处理草船
					if(_fightingType == FIGHTINGTYPE_SHIPWAR){
						(XFacade.instance.getView(FightingView) as FightingView).showItem(parsingHp(args[1]))
					}
					break;
				}
				case ServiceConst.FIGHTING_RESULTS_CONST:
				{
					//trace(1,JSON.stringify(args));
					
					var obj:Object = args[1];
					var uid:* = GlobalRoleDataManger.instance.userid;
					if(obj && obj.hasOwnProperty(uid))
					{
						_overData = new FightingResultsData(obj[uid]);
						
						var o:Object = obj[uid];
						if(o.hasOwnProperty("returnType"))
						{
							EquipFightInfoView.returnType = Number(o["returnType"]);
						}
						
					}
					break;
				}
				case ServiceConst.FIGHTING_ESCAPE_BACK_CONST:
				{
					escapeFun(false);
					break;
				}	
				case ServiceConst.ERROR_FIGHT:
				{
					XTip.showTip(args[2]);
					escapeFun(false);
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function parsingHp(hpInfo:Array):void{
			var hp:int = 0;
			var info:Object;
			var arr:Array;
			var tmp:Object;
			var tmpArr:Array;
			var tmpArr2:Array;
			for(var i:int=0; i<hpInfo.length; i++){
				info = hpInfo[i];
				if(info && info.report && info.report.fighter && info.report.fighter.attack){
					arr = info.report.fighter.attack.te;
					if(arr){
						for(var j:int=0; j<arr.length; j++){
							tmpArr = arr[j];
							if(tmpArr){
								for(var k:int=0; k<tmpArr.length; k++){
									trace("parseHp:::",parseHp(tmpArr[k]));
									hp += parseHp(tmpArr[k])
								}
							}
						}
					}
					
					var obj:Object = info.report.fighter.attack.fe;
					for(var ii:String in obj){
						if(obj[ii] is Array){
							tmpArr = obj[ii];//like skill2
							trace("fe1::::",tmpArr)
							for(j=0; j<tmpArr.length; j++){
								trace("fe2:::",tmpArr[j])
								if(tmpArr[j].hasOwnProperty("te")){
									arr = tmpArr[j]["te"];
									trace("fe3:::",arr)
									if(arr){
										for(var k:int=0; k<arr.length; k++){
											trace("fe:::",parseHp(arr[k]));
											hp += parseHp(arr[k])
										}
									}
								}
							}
						}
					}

				}
				
				if(info && info.report && info.report.posHurt){
					tmpArr = info.report.posHurt
					for(var k:int=0; k<tmpArr.length; k++){
						trace("posHurt:::",parseHp(tmpArr[k]));
						hp += parseHp(tmpArr[k])
					}
				}
				
			}
			return hp;
			
			function parseHp(teInfo:Object):int{
				var hpNum:int = 0;
				var tmp:Array  = (teInfo.originPos+"").split("_");
				if(tmp[1].charAt(0) == "1"){
					var subHps:Array = (teInfo.subHp || []);
					for(var ix:int=0; ix<subHps.length; ix++){
						hpNum += subHps[ix];
					}
				}
				return hpNum;
			}
		}
		
		public function fightingDataBack2(... args):void{
			
			if(_scence is PveFightingScane) return ; 
			
			switch(args[0])
			{
				case ServiceConst.PVP_FANGQI_BACKDATA:
				case ServiceConst.FIGHTING_RESULTS_CONST2:
				{
					(_scence.fightingView as PvpFightingView).pvpTopView.stop();
					
					var obj:Object = args[1];
					var uid:* = GlobalRoleDataManger.instance.userid;
					if(obj && obj.hasOwnProperty(uid))
					{
						var _overData2:FightingResultsData = new FightingResultsData(obj[uid]);
						//测试数据
//						_overData2.integral = 1500;
//						_overData2.addIntegral = 1000;
//						_overData2.isWin = true;
//						_overData2.gradesRewards = [
//							{
//								id:1,num:1000
//							},
//							{
//								id:2,num:1000
//							}
//						];
						//测试数据
						
						XFacade.instance.openModule(ModuleName.FightResultPanel,[_overData2,Handler.create(this,fightingResultBack)]);
					}
					break;
				}
			}
		}
		
		
		

		
		/**
		 *stype 0 普通扫荡 1 精英扫荡 
		 */
		public function saoDangStage(ar:Array , nm:Number , lId:Number , sType:Number = 0):void
		{
			m_need = ar;
			ConsumeHelp.Consume(ar,Handler.create(this,gotoSaoDang,[nm,lId,sType]));
		}
		
		private function gotoSaoDang(nm:Number, lId:Number, sType:Number):void
		{
			var sId:Number = sType?ServiceConst.FIGHTING_MAP_SAODANG_JY : ServiceConst.FIGHTING_MAP_SAODANG;
			WebSocketNetService.instance.sendData(sId,[lId,nm]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(sId),
				this,sendSaodangBack);
		}
		
		
		private function sendSaodangBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendSaodangBack);
			var ar:Array = args[1];
			var ar2:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
				var ar3:Array = ar[i];
				var ar4:Array = [];
				ar2.push(ar4);
				for (var j:int = 0; j < ar3.length; j++) 
				{
					var itemD:ItemData = new ItemData();
					itemD.iid = Number(ar3[j].id);
					itemD.inum = Number(ar3[j].num);
					ar4.push(itemD);
				}
			}
			
			
			var id:Number = Number(args[2]);
			var fNum:Number = Number(args[3]);
			
			if(ar.length == 1)
			{
				XFacade.instance.openModule(ModuleName.SaoDangRewardView1,[id,fNum,ar2[0],m_need , args[0] == ServiceConst.FIGHTING_MAP_SAODANG ?0:1 ]);
			}else
			{
				XFacade.instance.openModule(ModuleName.SaoDangRewardView2,[ar2]);
			}
		}
		
		
		/**
		 *播放战报
		 *data 请求参数  [a,b,c....] 或  a
		 *openH 请求战报成功后调用 
		 *overH 播放完战报后调用
		 *errorH 请求战报发生错误时候调用
		 *serverId 战报请求协议  
		 */
		private var _openH:Handler;
		private var _overH:Handler;
		private var _errorH:Handler;
		public function getFightReport(data:*,openH:Handler = null, overH:Handler = null , errorH:Handler ,serverId:Number = ServiceConst.getFightReport):void
		{
			_fightingType = 0;
			_openH = openH;
			_overH = overH;
			_errorH = errorH;
			var ar:Array = [];
			if(data)
			{
				if(data is Array)
					ar = data
				else
					ar.push(data);
			}
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(serverId,ar);
			Signal.intance.on(
				ServiceConst.getServerEventKey(serverId),
				this,getFightReportBack);
		}
		
		private function getFightReportBack(... args):void{
			DataLoading.instance.close();
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getFightReportBack);
			showFightReportBack(args[1],args.length > 1 ? args[2]:null);
		}
		
		// 组队副本的处理
		public function showFightReport(t_fData:Object , t_rData:Object = null , overH:Handler = null):void
		{
			_overH = overH; 
			_fightingType = 0;
			showFightReportBack(t_fData,t_rData, true);
		}
			
		private function showFightReportBack(t_fData:Object , t_rData:Object = null, isZuduifuben:Boolean = false):void
		{
			var rD:* = t_fData;
			if(t_rData)
				_overData = new FightingResultsData( t_rData );
			if(rD is Object)
			{
				if(_openH)_openH.run();
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT,false,1,{type:"report",data:rD,complete:_overH, isZuduifuben: isZuduifuben});
			}else
			{
				if(_errorH)_errorH.runWith(1);
			}
			
			_openH = null;
			_overH = null;
			_errorH = null;
		}
		
		
		
		public static  function flipData(d:Object):Object{
			var jsStr:String = JSON.stringify(d);
			
			var thList:Array = [];
			
			thList.push(
				[
					new RegExp("point_2","g"),
					"point_3"
				],
				[
					new RegExp("point_1","g"),
					"point_2"
				],
				[
					new RegExp("point_3","g"),
					"point_1"
				]
			);
			
			for (var k:int = 1; k <= 2; k++) 
			{
				for (var i2:int = 1; i2 <= 4; i2++) 
				{
					for (var i3:int = 0; i3 < 3; i3++) 
					{
						var key1:String = "point_"+k+i2 +(i3 * 2 + 1);
						var key2:String = "point_"+k+i2 +(i3 * 2 + 2);
						var key3:String = "point_T"+k+i2 +(i3 * 2 + 2);
						thList.push(
							[
								new RegExp(key1,"g"),
								key3
							],
							[
								new RegExp(key2,"g"),
								key1
							],
							[
								new RegExp(key3,"g"),
								key2
							]
						);
					}
				}
			}
			
			
			
			
			for (var j:int = 0; j < thList.length; j++) 
			{
				var aa:Array = thList[j];
				jsStr = jsStr.replace(aa[0] , aa[1]);
			}
			return JSON.parse(jsStr);
		}
		
		public function get fightingType():int{
			return this._fightingType;
		}
		
		
		public static function get intance():FightingManager
		{
			if(_instance)
				return _instance;
			_instance = new FightingManager;
			return _instance;
		}
	}
}