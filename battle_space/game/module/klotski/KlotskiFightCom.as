package game.module.klotski
{
	import MornUI.klotski.KlotskiFightViewUI;
	
	import game.common.FilterTool;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.IBaseView;
	import game.common.baseScene.SceneType;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.bingBook.ItemContainer;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.ani.swf.MovieClip;
	import laya.events.Event;
	import laya.filters.Filter;
	import laya.maths.Rectangle;
	import laya.ui.UIUtils;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import laya.utils.Utils;

	/**
	 * KlotskiFightCom
	 * author:huhaiming
	 * KlotskiFightCom.as 2018-2-6 上午10:46:06
	 * version 1.0
	 *
	 */
	public class KlotskiFightCom
	{
		private var _ui:KlotskiFightViewUI;
		private var _items:Array = [];
		private var _rewards:Array;
		private var _data:Object;
		public var onShow:Boolean = false;
		public function KlotskiFightCom(ui:KlotskiFightViewUI)
		{
			this._ui  = ui;
			for(var i:int=0; i<5; i++){
				_items.push(new KlotskiFightItem(_ui["item_"+i]));
			}
			this._ui.visible = false;
		}
		
		public function show(step:int):void{
			onShow = true;
			this._ui.visible = true;
			this._ui.y = -_ui.height;
			Tween.to(this._ui,{y:0},300);
			this.addEvent();
			WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_SELECTSTAGE,[step]);
			
			var priceStr:String = DBKlotski.getDoublePrice();
			_ui.tfPrice.text = (priceStr+"").split("=")[1];
		}
		
		public function close():void{
			onShow = false;
			Tween.to(this._ui,{y:-_ui.height},300, null, Handler.create(this, setUiVisible));
			function setUiVisible():void{
				_ui.visible = false;
			}
			this.removeEvent();
		}
		
		private function onResult(cmd:int,... args):void{
			switch(cmd){
				case ServiceConst.KLOTSKI_SELECTSTAGE:
					_data = args[0];
					KlotskiFightItem.freshTimes = _data.refreshTimes;
					format();
					initReward();
					_ui.btnFight.disabled = XUtils.isEmpty(_data.forbiddens);
					break;
				case ServiceConst.KLOTSKI_FORBID:
					update(args[0].forbiddens);
					_data.forbiddens = args[0].forbiddens;
					initReward();
					_ui.btnFight.disabled = XUtils.isEmpty(_data.forbiddens);
					break;
				case ServiceConst.KLOTSKI_REFRESH:
					KlotskiFightItem.freshTimes = args[0].refreshTimes;
					reset(args[0].old,args[0]["new"])
					initReward();
					break;
				case ServiceConst.KLOTSKI_DOUBLE:
					_data.rangeAward = args[0]["rangeAward"]
					initReward();
					break;
			}
		}
		
		private function format():void{
			var index:int=0;
			var item:KlotskiFightItem;
			for(var i:String in _data.forbiddenShows){
				item = _items[index++];
				item.format(i,_data.forbiddenShows[i], _data.forbiddens);
			}
		}
		
		private function update(data):void{
			var index:int=0;
			var item:KlotskiFightItem;
			for(var i:String in _data.forbiddenShows){
				item = _items[index++];
				item.update(data);
			}
		}
		
		private function reset(oldInfo:Object, curInfo:Object):void{
			var index:int=0;
			var item:KlotskiFightItem;
			var uid:String;
			for(var i:String in oldInfo){
				uid = i;
			}
			var curId:String;
			for(i in curInfo){
				curId = i;
			}
			for(i in _data.forbiddenShows){
				item = _items[index++];
				if(item.uid == uid){
					delete _data.forbiddenShows[uid]
					_data.forbiddenShows[curId] = curInfo[curId];
					item.reset(curId,curInfo[curId]);
					break;
				}
			}
		}
		
		private function initReward():void{
			if(!_rewards){
				_rewards = new Array();
				var item:ItemContainer;
				for(var ii:int=0; ii<6; ii++){
					item = new ItemContainer();
					this._ui.itemSpr.addChild(item);
					item.x = ii*60;
					item.scale(0.7,0.7);
					_rewards.push(item);
				}
			}
			
			var i:int=0;
			item = _rewards[i];
			if(_data.reward){
				item.setData(_data.reward[0][0],_data.reward[0][1]*_data.rangeAward);
			}
			i++;
			
			for(i; i<_rewards.length; i++){
				item = _rewards[i];
				item.setData(_items[i-1].itemId,_data.rangeAward);
				if(checkIn(_data.forbiddens, _items[i-1].uid)){
					item.visible = true;
				}else{
					item.visible = false;
				}
			}
			
			var index:int=0;
			for(i=0; i<_rewards.length; i++){
				item = _rewards[i];
				item.x = index*60;
				if(item.visible){
					index ++;
				}
			}
			
			_ui.btnDouble.visible = (_data.rangeAward != 2)
			
			function checkIn(valObj:Object, val:*):Boolean{
				for(var i:String in valObj){
					if(valObj[i] == val){
						return true;
					}
				}
				return false;
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case _ui.btnHide:
					this.close();
					break;
				case _ui.btnFight:
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_KLOTSKI, null, Handler.create(this, onBack))
					break;
				case _ui.btnDouble:
					WebSocketNetService.instance.sendData(ServiceConst.KLOTSKI_DOUBLE);
					break;
			}
			
			function onBack():void{
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
				XFacade.instance.openModule("KlotskiView");
			}
		}
		
		private function addEvent():void{
			_ui.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_SELECTSTAGE),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_FORBID),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_REFRESH),this,onResult)
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_DOUBLE),this,onResult)
		}
		
		private function removeEvent():void{
			_ui.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_SELECTSTAGE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_FORBID),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_REFRESH),this,onResult)
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KLOTSKI_DOUBLE),this,onResult)
		}
	}
}