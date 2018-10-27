package game.global.data
{
	import game.common.ResourceManager;
	import game.global.GameConfigManager;
	import game.global.vo.ItemVo;


	/**
	 * DBItem
	 * author:huhaiming
	 * DBItem.as 2017-3-15 下午3:56:07
	 * version 1.0
	 *
	 */
	public class DBItem
	{
		/**配置常量-水*/
		public static const WATER:Number=1;
		/**配置常量-石头*/
		public static const STONE:Number=2;
		/**配置常量-钢材*/
		public static const STEEL:Number=3;
		/**配置常量-黄金*/
		public static const GOLD:Number=4;
		/**配置常量-食物*/
		public static const FOOD:Number=5;
		/**配置常量-贡献*/
		public static const CONTRIBUTE:Number=6;
		/**配置常量-基地互动奖牌*/
		public static const MEDAL:int=8;
		/**配置常量-基地互动奖牌*/
		public static const DB:int=9;
		/**配置常量-矿场点数*/
		public static const MINE_POINT:int=13;
		/**配置常量-PVP代币*/
		public static const PVP_TOKEN:int = 14;
		/**配置常量-面包*/
		public static const BREAD:Number=20;
		
		public static const PURPLE_CRYSTAL:int = 17;

		/**
		 * 军粮
		 */
		public static const ARMY_GROUP_FOOD:int=16;

		/***/
		public function DBItem()
		{


		}

		/**获取道具数据*/
		public static function getItemData(itemId:*):ItemVo
		{
			return GameConfigManager.items_dic[itemId];
		}

		/**计算价格*/
		public static function caculatePrice(itemId:Number, itemNum:Number):Number
		{
			return Math.ceil(getItemPrice(itemId) * itemNum);
		}

		private static var _priceDB:Object;

		/**获取道具价格*/
		public static function getItemPrice(itemId:Number):Number
		{
			return priceDB[itemId] ? priceDB[itemId].price : 0
		}

		private static function get priceDB():Object
		{
			if (!_priceDB)
			{
				_priceDB=ResourceManager.instance.getResByURL("config/item_price.json");
			}
			return _priceDB;
		}
	}
}
