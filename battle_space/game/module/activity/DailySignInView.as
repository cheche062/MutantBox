package game.module.activity 
{
	import MornUI.acitivity.DailySignInViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 7日签到
	 * @author hejianbo
	 */
	public class DailySignInView extends BaseView 
	{
		private var listSelectIndex:int = 0;
		/**服务端数据*/
		private var serverdata;
		
		public function DailySignInView() 
		{
			super();
			
			ResourceManager.instance.load(ModuleName.DailySignInView,Handler.create(this, resLoader));
		}
		
		public function resLoader():void
		{
			this.addChild(view);
			
			view.list_daily.itemRender = DailyItem;
			view.list_daily.array = null;
			view.list_lianxu.itemRender = DailyItem2;
			view.list_lianxu.array = null;
			
			addEvent();
			
		}
		
		/**创建每日的奖励*/
		private function createDailyAwards():void {
			var data = ResourceManager.instance.getResByURL("config/activity/clock_daily_rewards.json");
			var result = ToolFunc.objectValues(data).map(function(item) {
				var days = Number(item["days"]);
				return {
					"isSelect": days == listSelectIndex + 1,
					"isPassDay": days < getWitchDay(), // 是否是过去的天数
					"awards": item["rewards"],
					"isToday": getWitchDay() == days,
					"isGet": serverdata["daily_log"].indexOf(days) > -1 // 是否已领取
				}
			});
			
			view.list_daily.array = result;
		}
		
		/**该天是否是漏签*/
		private function isLeaveGet(day):Boolean {
			if (!view.list_daily.array || !view.list_daily.array.length) return true;
			var data = view.list_daily.array[day];
			if (!data) return true;
			return !data["isGet"] && data["isPassDay"];
		}
		
		/**今天是否已领取*/
		private function isTodayGet():Boolean {
			return serverdata["daily_log"].indexOf(getWitchDay()) > -1;
		}
		
		/**今天是第几天*/
		private function getWitchDay():int {
			return Math.ceil((TimeUtil.nowServerTime - serverdata["start_date"]) / 86400);
		}
		
		private function listHandler(index):void {
			if (index == -1) return;
			listSelectIndex = index;
			
			createDailyAwards();
			
			view.reCheckBtn.disabled = !isLeaveGet(listSelectIndex);
		}
		
		/**创建连续签到的奖励*/
		private function createLianxuAwards():void {
			var data = ResourceManager.instance.getResByURL("config/activity/clock_daily_rewards.json");
			var result = ToolFunc.objectValues(data).filter(function(item) {
				return !!item["lx_rewards"];
			});
			
			result = result.map(function(item) {
				return {
					"awards": item["lx_rewards"],
					"days": item["days"],
					"isSelect": serverdata["daily_lx_log"].indexOf(Number(item["days"])) > -1
				}
			});
			
			view.list_lianxu.array = result;
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.signBtn:
					sendData(ServiceConst.SIGNIN_7_GET);
					
					break;
				
				case view.reCheckBtn:
					trace(listSelectIndex);
					
					var data = ResourceManager.instance.getResByURL("config/activity/clock_fill_price.json");
					var targetData = ToolFunc.getItemDataOfWholeData(Number(serverdata["buy_num"] + 1), data, "down", "up");
					if (targetData) {
						var priceArr = targetData["price"].split("=");
						// 确认购买的弹层
						XFacade.instance.openModule(ModuleName.ItemAlertView, ["L_A_67", priceArr[0], priceArr[1], function(){
							sendData(ServiceConst.SIGNIN_7_REPAIR, [listSelectIndex + 1]);
						}]);
					}
					break;
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(...args):void
		{
			trace("7日签", args[1]);
			switch(args[0]) {
				case ServiceConst.SIGNIN_OPEN:
					serverdata = args[1];
					
					createDailyAwards();
					createLianxuAwards();
					
					view.signBtn.disabled = isTodayGet();
					view.list_daily.selectedIndex = 0;
					
					view.signedNumTF.text = serverdata["daily_lx_log"].length ? Math.max.apply(null, serverdata["daily_lx_log"]) : "0";
					
					break;
				
				case ServiceConst.SIGNIN_7_GET:
				case ServiceConst.SIGNIN_7_REPAIR:
					
					showRewards(args[1]);
					
					break;
			}
		}
		
		private function showRewards(data):void {
			view.list_daily.selectedIndex = -1;
			
			var rewards:String = "";
			data["rewards"].concat(data["lx_rewards"]).forEach(function(item, index) {
				rewards += index == 0 ? item.join("=") : ";" + item.join("=");
			});
			
			ToolFunc.showRewardsHandler(rewards);
			
			sendData(ServiceConst.SIGNIN_OPEN);
		}
		
		private function addToStageEvent():void {
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_7_GET), this, serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_7_REPAIR), this, serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			sendData(ServiceConst.SIGNIN_OPEN);
		}
		
		private function removeFromStageEvent():void {
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_7_GET), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_7_REPAIR), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, this.onClick);
			view.list_daily.selectHandler = new Handler(this, listHandler);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			view.list_daily.selectHandler.recover();
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function get view():DailySignInViewUI{
			return _view = _view || new DailySignInViewUI();
		}
	}

}