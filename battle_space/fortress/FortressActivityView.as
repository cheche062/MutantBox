package game.module.fortress
{
	import MornUI.fortress.fortressActivityUI;
	import MornUI.fortress.iconItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Handler;
	
	
	/**
	 * 堡垒活动
	 * @author hejianbo
	 * 2018-01-18
	 */
	public class FortressActivityView extends BaseDialog
	{
		/**箱子间距*/
		private var BOX_SPACE:int = 28;
		/**指针间距*/
		private var POINTER_SPACE:int = BOX_SPACE + 64;
		/**指针  固定坐标*/
		private var POINTER_POS_0 = [16, 83];
		private var POINTER_POS_0_1 = [76, 26];
		private var POINTER_POS_1 = [110, 26];
		/**波数奖励url*/
		private var BAOLEI_POINT_URL = "config/baolei/baolei_point.json";
		/**堡垒参数url*/
		private var BAOLEI_PARAM_URL = "config/baolei/baolei_param.json";
		/**发动攻击次数购买价格*/
		private var BAOLEI_ATTEMPT_URL = "config/baolei/baolei_attempt.json";
		/**波数奖励 数据*/
		private var baolei_point_data:Object;
		/**堡垒 参数 数据*/
		private var baolei_param_data:Object;
				
		/**enter数据*/
		private var fortressData:Object = {
			attackTimes: 0, // 剩余发动次数（一般免费3次）
			attackRounds: 0, // 攻击波次数
			roundsReward: 0, // 领取记录
			buyTimes: 0 // 已购买次数
		};
		
		public function FortressActivityView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			// 进入堡垒
			sendData(ServiceConst.FORTRESS_ENTER);
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			// 初始化到 0位置
			updatePointPosition(0, 0);
			baolei_point_data = ResourceManager.instance.getResByURL(BAOLEI_POINT_URL);
			baolei_param_data = ResourceManager.instance.getResByURL(BAOLEI_PARAM_URL);
			view.dom_water.text = baolei_param_data["5"]["value"].split("=")[1];
			// 首先去读表再创建小箱子
			createItemBox(baolei_point_data);
			
			trace("【堡垒活动】:   init");
		}
		
		/**初始化创建小箱子*/ 
		private function createItemBox(data:Object):void{
			view.dom_HBox.space = BOX_SPACE;
			view.dom_HBox.destroyChildren();
			for (var key:String in data){
				var item = data[key];
				var child:View = new iconItemUI();
				child.dataSource = {
					"dom_icon": {skin: "fortress/clip_reward_" + item["ID"] + ".png", index: 0},
					"dom_text": item["num"],
					"gray": true
				}
				view.dom_HBox.addChild(child);
			}
		}
		
		/**更新指针的位置 && 遮罩*/
		private function updatePointPosition(index:int, percent:Number):void{
			var x:int;
			var y:int;
			// 0位置特殊
			if(index === 0){
				x = POINTER_POS_0[0] + (POINTER_POS_0_1[0] - POINTER_POS_0[0]) * percent;
				y = POINTER_POS_0[1] + (POINTER_POS_1[1] - POINTER_POS_0[1]) * percent;
				
			}else{
				x = POINTER_POS_1[0] + parseInt((percent + index - 1) * POINTER_SPACE);
				y = POINTER_POS_1[1];
			}
			
			view.dom_pointer.pos(x, y);
			
			// 遮罩
			var mask:Sprite = view.dom_all.mask;
			if(!mask){
				view.dom_all.mask = mask = new Sprite();
			}
			mask.graphics.clear();
			// 稍微加一点到指针下面去不流缝隙
			mask.graphics.drawRect(0, 0, x + 8, view.dom_all.height, "#000");
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
				
				// 扫荡
				case view.btn_five:
					var data:Array = baolei_param_data["5"]["value"].split("=");
					var text:String = GameLanguage.getLangByKey("L_A_79008");
					XFacade.instance.openModule("ItemAlertView", [text, data[0], data[1], function(){
						sendData(ServiceConst.FORTRESS_SWEP);
					}])
					
					break;
				
				// 进入战斗
				case view.btn_challenge:
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_FORTRESS, null, Handler.create(this, function(){
						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
						XFacade.instance.openModule(ModuleName.FortressActivityView);
					}));
					
					close();
					
					break;
				
				// 购买剩余发动次数
				case view.btn_add:
					var attempt_data = ResourceManager.instance.getResByURL(BAOLEI_ATTEMPT_URL);
					// 通过已购买次数来确定下次购买需要的水
					for(var key:String in attempt_data){
						var target:int = fortressData["buyTimes"] + 1;
						if(target >= attempt_data[key]["down"] && target <= attempt_data[key]["up"]){
							var price:Array = attempt_data[key]["price"].split("=");
							
							var text:String = GameLanguage.getLangByKey("L_A_79007");
							// 确认购买的弹层
							XFacade.instance.openModule("ItemAlertView", [text, price[0], price[1], function(){
								sendData(ServiceConst.FORTRESS_BUY_ATTACK);
							}])
							
							break;
						}
					}
					
					break;
				
				// 排行
				case view.btn_rank:
					XFacade.instance.openModule(ModuleName.FortressRankView);
					
					break;
				
				// 帮助
				case view.btn_info:
					var msg:String = GameLanguage.getLangByKey("L_A_79021");
					XTipManager.showTip(msg);
					
					break;
				
				default:
					break;
			}
		}
		
		/**小箱子点击事件*/
		private function boxClickHandler(event:Event):void{
			var target:View = event.target;
			var dataSource = target.dataSource;
			var index:int = view.dom_HBox.getChildIndex(target);
			/**当前物品的资格波数*/ 
			var currentNumText = Number(target.dataSource.dom_text);
			
			// 收取过了无需相应
			if(dataSource["dom_icon"] == 1) return;
			
			// 灰度可以查看奖励物品
			if(dataSource.gray){
				var rewardData:Array;
				// 读取数据
				for (var key in baolei_point_data) {
					if (Number(baolei_point_data[key]["num"]) == currentNumText) {
						rewardData = baolei_point_data[key]["reward"].split(";");
					}
				}
				var result:Array = rewardData.map(function(item:String, index:int){
					var _d = item.split("=");
					return {
						"id": _d[0],
						"num": _d[1]
					}
				})
				var childList:Array = createRewardPanel(result);
				// 显示箱子对应的奖励物品   	true 不显示确定按钮
				XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList, true]);
				
				return;
			}
			
			sendData(ServiceConst.FORTRESS_REWARD, currentNumText);
			trace("小箱子click:", index, currentNumText);
		}
		
		/**更新小箱子状态*/
		private function updateBoxState(index:int, data:Object):void{
			var child:View = view.dom_HBox.getChildAt(index);
			if(child){
				child.dataSource = copyDataSource(child.dataSource, data);
//				trace("小箱子dataSource:", index, child.dataSource);
			}
		}
		
		/**渲染堡垒页数据*/
		private function renderFortressEnter(data:Object):void{
			/**可发动次数*/
			var attackTimes = Number(data["attackTimes"]);
			//剩余攻击次数
			view.dom_attempts.text = GameLanguage.getLangByKey("L_A_79006").replace("{0}", attackTimes);
			// 没次数则禁用
			view.btn_challenge.disabled = (attackTimes == 0);
			
			/**当前攻击波次数*/ 
			var attackRounds:int = Number(data["attackRounds"]);
			view.dom_current.text = GameLanguage.getLangByKey("L_A_79001").replace("{0}", attackRounds);
			
			// 没有攻击波次数则扫荡按钮禁用
			view.btn_five.disabled = (attackRounds == 0);
			
			/**当前可领取的箱子索引最大值*/
			var currentIndex:int = 0; 
			// 当前索引对应的波数
			var currentStateNum:int = 0;
			// 下个索引对应的波数
			var nextStateNum:int = 0;
			
			//是否还有下一等级
			var isExistNext:Boolean = false;
			for (var key:String in baolei_point_data) 
			{
				// 攻击波次数不够了
				if(Number(baolei_point_data[key].num) > attackRounds){
					var _num = Number(baolei_point_data[key].num);
					// 距下一等级还有数
					view.dom_level.text = GameLanguage.getLangByKey("L_A_79002").replace("{0}", _num - attackRounds);
					nextStateNum = _num;
					
					isExistNext = true;
					break;
				}else{
					currentIndex = Number(key);
					currentStateNum = Number(baolei_point_data[key].num);
				}
			}
			
			// 当前攻击波次数在两个等级分区间所占的比例，为了去取进度值
			var percent = (attackRounds - currentStateNum) / (nextStateNum - currentStateNum);
			// 没有下一等级了(已经是最大等级)
			if(!isExistNext){
				view.dom_level.text = GameLanguage.getLangByKey("L_A_79003");
				percent = 0;
			}
			
			updatePointPosition(currentIndex, percent);
			
			/**箱子状态数据*/
			var resultState:Array = [];
			/*通过已有的攻击波次数来渲染箱子是否gray*/
			for (var i:int = 0; i < view.dom_HBox.numChildren; i++) 
			{
				var isGray= currentIndex > i;
				resultState[i] = {"gray": !isGray};
			}
			
			// 领取记录(打开已领取的箱子)
			var roundsReward:Array = data["roundsReward"];
			for (var key2:String in baolei_point_data)
			{
				var isOpened = roundsReward.indexOf(Number(baolei_point_data[key2].num)) > -1 ? 1 : 0;
				// 数据表从1开始
				resultState[Number(key2) - 1]["dom_icon"] = isOpened;
			}
			
			// 更新箱子
			for (var i:int = 0; i < view.dom_HBox.numChildren; i++) 
			{
				updateBoxState(i, resultState[i]);
			}
		}
		
		/**创建奖励小图的方法*/
		private function createRewardPanel(data:Array):Array{
			// 领取成功的提示弹框
			var childList = data.map(function(item, index){
				var child:ItemData = new ItemData();
				child.iid = item["id"];
				child.inum = item["num"];
				return child;
			})
				
			return childList;
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【堡垒活动】", args);
			switch(args[0]){
				//打开周卡
				case ServiceConst.FORTRESS_ENTER:{
					fortressData = args[1];
					renderFortressEnter(fortressData);
					
					break;
				}
				
				// 领取成功
				case ServiceConst.FORTRESS_REWARD:{
					var index:int = -1;
					for (var key:String in baolei_point_data){
						if(baolei_point_data[key].num == args[1]){
							index = Number(key) - 1;
							break;
						}
					}
					// 确认收取的那一只   更新小箱子
					updateBoxState(index, {"dom_icon": 1});
					
					var childList:Array = createRewardPanel(args[2]);
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					
					break;
				}
				
				// 扫荡成功
				case ServiceConst.FORTRESS_SWEP:{
					// 新的总攻击波数据
					var newAttackRounds = args[1];
					//本次增加的攻击波次数
					var currentAttackRounds = args[2];
					renderFortressEnter(copyDataSource(fortressData, {"attackRounds": newAttackRounds}));
					
					// 扫荡成功的弹层
					XFacade.instance.openModule(ModuleName.ChangleView, currentAttackRounds);
					
					break;
				}
				
				// 购买剩余发动次数
				case ServiceConst.FORTRESS_BUY_ATTACK:{
					// 新的剩余发动次数
					renderFortressEnter(copyDataSource(fortressData, {"attackTimes": args[1], "buyTimes": args[2]}));
					
					break;
				}
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);

			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_ENTER), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_SWEP), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_BUY_ATTACK), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_REWARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			// 添加小箱子点击事件
			for (var i:int = 0; i < view.dom_HBox.numChildren; i++) 
			{
				view.dom_HBox.getChildAt(i).on(Event.CLICK, this, boxClickHandler);
			}
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_ENTER), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_SWEP), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_BUY_ATTACK), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			// 移除小箱子点击事件
			for (var i:int = 0; i < view.dom_HBox.numChildren; i++) 
			{
				view.dom_HBox.getChildAt(i).off(Event.CLICK, this, boxClickHandler);
			}
		}
		
		/**
		 * 拷贝数据副本
		 * @param source 源数据
		 * @param data 扩展数据
		 * @return 
		 */
		private function copyDataSource(source:Object, data:Object):Object{
			var obj = source || {};
			for(var key:String in data){
				obj[key] = data[key];
			}
			
			return obj;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():fortressActivityUI{
			_view = _view || new fortressActivityUI();
			return _view;
			
		}
	}
}