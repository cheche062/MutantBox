package game.module.armyGroup 
{
	import MornUI.armyGroup.ArmyGroupOutPutViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.events.Event;
	
	/**
	 * 商店（原先是产出+商店）
	 * @author ...
	 */
	public class ArmyGroupOutPutView extends BaseDialog 
	{
		/**军衔等级*/
		private var level;
		public function ArmyGroupOutPutView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.closeBtn:
					close();
					break;
			}
		}
		
	
		/**获取服务器消息*/
		private function serviceResultHandler(...args):void
		{
			trace("【国战商店】", args[0], args[1]);
			switch(args[0]) {
				case ServiceConst.ARMY_GROUP_GET_MILITARY_INFO:
					level = Number(args[1]["military_id"]);
					createDoodList();
					
					break;
				
				case ServiceConst.ARMY_GROUP_GET_STORE_BUY:
					createDoodList();
					var itemArr = args[1]["item"].split("=")
					XTip.showAwardNameAndNumAni([itemArr[0], itemArr[1]]);
					break;
			}
		}
		
		private function createDoodList():Array {
			var data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_shop.json");
			var result = ToolFunc.objectValues(data).filter(function(item) {
//				return Number(item["max_level"]) <= level;
				return {
					"id": item["id"],
					"item": item["item"],
					"price": item["price"],
					"max_level":item["max_level"],
					"curr_level": level
				}
			}).map(function(item) {
				return {
					"id": item["id"],
					"item": item["item"],
					"price": item["price"],
					"max_level":item["max_level"],
					"curr_level": level
				}
			});
			
			view.storeList.array = result;
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(...args):void{
			super.show();
			this.view.visible = true;
			AnimationUtil.flowIn(this);
			
			
			sendData(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO);
			
		}
		
		override public function close():void{
			onClose();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ArmyGroupOutPutViewUI();
			this.addChild(_view);
			this._closeOnBlank = true;
			
			view.storeList.itemRender = AGStoreItem;
			view.storeList.array = null;
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_STORE_BUY), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_STORE_BUY), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		public function get view():ArmyGroupOutPutViewUI{
			return _view;
		}
		
	}

}