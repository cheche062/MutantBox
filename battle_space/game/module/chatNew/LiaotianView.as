package game.module.chatNew
{
	import MornUI.chatNew.LiaotianViewUI;
	
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.alert.XAlert;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.VScrollBar;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 新的聊天  包含（公会聊天， 世界聊天，世界boss内地图聊天， 好友管理）
	 * @author hejianbo
	 * 
	 */
	public class LiaotianView extends BaseView
	{
		/**状态树*/
		public static var state:DataVo;
		/**页签的内容*/
		private var tabs_content_list:Array;
		
		/**初始x坐标*/
		private var INIT_X;
		
		/**是否显示中*/
		private var isShow:Boolean = false;
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		/**世界聊天*/
		public static const WORLD_CHAT = "WORLD";
		/**boss地图聊天*/
		public static const BOSSMAP_CHAT = "BOSSMAP";
		/**公会聊天*/
		public static const GUILD_CHAT = "GUILD";
		/**好友聊天*/
		public static const FRIEND_CHAT = "FRIEND";
		/**聊天冷却时间*/
		private const COOLING_TIME = 2;
		/**有新消息的好友uid*/
		private var friendsNewChatUidList:Array = [];
		/**当前发送的信息*/
		private var current_msg:String;
		/**隐藏后的回调*/
		private var callBack:Function;
		/**注册的当前模块*/
		public static var current_module_view:*;
		
		
		public function LiaotianView() {
			super();
			m_iLayerType=LayerManager.M_POP;
			m_iPositionType=LayerManager.LEFT;
		}
		
		override public function createUI():void {
			this.addChild(view);
			
			view.inputTF.maxChars=200;
			
			view.dom_friends_list.itemRender = FriendItem1;
			view.dom_friends_list.array = [];
		}
		
		/**
		 * tabs需要展示的页签   msgs传递过来的相关消息
		 * @param options {tabs:Array, bossId:int, msgs:Array, isHome:Boolean 是否是主基地}
		 * @return 
		 * 
		 */
		override public function show(options:Object):void {
			super.show();
			this.visible = true;
			state = state || new DataVo();
			
			toggleState(false);
//			toggleRedot(false);
			
			state.BOSSID = options.bossId;
			tabs_content_list = options.tabs;
			callBack = options.callBack;
			INIT_X = options.isHome ? -485 : -436;
			this.x = INIT_X;
			
			view.dom_tabList.array = getTabsArray(tabs_content_list);
			view.dom_tabList.x = (view.width - tabs_content_list.length * 136) / 2 - 20;
			
			if (options.msgs) {
				dealWithWorldGonghuiMsg(options.msgs[0], options.msgs[1], options.msgs[2]);
			}
			
			// 初始化信息
			view.dom_tabList.selectedIndex = -1;
			view.dom_tabList.selectedIndex = 0;
			
			current_module_view = null;
		}
		
		private function getTabsArray(data:Array):Array {
			var mapobj = {}
			mapobj[WORLD_CHAT] = "L_A_20823";
			mapobj[GUILD_CHAT] = "L_A_20824";
			mapobj[FRIEND_CHAT] = "L_A_3035";
			mapobj[BOSSMAP_CHAT] = "L_A_4405";
			return data.map(function(item) {
				return {
					"dom_btn": {selected: false, label: mapobj[item]},
					"dom_red": {visible: false}
				}
			});
		}
		
		/**处理传过来的 世界&公会&好友消息*/
		private function dealWithWorldGonghuiMsg(world:Array, gonghui:Array, newChatUid:Array):void {
			//			trace('接受的消息', world, gonghui, newChatUid);
			world.forEach(function(args) {
				var msg = msgCreator(args[1]);
				state.worldChatList.push(msg);
			});
			if (world.length) tabShowRed(WORLD_CHAT);
			
			gonghui.forEach(function(args) {
				var msg = msgCreator(args[2], args[3], args[4], args[5]);
				state.gonghuiChatList.push(msg);
			});
			if (gonghui.length) tabShowRed(GUILD_CHAT);
			
			friendsNewChatUidList = newChatUid.concat();
			if (newChatUid.length) tabShowRed(FRIEND_CHAT);
		}
		
		/**tab签显示小红点   需要显示小红点的页签内容字符*/
		private function tabShowRed(tab:String):void {
			var index = tabs_content_list.indexOf(tab);
			if (index == -1) return;
			if (index == view.dom_tabList.selectedIndex) return;
			view.dom_tabList.array.forEach(function(item, i) {
				if (index == i) {
					ToolFunc.copyDataSource(item["dom_red"], {visible: true});
					view.dom_tabList.setItem(i,	item);
				}
			});
		}
		
		/**发送消息*/
		private function sendMsgHandler():void {
			if (view.inputTF.text == "") return;
			if (clearTimerHandler) return;
			
			var showStr:String = view.inputTF.text;
			view.inputTF.text = "";
			// 发送的是哪个面板的消息
			switch (selectedTabContent) {
				case WORLD_CHAT:
					sendData(ServiceConst.WORLD_CHAT_SEND, [showStr]);
					
					break;
				
				case BOSSMAP_CHAT:
					sendData(ServiceConst.BOSS_MAP_CHAT, [state.BOSSID, showStr]);
					break;
				
				case GUILD_CHAT:
					sendData(ServiceConst.SEND_GUILD_TALK, [showStr]);
					break;
				
				case FRIEND_CHAT:
					if (!state.selected_uid) return XTip.showTip("L_A_3020");
					current_msg = showStr;
					sendData(ServiceConst.FRIEND_SENDCHAT, [state.selected_uid, showStr]);
					
					break;
			}
			
//			startCoolingTime();
		}
		
		/**开启冷冻*/ 
		private function startCoolingTime():void {
			clearTimerHandler = ToolFunc.limitHandler(COOLING_TIME, function(time) {
				view.sendBtn.disabled = true;
				view.sendBtn.label = "send(" + time + "s)"; 
			}, function() {
				view.sendBtn.disabled = false;
				view.sendBtn.label = "send";
				clearTimerHandler = null;
				trace('倒计时结束：：：');
			});
		}
		
		/**选择切换*/
		private function tabSelectHandler(index):void {
			if (index == -1) return;
			state.selected_uid = "";
			view.dom_tabList.array.forEach(function(item, i) {
				if (index == i) ToolFunc.copyDataSource(item["dom_red"], {visible: false});
				ToolFunc.copyDataSource(item["dom_btn"], {selected: (index == i)});
				view.dom_tabList.setItem(i,	item);
			});
			var isFriendTab = (selectedTabContent == FRIEND_CHAT);
			view.dom_viewStack.selectedIndex = isFriendTab ? 1 : 0;
			view.dom_title_box.visible = isFriendTab;
			
			view.dom_viewStack_back.selectedIndex = 0;
			view.dom_laba.visible = selectedTabContent == WORLD_CHAT;
			view.inputTF.x = selectedTabContent == WORLD_CHAT ? 68 : 18;
			
			updateLaba();
			
			renderChatHandler();
		}
		
		/**更新喇叭状态*/
		private function updateLaba():void {
			view.dom_laba.index = isBugleEnough() ? 0 : 1;
		}
		
		/**判断世界聊天需要的喇叭道具是否够*/
		private function isBugleEnough():Boolean {
			// 需要喇叭道具
			var data:Object = ResourceManager.instance.getResByURL("config/global_param.json");
			var targetValue:String = ToolFunc.getTargetItemData(data, "id", 26)["value"];
			var vArr = targetValue.split("=");
			var num = BagManager.instance.getItemNumByID(vArr[0]);
			
			return num >= Number(vArr[1]);
		}
		
		/**选中的页签内容tab*/
		private function get selectedTabContent():String {
			return tabs_content_list[view.dom_tabList.selectedIndex];
		}
		
		/**渲染聊天面板信息*/
		private function renderChatHandler():void {
			switch (selectedTabContent) {
				case WORLD_CHAT:
					renderChatList(state.worldChatList);
					break;
				
				case BOSSMAP_CHAT:
					renderChatList(state.bossMapChatList);
					break;
				
				case GUILD_CHAT:
					renderChatList(state.gonghuiChatList);
					break;
				
				case FRIEND_CHAT:
					sendData(ServiceConst.FRIEND_GETFRIENDLIST);
					break;
			}
		}
		
		/**渲染聊天记录*/
		private function renderChatList(data:Array):void {
			view.chatContainer.destroyChildren();
			data.forEach(function(item) {
				var child:LiaotianItem = createChatItem(item);
				view.chatContainer.addChild(child);
			});
			
			var scroll:VScrollBar = view.chatContainer.vScrollBar;
			timerOnce(50, this, function() {
				scroll.value = scroll.max;
			});
		}
		
		/**添加聊天信息*/
		private function addChat(msg):void {
			var child:LiaotianItem = createChatItem(msg);
			var scroll:VScrollBar = view.chatContainer.vScrollBar;
			
			view.chatContainer.addChild(child);
			timerOnce(50, this, function() {
				Tween.to(scroll, {value: scroll.max}, 300, Ease.linearNone);
			});
		}
		
		/**创建聊天信息子项    普通聊天消息 & 公会的宣战消息*/
		private function createChatItem(data):LiaotianItem {
			var child:* = data["isWar"] ? new GuozhanMsgItem() : new LiaotianItem();
			
			var uid = User.getInstance().uid;
			// 该信息是否是我的信息
			data.type = uid == data.uid ? "self" : "other";
			child.dataSource = data;
			var lastChild = view.chatContainer.getChildAt(view.chatContainer.numChildren - 1);
			if (lastChild) {
				child.y = lastChild.y + lastChild.height + 10;
			}
			
			return child;
		}
		
		private function onClickHandler(e:Event):void {
			switch (e.target) {
				case view.closeBtn:
					closeHandler();
					
					break;
				
				case view.sendBtn:
					// 发送消息
					sendMsgHandler();
					break;
				
				case view.btn_back:
					state.selected_uid = "";
					view.dom_viewStack.selectedIndex = 1;
					view.dom_viewStack_back.selectedIndex = 0;
					
					break;
				
				case view.btn_apply:
					XFacade.instance.openModule(ModuleName.SearchFriendsView);
					break;
			}
		}
		
		public function closeHandler():void {
			isShow = this.x == 0;
			var targetX = isShow ? INIT_X : 0;
			isShow = !isShow;
			
			toggleRedot(false);
			if (isShow) {
				toggleState(isShow);
				Tween.to(this, {x: targetX}, 200, Ease.linearNone);
			} else {
				Tween.to(this, {x: targetX}, 200, Ease.linearNone, Handler.create(this, function(){
					toggleState(isShow);
				}));
			}
		}
		
		/**输入禁止超过200个字符*/
		private function checkInput(e):void {
			if (e.text.length > 200) {
				view.inputTF.text = e.text.substr(0, 200);
			}
		}
		
		// 回车键发送
		private function keyupHandler(e:Event):void {
			if (this.x == INIT_X) return;
			if (e.keyCode == 13) {
				sendMsgHandler();
			}
		}
		
		/**切换小红点*/
		private function toggleRedot(bool:Boolean):void {
			view.dom_redot.visible = bool;
		}
		
		private function toggleState(bool:Boolean):void {
			for (var i = 0; i < view.numChildren; i++) {
				var child:Node = view.getChildAt(i);
				if (child != view.closeBtn) {
					child.visible = bool;
				}
			}
			view.dom_jiantou.visible = bool;
			
			if (!bool) {
				callBack && callBack();
				callBack = null;
			}
			
			if (bool){
				updateLaba();
				renderChatHandler();
			}
			
			MainView.isChatNewViewShow = bool;
			
			trace("聊天切换")
		}
		
		/**创建聊天消息对象*/
		private function msgCreator(uid, name, word, time):Object {
			return {
				"uid": uid,
				"name": name,
				"word": word,
				"time": time || TimeUtil.getHMS(TimeUtil.now)
			};
		}
		
		/**创建公会国战战斗消息*/
		private function msgGuildWarCreator(args):Object {
			// 获取城池名字
			var city_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
			
			return {
				"isWar": true, //是否是国战战斗信息
				"uid": args[6]["uid"],//发起玩家
				"name": args[3],//发起玩家
				"msg_type": args[6]["msg_type"],//信息类型
				"city_id": args[6]["city_id"],//城池id
				"city_name": GameLanguage.getLangByKey(city_data[args[6]["city_id"]]["name"]),//城池name
				"map_id": args[6]["map_id"],
				"att_guild_name": args[6]["att_guild_name"],//宣战公会
				"def_guild_name": args[6]["def_guild_name"],//防守公会
				"att_player_name": args[6]["att_player_name"],//宣战玩家
				"att_player_position": args[6]["att_player_position"],//宣战玩家职位
				"time": args[5] || TimeUtil.getHMS(TimeUtil.now)
			};
		}
		
		/**请求回来的数据处理*/
		private function onServerResult(...args):void{
			var cmd = Number(args[0]);
			trace('%c 【聊天】：', 'color: green', cmd, args);
			toggleRedot(!isShow);
			var result = args[1];
			var uid = User.getInstance().uid;
			
			switch(cmd) {
				// 公会
				case ServiceConst.GET_GUILD_TALK:
					var msg;
					// 普通的公会信息  || 关于国战战斗的公会信息
					if (args[1] == "guild") {
						msg = msgCreator(args[2], args[3], args[4], args[5]);
						
					} else if (args[1] == "legionwar"){
						msg = msgGuildWarCreator(args);
						
						GlobalRoleDataManger.instance.addLegionwarMsg(msg);
					}
					
					state.gonghuiChatList.push(msg);
					if (selectedTabContent == GUILD_CHAT) {
						isShow && addChat(msg);
					}
					tabShowRed(GUILD_CHAT);
					
					break;
				
				// boss地图
				case ServiceConst.BOSS_SERVER_CHAT:
					var msg = args[1];
					state.bossMapChatList.push(msg);
					if (selectedTabContent == BOSSMAP_CHAT) {
						isShow && addChat(msg);
					}
					tabShowRed(BOSSMAP_CHAT);
					
					break;
				
				// 世界聊天
				case ServiceConst.WORLD_CHAT_RECEIVE:
					var msg = args[1];
					state.worldChatList.push(msg);
					if (selectedTabContent == WORLD_CHAT) {
						isShow && addChat(msg);
						
						updateLaba();
					}
					tabShowRed(WORLD_CHAT);
					
					break;
				
				//获取游戏好友列表
				case ServiceConst.FRIEND_GETFRIENDLIST:
					state.extendData(result);
					renderFriends(state.friend_list, friendsNewChatUidList);
					
					if (state.apply_list.length) tabShowRed(FRIEND_CHAT);
					renderApplyInfo(state.apply_list);
					
					break;
				
				//好友聊天记录
				case ServiceConst.FRIEND_GATCHATLIST:
					var chatLog:Array = state.addAllChatHandlerNew(result[0]);
					renderChatList(chatLog);
					
					break;
				
				//给好友发消息
				case ServiceConst.FRIEND_SENDCHAT:
					if (!result[0]) return;
					var msg = msgCreator(uid, User.getInstance().name, current_msg);
					if (selectedTabContent == FRIEND_CHAT) {
						isShow && addChat(msg);
					}
					
					current_msg = "";
					// 存储消息
					state.addChatItemByUId(state.selected_uid, msg);
					
					break;
				
				//接受好友消息
				case ServiceConst.FRIEND_GETCHAT:
					var msg = msgCreator(args[1], args[2], args[3]);
					if (selectedTabContent == FRIEND_CHAT && msg["uid"] == state.selected_uid) {
						isShow && addChat(msg);
					} else {
						updateFriendsListRedPoint(msg["uid"]);
					}
					
					// 存储消息
					state.addChatItemByUId(msg["uid"], msg);
					tabShowRed(FRIEND_CHAT);
					
					if (friendsNewChatUidList.indexOf(msg["uid"]) == -1) friendsNewChatUidList.push(msg["uid"]);
					
					break;
				
				//删除好友
				case ServiceConst.FRIEND_DELETEFRIEND:
					if (!result[0]) return;
					state.deleteFriend(state.delete_uid);
					friendsNewChatUidList = friendsNewChatUidList.filter(function(item) {return item != state.delete_uid});
					renderFriends(state.friend_list, friendsNewChatUidList);
					
					break;
				
				//是否同意好友申请
				case ServiceConst.FRIEND_MANAGEFRIEND:
					if (!result[0]) return;
					state.applyHandler();
					
					renderApplyInfo(state.apply_list);
					if(state.isAgree) {
						sendData(ServiceConst.FRIEND_GETFRIENDLIST);
						tabShowRed(FRIEND_CHAT);
					}
					
					break;
				
				//某人通过你的好友请求
				case ServiceConst.FRIEND_GETREQUESTAPPLY:
					var info:Object = state.addFriend(args[1], args[2]);
					view.dom_friends_list.addItem(info);
					tabShowRed(FRIEND_CHAT);
					
					break;
				
				// 别人要加我好友
				case ServiceConst.FRIEND_GETREQUEST:
					state.addApplyFriend(args[1], args[2]);
					renderApplyInfo(state.apply_list);
					
					// 给予提示小红点
					tabShowRed(FRIEND_CHAT);
					
					break;
			}
		}
		
		/**渲染别人要加我好友的消息*/
		public function renderApplyInfo(data:Array):void {
			view.dom_applyRed.visible = !!data.length;
			view.dom_applyNum.text = String(data.length);
		}
		
		/**更新好友列表消息小红点*/
		public function updateFriendsListRedPoint(id:int):void {
			view.dom_friends_list.array.forEach(function(item, i) {
				if (id == item["uid"]) {
					item["isShowRed"] = true;
					view.dom_friends_list.setItem(i, item);
				}
			});
		}
		
		/**
		 *  渲染好友列表
		 * @param data 
		 * @param friendsNewChatUid 有新消息的好友uid
		 * 
		 */
		public function renderFriends(data:Array, friendsNewChatUid:Array = []):void {
			var result:Array = data.map(function(item) {
				return {
					"name": item["name"],
					"uid": item["uid"],
					"is_online": item["is_online"],
					"isShowRed": (friendsNewChatUid.indexOf(item["uid"]) != -1)
				}
			});
			view.dom_friends_list.array = result;
		}
		
		/**选择好友*/
		private function selectFriendHandler(e:Event = false):void {
			var index:int = view.dom_friends_list.selectedIndex;
			if (index == -1) return;
			var targetData = view.dom_friends_list.getItem(index);
			if (!targetData) return;
			var uid = targetData["uid"];
			
			// 删除按钮
			if (e && e.target && (e.target.name == "dom_cancel")) {
				var name = state.getUserNameById(uid);
				var text = GameLanguage.getLangByKey("L_A_3022").replace("{0}", name);
				XAlert.showAlert(text, Handler.create(this, function() {
					state.delete_uid = uid;
					WebSocketNetService.instance.sendData(ServiceConst.FRIEND_DELETEFRIEND, [uid]);
				}));
				return;
			}
			
			// 聊天按钮
			if (e && e.target && (e.target.name == "dom_talk")) {
				state.selected_uid = uid;
				friendsNewChatUidList = friendsNewChatUidList.filter(function(item) {return item != uid});
				targetData["isShowRed"] = false;
				view.dom_friends_list.setItem(index, targetData);
				
				// 已经有记录则直接拿来渲染  否则 请求数据
				if (state.allFriendsChatLog[uid]) {
					renderChatList(state.allFriendsChatLog[uid]);
				} else {
					sendData(ServiceConst.FRIEND_GATCHATLIST, [uid]);
				}
				
				view.dom_viewStack_back.selectedIndex = 1;
				view.dom_viewStack.selectedIndex = 0;
				return;
			}
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, onClickHandler);
			view.dom_tabList.selectHandler = new Handler(this, tabSelectHandler);
			view.inputTF.on(Event.INPUT, this, checkInput);
			view.dom_friends_list.on(Event.CLICK, this, selectFriendHandler);
			Laya.stage.on(Event.KEY_UP, this, keyupHandler); 
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_CHAT), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_CHAT_RECEIVE), this, onServerResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUESTAPPLY), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_DELETEFRIEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GATCHATLIST), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SENDCHAT), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEND_INVITE), this, onServerResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClickHandler);
			view.dom_tabList.selectHandler.recover();
			view.inputTF.off(Event.INPUT, this, checkInput);
			view.dom_friends_list.off(Event.CLICK, this, selectFriendHandler);
			Laya.stage.off(Event.KEY_UP, this, keyupHandler); 
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_CHAT), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_CHAT_RECEIVE), this, onServerResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUEST), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETREQUESTAPPLY), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETCHAT), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_DELETEFRIEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GATCHATLIST), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SENDCHAT), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEND_INVITE), this, onServerResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function onStageResize():void {
			view.y = (stage.height - view.height) / 2 - 20;
		}
		
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void {
			super.close();
			
			state.gonghuiChatList.length = 0;
			state.worldChatList.length = 0;
			
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
		}
		
		public static function hide():void {
			var v:LiaotianView = XFacade.instance.getView(LiaotianView);
			v && (v.visible = false);
		}
		
		public static function show():void {
			var v:LiaotianView = XFacade.instance.getView(LiaotianView);
			v && (v.visible = true);
		}
		
		private function get view():LiaotianViewUI {
			return _view = _view || new LiaotianViewUI();
		}
	}
}