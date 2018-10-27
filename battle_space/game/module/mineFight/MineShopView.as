package game.module.mineFight 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.mineFight.MineShopViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineShopView extends BaseDialog 
	{
		private var _mpImg:Image;
		private var _itemArr:Array;
		
		public function MineShopView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("mineShop: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.MINE_SHOP_INIT:
					_itemArr = [];
					
					for each(var ii in args[1].shopCfg) 
					{
						_itemArr.push(ii);
					}
					
					_itemArr.sort( function(a:Object,b:Object):int{
									return Boolean(parseInt(a.id) < parseInt(b.id))? -1:1; } );
									
					view.itemList.array = _itemArr;
					
					break;
				case ServiceConst.MINE_SHOP_BUY:
					
					
					var list:Array = args[1].item;
					XItemTip.showTip(list[0][0]+"="+list[0][1]);
					/*var len:int = list.length;
					var ar:Array = [];
					for (var i:int = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);*/
					break;
				default:
					break;
			}
		}
		
		private function refreshInfo():void
		{
			view.curNum.text = User.getInstance().minePoint;
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			WebSocketNetService.instance.sendData(ServiceConst.MINE_SHOP_INIT, []);
			refreshInfo();
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new MineShopViewUI();
			this.addChild(_view);
			
			view.itemList.itemRender = MineShopItem;
			view.itemList.scrollBar.sizeGrid = "6,0,6,0";
			
			_mpImg = new Image();
			_mpImg.skin = GameConfigManager.getItemImgPath(13);
			_mpImg.x = 380;
			_mpImg.y = 480;
			_mpImg.width = _mpImg.height = 50;
			view.addChild(_mpImg);
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MINE_SHOP_INIT), this, serviceResultHandler, [ServiceConst.MINE_SHOP_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MINE_SHOP_BUY), this, serviceResultHandler, [ServiceConst.MINE_SHOP_BUY]);
			
			Signal.intance.on(User.PRO_CHANGED, this, refreshInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MINE_SHOP_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MINE_SHOP_BUY), this, serviceResultHandler);
			
			Signal.intance.off(User.PRO_CHANGED, this, refreshInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		
		private function get view():MineShopViewUI{
			return _view;
		}
	}

}