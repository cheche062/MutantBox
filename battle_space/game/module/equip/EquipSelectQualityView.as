package game.module.equip
{
	import MornUI.equip.EquipSelectQualityViewUI;
	
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class EquipSelectQualityView extends Box
	{
		private var m_ui:EquipSelectQualityViewUI;
		
		public function EquipSelectQualityView(p_ui:EquipSelectQualityViewUI)
		{
			super();
			m_ui=p_ui;
			initUI();
		}
		
		private function initUI():void
		{
			for (var i:int = 0; i < 6; i++) 
			{
				var l_image:Image=this.m_ui.getChildByName("GouImage"+i) as Image
				l_image.visible=false;
			}
		}
		
		
	}
}