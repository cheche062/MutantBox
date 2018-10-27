package game.module.relic
{
	import MornUI.relic.LevelUpCellUI;
	import MornUI.relic.PlanRewardCellUI;
	
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	
	import laya.ui.Box;
	
	public class PlanRewardCell extends Box
	{
		private var m_ui:PlanRewardCellUI;
		private var m_data:ItemData;
		public function PlanRewardCell()
		{
			super();
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			if(m_data)
			{
				initUI();
			}
		}
		
		
		private function initUI():void
		{
			var itemvo:ItemVo=GameConfigManager.items_dic[m_data.iid];
			m_ui.RewardImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			m_ui.RewardImage.name="RewardImage_"+itemvo.id;
			m_ui.RewardText.text="x"+m_data.inum;
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new PlanRewardCellUI();
				this.addChild(m_ui);
			}
		}
		
	}
}