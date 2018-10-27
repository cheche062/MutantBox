package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.equip.WashPropertyCellUI;
	
	import laya.ui.Box;
	import game.global.vo.equip.AttVo;
	
	public class WashPropertyCell extends Box
	{
		private var m_ui:WashPropertyCellUI;
		private var m_data:AttVo;
		
		public function WashPropertyCell(p_ui:WashPropertyCellUI)
		{
			super();
			m_ui=p_ui;
			init();
		}
		
		private function initUI():void
		{
			m_ui.PropertyImage.skin="common/icons/"+m_data.name+".png";
			m_ui.PropertyTextg.text=m_data.num+"/"+m_data.max;
			m_ui.NowPropertyBat.value=m_data.num/m_data.max;
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			if(m_data!=null)
			{
				initUI();
			}
			
		}
		
		public function setLock():AttVo
		{
			m_ui.LockBtn.selected=!m_ui.LockBtn.selected;
			if(m_ui.LockBtn.selected==true)
			{
				return m_data;
			}
			return null;
		}
		
		
		public function relaseLockType():void
		{
			m_ui.LockBtn.selected=false;
		}
		
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new WashPropertyCellUI();
				this.addChild(m_ui);
			}
		}
	}
}