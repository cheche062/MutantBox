package game.module.liangjiu
{
	import MornUI.liangjiu.ronglianUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.UIRegisteredMgr;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.CheckBox;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 熔炼分页 
	 * @author hejianbo
	 * 
	 */
	public class RonglianView extends ronglianUI
	{
		/**状态管理器*/
		private var state:LiangjiuVo;
		/**目标祝福值*/
		private var target_wish:int;
		
		/**当次合成次数*/
		private var ronglian_times:int = 1;
		/**三个坑的坐标*/
		private var posList:Array = [];
		/**选中的晶石id*/
		private var idList:Array = [];
		/**合成道具字符串*/
		private var itemStr:String = "";
		/**长按时间的起始记录时间*/
		private var timeStart:int;
		/**是否自动玩中*/
		private var isAutoPlay:Boolean;
		/**是否自动玩中*/
		private var tech_point:int = null;
		/**升级动画*/
		private var animateDom:Animation;
		
		
		/**总的晶石id顺序*/
		private var total_jingshi:Array = [93214, 93220, 93226, 93215, 93221, 93227, 93216, 93222, 93228, 
			93217, 93223, 93229, 93218, 93224, 93230, 93219, 93225, 93231];
		/**可合成匹配的晶石id*/
		private var pair_ids:Array = [
			[93214, 93220, 93226],
			[93215, 93221, 93227],
			[93216, 93222, 93228],
			[93217, 93223, 93229],
			[93218, 93224, 93230],
			[93219, 93225, 93231]
		]
		
		public function RonglianView()
		{
			super();
			init();
		}
		
		private function init():void {
			dom_list.vScrollBarSkin = "";
//			dom_list.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
//			dom_list.scrollBar.elasticDistance = 30;//设置橡皮筋极限距离。
			dom_list.array = [];
			
			for (var i = 0; i < dom_addImg.numChildren; i++) {
				var child:* = dom_addImg.getChildAt(i);
				posList.push([child.x, child.y]);
			}
			dom_addImg.destroyChildren();
//			btn_confirm.disabled = true;
			
			UIRegisteredMgr.AddUI(this.doubleTips,"doubleTips");
			UIRegisteredMgr.AddUI(this.mutilTimes,"mutilTimes");
			UIRegisteredMgr.AddUI(this.btn_confirm,"startRLBtn");
			UIRegisteredMgr.AddUI(this.ronglianResult,"ronglianResult");
		}
		
		public function show(data):void {
			dom_ten.clickHandler = new Handler(this, checkBoxSelectHandler, [10]);
			dom_hundred.clickHandler = new Handler(this, checkBoxSelectHandler, [100]);
//			dom_list.selectHandler = new Handler(this, listClickHandler);
			
//			btn_confirm.on(Event.MOUSE_DOWN, this, function() {
//				//				trace('down')
//				timeStart = new Date().getTime();
//				timerLoop(1000, this, longClickHandler);
//			});
			
//			btn_confirm.on(Event.MOUSE_UP, this, mouseClearHandler);
//			btn_confirm.on(Event.MOUSE_OUT, this, mouseClearHandler);
			btn_confirm.on(Event.CLICK, this, clickHandler);
			
			state = data;
		}
		
		public function update():void {
			renderMask(state.wish);
			renderJingshi(state.jingshi_items);
			
			if (tech_point == null || tech_point == state.tech_point) {
				tech_point = state.tech_point;
				dom_points.text = String(tech_point);
				if (isAutoPlay) {
					timerOnce(1000, this, confirmHandler);
				}
			} else {
				if (!animateDom) {
					animateDom = new Animation();
					animateDom.loadAtlas("appRes/effects/ronglian.json", Handler.create(this, playAnimation));
				}
				
				playAnimation();
			}
		}
		
		private function playAnimation():void {
			animateDom.pos(-110, -30);
			this.addChild(animateDom);
			animateDom.once(Event.COMPLETE, this, function() {
				Tween.to(animateDom, {x: 160, y: -180}, 600, null, Handler.create(this, updateZhufu));
			});
			
			animateDom.play(0, false);
		}
		
		private function updateZhufu():void {
			animateDom.removeSelf();
			
			Tween.to(dom_points, {scaleX: 1.5, scaleY: 1.5}, 100, null, Handler.create(this, function() {
				Tween.to(dom_points, {scaleX: 1, scaleY: 1}, 100, null, Handler.create(this, function() {
					tech_point = state.tech_point;
					dom_points.text = String(tech_point);
					if (isAutoPlay) {
						timerOnce(1000, this, confirmHandler);
					}
				}));
			}));
		}
		
		private function clickHandler():void {
			isAutoPlay = !isAutoPlay;
			if (isAutoPlay) {
				// 自动玩
				btn_confirm.label = "L_A_20604";
				confirmHandler();
			} else {
				// 取消
				btn_confirm.label = "L_A_14033";
			}
		}
		
		/**合成*/
		private function confirmHandler():void {
			// 是否使用水
			var useWater:Boolean = dom_critical.selected ? 1 : 0;
			
			trace('自动玩');
			
			for (var i=0; i < pair_ids.length; i++) {
				var isEnough:Boolean = pair_ids[i].every(function(itemId) {
					var idNumArr = ToolFunc.find(state.jingshi_items, function(idNumArr) {
						return idNumArr[0] == itemId;
					});
					return idNumArr && (idNumArr[1] >= ronglian_times);
				});
				if (isEnough) {
					var result:String = "";
					pair_ids[i].forEach(function(item) {
						var str = item + "=" + ronglian_times;
						result = !!result? result + ";" + str : str;
					});
					itemStr = result;
					
					WebSocketNetService.instance.sendData(ServiceConst.NIANGJIU_HECHENG, [itemStr, useWater]);
					
					return;
				}
			}
			
			clearAutoPlay();
			XTip.showTip("L_A_924017");
			
		}
		
		/**长按连续发送请求*/
//		private function longClickHandler():void {
//			//			trace('连续请求。。。')
//			confirmHandler();
//		}
		
		/**鼠标清除事件监听*/
//		private function mouseClearHandler():void {
//			//			trace('up')
//			var diff = new Date().getTime() - timeStart;
//			if (diff <= 200) {
//				confirmHandler();
//			}
//			clearTimer(this, longClickHandler);
//		}
		
		/**渲染祝福值*/
		private function renderMask(num):void {
			var result = ResourceManager.instance.getResByURL("config/tech_smelting_compose_cost.json");
			var targetData = ToolFunc.getItemDataOfWholeData(state.tech_point, result, "down", "up");
			target_wish = targetData["cost"];
			
			dom_fire.text = num + " / " + target_wish;
			var angle = num / target_wish * 360;
			
			// 遮罩
			var mask:Sprite = dom_fireMask.mask;
			if(!mask){
				dom_fireMask.mask = mask = new Sprite();
			}
			mask.graphics.clear();
			var _w = dom_fireMask.width;
			mask.graphics.drawPie(_w / 2, _w / 2, _w, -90, angle - 90, "#f00");
		}
		
		/**list事件*/
		private function listClickHandler(index):void {
			if (index == -1) return;
			
			var _dataSource = dom_list.getItem(index);
			if (_dataSource["gray"]) return;
			if (_dataSource["dom_num"] == 0) return XTip.showTip("L_A_19006");
			
			var cb = function(bool:Boolean) {
				_dataSource = dom_list.getItem(index);
				dom_list.setItem(index, ToolFunc.copyDataSource(_dataSource, {"gray": bool}));
			}
			selectJingshi(_dataSource["js_id"], cb.bind(this));
		}
		
		/**选中要合成的晶石*/
		private function selectJingshi(id:int, cb:Function):void {
			var current_num:int = dom_addImg.numChildren;
			if (current_num == 3) return XTip.showTip("L_A_19005");
			
			var skin = getJingshiSkin(id);
			var img:Image = new Image(skin);
			var pos = posList.splice(0, 1)[0];
			img.pos(pos[0], pos[1]);
			dom_addImg.addChild(img);
			
			cb(true);
			img.once(Event.CLICK, this, function() {
				cb(false);
				dom_addImg.removeChild(img);
				posList.push(pos);
				setIdList(id, false);
				dom_list.selectedIndex = -1;
			});
			
			setIdList(id, true);
		}
		
		/**添加待合成的晶石*/
		private function setIdList(id, isAdd:Boolean):void {
			if (isAdd) {
				idList.push(id);
			} else {
				idList.splice(idList.indexOf(id), 1);
			}
			
			getItemStr();
		}
		
		/**计算itemStr*/
		private function getItemStr():void {
			var result:String = "";
			idList.sort(function(a, b) {return Number(a) - Number(b)});
			idList.forEach(function(item) {
				var str = item + "=" + ronglian_times;
				result = !!result? result + ";" + str : str;
			});
			itemStr = result;
			
			var data = ResourceManager.instance.getResByURL("config/tech_smelting_Synthesis.json");
			var options:Array = ToolFunc.objectValues(data).map(function(item) {
				return item["cost_item"];
			});
			// 需在表里有该选项才行
//			btn_confirm.disabled = options.indexOf(itemStr) == -1;
		}
		
		/**错误*/
		public function errorHandler():void {
			clearAutoPlay();
		}
		
		private function clearAutoPlay():void {
			isAutoPlay = false;
			btn_confirm.label = "L_A_14033";
		}
		
		/***晶石是否足够*/
		private function isEnoughNum():Boolean {
			var current_data = {};
			state.jingshi_items.forEach(function(item) {
				current_data[item[0]] = item[1];
			});
			var result:Boolean = idList.every(function(id) {
				return Number(current_data[id]) >= ronglian_times;
			});
			return result;
		}
		
		/**渲染晶石列表*/
		private function renderJingshi(data:Array):void {
			var current_data = {};
			data.forEach(function(item) {
				current_data[item[0]] = item[1];
			});
			var result = total_jingshi.map(function(item) {
				return {
					"js_id": item,
					"dom_img": getJingshiSkin(item),
					"dom_num": current_data[item] || 0,
					"gray": idList.indexOf(item) > -1
				}
			});
			dom_list.array = result;
		}
		
		/**晶石皮肤*/
		private function getJingshiSkin(id:int):String{
			return "appRes/icon/itemIcon/" + id + ".png";
		}
		
		private function checkBoxSelectHandler(num:int):void {
			var current_dom:CheckBox = num == 10 ? dom_ten : dom_hundred;
			var other_dom:CheckBox = num == 10 ? dom_hundred : dom_ten;
			
			if (current_dom.selected) {
				ronglian_times = num;
				other_dom.selected = false;
				
			} else {
				ronglian_times = 1;
			}
			
			getItemStr();
		}
		
		public function close():void {
			dom_ten.clickHandler.clear();
			dom_hundred.clickHandler.clear();
			btn_confirm.offAll();
//			dom_list.selectHandler.clear();
			clearAutoPlay();
		}
	}
}