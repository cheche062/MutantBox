package game.module.chatNew
{
	import MornUI.chatNew.SearchFriendsViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 搜索好友 
	 * @author hejianbo
	 * 
	 */
	public class SearchFriendsView extends BaseDialog
	{
		/**是否是搜索出的好友（主动请求or被请求）*/ 
		private var is_apply:Boolean = true;
		/**目前处理的uid*/ 
		private var current_id:int = 0;
		/**推荐的好友数据*/ 
		private var recommend_data:Array;
		
		
		public function SearchFriendsView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void {
			this.addChild(view);
			
			view.dom_input.text = "";
			
			view.dom_searchList.itemRender = SearchFriendsItem;
			view.dom_searchList.array = null;
			
			view.dom_applyList.itemRender = ApplyFriendItem;
			view.dom_applyList.array = null;
			
			view.dom_facebookList.itemRender = FaceBookFriendItem;
			view.dom_facebookList.array = null;
			
		}
		
		override public function show(... args):void {
			super.show();
			AnimationUtil.flowIn(this);
			
			LiaotianView.state.isSearchPopShow = true;
			
			view.dom_tab.selectedIndex = -1;
			view.dom_tab.selectedIndex = 0;
			
			// App端没有facebook的好友邀请
			if (GameSetting.isApp) {
				view.dom_tab.labels = "L_A_3025,L_A_3024";
				view.btn_facebook.visible = false;
			} else {
				view.btn_facebook.visible = true;
				view.dom_tab.labels = "L_A_3025,L_A_3024,L_A_3026";
			}
		}
		
		private function tabSelectHandler(index:int):void {
			if (index == -1) return;
			view.dom_viewstack.selectedIndex = index;
			switch (index) {
				case 0:
					renderApplyFriendsList(LiaotianView.state.apply_list);
					
					break;
				
				case 1:
					if (!recommend_data || !recommend_data.length) {
						sendData(ServiceConst.FRIEND_RECOMMEND);
					}
					break;
				
				case 2:
					var _this:SearchFriendsView = this;
					function initData(arr:Array = [] ):void {
						trace("done==========")
						trace("【facebook数据】",arr);
						if (arr.length == 0) {
							return trace("无好友");
						}
						
						// 截取10个 防止太多
						arr = arr.slice(0, 10);
						var uidArr:Array = arr.map(function(item) {
							return item["uid"];
						});
						var result:String = uidArr.join(",");
						_this.sendData(ServiceConst.DEMAND_PLAYER_INFO, [result]);
					}
					
					__JS__("getInviteList(initData)");
					
					view.dom_facebookList.array = null;
					
					break;
				
			}
		}
		
		/**
		 * 请求回来的数据处理
		 * @param args
		 * 
		 */
		private function onServerResult(...args):void{
			var cmd = Number(args[0]);
			trace('%c 【搜索好友】：', 'color: green', cmd, args);
			var result = args[1];
			
			switch(cmd) {
				// 后端推荐的玩家
				case ServiceConst.FRIEND_RECOMMEND:
					recommend_data = ToolFunc.objectValues(result);
					view.dom_searchList.array = createFriendsListData(randomDataFromList(recommend_data), recommendDataHandler);
					
					break;
				
				case ServiceConst.FRIEND_APPLYFRIEND:
					if (!result[0]) return;
					XTip.showTip("L_A_3021");
					updateSearchFriendsList(current_id);
					current_id = 0;
					
					break;
				
				//搜索好友（搜索的好友只会有一个）
				case ServiceConst.FRIEND_SEARCHFRIEND:
					var list:Array = ToolFunc.objectValues(args).filter(function(item) {
						return typeof item == "object";
					});
					
					view.dom_searchList.array = createFriendsListData(list, searchDataHandler);
					
					break;
				
				case ServiceConst.FRIEND_MANAGEFRIEND:
					// 重新渲染
					timerOnce(100, this,function() {
						renderApplyFriendsList(LiaotianView.state.apply_list);
					})
					
					break;
				
				case ServiceConst.DEMAND_PLAYER_INFO:
					var facebookFriends:Array = ToolFunc.objectValues(result);
					view.dom_facebookList.array = createFriendsListData(facebookFriends, facebookDataHandler);
					
					break;
			}
		}
		
		/**在数据里随机取值*/
		private function randomDataFromList(data:Array):Array {
			var _data_copy:Array = data.concat();
			var result:Array = [];
			for (var i = 0; i < 3; i++) {
				if (_data_copy.length == 0) return result;
				var index = ToolFunc.getRandomNumber(_data_copy.length - 1);
				result.push(_data_copy.splice(index, 1)[0]);
			}
			
			return result;
		}
		
		/**创建好友玩家数据*/
		private function createFriendsListData(data:Array, handler:Function):void {
			var _this = this;
			var callBack = function(uid) {
				_this.current_id = uid;
				_this.sendData(ServiceConst.FRIEND_APPLYFRIEND, [uid]);
			}
			var friend_data:Array = data.map(function(item) {
				var _data = handler.call(this, item);
				_data.callBack = callBack;
				return _data;
			}, this);
			return friend_data;
		}
		
		/**推荐好友的数据处理逻辑*/
		private function recommendDataHandler(item:Object):Object {
			return {
				uid: item["base"]["uid"],
				name: item["base"]["name"],
				level: "Lv." + item["level"],
				guild_name: getGuildName(item["guild_name"])
			}
		}
		
		/**搜索的好友数据处理逻辑*/
		private function searchDataHandler(item:Object):Object {
			return {
				uid: item["uid"],
				name: item["name"],
				level: "Lv." + item["level"],
				guild_name: getGuildName(item["guild_name"]) 
			}
		}
		
		/**facebook好友的数据处理逻辑*/
		private function facebookDataHandler(item:Object):Object {
			var uid = item["base"]["uid"];
			var isAlreadyFriend:Boolean = LiaotianView.state.friend_list.some(function(item){
				return item["uid"] == uid;
			});
			return {
				uid: uid,
				name: item["base"]["name"],
				level: "Lv." + item["level"],
				isAlreadyFriend: isAlreadyFriend,
				guild_name: getGuildName(item["guild_name"])
			}
		}
		
		private function getGuildName(data):String {
			return data ? data : "L_A_3040";
		}
		
		/**更新搜索好友的列表  去除已经发送请求的*/
		private function updateSearchFriendsList(uid:int):void {
			view.dom_searchList.array = view.dom_searchList.array.filter(function(item) {
				return Number(item["uid"]) != Number(uid);
			});
		}
		
		/**渲染他人的申请*/ 
		private function renderApplyFriendsList(data:Array):void {
			var _this = this;
			// type 1同意  2拒绝
			var callBack = function(uid, type) {
				_this.current_id = uid;
				LiaotianView.state.isAgree = type == 1;
				LiaotianView.state.apply_uid = uid;
				_this.sendData(ServiceConst.FRIEND_MANAGEFRIEND, [uid, type]);
			}
			var result:Array = data.map(function(item){
				return {
					uid: item["uid"],
					name: item["name"],
					level: "Lv." + (item["level"] || ""),
					guild_name: getGuildName(item["guild_name"]),
					callBack: callBack
				}
			}, this);
			
			view.dom_applyList.array = result;
		}
		
		private function onClickHandler(e:Event):void {
			switch (e.target) {
				case view.btn_search:
					var text = view.dom_input.text;
					text = text.replace(/^\s+|\s+$/g, '');
					view.dom_input.text = "";
					if (text == "") return XTip.showTip(GameLanguage.getLangByKey("L_A_3017"));
					
					// 搜索好友
					sendData(ServiceConst.FRIEND_SEARCHFRIEND, [text]);
					
					break;
				
				case view.btn_change:
					view.dom_searchList.array = createFriendsListData(randomDataFromList(recommend_data), recommendDataHandler);
					
					break;
				
				case view.btn_close:
					close();					
					break;
				
				case view.btn_facebook:
					XFacade.instance.openModule(ModuleName.InviteFriendsView);
					
					break;
				
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, onClickHandler);
			view.dom_tab.selectHandler = new Handler(this, tabSelectHandler);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEARCHFRIEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_RECOMMEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_APPLYFRIEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DEMAND_PLAYER_INFO), this, onServerResult);
			
			super.addEvent();
		}
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, onClickHandler);
			view.dom_tab.selectHandler.recover();
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEARCHFRIEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_RECOMMEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_APPLYFRIEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_MANAGEFRIEND), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DEMAND_PLAYER_INFO), this, onServerResult);
			
			
			super.removeEvent();
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
			LiaotianView.state.isSearchPopShow = false;
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view():SearchFriendsViewUI {
			_view = _view || new SearchFriendsViewUI();
			return _view;
		}
	}
}