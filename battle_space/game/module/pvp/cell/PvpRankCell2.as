package game.module.pvp.cell
{
	import game.global.GlobalRoleDataManger;

	public class PvpRankCell2 extends PvpRankCell
	{
		public function PvpRankCell2()
		{
			super();
		}
		
		protected override function get cellType():Number{
			return 2;
		}
	}
}