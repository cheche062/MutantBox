package game.module.bossFight
{
	import MornUI.bossFight.RankInfoCellUI;
	import MornUI.bossFight.RankRewardInfoCellUI;
	
	import game.global.vo.worldBoss.BossRankPlayerInfoVo;
	
	import laya.ui.Box;
	
	public class RankInfoCell extends Box
	{
		private var m_ui:RankInfoCellUI;
		private var m_data:BossRankPlayerInfoVo;
		public function RankInfoCell(p_ui:RankInfoCellUI)
		{
			super();
			this.m_ui = p_ui;
			init();
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
//			if(m_data)
//			{
				initUI();
//			}
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			this.m_ui.RankText0.text=m_data ? String(m_data.rank) : "-";
			this.m_ui.RankText1.text=m_data ? String(m_data.name) : "-";
			this.m_ui.RankText2.text=m_data ? String(m_data.level) : "-";
			this.m_ui.RankText3.text=m_data ? m_data.progress + "%" : "-";
			this.m_ui.RankText4.text=m_data ? String(m_data.rounds) : "-";
			this.m_ui.MyIconImage.visible=false;
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new RankInfoCellUI();
				this.addChild(m_ui);
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy RankInfoCell");
			m_ui = null;
			m_data = null;
			
			super.destroy(destroyChild);
		} 
	}
}