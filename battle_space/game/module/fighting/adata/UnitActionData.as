/***
 *作者：罗维
 */
package game.module.fighting.adata
{
	import game.global.fighting.BaseUnit;
	import game.module.fighting.cell.FightingTile;
	
	import laya.utils.Pool;

	public class UnitActionData
	{
		public static const UNITACTIONDATA_MAIN_TYPE:int = 1;  //主动画
		
		public var type:int;
		public var target:String;
		public var actionList:Array;
		
		public static const UNITACTIONDATA_SIGN:String = "UNITACTIONDATA_SIGN";
		
		public function UnitActionData()
		{
		}
		
		public static function create(_target:String):UnitActionData
		{
			var v:UnitActionData = Pool.getItemByClass(UNITACTIONDATA_SIGN,UnitActionData);
			v.target = _target;
			v.actionList = [];
			v.type = 0;
			return v;
		}
		
		public function clear():void
		{
			this.target = null;
			this.actionList = null;
			Pool.recover(UNITACTIONDATA_SIGN,this);
		}
	}
}