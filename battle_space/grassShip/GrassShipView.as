package game.module.grassShip
{
	import MornUI.grassShip.grassShipViewUI;
	import MornUI.grassShip.iconItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.alert.XAlert;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Handler;
	
	/**
	 * 草船借箭
	 * @author hejianbo
	 * 2018-01-25
	 */
	public class GrassShipView extends BaseDialog
	{
		
		/**借箭参数url*/
		private const JIEJIAN_PARAM_URL = "config/jiejian/jiejian_param.json";
		/**阶段奖励url*/
		private const JIEJIAN_STAGE_URL = "config/jiejian/jiejian_stage_reward.json";
		/**突破奖励url*/
		private const JIEJIAN_TUPO_URL = "config/jiejian/jiejian_tupo_reward.json";
		/**道具兑换url*/
		private const JIEJIAN_ITEM_URL = "config/jiejian/jiejian_item.json";
		/**购买次数url*/
		private const JIEJIAN_BUYTIME_URL = "config/jiejian/jiejian_time.json";
		/**大本营等级对应的阶段奖励倍率*/
		private const JIEJIAN_DBY_URL = "config/jiejian/jiejian_rparam.json";
	
		/**指针间距*/
		private const POINTER_SPACE = 82; 
		/**起始y轴坐标*/
		private const POINTER_POS_0 = 240;
		
		/**服务端数据*/
		private var server_data:GrassShipServerVo;
		/**是否是首次兑换道具*/
		private var isFirstExchange:Boolean = true;
		
		public function GrassShipView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			server_data = new GrassShipServerVo();
			
			// 进入界面
			sendData(ServiceConst.CAOCHUAN_GET_INFO);
			
		}
		
		/**更新所有视图*/
		private function updateView(data: GrassShipServerVo):void{
			updateJieduan(data);
			updateHistoryBest(data);
			updateAttempts(data);
			updateDaojuItem(data);
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			// 初始化到 0位置
			updatePointPosition(0, 0);
			createItemBox();
			createDaojuItem();
			
			trace("【草船借箭】:   init");
		}
		
		
		/**更新道具是否可以点击 && 剩余可兑换次数*/
		private function updateDaojuItem(data: GrassShipServerVo):void{
			// 剩余积分
			view.dom_exchange_num.text = String(data.day_point);
			// 是否够兑换， 不够则禁用
			for (var i = 0; i < view.dom_HBox_exchange.numChildren; i++) {
				var child: ExchangeItem = view.dom_HBox_exchange.getChildAt(i);
				var itemSource = child.dataSource;
				
				//是否够买
				var isEnough:Boolean = Number(itemSource["dom_num"]) <= data.day_point;
				// 当前可买次数
				var cur_times = Number(itemSource["btn_exchange"]["label"].match(/\d+/)[0]);
				
				var _logNum = data.day_shop_buy_log[itemSource["my_ID"]] || 0;
				cur_times = itemSource["limit_times"] - _logNum;
				
				// 按钮文案
				var label = "Exchange(" + cur_times + ")";
				//是否达上限
				var isLimit:Boolean = (cur_times == 0);
				var disabled = isLimit || !isEnough;
				var result = {"btn_exchange": {"disabled": disabled, "label": label}};
					
				child.dataSource = ToolFunc.copyDataSource(child.dataSource, result);
			}
		}
		
		/**更新剩余战斗次数*/
		private function updateAttempts(data: GrassShipServerVo):void{
			/**是否还有剩余次数*/
			var hasTimes:Boolean = (data.day_combat_number == 0);
			// 次数0则禁用
			view.btn_attempts.disabled = hasTimes;
			view.dom_able.visible = !hasTimes;
			view.dom_buy.visible = hasTimes;
			
			// 有次数
			if (!hasTimes) {
				view.dom_times.text = data.day_combat_number;
			} else {
				/**购买数据*/
				var buy_data = ResourceManager.instance.getResByURL(JIEJIAN_BUYTIME_URL);
				// 下次购买次数
				var next:int = data.day_buy_number + 1;
				var result:Object = ToolFunc.getItemDataOfWholeData(next, buy_data, "down", "up");
				
				view.dom_buy_num.text = result["price"].split("=")[1];
			}
		}
		
		/**更新历史最高信息*/
		private function updateHistoryBest(data: GrassShipServerVo):void{
			/**突破数据*/
			var tupo_data = ResourceManager.instance.getResByURL(JIEJIAN_TUPO_URL);
			/**可领取的突破奖励档位*/
			var tupoArr:Array = [];
			/**不可领取的突破奖励档位*/
			var disTupoArr:Array = [];
			for (var key in tupo_data) {
				var score_grade = Number(tupo_data[key]["score_grade"]);
				if (data.history_max_point >= score_grade) {
					tupoArr.push(score_grade);
				} else {
					disTupoArr.push(score_grade)
				}
			}
			
			tupoArr = tupoArr.filter(function(item, index){
				return ToolFunc.hasKey(data.history_get_log, item) == false;
			})
			
			// 右侧数字
			var minNum:int;
			var tupoIndex = 0;
			// 有未领取的则显示未领取中的最小值， 没有则显示下一档几剩下的最小值
			if (tupoArr.length > 0) {
				minNum = Math.min.apply(null, tupoArr);
			} else {
				// 还有下一级
				if (disTupoArr.length > 0) {
					minNum = Math.min.apply(null, disTupoArr);
				} else {
					minNum = data.history_max_point;
					tupoIndex = 1; 
				}
			}
			
			view.dom_history.text = data.history_max_point + '/' + minNum;
			
			// 不够领
			view.btn_tupo.gray = data.history_max_point < minNum;
			view.btn_tupo.index = tupoIndex;
			
			var result = ToolFunc.getTargetItemData(tupo_data, "score_grade", minNum);
			view.btn_tupo["rewards"] = result["rewards"];
			
		}
		
		/**更新阶段奖励视图 & 指针位置*/
		private function updateJieduan(data:GrassShipServerVo):void{
			view.dom_day_total.text = data.day_total_point;
			var _daynum = Number(data.day_total_point);
			// 箱子是否置灰，   箱子是否打开
			var result:Object = {};
			for (var i = 0; i < view.dom_VBox_stage.numChildren; i++) {
				var child:View = view.dom_VBox_stage.getChildAt(i);
				var dataSource = child.dataSource;
				var cur_num:int = Number(dataSource["dom_text"]);
				result["gray"] = cur_num > _daynum;
				result["dom_icon"] = ToolFunc.hasKey(data.day_get_log, cur_num) ? 1 : 0;
				child.dataSource = ToolFunc.copyDataSource(child.dataSource, result);
			}
			
			/**箱子数据*/
			var box_data = ResourceManager.instance.getResByURL(JIEJIAN_STAGE_URL);
			
			/**当前可领取的箱子索引最大值*/
			var currentIndex:int = 0; 
			// 当前索引对应的value
			var currentStateNum:int = 0;
			// 下个索引对应的value
			var nextStateNum:int = 0;
			
			//是否还有下一等级
			var isExistNext:Boolean = false;
			for (var key:String in box_data) {
				// 攻击波次数不够了
				if(Number(box_data[key].value) > _daynum){
					var _num = Number(box_data[key].value);
					// 下一等级value
					nextStateNum = _num;
					isExistNext = true;
					break;
				}else{
					currentIndex++;
					currentStateNum = Number(box_data[key].value);
				}
			}
			
			// 当前攻击波次数在两个等级分区间所占的比例，为了去取进度值
			var percent = (_daynum - currentStateNum) / (nextStateNum - currentStateNum);
			// 没有下一等级了(已经是最大等级)
			if(!isExistNext) { percent = 0;}
			
			updatePointPosition(currentIndex, percent);
			
		}
		
		/**更新指针的位置 && 遮罩*/
		private function updatePointPosition(index:int, percent:Number):void{
			var y:int;
			// 0位置特殊
			y = index === 0 ? POINTER_POS_0 : POINTER_POS_0 - parseInt((percent + index - 1) * POINTER_SPACE);
			// 最上面的位置是-17
			view.dom_pointer.y = Math.max(y, -17);
			
			// 遮罩
			var mask:Sprite = view.dom_all.mask;
			if(!mask){
				view.dom_all.mask = mask = new Sprite();
			}
			mask.graphics.clear();
			// 稍微加一点到指针下面去不流缝隙
			mask.graphics.drawRect(0, y + 50 , view.dom_all.width, view.dom_all.height, "#000");
		}
		
		/**初始创建阶段奖励小箱子*/
		private function createItemBox():void{
			view.dom_VBox_stage.destroyChildren();
			/**箱子数据*/
			var data = ResourceManager.instance.getResByURL(JIEJIAN_STAGE_URL);
			var index:int = 1;
			for (var key in data) {
				var item = data[key];
				var child:View = new iconItemUI();
				child.dataSource = {
					"dom_icon": {skin: "grassShip/clip_reward_" + (index++) + ".png", index: 0},
					"dom_text": item["value"],
					"gray": true,
					"rewards": item["rewards"]
				}
				
				//添加到第0个位置
				view.dom_VBox_stage.addChildAt(child, 0);
			}
		}
		
		/**创建道具dom*/
		private function createDaojuItem():void{
			view.dom_HBox_exchange.destroyChildren();
			var daoju_data = ResourceManager.instance.getResByURL(JIEJIAN_ITEM_URL);
			var level = User.getInstance().level;
			var result:Array = ToolFunc.getItemDataOfWholeData(level, daoju_data, "level_down", "level_up", false);
			
			result.forEach(function(item, index){
				var child:ExchangeItem = new ExchangeItem();
				var times:String = "(" + item["limit"] + ")";
				child.dataSource = {
					"btn_exchange": {"disabled": true, "label": "Exchange" + times},
					"rewards": item["rewards"],
					"dom_num": item["price"],
					"dom_title": "",
					"my_ID": item["id"],
					"limit_times": Number(item["limit"])
				}
				view.dom_HBox_exchange.addChild(child);
			})
		}
		
		/**点击兑换请求*/
		private function exchangeHandler(dataSource):void{
			// 首次兑换需要二次确认的弹框
			if (isFirstExchange) {
				var text:String = GameLanguage.getLangByKey("L_A_80010");
				// 确认购买的弹层
				XAlert.showAlert(text, Handler.create(this, function(){
					isFirstExchange = false;
					sendData(ServiceConst.CAOCHUAN_BUY_SHOP_ITEM, dataSource.my_ID);
				}));
				
			} else {
				sendData(ServiceConst.CAOCHUAN_BUY_SHOP_ITEM, dataSource.my_ID);
			}
			
			trace("兑换道具ID:", dataSource.my_ID, dataSource)
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
			close();
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					close();
					
					break;
				
				// 排行
				case view.btn_rank:
					XFacade.instance.openModule(ModuleName.GrassShipRankView);
					
					break;
				
				// 战斗
				case view.btn_attempts:
					// 战斗结束后的回调
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SHIPWAR, null, Handler.create(this, function(){
						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
						XFacade.instance.openModule(ModuleName.GrassShipView);
					}));
					
					
					close();
					
					break;
				
				// 突破
				case view.btn_tupo:
					// 突破奖励已经领光了
					if (view.btn_tupo.index == 1) return;
					
					// 根据当前累计的流行石数量与下一突破资格数量做比较，不够 灰度且可查看奖励品， 够了就发送领取请求
					if (view.btn_tupo.gray && view.btn_tupo["rewards"]) {
						var rewardsArr:Array = view.btn_tupo["rewards"].split(";");
						var childList:Array = createRewardPanel(rewardsArr);
						// 显示箱子对应的奖励物品   	true 确定按钮
						XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList, true]);
						
						return;
					}
					var _index = view.dom_history.text.indexOf("/");
					var result = Number(view.dom_history.text.slice(_index + 1));
					
					// 发送领取的请求
					sendData(ServiceConst.CAOCHUAN_HISTORY_MAX, result);
					break;
				
				// 购买战斗次数
				case view.btn_add:
					var buy_data = ResourceManager.instance.getResByURL(JIEJIAN_BUYTIME_URL);
					// 下次购买次数
					var next:int = server_data.day_buy_number + 1;
					var result:Object = ToolFunc.getItemDataOfWholeData(next, buy_data, "down", "up");
					var priceArr:Array = result["price"].split("=");
					var text:String = GameLanguage.getLangByKey("L_A_80006");
					
					XFacade.instance.openModule("ItemAlertView", [text, priceArr[0], priceArr[1], function(){
						sendData(ServiceConst.CAOCHUAN_BUY_TIMES);
					}])
					
					break;
				
				// 帮助
				case view.btn_info:
					var msg:String = GameLanguage.getLangByKey("L_A_80005");
					XTipManager.showTip(msg);
				
				default:
					break;
			}
		}
		
		/**创建奖励小图的方法*/
		private function createRewardPanel(data:Array):Array{
			// 领取成功的提示弹框
			var childList = data.map(function(item, index){
				var child:ItemData = new ItemData();
				var _index = item.indexOf("=");
				child.iid = item.slice(0, _index);
				child.inum = item.slice(_index + 1);
				return child;
			})
			
			return childList;
		}
		
		/**小箱子点击事件*/
		private function boxClickHandler(event:Event):void{
			var target:View = event.target;
			var dataSource = target.dataSource;
			trace("小箱子click:", dataSource);
			// 收取过了无需响应
			if(dataSource["dom_icon"] == 1) return;
			
			// 灰度可以查看奖励物品
			if(dataSource.gray){
				//大本营对应的数据表倍率
				var dby_data = ResourceManager.instance.getResByURL(JIEJIAN_DBY_URL);
				// 大本营等级
				var lv = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BASE);
				var dby_item = ToolFunc.getTargetItemData(dby_data, "level", lv);
				if (dby_item) {
					var power = Number(dby_item["value"]);
					var rewardData = dataSource.rewards.split(";");
					rewardData = rewardData.map(function(item:String, index:int){
						var arr:Array = item.split("=");
						return arr[0] + "=" + Math.floor(Number(arr[1]) * power);
					})
					
					var childList:Array = createRewardPanel(rewardData);
					// 显示箱子对应的奖励物品   	true 不显示确定按钮
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList, true]);
				}
				
				return;
			}
			
			sendData(ServiceConst.CAOCHUAN_DAY_REWARD, Number(dataSource["dom_text"]));
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【草船借箭接收数据：】", args);
			switch(args[0]){
				//打开
				case ServiceConst.CAOCHUAN_GET_INFO:
					server_data = args[1];		
					updateView(server_data);
					
					break;
				
				// 购买战斗次数
				case ServiceConst.CAOCHUAN_BUY_TIMES:
					var result = {
						"day_combat_number": Number(server_data.day_combat_number) + 1,
						"day_buy_number": args[1]["day_buy_number"]
					}
					
					updateAttempts(ToolFunc.copyDataSource(server_data, result))
					
					break;
				
				// 阶段奖励
				case ServiceConst.CAOCHUAN_DAY_REWARD:
					var result = {
						"day_get_log": args[1]["day_get_log"]
					}
					var rewardData:Array = args[1]["reward"].map(function(item:Array, index){
						return item.join("=");
					})
					var childList:Array = createRewardPanel(rewardData);
					// 显示箱子对应的奖励物品  
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					
					updateJieduan(ToolFunc.copyDataSource(server_data, result));
					
					break;
				
				// 突破奖励
				case ServiceConst.CAOCHUAN_HISTORY_MAX:
					var result = {
						"history_get_log": args[1]["history_get_log"]
					}
					var rewardData:Array = args[1]["reward"].map(function(item:Array, index){
						return item.join("=");
					})
					var childList:Array = createRewardPanel(rewardData);
					// 显示箱子对应的奖励物品  
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					
					updateHistoryBest(ToolFunc.copyDataSource(server_data, result));
					
					break;
				
				// 兑换道具
				case ServiceConst.CAOCHUAN_BUY_SHOP_ITEM:
					var result = {
						"day_point": args[1]["day_point"],
						"day_shop_buy_log": args[1]["day_shop_buy_log"]
					}
					// 兑换到的商品id
					var daoju_data = ResourceManager.instance.getResByURL(JIEJIAN_ITEM_URL);
					var objItem = ToolFunc.getTargetItemData(daoju_data, "id", args[1]["shop_item_id"]);
					if (objItem) {
						var rewardsArr = objItem["rewards"].split(";")
						var childList:Array = createRewardPanel(rewardsArr);
						// 显示箱子对应的奖励物品  
						XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					}
					
					updateDaojuItem(ToolFunc.copyDataSource(server_data, result))
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_GET_INFO), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_BUY_TIMES), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_BUY_SHOP_ITEM), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_HISTORY_MAX), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_DAY_REWARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			// 添加小箱子点击事件
			for (var i:int = 0; i < view.dom_VBox_stage.numChildren; i++) 
			{
				view.dom_VBox_stage.getChildAt(i).on(Event.CLICK, this, boxClickHandler);
			}
			
			//缓存一下
			var _exchangeHandler = exchangeHandler.bind(this);
			// 添加兑换事件
			for (var i:int = 0; i < view.dom_HBox_exchange.numChildren; i++) 
			{
				var child: ExchangeItem = view.dom_HBox_exchange.getChildAt(i); 
				child.bindExchangeHandler = _exchangeHandler;
			}
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_GET_INFO), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_BUY_TIMES), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_BUY_SHOP_ITEM), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_HISTORY_MAX), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_DAY_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			// 移除小箱子点击事件
			for (var i:int = 0; i < view.dom_VBox_stage.numChildren; i++) 
			{
				view.dom_VBox_stage.getChildAt(i).off(Event.CLICK, this, boxClickHandler);
			}
			// 移除兑换事件
			for (var i:int = 0; i < view.dom_HBox_exchange.numChildren; i++) 
			{
				var child: ExchangeItem = view.dom_HBox_exchange.getChildAt(i); 
				child.bindExchangeHandler = null;
			}
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():grassShipViewUI{
			_view = _view || new grassShipViewUI();
			return _view;
		}
	}
}