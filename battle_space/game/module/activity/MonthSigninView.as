package game.module.activity
{
	import MornUI.acitivity.MonthSigninViewUI;
	
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
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 月卡签到
	 * @author hejianbo
	 * 
	 */
	public class MonthSigninView extends BaseView
	{
		/**服务端数据*/
		private var serverdata;
		
		public function MonthSigninView()
		{
			super();
			
			ResourceManager.instance.load(ModuleName.MonthSigninView,Handler.create(this, resLoader));
			
		}
		
		public function resLoader():void {
			this.addChild(view);
			
			addEvent();
			
			view.dom_list.itemRender = MonthSigninItem;
			view.dom_list.array = null;
			
		}
		
		/**创建每日的奖励*/
		private function createMonthAwards():void {
			var data = ResourceManager.instance.getResByURL("config/activity/clock_month_rewards.json");
			var callback = callbackHandler.bind(this);
			var result = ToolFunc.objectValues(data).map(function(item) {
				var days = Number(item["days"]);
				return {
					"callback": callback,
					"vip": getVipNum(item),
					"days": days,
					"isPassDay": days < getWitchDay(), // 是否是过去的天数
					"awards": item["reward"],
					"isToday": getWitchDay() == days,
					"isGet": serverdata["month_log"].indexOf(days) > -1 // 是否已领取
				}
			});
			
			view.dom_list.array = result;
		}
		
		private function callbackHandler(dom:MonthSigninItem):void {
			//补签
			if (dom.dom_isget.index == 1) {
				var data = ResourceManager.instance.getResByURL("config/activity/clock_fill_price.json");
				var targetData = ToolFunc.getItemDataOfWholeData(Number(serverdata["buy_num"]) + 1, data, "down", "up");
				if (targetData) {
					var priceArr = targetData["price"].split("=");
					// 确认购买的弹层
					XFacade.instance.openModule(ModuleName.ItemAlertView, ["L_A_67", priceArr[0], priceArr[1], function(){
						sendData(ServiceConst.SIGNIN_30_REPAIR, [dom.dataSource.days]);
					}]);
				}
			} else {
				// 签到当日
				if (dom.dataSource.isToday && !dom.dataSource.isGet) {
					sendData(ServiceConst.SIGNIN_30_GET);
				}
			}
		}
		
		private function isVipDay(days):Boolean{
			var targetdata = ToolFunc.find(view.dom_list.array, function(item) {
				return item["days"] == days;
			});
			if (targetdata) {
				return !!targetdata["vip"];
			}
			return false;
		}
		
		
		/**获取vip奖励的对应等级*/
		private function getVipNum(data):void {
			for (var i=0; i<=7; i++) {
				if (data["reward_" + i]) {
					return i;
				}
			}
			return 0;
		}
		
		/**今天是第几天*/
		private function getWitchDay():int {
			return Math.ceil((TimeUtil.nowServerTime - serverdata["start_date"]) / 86400);
		}
		
		private function onClick(event:Event):void {
			switch(event.target){
				
				
			}
		}
		
		private function showRewards(data):void {
			var rewards:String = "";
			data.forEach(function(item, index) {
				rewards += index == 0 ? item.join("=") : ";" + item.join("=");
			});
			
			ToolFunc.showRewardsHandler(rewards);
		}
		
		private function createLianxuAwards():void {
			var data = ResourceManager.instance.getResByURL("config/activity/clock_month_rewards.json");
			var lxData = ToolFunc.objectValues(data).filter(function(item) {
				return !!item["lx_rewards"];
			});
			
			lxData.forEach(function(item, index) {
				view["dom_lx" + (index + 1)].text = GameLanguage.getLangByKey("L_A_88431").replace("{0}", item["days"]);
				var dom:Sprite = view["dom_award" + index];
				dom.destroyChildren();
				dom.addChild(ToolFunc.createRewardsDoms(item["lx_rewards"])[0]);
				view["dom_ok" + index].visible = serverdata["month_lx_log"].indexOf(Number(item["days"])) > -1;
			});
			
		}
		
		private function onResult(...args):void{
			trace("月签", args[1]);
			switch(args[0]) {
				case ServiceConst.SIGNIN_OPEN:
					serverdata = args[1];
					createMonthAwards();
					
					view.dom_leiji.text = String(serverdata["month_log"].length);
					createLianxuAwards();
					
					break;
				
				case ServiceConst.SIGNIN_30_GET:
				case ServiceConst.SIGNIN_30_REPAIR:
					showRewards(args[1]["rewards"].concat(args[1]["lx_rewards"]));
					sendData(ServiceConst.SIGNIN_OPEN);
					
					break;
			}
		}
		
		private function addToStageEvent():void 
		{
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_30_GET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_30_REPAIR), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			WebSocketNetService.instance.sendData(ServiceConst.SIGNIN_OPEN);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_30_GET), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_30_REPAIR), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
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
		
		public function get view():MonthSigninViewUI{
			_view = _view || new MonthSigninViewUI();
			return _view;
		}
			
	}
}