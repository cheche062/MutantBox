package game.module.chargeView
{
	import MornUI.chargeView.VipShopUI;
	
	import game.common.DataLoading;
	import game.common.XItemTip;
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.module.store.StoreItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * VipStoreView
	 * author:huhaiming
	 * VipStoreView.as 2018-1-26 下午3:15:32
	 * version 1.0
	 *
	 */
	public class VipStoreView extends BaseView
	{
		public function VipStoreView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			var arr:Array = VIPVo.getShopList(User.getInstance().VIP_LV);
			arr = JSON.parse(JSON.stringify(arr));
			view.list.array = arr;
			WebSocketNetService.instance.sendData(ServiceConst.GET_VIP_SHOP);
		}
		
		private function onClick(e:Event):void{
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("args::",args)
			switch(cmd)
			{
				case ServiceConst.GET_VIP_SHOP:
					var info:Object = args[1].vip_shop_info;
					var arr:Array = view.list.array;
					for(var i:int=0; i<arr.length; i++){
						arr[i]["times"] = info[arr[i]["id"]];
					}
					view.list.array = arr;
					break;
				case ServiceConst.VIP_SHOP_BUY:
					var id:int = args[1].id;
					arr = view.list.array;
					for(i=0; i<arr.length; i++){
						if(arr[i]["id"] == id){
							arr[i]["times"] = arr[i]["times"]-1;
							break;
						}
					}
					view.list.array = arr;
					
					XItemTip.showTip(args[1].reward);
					break;
			}
		}
		
		private function onBuy(item:*):void{
			//DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.VIP_SHOP_BUY,[item.data.id]);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_VIP_SHOP), this, this.serviceResultHandler,[ServiceConst.GET_VIP_SHOP]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.VIP_SHOP_BUY), this, this.serviceResultHandler,[ServiceConst.VIP_SHOP_BUY]);
			Signal.intance.on(VipStoreItem.BUY, this, this.onBuy);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick)
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_VIP_SHOP), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.VIP_SHOP_BUY), this, this.serviceResultHandler);
			Signal.intance.off(VipStoreItem.BUY, this, this.onBuy);
		}
		
		override public function createUI():void{
			this._view = new VipShopUI();
			this.addChild(this._view);
			view.list.itemRender = VipStoreItem;
			view.list.vScrollBarSkin = "";
		}
		
		private function get view():VipShopUI{
			return this._view as VipShopUI;
		}
	}
}