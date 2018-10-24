package game.module.equip
{
	import game.common.UIRegisteredMgr;
	import MornUI.equip.WashBagViewUI;
	
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.vo.equip.EquipmentBaseVo;
	
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class WashBagView extends Box
	{
		private var m_ui:WashBagViewUI;
		private var m_selectType:int=0;
		private var m_data:EquipmentBaseVo;
		private var m_heroCellList:Array=[];
		public function WashBagView(p_ui:WashBagViewUI,p_data:EquipmentBaseVo)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		private function initUI():void
		{
			m_selectType=0;
			m_heroCellList=new Array();
			update(m_data);
			setType(1)
			
			UIRegisteredMgr.AddUI(m_ui.SoldierList, "EquipBagList");
		}
		
		public function update(p_data:EquipmentBaseVo):void
		{
			m_data=p_data;
			var l_arr:Array=BagManager.instance.getItemListByType([10],[1,2,3,4,5,6]);
			l_arr=finishEquipList(l_arr);
			m_ui.SoldierList.itemRender=EquipBagCell;
			m_ui.SoldierList.vScrollBarSkin="";
			m_ui.SoldierList.selectEnable=true;
			m_ui.SoldierList.array=l_arr;
			m_ui.HeroPanel.selected=true;
			m_ui.HeroPanel.vScrollBarSkin="";
			createPanel();
		}
		
		private function finishEquipList(p_arr:Array):Array
		{
			var max:int=4*5;
			var l_addNum:int=0;
			if(p_arr.length<max)
			{
				l_addNum=max-p_arr.length;
			}
			else
			{
				var l_line:int=p_arr.length%4;
				l_addNum=4-l_line;
			}
			
			for(var i:int=0;i<l_addNum;i++)
			{
				p_arr.push(null)
			}
			return p_arr;
		}
		
		
		public function createPanel():void
		{
			var maxy:int=0;
			
			for (var i:int = 0; i < m_data.heroList.length; i++) 
			{
				var l_cell:EquipHeroCell;
				if((m_heroCellList.length)>i)
				{
					l_cell=m_heroCellList[i];
				}
				else
				{
					l_cell=new EquipHeroCell();
					m_ui.HeroPanel.addChild(l_cell);
					l_cell.dataSource=m_data.heroList[i];
					m_heroCellList.push(l_cell);
				}
				l_cell.updateInfo(m_data.heroList[i])
				l_cell.y = maxy;
				if (i == 0)
				{
					UIRegisteredMgr.AddUI(l_cell, "HeroList");
					UIRegisteredMgr.AddUI(l_cell.m_ui.EquipCell0, "EquipCell");
					
				}
				if(l_cell.isClick==true)
				{
					maxy+=105;	
				}
				else
				{
					maxy+=265;	
				}
			}
			m_ui.HeroPanel.refresh();
		}
		
		public function selectHeroEquipCell(p_heroid:int,p_local:int):void
		{
			for (var i:int = 0; i < m_heroCellList.length; i++) 
			{
				var l_cell:EquipHeroCell=m_heroCellList[i];
				if(l_cell.heroData.unitId==p_heroid)
				{
					l_cell.setSelectEquipCell(p_local);
					
				}
				else
				{
					l_cell.setSelectEquipCell(-1);
				}
			}
			
		}
		
		
		public function setType(p_type:int):void
		{
			if(p_type!=m_selectType)
			{
				m_selectType=p_type;
				switch(m_selectType)
				{
					case 1:
					{
						this.m_ui.SoldierBtn.selected=false;
						this.m_ui.HeroBtn.selected=true;
						m_ui.SoldierList.visible=false;
//						m_ui.HeroList.visible=false;
						m_ui.HeroPanel.visible=true;
						break;
					}
					case 2:
					{
						this.m_ui.SoldierBtn.selected=true;
						this.m_ui.HeroBtn.selected=false;
						m_ui.SoldierList.visible=true;
//						m_ui.HeroList.visible=false;
						m_ui.HeroPanel.visible=false;
						break;
					}
				}
			}
		}
		
	}
}