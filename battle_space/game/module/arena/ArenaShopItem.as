package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.FilterTool;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.arena.ArenaShopVo;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.arena.ArenaShopItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaShopItem extends BaseView 
	{
		
		private var _itemCon:ItemContainer;
		
		private var _goodsData:ArenaShopVo;
		
		public function ArenaShopItem() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.buyBtn:
					WebSocketNetService.instance.sendData(ServiceConst.ARENA_SHOP_CHANGE, [_goodsData.id]);
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
			
			_goodsData = value as ArenaShopVo;
			//trace("goodsInfo: ", value);
			
			if (!_itemCon)
			{
				_itemCon = new ItemContainer();
				_itemCon.x = 51;
				_itemCon.y = 20;
				//_itemCon.userCircleBg = true;
				view.addChild(_itemCon);
			}
			
			_itemCon.setData(_goodsData.item_id.split("=")[0], _goodsData.item_id.split("=")[1]);
			
			//view.itemNameTF.text = GameLanguage.getLangByKey(GameConfigManager.items_dic[_goodsData.item_id.split("=")[0]].name);
			view.priceTF.text = _goodsData.price.split("=")[1];
			view.remainTF.wordWrap = true;
			
			view.buyBtn.disabled = false;
			if (_goodsData.buy_times >= _goodsData.attempts)
			{
				view.buyBtn.disabled = true;
			}
			view.buyBtn.label = GameLanguage.getLangByKey("L_A_34007") + " (" + (_goodsData.attempts - _goodsData.buy_times) + "/" + _goodsData.attempts + ")";
			
			
			view.itemContainer.disabled = false;
			_itemCon.filters = [];
			if (User.getInstance().arenaGroup < _goodsData.group)
			{
				_itemCon.filters = [FilterTool.grayscaleFilter];
				view.itemContainer.disabled = true;
				view.remainTF.visible = true;
				//view.remainTF.text = "need groud " + _goodsData.group + " open";
				view.remainTF.text = GameLanguage.getLangByKey("L_A_53079").replace("{0}", GameLanguage.getLangByKey(_goodsData.des));
				view.buyBtn.visible = false;
			}
			else
			{
				view.buyBtn.visible = true;
				view.remainTF.visible = false;
			}
		}
		
		override public function createUI():void
		{
			this._view = new ArenaShopItemUI();
			view.cacheAsBitmap = true;
			addEvent();
			this.addChild(_view);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			//Signal.intance.on(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler,[GuildEvent.CHANGE_GUILD_DESC]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			//Signal.intance.off(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler);
			
			super.removeEvent();
		}
		
		override public function dispose():void{
			removeEvent();
			super.dispose();
		}
		
		private function get view():ArenaShopItemUI{
			return _view;
		}
		
	}

}