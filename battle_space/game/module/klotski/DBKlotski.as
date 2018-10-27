package game.module.klotski
{
	import game.common.ResourceManager;
	import game.global.vo.User;

	/**
	 * DBKlotski
	 * author:huhaiming
	 * DBKlotski.as 2018-2-6 下午5:52:35
	 * version 1.0
	 *
	 */
	public class DBKlotski
	{
		private static var _rewardData:Object;
		private static var _priceData:Object
		private static var _resetData:Object;
		public function DBKlotski()
		{
		}
		
		public static function getRewadData():Array{
			var lv:int = User.getInstance().level;
			for(var i:String in rewardData){
				if(rewardData[i].level_down <= lv && rewardData[i].level_up >= lv){
					return (rewardData[i].reward+"").split(";")
				}
			}
			return [];
		}
		
		public static function getDoublePrice():String{
			var lv:int = User.getInstance().level;
			for(var i:String in priceData){
				if(priceData[i].level_down <= lv && priceData[i].level_up >= lv){
					return priceData[i].price+""
				}
			}
			return "0=0";
		}
		
		/**重置价格*/
		public static function getResetPrice(resetTime:int):String{
			resetTime ++;
			var data:Object = ResourceManager.instance.getResByURL("config/ban_pick_reset.json");
			var tmp:Object;
			for(var i:String in data){
				tmp = data[i];
				if(tmp.down <= resetTime && tmp.up >= resetTime){
					return tmp.price;
				}
			}
			return "1=0";
		}
		
		/**刷新价格*/
		public static function getFreshPrice(freshTimes:int):String{
			freshTimes ++;
			var data:Object = ResourceManager.instance.getResByURL("config/ban_pick_price.json");
			var tmp:Object;
			for(var i:String in data){
				tmp = data[i];
				if(tmp.down <= freshTimes && tmp.up >= freshTimes){
					return tmp.price;
				}
			}
			return "1=0";
		}
		
		private static function get rewardData():Object{
			if(!_rewardData){
				_rewardData = ResourceManager.instance.getResByURL("config/ban_pick_passreward.json");
			}
			return _rewardData;
		}
		
		private static function get priceData():Object{
			if(!_priceData){
				_priceData = ResourceManager.instance.getResByURL("config/ban_pick_cardreward.json");
			}
			return _priceData;
		}
	}
}