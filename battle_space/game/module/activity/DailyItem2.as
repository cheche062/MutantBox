package game.module.activity
{
	import MornUI.acitivity.DailyItem2UI;
	
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	
	public class DailyItem2 extends DailyItem2UI
	{
		public function DailyItem2()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			var awardArr = value["awards"].split("=");
			dom_icon.skin = GameConfigManager.getItemImgPath(awardArr[0]);
			dom_num.text = awardArr[1];
			dom_day.text = GameLanguage.getLangByKey("L_A_88432").replace("{0}", value["days"]);
			dom_selected.visible = value["isSelect"];
			
			dom_icon.offAll();
			dom_icon.on(Event.CLICK, this, showTips, [awardArr[0]]);
			
			
			super.dataSource = value;
		}
		
		private function showTips(id):void {
			ItemTips.showTip(id);
		}
	}
}