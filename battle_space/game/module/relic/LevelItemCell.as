package game.module.relic
{
	import game.common.XUtils;
	import game.global.data.bag.ItemCell;
	
	public class LevelItemCell extends ItemCell
	{
		public function LevelItemCell()
		{
			super();
		}
		
		public override function bindNum():void{
			_itemNumLal.text = data.inum < 1 ? "" : String(XUtils.formatResWith(data.inum));
			if(data.inum<=0)
			{
				_itemIcon.gray=true;
			}
			else
			{
				_itemIcon.gray=false;
			}
			//			_itemNumLal.text = 9999;
		}
		
	}
}