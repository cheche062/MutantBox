package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.equip.WashPropertyChangeUI;
	
	import game.global.vo.equip.AttVo;
	
	import laya.ui.Box;
	
	public class WashPropertyChange extends Box
	{
		private var m_ui:WashPropertyChangeUI;
		private var m_data:AttVo;
		public function WashPropertyChange(p_ui:WashPropertyChangeUI)
		{
			super();
			init();
		}
		
		private function initUI():void
		{
			this.m_ui.ArrowImage.visible=false;
			var l_color:String="#ffffff";
			if(m_data.num>m_data.change)
			{
				this.m_ui.ArrowImage.skin="equip/arrow_down.png";
				//l_color="#ff0000"
			}
			else if(m_data.num<m_data.change)
			{
				this.m_ui.ArrowImage.skin="equip/arrow_up.png";
				//l_color="#00ff70"
			}
			else
			{
				this.m_ui.ArrowImage.visible=false;
			}
			m_ui.PropertyImage.skin="common/icons/"+m_data.name+".png";
			m_ui.PropertyTextg.color=l_color;
			m_ui.PropertyTextg.text=m_data.change+"/"+m_data.max;
			m_ui.NowPropertyBat.value=m_data.num/m_data.max;
			m_ui.ChangeImage.visible=false;
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
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new WashPropertyChangeUI();
				this.addChild(m_ui);
			}
		}
	}
}