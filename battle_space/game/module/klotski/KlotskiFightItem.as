package game.module.klotski
{
	import MornUI.klotski.KlotskiFightItemUI;
	
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.Tween;

	/**
	 * KlotskiFightItem
	 * author:huhaiming
	 * KlotskiFightItem.as 2018-2-6 下午12:21:34
	 * version 1.0
	 *
	 */
	public class KlotskiFightItem
	{
		private var _ui:KlotskiFightItemUI;
		private var _uid:*;
		private var _itemId:*;
		private var _item:ItemContainer
		private var _isLocked:Boolean = false;
		private var _action:Boolean = false;
		/**事件-禁用单位*/
		public static const DISABLED:String = "disabled";
		
		public static var freshTimes:int=0;
		public function KlotskiFightItem(ui:KlotskiFightItemUI)
		{
			this._ui = ui;
			this._ui.bmUnit.visible = this._ui.bmReward.visible = false;
			this._ui.scrollRect = new Rectangle(0,0,_ui.width, _ui.height);
			
			_item = new ItemContainer();
			_item.scale(0.7,0.7);
			this._ui.spItem.addChild(_item);
			
			this._ui.btnOpen.on(Event.CLICK, this, this.onClick);
			this._ui.btnSwitch.on(Event.CLICK, this, this.onClick);
			this._ui.btnRest.on(Event.CLICK, this, this.onClick);
		}
		
		private function onClick(e:Event):void{
			switch(e.currentTarget){
				case this._ui.btnOpen:
					WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_FORBID,[_uid, 1]);
					break;
				case this._ui.btnSwitch:
					changeState();
					break;
				case this._ui.btnRest:
					var priceStr = DBKlotski.getFreshPrice(freshTimes);
					var priceArr:Array = priceStr.split("=")
					var text:String = GameLanguage.getLangByKey("L_A_80413");
					
					XFacade.instance.openModule("ItemAlertView", [text, priceArr[0], priceArr[1], function(){
						refresh();
					}])
					
					
					break;
			}
		}
		
		private function refresh():void{
			WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_REFRESH,[_uid]);
		}
		
		public function format(uid:*, data,list:Object):void{
			_uid = uid;
			_itemId = data;
			var vo:Object = GameConfigManager.unit_json[uid]
			_ui.bgUnit.skin = "common/bg6_"+(vo.rarity)+".png";
			_ui.picUnit.skin = UnitPicUtil.getUintPic(uid+"",UnitPicUtil.PIC_HALF);
			_item.setData(data+"");
			_item.numTF.text = "";
			
			this._ui.bmUnit.visible = true;
			this._ui.bmReward.visible = false
			if(list && checkIn(list, uid)){
				this._ui.bmLeft.visible = this._ui.bmRight.visible = false;
				this._ui.btnOpen.visible = false;
				_isLocked = true;
				_action = true;
				_ui.bgUnit.gray = _ui.picUnit.gray = true;
				_ui.btnRest.disabled = true;
				_ui.btnSwitch.label = "L_A_80407";
			}else{
				this._ui.bmLeft.visible = this._ui.bmRight.visible = true;
				this._ui.bmLeft.x = 0;
				this._ui.bmRight.x = 82;
				this._ui.btnOpen.visible = true;
				_isLocked = false;
				_action = false;
				_ui.bgUnit.gray = _ui.picUnit.gray = false;
				_ui.btnRest.disabled = false;
				_ui.btnSwitch.label = "L_A_80406";
			}
		}
	
		private function checkIn(valObj:Object, val:*):Boolean{
			for(var i:String in valObj){
				if(valObj[i] == val){
					return true;
				}
			}
			return false;
		}
		
		public function update(list:Object):void{
			if(list && checkIn(list, _uid)){
				if(!_action){//需要动画
					_action = true;
					this._ui.bmLeft.visible = this._ui.bmRight.visible = true;
					this._ui.bmLeft.x = 0;
					this._ui.bmRight.x = 82;
					Tween.to(this._ui.bmLeft,{x:-82},200);
					Tween.to(this._ui.bmRight, {x:164},200);
				}else{
					this._ui.bmLeft.visible = this._ui.bmRight.visible = false;
				}
				this._ui.bmUnit.visible = true;
				this._ui.bmReward.visible = false;
				this._ui.btnOpen.visible = false;
				_ui.bgUnit.gray = _ui.picUnit.gray = true;
				_isLocked = true;
				_ui.btnRest.disabled = true;
				_ui.btnSwitch.label = "L_A_80407";
			}else{
				this._ui.bmUnit.visible = false;
				this._ui.bmReward.visible = true
				_ui.bgUnit.gray = _ui.picUnit.gray = false;
				_isLocked = false;
				_ui.btnRest.disabled = false;
				_ui.btnSwitch.label = "L_A_80406";
			}
		}
		
		public function reset(uid:*, data):void{
			_uid = uid;
			var vo:Object = GameConfigManager.unit_json[uid]
			_ui.bgUnit.skin = "common/bg6_"+(vo.rarity)+".png";
			_ui.picUnit.skin = UnitPicUtil.getUintPic(uid+"",UnitPicUtil.PIC_HALF);
			_item.setData(data+"");
			_item.numTF.text = "";
			_itemId = data;
		}
		
		private function changeState():void{
			var type:int = 1;
			if(_isLocked){
				type = 2;
			}
			WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_FORBID,[_uid,type]);
		}
		
		public function get uid():*{
			return _uid;
		}
		
		public function get itemId():*{
			return _itemId;
		}
	}
}