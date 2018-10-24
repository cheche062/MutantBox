package game.module.activity.SuperSaleOne
{
	import game.common.XFacade;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import laya.ui.View;
	import MornUI.SuperSaleOne.SuperSaleOneItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class SuperSaleOneItem 
	{
		
		private var _saleItem:SuperSaleOneItemUI;
		private var _itemdata:SuperSaleOneVo;
		private var _itemContainer:ItemContainer;
		
		public function SuperSaleOneItem() 
		{
			super();
		}
		
		public function setMC(view:SuperSaleOneItemUI):void
		{
			if (_saleItem)
			{
				_saleItem = null;
			}
			
			if (!_itemContainer)
			{
				_itemContainer = new ItemContainer();
				_itemContainer.x = 28;
				_itemContainer.y = 20;
				_itemContainer.userCircleBg = true;
			}
			
			_saleItem = view;
			
			_saleItem.addChild(_itemContainer);
			_saleItem.refreshBtn.on(Event.CLICK, this, this.btnHandle);
			_saleItem.buyBtn.on(Event.CLICK, this, this.btnHandle);
			_saleItem.stockTxt.text = "";
			_saleItem.refreshPriceTxt.text = "";
			_saleItem.oriPriceTxt.text = "";
			_saleItem.nowPriceTxt.text = "";
		}
		
		private function btnHandle(e:Event):void
		{
			switch(e.target)
			{
				case _saleItem.refreshBtn:
					if (GlobalRoleDataManger.instance.SSONeedAlert)
					{
						GlobalRoleDataManger.instance.SSONeedAlert = false;
						XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_56077"),
																			1,
																			_itemdata.refreshPrice,
																			function() {
																				if (User.getInstance().water < _itemdata.refreshPrice)
																				{
																					XFacade.instance.openModule(ModuleName.ChargeView);
																					return;
																				}																				
																				Signal.intance.event(SuperSaleOneView.REFRESH_ITEM, _itemdata.itemIndex);}]);
						return;
					}
					
					checkRefresh();
					break;
				case _saleItem.buyBtn:
					
					if (User.getInstance().water < _itemdata.nowPrice)
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
						return;
					}
					Signal.intance.event(SuperSaleOneView.BUY_ITEM, _itemdata.itemIndex);
					break;
				default:
					break;
			}
		}
		
		private function checkRefresh():void
		{
			if (User.getInstance().water < _itemdata.refreshPrice)
			{
				XFacade.instance.openModule(ModuleName.ChargeView);
				return;
			}
			
			Signal.intance.event(SuperSaleOneView.REFRESH_ITEM, _itemdata.itemIndex);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:SuperSaleOneVo):void
		{
			if (!value)
			{
				return;
			}
			_itemdata = value;
			_itemContainer.setData(_itemdata.itemInfo.split("=")[0], _itemdata.itemInfo.split("=")[1]);
			_saleItem.stockTxt.text = _itemdata.nowNum + "/" + _itemdata.maxNum;
			_saleItem.oriPriceTxt.text = _itemdata.oriPrice;
			_saleItem.nowPriceTxt.text = _itemdata.nowPrice;
			_saleItem.discountTxt.text = (100 - _itemdata.discount) + "%";
			_saleItem.refreshPriceTxt.text = _itemdata.refreshPrice;
			
			_saleItem.refreshBtn.skin = "SuperSaleOne/btn_" + (100 - _itemdata.discount) + ".png";
			
			_saleItem.buyBtn.disabled = false;
			if (_itemdata.nowNum <= 0)
			{
				_saleItem.buyBtn.disabled = true;
			}
		}
		
		override public function createUI():void
		{
			
		}
		
		override public function addEvent():void
		{
			super.addEvent();
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
		}
		
	}
}