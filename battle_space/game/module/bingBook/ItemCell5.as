package game.module.bingBook
{
	import game.common.XUtils;
	import game.global.data.bag.ItemCell3;
	
	public class ItemCell5 extends ItemCell3
	{
		public function ItemCell5()
		{
			super();
		}
		public override function bindNum():void
		{
			if(data.iid == 1)
			{
				_itemNumLal.text = data.inum <  1 ? "0" : String(XUtils.formatResWith(data.inum));
			}else
			{
				_itemNumLal.text = "";
			}
//		
		}
	}
}