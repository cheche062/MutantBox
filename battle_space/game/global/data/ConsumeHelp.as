package game.global.data
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.data.bag.ItemData;
	import game.global.vo.User;
	
	import laya.utils.Handler;

	public class ConsumeHelp
	{
		public function ConsumeHelp()
		{
		}
		
		public static function Consume(cAr:Array , handel:Handler , waterStr:String = "", force:Boolean = false):void
		{
			var maxPrice:int = 0;
			var water:Number = 0;
//			XFacade.instance.openModule("ConsumeHelpPanel",[cAr,Math.ceil(maxPrice),handel]);
//			return ;
			trace("cAr", cAr);
			var showAr:Array = [];
			for (var i:int = 0; i < cAr.length; i++) 
			{
				var item:ItemData = cAr[i];
				if(!item)
					continue;
				var itemPrice:Number = DBItem.getItemPrice(item.iid);
				trace("itemPrice:"+itemPrice);
				if(!itemPrice)
					continue;
				if(item.iid == DBItem.WATER)
				{
					water += item.inum;
					continue;
				}
				
				var itemNum:Number = User.getInstance().getResNumByItem(item.iid+"");
				trace("itemNum:"+itemNum);
				if(itemNum < item.inum)
				{
					maxPrice += DBItem.caculatePrice(item.iid, item.inum - itemNum);
					var i2:ItemData = new ItemData();
					i2.iid = item.iid;
					i2.inum = item.inum - itemNum;
					showAr.push(i2);
				}
			}
			trace("maxPrice:"+maxPrice);
			trace("water:"+water);
			if(maxPrice)
			{
				
				XFacade.instance.openModule("ConsumeHelpPanel",[showAr,Math.ceil(maxPrice),handel]);
				return ;
			}
			
			if(water)
			{
				XFacade.instance.openModule(ModuleName.ItemAlertView, [waterStr,
					DBItem.WATER,
					water,
					function(){									
						ConsumeWater(water,handel)
					}]
				);
				
				return ;
			}
			
			if(force){
				XFacade.instance.openModule(ModuleName.ItemAlertView, [waterStr,
					DBItem.GOLD,
					item.inum,
					function(){
						ConsumeGold(item.inum,handel)
					}]
				);
				return ;
			}
			
			handel.run();	
		}
		
		
		public static function ConsumeWater(wnum:Number , handel:Handler):void
		{
//			XFacade.instance.openModule("PurchasePanel");
			var waterNum:Number = User.getInstance().water
			if(waterNum < wnum)
			{
//				XFacade.instance.openModule("PurchasePanel"); //弃用
				XFacade.instance.openModule(ModuleName.ChargeView);
				return ;
			}
			handel.run();
		}
		
		private static function ConsumeGold(gnum , handel:Handler):void{
			//			XFacade.instance.openModule("PurchasePanel");
			var num:Number = User.getInstance().gold
			if(num < gnum)
			{
				XFacade.instance.openModule(ModuleName.ItemAlertView, ["",
					DBItem.WATER,
					gnum - num,
					function(){									
						ConsumeWater(gnum - num,handel)
					}]
				);
			}
			handel.run();
		}
	}
}