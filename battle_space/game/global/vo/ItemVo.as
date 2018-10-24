/***
 *作者：罗维
 */
package game.global.vo
{
	import game.global.GameConfigManager;
	import game.global.consts.ItemConst;
	import game.module.bag.mgr.ItemManager;

	public class ItemVo
	{
		public var id:uint;
		public var name:String;
		public var des:String;
		public var type:uint;
		public var subType:uint;
		public var rarity:uint;
		public var quality:uint;
		public var use_level:uint;
		public var stack:uint;
		public var icon:String;
		public var special_effects:uint;
		public var param1:uint=0;
		public var param2:uint;
		public var price:String;
		public var useMsg:String;
		public var abbreviation:String;
		public var source:String;
		
		
		
		public static var USETYPE_USE:String = "USETYPE_USE";  //礼包  - 直接使用
		public static var USETYPE_SELECT:String = "USETYPE_SELECT"; //礼包  - 选择兑换
		public static var USETYPE_CHANGENAME:String = "USETYPE_CHANGENAME";
		
		public function ItemVo()
		{
		}
		
		private var _priceAr:Array;
		public function get priceAr():Array
		{
			if(!_priceAr)
			{
				_priceAr = ItemManager.StringToReward(price);
			}
			return _priceAr;
		}
		
		//是否可以出售
		public function get isSell():Boolean{
			return priceAr && priceAr.length;
		}
		
		//使用类型
		public function get useType():Number{
			if(type == ItemConst.ITEM_TYPE_GIFTBAG)
			{
				switch(subType)
				{
					case ItemConst.ITEM_GIFTBAG_SUBTYPE_1:
					case ItemConst.ITEM_GIFTBAG_SUBTYPE_2:
					{
						return USETYPE_USE;
						break;
					}
					case ItemConst.ITEM_GIFTBAG_SUBTYPE_3:
					case ItemConst.ITEM_GIFTBAG_SUBTYPE_4:
					{
						return USETYPE_SELECT;
						break;
					}
				}
			}
			else if(type == ItemConst.ITEM_TYPE_RANDOM)
			{
				return USETYPE_USE;
			}
			else if(type ==ItemConst.ITEM_TYPE_CHANGENAME)
			{
				return USETYPE_CHANGENAME;
			}
			
			return 0;
		}
		
		//执行命令（优先级位于礼包使用类型后）
		private var _useMsgPs:Array;
		public function get useMsgPs():Array{
			if(!_useMsgPs)
			{
				if(useMsg && useMsg.length)
					_useMsgPs = useMsg.split(",");
				else
					_useMsgPs = [];
			}
			return _useMsgPs;
		}
		
		public function get iconPath():String{
			return "appRes/icon/itemIcon/"+icon+".png";
		}
		
		
		public function get sourceAr():Array
		{
			var _sourceAr = [];
			if(source && source.length) {
				var ar:Array = source.split(",");
				for (var i:int = 0; i < ar.length; i++) {
					var sid:Number = ar[i];
					var sVo:itemSourceVo = GameConfigManager.itemSource_dic[sid];
					if(sVo) _sourceAr.push(sVo);
				}
			}
			return _sourceAr;
		}
	}
}