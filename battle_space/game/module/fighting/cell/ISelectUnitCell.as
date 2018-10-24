package game.module.fighting.cell
{
	import game.module.fighting.adata.ArmyData;

	public interface ISelectUnitCell
	{
		function get data():ArmyData;
		
		function set data(value:ArmyData):void;
		
		function getEnabled(showError:Boolean = false):Boolean;
	}
}