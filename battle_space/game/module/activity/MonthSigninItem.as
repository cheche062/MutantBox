package game.module.activity
{
	import MornUI.acitivity.MonthSigninItemUI;
	
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class MonthSigninItem extends MonthSigninItemUI
	{
		public function MonthSigninItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
//			dom_bg.visible = value["type"];
			
			dom_icon.destroyChildren();
			dom_icon.addChild(ToolFunc.createRewardsDoms(value["awards"])[0]);
			
			if (value["isGet"]) {
				dom_isget.index = 0;
			}else {
				if (value["isPassDay"]) {
					dom_isget.index = 1;
				} else {
					dom_isget.index = -1;
				}
			}
			
			dom_day_num.text = GameLanguage.getLangByKey("L_A_88432").replace("{0}", value["days"]);
			
			if (value["vip"] == 0) {
				dom_vip.visible = false;
			} else {
				dom_vip.visible = true;
				dom_vip_text.text = GameLanguage.getLangByKey("L_A_88433").replace("{0}", value["vip"]).replace("{1}", "2");
			}
			
			dom_select.visible = value["isToday"];
			
			dom_icon.gray = dom_bg.gray = value["isPassDay"];
			var _skin =  (DBItem.getItemData(value["awards"].split("=")[0]).quality - 1);
			_skin = _skin == 0 ? "" : "_" + _skin;
			dom_bg.skin = "activity/monthSignin/bg1" + _skin + ".png";
			
			this.offAll();
			this.on(Event.CLICK, null, value["callback"], [this]);
			
			super.dataSource = value;
		}
	}
}