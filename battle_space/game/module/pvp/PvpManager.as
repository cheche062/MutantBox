package game.module.pvp
{
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.PvpLevelVo;
	import game.global.vo.PvpMathCostVo;
	import game.global.vo.PvpRewardVo;
	import game.global.vo.User;
	import game.global.vo.pvpShopItemVo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Browser;
	import laya.utils.Handler;

	public class PvpManager
	{
		/**是否机器人*/
		public static var isRobot:int;
		/**当前时间*/
		public static var curTime:int = 0;
		private static var _instance:PvpManager;
		public static const SETQUICKMSG_EVENT:String = "SETQUICKMSG_EVENT";
		public static const ENEMYINFO_EVENT:String = "ENEMYINFO_EVENT";   
		
		public static const CANCELPIPEI_EVENT:String = "CANCELPIPEI_EVENT";  //匹配状态改变
		
		
		
		public static const MAININFOCHANGE_EVENT:String = "MAININFOCHANGE_EVENT";
		public static const PVP_TOKENNUMBER_CHANGE_EVENT:String = "PVP_TOKENNUMBER_CHANGE_EVENT";
		public static const REWARDCHANGE_EVENT:String = "REWARDCHANGE_EVENT";
		
		
		public function PvpManager()
		{
			if(_instance){				
				throw new Error("PvpManager是单例,不可new.");
			}
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_MSG_BACK),
				this,setMsgFun);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_READY),
				this,enemyReadyfun);
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.ERROR),
				this,errorFun);
			
			_instance = this;
		}
		

		public function get userInfo():Object
		{
			if(!_userInfo) _userInfo = {};
			return _userInfo;
		}

		public function set userInfo(value:Object):void
		{
			
			_userInfo = value;
		}

		public function get getedRewards():Array
		{
			if(!_getedRewards) _getedRewards = [];
			return _getedRewards;
		}

		public function set getedRewards(value:Array):void
		{
			_getedRewards = value;
		}

		public static function get intance():PvpManager
		{
			if(_instance)
				return _instance;
			_instance = new PvpManager;
			
			return _instance;
		}
		
		private var _pipeiHander:Handler ;
		private var _pipeiCSHander:Handler;
		/**
		 *开始匹配 
		 */
		public function pipei(hander:Handler,pipeiCSHander:Handler):void{
			_pipeiHander = hander;
			_pipeiCSHander = pipeiCSHander;
			WebSocketNetService.instance.sendData(ServiceConst.PVP_PIPEI,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_PIPEI),
				this,getPiPeiBack);
			var csTm:Number = 20;
			var _json:* = ResourceManager.instance.getResByURL("config/pvp_param.json");
			if(_json)
			{
				var arr:Array = (_json[3].value+"").split("|");
				if(!arr[1]){
					arr = [5,10];
				}
				csTm = Math.floor(Math.random()*(arr[1]-arr[0])+Math.floor(arr[0]))
				//csTm = Number(_json[3].value);
			}
//			csTm = 10;
			Laya.timer.once(csTm * 1000,this,chaoshi);
		}
		
		public function enemyReadyfun(... args):void
		{
			enemyReady = true;
			Signal.intance.event(ENEMYINFO_EVENT);
		}
		
		public function errorFun(... args):void
		{
			var errConst:uint = args[1];
			if(errConst == ServiceConst.PVP_PIPEI)
			{
				if(_pipeiHander)
					_pipeiHander.runWith([0]);
				_pipeiCSHander = null;
			}
			
		}
		
		
		
		public function setMsgFun(... args):void
		{
			var msgId:Number = Number(args[1]);
			Signal.intance.event(SETQUICKMSG_EVENT,[msgId,false]);
		}
		
		public function getPiPeiBack(... args):void
		{
			trace("getPiPeiBack::",args)
			
			isRobot = args[3];
			
			Signal.intance.off(ServiceConst.getServerEventKey(args[0]), this,getPiPeiBack);
			Laya.timer.clear(this,chaoshi);
			var copyAr:Array = [];
			for (var i:int = 1; i < args.length; i++) 
			{
				copyAr.push(args[i]);
			}
		
			enemyInfo = copyAr[1];
			enemyReady = false;
			if(_pipeiHander)
				_pipeiHander.runWith(copyAr);
			_pipeiCSHander = null;
		}
		
		public var enemyInfo:Object;
//		public var enemyInfo:Object = {
//			uid:"11111",
//			name:"路人甲",
//			topUnit:2000,
//			heros:[2000,2001],
//			userLevel:10,
//			integral:1000
//		};
		public var enemyReady:Boolean;
		
		/**
		 *开始匹配 
		 */
		public function userStart():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_USERSTARTE,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_USERSTARTE),
				this,userStartBack);
			
		}
		
		
		private function chaoshi():void{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_TIMER_OUT,[]);
			if(_pipeiCSHander)
				_pipeiCSHander.run();
		}
		
		private var buzhenAr:Array = [];
		public function userStartBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,userStartBack);
			
			
			buzhenAr.splice(0,buzhenAr.length);
			for (var i:int = 0; i < args.length; i++) 
			{
				buzhenAr.push(args[i]);
			}
			loadFightRec();
		}
		
		/**
		 *预加载资源 
		 */
		public function loadFightRec():void
		{
			ResourceManager.instance.load("PvPFightingScene",Handler.create(this,_onLoaded));
		}
		
		private function _onLoaded(_e:*=null):void{
			serverStart();
		}
		
		
		/**
		 *开始布阵
		 */
		public function serverStart():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_LOADOVER,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_LOADOVER),
				this,serverStartBack);
		}
		
		public function serverStartBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,serverStartBack);
			FightingManager.intance.setPvpSquad(FightingManager.FIGHTINGTYPE_PVP,buzhenAr,Handler.create(this,fightBack));
		}
		
		private function fightBack():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			var obj:Object = { };
			obj.fun = function() {
				XFacade.instance.openModule(ModuleName.PvpMainPanel);
			};
			Laya.timer.once(500, obj, obj.fun );
		}
		
		private var sendMsgTimer:Number = 0;
		public function sendMsg(msgId:Number):void
		{
			if(Browser.now() - sendMsgTimer > 5000)
			{
				WebSocketNetService.instance.sendData(ServiceConst.PVP_MSG_SEND,[msgId]);
				sendMsgTimer = Browser.now();
				
				Signal.intance.event(SETQUICKMSG_EVENT,[msgId,true]);
				return ;
			}
			
			XTip.showTip("L_A_931006");
		}
		
		
		public function getMainInfoData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_MAININFO,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_MAININFO),
				this,getMainInfoDataBack);
		}
		
		public var todayUnits:Array = [];
		private var _userInfo:Object;
		private var _tokenNumber:Number = 0;
		public var shopCount:Object;
		private var _getedRewards:Array;
		
		public function get tokenNumber():Number
		{
			return _tokenNumber;
		}
		
		public function set tokenNumber(value:Number):void
		{
			if(_tokenNumber != value)
			{
				User.getInstance().token = _tokenNumber = value;
				Signal.intance.event(PVP_TOKENNUMBER_CHANGE_EVENT);	
			}
		}
		
		public function getMainInfoDataBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,serverStartBack);
			todayUnits = args[1].todayUnits;
			userInfo = args[1].userInfo;
			tokenNumber = Number(userInfo.tokenNumber);
			shopCount = userInfo.shopCount;
			getedRewards = userInfo.getedRewards;
			refreshRewardNum();
			Signal.intance.event(MAININFOCHANGE_EVENT);	
		}
		
		public var refrechGetNum:Number = 0;
		private function refreshRewardNum():void
		{
			refrechGetNum = 0;
			var ar:Array = GameConfigManager.pvpRewardVos;
			for (var i:int = 0; i < ar.length; i++) 
			{
				var vo:PvpRewardVo = ar[i];
				if(vo.state == 1)
					refrechGetNum ++;
			}
			
			Signal.intance.event(REWARDCHANGE_EVENT);	
		}
		
		public function getReward(num:Number):void
		{
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_GETREWARD),
				this,getRewardBack);
			WebSocketNetService.instance.sendData(ServiceConst.PVP_GETREWARD,[num]);
			
			
		}
		
		
		public function getRewardBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getRewardBack);
			var num:Number = args[1];
			this.tokenNumber = Number(args[2]);
			getedRewards.push(num);
			refreshRewardNum();
			
			var vo:PvpRewardVo;
			for (var i:int = 0; i < GameConfigManager.pvpRewardVos.length; i++) 
			{
				var vo2:PvpRewardVo = GameConfigManager.pvpRewardVos[i];
				if(vo2.num == num) 
				{
					vo = vo2;
					break;
				}
			}
			
			if(vo)
			{
				XFacade.instance.openModule(ModuleName.ShowRewardPanel,[vo.showReward]);
			}
			
		}
		
		
		public function getShopCountBySid(sId:Number):void
		{
			if(!shopCount || !shopCount.hasOwnProperty(sId)) return 0;
			return Number(shopCount[sId]);
		}
		
		
		public function cancelPipei():void
		{
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_CANCEL),
				this,cancelPipeiBack);
			WebSocketNetService.instance.sendData(ServiceConst.PVP_CANCEL,[]);
			
			Laya.timer.clear(this,chaoshi);
			
		}
		
		
		public function cancelPipeiBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,cancelPipeiBack);
			Signal.intance.event(CANCELPIPEI_EVENT);	
		}
		
		public function shopBuy(sId:Number):void
		{
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.PVP_SHOP_BUY),
				this,shopBuyBack);
			WebSocketNetService.instance.sendData(ServiceConst.PVP_SHOP_BUY,[sId]);
		}
		
		public function shopBuyBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,shopBuyBack);
			
//			XTip.showTip("L_A_68");
			
			var obj:Object = args[1];
			var sid:* = obj.goodsId;
			var vo:pvpShopItemVo = getPvpShopItemById(sid);
			if(vo)
			{
//				XFacade.instance.openModule(ModuleName.ShowRewardPanel,[vo.showItems]);
				XItemTip.showTip(vo.item);
			}
			
			
			if(!shopCount) shopCount = {};
			
			if(shopCount.hasOwnProperty(sid))
			{
				 shopCount[sid] = Number(shopCount[sid]) + 1;
			}else
			{
				shopCount[sid] = 1;
			}
			
			this.tokenNumber = Number(obj.tokenNumber);
			
		}
		
		
		//辅助方法
		/**
		 *根据积分获取段位等级对象
		 */
		public function getPvpLevelByIntegral(integral:Number):Number{
			var levelVo:Array = GameConfigManager.pvpLevelVoList;
			if(!levelVo || !levelVo.length)return null;
			if(!integral) return levelVo[0];
			for (var i:int = 0; i < levelVo.length; i++) 
			{
				var vo:PvpLevelVo = levelVo[i];
				if(vo.coincide(integral))
				{
					return vo;
				}
			}
			return levelVo[0];
		}
		
		public function getPvpLevelVoByLevel(level:Number):PvpLevelVo{
			var levelVo:Array = GameConfigManager.pvpLevelVoList;
			if(!levelVo)return null;
			for (var i:int = 0; i < levelVo.length; i++) 
			{
				var vo:PvpLevelVo = levelVo[i];
				if(vo.id == level)
				{
					return vo;
				}
			}
			return null;
		}
		
		public function getPvpMathCostVo(level:Number,matchTimes:Number):PvpMathCostVo
		{
			var vos:Array = GameConfigManager.pvpMathCostVoList;
			if(!vos || !vos.length)return null;
			for (var i:int = 0; i < vos.length; i++) 
			{
				var vo:PvpMathCostVo = vos[i];
				if(vo.coincide(level,matchTimes))
				{
					return vo;
				}
			}
			return null;
		}
		
		public function getPvpShopItemById(sId:Number):pvpShopItemVo{
			var vos:Array = GameConfigManager.pvpShopItemVos;
			if(!vos || !vos.length)return null;
			for (var i:int = 0; i < vos.length; i++) 
			{
				var vo:pvpShopItemVo = vos[i];
				if(vo.id == sId)
				{
					return vo;
				}
			}
			return null;
		}
		
		
		
		
	}
}