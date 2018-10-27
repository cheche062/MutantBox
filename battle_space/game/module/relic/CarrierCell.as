package game.module.relic
{
	import laya.ui.Image;
	import MornUI.friend.FriendRequestCellUI;
	import MornUI.relic.CarrierCellUI;
	
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.TransportVehicleInfo;
	import game.global.vo.relic.TransportVehicleVo;
	
	import laya.ui.Box;
	
	public class CarrierCell extends Box
	{
		private var m_ui:CarrierCellUI;
		private var m_data:TransportVehicleInfo;
		private var m_vo:TransportVehicleVo;
		
		public function CarrierCell(p_ui:CarrierCellUI)
		{
			super();
			m_ui=p_ui;
			init();			
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
		 * 初始化
		 */
		private function initUI():void
		{
			this.m_ui.SelectBtn.name="SelectBtn_"+m_data.baseVo.id;
			this.m_ui.CarrierImage.skin="relic/"+m_data.baseVo.tupian+".png";
			if(m_data.status==2)
			{
				this.m_ui.SelectBtn.skin="common/btn_5.png";
				this.m_ui.SelectBtn.text.text=GameLanguage.getLangByKey("L_A_34093");
				this.m_ui.SelectBtn.visible=false;
				this.m_ui.SelectedText.text=GameLanguage.getLangByKey("L_A_34093");
				this.m_ui.SelectedText.visible=true;
				this.m_ui.ItemImage.visible=false;
			}
			else if(m_data.status==1)
			{
				this.m_ui.SelectBtn.skin="common/btn_6.png";
				this.m_ui.SelectBtn.text.text=GameLanguage.getLangByKey("L_A_34092");
				this.m_ui.SelectBtn.selected=false;
				this.m_ui.ItemImage.visible=false;
				this.m_ui.SelectBtn.visible=true;
				this.m_ui.SelectedText.visible=false;
			}
			else if(m_data.status==0)
			{
				this.m_ui.SelectBtn.skin="common/btn_6.png";
				var l_arr:Array=m_data.baseVo.price.split("=");
				var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[0]];
				this.m_ui.ItemImage.visible=true;
				this.m_ui.ItemImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
				if(m_data.baseVo.getPrice()==0)
				{
					this.m_ui.ItemImage.visible=false;
					this.m_ui.SelectBtn.text.text=GameLanguage.getLangByKey("L_A_27");
				}
				else
				{
					this.m_ui.SelectBtn.text.text=m_data.baseVo.getPrice();
				}
				this.m_ui.SelectBtn.selected=false;
				this.m_ui.SelectBtn.visible=true;
				this.m_ui.SelectedText.visible=false;
			}
			m_ui.CarrierNameText.text=GameLanguage.getLangByKey(m_data.baseVo.name);
			m_ui.ProtectText.text=m_data.baseVo.rate+"%";
			
			m_ui.PopulationText.text=m_data.baseVo.members;
			m_ui.TimeText.text=m_data.baseVo.reduce_time+"%";
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new CarrierCellUI();
				this.addChild(m_ui);
			}
		}
	}
}