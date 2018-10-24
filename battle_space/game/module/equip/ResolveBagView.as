package game.module.equip
{
	import MornUI.equip.ResolveBagViewUI;
	
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	
	import laya.ui.Box;
	
	public class ResolveBagView extends Box
	{
		private var m_ui:ResolveBagViewUI;
		
		public function ResolveBagView(p_ui:ResolveBagViewUI)
		{
			super();
			m_ui=p_ui;
			initUI();
		}
		
		private function initUI():void
		{
			var l_arr:Array=BagManager.instance.getItemListByType([10],[1,2,3,4,5,6]);
			m_ui.BagItemList.itemRender=EquipBagCell;
			m_ui.BagItemList.vScrollBarSkin="";
			m_ui.BagItemList.selectEnable=true;
			l_arr=finishEquipList(l_arr);
			m_ui.BagItemList.array=l_arr;
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
		
		
		/**
		 * 刷新列表
		 */
		public function updateList(p_data:Array):void
		{
			m_ui.BagItemList.array=p_data;
			m_ui.BagItemList.refresh();
		}
		
	}
}