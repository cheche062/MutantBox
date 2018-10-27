package game.module.liangjiu
{
	import game.common.UIRegisteredMgr;
	import MornUI.liangjiu.LianshiUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.CheckBox;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 炼石分页 
	 * @author hejianbo
	 * 
	 */
	public class LianshiView extends LianshiUI
	{
		/**状态管理器*/
		private var state:LiangjiuVo;
		/**当次炼石次数*/
		public var lianshi_times:int = 1;
		
		/**粮草消耗*/
		private var food_cost:String;
		
		/**长按时间的起始记录时间*/
		private var timeStart:int;
		
		public function LianshiView()
		{
			super();
			
			init();
		}
		
		private function init():void {
			dom_list.vScrollBarSkin = "";
			dom_list.array = [];
			
			var result = ResourceManager.instance.getResByURL("config/tech_smelting_param.json");
			food_cost = ToolFunc.getTargetItemData(result, "id", "1")["value"];
			
			UIRegisteredMgr.AddUI(this.fireNotice,"fireNotice");
			UIRegisteredMgr.AddUI(this.mutilTips,"mutilTips");
			UIRegisteredMgr.AddUI(this.btn_confirm,"startComBtn");
			
		}
		
		public function show(data):void {
			dom_ten.clickHandler = new Handler(this, checkBoxSelectHandler, [10]);
			dom_hundred.clickHandler = new Handler(this, checkBoxSelectHandler, [100]);
			btn_confirm.on(Event.MOUSE_DOWN, this, function() {
//				trace('down')
				timeStart = new Date().getTime();
				timerLoop(1000, this, longClickHandler);
			});
			
			btn_confirm.on(Event.MOUSE_UP, this, mouseClearHandler);
			btn_confirm.on(Event.MOUSE_OUT, this, mouseClearHandler);
			
			state = data;
		}
		
		/**鼠标清除事件监听*/
		private function mouseClearHandler():void {
//			trace('up')
			var diff = new Date().getTime() - timeStart;
			if (diff <= 200) {
				confirmHandler();
			}
			clearTimer(this, longClickHandler);
		}
		
		/**错误*/
		public function errorHandler():void {
			clearTimer(this, longClickHandler);
		}
		
		/**长按连续发送请求*/
		private function longClickHandler():void {
//			trace('连续请求。。。')
			confirmHandler();
		}
		
		/**发送请求*/
		private function sendData():void {
			WebSocketNetService.instance.sendData(ServiceConst.NIANGJIU_LIANSHI, [lianshi_times]);
		}
		
		private function confirmHandler():void {
			var priceArr = food_cost.split("=");
			var cost = priceArr[1] * lianshi_times;
			var isEnough = User.getInstance().food >= cost;
			if (isEnough) {
				sendData();
			} else {
				var diff = cost - User.getInstance().food;
				var num = DBItem.caculatePrice(priceArr[0], diff);
				var i2:ItemData = new ItemData();
				i2.iid = 5;
				i2.inum = diff;
				
				XFacade.instance.openModule(ModuleName.ConsumeHelpPanel,[[i2], num, Handler.create(this, sendData)]);
				btn_confirm.disabled = true;
				timerOnce(200, this, function() {
					btn_confirm.disabled = false;
				});
				
				clearTimer(this, longClickHandler);
			}
		}
		
		public function update():void {
			renderLog(state.jingshi_log);
			dom_fire.text = String(state.fire);
			
			refreshFood();
		}
		
		/**飘字效果*/
		public function showFoodText():void {
			var txt = "-" + Number(food_cost.split("=")[1]) * lianshi_times;
			var _label:Label = new Label(txt);
			_label.font = XFacade.FT_Futura;
			_label.fontSize = 18;
			_label.color = "#fff";
			_label.pos(dom_food.x, dom_food.y);
			
			this.addChild(_label);
			Tween.to(_label, {y: _label.y - 30}, 500, Ease.circOut, Handler.create(this, function():void{
				_label.destroy();
			}));
		}
		
		/**刷新食物*/
		private function refreshFood():void {
			var foodNum = User.getInstance().food;
			var food = XUtils.formatResWith(foodNum);
			var cost = Number(food_cost.split("=")[1]) * lianshi_times;
			
			dom_food.text = food + "/" + cost;
			dom_food.color = foodNum >= cost ? "#fff" : "#f00";
		}
		
		private function checkBoxSelectHandler(num:int):void {
			var current_dom:CheckBox = num == 10 ? dom_ten : dom_hundred;
			var other_dom:CheckBox = num == 10 ? dom_hundred : dom_ten;
			
			if (current_dom.selected) {
				lianshi_times = num;
				other_dom.selected = false;
			} else {
				lianshi_times = 1;
			}
			
			refreshFood();
		}
		
		/**渲染获取晶石的记录*/
		private function renderLog(data:Array):void {
			var result = data.map(function(item:Array) {
				var info = DBItem.getItemData(item[0]);
				var name = GameLanguage.getLangByKey(info["name"]);
				return {
					"dom_text": {
						text: "Get " + name + " +" + item[1],
						color: getColor(item[0])
					}
				}
			});
			
			dom_list.array = result;
		}
		
		/**道具对应的颜色*/
		private function getColor(id):* {
			if ([93214, 93220, 93226].indexOf(id) > -1) return "#b9b9b9";
			if ([93215, 93221, 93227].indexOf(id) > -1) return "#91fe97";
			if ([93216, 93222, 93228].indexOf(id) > -1) return "#53d0ff";
			if ([93217, 93223, 93229].indexOf(id) > -1) return "#e587f6";
			if ([93218, 93224, 93230].indexOf(id) > -1) return "#ff8080";
			if ([93219, 93225, 93231].indexOf(id) > -1) return "#ffb554";
		}
		
		public function close():void {
			dom_ten.clickHandler.clear();
			dom_hundred.clickHandler.clear();
			btn_confirm.offAll();
		}
		
		
	}
}