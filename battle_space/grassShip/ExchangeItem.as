package game.module.grassShip
{
	import MornUI.grassShip.exchangeItemUI;
	
	import game.global.GameConfigManager;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	public class ExchangeItem extends exchangeItemUI
	{
		private var itemContainer: ItemContainer = null;
		public function ExchangeItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			if(!value)return;
			var rewards=value["rewards"];
			
			if (rewards && !itemContainer){
				var _index = rewards.indexOf("=");
				var child = new ItemContainer();
				var _id = rewards.slice(0,_index);
				var _name = GameConfigManager.items_dic[_id]["name"];
				value["dom_title"] = _name;
				child.setData(_id, rewards.slice(_index + 1));
				child.pos(50,40);
				itemContainer = child;
				this.addChild(child);
			}
			
			super.dataSource = value;
			
//			trace("兑换dataSource: ", value)
		}
		
		public function set bindExchangeHandler(fn:Function):void{
			var btn:Button = this.getChildByName("btn_exchange");
			if (fn) {
				btn.clickHandler = Handler.create(this, fn, [dataSource], false);
				
			} else {
				btn.clickHandler = null;
			}
		}
	}
}