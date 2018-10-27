package game.global.vo 
{
	import game.common.ResourceManager;
	import game.global.GameConfigManager;

	/**
	 * ...
	 * @author ...
	 */
	public class VIPVo 
	{
		
		public var level:int = 0;
		//public var amount:Number = 0;
		public var combat_spped_up:Number = 0;
		public var train_speed_up:Number = 0;
		public var radar_refresh:Number = 0;
		public var build_speed_up:Number = 0;
		public var radar_fight:Number = 0;
		public var arena:Number = 0;
		public var team_hunting:Number = 0;
		public var check_in_rewards:Number = 0;
		public var reward_pack:String = "";
		public var vip_des:String = "";
		public var stage_wipe:int=0;
		public var elite_wipe:int=0;
		public var old_price:String;
		public var new_price:String;
		
		/***/
		private static var _data:Object;
		/**VIP礼包*/
		private static var _giftData:Object;
		/**商店*/
		private static  var _shopData:Object;
		/**最大等级*/
		public static const MAX_LV:int = 12;
		public function VIPVo() 
		{
			
		}
		
		public function get amount():Number{
			return data[level]?data[level]["amount"]:0;
		}
		
		/**获取VIP礼包信息*/
		public static function getGiftInfo(vipLv:int):Object{
			return giftData[vipLv];
		}
		
		/**获取 商店信息*/
		public static function getShopList(vipLv:int):Array{
			var arr:Array = [];
			for(var i:int=1; i<999; i++){
				if(!shopData[i]){
					break;
				}else{
					arr.push(shopData[i]);
				}
			}
			return arr;
		}
		
		/**获取VIP信息*/
		public static function getVipInfo():VIPVo{
			return GameConfigManager.vip_info[User.getInstance().VIP_LV];
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/vip_config.json");
			}
			return _data;
		}
		
		private static function get giftData():Object{
			if(!_giftData){
				_giftData = ResourceManager.instance.getResByURL("config/vip_gift.json");
			}
			return _giftData
		}
		
		private static function get shopData():Object{
			if(!_shopData){
				_shopData = ResourceManager.instance.getResByURL("config/vip_shop.json");
			}
			return _shopData;
		}
		
	}

}