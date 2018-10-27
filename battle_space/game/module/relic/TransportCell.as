package game.module.relic
{
	import MornUI.relic.TransportCellUI;
	
	import game.global.GameConfigManager;
	import game.global.vo.relic.EnemieVo;
	import game.global.vo.relic.TransportPlanVo;
	
	import laya.ui.Box;
	
	public class TransportCell extends Box
	{
		private var m_ui:TransportCellUI;
		private var m_data:EnemieVo;
		public function TransportCell(p_ui:TransportCellUI,p_data:EnemieVo)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		private function initUI():void
		{
			var l_planVo:TransportPlanVo;
			for (var i:int = 0; i < GameConfigManager.TransportPlanList.length; i++) 
			{
				l_planVo=GameConfigManager.TransportPlanList[i];
				if(l_planVo.id==m_data.Plan)
				{
//					m_ui.PlanText.text=l_planVo.name;
					break;	
				}
			}
			if(m_data.isSelf==false)
			{
				m_ui.TransportImage.skin="common/plan_round_e.png";
				m_ui.ItemImage.skin="common/icon_1.png";
			}
			else
			{
				m_ui.TransportImage.skin="common/plan_round_self.png";
				m_ui.ItemImage.skin="common/icon_3.png";
			}
		}
	}
}