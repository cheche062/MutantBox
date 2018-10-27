package game.module.equip
{
	import MornUI.equip.ResolveBagViewUI;
	import MornUI.equip.ResolveRewardViewUI;
	
	import game.global.GameLanguage;
	import game.global.data.bag.ItemCell;
	
	import laya.ui.Box;
	
	public class ResolveRewardView extends Box
	{
		private var m_ui:ResolveRewardViewUI;
		private var m_data:Array;
		public function ResolveRewardView(p_data:Array,p_ui:ResolveRewardViewUI)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		private function initUI():void
		{
			this.m_ui.TitleText.text=GameLanguage.getLangByKey("L_A_48024");
			this.m_ui.ItemList.itemRender=ItemCell;
			this.m_ui.ItemList.array=m_data;
		}
		
	}
}