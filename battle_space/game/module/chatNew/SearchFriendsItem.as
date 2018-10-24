package game.module.chatNew
{
	import MornUI.chatNew.SearchFriendsItemUI;
	
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class SearchFriendsItem extends SearchFriendsItemUI
	{
		public function SearchFriendsItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_name.text = value["name"];
			dom_level.text = value["level"];
			dom_guild.text = value["guild_name"];
			
			btn_add.offAll();
			btn_add.on(Event.CLICK, this, value["callBack"], [value["uid"]]);
		
			super.dataSource = value;
		}
		
	}
}