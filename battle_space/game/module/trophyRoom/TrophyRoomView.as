package game.module.trophyRoom
{
	import MornUI.trophyRoom.TrophyRoomViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * TrophyRoomView
	 * author: hejianbo
	 * TrophyRoomView.as 2017-12-05 下午17:17:00
	 * version 1.0
	 */
	public class TrophyRoomView extends BaseDialog
	{
		private static var L_A_76100 = "L_A_76100"	//军需所
		private static var L_A_76108 = "L_A_76108"	//1.购买资源时，有机率出现使下次购买必定2倍或3倍暴击的事件.
													//2.暴击事件只在当日有效，需尽快触发。
													//3.当日购买资源次数越多，获得的资源数量越多。
		
		//打开战利品室
		private var TROPHY_ROOM_ENTER:int = ServiceConst.TROPHY_ROOM_ENTER;
		//领取
		private var TROPHY_ROOM_GET:int = ServiceConst.TROPHY_ROOM_GET;
		//错误消息
		private var ERROR:int = ServiceConst.ERROR;
		
		//配置   价格表  参数表  产出表
		private var configJson:Array = ["config/supply_price.json", "config/supply_param.json", "config/supply_output.json"];
		
		//食物 军粮 各自的总免费次数
		private static var FOOD_FREE_TIMES:int = 0;
		private static var GRAIN_FREE_TIMES:int = 0;
		
		public function TrophyRoomView()
		{
			super();
			
			closeOnBlank = true;
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					this.close();
					break

				case view.btn_help:
					var msg:String = GameLanguage.getLangByKey(L_A_76108);
					XTipManager.showTip(msg);
					
					break
			}
		}
		
		override public function createUI():void{
			this._view = new TrophyRoomViewUI();
			view.dom_txt_title.text = GameLanguage.getLangByKey(L_A_76100);
			
			this.addChild(view);
		}
		
		override public function show(...args):void{
			super.show();
			
			createTrophyRoomItemUI();
			
			AnimationUtil.flowIn(this);
			
			totalFreeTimes();
			
			//打开战利品室
			trace("【TrophyRoomView】发送:", TROPHY_ROOM_ENTER);
			sendData(TROPHY_ROOM_ENTER);
		}
		
		/**
		 * 创建战利品室的食物和军粮ui
		 */
		private function createTrophyRoomItemUI():void{
			//销毁子元素
			view.dom_content.destroyChildren();
			var supply_param = ResourceManager.instance.getResByURL(configJson[1]);
			
			// trace("【TrophyRoomView】表数据:", supply_param);
			for each(var v:Object in supply_param){
				var itemUi:TrophyRoomItem = new TrophyRoomItem();
				var splitArr:Array = v.value.split("=");
				var lev:int = User.getInstance().sceneInfo.getBuildingLv(splitArr[0]);
				if(lev >= parseInt(splitArr[1])){
					itemUi.initType(v.id);
					itemUi.name = "item" + v.id;
					itemUi.clickHandler = confirmGet.bind(this);
				}else{
					itemUi.initType("0");
				}
				
				view.dom_content.addChild(itemUi);
			}
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【TrophyRoomView】接受数据:", args);

			var data:* = args[1];
			//产出
			var outputInfo:Object = levelToOutput(User.getInstance().level);

			switch (args[0]){
				//进入战利品室
				case TROPHY_ROOM_ENTER:
					//价格
					var foodInfo:Object = getTimesToPriceScale(data.foodGetTimes, "1");
					var grainInfo:Object = getTimesToPriceScale(data.grainGetTimes, "2");
					data.foodPrice = foodInfo.price;
					data.foodScale = foodInfo.scale;
					data.grainPrice = grainInfo.price;
					data.grainScale = grainInfo.scale;
					data.foodTotalFreeTimes = FOOD_FREE_TIMES;
					data.grainTotalFreeTimes = GRAIN_FREE_TIMES;
					
					data.foodOutput = realityOutput(outputInfo.foodOutput, data.foodScale, data.foodCritRate);
					data.grainOutput = realityOutput(outputInfo.grainOutput, data.grainScale, data.grainCritRate);

					for(var i:int; i < view.dom_content.numChildren; i++){
						var child:TrophyRoomItem = view.dom_content.getChildAt(i);
						child.updataInfo(data);
					}
					
					break;
				
				//领取
				case TROPHY_ROOM_GET:
					data = {};
					var key:String = args[1] === "1"? "food" : "grain";
					var info:Object = getTimesToPriceScale(args[2], args[1]);
					data[key + "Price"] = info.price;
					data[key + "Scale"] = info.scale;
					
					data[key + "Output"] = realityOutput(outputInfo[key + "Output"], data[key + "Scale"], args[3]);
					delete data[key + "Scale"];
					data[key + "GetTimes"] = args[2];
					data[key + "CritRate"] = args[3];
					data[key + "TotalFreeTimes"] = args[1] === "1"? FOOD_FREE_TIMES : GRAIN_FREE_TIMES;
					
					var child:TrophyRoomItem = view.dom_content.getChildByName("item" + args[1]);
										
					child.updataInfo(data);
					child.getSuccessAnimation(args[4][0].num);
					
					break;
			}
		}

		/**
		 * 实际产出 = 产出 * 产出比例  / 100 *暴击倍率
		 * @param outPut
		 * @param scale
		 * @param critrate
		 * @return 
		 * 
		 */
		private function realityOutput(outPut:Number, scale:Number, critrate:Number):int{
			return Math.ceil(outPut * scale / 100 * critrate);
		}
		
		/**
		 * 根据购买次数计算价格和产出比例
		 * @param times
		 * @param type
		 * @return 
		 * 
		 */
		private function getTimesToPriceScale(times:int, type:String){
			var supply_price = ResourceManager.instance.getResByURL(configJson[0]);
			var data:Object = {};
			for each(var val:Object in supply_price){
				if(parseInt(val.CS) === times + 1 ){
					data.price = parseInt(val["cost" + type].split("=")[1]);
					data.scale = parseInt(val["scale" + type]);
					
					break;
				}
			}
			
			return data;
		}
		
		/**
		 * 根据用户等级计算产出
		 * @param level
		 * @return 
		 * 
		 */
		private function levelToOutput(level:Number):Object{
			trace("【TrophyRoomView】玩家等级:", level);

			var supply_output = ResourceManager.instance.getResByURL(configJson[2]);
			var data:Object = {};
			for each (var val:Object in supply_output){
				if(parseInt(val.level) === level){
					data.foodOutput = parseInt(val.food);
					data.grainOutput = parseInt(val.army_food);
					
					break;
				}
			}
			
			return data;
		}
		
		/**
		 * 计算总共的免费次数 
		 * @return 
		 * 
		 */
		private function totalFreeTimes():void{
			var supply_price = ResourceManager.instance.getResByURL(configJson[0]);
			var times1:int;
			var times2:int;
			for(var i:int = 1; i < 1000; i++){
				var foodB:Boolean = (supply_price[i].cost1.split("=")[1] === "0");
				var grainB:Boolean = (supply_price[i].cost2.split("=")[1] === "0");
				
				if(foodB) times1++;
				if(grainB) times2++;
				
				if(!foodB && !grainB) break;
			}
			FOOD_FREE_TIMES = times1;
			GRAIN_FREE_TIMES = times2;
			
			trace("【总共的免费次数】",FOOD_FREE_TIMES, GRAIN_FREE_TIMES);
		}
		
		override public function close():void{

			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
			
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(TROPHY_ROOM_ENTER), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(TROPHY_ROOM_GET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ERROR), this, onError);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(TROPHY_ROOM_ENTER), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(TROPHY_ROOM_GET), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ERROR), this, onError);
		}
		
		
		/**
		 * 确定领取命令发送
		 * @param value
		 * 
		 */
		private function confirmGet(value:int):void{
			trace("【TrophyRoomView】领取发送:", TROPHY_ROOM_GET, value);
			sendData(TROPHY_ROOM_GET, [value]);
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			configJson = null;
			super.destroy(destroyChild);
		}
		
		
		public function get view():TrophyRoomViewUI{
			return this._view as TrophyRoomViewUI;
		}
		
		
	}
}