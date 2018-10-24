package game.global.data
{
	import game.common.ResourceManager;
	import game.global.GameLanguage;
	import game.global.vo.User;

	/**
	 * DBStore 商店源数据
	 * author:huhaiming
	 * DBStore.as 2017-4-17 上午10:15:24
	 * version 1.0
	 *
	 */
	public class DBStore
	{
		private static var _storeDB:Object;
		private static var _itemDB:Object;
		/**当前的的商店列表*/
		public static var SHOPIDS:Array = [];
		public function DBStore()
		{
		}
		
		public static function getTypeList():Array{
			var arr:Array = [];
			SHOPIDS = [];
			for(var i:String in storeDB){
				if(User.getInstance().level >= storeDB[i].level_open && storeDB[i].open == 1){
					//折扣商店不属于现在的通用商店规则，故先直接替换标签
					if(storeDB[i].name == 'L_A_20500'){
						storeDB[i].name ='L_A_19211';
					}
					arr.push(GameLanguage.getLangByKey(storeDB[i].name));
					SHOPIDS.push(storeDB[i].id);
				}
			}
			return arr
		}
		
		/**根据商店类型获取商店信息*/
		public static function getShopInfo(type:int):Object{
			return storeDB[type];
		}
		
		/**是否可以刷新*/
		public static function getCanFresh(type:int):Boolean{
			return parseInt(storeDB[type]["switch"]) == 1;
		}
		
		/**获取道具信息*/
		public static function getItemInfo(itemId:*, itemType:*):Object{
			var info:Object = getShopInfo(itemType);
			var src:Object  = _itemDB[info["type"]];
			return src ? src[itemId] : {};
		}
		
		/**获取刷新货币*/
		public static function getRefreshPrice(time:Number):Number{
			if(time< 3){
				return 10;
			}else if(time <5){
				return 11
			}
			return 12;
		}
		
		private static function get storeDB():Object{
			if(!_storeDB){
				_storeDB = ResourceManager.instance.getResByURL("config/shop_type.json");
				_itemDB = {};
				_itemDB["shop_jdhd"] = ResourceManager.instance.getResByURL("config/shop_jdhd.json");
				_itemDB["shop_test"] = ResourceManager.instance.getResByURL("config/shop_test.json");
				_itemDB["shop_res"] = ResourceManager.instance.getResByURL("config/shop_res.json");
			}
			return _storeDB
		}
	}
}