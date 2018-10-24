package game.module.chatNew
{
	import MornUI.chatNew.FaceBookFriendItemUI;
	
	import laya.events.Event;
	
	/**
	 * Facebook好友子项
	 * @author hejianbo
	 * 
	 */
	public class FaceBookFriendItem extends FaceBookFriendItemUI
	{
		public function FaceBookFriendItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_name.text = value["name"];
			dom_level.text = value["level"] || "";
			dom_guild.text = value["guild_name"] || "";
			btn_add.visible = !value["isAlreadyFriend"];
			
			btn_add.offAll();
			btn_add.on(Event.CLICK, this, value["callBack"], [value["uid"]]);
			
			super.dataSource = value;
		}
	}
}