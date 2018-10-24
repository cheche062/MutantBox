/***
 *作者：罗维
 */
package game.global.data.bag
{
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnit;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.bag.mgr.ItemManager;
	import game.net.socket.WebSocketNetService;
	
	public class BagManager
	{
		public function BagManager()
		{
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BAG_CHANGE_CONST),
				this,changeBagDataBack);
		}
		
		private static var _instance:BagManager;
		public static function get instance():BagManager{
			if(!_instance){
				_instance=new BagManager();
			}
			return _instance;
		}
		
		public var itemList:Array;
		public var itemDic:Object;
		//public function changeItem(itemKey:String,itemNum:uint,refresh:Boolean = false):void
		public function changeItem(itemKey:String,itemPro:Object,refresh:Boolean = false):void
		{
			var itemNum:Number = itemPro[0];
			//todo过期时间处理itemPro[0]
			var i:int;
			var itemd:ItemData;
			if(itemNum == 0)
			{
				if(itemDic.hasOwnProperty(itemKey)){
					delete itemDic[itemKey];
					i = getItemIdx(itemKey);
					if(i != -1)
					{
						itemList.splice(i,1);
						Signal.intance.event(BagEvent.BAG_EVENT_DEL,[itemKey]);
					}
				}
			}else if(itemDic.hasOwnProperty(itemKey)){
				itemd = itemDic[itemKey];
				itemd.inum = itemNum;
				itemd.exPro = itemPro[2];
				return ;
			}else
			{
				itemd = new ItemData();
				var idAr:Array = itemKey.split("_");
				itemd.iid = Number(idAr[0]);
				itemd.key = itemKey;
				itemd.inum = itemNum;
				itemd.exPro = itemPro[2];
				itemList.push(itemd);
				itemDic[itemd.key] = itemd;
				Sorting();
			}
			
			if(refresh)
			{
				Signal.intance.event(BagEvent.BAG_EVENT_CHANGE);
			}
		}
		
		private function getItemIdx(itemKey:String):Number{
			for (var i:int = 0; i < itemList.length; i++) 
			{
				var itemd:ItemData = itemList[i];
				if(itemd.key == itemKey)
					return i;
			}
			return -1;
		}
	
		/**
		 *根据物品类型及子类型 获得物品集合 
		 */
		public function getItemListByType(itypes:Array = null , subtypes:Array = null):Array{
			if(!itemDic || !itemList){  //尚未获取包裹数据
				initBagData();
				return null;
			}
			var rt:Array = [];
			for (var i:int = 0; i < itemList.length; i++) 
			{
				var idata:ItemData = itemList[i];
				if(!idata.vo)
					trace("没有实体"+idata.iid);
//				if(idata.vo.type==undefined)
//				{
//					trace("type undefined"+idata.iid);
//				}
				if(idata.vo!=null)
				{
					if( (!itypes || itypes.indexOf(idata.vo.type) != -1) &&  (!subtypes || subtypes.indexOf(idata.vo.subType) != -1) )
					{
						rt.push(idata);
					}
				}
			}
			return rt;
		}
		
		/**
		 *根据道具id获取道具列表
		 * @param iid 道具ID
		 */
		public function getItemListByIid(iid:Number):Array{
			if(!itemDic || !itemList){  //尚未获取包裹数据
				initBagData();
				return null;
			}
			var rt:Array = [];
			for (var i:int = 0; i < itemList.length; i++) 
			{
				var idata:ItemData = itemList[i];
//				if(!idata.vo)
//					trace("没有实体"+idata.iid);
				if( idata.iid == iid )
				{
					rt.push(idata);
				}
			}
			return rt;
		}
		
		/**
		 * 根据道具id获取道具总数量
		 * @return
		 */
		public function getItemNumByID(iid:Number):int
		{
			var arr:Array = getItemListByIid(iid);
			if (!arr || arr.length == 0)
			{
				return 0;
			}
			
			var len:int = arr.length;
			var num:int = 0;
			for (var i:int = 0; i < len; i++) 
			{
				num += parseInt(arr[i].inum);
			}
			return num;
		}
		
		
		/**
		 * 排序
		 * 
		 */
		public function Sorting():Boolean{
			if(!itemList)
			{
				return false;
			}
//			trace("执行道具排序");
			itemList.sort(sortFun);
			return true;
		}
		
		public static function sortFun(i1:ItemData,i2:ItemData):Number{
			
			//trace("i1:", i1.vo, "i2:", i2.vo);
		    //类型       小 -  大
			if (!i1.vo || !i2.vo) return 0;
			if(i1.vo.type < i2.vo.type)
				return -1;
			if(i1.vo.type > i2.vo.type)
				return 1;
			//子类型   小 - 大
			if(i1.vo.subType < i2.vo.subType)
				return -1;
			if(i1.vo.subType > i2.vo.subType)
				return 1;
			//品质   高 - 低
			if(i1.vo.quality > i2.vo.quality)
				return -1;
			if(i1.vo.quality < i2.vo.quality)
				return 1;
			//使用等级   小 - 大
			if(i1.vo.use_level < i2.vo.use_level)
				return -1;
			if(i1.vo.use_level > i2.vo.use_level)
				return 1;
			//ID     小 - 大
			if(i1.iid < i2.iid)
				return -1;
			if(i1.iid > i2.iid)
				return 1;
			//数量   大 - 小
			if(i1.inum > i2.inum)
				return -1;
			if(i1.inum < i2.inum)
				return 1;
			return 0;
		}
		
		
		public function initBagData():void{
			trace(1,"initBagData");
			WebSocketNetService.instance.sendData(ServiceConst.BAG_INFO_DATA_CONST,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BAG_INFO_DATA_CONST),
				this,initBagDataBack);
		}
		
		private function initBagDataBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,initBagDataBack);
			itemDic = {};
			itemList = [];
			var sitems:Object = args[1];
//			trace("背包消息id"+args[0]);
//			trace("背包数据返回:"+JSON.stringify(sitems));
			for(var iid:String in sitems) 
			{
				var sitems2:Object = sitems[iid];
				for(var ikey:String in sitems2) 
				{
					var idata:ItemData = new ItemData();
					idata.iid = Number(iid);
					idata.key = ikey;
					if(sitems2[ikey]){
						idata.inum = Number(sitems2[ikey][0]);
						//todo过期时间[ikey][1]
						idata.exPro = sitems2[ikey][2];
					}
					//idata.inum = Number(sitems2[ikey]);
					itemDic[ikey] = idata;
					itemList.push(idata);
				}
			}
			Sorting();
			Signal.intance.event(BagEvent.BAG_EVENT_INIT);
		}
		
		private function changeBagDataBack(... args):void{
			if(!itemDic || !itemList)   //没原始数据，不理会
				return ;
			var key:String = args[1];
			var ps:Array = args[2];
			//trace("changeBagDataBack=========>>",ps);
			this.changeItem(key,ps);
			var iidata:ItemData = itemDic[key];
			if(iidata)
			{
				
			}
			Signal.intance.event(BagEvent.BAG_EVENT_CHANGE);
			//同步建筑-兵营状态
			DBUnit.isAnyCanUp();
			//同步建筑-雷达状态
			DBUnit.isRadioCanUp();

			User.getInstance().event();
		}
		
		public function getEquipByHeroId(p_heroId:int):Array
		{
			if(!itemList)
			{
				initBagData();
				return null;
			}
			var l_arr:Array=new Array();
			for(var i:int=0;i<itemList.length;i++)
			{
				var l_itemd:ItemData=itemList[i];
				if(l_itemd!=null&&l_itemd.vo!=null)
				{
					if(l_itemd.vo.type==10)
					{
						if(l_itemd.vo.param1==p_heroId && l_itemd.vo.type==ItemConst.ITEM_TYPE_EQUIP)
						{
							l_arr.push(l_itemd);
						}
					}
				}
				
			}
			return l_arr;
		}
		
		public function sellItem(ikey:String,inum:Number):void{
			WebSocketNetService.instance.sendData(ServiceConst.BAG_SELL_CONST,[ikey,inum]);
		}
		
		
		public function useItem(ikey:String,inum:Number,data:String = ""):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BAG_USEPACKAGE,[ikey,inum,data]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BAG_USEPACKAGE),
				this,useItemBack);
		}
		
		public function useItem2(ikey:String,inum:Number):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BAG_USEPACKAGE2,[ikey,inum]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BAG_USEPACKAGE2),
				this,useItemBack);
		}
		
		
		private function useItemBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,useItemGetRsBack);
			var obj:Object = args[1];
			var items:Array = obj.get_items;
			var ar:Array = [];
			for (var i:int = 0; i < items.length; i++) 
			{
				var itd:ItemData = new ItemData();
				itd.iid = Number(items[i][0]);
				itd.inum = Number(items[i][1]);
				ar.push(itd);
			}	
			XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
			
			
			
		}
		
		public function useItemGetRs(ikey:String):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BAG_SHOWPACKAGE,[ikey]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BAG_SHOWPACKAGE),
				this,useItemGetRsBack);
		}
		
		private function useItemGetRsBack(... args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,useItemGetRsBack);
			var obj:Object = args[1];
			var iNum:Number = Number(obj.item_num);
			var iKey:String = obj.item_unique_id;
			var items:Array = obj.items;
			var ar:Array = [];
			for (var i:int = 0; i < items.length; i++) 
			{
				var itd:ItemData = new ItemData();
				itd.iid = Number(items[i][0]);
				itd.inum = Number(items[i][1]);
				ar.push(itd);
			}	
			XFacade.instance.openModule("ItemUseSelctView",[ar,iNum,iKey]);
			
		}
		
		/**获得晶石道济集合   返回数组[[93214, 2]...]*/
		public function getJingshiList():Array{
			var result = [];
			for (var i = 93214; i <= 93231; i++) {
				var num = getItemNumByID(i);
				if (num) result.push([i, num]);
			}
			return result;
		}
		
		
		
		
		
		
	}
}