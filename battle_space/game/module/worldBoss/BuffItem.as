package game.module.worldBoss
{
	import MornUI.worldBoss.BuffItemUI;
	
	import game.common.ToolFunc;
	import game.common.XTip;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	
	
	public class BuffItem extends BuffItemUI
	{
		public function BuffItem(clickFn)
		{
			super();
			
			this.on(Event.CLICK, this, function() {
				if (this.dataSource["add"] == this.dataSource["max"]) {
					return XTip.showTip(GameLanguage.getLangByKey("L_A_85052"));
				}
				clickFn(this.dataSource["id"]);
			});
		}
		
		override public function set dataSource(value:*):void {
			var value = ToolFunc.copyDataSource(this.dataSource, value);
			
			// 队伍编号是否显示
			this.dom_icon.skin = "appRes/icon/buff_big/" + value["id"] + ".png";
			this.dom_price.text = value["price"];
			this.dom_add.text = "+" + value["add"] * 10 + "%";
			
			
			super.dataSource = value;
		}
		
		
	}
}