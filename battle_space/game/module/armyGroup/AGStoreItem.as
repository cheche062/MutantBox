package game.module.armyGroup
{
	import MornUI.armyGroup.AGStoreItemUI;
	
	import game.common.ToolFunc;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.net.socket.WebSocketNetService;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AGStoreItem extends AGStoreItemUI
	{
		
		public function AGStoreItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			var price = value["price"].split("=")
			dom_icon.skin = GameConfigManager.getItemImgPath(price[0]);
			priceTxt.text = price[1];
			
			var child = ToolFunc.createRewardsDoms(value["item"])[0];
			this.imgIcon.destroyChildren();
			child.pos(60, 25);
			this.imgIcon.addChild(child);
//			addChildAt(child,2);
			
			buyBtn.disabled = BagManager.instance.getItemNumByID(price[0]) < Number(price[1]);
			buyBtn.on(Event.CLICK, this, clickHandler, [value["id"]]);
			if(value["curr_level"]<value["max_level"]){
				imgTip.visible = true;
				lb_1.text = GameLanguage.getLangByKey('L_A_73114');
				lb_2.text = GameLanguage.getLangByKey('L_A_'+ (20882+Number(value["max_level"])));
				for(var i =0;i<this.numChildren-1;i++ ){
					this.getChildAt(i).disabled = true;
				}
			}
			else{
				imgTip.visible = false;
				for(var i =0;i<this.numChildren-1;i++ ){
					this.getChildAt(i).disabled = false;
				}
			}
			super.dataSource = value;
		}
		
		private function clickHandler(id):void {
			trace(id)
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_STORE_BUY, [id]);
		}
		
		
	
	}

}