package game.global.data
{
	import game.common.ResourceManager;
	import game.global.vo.User;

	/**
	 * DBInvasion
	 * author:huhaiming
	 * DBInvasion.as 2017-4-24 下午5:00:35
	 * version 1.0
	 *
	 */
	public class DBInvasion
	{
		private static var _matchPriceData:Object;
		private static var _changePriceData:Object;
		public function DBInvasion()
		{
		}
		
		/**获取购买次数的价格*/
		public static function getBuyPrice(times:int):String{
			times = times +1;
			var tmp:Object;
			var bLv:int = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT)
			for(var i:String in matchPriceData){
				tmp = matchPriceData[i];
				if(bLv == tmp.level && times >= tmp.down && times <= tmp.up){
					return tmp.price
				}
			}
			return "";
		}
		
		/***/
		public static function getFreeBuyTime():Number{
			var time:Number = 999;
			var tmp:Object;
			for(var i:String in matchPriceData){
				tmp = matchPriceData[i];
				time = Math.min(tmp.down,time);
			}
			return time-1;
		}
		
		/**获取更换对手的价格比例*/
		public static function getChangePriceRate(times:int):Number{
			times = times +1;
			var tmp:Object;
			for(var i:String in changePriceData){
				tmp = changePriceData[i];
				if(times >= tmp.down  && times <= tmp.up){
					return (tmp.price);
				}
			}
			return 1;
		}
		
		/***/
		public static function getFreeChangeTime():Number{
			var time:Number = 999;
			var tmp:Object;
			for(var i:String in changePriceData){
				tmp = changePriceData[i];
				time = Math.min(tmp.down,time);
			}
			return time-1;
		}
		
		private static function get matchPriceData():Object{
			if(!_matchPriceData){
				_matchPriceData = ResourceManager.instance.getResByURL("config/base_num.json");
			}
			return _matchPriceData;
		}
		
		private static function get changePriceData():Object{
			if(!_changePriceData){
				_changePriceData = ResourceManager.instance.getResByURL("config/base_buy2.json");
			}
			return _changePriceData;
		}
	}
}