package game.module.mainui.speedView
{
	import game.module.bingBook.ItemContainer;
	import MornUI.homeScenceView.SpeedItemUI;
	
	import game.common.ItemTips;
	import game.global.data.DBItem;
	import game.global.data.bag.BagManager;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.module.invasion.ItemIcon;
	
	/**
	 * SpeendItem
	 * author:huhaiming
	 * SpeendItem.as 2018-1-19 上午10:39:58
	 * version 1.0
	 *
	 */
	public class SpeendItem
	{
		private var _ui:SpeedItemUI;
		private var _itemId:*;
		private var _isTimeItem:Boolean=false;
		private var _item:ItemContainer;
		public function SpeendItem(ui:SpeedItemUI, isTimeItem:Boolean=false)
		{
			super();
			this._ui = ui;
			_isTimeItem = isTimeItem;
			init();
		}
		
		public function format(itemId:*):void{
			_itemId = itemId;
			if(itemId == DBItem.WATER){
				_item.dataSource = {id:itemId};
				_ui.tfTitle.text = "L_A_17000";
				_ui.tfDes.text = "L_A_17001";
			}else{
				update();
				var db:ItemVo = DBItem.getItemData(_itemId);
				_ui.tfTitle.text = db.name+"";
				_ui.tfDes.text = db.des+"";
			}
		}
		
		public function update():void{
			trace("update.............");
			var num:int = BagManager.instance.getItemNumByID(_itemId);
			
			_item.setData(_itemId,num)
			//_item.dataSource = {id:_itemId,num:num};
			_ui.btnUse.disabled = this._ui.btnContinue.disabled = (num == 0)
		}
		
		private function init():void{
			if(_isTimeItem){
				_ui.btnSpeed.visible = true;
				_ui.btnContinue.visible = _ui.btnUse.visible = false;
			}else{
				_ui.btnSpeed.visible = false;
				_ui.btnContinue.visible = _ui.btnUse.visible = true;
			}
			
			_item = new ItemContainer();
			_ui.itemContainer.addChild(_item);
		}
	}
}