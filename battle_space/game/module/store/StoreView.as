package game.module.store
{
	import MornUI.store.StoreUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.DBStore;
	import game.global.data.ItemCell2;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.module.activity.ActivityMainView;
	import game.module.alert.XAlert;
	import game.net.socket.WebSocketNetService;
	import game.common.ToolFunc;
	import game.global.util.TimeUtil;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
		
	/**
	 * StoreView 商店
	 * author:huhaiming
	 * StoreView.as 2017-4-17 上午9:45:24
	 * version 1.0
	 *
	 */
	public class StoreView extends BaseDialog
	{
		private var _storeId:*;
		private var _curItem:StoreItem;
		private var _freshTime:Number;
		/**商店类型，多个商店共用一个界面，0【折扣+资源】；1【互动商店】  */
		private var _storeType:Number;
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		/**活动列表*/
		private var activityData;
		/**折扣商店ID*/
		private var dis_shop_id = '';
		
		public function StoreView()
		{
			super();
			_closeOnBlank = true;
		}
		
		private function onResult(cmd:int, ...args):void{
			trace("S_OnResult",args);
			DataLoading.instance.close();
			switch(cmd){
				case ServiceConst.S_LIST:
				case ServiceConst.S_REFRESH:
					format(args[1]);
					break;
				case ServiceConst.S_BUY:
					XItemTip.showTip(_curItem.data.item_id);
					_curItem.data.buy_limit = parseInt(_curItem.data.buy_limit) - 1;
					_curItem.dataSource = _curItem.data;
					break;
				//基地附近的红点
				case ServiceConst.GET_ACT_LIST:
				{
					//trace("actList:"+JSON.stringify(args));
					trace("actList:",args);
					trace("args[1]:",args[0]);
					activityData  = args[0].activity; 
					doClearTimerHandler();
					for(var i = 0;i<activityData.length;i++){
						if(activityData[i].tid == 19){
							dis_shop_id = activityData[i].id;
							WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_VIEW,activityData[i].id);//活动id 
							clearTimerHandler = ToolFunc.limitHandler(Math.abs(activityData[i].end_date_time - TimeUtil.nowServerTime), function(time) {
								var detailTime = TimeUtil.toDetailTime(time);
								view.lbCountdown.text =  GameLanguage.getLangByKey('L_A_83082') +' '+TimeUtil.timeToText(detailTime);
							}, function() {
								view.lbCountdown.text = "";
								//					setTitle_bg("2");
								clearTimerHandler = null;
								//更新数据
								WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
								trace('倒计时结束：：：');
							}, false);
							
						}
					}
					break;
				}	
				//折扣商店
				case ServiceConst.DISCOUNT_VIEW:
				{
					var buyObj:Object = args[0];
					var listArr:Array = args[1];
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
					view.typeTab.visible = true;
					view.typeTab.selectedIndex = 0;
					onChange();
					view.listDiscount.array = listArr;
//					view.numTf.text = XUtils.formatResWith(User.getInstance().water);
					trace("listArr:"+JSON.stringify(listArr));
					break;
				}	
				case ServiceConst.DISCOUNT_BUY:
				{
					WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_VIEW,dis_shop_id);//活动id 
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					break;
				}
			}
		}
		
		private function onRender(cell:Box,index:int):void
		{
			if(index>view.listDiscount.array.length-1)
			{
				return;
			}
			var data:Object = view.listDiscount.array[index];
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
			btnBuy.on(Event.CLICK,this,onBuy_1,[data["id"]]);
		}
		
		private function onBuy_1(itemId:int):void
		{
			trace("购买");
			WebSocketNetService.instance.sendData(ServiceConst.DISCOUNT_BUY,[dis_shop_id,itemId]);//活动id 
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
			DataLoading.instance.close();
		}
		
		private function format(data:Object):void{
			var list:Array = data.list;
			this.view.itemList.array = list;
			this.view.priceTF.text = DBStore.getRefreshPrice(data.refresh)+"";
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				case view.refreshBtn:
					XAlert.showAlert("U need pay\t<font color='#ff0000'>"+this.view.priceTF.text+ "</font>\twater to refresh", 
						Handler.create(WebSocketNetService.instance, WebSocketNetService.instance.sendData,[ServiceConst.S_REFRESH,[_storeId]]
					))
					break;
			}
		}
		
		private function onChange():void{
			//指定类型
			var type:int = DBStore.SHOPIDS[view.typeTab.selectedIndex];
			//
			switch(_storeType){
				case 0:
					type = DBStore.SHOPIDS[1];
					switch(view.typeTab.selectedIndex){
						case 0:
							view.listDiscount.visible = true;
							view.itemList.visible = false;
							view.lbCountdown.visible = true;
							break;
						case 1:
							view.listDiscount.visible = false;
							view.itemList.visible = true;
							view.lbCountdown.visible = false;
							break;
					}
					break;
				case 1:
					type = DBStore.SHOPIDS[0];
					view.typeTab.visible = false;
					view.listDiscount.visible = false;
					view.itemList.visible = true;
					view.lbCountdown.visible = false;
					break;
			}
			StoreItem.type = type;
			_storeId = type;
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.S_LIST,[_storeId]);
			this.view.refreshBtn.disabled = !DBStore.getCanFresh(_storeId);
			this.view.refreshBox.visible = !this.view.refreshBtn.disabled
			//
				
			var info:Object = DBStore.getShopInfo(_storeId);
			var itemData:ItemVo = DBItem.getItemData(info.canshu1);
			view.currencyIcon.skin = "common/icons/"+itemData.icon+".png"
			view.currencyTF.text = User.getInstance().getResNumByItem(info.canshu1)+"";
			
		}
		
		private function onBuy(item:*):void{
			_curItem = item;
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.S_BUY,[_storeId,_curItem.data.id]);
		}
		
		private function onUserChange():void{
			var info:Object = DBStore.getShopInfo(_storeId);
			var itemData:ItemVo = DBItem.getItemData(info.canshu1);
			view.currencyIcon.skin = "common/icons/"+itemData.icon+".png"
			view.currencyTF.text = User.getInstance().getResNumByItem(info.canshu1)+"";
		}
		
		override public function show(...args):void{
			super.show();
			
			view.typeTab.labels = DBStore.getTypeList().join(",");
			view.typeTab.visible = false;
			
			AnimationUtil.flowIn(this);
			var index:int = args[0]?args[0]:0;
			_storeType = 0;
			//获取商店数据类型
			if(args[0].length > 1){
				index = args[0][0];
				_storeType = args[0][1];
				//折扣商店换顶部名字
				if(_storeType == 0){
					view.titleTF.text = 'L_A_19212';
				}
				view.typeTab.selectedIndex = 1;
			}
			else{
				if(index != undefined){
					for(var i:int=0; i<DBStore.SHOPIDS.length; i++){
						if(DBStore.SHOPIDS[i] == index){
							view.typeTab.selectedIndex = i;
							break;
						}
					}
				}
			}
			onChange();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			this._storeId = null;
			this._curItem = null;
			super.close();
		}
		
		override public function createUI():void{
			this._view = new StoreUI();
			this.addChild(_view);
			view.itemList.itemRender = StoreItem;
			
			view.listDiscount.renderHandler = Handler.create(this, onRender, null, false);
			
			view.typeTab.labels = DBStore.getTypeList().join(",");
			//人肉设置TAB的字体
			var btns:* = view.typeTab.items;
			for(var i:Number=0; i<btns.length; i++){
				Button(btns[i]).labelFont = XFacade.FT_BigNoodleToo;
			}
			this.closeOnBlank = true;
			this.cacheAsBitmap = true;
			view.lbCountdown.visible = false;
			view.itemList['clickSound'] = ""
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			//检查是否有活动
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, onResult);
			WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
			//折扣商店挪一下位置
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_VIEW), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_BUY), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.S_LIST),this,onResult,[ServiceConst.S_LIST]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.S_BUY),this,onResult,[ServiceConst.S_BUY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.S_REFRESH),this,onResult,[ServiceConst.S_REFRESH]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(User.PRO_CHANGED, this, this.onUserChange);
			view.typeTab.on(Event.CHANGE, this, this.onChange);
			Signal.intance.on(StoreItem.BUY, this, this.onBuy);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, onResult);
			//折扣商店挪一下位置
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_VIEW), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DISCOUNT_BUY), this, onResult);
			
			view.typeTab.off(Event.CHANGE, this, this.onChange);
			Signal.intance.off(StoreItem.BUY, this, this.onBuy);
			Signal.intance.off(User.PRO_CHANGED, this, this.onUserChange);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.S_LIST),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.S_BUY),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.S_REFRESH),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			doClearTimerHandler();
			super.removeEvent();
		}
		
		private function doClearTimerHandler():void {
			clearTimerHandler && clearTimerHandler();
			clearTimerHandler = null;
		}
		
		private function get view():StoreUI{
			return this._view as StoreUI;
		}
		
	}
}