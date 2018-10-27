package game.module.equip
{
	import MornUI.equip.ResolveInfoViewUI;
	
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.vo.equip.EquipmentIntensifyVo;
	import game.global.vo.equip.EquipmentListVo;
	
	import laya.ui.Box;
	
	public class ResolveInfoView extends Box
	{
		private var m_ui:ResolveInfoViewUI;
		private var m_data:Array;
		private var m_rewardData:Array;
		public function ResolveInfoView(p_ui:ResolveInfoViewUI,p_data:Array)
		{
			super();
			
			m_ui=p_ui;
			m_data=p_data
			initUI();
		}
		/**
		 * 初始化
		 */
		private function initUI():void
		{
			m_ui.ResolveItemCellList.itemRender=EquipBagCell;
			m_ui.ResolveItemCellList.vScrollBarSkin="";
			m_ui.ResolveItemCellList.selectEnable=true;
			m_data=clearUpEquipList(m_data);
			m_data=finishEquipList(m_data);
			m_ui.ResolveItemCellList.array=m_data;
			m_ui.RewardList.visible=false;
		}
		/**
		 *整理装备分解 
		 * @param p_arr
		 * @return 
		 * 
		 */		
		private function clearUpEquipList(p_arr:Array):Array
		{
			var l_arr:Array=new Array();
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_arr[i]!=null)
				{
					l_arr.push(p_arr[i]);
				}
			}
			return l_arr;
		}
		
		/**
		 * 
		 * @param p_arr
		 * @return 
		 * 
		 */		
		private function finishEquipList(p_arr:Array):Array
		{
			var max:int=6*3;
			var l_addNum:int=0;
			if(p_arr.length<max)
			{
				l_addNum=max-p_arr.length;
			}
			else
			{
				var l_line:int=p_arr.length%6;
				l_addNum=6-l_line;
			}
			
			for(var i:int=0;i<l_addNum;i++)
			{
				p_arr.push(null)
			}
			return p_arr;
		}
		
		
		
		
		/**
		 * 刷新列表
		 */
		public function updateList(p_data:Array):void
		{
			m_data=p_data;
			m_ui.ResolveItemCellList.selectEnable=true;
			m_data=clearUpEquipList(m_data);
			m_data=finishEquipList(m_data);
			m_ui.ResolveItemCellList.array=m_data;
			m_ui.ResolveItemCellList.refresh();
			getRewardList();
		}
		
		
		private function getRewardList():void
		{
			var l_arr:Array=new Array();
			for (var i:int = 0; i < m_data.length; i++) 
			{
				
				if(m_data[i]!=null)
				{
					var l_vo:EquipmentListVo=GameConfigManager.EquipmentList[m_data[i].iid];
					var level:int=0;
					if(m_data[i].exPro.strong_level==undefined)
					{
						level=0;
					}
					else
					{
						level=m_data[i].exPro.strong_level;
					}
					var l_equipstr:EquipmentIntensifyVo=getEquipStringInfo(m_data[i].iid,level);
					var baseArr:Array=new Array();
					var strongArr:Array=new Array();
					strongArr=l_equipstr.getResolve();
					baseArr=l_vo.getResolve();
					for (var j:int = 0; j < baseArr.length; j++) 
					{
						l_arr=combineReward(l_arr,baseArr[j]);
					}
					for (var j:int = 0; j < strongArr.length; j++) 
					{
						l_arr=combineReward(l_arr,strongArr[j]);
					}
				}
			}
			setReward(l_arr);
		}
	
		
		private function combineReward(p_arr:Array,p_additem:ItemData):Array
		{
			if(p_arr.length<=0)
			{
				p_arr.push(p_additem);
				return p_arr;
			}
			var ishas:Boolean=false;
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_additem.iid==p_arr[i].iid)
				{
					ishas=true;
					p_arr[i].inum=parseInt(p_arr[i].inum)+parseInt(p_additem.inum);	
				}
			}
			if(ishas==false)
			{
				p_arr.push(p_additem);
			}
			return p_arr;
		}

		private function getEquipStringInfo(p_id:int,p_level:int):EquipmentIntensifyVo
		{
			var l_vo:EquipmentIntensifyVo;		
			var l_equipvo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentIntensifyList.length; i++) 
			{
				var l_vo:EquipmentIntensifyVo= GameConfigManager.EquipmentIntensifyList[i];
				if(l_vo.node_id==l_equipvo.streng_id && l_vo.level==p_level)
				{
					return l_vo;
				}
			}
			return null;
		}

		/**
		 * 奖励
		 */
		public function setReward(p_data:Array):void
		{
			if(p_data!=null)
			{
				m_ui.RewardList.visible=true;
				m_ui.RewardList.itemRender=ItemCell;
				m_ui.RewardList.array=p_data;
				m_ui.ResolveItemCellList.refresh();
			}
			else
			{
				m_ui.RewardList.visible=false;
			}
		}
		
		
		
	}
}