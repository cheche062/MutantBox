package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossChatViewUI;
	
	import game.common.LayerManager;
	import game.common.ToolFunc;
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.VScrollBar;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 世界boss聊天
	 * @author hejianbo
	 * 2018-05-10 17:34:30
	 */
	public class WorldBossChatView extends BaseView
	{
		private const INIT_X = -436;
		/**公会聊天信息*/
		private var gonghuiChatList:Array = [];
		/**世界聊天信息*/
		private var worldChatList:Array = [];
		private var BOSSID:String;
		/**是否显示中*/
		private var isShow:Boolean = false;
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		
		public function WorldBossChatView()
		{
			super();
			m_iLayerType=LayerManager.M_POP;
			m_iPositionType=LayerManager.LEFT;
		}
		
		override public function show(... args):void
		{
			super.show(args);
			initChatHandler();
			
			this.x = INIT_X;
			toggleState(false);
			toggleRedot(false);
			//参数
			var param:Array = args[0];
			BOSSID = param[0];
			
			// 公会
			var guildID = User.getInstance().guildID;
			if (guildID) {
				view.tabCtrl.labels = "WORLD,GUILD";
				view.tabCtrl.x=80;
			} else {
				view.tabCtrl.labels = "WORLD";
				view.tabCtrl.x=152;
			}
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
			view.inputTF.maxChars=200;
			
			// 初始化信息
			view.tabCtrl.selectedIndex=0;
		}
		
		/**
		 * 输入禁止超过200个字符
		 *
		 */
		private function checkInput(e):void
		{
			if (e.text.length > 200) {
				view.inputTF.text = e.text.substr(0, 200);
			}
		}
		
		private function sendMsgHandler():void
		{
			if (view.inputTF.text == "") return;
			if (clearTimerHandler) return;
			
			// 过滤敏感词汇
			var showStr:String=view.inputTF.text;
			// 发送的是哪个面板的消息
			switch (view.tabCtrl.selectedIndex)
			{
				case 0:
					// 发送世界消息
					sendData(ServiceConst.BOSS_MAP_CHAT, [BOSSID, showStr]);
					break;
				case 1:
					// 发送公会消息
					sendData(ServiceConst.SEND_GUILD_TALK, [showStr]);
					break;
				default:
					break;
			}
			
			view.inputTF.text = "";
			
			// 开启冷冻
			clearTimerHandler = ToolFunc.limitHandler(5, function(time) {
				view.sendBtn.disabled = true;
				view.sendBtn.label = "send(" + time + "s)"; 
			}, function() {
				view.sendBtn.disabled = false;
				view.sendBtn.label = "send";
				clearTimerHandler = null;
				trace('倒计时结束：：：');
			});
		}
		
		/**
		 * 根据选项卡初始化聊天面板信息
		 *
		 */
		private function initChatHandler():void
		{
			view.chatContainer.destroyChildren();
			
			var chatList:Array = view.tabCtrl.selectedIndex == 0 ? worldChatList : gonghuiChatList;
			// {"uid":4,"time":"20:09:02","name":"Player4","word":"hello"}
			chatList.forEach(function(item) {
				var child:WorldBossChatViewItem = createChatItem(item);
				view.chatContainer.addChild(child);
			});
			
			var scroll:VScrollBar = view.chatContainer.vScrollBar;
			timerOnce(50, this, function() {
				scroll.value = scroll.max;
			});
		}
		
		/**创建聊天信息子项*/
		private function createChatItem(data):WorldBossChatViewItem {
			var child:WorldBossChatViewItem = new WorldBossChatViewItem();
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
		
		/**添加聊天信息*/
		private function addChat(msg):void {
			var child:WorldBossChatViewItem = createChatItem(msg);
			var scroll:VScrollBar = view.chatContainer.vScrollBar;
			
			view.chatContainer.addChild(child);
			timerOnce(50, this, function() {
				Tween.to(scroll, {value: scroll.max}, 300, Ease.linearNone);
			});
		}
		
		override public function close():void
		{
			super.close();
			
			gonghuiChatList.length = 0;
			worldChatList.length = 0;
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
			
		}
		
		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
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
					
					if (isShow){
						initChatHandler();
					}
					
					break;
				case view.sendBtn:
					// 发送消息
					sendMsgHandler();
					break;
				default:
					break;
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
		
		/**请求回来的数据处理*/
		private function onServerResult(...args):void{
			var cmd = Number(args[0]);
			trace('%c 【boss聊天】：', 'color: green', cmd, args);
			toggleRedot(!isShow);
			
			switch(cmd) {
				//公会聊天
				case ServiceConst.GET_GUILD_TALK:
					var msg = {
						"uid": args[2],
						"name": args[3],
						"word": args[4],
						"time": args[5]
					};
					gonghuiChatList.push(msg);
					isShow && addChat(msg);
					
					break
				
				//世界聊天
				case ServiceConst.BOSS_SERVER_CHAT:
					var msg = args[1];
					worldChatList.push(msg);
					isShow && addChat(msg);
					
					break
			}
		}
		
		private function toggleState(bool:Boolean):void {
			for (var i = 0; i < view.numChildren; i++) {
				var child:Node = view.getChildAt(i);
				if (child != view.closeBtn) {
					child.visible = bool;	
				}
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, onClickHandler);
			view.tabCtrl.on(Event.CHANGE, this, initChatHandler);
			view.inputTF.on(Event.INPUT, this, checkInput);
			Laya.stage.on(Event.KEY_UP, this, keyupHandler); 
				
			// 实时获取公会消息
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onServerResult);
			// 实时获取世界消息
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_CHAT), this, onServerResult);
		}
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, onClickHandler);
			view.tabCtrl.off(Event.CHANGE, this, initChatHandler);
			view.inputTF.off(Event.INPUT, this, checkInput);
			Laya.stage.off(Event.KEY_UP, this, keyupHandler); 
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_TALK), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_SERVER_CHAT), this, onServerResult);
		}
		
		private function get view():WorldBossChatViewUI
		{
			_view = _view || new WorldBossChatViewUI();
			return _view;
		}
	}
}