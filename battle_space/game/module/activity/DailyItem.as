package game.module.activity
{
	import MornUI.acitivity.DailyItemUI;
	
	import game.common.ItemTips;
	import game.common.ToolFunc;
	import game.global.GameConfigManager;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	
	public class DailyItem extends DailyItemUI
	{
		public function DailyItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			
			var awardArr = value["awards"].split("=");
			dom_icon.skin = GameConfigManager.getItemImgPath(awardArr[0]);
			dom_num.text = awardArr[1];
			setbg(value["isToday"]);
			
			dom_selected.visible = value["isSelect"];
			
			if (value["isGet"]) {
				dom_log.visible = true;
				dom_log.skin = "activity/icon_qian.png";
			}else {
				if (value["isPassDay"]) {
					dom_log.visible = true;
					dom_log.skin = "activity/icon_bu.png";
				} else {
					dom_log.visible = false;
				}
			}
			
			
			dom_icon.offAll();
			dom_icon.on(Event.CLICK, this, showTips, [awardArr[0]]);
			
			super.dataSource = value;
		}
		
		private function setbg(bool:Boolean):void {
			var i1 = this.getChildIndex(dom_bg);
			var i2 = this.getChildIndex(dom_icon);
			var maxI = Math.max(i1, i2);
			var minI = Math.min(i1, i2);
			if (bool) {
				addChildAt(dom_icon, maxI);
				addChildAt(dom_bg, minI);
			} else {
				addChildAt(dom_icon, minI);
				addChildAt(dom_bg, maxI);
			}
		}
		
		private function showTips(id):void {
			ItemTips.showTip(id);
		}
	}
}