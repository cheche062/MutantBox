package game.module.chatNew
{
	import game.common.ToolFunc;
	import game.global.util.TimeUtil;
	import game.global.vo.User;

	/**
	 *  聊天数据vo
	 * @author hejianbo
	 * 
	 */
	public class DataVo
	{
		/**公会聊天信息*/
		public var gonghuiChatList:Array = [];
		/**世界聊天信息*/
		public var worldChatList:Array = [];
		/**boss地图聊天信息*/
		public var bossMapChatList:Array = [];
		/**世界boss战斗内使用*/
		public var BOSSID:String;
		
		/**所有好友的聊天记录*/
		public var allFriendsChatLog:Object = {};
		
		/**好友列表*/
		public var friend_list:Array = [];
		/**邀请消息列表*/
		public var apply_list:Array = [];
		/**选中好友的uid*/
		public var selected_uid:int = 0;
		/**删除好友的uid*/
		public var delete_uid:int = 0;
		/**是否同意*/
		public var isAgree:Boolean = false;
		/**处理其他玩家的申请uid*/
		public var apply_uid:int = 0;
		
		/**搜索弹层是否弹出中*/
		public var isSearchPopShow:Boolean;
		
		
		public function DataVo()
		{
		}
		
		public function extendData(data:Object):void {
			for (var key in data) {
				if (this.hasOwnProperty(key)) {
					this[key] = data[key];
				}
			}
		}
		
		/**添加单个好友的聊天记录*/
		public function addAllChatHandler(data):Array {
			var result:Array = ToolFunc.objectValues(data)
			.filter(function(item) {
				return typeof item == "object";
			})
			.map(function(item) {
				var name = getUserNameById(item["uid"]);
				item["name"] = name || User.getInstance().name;
				item["isSelf"] = !name;
				
				return item;
			});
			
			return allFriendsChatLog[selected_uid] = result;
		}
		
		/**添加单个好友的聊天记录(新)*/
		public function addAllChatHandlerNew(data):Array {
			var result:Array = ToolFunc.objectValues(data)
				.filter(function(item) {
					return typeof item == "object";
				})
				.map(function(item) {
					var name = getUserNameById(item["uid"]);
					item["name"] = name || User.getInstance().name;
					item["word"] = item["msg"];
					item["time"] = TimeUtil.getHMS(Number(item["time"]) * 1000);
					
					return item;
				});
			
			return allFriendsChatLog[selected_uid] = result;
		}
		
		/**添加单个聊天记录*/
		public function addChatItemByUId(uid:int, info:Object):void {
			allFriendsChatLog[uid] = allFriendsChatLog[uid] || [];
			allFriendsChatLog[uid].push(info);
		}
		
		/**通过id找name*/
		public function getUserNameById(uid:int):String {
			var target = ToolFunc.find(friend_list, function(info) {
				return info["uid"] == uid;
			});
			return (target && target["name"]) || ""; 
		}
		
		/**删除好友*/
		public function deleteFriend(uid:int):void {
			friend_list = friend_list.filter(function(item) {
				return item["uid"] != uid;
			});
			// 删除对应的聊天记录
			delete allFriendsChatLog[uid];
		}
		
		/**好友申请处理*/
		public function applyHandler():void{
			// 将处理的这条uid过滤掉
			apply_list = apply_list.filter(function(item) {
				return item["uid"] != apply_uid;
			});
		}
		
		/**增加一个好友*/
		public function addFriend(uid:int, name:String):Object{
			var info:Object = {
				"uid": uid,
				"name": name,
				"is_online": true
			}
			friend_list.push(info);
			
			return info;
		}
		
		/**增加别人加我好友的邀请*/
		public function addApplyFriend(uid:int, name:String):Object{
			var info:Object = {
				"uid": uid,
				"name": name,
				"is_online": true
			}
			apply_list.push(info);
			
			return info;
		}
		
	}
}