package game.module.mainui
{
	import game.common.GameLanguageMgr;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameSetting;
	import game.net.socket.WebSocketNetService;
	import MornUI.chargeView.ReItemUI;
	
	import game.common.AlertManager;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.vo.reVo;
	import game.module.chargeView.ChargeView;
	
	import laya.events.Event;
	
	public class ReItemView extends BaseView
	{
		private var m_ui:ReItemUI;
		private var m_data:reVo;
		/**是否是周卡*/
		private var isWeekCard:Boolean = false;
		/**是否是基金卡*/
		private var isJiJingCard:Boolean = false;
		/**定义宽度*/
		public static const WIDTH:Number = 268;
		/**定义高度*/
		public static const HEIGHT:Number = 197;
		
		public function ReItemView()
		{
			super();
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			trace("dataDetail:", value);
			m_data = value;
			
			/*// 周卡特别处理(取消这个功能时把这行注释掉即可)
			isWeekCard = Number(m_data.icon) === 8;
			isJiJingCard = Number(m_data.icon) === 9;*/
			
			
			initUI();
		}
		
		
		private function initUI():void
		{
			
			
			if (GameSetting.isApp)
			{
				// 价格必须写入
				this.m_ui.priceText.text = "$" + m_data.price;
				//this.scaleX = this.scaleY = 0.8;
				
				this.m_ui.IconImage.skin="appRes/icon/chargeIcon/icon_"+m_data.icon+".png";
				this.m_ui.IconImage.mouseEnabled = false;
				this.m_ui.IconImage.mouseThrough = true;
				this.m_ui.ItemNumText.text = m_data.token;
				this.m_ui.AddNumText.text = m_data.extra != 0 ? "+" + m_data.extra : "";
			}
			else
			{
				getReVoByName(m_data.name);
			}
		}
		
		private function getReVoByName(p_str:String):void
		{
			for (var i:int = 0; i < GameConfigManager.re_list.length; i++) 
			{
				var l_revo:reVo=GameConfigManager.re_list[i];
				if(l_revo.item_id == p_str)
				{
					// 价格必须写入
					this.m_ui.priceText.text = "$" + l_revo.price;
					//this.scaleX = this.scaleY = 0.8;
					
					this.m_ui.IconImage.skin="appRes/icon/chargeIcon/icon_"+l_revo.icon+".png";
					this.m_ui.IconImage.mouseEnabled = false;
					this.m_ui.IconImage.mouseThrough = true;
					this.m_ui.ItemNumText.text = l_revo.token;
					this.m_ui.AddNumText.text = l_revo.extra != 0 ? "+" + l_revo.extra : "";
				}
			}
		}
		
		
		private function showMeTheMoney():void 
		{
			
			
			if (GameSetting.isApp)
			{
				GlobalRoleDataManger.instance.ItemPayHandler(m_data);
			}
			else
			{
				WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,["US",32,m_data.id,1,235,1,"facebok"]);
			}
		}
		
		/**帮助小提示*/
		private function showInfoHandler():void 
		{
			var msg:String = GameLanguage.getLangByKey("L_A_56085");
			XTipManager.showTip(msg);
		}
		
		/**
		 * 初始化控件
		 */		
		override public function init():void{
			if(!m_ui){
				m_ui = new ReItemUI();
				this.addChild(m_ui);
				
				this.m_ui.dom_box.on(Event.CLICK, this, showMeTheMoney);
				//this.m_ui.btn_info.on(Event.CLICK, this, showInfoHandler);
			}
		}
		
		
	}
}