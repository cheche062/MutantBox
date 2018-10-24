package game.module.chatNew
{
	import MornUI.chatNew.FriendItem1UI;
	
	public class FriendItem1 extends FriendItem1UI
	{
		public function FriendItem1()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_name.text = value["name"];
			dom_name.color = value["is_online"] == 0 ? "#cbcdcc" : "#ffefa7";
			dom_bg.gray = value["is_online"] == 0 ? 1 : 0;
			dom_online.index = value["is_online"] == 0 ? 1 : 0;
			
			dom_red.visible = value["isShowRed"];
			dom_cancel.visible = true;
			
			super.dataSource = value;
		}
	}
}