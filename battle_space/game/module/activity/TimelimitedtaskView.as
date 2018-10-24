package game.module.activity
{
	import MornUI.acitivity.TimelimitedtaskViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	import org.flexunit.internals.namespaces.classInternal;
	
	/**
	 * 限时任务
	 * @author hejianbo
	 * 
	 */
	public class TimelimitedtaskView extends BaseView
	{
		private var clearTimerHandler:Function;
		
		public function TimelimitedtaskView()
		{
			super();
			ResourceManager.instance.load(ModuleName.MonthSigninView,Handler.create(this, resLoader));
			
		}
		
		public function resLoader():void {
			this.addChild(view);
			
			addEvent();
			
			view.dom_list.itemRender = TaskItem;
			view.dom_list.array = null;
			
		}
		
		private function timeCountDown(totalTime:int):void {
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
			clearTimerHandler = ToolFunc.limitHandler(totalTime, function(time) {
				var detailTime = TimeUtil.toDetailTime(time);
				view.dom_time.text = TimeUtil.timeToTextLetter2(detailTime);
//				trace(detailTime);
			}, function() {
				view.dom_time.text = "";
				clearTimerHandler = null;
				trace('倒计时结束：：：');
			}, false);
		}
		
		private function renderList(data:Object):void {
			var task_reward_data = ResourceManager.instance.getResByURL("config/activity/Time_limited_task_reward.json");
			var result:Array = ToolFunc.objectValues(data).map(function(item, index) {
				var table_data = task_reward_data[item.task];
				item["reward"] = table_data.reward;
				item["name"] = table_data.name;
				item["rank"] = table_data.rank;
				item["type"] = table_data.type;
				var content_text:String = GameLanguage.getLangByKey(table_data.describe);
				content_text = content_text.replace("{0}", table_data.canshu2).replace("{1}", table_data.canshu1);
				item["describe"] = content_text + " (" + item.progress + "/" + table_data.canshu2 + ")";
				item["isReach"] = item.progress == table_data.canshu2;
				return item;
			});
			result = result.sort(function(a, b) {
				return a.collected == 1 ? 1 : -1;
			});
			result.forEach(function(item, index) {
				item["index"] = index;
			})
			
			trace(result);
			view.dom_list.array = result;
		}
		
		private function onResult(...args):void{
			var cmd = args[0];
			var server_data = args[1];
			trace("限时任务", args[1]);
			switch(cmd) {
				case ServiceConst.TIME_LIMIT_TASK_OPEN:
//					var arr = {
//						"101":{"mainTaskId":101,"end":191563,"task":101,"progress":"1","collected":0},
//						"108":{"mainTaskId":108,"end":191563,"task":108,"progress":0,"collected":0},
//						"115":{"mainTaskId":115,"end":191563,"task":115,"progress":0,"collected":0},
//						"122":{"mainTaskId":122,"end":537163,"task":122,"progress":0,"collected":0}
//					}
					timeCountDown(Number(server_data.time));
					
					renderList(server_data.tasks);
					
					break;
				
				case ServiceConst.TIME_LIMIT_TASK_GET:
					ToolFunc.showRewardsHandlerByArray(server_data);
					WebSocketNetService.instance.sendData(ServiceConst.TIME_LIMIT_TASK_OPEN);
					break;
			}
		}
		
		private function addToStageEvent():void 
		{
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIME_LIMIT_TASK_OPEN), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIME_LIMIT_TASK_GET), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			WebSocketNetService.instance.sendData(ServiceConst.TIME_LIMIT_TASK_OPEN);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIME_LIMIT_TASK_OPEN), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIME_LIMIT_TASK_GET), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
		}
		
		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
		}
		
		override public function removeEvent():void{
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		override public function close():void{
			onClose();
		}
		
		private function onClose():void{
			super.close();
			
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		public function get view():TimelimitedtaskViewUI{
			_view = _view || new TimelimitedtaskViewUI();
			return _view;
		}
	}
}