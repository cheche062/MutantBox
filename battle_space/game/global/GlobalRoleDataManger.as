package game.global
{
	import game.common.AndroidPlatform;
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.reVo;
	import game.module.armyGroup.ArmyGroupChatItem;
	import game.module.chests.ChestsMainView;
	import game.module.fighting.mgr.FightingManager;
	import game.module.guild.GuildChatItem;
	import game.module.login.PreLoadingView;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.net.HttpRequest;
	import laya.net.Loader;
	import laya.ui.ProgressBar;
	import laya.utils.Browser;
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	import laya.utils.Timer;

	public class GlobalRoleDataManger
	{
		/**获取主角信息*/
		public var user:User;
		private static var _instance:GlobalRoleDataManger;
		private var _chatDate:Date;

		private var _chatItemVec:Vector.<GuildChatItem>=new Vector.<GuildChatItem>();
		private var _chatCount:int=0;
		private var _ispay:Boolean;

		// copy 军团聊天消息中的公会消息
		// 聊天时间
		private var _armyChatDate:Date=new Date();
		// 是否是自己发的消息
		private var _isSelfChat:Boolean=false;
		// 聊天消息容器
		private var _armyChatVo:Vector.<ArmyGroupChatItem>=new Vector.<ArmyGroupChatItem>();
		// 聊天消息数量
		private var _armyChatCount:int=0;

		// 军团聊天消息中的世界消息
		private var _worldChatVo:Vector.<ArmyGroupChatItem>=new Vector.<ArmyGroupChatItem>();
		private var _worldChatCount:int=0;

		// 军团聊天消息中的城市消息
		private var _cityChatVo:Vector.<ArmyGroupChatItem>=new Vector.<ArmyGroupChatItem>();
		private var _cityChatCount:int=0;

		public var SSONeedAlert:Boolean = true;
		
		public var baseTime:int = 0;
		public var addTime:int = 0;
		public var msgTime:int = 99999;
		
		public var boardcastVec:Array = [];
		public var isBoarding:Boolean = false;
		
		/**
		 * 分享状态
		 */
		public var ShareState:Boolean = true;

		public static function get instance():GlobalRoleDataManger
		{
			if (_instance)
				return _instance;
			_instance=new GlobalRoleDataManger;

			return _instance;
		}

		private function onError(... args):void
		{
			if (GameSetting.isLogin == false)
			{
				if (GameSetting.isApp)
				{
					(XFacade.instance.getView(PreLoadingView) as PreLoadingView).openSwitchLoginView();
				}
			}
			XTip.showTip(GameLanguage.getLangByKey(args[2]));
		}

		////========================数据处理部分
		private var loginHandler:Handler;

		public function userLogin(dataAr:Array, caller:*, backFun:Function):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.LOGIN_CONST, dataAr);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LOGIN_CONST), this, loginWin);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PAY_SUCCESS), this, onResult);
			loginHandler=Handler.create(caller, backFun);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WATER), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			msgTime = baseTime+parseInt(Math.random() * 10) % addTime;
		}


		public var userid:*;
		public var getWaterNum:int=0;

		private function onResult(cmd:int, ... args):void
		{
			// TODO Auto Generated method stub
			switch (cmd)
			{
				case ServiceConst.GET_WATER:
					//trace("ServiceConst.GET_WATER");
					if (GlobalRoleDataManger.instance.user.water != parseInt(args[0]))
					{
						var getWaternum = (parseInt(args[0]) - GlobalRoleDataManger.instance.user.water);
						if( getWaternum > 0){
							HomeScene(ModuleManager.intance.getModule(HomeScene)).showHarvestNum([1,getWaternum]);
						}
						GlobalRoleDataManger.instance.user.water=parseInt(args[0]);
						MainView(XFacade.instance.getView(MainView)).UpdateWater();
						_ispay=false;
						getWaterNum=0;
					}
					else if (_ispay == true && getWaterNum == 1)
					{
						var timer:Timer=new Timer();
						timer.once(60000, this, getWatch);
						_ispay=false;
						getWaterNum=0;
					}
					else
					{
						var timer:Timer=new Timer();
						timer.once(10000, this, getWatch);
						getWaterNum++;
					}

					break;
				case ServiceConst.PAY_SUCCESS:
				{
					trace("ServiceConst.PAY_SUCCESS",args);
					WebItemPayHandler(args);
					break;
				}
			}
		}

		public function loginWin(... args):void
		{
			trace("loginWin", args);
			if (!this.user)
			{
				this.user=User.getInstance();
			}
			this.user.updateVo(args[1]);
			TimeUtil.syncSrvTime(args[1].server_time);
			//
			trace("setLan------>")
			trace(args[1].lang)
			GameSetting.lang=(args[1].lang || "en-us")
			Signal.intance.off(ServiceConst.getServerEventKey(args[0]), this, loginWin);
			userid=args[1].uid;

			if (args[1].guild_id && args[1].guild_id != "0")
			{
				this.user.guildID=args[1].guild_id;
			}

			if (args[1].step)
			{
				this.user.guideStep=args[1].step;
			}

			if (args[1].mine_point)
			{
				this.user.minePoint=args[1].mine_point
			}
			
			if (args[1].energy)
			{
				this.user.purpleCrystal=args[1].energy
			}

			if (args[1].is_new_user)
			{
				this.user.is_new_user=args[1].is_new_user;
				if (this.user.is_new_user == true)
				{
					//trace("create_role");
					AndroidPlatform.instance.FGM_CustumEvent("00_create_role");
				}
			}
			
			this.user.inviteCode = args[1].invite_key;
			this.user.VIP_LV=args[1].vip_info.vip_level;
			this.user.chargeNum = args[1].vip_info.amount;
			
			if (loginHandler)
				loginHandler.run();
				
			loginHandler.clear();
			loginHandler = null;
			
			//trace("this.user.guideStep:",this.user.guideStep);
			//移到登录界面处理
			/**
			if (this.user.guideStep < 999)
			{
				if (this.user.guideStep == 0)
				{
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SIMULATION);
				}
				this.user.hasFinishGuide = false;
				XFacade.instance.openModule(ModuleName.NewerGuideView);
			}
			 */
			
			//trace("时候是ipx：", GameSetting.isIPhoneX);
//			Laya.timer.once(500, this, function() {
//							XFacade.instance.openModule(ModuleName.FunctionGuideView, 1200);
//							} );
							
			//XFacade.instance.openModule(ModuleName.DailySignInView);
			//XFacade.instance.openModule(ModuleName.HQUpgradeView,28);
			//this.user.hasFinishGuide = false;
			//XFacade.instance.openModule(ModuleName.NewerGuideView);
			//FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SIMULATION);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			_chatDate=new Date();
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, getGuildChatInfoHandler, [ServiceConst.GET_GUILD_TALK]);
			// 获取世界聊天消息
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_WORLD_MSG), this, getMsgHandler, [ServiceConst.ARMY_GROUP_GET_WORLD_MSG]);
			// 获取城市聊天消息
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_CITY_MSG), this, getMsgHandler, [ServiceConst.ARMY_GROUP_GET_CITY_MSG]);
			// 获取分享数据
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_SHARE_INFO), this, getMsgHandler, [ServiceConst.GET_SHARE_INFO]);
			// 获取周卡信息
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_WEEK_CARD), this, getMsgHandler, [ServiceConst.OPEN_WEEK_CARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LVFUNDATION_INIT), this, getMsgHandler, [ServiceConst.LVFUNDATION_INIT]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_BOARD), this, getBoardMsgHandler, [ServiceConst.GET_BOARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOARD_PUSH), this, getBoardMsgHandler, [ServiceConst.BOARD_PUSH]);

			if(this.user.guideStep>=999)
			{
				WebSocketNetService.instance.sendData(ServiceConst.GAME_BOARD_GET_LIST);
			}
			
			WebSocketNetService.instance.sendData(ServiceConst.GET_SHARE_INFO);
			WebSocketNetService.instance.sendData(ServiceConst.OPEN_WEEK_CARD);
			WebSocketNetService.instance.sendData(ServiceConst.LVFUNDATION_INIT);
			
			Laya.timer.loop(1000, this, timeCount);
			
		}
		
		public function timeCount():void
		{
			msgTime--;
			if (msgTime <= 0)
			{
				msgTime = baseTime+parseInt(Math.random() * 10) % addTime;
				WebSocketNetService.instance.sendData(ServiceConst.GET_BOARD);
			}
		}

		/**
		 * 过滤敏感词汇
		 *
		 */
		private function filterWordsHandler(getStr:String):String
		{
			// 敏感词汇
			var forbiddenArray:Array=GameConfigManager.ArmyGroupFilterWords;
			var showStr:String=getStr;
			for (var i=0; i < forbiddenArray.length; i++)
			{
				showStr=showStr.replace(new RegExp(forbiddenArray[i], "g"), "**");
			}
			return showStr;
		}
		
		private function getBoardMsgHandler(cmd:int, ...args):void
		{
			var boardData:Object;
			switch(cmd)
			{
				case ServiceConst.GET_BOARD:
					var bannerList:Object = args[1]["banner"];
					for (var info in bannerList)
					{
						
						boardData = { };
						boardData.type = bannerList[info][0];
						boardData.uid = bannerList[info][1];
						boardData.username = bannerList[info][2];
						boardData.sysMsg = bannerList[info][4];
						boardcastVec.push(boardData);
					}
					break;
				case ServiceConst.BOARD_PUSH:
					var sInfo:Array = args[1];
					boardData = { };
					boardData.type = sInfo[0];
					boardData.uid = sInfo[1];
					boardData.username = sInfo[2];
					boardData.sysMsg = sInfo[4];
					boardcastVec.push(boardData);
					break;
				default:
					break;
			}
			
			goMsg();
		}
		
		/**开始轮播跑马灯*/
		public function goMsg():void {
			if (!isBoarding && boardcastVec.length > 0)
			{
				isBoarding = true;
				XFacade.instance.openModule(ModuleName.BoardCasterView);
			}
		}
		
		/**添加国战战斗信息*/
		public function addLegionwarMsg(msg):void {
			var text:String;
			switch (Number(msg.msg_type)) {
				case 1:
					//我方已对XX星球宣战
					text = "L_A_2752";
					break;
				
				case 2:
					//我方XX星球,遭受攻击
					text = "L_A_2753";
					break;
				
				case 3:
					//我方正在攻打XX星球，我们需要你
					text = "L_A_2754";
					break;
				
				case 4:
					//XX星球遭到攻击，我们需要你
					text = "L_A_2755";
					break;
			}
			text = GameLanguage.getLangByKey(text).replace("{0}", msg.city_name);
			var boardData = createMsg(2, msg.uid, msg.att_player_name, text);
			boardcastVec.push(boardData);
			
			goMsg();
		}
		
		private function createMsg(type, uid, username, sysMsg):Object {
			return {
				type: type,
				uid: uid,
				username: username,
				sysMsg: sysMsg
			}
		}
		
		/**
		 * 获取世界聊天消息
		 * @param cmd 服务器指令
		 * @param args 服务器返回消息
		 *
		 */
		private function getMsgHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_WORLD_MSG:
					// trace("世界消息：", args);
					// 如果是世界消息
					armyWorldChatHandler(args[1]);
					break;
				case ServiceConst.ARMY_GROUP_GET_CITY_MSG:
					// trace("城市消息：", args);
					// 如果是城市消息
					armyCityChatHandler(args[1]);
					break;
				case ServiceConst.GET_SHARE_INFO:
					//trace("分享信息：", args);
					break;
				case ServiceConst.OPEN_WEEK_CARD:
					//是否购买过
					var isBuyed = args[1].card_last_time["7"];
					// 是否有周卡
					var result:Boolean = false;
					
					//购买过
					if(isBuyed){
						// 未过期
						if(parseInt(isBuyed) - parseInt(TimeUtil.now / 1000) > 0){
							result = true;
						}else{
							result = false;
						}
					}else{
						result = false;
					}
					
					user.hasWeekCard = result;
					user.event();
					break;
				case ServiceConst.LVFUNDATION_INIT:
					user.hasBuyFun = false;
					if (parseInt(args[1].fund_pay) > 0)
					{
						user.hasBuyFun = true;
					}
					user.event();
					break;
				default:
					break;

			}
		}

		/**
		 * 处理军团聊天中的城市消息
		 * @param message 消息体
		 *
		 */
		private function armyCityChatHandler(message:Object):void
		{
			var chatItem:ArmyGroupChatItem=new ArmyGroupChatItem();
			var chatParm:Object={type: "", time: "", group: "", name: "", word: ""};

			if (User.getInstance().uid == parseInt(message.uid))
			{
				chatParm.type="self";
				isSelfChat=true;
			}
			else
			{
				chatParm.type="other";
				isSelfChat=false;
			}

			// 时间
			chatParm.time=message.time;
			// 名字
			chatParm.name=message.name;
			// 消息
			chatParm.word=filterWordsHandler(message.word);
			// 公会
			chatParm.group=message.guildName;
			// 设置消息的数据源，传给数据项渲染UI
			chatItem.dataSource=chatParm;
			// 设置消息的纵向位置
			if (cityChatCount > 0)
				chatItem.y=cityChatVo[cityChatCount - 1].y + cityChatVo[cityChatCount - 1].height + 10;
			else
				chatItem.y=0;
			// 消息进栈
			cityChatVo.push(chatItem);
			Signal.intance.event(ArmyGroupEvent.SPREAD_CITY_TALK, isSelfChat);
		}

		/**
		 * 处理军团聊天中的世界消息
		 * @param message 消息体
		 *
		 */
		private function armyWorldChatHandler(message:Object):void
		{
			var chatItem:ArmyGroupChatItem=new ArmyGroupChatItem();
			var chatParm:Object={type: "", time: "", group: "", name: "", word: ""};

			if (User.getInstance().uid == parseInt(message.uid))
			{
				chatParm.type="self";
				isSelfChat=true;
			}
			else
			{
				chatParm.type="other";
				isSelfChat=false;
			}

			// 时间
			chatParm.time=message.time;
			// 名字
			chatParm.name=message.name;
			// 消息
			chatParm.word=filterWordsHandler(message.word);
			// 公会
			chatParm.group=message.guildName;
			// 设置消息的数据源，传给数据项渲染UI
			chatItem.dataSource=chatParm;
			// 设置消息的纵向位置
			if (worldChatCount > 0)
				chatItem.y=worldChatVo[worldChatCount - 1].y + worldChatVo[worldChatCount - 1].height + 10;
			else
				chatItem.y=0;
			// 消息进栈
			worldChatVo.push(chatItem);
			Signal.intance.event(ArmyGroupEvent.SPREAD_WORLD_TALK, isSelfChat);
		}

		/**获取服务器消息*/
		private function getGuildChatInfoHandler(cmd:int, ... args):void
		{
			//trace("talkService: ",args);
			// TODO Auto Generated method stub
			var len:int=0;
			var i:int=0;
			switch (cmd)
			{
				case ServiceConst.GET_GUILD_TALK:
					var chatItem:GuildChatItem=new GuildChatItem();
					var chatData:Object={type: "", time: "", name: "", word: ""};

					if (args[1] == "dh")
					{
						chatData.type="dh";
					}
					else if (args[1] == "tm")
					{
						chatData.type="tm";
					}
					else if (args[1] != "gs")
					{

						if (User.getInstance().uid == parseFloat(args[2]))
						{
							chatData.type="self";
							isSelfChat=true;
						}
						else
						{
							chatData.type="other";
							isSelfChat=false;
						}
					}
					else
					{

						chatData.type="sys";
					}
					trace("args[5]:", args[5]);
					_chatDate.setTime(parseInt(args[5]) * 1000);

					//chatData.time=(_chatDate.getHours() < 10 ? "0" + _chatDate.getHours() : _chatDate.getHours()) + ":" + (_chatDate.getMinutes() < 10 ? "0" + _chatDate.getMinutes() : _chatDate.getMinutes())
					chatData.time=args[5];
					chatData.name=args[3];
					chatData.word="\n" + GameLanguage.getLangByKey(args[4]);
					chatData.params=args[6];

					chatItem.dataSource=chatData;
					if (_chatCount > 0)
					{
						chatItem.y=_chatItemVec[_chatCount - 1].y + _chatItemVec[_chatCount - 1].height + 10;
					}
					else
					{
						chatItem.y=0;
					}
					_chatItemVec.push(chatItem);

					// 处理军团中公会消息
					armyGuildChatHandler(args);

					User.getInstance().hasNewChat=true;
					Signal.intance.event(GuildEvent.SPREAD_GUILD_TALK, isSelfChat);
					break;
				default:
					break;
			}
		}

		/**
		 * 处理军团中公会消息
		 * @param args 服务器返回参数
		 *
		 */
		private function armyGuildChatHandler(args:Array):void
		{
			var chatItem:ArmyGroupChatItem=new ArmyGroupChatItem();
			var chatParm:Object={type: "", time: "", group: "", name: "", word: ""};

			if (args[1] != "dh" && args[1] != "tm" && args[1] != "gs")
			{
				if (User.getInstance().uid == parseFloat(args[2]))
				{
					chatParm.type="self";
					isSelfChat=true;
				}
				else
				{
					chatParm.type="other";
					isSelfChat=false;
				}
			}
			else
				chatParm.type="error";

			// 时间
			// armyChatDate.setTime(parseInt(args[5]) * 1000);
			chatParm.time=args[5];
			// 名字
			chatParm.name=args[3];
			// 消息
			chatParm.word=filterWordsHandler(args[4]);
			// 设置消息的数据源，传给数据项渲染UI
			chatItem.dataSource=chatParm;
			// 设置消息的纵向位置
			if (armyChatCount > 0)
				chatItem.y=armyChatVo[armyChatCount - 1].y + armyChatVo[armyChatCount - 1].height + 10;
			else
				chatItem.y=0;
			// 消息进栈
			armyChatVo.push(chatItem);
		}

		public function ItemPayHandler(p_data:reVo)
		{
//			_ispay=true;
//			var timer:Timer=new Timer();
//			timer.once(1000,this,getWatch);
			p_data.serverId=GameSetting.ServerId;
			AndroidPlatform.instance.FGM_Purchase(p_data, Handler.create(this, this.onPayHandler));

		}

		public function WebItemPayHandler(args:* = null)
		{
			_ispay=true;
			getWaterNum=0;
			var timer:Timer=new Timer();
			timer.once(2500, this, getWatch);
			if(GameSetting.Platform == GameSetting.P_GW){
				if(args && args[1]){
					var val:* = args[1];
					__JS__("sendGoogleAd(val)");
				}
				/*var url:String = __JS__("sendGoogleAd(val)");
				
				var xhr:HttpRequest = new HttpRequest();
				xhr.http.timeout = 10000;//设置超时时间；
				xhr.send(url,"","get","text");
				trace("发送google统计",url)*/
			}
		}
		
		public function shareGame(data:Object):void
		{
			
			/*if (!ShareState)
			{
				return;
			}*/
			var pic:String = "https://image.movemama.com/bs/qa/"+ResourceManager.instance.setResURL('shareImg/' + data.pic_id + '.jpg')
			var url:String = 'https://apps.facebook.com/battlespacestrategic/'
			if (GameSetting.isApp) {
				AndroidPlatform.instance.FGM_FacebookShare(GameLanguage.getLangByKey(data.title),GameLanguage.getLangByKey(data.content),pic,url)
			}
			else
			{
				//title,description, img, url
				//__JS__("share('mt','des','http://www.mutantbox.com','mutantbox.com')");
				trace("请求书数据:", data);
				//var str:String = 'fbShare("' + GameLanguage.getLangByKey(data.title) + '","' + GameLanguage.getLangByKey(data.content) + '","' + ResourceManager.instance.setResURL("appRes/shareImg/" + data.pic_id + ".jpg") + '","mutantbox.com")';
				__JS__("fbShare( GameLanguage.getLangByKey(data.title), GameLanguage.getLangByKey(data.content) ,pic,url)");
				//trace("拼合数据:", str);
				//__JS__(str);
			}
		}

		private function onPayHandler(p_str:String):void
		{
			// TODO Auto Generated method stub
			var _obj:Object=JSON.parse(p_str);
			trace("回调登录数据:" + p_str);
			var l_suc:Boolean=_obj["isSuc"];
			if (l_suc == true || Browser.onIOS)
			{
				_ispay=true;
				getWaterNum=0;
				var timer:Timer=new Timer();
				timer.once(1000, this, getWatch);
				if (Browser.onIOS)
				{
					if (_obj["errCode"] == 9)
					{
						XTip.showTip("L_A_52015");
					}
					else if (_obj["errCode"] == 10)
					{
						XTip.showTip("L_A_52016");
					}
				}
			}
			else
			{
				XTip.showTip("L_A_52015");
			}
		}

		private function getWatch():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.GET_WATER, []);
		}

		public function get chatItemVec():Vector.<GuildChatItem>
		{
			return _chatItemVec;
		}

		public function get chatCount():int
		{
			return _chatCount;
		}

		public function set chatCount(value:int):void
		{
			_chatCount=value;
		}

		/**
		 * 获取军团中城市消息容器
		 * @return 返回军团中城市消息容器
		 *
		 */
		public function get cityChatVo():Vector.<ArmyGroupChatItem>
		{
			return _cityChatVo;
		}

		/**
		 * 军团中城市消息数量
		 * @return 返回军团中城市消息数量
		 *
		 */
		public function get cityChatCount():int
		{
			return _cityChatCount;
		}

		/**
		 * 军团中城市消息数量
		 * @param value 数量
		 *
		 */
		public function set cityChatCount(value:int):void
		{
			_cityChatCount=value;
		}

		/**
		 * 获取军团中世界消息容器
		 * @return 返回军团中世界消息容器
		 *
		 */
		public function get worldChatVo():Vector.<ArmyGroupChatItem>
		{
			return _worldChatVo;
		}

		/**
		 * 军团中世界消息数量
		 * @return 返回军团中世界消息数量
		 *
		 */
		public function get worldChatCount():int
		{
			return _worldChatCount;
		}

		/**
		 * 军团中世界消息数量
		 * @param value 数量
		 *
		 */
		public function set worldChatCount(value:int):void
		{
			_worldChatCount=value;
		}

		/**
		 * 获取军团中公会消息容器
		 * @return 返回军团中公会消息容器
		 *
		 */
		public function get armyChatVo():Vector.<ArmyGroupChatItem>
		{
			return _armyChatVo;
		}

		/**
		 * 军团中公会消息数量
		 * @return 返回军团中公会消息数量
		 *
		 */
		public function get armyChatCount():int
		{
			return _armyChatCount;
		}

		/**
		 * 军团中消息的时间
		 * @return
		 *
		 */
		public function get armyChatDate():Date
		{
			return _armyChatDate;
		}

		/**
		 * 军团中公会消息数量
		 * @param value 数量
		 *
		 */
		public function set armyChatCount(value:int):void
		{
			_armyChatCount=value;
		}

		/**
		 * 公会消息中是否是自己发的消息
		 * @return
		 *
		 */
		private function get isSelfChat():Boolean
		{
			return _isSelfChat;
		}

		/**
		 * 公会消息中是否是自己发的消息
		 * @return
		 *
		 */
		private function set isSelfChat(value:Boolean):void
		{
			_isSelfChat=value;
		}


	}
}
