package game.module.guild
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.guild.GuildItemVo;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.display.Text;
	import laya.events.Event;
	import MornUI.guild.GuildGoodItemUI;
	import MornUI.guild.GuildMemberItemUI;
	
	import laya.display.Sprite;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class GuildGoodItem extends Box
	{
		private var itemMC:GuildGoodItemUI;
		private var _data:GuildItemVo;
		
		private var _itemContainer:ItemContainer;
		private var _numText:Text;
		
		public function GuildGoodItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new GuildGoodItemUI();
			this.addChild(itemMC);
			
			_itemContainer = new ItemContainer();
			_itemContainer.x = 8;
			_itemContainer.y = 6;
			_itemContainer.numTF.visible = false;
			itemMC.addChild(_itemContainer);
			
			_numText = new Text();
			_numText.font = "BigNoodleToo";
			_numText.fontSize = 16;
			_numText.color = "#369ecc";
			_numText.align = "right";
			_numText.text = "x100";
			_numText.width = 60;
			_numText.x = 18;
			_numText.y = 65;
			itemMC.addChild(_numText);
			
			itemMC.buyBtn.on(Event.CLICK, this, this.buyItem);
		}
		
		private function buyItem():void 
		{
			if (parseInt(this.itemMC.goodPriceTF.text) > User.getInstance().contribution)
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_57005"),0,function(v:int){
									if (v == AlertType.RETURN_YES)
									{
										XFacade.instance.openModule(ModuleName.GuildDonateView);
									}
								});
				return;
			}
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BUY_GOODS, [data.id]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			this._data = value as GuildItemVo;
			
			if (!data)
			{
				return;
			}
			
			_itemContainer.setData(this.data.item.split("=")[0]);
			
			this.itemMC.limiteTF.text = data.buyLimit + "/" + this.data.purchase_attempts;
			this.itemMC.goodPriceTF.text = this.data.price.split("=")[1];
			_numText.text = "x" + this.data.item.split("=")[1];
			
			if (data.unlock_level > User.getInstance().guildLv)
			{
				view.lvLimitTF.text = GameLanguage.getLangByKey("L_A_73") + data.unlock_level + " unlock";
				view.lvLimitTF.visible = true;
				view.iImg.visible = false;
				view.goodPriceTF.visible = false;
				view.buyBtn.disabled = true;
			}
			else
			{
				view.lvLimitTF.visible = false;
				view.iImg.visible = true;
				view.goodPriceTF.visible = true;
				view.buyBtn.disabled = false;
			}
		
		}
		
		public function get data():GuildItemVo
		{
			return this._data;
		}
		
		private function get view():GuildGoodItemUI
		{
			return itemMC;
		}
	}
}