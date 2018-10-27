package game.module.tips.itemTip
{
	import game.global.GameConfigManager;
	import game.global.GlobalRoleDataManger;
	import game.global.data.bag.ItemData;
	import game.global.vo.User;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.EquipmentHeroInfoVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.EquipmentSuitVo;
	import game.global.vo.equip.HeroEquipVo;
	import game.module.fighting.adata.ActionData;
	import game.module.tips.itemTip.base.BaseItemTip;
	
	import laya.display.Sprite;
	import laya.net.URL;
	import laya.utils.ClassUtils;
	import laya.utils.Dictionary;
	import laya.utils.Pool;

	public class ItemTipManager
	{
//		public static const ItemTips_SIGNKEY:String = "ItemTips_SIGNKEY";  //对象池标识
		
//		public static const ItemTipComponent:String = "tips.ItemTipComponent";
		public static const ItemTipPanel_CLS:String = "tips.ItemTipPanel";
		public static const ItemTipPanel_CLS2:String = "tips.ItemTipPanel2";
		public static const ItemTipTileCell_CLS:String = "tips.ItemTipTileCell";
		public static const ItemTipIconCell_CLS:String = "tips.ItemTipIconCell";
		public static const ItemTipEquipCell_ClS:String="tips.ItemTipEquipCell";
		
		public function ItemTipManager()
		{
		}
		
		public static function init():void
		{
			ClassUtils.regClass(ItemTipManager.ItemTipPanel_CLS,ItemTipPanel3);
			ClassUtils.regClass(ItemTipManager.ItemTipPanel_CLS2,ItemTipPanel2);
			ClassUtils.regClass(ItemTipManager.ItemTipTileCell_CLS,ItemTipTileCell);
			ClassUtils.regClass(ItemTipManager.ItemTipIconCell_CLS,ItemTipIconCell);
			ClassUtils.regClass(ItemTipManager.ItemTipEquipCell_ClS,ItemTipEquipCell);
		}
		
		/**
		 * itemD 主道具 compareD 比对道具
		 * 
		 */
		public static function getTips(itemD:ItemData=null, compareD:EquipInfoVo = null,hero:HeroEquipVo=null):BaseItemTip
		{
			var cData:Array = []; 
			if(itemD)
			{
				cData.push(formatItem( itemD , false,hero) );
			}
			
			if(compareD)
			{
				cData.push(formatEquipTips(compareD,true,hero) );
			}
			var tip:BaseItemTip = itemTipCom;
			tip.data = JSON.stringify(cData);
			return tip;
		}
		
		
		
		private static var _itemTipCom:ItemTipComponent;
		public static function get itemTipCom():ItemTipComponent{
			if(!_itemTipCom)
				_itemTipCom = new ItemTipComponent();
			return _itemTipCom;
		}
		
		public static function set itemTipCom(v:ItemTipComponent):void{
			_itemTipCom = v;
		}
		
		
		/**
		 * itemD 道具ID isCompare 是否有比对道具
		 */
		public static function formatItem(itemD:ItemData , isCompare:Boolean = false,hero:HeroEquipVo=null):Object
		{
			var obj:Object = {};
			var user:User = GlobalRoleDataManger.instance.user;
			obj.cls = ItemTipManager.ItemTipPanel_CLS;  //道具TIPS的界面类型
			
			var cData:Array = []; 
			obj.data = cData;
			
			//头部信息
			cData.push(formatItemTile(itemD,isCompare));
			//info信息
			itemD.playerLevel=user.level;
			if(itemD.exPro!=null)
			{
				if(itemD.exPro.strong_level==undefined)
				{
					itemD.level=0;
				}
				else
				{
					itemD.level=itemD.exPro.strong_level;
				}
			}
			cData.push(formatItemInfo(itemD));
			//装备\
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[itemD.vo.id];
			if(l_equipVo)
			{
				cData.push(formatEquip(itemD,hero));
			}
			
			return obj;
		}
		
		public static function formatEquipTips(itemD:EquipInfoVo, isCompare:Boolean = false,hero:HeroEquipVo=null):Object
		{
			var obj:Object = {};
			var user:User = GlobalRoleDataManger.instance.user;
//			obj.cls = !isCompare ?  ItemTipManager.ItemTipPanel_CLS : ItemTipManager.ItemTipPanel_CLS2;  //道具TIPS的界面类型
			obj.cls = ItemTipManager.ItemTipPanel_CLS2;
			var cData:Array = []; 
			obj.data = cData;
			var l_itemD:ItemData=new ItemData();
			l_itemD.iid=itemD.equip_item_id;
//			l_itemD.vo=GameConfigManager.items_dic[itemD.equip_item_id]
			l_itemD.level=itemD.strong_level;
			l_itemD.playerLevel=user.level;
			//头部信息
			cData.push(formatItemTile(l_itemD,isCompare));
			//info信息
			cData.push(formatItemInfo(l_itemD));
			//装备\
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[l_itemD.vo.id];
			if(l_equipVo)
			{
				cData.push(formatEquipForPlayer(itemD,hero));
			}
			
			return obj;
		}
		
		
		
		
		/**
		 *组成头部 
		 */
		public static function formatItemTile(itemD:ItemData , isCompare:Boolean = false):Object
		{
			var obj:Object = {};
			obj.cls = ItemTipManager.ItemTipTileCell_CLS;  //道具TIPS的界面类型
			if(itemD.vo==null)
			{
//				itemD.vo=GameConfigManager.items_dic[itemD.iid];
				
			}
			obj.data = {
				iname:itemD.vo.name,
				isEquiped:isCompare
			};
			return obj;
		}
		
		
		/**
		 *组成头部 
		 */
		public static function formatItemInfo(itemD:ItemData):Object
		{
			var obj:Object = {};
			obj.cls = ItemTipManager.ItemTipIconCell_CLS;  //道具TIPS的界面类型

			obj.data = {
				icon:itemD.vo.iconPath,
				quality:itemD.vo.quality,
				id:itemD.iid,
				name:itemD.vo.name,
				level:itemD.level,
				playerLevel:itemD.playerLevel
			};
			return obj;
		}
		
		/**
		 * 套装
		 */
		public static function formatEquip(itemD:ItemData,equipVo:HeroEquipVo):Object
		{
			var obj:Object={};
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[itemD.vo.id];
			var l_suitVo:EquipmentSuitVo=null;
			var btntype:int;
			for(var i:int=0;i<GameConfigManager.EquipmentSuitList.length;i++)
			{
				var l_vo:EquipmentSuitVo=GameConfigManager.EquipmentSuitList[i];
				if(l_equipVo.suit==l_vo.suit)
				{
					l_suitVo=l_vo;
					break;
				}
			}
			if(equipVo)
			{
				btntype=1;
			}
			else
			{
				btntype=2;
			}
				
			
			
			obj.cls=ItemTipManager.ItemTipEquipCell_ClS;  //道具TIPS的界面类型
			obj.data={
				itemData:itemD,
				type:1,
				btntype:btntype,
				equipBaseAtt:l_equipVo.getAttr(),
				playerBase:equipVo,
				suitBase:l_suitVo	
			};
			
			return obj;
		}
		
		public static function formatEquipForPlayer(itemD:EquipInfoVo,equipVo:HeroEquipVo):Object
		{
			var obj:Object={};
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[itemD.equip_item_id];
			var l_suitVo:EquipmentSuitVo=null;
			for(var i:int=0;i<GameConfigManager.EquipmentSuitList.length;i++)
			{
				var l_vo:EquipmentSuitVo=GameConfigManager.EquipmentSuitList[i];
				if(l_equipVo.suit==l_vo.suit)
				{
					l_suitVo=l_vo;
					break;
				}
			}
			var num:int=0;
			if(equipVo!=null)
			{
				if(equipVo.equipList!=null&&l_suitVo!=null)
				{
					var l_dic:Dictionary=new Dictionary();
					l_dic.set(l_suitVo.suit,0);
					for(var i:int=0;i<equipVo.equipList.length;i++)
					{
						var l_equipVo1:EquipInfoVo=equipVo.equipList[i];
						var l_equipBaseInfo:EquipmentListVo=GameConfigManager.EquipmentList[l_equipVo1.equip_item_id];
						if(l_equipBaseInfo.suit>0&&l_suitVo.suit==l_equipBaseInfo.suit)
						{
							var l_equipSuitNum:int=l_dic.get(l_equipBaseInfo.suit);
							if(l_equipSuitNum==null||l_equipSuitNum==undefined)
							{
								l_equipSuitNum=1;
							}
							else
							{
								l_equipSuitNum+=1;
							}
							l_dic.set(l_equipBaseInfo.suit,l_equipSuitNum);
						}
					}
				}
				if(l_suitVo!=null)
				{
					num=l_dic.get(l_suitVo.suit);
				}
			}
			
			
			
			var btntype:int;
			if(equipVo)
			{
				btntype=1;
			}
			else
			{
				btntype=2;
			}
			
			obj.cls=ItemTipManager.ItemTipEquipCell_ClS;  //道具TIPS的界面类型
			obj.data={
				itemData:itemD,
				type:2,
				btntype:btntype,
				equipBaseAtt:l_equipVo.getAttr(),
				playerBase:equipVo,
				suitBase:l_suitVo,
				hasSuit:num
			};
			return obj;
		}
		
		
		
	}
}