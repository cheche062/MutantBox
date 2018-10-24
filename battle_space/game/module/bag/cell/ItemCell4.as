package game.module.bag.cell
{
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.vo.equip.EquipmentListVo;
	import game.module.equip.EquipTipsView;
	
	import laya.events.Event;
	
	public class ItemCell4 extends ItemCell
	{
		public function ItemCell4()
		{
			super();
		}
		
		protected override function showTipFun(e:Event):void
		{
			if(!_data)return ;
			
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[_data.iid];
			if(l_equipVo==null||l_equipVo==undefined)
			{
//				ItemTips.showTip(_data.iid);	
			}
			else
			{
				EquipTipsView.showTip(_data);
			}
		}
	}
}