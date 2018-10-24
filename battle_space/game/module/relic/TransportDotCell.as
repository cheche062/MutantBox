package game.module.relic
{
	import MornUI.relic.TransportDotCellUI;
	
	import game.global.util.TimeUtil;
	import game.global.vo.relic.EnemieVo;
	
	import laya.ui.Box;
	
	public class TransportDotCell extends Box
	{
		private var m_ui:TransportDotCellUI;
		private var m_data:EnemieVo;
		public function TransportDotCell(p_ui:TransportDotCellUI,p_data:EnemieVo)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		private function initUI():void
		{
			
			if(m_data.isSelf==false)
			{
				m_ui.DotImage.skin="relic/bg3.png";
				m_ui.TimeCell.visible=false;
				m_ui.TimeText.visible=false;
			}
			else
			{
				m_ui.DotImage.skin="relic/bg3_1.png";
				m_ui.TimeCell.visible=true;
				m_ui.TimeText.visible=true;
				m_ui.TimeText.text="";
			}
		}
		
		public function setTime(p_time:Number):void
		{
			m_ui.TimeText.text=TimeUtil.getTimeCountDownStr(p_time,false);	
		}
		
	}
}