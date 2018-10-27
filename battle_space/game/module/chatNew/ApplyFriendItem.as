package game.module.chatNew
{
	import MornUI.chatNew.ApplyFriendItemUI;
	
	import laya.events.Event;
	
	/**
	 *  他人好友申请子项
	 * @author hejianbo
	 * 
	 */
	public class ApplyFriendItem extends ApplyFriendItemUI
	{
		public function ApplyFriendItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_name.text = value["name"];
			dom_level.text = value["level"] || "";
			dom_guild.text = value["guild_name"] || "";
			
			dom_yes.offAll();
			dom_no.offAll();
			dom_yes.on(Event.CLICK, this, value["callBack"], [value["uid"], 1]);
			dom_no.on(Event.CLICK, this, value["callBack"], [value["uid"], 2]);
			
			super.dataSource = value;
		}
	}
}