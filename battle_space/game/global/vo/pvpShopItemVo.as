package game.global.vo
{
	import game.module.bag.mgr.ItemManager;
	import game.module.pvp.PvpManager;

	public class pvpShopItemVo
	{
		public var id:Number = 0;
		public var item:String;
		public var num:Number = 0;
		public var cost:String;
		public var condition:Number = 0;
		public var lg:String;
		
		private var _showItems:Array;
		private var _showCosts:Array ;
		
		public function pvpShopItemVo()
		{
		}
		
		
		public function get showItems():Array
		{
			if(!_showItems)
			{
				_showItems = ItemManager.StringToReward(item);
			}
			return _showItems;
		}
		
		public function get showCosts():Array
		{
			if(!_showCosts)
			{
				_showCosts = ItemManager.StringToReward(cost);
			}
			return _showCosts;
		}
		
		public function get state():Number{
			var levelVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
				Number(PvpManager.intance.userInfo.integral)
			);
			if(!levelVo || levelVo.id < condition) return -2;  //段位不够
			if(PvpManager.intance.getShopCountBySid(id) >= num) return -1;  //次数不够
			if(showCosts[0].inum > PvpManager.intance.tokenNumber) return 0; //积分不够
			return 1;
			
		}
	}
}