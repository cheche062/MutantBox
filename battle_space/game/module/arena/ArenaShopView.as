package game.module.arena 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.arena.ArenaShopVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.arena.ArenaShopUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaShopView extends BaseDialog 
	{
		
		/*private var _r1RewardVec:Vector.<ArenaShopVo> = new Vector.<ArenaShopVo>();
		private var _r2RewardVec:Vector.<ArenaShopVo> = new Vector.<ArenaShopVo>();
		private var _r3RewardVec:Vector.<ArenaShopVo> = new Vector.<ArenaShopVo>();*/
		
		private var _rewardVec:Vector.<ArenaShopVo> = new Vector.<ArenaShopVo>();
		
		public function ArenaShopView() 
		{
			super();
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("arenaShopResult: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.ARENA_SHOP_CHANGE:
					User.getInstance().areanCoin = args[1].arena_coin;
					User.getInstance().event();
					len = args[1].shop_log.length;
					for (i = 0; i < len ; i++)
					{
						updateBuyTimes(args[1].shop_log[i].id, args[1].shop_log[i].num);
					}
					view.goodsList.refresh();
					view.nowCoinTF.text = " " + User.getInstance().areanCoin;
					
					XItemTip.showTip(args[1].buy_item);
					//XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					
					/*var itemVo:ItemData = new ItemData();
					itemVo.iid = args[1].buy_item.split("=")[0];
					itemVo.inum = args[1].buy_item.split("=")[1];
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[[itemVo]]);*/
					break;
				case ServiceConst.ARENA_SHOP_LOG:
					len = args[1].length;
					for (i = 0; i < len ; i++)
					{
						updateBuyTimes(args[1][i].id, args[1][i].num);
					}
					view.goodsList.refresh();
					break;
				default:
					break;
			}
		}
		
		private function updateBuyTimes(id:String,time:int):void
		{
			var len:int = _rewardVec.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				if (_rewardVec[i].id == id)
				{
					_rewardVec[i].buy_times = time;
				}
			}
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case this.view.pointsIcon:
					ItemTips.showTip("12");
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			
			this.closeOnBlank = true;
			
			AnimationUtil.flowIn(this);
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_SHOP_LOG, []);
			view.nowCoinTF.text = " " + User.getInstance().areanCoin;
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new ArenaShopUI();
			this.addChild(_view);
			
			_rewardVec =  GameConfigManager.arena_shop_vec;
			
			trace("rewVec:", _rewardVec);
			
			
			view.goodsList.itemRender = ArenaShopItem;
			view.goodsList.dataSource = _rewardVec;
			
			this.view.pointsIcon.mouseEnabled = true;
			
			view.nowCoinTF.text = ": " + User.getInstance().areanCoin;
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_CHANGE),this,serviceResultHandler,[ServiceConst.ARENA_SHOP_CHANGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_LOG),this,serviceResultHandler,[ServiceConst.ARENA_SHOP_LOG]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_CHANGE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_LOG),this,serviceResultHandler);
			
			super.removeEvent();
		}
		
		
		
		private function get view():ArenaShopUI{
			return _view;
		}
		
	}

}