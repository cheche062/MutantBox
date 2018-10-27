package game.module.fighting.mgr
{
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.cond.ConditionsManger;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.StageChapterVo;
	import game.global.vo.StageLevelVo;
	import game.global.vo.VIPVo;
	import game.module.fighting.panel.SaoDangRewardView1;
	import game.module.fighting.panel.SaoDangRewardView2;
	import game.module.fighting.sData.stageChapetrData;
	import game.module.fighting.sData.stageLevelData;
	import game.module.fighting.view.FightingChapetrView;
	import game.module.fighting.view.FightingJYChapetrView;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Handler;
	import laya.utils.Timer;

	/**推图*/
	public class FightingStageManger
	{
		public static var FIGHTINGMAP_INIT:String = "FIGHTINGMAP_INIT";  //数据初始化
		public static var FIGHTINGMAP_CHAPETR_INIT:String = "FIGHTINGMAP_CHAPETR_INIT";  //某关数据初始化
		
		public static var FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE = "FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE"; //章节领奖状态发生变化
		
		public static var FIGHTINGMAP_LEVEL_CHANGE:String = "FIGHTINGMAP_LEVEL_CHANGE";  //关卡信息变化
		public static var FIGHTINGMAP_LEVEL_STAR_CHANGE:String = "FIGHTINGMAP_LEVEL_STAR_CHANGE";  //星级变化
		public static var FIGHTINGMAP_LEVEL_FNUM_CHANGE:String = "FIGHTINGMAP_LEVEL_FNUM_CHANGE";  //攻打次数发生变化
		
		
//		public static var TEXING_CHANGE:String = "TEXING_CHANGE";
		
		public var isInit:Boolean = false;  //是否首次请求过数据
		public var isSend:Boolean = false;
		public var stageList1:Array = [];  //主线可攻打关卡
		public var stageList2:Array = [];  //精英可攻打关卡
		public var buyNum1:Number = 0;  //主线购买次数 
		public var buyNum2:Number = 0;  //精英购买次数 
		public var autoSelectCID:int = -1;  //手动选择关卡ID;
		/***
		 *全局配置表控制器 
		 */
		private static var _instance:FightingStageManger;

		private var maxcId:Number;

		public var ifFirstCharge:Boolean = false;
		public function FightingStageManger()
		{
			if(_instance){				
				throw new Error("FightingStageManger是单例,不可new.");
			}
			_instance = this;
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_CHAPETR),
				this,getChapetrDataBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_LEVEL_CHANGE),
				this,levelChangeBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_CHAPETR_REWARD),
				this,rewardChangeBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_BUYNUM_CHANGE),
				this,buyNumChangeBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_FNUM_CHANGE),
				this,fightingNumChangeBack);
			
		}
		
		
		
		public static function get intance():FightingStageManger
		{
			if(_instance)
				return _instance;
			_instance = new FightingStageManger;
			return _instance;
		}
		
		public function initData():void{
			if(isSend) return ;
			isSend = true;
			
			//加载推图相关配置
			ResourceManager.instance.load("FightingStageManger",Handler.create(this,onLoaded));
		}
		
		private function onLoaded(_e:*=null):void{
			//初始推图相关配置
			GameConfigManager.initStageConfig();
			initServerData();
		}
		
		
		
		private function initServerData():void
		{
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.NEW_FIGHTING_MAP_INIT),
				this,initServerDataBack);
			WebSocketNetService.instance.sendData(ServiceConst.NEW_FIGHTING_MAP_INIT);
		}
		
		
		private function initServerDataBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,initServerDataBack);
			
			var d:Object;
			var lvId:Number;
			d = args[1];

			buyNum1 = Number(d.buyTimes);
			lvId =  Number(d.maxLevel);
			initSetData(lvId,false);
			
			d = args[2];
			buyNum2 = Number(d.buyTimes);
			lvId =  Number(d.maxLevel);
			
			initSetData(lvId,true);
			
			isInit = true;
			Signal.intance.event(FIGHTINGMAP_INIT);
		}
		
		
		private function initSetData(lvId:Number,jy:Boolean):void{
			if(!lvId) return ;
			var lvdic:Object; //关卡LIST
			var lvArr:Array;
			var chapDic:Object;
			var list:Array;
			//trace("精英？"+jy);
			if(!jy)
			{
				lvdic = GameConfigManager.stage_level_dic;
				lvArr = GameConfigManager.stage_level_arr;
				chapDic = GameConfigManager.stage_chapter_dic;
				list = stageList1;
			}else
			{
				lvdic = GameConfigManager.stage_level_jy_dic;
				lvArr = GameConfigManager.stage_level_jy_arr;
				chapDic = GameConfigManager.stage_chapter_jy_dic;
				list = stageList2;
				
			}
			var vo:StageLevelVo = lvdic[lvId];//最大开启关卡对应最大章节
			maxcId = vo.chapter_id;
			trace("lvId:"+lvId); 
//			trace("lvdic:"+JSON.stringify(lvdic));
			trace("cId:"+maxcId);
			for (var i:int = 1; i <= maxcId; i++) 
			{
				var cVo:StageChapterVo = chapDic[i];
				
				list.push(newStageChapetrData(jy,i,cVo,lvId,vo.chapter_id,maxcId));
			}
			
		}
		
		
		private function newStageChapetrData(jy:Boolean , cid:Number , cVo:StageChapterVo , maxLv:Number = 0,maxcId:int):stageChapetrData{
			var scData:stageChapetrData = new stageChapetrData();
			scData.type = jy ? 2 : 1;
			scData.id = cid;
			for (var j:int = 0; j < cVo.levelList.length; j++) 
			{
				var levelVo:StageLevelVo = cVo.levelList[j];
				var slData:stageLevelData = new stageLevelData();
				slData.type = scData.type;
				slData.id = levelVo.id;
//				slData.star = levelVo.id <= maxLv ? 1 : 0;
//				slData.star = 1;//全部解锁
				if(levelVo.chapter_id<maxcId)
				{
					slData.star = 1;
				}else if(levelVo.chapter_id == maxcId)
				{
					if(levelVo.id<=maxLv)
					{
						slData.star = 1;
					}else
					{
						slData.star = 0;
//						trace("curCId"+levelVo.chapter_id);
					}
				}else
				{
				
					slData.star = 0;
				}
				
				slData.fightNum = levelVo.challenge_times;
				scData.levelList.push(slData);
			}
			return scData;
		}
		
		//取得可攻打章节数
		public function passNum(jy:Boolean):Number
		{
			var chapDic:Object;
			var list:Array;
			if(!jy)
			{
				list = stageList1;
				chapDic = GameConfigManager.stage_chapter_dic;
				//trace("stageList1:"+JSON.stringify(stageList1));
				//trace("chapDic:",chapDic);
				//trace("list.length:"+list.length);
			}
			else
			{
				list = stageList2;
				chapDic = GameConfigManager.stage_chapter_jy_dic;
//				trace("stageList2:"+JSON.stringify(stageList2));
//				trace("list.length:"+list.length);
			}
			if(!list.length) return 1;
			
			for (var i:int = list.length - 1; i >= 0; i--) 
			{
				var scData:stageChapetrData = list[i];
				if(scData.isThrough)
				{
					var nextId:Number = scData.id + 1;
					if( chapDic[nextId] )
					{
						return nextId;
					}
				}else
				{
					trace("未通关的章节:"+ scData.id);
				}
			}
			return 1;
		}
		
		//取得符合条件的章节数
		//param jy 是否精英副本
		public function openNum(jy:Boolean):Number
		{
			if(!jy) return openPt();
			return openJy();
		}
		
		private function openPt():Number {
			if (autoSelectCID > 0)
			{
				return autoSelectCID;
			}
			var stageChapterArr:Array =  GameConfigManager.stage_chapter_arr;
			var i:int = 0;
			for (; i < stageChapterArr.length; i++) 
			{
				var vo:StageChapterVo = stageChapterArr[i];
				var conStr:String = "0="+vo.chapter_condition;
				if(ConditionsManger.cond(conStr))
				{
					return i;
				}
			}
			return stageChapterArr.length;
		}
		
		private function openJy():Number{
			var stageChapterArr:Array =  GameConfigManager.stage_chapter_jy_arr;
			var zxNum:Number = 0;
			
			if(stageList1.length)
			{
				for (var j:int = stageList1.length - 1; j >= 0; j--) 
				{
					var scData:stageChapetrData = stageList1[j];
					if(scData.isThrough)
					{
						zxNum = scData.id;
						break;
					}
				}
				
			}
			var i:int = 0;
			for (; i < stageChapterArr.length; i++) 
			{
				var vo:StageChapterVo = stageChapterArr[i];
				if(vo.chapter_condition > zxNum)
				{
					return i;
				}
			}
			return stageChapterArr.length;
		}
		
		public function getChapetrData(cid:Number , jy:Boolean):stageChapetrData
		{
			
			var list:Array = jy ? stageList2 : stageList1;
			var chapDic:Object = jy ? GameConfigManager.stage_chapter_jy_dic : GameConfigManager.stage_chapter_dic;
			if(list.length < cid)
			{
				var adN:Number = cid - list.length;
				for (var i:int = 0; i < adN; i++) 
				{
					list.push(null);
					var cVo:StageChapterVo = chapDic[list.length];
					list[list.length - 1] = newStageChapetrData(jy,list.length,cVo);
				}
			}
			
			var scData:stageChapetrData = list[cid - 1];
			
			var day:Number = new Date(TimeUtil.now).getDate();
			
			/*trace("章节信息:", scData.levelList);
			trace("cid:"+cid);*/
			if(!scData.isInit || scData.dayTimer != day)
			{
				var minNum:Number = Math.min(openNum(jy),passNum(jy));
				if(scData.id <= minNum )
				{
					WebSocketNetService.instance.sendData(ServiceConst.NEW_FIGHTING_MAP_CHAPETR,[jy ? 2 :1 , cid]);
					scData.isInit = true;
					scData.dayTimer = day;
				}
			}
			return scData;
		}
		
		public function getChapetrDataBack(... args):void
		{
			var jyN:Number = Number(args[1]);
			var cid:Number = Number(args[2]);
			var list:Array = jyN == 1 ? stageList1 : stageList2;
			var scData:stageChapetrData = list[cid - 1];
			if(scData)
			{
				
				var dObj:Object = args[3];
				
				scData.integral = Number(dObj.integral);
				scData.rewardState = dObj.prizeGetTimes;
				var levels:Object = dObj.levels;
				for (var i:int = 0; i < scData.levelList.length; i++) 
				{
					var cdata:stageLevelData = scData.levelList[i];
					if(levels.hasOwnProperty(cdata.id))
					{
						cdata.star = Number(levels[cdata.id].star);
						cdata.fightNum = Number(levels[cdata.id].fightTimes);
						cdata.buyTimes = Number(levels[cdata.id].buyTimes);
					}
				}
				
				Signal.intance.event(FIGHTINGMAP_CHAPETR_INIT,[jyN == 2 , cid]);
			}
		}
		
		private function levelChangeBack(... args):void
		{
			trace("星级更新");
			ifFirstCharge = false;
			var changeValue:Array = [false,false,false];  //章节领奖状态变化， 关卡星级变化 ，新通关
			
			var jyN:Number = Number(args[1]);
			var cid:Number = Number(args[2]);
			var jf:Number = Number(args[3]);
			var lid:Number = Number(args[4]);
			var lstar:Number = Number(args[5]);
			
			var list:Array = jyN == 1 ? stageList1 : stageList2;
			var scData:stageChapetrData = list[cid - 1];
			if(!scData)return ;
			
			if(scData.integral != jf)
			{
				scData.integral = jf;
				changeValue[0] = true;
			}
			
			
			var slData:stageLevelData;
			for (var i:int = 0; i < scData.levelList.length; i++) 
			{
				var slData2:stageLevelData = scData.levelList[i];
				if(slData2.id == lid){
					slData = slData2;
					var vipVo:VIPVo = VIPVo.getVipInfo();
					if(jyN == 1){
						slData.fightNum = (Math.round(slData.fightNum)+Math.round(vipVo.stage_wipe))
					}else{
						slData.fightNum = (Math.round(slData.fightNum)+Math.round(vipVo.elite_wipe))
					}
					break;
				}
			}
			if(slData)
			{
				if(slData.star != lstar)
				{
					if(slData.star==0)//代表第一次通关
					{
						trace("第一次通关:"+lid);
						if(lid==20)//通关4-1时候，提示首冲
						{
							ifFirstCharge = true;
						}
					}
					changeValue[1] = true;
					if(!slData.star)
					{
						changeValue[2] = true;
					}
					slData.star = lstar;
				}
			}
			
			if(changeValue[0]) Signal.intance.event(FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,[jyN == 2 , cid]);
			if(changeValue[1]) Signal.intance.event(FIGHTINGMAP_LEVEL_STAR_CHANGE,[jyN == 2 , lid]);
//			if(changeValue[2]) Signal.intance.event(FIGHTINGMAP_LEVEL_FNUM_CHANGE,[jyN == 2 , lid]);
			if(changeValue[2])
			{
				if(slData.type == 1) FightingChapetrView.newOpenStageLevelID = slData.id +1 ;
				else FightingJYChapetrView.newOpenStageLevelID = slData.id +1 ;
			}
		}
		
		private function rewardChangeBack(... args):void
		{
			var jyN:Number = Number(args[1]);
			var cid:Number = Number(args[2]);
			var list:Array = jyN == 1 ? stageList1 : stageList2;
			var scData:stageChapetrData = list[cid - 1];
			if(!scData)return ;
			scData.rewardState = args[3];
			Signal.intance.event(FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,[jyN == 2 , cid]);
		}
		
		private function buyNumChangeBack(... args):void
		{
			var jyN:Number = Number(args[1]);
			var lid:Number = Number(args[2]);
			var fNum:Number = Number(args[3]);
			var bNum:Number = Number(args[4]);
			if(jyN == 1)
				buyNum1 = bNum;
			else
				buyNum2 = bNum;
			setLevelBuyNum(lid,fNum,jyN == 2);
			Signal.intance.event(FIGHTINGMAP_LEVEL_FNUM_CHANGE,[jyN == 2 , lid]);
			
		}
		
		private function fightingNumChangeBack(... args):void
		{
			var jyN:Number = Number(args[1]);
			var lid:Number = Number(args[2]);
			var fNum:Number = Number(args[3]);
			setLevelBuyNum(lid,fNum ,jyN == 2);
			Signal.intance.event(FIGHTINGMAP_LEVEL_FNUM_CHANGE,[jyN == 2 , lid]);
		}
		
		private function setLevelBuyNum(lid:Number, fNum:Number,jy:Boolean):void
		{
			var list:Array = !jy ? stageList1 : stageList2;
			for (var i:int = 0; i < list.length; i++) 
			{
				var scData:stageChapetrData = list[i];
				var lAr:Array = scData.levelList;
				for (var j:int = 0; j < lAr.length; j++) 
				{
					var slData:stageLevelData = lAr[j];
					if(slData.id == lid)
					{
						return slData.fightNum = fNum;
					}
				}
				
			}
			
		}
		
		//判断某关卡是否可以被攻击
		public function levelIsF(lid:Number , jy:Boolean):Boolean
		{
			var lvdic:Object; //关卡LIST
//			var chapDic:Object; 
			var list:Array;
			var pass:Number = passNum(jy);
			if(!jy)
			{
				lvdic = GameConfigManager.stage_level_dic;
//				chapDic = GameConfigManager.stage_chapter_dic;
				list = stageList1;
			}else
			{
				lvdic = GameConfigManager.stage_level_jy_dic;
//				chapDic = GameConfigManager.stage_chapter_jy_dic;
				list = stageList2;
			}
			
			var cvo:StageLevelVo = lvdic[lid];
			
			if(pass < cvo.chapter_id) return false;  //大于可攻击章节 直接否
			if(pass > cvo.chapter_id) return true;  //小于可攻击章节 直接是
			
			var scData:stageChapetrData = list[cvo.chapter_id - 1];
			if(!scData)return false;
			var lAr:Array = scData.levelList;
			for (var j:int = 0; j < lAr.length; j++) 
			{
				var slData:stageLevelData = lAr[j];
				if(slData.star && (slData.id == cvo.id || slData.id == cvo.id - 1))
					return true;
			}
			
			return false;
		}
		
	}
}