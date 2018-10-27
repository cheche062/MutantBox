package game.module.chargeView
{
	import MornUI.fackBookChange.PayChannelItemUI;
	
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.event.WebPayEvent;
	import game.global.vo.facebookPay.PayWayVo;
	
	import laya.events.Event;
	import laya.ui.Box;
	
	public class PayChannelItem extends Box
	{
		private var m_data:PayWayVo;
		private var m_ui:PayChannelItemUI;
		
		public function PayChannelItem()
		{
			super();
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(value!=null)
			{
				m_data=value;
				initUI();
			}
		}
		
		private function initUI():void
		{
			if(m_data.img==null)
			{
				m_ui.PayImage.skin=m_data.img_url;
			}
			else
			{
				m_ui.PayImage.skin=m_data.img;
			}
			if(m_data.img==null&&m_data.img_url==null)
			{
				m_ui.PayImage.skin="fackBookChange/facebook.png";
			}
			m_ui.PayText.text=m_data.pay_way;
		}
		
		public function setSelected(value:Boolean):void
		{
			this.selected = value;
			if(this.selected==true)
			{
				m_ui.bgImage.skin="fackBookChange/bg1_1.png";
				
			}
			else
			{
				m_ui.bgImage.skin="fackBookChange/bg1.png";
			}
		}

		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new PayChannelItemUI();
				this.addChild(m_ui);
			}
		}
	}
}