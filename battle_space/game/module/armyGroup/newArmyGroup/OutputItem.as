package game.module.armyGroup.newArmyGroup
{
	import MornUI.armyGroup.newArmyGroup.OutPutItemUI;
	
	import game.common.ToolFunc;
	import game.global.util.TimeUtil;
	
	import laya.events.Event;
	
	public class OutputItem extends OutPutItemUI
	{
		public function OutputItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_name.text = value["name"];
			switch (value["state"]) {
				case 0:
					dom_state.text = "L_A_21032";
					dom_state.color = "#fffa9f";
					break;
				case 1:
					dom_state.text = "L_A_21033";
					dom_state.color = "#ff6567";
					break;
				case 2:
					dom_state.text = "L_A_21034";
					dom_state.color = "#48d0ff";
					break;
			}
			dom_rewards.destroyChildren();
			ToolFunc.createRewardsDoms(value["rewards"]).forEach(function(item) {
				dom_rewards.addChild(item);
			});
			
			// 倒计时时间
			var countDownTime:int;
			var hours:Array = value["access_time"].split(",");
			var stamps:Array = hours.map(function(hour:String, index){
				return {
					i: index,
					time:TimeUtil.getCurrentTimeToStampByHours(Number(hour))	
				};
			}).filter(function (item) {
				return item.time > TimeUtil.now;
			});
			
			if (stamps.length == 0) {
				// 下一日的第一个时间点
				countDownTime = hours[0] + ":00:00";
			} else {
				countDownTime = hours[stamps[0]["i"]] + ":00:00";
			}
			
			dom_time.text = countDownTime;
			dom_go.on(Event.CLICK, this, value["callBack"], [value["city_id"]]);
			
			super.dataSource = value;
		}
	}
}