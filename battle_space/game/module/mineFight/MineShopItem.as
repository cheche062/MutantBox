package game.module.mineFight 
{
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.mineFight.MineShopItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineShopItem extends BaseView 
	{
		
		
		private var _itemCon:ItemContainer;
		
		private var _itemData:Object;
		
		private var _buyItemImg:Image;
		
		public function MineShopItem() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.buyBtn:
					WebSocketNetService.instance.sendData(ServiceConst.MINE_SHOP_BUY, [_itemData.id]);
					break;
				
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			if (!value)
			{
				return;
			}
			
			_itemData = value;
			
			if (!_itemCon)
			{
				_itemCon = new ItemContainer();
				_itemCon.x = 25;
				_itemCon.y = 25;
				_itemCon.userCircleBg = true;
				view.addChild(_itemCon);
				
				_buyItemImg = new Image();
				_buyItemImg.x = 115;
				_buyItemImg.y = 63;
				_buyItemImg.width = _buyItemImg.height = 50;
				view.addChild(_buyItemImg);
				
			}
			
			view.iName.text = GameLanguage.getLangByKey(GameConfigManager.items_dic[_itemData.item_id.split("=")[0]].name);
			_buyItemImg.skin = GameConfigManager.getItemImgPath(_itemData.price.split("=")[0]);
			view.iPrice.text = _itemData.price.split("=")[1];
			_itemCon.setData(_itemData.item_id.split("=")[0], _itemData.item_id.split("=")[1]);
			
		}
		
		override public function createUI():void
		{
			this._view = new MineShopItemUI();
			view.cacheAsBitmap = true;
			addEvent();
			this.addChild(_view);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		override public function dispose():void{
			removeEvent();
			super.dispose();
		}
		
		private function get view():MineShopItemUI{
			return _view;
		}
		
	}

}