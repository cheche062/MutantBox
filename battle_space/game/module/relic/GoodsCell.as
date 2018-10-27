package game.module.relic
{
	import MornUI.relic.CarrierCellUI;
	import MornUI.relic.GoodsCellUI;
	
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.bag.ItemData;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.TransportPlanInfoVo;
	import game.global.vo.relic.TransportPlanVo;
	import game.global.vo.relic.TransportVehicleVo;
	
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class GoodsCell extends Box
	{
		private var m_ui:GoodsCellUI;
		private var m_data:TransportPlanInfoVo;
		private var m_vo:TransportPlanVo;
		private var m_select:Boolean;
		private var m_vehicle:int;
		public function GoodsCell(p_ui:GoodsCellUI,p_data:TransportPlanInfoVo,p_vehicle:int)
		{
			super();
			m_select=false;
			m_ui=p_ui;
			m_data=p_data;
			m_vehicle=p_vehicle;
			init();
			initUI();
		}
		
		/**
		 *初始化 
		 * 
		 */		
		private function initUI():void
		{
			var l_vehicle:TransportVehicleVo;
			m_ui.CostLabText.text=GameLanguage.getLangByKey("L_A_34009");
			m_ui.TimeLabText.text=GameLanguage.getLangByKey("L_A_34010");
			m_ui.RewardLabText.text=GameLanguage.getLangByKey("L_A_34011");
			m_ui.CoolTimeText.text="";
			for (var i:int = 0; i < GameConfigManager.TransportVehicleList.length; i++) 
			{
				if(m_vehicle==GameConfigManager.TransportVehicleList[i].id)
				{
					l_vehicle=GameConfigManager.TransportVehicleList[i];
					m_ui.CoolTimeText.text="(-"+l_vehicle.reduce_time+"%)";
				}
			}
//			if(m_data.isFree==1)
//			{
//				m_ui.CostText.text=GameLanguage.getLangByKey("L_A_27");
//			}
//			else
//			{
				m_ui.CostText.text="x"+m_data.baseVo.getCostNum();
//			}
			m_ui.FoodsNameText.text=GameLanguage.getLangByKey(m_data.baseVo.name);
			if(l_vehicle!=null)
			{
				var l_time:Number=m_data.baseVo.time*(100-parseInt(l_vehicle.reduce_time))/100;
				m_ui.TimeText.text=TimeUtil.getTrainTimeStr(l_time);	
			}
			else
			{
				m_ui.TimeText.text=TimeUtil.getTrainTimeStr(m_data.baseVo.time);
			}
			
			var l_arr:Array=m_data.baseVo.cost.split("=");
			var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			m_ui.CostImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			m_ui.CostImage.name="CostImage_"+itemvo.id;
			var l_arr:Array=m_data.baseVo.getRewardList();
	
			m_ui.RewardList.itemRender=PlanRewardCell;
			m_ui.RewardList.hScrollBarSkin="";
			m_ui.RewardList.selectEnable = true;
			m_ui.RewardList.selectHandler=new Handler(this, onHeroSelect);
			m_ui.RewardList.array=l_arr;
			if(m_data.status==3)
			{
				selectType(true);
			}
			else
			{
				selectType(false);
				if(m_data.status==0)
				{
					m_ui.BuyBtn.text.text=GameLanguage.getLangByKey("L_A_34007");
				}
				else if(m_data.status==1)
				{
					m_ui.BuyBtn.text.text=GameLanguage.getLangByKey("L_A_34092");
				}
				else
				{
					m_ui.BuyBtn.visible=false;
					m_ui.SelectedText.text=GameLanguage.getLangByKey("L_A_34097");
					m_ui.SelectedText.visible=true;
				}
			}
		}
		
		private function onHeroSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			for (var i:int = 0; i < m_ui.RewardList.array.length; i++) 
			{
				var l_cell:PlanRewardCell=this.m_ui.RewardList.getCell(i) as PlanRewardCell;
				if(l_cell!=null)
				{
					l_cell.selected=false;
				}
			}
			var l_selectCell:PlanRewardCell=this.m_ui.RewardList.getCell(p_index) as PlanRewardCell;
			var l_data:ItemData=this.m_ui.RewardList.getItem(p_index);
			var itemvo:ItemVo=GameConfigManager.items_dic[l_data.iid];
			ItemTips.showTip(itemvo.id);
			
		}
		
		public function selectType(p_select:Boolean):void
		{
			m_select=p_select;
			if(m_select==true)
			{
				m_ui.PlanImage.skin="relic/bg1.png";
				m_ui.BuyBtn.visible=false;
				m_ui.SelectedText.visible=true;
				m_ui.SelectedText.text="Selected";
			}
			else
			{
				m_ui.PlanImage.skin="relic/bg1_1.png";
				m_ui.SelectedText.visible=false;
				m_ui.BuyBtn.visible=true;
				if(m_data.status==2)
				{
					m_ui.BuyBtn.visible=false;
					m_ui.SelectedText.text=GameLanguage.getLangByKey("L_A_34097");
					m_ui.SelectedText.visible=true;
				}
			}
		}
		
		public function setFreeNum(p_num:int):void
		{
			if(m_data.baseVo.type==1)
			{
				m_ui.FreeNumText.visible=true;
				m_ui.FreeNumText.text=p_num+"/"+GameConfigManager.transportParam.freePlanBuyTime;
			}
			else{
				m_ui.FreeNumText.visible=false;
			}
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new GoodsCellUI();
				this.addChild(m_ui);
			}
		}
	}
}