package game.module.chargeView
{
	import MornUI.chargeView.VipStoreItemUI;
	
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.data.DBItem;
	import game.global.data.DBStore;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * VipStoreItem
	 * author:huhaiming
	 * VipStoreItem.as 2018-1-26 下午3:15:09
	 * version 1.0
	 *
	 */
	public class VipStoreItem extends VipStoreItemUI
	{
		public var data:Object;
		/***/
		public static const BUY:String = "vip_buy";
		public function VipStoreItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			data = value;
			if(data){
				
				imVip.skin = "chargeView/v"+data.vip_level+".png"
				this.disabled = (data.vip_level > User.getInstance().VIP_LV)
					
				var tmp:Array = (data.price+"").split("=");
				
				this.priceTF.text = tmp[1]+"";
				ItemUtil.formatIcon(currencyIcon, data.price);
				this.limitTF.text = data.times+"";
				if(data.times == 0){
					buyBtn.disabled = true;
				}else{
					buyBtn.disabled = false;
				}
				
				this.buyBtn.on(Event.CLICK, this, this.onClick);
				this.item.on(Event.CLICK, this, this.onClick);
				
				tmp = (data.item+"").split("=");
				this.numTF.text = (parseInt(tmp[1])>1?tmp[1]:"")+"";
				
				var vo:Object = DBItem.getItemData((data.item+"").split("=")[0]);
				this.nameTF.text = vo.abbreviation+"";
				ItemUtil.format(tmp[0], this.item);
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case this.buyBtn:
					var arr:Array = (data.now_price+"").split("=");
					if(arr[0] == DBItem.WATER){
						if(User.getInstance().water < arr[1]){
							XFacade.instance.openModule(ModuleName.ChargeView);
						}else{
							Signal.intance.event(BUY, this);
						}
					}else{
						Signal.intance.event(BUY, this);
					}
					break;
				case this.item:
					var db:Object = GameConfigManager.items_dic[(data.item + "").split("=")[0]];
					trace("db:", db);
					if(db){
						ItemTips.showTip(db.id);
					}
					break;
			}
		}
		
		/**@inheritDoc */
		override public function destroy(destroyChild:Boolean = true):void {
			this.buyBtn.off(Event.CLICK, this, this.onClick);
			this.item.off(Event.CLICK, this, this.onClick);
			super.destroy(destroyChild);
		}
	}
}