package game.module.chargeView
{
	import MornUI.fackBookChange.FaceBookReItemUI;
	
	import game.common.GameLanguageMgr;
	import game.common.XTipManager;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.reVo;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class FaceBookReItem extends Box
	{
		private var m_ui:FaceBookReItemUI;
		private var m_data:Object;
		/**定义宽度*/
		public static const WIDTH:Number = 214;
		/**定义高度*/
		public static const HEIGHT:Number = 105;
		
		/**是否是周卡*/
		private var isWeekCard:Boolean = false;
		/**是否是基金卡*/
		private var isJiJingCard:Boolean = false;
		
		private var waterImg:Image;
		
		
		public function FaceBookReItem()
		{
			super();
			init();
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			//trace("dataSource::",value)
			if (!value)
			{
				return;
			}
			m_data=value;
			initUI();
		}
		
		private function initUI():void
		{
			var p_str = m_data.name;
			
			/*isWeekCard = (p_str.indexOf("_7") > -1);
			isJiJingCard = (p_str.indexOf("_fund") > -1);
			
			//基金卡系列判断
			m_ui.dom_bottom_box.visible = !isJiJingCard;
			m_ui.dom_jijing.visible = isJiJingCard;
			
			// 非基金卡
			if (!isJiJingCard) {
				this.m_ui.ItemNumText.text = m_data.productsVo.number;
				this.m_ui.AddNumText.text = m_data.productsVo.presented != 0 ? "+" + m_data.productsVo.presented : "";
			} else {
				m_ui.dom_box.disabled = !m_data["isAbleBuyFunCard"];
			}*/
			
			this.scaleX = this.scaleY = 1.25;
			
			this.m_ui.ItemNumText.text = m_data.productsVo.number;
			this.m_ui.AddNumText.text = m_data.productsVo.presented != 0 ? "+" + m_data.productsVo.presented : "";
			
			getReVoByName(p_str);
		}
		
		private function getReVoByName(p_str:String):void
		{
			for (var i:int = 0; i < GameConfigManager.re_list.length; i++) 
			{
				var l_revo:reVo=GameConfigManager.re_list[i];
				if(l_revo.item_id == p_str)
				{
					// 价格必须写入
					this.m_ui.priceText.text = GameLanguageMgr.instance.getConfigLan(l_revo.name);
					/*trace("l_revo:", l_revo);
					trace("getConfigLan:", GameLanguageMgr.instance.getConfigLan(l_revo.name));
					trace("price:", p_str)*/
					
					// 根据是否是周卡来分别设置txt的坐标
					/*if(isWeekCard){
						m_ui.ItemNumText.pos(92, 204);
						m_ui.AddNumText.x = 60;
						m_ui.AddNumText.text = "+" + "100 Every day";
						m_ui.dom_box.disabled = !m_data["isAbleBuyWeekCard"];
						
					} else {
						m_ui.ItemNumText.pos(70, 236);
						m_ui.AddNumText.x = 137;
						m_ui.dom_box.disabled = false;
					}*/
					
					// 哪种卡   皮肤渲染
					/*if (isWeekCard) {
						m_ui.btn_type1.skin = "chargeView/bg1_2.png";
					} else if (isJiJingCard) {
						m_ui.btn_type1.skin = "chargeView/chargeBtn_2.png";
					} else {
						m_ui.btn_type1.skin = "chargeView/chargeBtn.png";
					}*/
					
					//m_ui.btn_info.visible = isWeekCard;
					//m_ui.dom_icon_up.visible = isWeekCard;
					
					// 非基金卡
					if (!isJiJingCard) {
						this.m_ui.IconImage.skin="appRes/icon/chargeIcon/icon_"+l_revo.icon+".png";
					}
				}
			}
		}
		
		/**帮助小提示*/
		private function showInfoHandler():void 
		{
			var msg:String = GameLanguage.getLangByKey("L_A_56085");
			XTipManager.showTip(msg);
		}
		
		/**购买*/
		private function showMeTheMoney():void{
			m_data.onSelectChargeHandler(isWeekCard);
			
			//trace("确认购买 是否是周卡", isWeekCard);
		}

		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new FaceBookReItemUI();
				this.addChild(m_ui);
				
				m_ui.dom_box.on(Event.CLICK, this, showMeTheMoney);
				//m_ui.btn_info.on(Event.CLICK, this, showInfoHandler);
				
			}
		}
		
	}
}