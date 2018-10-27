package game.module.klotski
{
	import MornUI.klotski.KlotskiViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Rectangle;
	
	/**
	 * KlotskiView
	 * author:huhaiming
	 * KlotskiView.as 2018-2-6 上午10:38:05
	 * version 1.0
	 *
	 */
	public class KlotskiView extends BaseDialog
	{
		private var _fightCom:KlotskiFightCom;
		private var _items:Array = [];
		private var _data:Object;
		private var _selectedItem:KlotskiItem;
		private var _rewardItems:Array = [];
		public function KlotskiView()
		{
			super();
		}
		
		private function onResult(cmd:int,... args):void{
			switch(cmd){
				case ServiceConst.KLOTSKI_GETINFO:
				case ServiceConst.KLOTSKI_RESET:
					this._data = args[0];
					for(var i:int=0; i<_items.length; i++){
						if(i < this._data.step -1){
							view["item_"+i].gray = false;
							_items[i].state = KlotskiItem.DONE;
						}else if(i > this._data.step -1){
							_items[i].state = KlotskiItem.NORMAL;
							view["item_"+i].gray = true;
						}else{
							_items[i].state = KlotskiItem.NORMAL;
							view["item_"+i].gray = false;
						}
					}
					selectedItem = _items[this._data.step -1];
					this.view.btnReset.disabled = (this._data.step == 1);
					this.view.btnReward.disabled = (!this._data.isCompleted || this._data.getCompletedReward)
					
					view.tfPrice.text = DBKlotski.getResetPrice(_data.resetTimes).split("=")[1];
					break;
				case ServiceConst.KLOTSKI_REWARD:
					this._data.getCompletedReward = 1;
					this.view.btnReward.disabled = true;
					//[32155,{"getCompletedReward":1,"reward":[[20002,"1"],[20003,"1"],[30016,"5"]]}]
					var ar:Array = [];
					var list:Array = args[0].reward;
					for (i = 0; i < list.length; i++)
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
			WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_GETINFO,null);
			showReward();
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			_fightCom.close();
			this.view.btnReward.disabled = false;
			super.close();
		}
		
		private function showReward():void{
			var itemList:Array = DBKlotski.getRewadData();
			var tmp:Array;
			for(var i=0; i<itemList.length; i++){
				tmp = (itemList[i]+"").split("=");
				var item:ItemContainer = _rewardItems[i];
				if(!item){
					item = new ItemContainer(); 
					_rewardItems.push(item);
					item.x = i*90;
					view.itemSpr.addChild(item);
				}
				item.setData(tmp[0],tmp[1]);
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
				case view.btnReset:
					var priceStr = DBKlotski.getResetPrice(_data.resetTimes);
					var priceArr:Array = priceStr.split("=")
					var text:String = GameLanguage.getLangByKey("L_A_80414");
					
					XFacade.instance.openModule("ItemAlertView", [text, priceArr[0], priceArr[1], function(){
						reset();
					}])
					break;
				case view.btnHelp:
					var str:String = GameLanguage.getLangByKey("L_A_80401");
					XTipManager.showTip(str);
					break;
				case view.btnReward:
					WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_REWARD,null);
					break;
			}
		}
		
		private function reset():void{
			WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_RESET,null);
		}
		
		private function onSelected():void{
			_fightCom.show(this._data.step);
		}
		
		private function set selectedItem(item:KlotskiItem):void{
			if(_selectedItem){
				_selectedItem.selected = false;
			}
			_selectedItem = item;
			if(_selectedItem){
				_selectedItem.selected = true;
			}
		}
		
		private function get selectedItem():KlotskiItem{
			return this._selectedItem;
		}
		
		override protected function _onClick():void{
			if(this._fightCom.onShow){
				_fightCom.close();
			}else{
				this.close();
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_GETINFO),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_RESET),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_REWARD),this,onResult);
			Signal.intance.on(KlotskiItem.SELECTED, this, onSelected);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_GETINFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_RESET),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_REWARD),this,onResult);
			Signal.intance.off(KlotskiItem.SELECTED, this, onSelected);
		}
		
		override public function createUI():void{
			this._view = new KlotskiViewUI();
			this.addChild(_view);
			this.scrollRect = new Rectangle(0,10,view.width,view.height);
			for(var i:int=0; i<7; i++){
				_items.push(new KlotskiItem(view["item_"+i], i))
			}

			_fightCom = new KlotskiFightCom(view.fightCom);
			_fightCom.close();
			
			this.closeOnBlank = true;
		}
		
		private function get view():KlotskiViewUI{
			return this._view;
		}
	}
}