package game.module.bag.cell
{
	import game.common.XUtils;

	public class RewardCellMin1 extends RewardCellMin
	{
		public function RewardCellMin1()
		{
			super();
		}
		
		public override function bindNum():void{
			_itemNumLal.text = "x" + XUtils.formatResWith(data.inum);
		}
	}
}