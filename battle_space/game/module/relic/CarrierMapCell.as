package game.module.relic
{
	import MornUI.relic.CarrierMapCellUI;
	
	import game.global.vo.relic.EnemieVo;
	
	import laya.ui.Box;
	
	public class CarrierMapCell extends Box
	{
		private var m_ui:CarrierMapCellUI;
		private var m_data:EnemieVo;
		public function CarrierMapCell(p_ui:CarrierMapCellUI,p_data:EnemieVo)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		private function initUI():void
		{
			if(m_data.isSelf==true)
			{
				this.m_ui.CarrierImage.skin="common/plan_round_1.png";	
				this.m_ui.CarImage.skin="relic/icon_4.png";
			}
			else
			{
				this.m_ui.CarrierImage.skin="common/plan_round_2.png";
				this.m_ui.CarImage.skin="relic/icon_2.png";
			}
		}
		
		
		
	}
}