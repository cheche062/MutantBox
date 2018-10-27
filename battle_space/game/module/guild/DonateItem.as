package game.module.guild
{
	import MornUI.guild.DonateItemUI;
	
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 公会捐献子项
	 * @author hejianbo
	 * 
	 */
	public class DonateItem extends DonateItemUI
	{
		public function DonateItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			dom_icon.skin = GameConfigManager.getItemImgPath(value.icon_id);			
			dom_icon2.skin = GameConfigManager.getItemImgPath(value.icon_id);			
			dom_num.text = "x" + value.icon_num;
			dom_mine.text = "(" + value.my_num + ")";
			dom_guildExp.text = "+" + value.guild_exp;
			dom_guildFund.text = "+" + value.guild_fund;
			dom_personalFund.text = "+" + value.personal_fund;
			
			dom_icon.on(Event.CLICK, this, showTips, [value.icon_id]);
			btn_donate.on(Event.CLICK, this, buyHandler, [value.type_id]);
			
			btn_donate.disabled = value.my_num < value.icon_num;
			
			super.dataSource = value;
		}
		
		private function showTips(id):void {
			ItemTips.showTip(id);
		}
		
		private function buyHandler(id):void {
			
			
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_DONATE, [id]);
		}
		
	}
}