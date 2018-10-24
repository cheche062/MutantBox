package game.module.guild
{
	import MornUI.guild.GuildStoreViewUI;
	
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 公会商店
	 * @author mutantbox
	 * 
	 */
	public class GuildStoreView extends BaseView
	{
		private var storeGoodsList:Array; 
		
		public function GuildStoreView()
		{
			super();
			
		}
		
		private function addToStageHandler():void 
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_OPEN_STORE), this, this.serviceEventHandler,[ServiceConst.GUILD_OPEN_STORE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_BUY_GOODS), this, this.serviceEventHandler,[ServiceConst.GUILD_BUY_GOODS]);
//			Signal.intance.on(User.PRO_CHANGED, this, this.onUserChange);
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_OPEN_STORE, []);
		}
		
		private function removeFromStageHandler():void 
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_OPEN_STORE), this, this.serviceEventHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_BUY_GOODS), this, this.serviceEventHandler);
//			Signal.intance.off(User.PRO_CHANGED, this, this.onUserChange);
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.btn_all:
					XFacade.instance.openModule(ModuleName.StoreListAllView);
					
					break;
			}
		}
		/**获取服务器消息*/
		private function serviceEventHandler(cmd:int, ...args):void
		{
			trace("【公会商店】", args);
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.GUILD_BUY_GOODS:
					var _id = args[1];
					var data = ToolFunc.find(storeGoodsList, function(item) {
						return item.id == _id;
					});
					data.limit = data.limit - 1;
					view.dom_list.array = ToolFunc.extendDeep(storeGoodsList);
					
					//更新贡献值
					GuildMainView.state.personal_fund = GuildMainView.state.personal_fund - data["price"]["num"];
					updateUserNum(storeGoodsList[0]["price"]["id"]);
					
					XTip.showAwardNameAndNumAni([data.item.id, data.item.num]);
					
					break;
				
				case ServiceConst.GUILD_OPEN_STORE:
					storeGoodsList = args[1];
					view.dom_list.array = ToolFunc.extendDeep(storeGoodsList);
					
					updateUserNum(storeGoodsList[0]["price"]["id"]);
					
					break;
				default:
					break;
			}
		}
		
		private function updateUserNum(id):void {
			view.dom_userNum.text = GuildMainView.state.personal_fund;
			view.dom_icon.skin = GameConfigManager.getItemImgPath(id);
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildStoreViewUI();
			this.addChild(_view);
			
			view.dom_list.itemRender = StoreItem;
			view.dom_list.vScrollBarSkin = "common/vscrollBarr.png";
			view.dom_list.array = null;
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageHandler);
			this.off(Event.REMOVED, this, removeFromStageHandler);
			
			super.removeEvent();
		}
		
		private function get view():GuildStoreViewUI{
			return _view;
		}
	}
}