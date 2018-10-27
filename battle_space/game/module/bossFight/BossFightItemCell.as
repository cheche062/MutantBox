package game.module.bossFight
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	
	public class BossFightItemCell extends ItemCell
	{
		public function BossFightItemCell()
		{
			super();
		}
		
		override public function set data(value:ItemData):void{
			//			selectEff;
			super.data = value;
			
			initUI();
		}
		
		private function initUI():void
		{
			if(data!=null)
			{
				if(data.inum<=0)
				{
					if(data.iid==60003)
					{
						_itemIcon.skin="bossFight/icon_3.png"
					}
					else if(data.iid==60004)
					{
						_itemIcon.skin="bossFight/icon_5.png"
					}
					else
					{
						_itemIcon.skin="bossFight/icon_4.png"
					}
					_itemIcon.alpha=0.5;
				}
				else
				{
					_itemIcon.skin="appRes/icon/itemIcon/"+_data.vo.icon+".png";
					_itemIcon.alpha=1;
				}
			}
			
			
		}
		
	}
}