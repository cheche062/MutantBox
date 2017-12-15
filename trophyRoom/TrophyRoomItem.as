package game.module.trophyRoom
{
	import MornUI.trophyRoom.TrophyRoomItemUI;
	
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	
	import laya.display.Text;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 食物或军粮的ui控件 
	 * @author hejianbo 
	 * 
	 */
	public class TrophyRoomItem extends TrophyRoomItemUI
	{
		private static const L_A_76101 = "L_A_76101"	//食物
		private static const L_A_76102 = "L_A_76102"	//军粮
		private static const L_A_76103 = "L_A_76103"	//GET
		private static const L_A_76104 = "L_A_76104"	//BUY
		private static const L_A_76105 = "L_A_76105"	//下次购买必定翻2倍
		private static const L_A_76106 = "L_A_76106"	//下次购买必定翻3倍
		private static const L_A_76107 = "L_A_76107"	//建造公会后可购买能量棒
		private static const FOO_DICON_URL = "trophyRoom/food.png"	//食物皮肤地址
		private static const FOO_ARMY_DICON_URL = "trophyRoom/army_food.png"	//军粮皮肤地址

		//战利品的类型："0"：锁，"1"：食物，"2"：军粮
		private var trophyType:String = "-1";
		//公用icon
		private var dom_icon:ItemContainer;
		//icon id
		private var icon_id:int;
		
		public function TrophyRoomItem()
		{
			super();
			init();
		}
		
		private function init(): void{
			dom_active_box.visible = false;
			dom_lock_box.visible = false;
			
			dom_txt_title.font = XFacade.FT_BigNoodleToo;
			dom_txt_buy.font = XFacade.FT_BigNoodleToo;
			dom_txt_next.font = XFacade.FT_Futura;
			dom_txt_lock.font = XFacade.FT_Futura;
			dom_txt_free.font = XFacade.FT_Futura;
			dom_txt_money.font = XFacade.FT_Futura;
			
		}
		
		/**
		 * 初始化类型
		 */
		public function initType(value:String): void{
			trophyType = value;
			var isOpen:Boolean = (trophyType !== "0");
			dom_active_box.visible = isOpen;
			dom_lock_box.visible = !isOpen;
			
			//锁定状态
			if(!isOpen){
				dom_txt_lock.text = GameLanguage.getLangByKey(L_A_76107);
				
				return;
			}
			
			if(trophyType === "1"){
				dom_txt_title.text = GameLanguage.getLangByKey(L_A_76101);
				icon_id = 5; 
					
			}else if(trophyType === "2"){
				dom_txt_title.text = GameLanguage.getLangByKey(L_A_76102);
				icon_id = 16; 
			}
			
			dom_icon = new ItemContainer();
			this.dom_icon_box.addChild(dom_icon);
			
		}

		/**
		 * 更新数据 
		 * @param data
		 * 
		 */
		public function updataInfo(data:Object): void{
			if(trophyType === "0") return;
			
			var key:String = trophyType === "1"? "food" : "grain";
			var totalFreeTimes = data[key + "TotalFreeTimes"];
			
			//免费次数
			var freeTimes:int = totalFreeTimes - data[key + "GetTimes"];
			if(freeTimes > 0){
				dom_txt_free.visible = true;
				dom_txt_free.text = "Free" + freeTimes;
				dom_money.visible = false;
				dom_txt_buy.text = GameLanguage.getLangByKey(L_A_76103);
				
			}else{
				dom_txt_free.visible = false;
				dom_money.visible = true;
				dom_txt_money.text = data[key + "Price"];
				dom_txt_buy.text = GameLanguage.getLangByKey(L_A_76104);
			}
			
			//产出
			dom_icon.setData(icon_id, data[key + "Output"]);
			
			//下次暴击倍数
			switch (data[key + "CritRate"]){
				case 1:
					dom_next.visible = false;
					break;
				case 2:
					dom_txt_next.text = GameLanguage.getLangByKey(L_A_76105);
					dom_next.visible = true;
					break;
				case 3:
					dom_txt_next.text = GameLanguage.getLangByKey(L_A_76106);
					dom_next.visible = true;
					break;
			}
		}
		
		/**
		 * 领取成功的飘字动画展示
		 * 
		 */
		public function getSuccessAnimation(str: String):void{
			var dom_txt:* = this.getChildByName("dom_txt");
			if(dom_txt){
				Tween.clearAll(dom_txt);
				this.clearTimer(this, destroyDomTxtDelay);
				dom_txt.y = 0;
				
			}else{
				dom_txt = new Text();
				var skin:String = trophyType === "1"? FOO_DICON_URL : FOO_ARMY_DICON_URL;
				var dom_img:Image = new Image(skin);
				dom_img.scale(0.6, 0.6, true);
				dom_img.anchorX = 0.5;
				dom_img.anchorY = 0.5;
				dom_img.pos(-20, 20);
				
				dom_txt.font = XFacade.FT_Futura;
				dom_txt.color = "#fff";
				dom_txt.fontSize = 36;
				dom_txt.name = "dom_txt";
				dom_txt.addChild(dom_img);
				this.addChild(dom_txt);
			}
			
			dom_txt.text = "+" + str;
			dom_txt.x = (this.width - dom_txt.width) / 2;
			dom_txt.x = dom_txt.x + 20;
			
			Tween.to(dom_txt, {y: dom_txt.y - 30}, 500, Ease.circOut, Handler.create(this, function():void{
				this.timerOnce(800, this, destroyDomTxtDelay);
			}))
		}
		
		/**
		 * 延迟执行的清除文本动画元素 
		 * 
		 */
		private function destroyDomTxtDelay():void{
			var dom_txt:* = this.getChildByName("dom_txt");
			dom_txt && dom_txt.destroy(true);
		}
		
		/**
		 * 设置点击获取事件 
		 * @param confirmGet 回调
		 * 
		 */
		public function set clickHandler(confirmGet:Function):void{
			//开启状态
			if(parseInt(trophyType) > 0){
				btn_buy.clickHandler = Handler.create(this, confirmGet, [trophyType], false);
			}
			
		}
		
	}
}