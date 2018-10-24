package game.module.inviteFriend
{
	import MornUI.inviteFriends.InviteGameFriendsUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 邀请游戏内好友 
	 * @author hejianbo
	 * 2018-03-28 10:19:58
	 */
	public class InviteGameFriends extends BaseDialog
	{
		/**总的数据*/
		private var content_total:Array = [];
		
		public function InviteGameFriends()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function createUI():void{
			
			this.addChild(view);
			
			// 橡皮筋
			view.dom_list.scrollBar.elasticBackTime = 200;
			view.dom_list.scrollBar.elasticDistance = 50;
			
			updateList(content_total)
			
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			
			//发送请求好友列表
			sendData(ServiceConst.FRIEND_GETFRIENDLIST);
			
		}
		
		private function onClick(e:Event):void{
			switch(e.target)
			{
				case view.btn_close:
					close();
					
					break;
				
				case view.btn_invite:
					XFacade.instance.openModule(ModuleName.InviteFriendsView);
					close();
					
					break;
				
				case view.dom_all:
					var selected:Boolean = view.dom_all.selected;
					var data:Array = view.dom_list.array; 
					data.forEach(function(item, index){
						if (item["dom_online"] == 1) {
							item.dom_check = selected;
						}
					})
					
					updateList(data);
					break;
				
				// 确认按钮
				case view.btn_send:
					var namesArr:Array = view.dom_list.array.filter(function(item, index){
						return item.dom_check;
					}).map(function(item, index){
						return item.dom_uid;
					})
					
					// 有选中的好友
					if(namesArr.length){
						var result:String = namesArr.join("-");
						// 邀请语言
						var _txt = GameLanguage.getLangByKey("L_A_84454");
						
						// 发送邀请
						sendData(ServiceConst.FRIEND_SEND_INVITE, [result, _txt]);
						
					}else{
						XTip.showTip(GameLanguage.getLangByKey("L_A_61000"));
					}
					
					break;
				
				default:
					break;
			}
		}
		
		/**
		 * 点击当前好友
		 * 
		 */
		private function clickListHandler(e, index):void{
			if(e.type !== Event.CLICK) return;
			
			var itemData = view.dom_list.getItem(index);
			
			//在线
			if (itemData["dom_online"] == 1) {
				itemData.dom_check = !itemData.dom_check;
				view.dom_list.setItem(index, itemData);
				updateAllBtnState();
				
			} else {
				var text = GameLanguage.getLangByKey("L_A_84453");
				XTip.showTip(text);
			}
			
			trace(index)
		}
		
		/**
		 * 更新选中全部按钮状态
		 * 
		 */
		private function updateAllBtnState():void{
			// 是否是全部选中
			var isAll:Boolean = false;
			if(view.dom_list.array.length){
				isAll = view.dom_list.array.every(function(item, index){
					// 选中 || 未在线
					return item.dom_check || (item.dom_online != 1);
				})
			}
			
			view.dom_all.selected = isAll;
		}
		
		/**
		 * 更新好友列表 
		 * 
		 */
		private function updateList(data:Array):void{
			// 确保数据不变
			view.dom_list.array = ToolFunc.extendDeep(data);
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace('【InviteGameFriends】', args)
			
			// 测试数据
//			args[1]["friend_list"] = [
//				{name: "Player28", time: 1521600821, is_online: 1, uid: 28},
//				{name: "Player29", time: 1521600821, is_online: 0, uid: 29},
//				{name: "Player30", time: 1521600821, is_online: 1, uid: 30},
//				{name: "Player31", time: 1521600821, is_online: 1, uid: 31},
//				{name: "Player32", time: 1521600821, is_online: 1, uid: 32}
//			]
			switch (args[0]) {
				//获取好友列表
				case ServiceConst.FRIEND_GETFRIENDLIST:
					content_total = args[1]["friend_list"].map(function(item, index){
						return {
							dom_name: item["name"],
							dom_uid: item["uid"],
							dom_online: item["is_online"],
							gray: (item["is_online"] != 1),
							dom_check: false
						}
					})
					
					updateList(content_total)
					updateAllBtnState();
					
					break;
				
				// 邀请成功
				case ServiceConst.FRIEND_SEND_INVITE:
					var text = GameLanguage.getLangByKey("L_A_84452");
					XTip.showTip(text);
					
					close()
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.dom_list.mouseHandler = Handler.create(this, clickListHandler, null, false);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEND_INVITE), this, onResult);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.dom_list.mouseHandler = null;
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_GETFRIENDLIST), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FRIEND_SEND_INVITE), this, onResult);
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
			
			content_total.length = 0;
			updateList(content_total);
			updateAllBtnState();
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():InviteGameFriendsUI{
			_view = _view || new InviteGameFriendsUI();
			return _view;
		}
		
		
	}
}