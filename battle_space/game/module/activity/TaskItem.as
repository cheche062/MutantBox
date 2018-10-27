package game.module.activity
{
	import MornUI.acitivity.TaskItemUI;
	
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 限时任务子项 
	 * @author hejianbo
	 * 
	 */
	public class TaskItem extends TaskItemUI
	{
		public function TaskItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			dom_title.text = value.name;
			dom_content.text = value.describe;
			
			var isOdd = value.index % 2 == 0;
			dom_bg.skin = isOdd? "activity/bg1_1 (2).png" : "activity/bg1_2 (2).png";
			dom_title.color = dom_content.color = isOdd ? "#afdcff" : "#affffe";
			btn_get.skin = isOdd ? "activity/btn_1 (2).png" : "activity/btn_2 (2).png";
			
			dom_icon.skin = "activity/box_" + (value.index + 1) + ".png";
			
			dom_icon.offAll();
			dom_icon.on(Event.CLICK, this, showRewards, [value.reward]);
			btn_get.offAll();
			btn_get.on(Event.CLICK, this, getReward, [value.mainTaskId, value.task]);
			
			btn_get.gray = !value.isReach;
			if (value.collected == 1) {
				btn_get.gray = true;
				btn_get.label = "L_A_80727";
			}
			
			super.dataSource = value;
		}
		
		private function showRewards(reward:String):void {
			ToolFunc.showRewardsHandler(reward);
		}
		
		private function getReward(mainTaskId, task):void {
			if (dataSource.collected == 1) {
				return;
			}
			if (btn_get.gray) {
				if (dataSource.type == "1") {
					XFacade.instance.openModule(ModuleName.ChestsMainView);
				} else if (dataSource.type == "2"){
					XFacade.instance.openModule(ModuleName.CampView);
				}
				
				XFacade.instance.closeModule(WelfareMainView);
				return
			}
			WebSocketNetService.instance.sendData(ServiceConst.TIME_LIMIT_TASK_GET, [mainTaskId, task]);
		}
	}
}