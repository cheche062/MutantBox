package game.module.guild
{
	import MornUI.guild.StoreItemUI;
	
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 公会商店子项 
	 * @author mutantbox
	 * 
	 */
	public class StoreItem extends StoreItemUI
	{
		public function StoreItem()
		{
			super();
			
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			dom_icon.skin = GameConfigManager.getItemImgPath(value.item.id);			
			dom_iconNum.text = value.item.num;
			dom_name.text = DBItem.getItemData(value.item.id).name;
			dom_num.text = value.limit;
			btn_confirm.label = value.price.num;
			dom_needIcon.skin = GameConfigManager.getItemImgPath(value.price.id);
			
			dom_icon.on(Event.CLICK, this, showTips, [value.item.id]);
			btn_confirm.on(Event.CLICK, this, buyHandler, [value.id]);
			btn_confirm.disabled = value.limit == 0;
			
			
			super.dataSource = value;
		}
		
		private function showTips(id):void {
			ItemTips.showTip(id);
		}
		
		private function buyHandler(id):void {
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BUY_GOODS, [id]);
		}
	}
}