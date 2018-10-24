package game.module.inviteFriend 
{
	import MornUI.inviteFriends.InviteFriendsViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 邀请好友
	 * @author hejianbo
	 */
	public class InviteFriendsView extends BaseDialog 
	{
		/**总的数据*/
		private var content_total:Array = [];
		
		/**测试数据*/
//		private var test_data:Array = [ 
//			{ id:"001", name:"test1", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"002", name:"test2", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"003", name:"test3", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"004", name:"test4", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"005", name:"test5", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"006", name:"test6", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}},
//			{ id:"007", name:"test7", picture: { data: { weight:50, height:50, url:"inviteFriends/pic.png" }}}
//		]
		
		public function InviteFriendsView()
		{
			super();
			closeOnBlank = true;
			
		}
		
		override public function createUI():void{
			
			this.addChild(view);
			updateList(content_total)
			
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			__JS__("getInviteList(initData)");
			
			/**
			 * 初始化数据
			 * 
			 */
			function initData(arr:Array = [] ):void {
				trace("done==========")
				trace(arr);
				var friendList:Array = arr;
				
				for(var i:int=0; i < friendList.length; i++){
					content_total.push({
						user_id: friendList[i].id,
						dom_content: friendList[i].name,
						dom_check: false,
						dom_icon: friendList[i].picture.data.url
					})
				}
				updateList(content_total);
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target)
			{
				case view.btn_close:
					close();
					
					break;
				
				case view.dom_all:
					var selected:Boolean = view.dom_all.selected;
					var data:Array = view.dom_list.array; 
					data.forEach(function(item, index){
						item.dom_check = selected;
					})
					
					updateList(data);
					break;
				
				// 确认按钮
				case view.btn_confirm:
					var namesArr:Array = view.dom_list.array.filter(function(item, index){
						return item.dom_check;
					}).map(function(item, index){
						return item.user_id;
					})
					
					if(namesArr.length){
						var result:String = namesArr.join(",");
						updateList(content_total);
						updateAllBtnState();
						
						// 邀请语言
						var _txt = GameLanguage.getLangByKey("L_A_80737");
						
						var str:String = "fbInvite('invteFriend', _txt, result)";
						trace("确认发送: ", str);
						
						__JS__("fbInvite('invteFriend', _txt, result)");
						
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
			itemData.dom_check = !itemData.dom_check;
			view.dom_list.setItem(index, itemData);
			
			updateAllBtnState();
			
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
					return item.dom_check;
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
			view.dom_list.array = copyArray(data);
		}
		
		/**
		 * 输入内容时调度 
		 * 
		 */
		private function inputHandler(e):void{
			var search:String = e.text;
			
			var data:Array = content_total.filter(function(item, index){
				var str:String = item.dom_content;
				return str.toLowerCase().indexOf(search.toLowerCase()) > -1;
			})
			
			updateList(data);
			updateAllBtnState();
			
			trace(search);
		}
		
		/**
		 * 拷贝数组数据 
		 * 
		 */
		private function copyArray(arr:Array):Array{
			return arr.map(function(item, index){
				var obj:Object = {};
				for(var key:String in item){
					obj[key] = item[key];
				}
				
				return obj;
			})
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.dom_list.mouseHandler = Handler.create(this, clickListHandler, null, false);
			view.dom_input.on(Event.INPUT, this, inputHandler);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.dom_input.off(Event.INPUT, this, inputHandler);
			view.dom_list.mouseHandler = null;
			
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
			
			content_total.length = 0;
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():InviteFriendsViewUI{
			_view = _view || new InviteFriendsViewUI();
			return _view;
		}
	}

}