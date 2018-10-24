package game.module.bossFight
{
	import MornUI.bossFight.BossFightItemViewUI;
	import MornUI.bossFight.DemonBandatViewUI;
	
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.global.vo.worldBoss.BossLevelVo;
	import game.global.vo.worldBoss.BossSellItemVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	
	public class BossFightItemView extends BaseDialog
	{
		private var m_data:BossFightInfoVo;
		//购买物品的信息
		private var m_type:int;
		private var m_itemId:int;
		private var	m_itemArr:Array;
		private var m_cost:int;
		public function BossFightItemView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new BossFightItemViewUI();
			this.addChild(_view);
		}
		
		/**
		 * 
		 */
		override public function show(...args):void
		{
			super.show(args);
			m_data=args[0];
			initUI();
		}
		
		private function initUI():void
		{
			view.TitleText.text=GameLanguage.getLangByKey("L_A_46034");	
			view.YourItemText.text=GameLanguage.getLangByKey("L_A_46033");
			
			view.BossFightTips.visible=false;
			var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_data.fightStep-1];
			var l_sellArr:Array=l_bossLevelVo.getSellArr();
			for (var i:int = 0; i < l_sellArr.length; i++) 
			{
				var l_image1:Image=this.view.getChildByName("ItemImage"+i)as Button;
				var l_btn:Button=this.view.getChildByName("BuyItemBtn"+i)as Button;
				var l_image:Image=this.view.getChildByName("BuyItemImage"+i) as Image;
				var l_sellItemVo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[i];
				ItemUtil.formatIcon(l_image, l_sellItemVo.price);
				l_btn.text.text=l_sellItemVo.sellPrice().toString();
			}
			initItemList();
		}
			
		/**按键监听*/
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.BuyItemBtn0:
					this.onBuyItemHandler(0);
					break;
				case this.view.BuyItemBtn1:
					this.onBuyItemHandler(1);
					break;
				case this.view.BuyItemBtn2:
					this.onBuyItemHandler(2);
					break;
				case this.view.CloseBtn:
					this.close();
					break;
				case this.view.BossFightTips.CloseBtn:
					this.view.BossFightTips.visible=false;
					break;
				case this.view.BossFightTips.BuyBtn:
					var user:User = GlobalRoleDataManger.instance.user;
					if(user.water>=m_cost)
					{
						if(m_type==0)
						{
							WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_BUY_TIME,[]);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_ITEM_BUY,[m_itemId]);
						}
					}
					else
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
					}
					
					break;
				default:
				{
					if(e.target.name.indexOf("ItemImage0")!=-1)
					{
						var l_sellItemVo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[0];
						
						ItemTips.showTip(l_sellItemVo.getItemId());
					}
					else if(e.target.name.indexOf("ItemImage1")!=-1)
					{
						var l_sellItemVo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[1];
						ItemTips.showTip(l_sellItemVo.getItemId());
					}
					else if(e.target.name.indexOf("ItemImage2")!=-1)
					{
						var l_sellItemVo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[2];
						ItemTips.showTip(l_sellItemVo.getItemId());
					}
					break;
				}
			}
		}
		
		/**购买物品*/
		private function onBuyItemHandler(p_type:int):void
		{
			var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_data.fightStep-1];
			var user:User = GlobalRoleDataManger.instance.user;
			var l_btn:Button=this.view.getChildByName("BuyItemBtn"+p_type)as Button;
			var l_image:Image=this.view.getChildByName("BuyItemImage"+p_type) as Image;
			var l_sellArr:Array=l_bossLevelVo.getSellArr();
			m_cost=parseInt(l_btn.text.text);
//			if(user.water>=parseInt(l_btn.text.text))
//			{
				this.view.BossFightTips.visible=true;
				m_type=1;
				var l_vo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[l_sellArr[p_type]-1];
				m_itemId=l_vo.sell_id;
				var item:BossFightTipsView=new BossFightTipsView(this.view.BossFightTips,1,l_vo);
//			}
//			else
//			{
//				XFacade.instance.openModule(ModuleName.ChargeView);
//			}
		}
		
		private function initItemList():void
		{
			m_itemArr=new Array();
			var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_data.fightStep-1];
			var l_sellArr:Array=l_bossLevelVo.getSellArr();
			for (var i:int = 0; i < l_sellArr.length; i++) 
			{
				var l_sellItemVo:BossSellItemVo=GameConfigManager.boss_sell_item_arr[i];
				var l_itemVo:ItemData=new ItemData();
				l_itemVo.iid=l_sellItemVo.getItemId();
				l_itemVo.inum=BagManager.instance.getItemNumByID(l_sellItemVo.getItemId());
				m_itemArr.push(l_itemVo);
			}
			view.ItemList.itemRender=BossFightItemCell;
			view.ItemList.vScrollBarSkin="";
			view.ItemList.selectEnable=true;
			view.ItemList.array=m_itemArr;
		}
		
		
		
		/**加入监听*/
		override public function addEvent():void
		{
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE,this,onResult);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,baginit,[BagEvent.BAG_EVENT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_ITEM_BUY),this,onResult,[ServiceConst.WORLD_BOSS_ITEM_BUY]);
		}
		
		/**移除监听*/
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE,this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_ITEM_BUY),this,onResult);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT,this,baginit);
		}
		
		private function baginit():void
		{
			// TODO Auto Generated method stub
			initItemList();
		}		
		
		/**
		 * 回调消息
		 * @param cmd
		 * @param args
		 * 
		 */		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.WORLD_BOSS_ITEM_BUY:
					this.view.BossFightTips.visible=false;
					break;
			}
			initItemList();
		}
		
		private function get view():BossFightItemViewUI{
			return _view;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BossFightItemView");
			m_data = null;
			m_itemArr = null;
			super.destroy(destroyChild);
		} 
		
	}
}