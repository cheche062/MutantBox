package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.equip.WashFightingCellUI;
	
	import game.global.GameLanguage;
	import game.global.vo.equip.WashFightVo;
	
	import laya.ui.Box;

	public class WashFightingCell extends Box
	{
		private var m_ui:WashFightingCellUI;
		private var m_data:WashFightVo;
		public function WashFightingCell(p_ui:WashFightingCellUI,p_data:WashFightVo)
		{
			m_ui=p_ui;
			m_data=p_data;
			init();
			initUI();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
		}
		
		private function initUI():void
		{
			var l_color:String="#ffffff";
			m_ui.FightNameText.text=GameLanguage.getLangByKey("L_A_48001");
			if(m_data.change==0)
			{
				m_ui.ArrowImage.visible=false;
				m_ui.FightingText.color="#ffffff";
			}
			else
			{
				m_ui.ArrowImage.visible=true;
				if(m_data.now<m_data.change)
				{
					this.m_ui.ArrowImage.skin="equip/arrow_down.png";
					l_color="#ff0000"
				}
				else if(m_data.now>m_data.change)
				{
					this.m_ui.ArrowImage.skin="equip/arrow_up.png";
					l_color="#00ff70"
				}
				m_ui.FightingText.color=l_color;
			}
			m_ui.FightingText.text=m_data.now;
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new WashFightingCellUI();
				this.addChild(m_ui);
			}
		}
	}
}