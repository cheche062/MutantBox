package game.module.friend
{
	import MornUI.friend.MailInfoViewUI;
	
	import game.global.data.bag.ItemCell;
	import game.global.vo.friend.MailInfoVo;
	
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class MailInfoView extends Box
	{
		private var m_ui:MailInfoViewUI;
		private var m_data:MailInfoVo;
		
		public function MailInfoView(p_ui:MailInfoViewUI,p_data:MailInfoVo)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		/**初始化ui数据*/
		private function initUI():void
		{
			this.m_ui.HeadLineText.text=m_data.title;
			this.m_ui.MailText.text=m_data.content;
			
			m_ui.dom_MailText_box.height = m_ui.MailText.height; 
			
			this.m_ui.TextPanel.selected=true;
			if(m_data.getItemList().length>0)
			{
				this.m_ui.ItemList.visible=true;
				this.m_ui.ItemList.itemRender=ItemCell;
//				this.m_ui.ItemList.selectEnable=true;
				this.m_ui.ItemList.hScrollBarSkin="";
				this.m_ui.ItemList.array=m_data.getItemList();
				this.m_ui.ItemList.renderHandler = new Handler(this, updateItem);
			}
			else
			{
				this.m_ui.ItemList.visible=false;
			}
			if(m_data.state==2 && m_data.getItemList().length>0)
			{
				this.m_ui.ReceiveBtn.visible=true;
				m_ui.ReceiveText.visible=false;
			}
			else
			{
				this.m_ui.ReceiveBtn.visible=false;
			}
			if(m_data.state==3)
			{
				m_ui.ReceiveText.visible=true;
			}
		}
		
		/**
		 * 判断是否要有遮罩
		 */
		private function updateItem(p_cell:ItemCell,p_index:int):void
		{
			// TODO Auto Generated method stub
			if(m_data.state==3)
			{
				p_cell.gray=true;
			}
			else
			{
				p_cell.gray=false;
			}
		}
	}
}