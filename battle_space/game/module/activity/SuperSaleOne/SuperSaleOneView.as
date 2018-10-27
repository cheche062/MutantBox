package game.module.activity.SuperSaleOne 
{
	import game.common.base.BaseView;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.activity.ActivityMainView;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.SuperSaleOne.SuperSaleOneViewUI;
	/**
	 * ...
	 * @author ...
	 */
	public class SuperSaleOneView extends BaseView
	{
		
		public static const BUY_ITEM:String = "BUY_ITEM";  //购买物品
		
		public static const REFRESH_ITEM:String = "REFRESH_ITEM";	//刷新物品
		
		private var _itemVec:Vector.<SuperSaleOneItem> = new Vector.<SuperSaleOneItem>(6);
		private var _itemInfo:Vector.<SuperSaleOneVo> = new Vector.<SuperSaleOneVo>(6);
		private var _refreshPriceArr:Array = [];
		
		private var _refreshTime:int = 0;
		private var _refreshPrice:int = 0;
		private var _remainTime:int = 0;
		
		public function SuperSaleOneView() 
		{
			super();
			
			ResourceManager.instance.load(ModuleName.SuperSaleOneView,Handler.create(this, resLoader));
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				
				case view.refreshAllbtn:
					if (User.getInstance().water < _refreshPrice)
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
						return;
					}
					WebSocketNetService.instance.sendData(ServiceConst.SUPER_SALE_ONE_REFRESH_ALL, [ActivityMainView.CURRENT_ACT_ID]);
					break;
				default:
					break;
			}
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			if (!view.displayedInStage)
			{
				return;
			}
			//trace("superSale:", args);
			
			var len:int = 0;
			var i:int = 0;
			var rw,ar:Array = [];
			switch(cmd)
			{
				case ServiceConst.SUPER_SALE_ONE_INIT:
					for (i = 0; i < 6; i++)
					{
						_itemInfo[i].itemInfo = args[0].items[i].item_id;
						_itemInfo[i].oriPrice = args[0].items[i].price.split("=")[1];
						_itemInfo[i].nowPrice = args[0].items[i].discount_price.split("=")[1];
						_itemInfo[i].discount = args[0].items[i].discount;
						_itemInfo[i].nowNum = args[0].items[i].limit;
						_itemInfo[i].maxNum = args[0].items[i].max;
						_itemInfo[i].refreshPrice = args[0].refresh_item_price.split("=")[1];
						
						_itemVec[i].dataSource = _itemInfo[i];
					}
					
					_refreshPriceArr = [];
					len = args[0].refresh_price.length;
					for (i = 0; i < len; i++) 
					{
						_refreshPriceArr.push( { up:args[0].refresh_price[i].up, price:args[0].refresh_price[i].price.split("=")[1] } );
					}					
					_refreshTime = args[0].refresh_time+1;
					_remainTime = parseInt(args[0].end_date) - parseInt(TimeUtil.now / 1000);
					updateRefreshPrice();
					remainTimeCount();
					break;
				case ServiceConst.SUPER_SALE_ONE_REFRESH_ALL:
					for (i = 0; i < 6; i++)
					{
						_itemInfo[i].itemInfo = args[0].items[i].item_id;
						_itemInfo[i].oriPrice = args[0].items[i].price.split("=")[1];
						_itemInfo[i].nowPrice = args[0].items[i].discount_price.split("=")[1];
						_itemInfo[i].discount = args[0].items[i].discount;
						_itemInfo[i].nowNum = args[0].items[i].limit;
						_itemInfo[i].maxNum = args[0].items[i].max;
						
						_itemVec[i].dataSource = _itemInfo[i];
					}
					_refreshTime = args[0].refresh_time+1;
					updateRefreshPrice();
					break;
				case ServiceConst.SUPER_SALE_ONE_BUY:
					updateItem(args[0].item);
					break;
				case ServiceConst.SUPER_SALE_ONE_REFRESH_GOODS:
					updateItem(args[0].item);
					break;
				default:
					break;
			}
		}
		
		private function updateRefreshPrice():void
		{
			var len:int = _refreshPriceArr.length;
			
			
			for (var i:int = 0; i < len; i++)
			{
				//trace("_refreshTime:", _refreshTime,"up:",_refreshPriceArr[i].up);
				if (_refreshTime <= _refreshPriceArr[i].up)
				{
					_refreshPrice = _refreshPriceArr[i].price;
					break;
				}
			}
			view.refreshAllTxt.text = _refreshPrice;
		}
		
		private function updateItem(info:Object):void
		{
			for (var i:int = 0; i < 6; i++) 
			{
				if (_itemInfo[i].itemInfo == info.item_id)
				{
					_itemInfo[i].oriPrice = info.price.split("=")[1];
					_itemInfo[i].nowPrice = info.discount_price.split("=")[1];
					_itemInfo[i].discount = info.discount;
					_itemInfo[i].nowNum = info.limit;
					_itemInfo[i].maxNum = info.max;
					
					_itemVec[i].dataSource = _itemInfo[i];
				}
			}
		}
		
		
		private function superSaleEventHandler(cmd:int, ...args):void 
		{
			//trace("cmd:", cmd, "args:", args);
			switch(cmd)
			{
				case BUY_ITEM:
					WebSocketNetService.instance.sendData(ServiceConst.SUPER_SALE_ONE_BUY, [ActivityMainView.CURRENT_ACT_ID,_itemInfo[args[0]].itemInfo]);
					break;
				case REFRESH_ITEM:
					WebSocketNetService.instance.sendData(ServiceConst.SUPER_SALE_ONE_REFRESH_GOODS, [ActivityMainView.CURRENT_ACT_ID,_itemInfo[args[0]].itemInfo]);
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(...args):void{
			super.show();
			
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function resLoader():void
		{
			this._view = new SuperSaleOneViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			
			for (var i:int = 0; i < 6; i++) 
			{
				_itemVec[i] = new SuperSaleOneItem();
				_itemVec[i].setMC(view["item_" + i]);
				
				
				_itemInfo[i] = new SuperSaleOneVo();
				_itemInfo[i].itemIndex = i;
			}
			
			addEvent();
			//initData();
		}
		
		override public function createUI():void{			
			
		}
		
		private function remainTimeCount():void
		{
			_remainTime--;
			if (_remainTime <= 0)
			{
				view.timeTxt.text = "00:00:00";
				return;
			}
			view.timeTxt.text = TimeUtil.getTimeCountDownStr(_remainTime,false);
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.SUPER_SALE_ONE_INIT, ActivityMainView.CURRENT_ACT_ID);
			Laya.timer.loop(1000, this, this.remainTimeCount);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_INIT), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_REFRESH_ALL), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_BUY), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_REFRESH_GOODS), this, this.serviceResultHandler);
			
			Signal.intance.on(REFRESH_ITEM, this, this.superSaleEventHandler,[REFRESH_ITEM]);
			Signal.intance.on(BUY_ITEM, this, this.superSaleEventHandler,[BUY_ITEM]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		
		
		private function removeFromStageEvent():void
		{
			Laya.timer.clear(this, this.remainTimeCount);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_INIT), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_REFRESH_ALL), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_BUY), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_SALE_ONE_REFRESH_GOODS), this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function addEvent():void {
			
			if (!view)
			{
				return;
			}
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			
			super.removeEvent();
		}
		
		private function get view():SuperSaleOneViewUI{
			return _view;
		}
		
	}

	private class SuperSaleOneVo
	{
		public var itemIndex:int = 0;
		public var itemInfo:String = "";
		public var discount:int = 0;
		public var oriPrice:int;
		public var nowPrice:int;
		public var maxNum:int;
		public var nowNum:int;
		public var refreshPrice:int = 20;
	}

}

