package game.module.bagua
{
	import MornUI.bagua.baguaViewUI;
	import MornUI.bagua.buffViewUI;
	
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
	import game.global.data.DBFightEffect;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.module.bingBook.ItemContainer;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	/**
	 * 奇门八卦
	 * @author hejianbo
	 * 2018-02-02
	 */
	public class BaguaView extends BaseDialog
	{
		/**刷新价格url*/
		private const BAGUA_PRICE_URL = "config/bagua/bagua_price.json";
		/**重置价格url*/
		private const BAGUA_RESET_URL = "config/bagua/bagua_reset.json";
		/**关卡奖励url*/
		private const BAGUA_GUANKA_URL = "config/bagua/bagua_guanka.json";
		/**宝箱奖励url*/
		private const BAGUA_BOX_URL = "config/bagua/bagua_box.json";
		/**npc url*/
		private const BAGUA_NPC_URL = "config/bagua/bagua_npc.json";
		
		/**奇门八卦*/
		private const MODULE_NAME = "【奇门八卦】:";
		/**当前选中项*/
		private const _current_select:int = -1;
		
		/**是否是第一次请求刷新*/
		private var isFirstRefresh = true;
		/**是否是第一次重置*/
		private var isFirstReset= true;
		
		/**状态树*/
		private var state:BaguaViewAllStateVo = new BaguaViewAllStateVo();
			
		public function BaguaView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			
			// 进入界面
			sendData(ServiceConst.BAGUA_ENTER);
			
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.dom_light_box.destroyChildren();
			// 只创建一次
			for (var i=0; i < 8; i++) {
				var child:BaguaLight = new BaguaLight();
				view.dom_light_box.addChild(child);
			}
			BaguaLight.changeSelectHandler = changeSelect.bind(this);
			
			updateMask(0);
			
			view.btn_getreward.zOrder = view.btn_reset.zOrder = view.btn_info.zOrder = 1;
			view.dom_npc_box.array = [];
			view.dom_npc_box.hScrollBarSkin = "";
			
			view.dom_buff.text = GameLanguage.getLangByKey("L_A_80507").replace(/##/g, '\n');
			
			trace(MODULE_NAME, "init");
		}
		
		/**创建遮罩  百分比*/ 
		private function updateMask(point:Number, isOver:Boolean):void{
			// 遮罩
			var mask:Sprite = view.dom_round.mask;
			var w = view.dom_round.width;
			point = Math.min(point, 1);
			point = Math.max(point, 0);
			if(!mask){
				view.dom_round.mask = mask = new Sprite();
			}
			mask.graphics.clear();
			mask.graphics.drawPie(w / 2, w / 2, w, -90, point * 360 - 90, "#000");
			
			var skin = isOver? "2" : "";
			// 皮肤
			view.dom_round.skin = "bagua/round" + skin + ".png";
		}
		
		/**选择改变*/
		private function changeSelect(index:int):void{
			// 还原上一项去除选中状态 
			updateLightItemState(current_select, {"isSelected": false});
			// 选中状态
			updateLightItemState(index, {"isSelected": true});
			
			current_select = index;
			
			trace("八卦状态树->state", current_select, state);
		}
		
		/**更新左侧八卦子元素state*/
		private function updateLightItemState(index:int, obj:Object):void{
			var child:BaguaLight = view.dom_light_box.getChildAt(index);
			if (child) {
				child.state = ToolFunc.copyDataSource(child.state, obj);
			}
		}
		
		/**更新宝箱视图*/
		private function updateBaoXiangView(arr:Array):void{
			/**宝箱奖励*/
			var data = ResourceManager.instance.getResByURL(BAGUA_BOX_URL);
			var num:int = 0;
			// 当前人数总和
			arr.forEach(function(item, index){
				num += item[1];
			})
			var user_data:Array = ToolFunc.getTargetItemData(data, "hp_level", state.hqLevel, false);
			var targetArr:Array = user_data.map(function(item, index){
				return Number(item["num"]);
			}).filter(function(item, index){
				return state.getedStep.indexOf(item) == -1;
			})
			
			// 是否领取完结
			var isOver = (targetArr.length == 0);
			// 目标人数
			var targetNum:int = isOver ? Number(user_data[user_data.length - 1]["num"]) : Math.min.apply(null, targetArr);
			// 全部逃完
			view.label_reward.text = num + "/" + targetNum;
			// 百分比
			var point:Number = num / targetNum;
			updateMask(point, isOver);
			
			// 当前宝箱奖励的数据
			var _data = isOver ? {"isOver": true} : ToolFunc.getTargetItemData(user_data, "num", targetNum);
			// 是否可领取
			_data["gray"] = isOver ? true : (point < 1);
			
			view.btn_getreward.dataSource = _data;
		}
		
		/**更新重置按钮*/
		private function updateResetBtn():void{
			var cost = nextResetCost(Number(state.resetTimes) + 1);
			view.label_reset.text = cost;
			
			// 重置按钮是否可点
			var isResetAble = true;
			for (var key in state.levels) {
				if (state.levels[key]["pass"] == 1) {
					isResetAble = false;
					break;
				}
			}
			
			view.btn_reset.disabled = isResetAble;
		}
		
		/**下次重置需要的花费数*/
		private function nextResetCost(tiems:int):String{
			/**重置价格*/
			var data = ResourceManager.instance.getResByURL(BAGUA_RESET_URL);
			var itemData:Object = ToolFunc.getItemDataOfWholeData(tiems, data, "down", "up");
			
			return itemData.price.split("=")[1];
		}
		
		/**更新八卦视图*/
		private function updateBaguaLightView(arr:Array):void{
			 for (var i=0; i < view.dom_light_box.numChildren; i++) {
				 var child:BaguaLight = view.dom_light_box.getChildAt(i);
				 var _state:BaguaLightStateVo = new BaguaLightStateVo();
				 _state.init(i, state.levels[i + 1], arr);
				 
				 child.state = _state;
			 }
		}
		
		/**npc显示列表*/
		private function updateNPCView(data:Array):void{
			/**npc*/
			var npc_data = ResourceManager.instance.getResByURL(BAGUA_NPC_URL);
			data = data.map(function(item, index){
				return npc_data[item]["unit_id"];
			})
			var result:Array = ToolFunc.concludeArray(data);
			// 全部都想资源地址
			var sourceArr = result.map(function(item, index){
				var skin:String = UnitPicUtil.getUintPic(item[0], UnitPicUtil.ICON_SKEW);
				return skin;
			})
			// 渲染数据
			var data_array = result.map(function(item, index){
				return {
					"dom_icon": sourceArr[index],
					"dom_num": item[1]
				}
			})
			// 资源加载完成				
			Laya.loader.load(sourceArr, Handler.create(this, function():void{
				view.dom_npc_box.array = data_array;
				view.dom_npc_box.scrollBar.value = 0;
			}))
		}
		
		/**rewards显示列表*/
		private function updateRewardsView(rewards:String):void{
			view.dom_rewards_box.destroyChildren();
			var _w = 0, _scale = 0.7;
			ToolFunc.rewardsDataHandler(rewards, function(id, num){
				// 添加小icon
				var child:ItemContainer = new ItemContainer();
				_w = child.width;
				child.setData(id, num);
				child.scale(_scale, _scale);
				view.dom_rewards_box.addChild(child);
			});
			var parent:Box = view.dom_rewards_box.parent;
			view.dom_rewards_box.x = (parent.width - _w * _scale * view.dom_rewards_box.numChildren) / 2;
		}
		
		/**更新刷新价格*/
		private function updateRefreshPrice(times:int):void{
			/**价格数据*/
			var data = ResourceManager.instance.getResByURL(BAGUA_PRICE_URL);
			var itemData:Object = ToolFunc.getItemDataOfWholeData(Number(times)+ 1, data, "down", "up");
			
			view.label_refresh.text = itemData["price"].split("=")[1];
			// 通关则禁用按钮
			view.btn_refresh.disabled = (state.levels[current_select + 1]["pass"] == 1);
		}
		
		/**
		 * 显示buff
		 * @param buffs
		 *
		 */
		private function showBuffsHandler(buffs:Array):void
		{
			view.dom_buff_box.destroyChildren();
			var result:Array = ToolFunc.concludeArray(buffs);
			result.forEach(function(item, index){
				var data:Object = DBFightEffect.getEffectInfo(item[0]);
				var skin:String = "appRes/icon/mazeIcon/" + data.icon + ".png";
				var dom_num:String = Number(data["effect2"]) * 100 * item[1] + "%";
				var des:String = GameLanguage.getLangByKey(data.des);
				des = des.replace(/\d+%/, dom_num);
				Laya.loader.load(skin, Handler.create(this, function():void{
					var buff:buffViewUI = new buffViewUI();
					buff.dataSource = {
						"dom_icon": skin,
						"dom_num": dom_num
					}
					buff.on(Event.CLICK, this, function():void{
						XTipManager.showTip(des);
					});
					view.dom_buff_box.addChild(buff);
				}));
			})
		}
		
		/**更新全部视图*/
		private function updateView(state:BaguaViewAllStateVo):void{
			showBuffsHandler(state.buffs);
			
			// 各关卡id及人数     =>  [[1, 2], [2, 1]]
			var result:Array = ToolFunc.concludeArray(state.usedUnitsHandler());
			updateBaoXiangView(result);
			
			updateBaguaLightView(result);
			
			updateResetBtn();
			
			// 默认第一关
			var _initIndex:int = _current_select == -1? 0 : _current_select;
			changeSelect(_initIndex);
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					close();
					
					break;
				
				// 帮助
				case view.btn_info:
					var msg:String = GameLanguage.getLangByKey("L_A_80401");
					XTipManager.showTip(msg);
					break;
				
				// 刷新战斗组
				case view.btn_refresh:
					if (isFirstRefresh) {
						var text:String = GameLanguage.getLangByKey("L_A_80501");
						var price = view.label_refresh.text;
						// 确认购买的弹层
						XFacade.instance.openModule("ItemAlertView", [text, "1", price, function(){
							sendData(ServiceConst.BAGUA_REFRESH, current_select + 1);
							isFirstRefresh = false;
						}])
					} else {
						sendData(ServiceConst.BAGUA_REFRESH, current_select + 1);
					}
					break;
				
				// 领取宝箱
				case view.btn_getreward:
					var _data = view.btn_getreward.dataSource;
					// 空数据 没得领了
					if (_data["isOver"]) return;
					if (_data["gray"]) {
						XFacade.instance.openModule(ModuleName.BaguaRewardsDialog, _data);
					} else {
						sendData(ServiceConst.BAGUA_GET_STEPREWARD);
					}
					break;
				
				// 重置
				case view.btn_reset:
					if (isFirstReset) {
						var text:String = GameLanguage.getLangByKey("L_A_80500");
						var price = nextResetCost(Number(state.resetTimes) + 1);
						// 确认购买的弹层
						XFacade.instance.openModule("ItemAlertView", [text, "1", price, function(){
							sendData(ServiceConst.BAGUA_RESET);
							isFirstReset = false;
						}])
					} else {
						sendData(ServiceConst.BAGUA_RESET);
					}
					
					break;
				
				// 战斗
				case view.btn_battle:
					// 战斗结束后的回调
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_BAGUA, (_current_select + 1), Handler.create(this, function(){
						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
						XFacade.instance.openModule(ModuleName.BaguaView);
					}));
					
					close();
					
					break;
					
				default:
					break;
			}
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace(MODULE_NAME, args);
			switch(args[0]){
				//打开
				case ServiceConst.BAGUA_ENTER:
				//重置
				case ServiceConst.BAGUA_RESET:
					state = ToolFunc.copyDataSource(state, args[1]);
					updateView(state);
					
					break;
				
				// 刷新成功
				case ServiceConst.BAGUA_REFRESH:
					// 更新单条旧数据
					var old_itemLevel = state.levels[args[1]];
					var new_itemLevel = ToolFunc.copyDataSource(old_itemLevel, {"refreshTimes": args[3], "team": args[2]});
					state.levels[args[1]] = new_itemLevel;
					
					updateView(state);
					
					break;
				
				// 领取宝箱奖励
				case ServiceConst.BAGUA_GET_STEPREWARD:
					var _reward = args[1].map(function(item, index){
						return item.join("=");
					}).join(";");
					var obj:Object = {
						"buff_reward": args[2].join(";"),
						"item_reward": _reward,
						"gray": false
					}
					XFacade.instance.openModule(ModuleName.BaguaRewardsDialog, obj);
					
					// 更新 buffs 和  getedStep
					state = ToolFunc.copyDataSource(state, {"getedStep": args[3], "buffs": state.buffs.concat(args[2])});
					updateView(state);
					
					break;
				
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BAGUA_ENTER), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BAGUA_REFRESH), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BAGUA_RESET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BAGUA_GET_STEPREWARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			for (var i=0; i < view.dom_light_box.numChildren; i++) {
				var child:BaguaLight = view.dom_light_box.getChildAt(i); 
				child.show();
			}
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BAGUA_ENTER), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BAGUA_REFRESH), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BAGUA_RESET), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BAGUA_GET_STEPREWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			for (var i=0; i < view.dom_light_box.numChildren; i++) {
				var child:BaguaLight = view.dom_light_box.getChildAt(i); 
				child.hide();
			}
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
			close();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function get current_select():int{
			return _current_select;
		}
		
		/**
		 * 设置当前选中的关卡索引(0 起始) && 同时更新npc和rewards视图
		 * @param value
		 * 
		 */
		private function set current_select(value:int):void{
			_current_select = value;
			
			// 当前选中关卡
			var levelsItem = state.levels[_current_select + 1];
			updateNPCView(levelsItem["team"]);
			updateRewardsView(levelsItem["rewards"]);
			updateRefreshPrice(levelsItem["refreshTimes"]);
			
			// 已完结
			view.btn_battle.disabled = (levelsItem["pass"] == 1);
		}
		
		public function get view():baguaViewUI{
			_view = _view || new baguaViewUI();
			return _view;
		}
	}
}