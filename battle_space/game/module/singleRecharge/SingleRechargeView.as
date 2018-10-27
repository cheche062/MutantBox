package game.module.singleRecharge
{
	import MornUI.singleRecharge.SingleRechargeViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.module.activity.ActivityMainView;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 单笔充值 
	 * @author hejianbo
	 * 2018-03-13
	 */
	public class SingleRechargeView extends BaseView
	{
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		public function SingleRechargeView()
		{
			super();
			this.width = 829;
			this.height = 520;
			ResourceManager.instance.load(ModuleName.SingleRechargeView, Handler.create(this, resLoader));
		}
		
		public function resLoader():void
		{
			this.addChild(view);
			
			view.dom_list.itemRender = SingleRechargeItem;
			view.dom_list.array = [];
			addEvent();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.btn_charge:
					XFacade.instance.closeModule(ActivityMainView);
					XFacade.instance.openModule(ModuleName.ChargeView);
					
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【单笔充值】", args);
			switch(args[0]){
				// getInfo获取活动信息
				case ServiceConst.SINGLE_CHARGE_INIT:
					// 活动时间
					view.dom_time.text = args[1]["basic"]["start_date"] + " - " + args[1]["basic"]["end_date"];
					
					remainTime(args[1]["basic"]["end_date_time"]);
					
					var result:Array = dealWithData(args[1]);
					view.dom_list.array = result;
					
					break;
				
				//领取奖励
				case ServiceConst.SINGLE_CHARGE_REWARD:
					if (ActivityMainView.CURRENT_ACT_ID == args[1]["actId"]) {
						var reward = updateState(args[1]["id"]);
						showRewardDialog(reward);
					}
					
					break;
				default:
					break;
				
			}
		}
		
		/**处理数据*/
		private function dealWithData(data):Array {
			// 添加回调函数
			var callBack = sendClaimHandler.bind(this);
			var resultArr:Array = [];
			var config = data["config"];
			var process = data["process"];
			for (var key in config) {
				var itemData = config[key];
				resultArr.push({
					"id": itemData["id"],
					"callBack": callBack,
					"time": itemData["time"],
					"used_times": 0,
					"status": 0,
					"condition": itemData["amount"],
					"reward": itemData["reward"],
					"residue_times": 0
				});
			};
			
			for (var key in process) {
				var itemProcess = process[key];
				var _data = ToolFunc.find(resultArr, function(item) {
					return item["id"] == key;
				});
				if (_data) {
					_data["used_times"] = itemProcess["used_times"];
					_data["residue_times"] = itemProcess["residue_times"];
				}
			}
			
			return resultArr;
		}
		
		/**活动剩余时间*/
		private function remainTime(time):String{
			var diff = parseInt(time - parseInt(TimeUtil.now / 1000));
			if (diff > 0) {
				clearTimerHandler = ToolFunc.limitHandler(diff, function(time) {
					var result = TimeUtil.toDetailTime(time);
					view.dom_remain.text = TimeUtil.timeToTextLetter(result);
				}, function() {
					view.dom_remain.text = "0m 0s";
					clearTimerHandler = null;
					trace('倒计时结束：：：');
				});
			} else {
				view.dom_remain.text = "0m 0s";
			}
		}
		
		/**更新状态*/
		private function updateState(data):String{
			var _i = -1;
			var targetData = view.dom_list.array.filter(function(item, index){
				if (item["id"] == data) {
					_i = index;
					return true;
				}
				return false;
			})[0];
			
			// 领取    状态更新为2  使用的次数自增一次
			targetData = ToolFunc.copyDataSource(targetData, {
				"residue_times": Number(targetData["residue_times"]) - 1,
				"used_times": Number(targetData["used_times"]) + 1
			});
			view.dom_list.setItem(_i, targetData);
			
			return targetData["reward"];
		}
		
		/**显示奖励列表弹层*/
		private function showRewardDialog(data):void{
			var childList:Array = []
			ToolFunc.rewardsDataHandler(data, function(id, num){
				var child:ItemData = new ItemData();
				child.iid = id;
				child.inum = num;
				childList.push(child);
			});
			
			XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
		}
		
		/**发送领取命令*/
		private function sendClaimHandler(data):void{
			trace(data);
			
			// 领取
			sendData(ServiceConst.SINGLE_CHARGE_REWARD, [ActivityMainView.CURRENT_ACT_ID, data]);
		}
		
		private function addToStageEvent():void 
		{
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SINGLE_CHARGE_INIT), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SINGLE_CHARGE_REWARD), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			// 发送消息初始化信息
			sendData(ServiceConst.SINGLE_CHARGE_INIT, ActivityMainView.CURRENT_ACT_ID);
		}
		
		private function removeFromStageEvent():void
		{
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SINGLE_CHARGE_INIT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SINGLE_CHARGE_REWARD),this,onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		public function get view():SingleRechargeViewUI{
			_view = _view || new SingleRechargeViewUI();
			return _view;
		}
	}
}