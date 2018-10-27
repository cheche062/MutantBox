package game.module.store
{
	import MornUI.store.StoreItemUI;
	
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.DBStore;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * StoreItem 商店单元条
	 * author:huhaiming
	 * StoreItem.as 2017-4-17 上午10:25:01
	 * version 1.0
	 *
	 */
	public class StoreItem extends StoreItemUI
	{
		public var data:Object;
		/**类型-外部赋值，用来获取数据源*/
		public static var type:int;
		/**事件-购买*/
		public static const BUY:String = "buy";
		
		public function StoreItem()
		{
			super();
			this.cacheAsBitmap = true;
			buyBtn['clickSound'] = ResourceManager.getSoundUrl("ui_dialog_buy",'uiSound');
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case this.buyBtn:
					var arr:Array = (data.now_price+"").split("=");
					if(arr[0] == DBItem.WATER){
						if(User.getInstance().water < arr[1]){
//							if(GameSetting.IsRelease)
//							{
//								XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//							}
//							else
//							{
								XFacade.instance.openModule(ModuleName.ChargeView);
//							}
						}else{
							Signal.intance.event(BUY, this);
						}
					}else{
						Signal.intance.event(BUY, this);
					}
					break;
				case this.item:
					var db:Object = GameConfigManager.items_dic[(data.item_id + "").split("=")[0]];
					trace("db:", db);
					if(db){
						ItemTips.showTip(db.id);
					}
					break;
			}
		}
		
		override public function set dataSource(value:*):void{
			data = value;
			if(data){
				var tmp:Array = (data.now_price+"").split("=");
				var db:Object = DBStore.getItemInfo(data.id, type);
				this.priceTF.text = tmp[1]+"";
				ItemUtil.formatIcon(currencyIcon, data.now_price);
				this.limitTF.text = data.buy_limit;//+"/"+db.attempts;
				if(data.buy_limit == 0){
					buyBtn.disabled = true;
				}else{
					buyBtn.disabled = false;
				}
				this.buyBtn.on(Event.CLICK, this, this.onClick);
				this.item.on(Event.CLICK, this, this.onClick);
				
				tmp = (data.item_id+"").split("=");
				this.numTF.text = (parseInt(tmp[1])>1?tmp[1]:"")+"";
				
				db = GameConfigManager.items_dic[(data.item_id + "").split("=")[0]];
				
				this.nameTF.text = db.abbreviation+"";
				ItemUtil.format(tmp[0], this.item);
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