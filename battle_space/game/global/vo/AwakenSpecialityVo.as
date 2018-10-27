package game.global.vo
{
	import game.module.bag.mgr.ItemManager;

	public class AwakenSpecialityVo
	{
		/**特性等级*/
		public var s_level:Number = 0;
		/**单位等级*/
		public var u_level:Number = 0;
		public var cost:String ;
		
		public function AwakenSpecialityVo()
		{
			
		}
		
		private var _costAr:Array;
		public function get costAr():Array
		{
			if(!_costAr)
			{
				_costAr = ItemManager.StringToReward(cost);
			}
			return _costAr;
		}
	}
}