/***
 *作者：罗维
 */
package game.module.fighting.adata
{
	public class frSoldierData
	{
		public var uid:Number;   //ID
		public var uMaxNum:Number;  //总数量
		public var uNum:Number;     //当前数量
		public var uLev:Number;   // 当前级别
		public var uExp:Number;  //当前经验
		public var addExp:Number ;  //增加经验
		
		public function frSoldierData()
		{
		}
		
		public function get death():Number{
			if(uMaxNum)
				return uMaxNum - uNum;
			return 0;
		}
	}
}