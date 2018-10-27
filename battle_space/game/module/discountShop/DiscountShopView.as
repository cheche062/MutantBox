package game.module.discountShop
{
	import MornUI.discountShop.DiscountShopUI;
	
	import game.common.ResourceManager;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.ItemCell2;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.module.activity.ActivityMainView;
	import game.module.bag.cell.ItemCell4;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class DiscountShopView extends BaseView
	{
		private var refreshTime:int;
		public function DiscountShopView(leftTime:int)
		{
			super();
			refreshTime = leftTime;
			Laya.timer.loop(1000, this, timeCountHandler);
			ResourceManager.instance.load(ModuleName.DiscountShop,Handler.create(this, resLoader));
			this.width = 846;
			this.height = 476;
		}
		
		private function resLoader():void
		{
			super.createUI();
			this.addChild(view);	
			view.list.renderHandler = Handler.create(this, onRender, null, false);
			addEvent();
			if(view.displayedInStage)
			{
				addToStageEvent();
			}
		
		}
		private function timeCountHandler():void
		{
			if(refreshTime<=0)
			{
				//				_timeCount = 0;
				Laya.timer.clear(this, timeCountHandler);
			}else
			{
				refreshTime--;
				var leftStr:String = TimeUtil.getTimeCountDownStr(refreshTime,false);
				view.leftTime.text = leftStr;
			}
		}	
		override public function dispose():void
		{
			super.dispose();
			Laya.timer.clear(this, timeCountHandler);
		}
		private function onRender(cell:Box,index:int):void
		{
			if(index>view.list.array.length-1)
			{
				return;
			}
			var data:Object = view.list.array[index];
			if(!data)
			{
				return;
			}
			cell.alpha = 1;
			var bg:Image = cell.getChildByName("bg") as Text;
			bg.visible = false;
			cell.disabled = false;
			var txt:Text = cell.getChildByName("txt") as Text;
			txt.visible = false;
			var nameTxt:Text = cell.getChildByName("itemName") as Text;
//			nameTxt.text = data["name"];
			trace("data:"+JSON.stringify(data));
			var propStr:String =  data["item_id"];
			var propArr:Array = propStr.split("=");
			trace("propArr"+propArr[0]);
			var itData:ItemVo = DBItem.getItemData(propArr[0]);
			nameTxt.text = itData.name; 
			
			var leftTxt:Text = cell.getChildByName("left") as Text;
			leftTxt.text = data["attempts"];
			if(parseInt(data["attempts"])==0)
			{
				cell.alpha = 0.8;
				txt.visible = bg.visible = true;
				cell.disabled = true;
				cell.gray = false;
			}else
			{
				cell.alpha = 1;
				txt.visible = bg.visible = false;
				cell.disabled = false;
			}
			var item:ItemCell2 = new ItemCell2();
			var itemData:ItemData = new ItemData();
			itemData.iid = propArr[0];
			itemData.inum = propArr[1];
			item.data = itemData;
			item.x = 20;
			item.y = 20;
			
			var price:String = data["price"];
			var pArr:Array = price.split("=");
			var itemIcon:Image = cell.getChildByName("itemIcon") as Image;
			itemIcon.skin = GameConfigManager.getItemImgPath(pArr[0]);
			var num:Text = cell.getChildByName("numTf") as Text;
			num.text = pArr[1];
			cell.addChildAt(item,cell.numChildren-2);
			var btnBuy:Button = cell.getChildByName("btn_buy") as Button;
			btnBuy.on(Event.CLICK,this,onBuy,[data["id"]]);
		}
		
		private function onBuy(itemId:int):void
		{
			trace("购买");
			WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_BUY,[ActivityMainView.CURRENT_ACT_ID,itemId]);//活动id 
		}
		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		override public function removeEvent():void{
			//			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
			
		}
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_VIEW), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_BUY), this, onResult);
//			Laya.timer.clear(this, timeCountHandler);
		}
		private function addToStageEvent():void 
		{
			//
			WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_VIEW,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_VIEW), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_BUY), this, onResult);
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.DISCOUNT_VIEW:
				{
					var buyObj:Object = args[1];
					var listArr:Array = args[2];
					trace("listArr0:"+JSON.stringify(listArr));
					if(buyObj)
					{
						for(var i:int=0;i<listArr.length;i++)
						{
							var item:Object = listArr[i];
							if(buyObj[item["id"]])
							{
								item["attempts"] = parseInt(item["attempts"])-buyObj[item["id"]];
							}
						} 
					}
					view.list.array = listArr;
					view.numTf.text = XUtils.formatResWith(User.getInstance().water);
					trace("listArr:"+JSON.stringify(listArr));
					break;
				}	
				case ServiceConst.DISCOUNT_BUY:
				{
					WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_VIEW,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					break;
				}
			}
		}
		public function get view():DiscountShopUI{
			_view = _view || new DiscountShopUI();
			return _view;
		}
	}
}