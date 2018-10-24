package game.module.kapai
{
	import MornUI.kapai.KapaiMainViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 卡牌大师  主视图
	 * @author hejianbo
	 * 2018-05-25
	 */
	public class KapaiView extends BaseView
	{
		
		/**活动详细信息*/
		private var info:Object
		
		//此处的state  分散的页签视图间是共享的
		/**卡牌详细数据  */
		public static var state:KapaiDataVo = new KapaiDataVo();
		
		public function KapaiView(data:Object)
		{
			super();
			info = data;
			this.width = 838;
			this.height = 497;
			
			ResourceManager.instance.load(ModuleName.KapaiView, Handler.create(this, resLoader));
		}
		
		private function resLoader(...args):void{
			
			trace("【卡牌大师 】", info.id, info);
			this.addChild(view);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
			var homePageView:HomePageView = new HomePageView();
			var drawCardView:DrawCardView = new DrawCardView();
			var swapCardView:SwapCardView = new SwapCardView();
			var rankCardView:RankCardView = new RankCardView();
			
			view.dom_viewStack.setItems([homePageView, drawCardView, swapCardView, rankCardView]);
			view.dom_tab.selectedIndex = -1;
			
			if (view.displayedInStage) {
				addToStageEvent();
			}
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			var cmd = args[0];
			var result = args[1];
			trace('%c 【卡牌大师】', 'color: green', cmd, result);
			switch(cmd){
				// 打开
				case ServiceConst.KAPAI_OPEN:
					state.init(result);
					
					if (view.dom_tab.selectedIndex == 0) {
						tabHandler(0);						
					} else {
						view.dom_tab.selectedIndex = 0;
					}
					
					break;
				
				//抽卡
				case ServiceConst.KAPAI_DRAW_CARD:
					state.drawCard(result);		
					refreshCurrentView();
					
					XFacade.instance.openModule(ModuleName.CardShowView, [result["cards"]]);
					
					break;
				
				//卡牌兑换点数
				case ServiceConst.KAPAI_CARD_NUM:
					state.cardToPoint(result);
					
					var child1:SwapCardView = view.dom_viewStack.selection;
					if (child1.refreshCards) {
						child1.refreshCards(result); 
					} else {
						child1.update(state);
					}
					
					break;
				
				//点数兑换卡牌
				case ServiceConst.KAPAI_NUM_CARD:
					state.pointToCard(result);
					
					var child2:SwapCardView = view.dom_viewStack.selection;
					if (child2.refreshCards) {
						child2.refreshCards(result); 
					} else {
						child2.update(state);
					}
					break;
				
				//领取卡牌奖励
				case ServiceConst.KAPAI_CARD_REWARD:
					state.rewardUpdate(result);
					
					// 显示奖励列表
					var targetData:Object = ToolFunc.getTargetItemData(state.card_exchange, "id", result["id"]); 
					ToolFunc.showRewardsHandler(targetData["reward"]);
					
					refreshCurrentView();
					
					break;
				
				//打开排行榜
				case ServiceConst.KAPAI_RANK:
					state.rankUpdate(result);
					
					var child3:RankCardView = view.dom_viewStack.selection;
					child3 && child3.refreshRank && child3.refreshRank(state); 
					
					break;
				
				// 领取排行榜奖励
				case ServiceConst.KAPAI_RANK_REWARD:
					state.getRankReward(result);
					
					ToolFunc.showRewardsHandler(result["reward"]);
					
					break;
			}
			
			trace('%c 【卡牌大师 state】', 'color: green', state);
		}
		
		/**页签切换*/
		private function tabHandler(index:int):void {
			view.dom_viewStack.selectedIndex = index;
			refreshCurrentView();
		}
		
		/**更新当前页*/
		private function refreshCurrentView():void {
			var child:HomePageView = view.dom_viewStack.selection;
			child && child.update && child.update(state);
		}
		
		public function addToStageEvent():void{
			view.dom_tab.selectHandler = Handler.create(this, tabHandler, null, false);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_OPEN), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_DRAW_CARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_CARD_NUM), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_NUM_CARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_CARD_REWARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_RANK), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.KAPAI_RANK_REWARD), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			view.dom_viewStack.items.forEach(function(item:HomePageView) {
				item.init && item.init();
			});
			
			// 进入
			sendData(ServiceConst.KAPAI_OPEN, [info.id]);
		}
		
		public function removeFromStageEvent():void{
			view.dom_tab.selectHandler.clear();
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_OPEN), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_DRAW_CARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_CARD_NUM), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_NUM_CARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_CARD_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_RANK), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.KAPAI_RANK_REWARD), this, onResult);			
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			view.dom_viewStack.items.forEach(function(item:HomePageView) {
				item.reset && item.reset();
			});
		}
		
		public function get view():KapaiMainViewUI{
			_view = _view || new KapaiMainViewUI();
			return _view;
		}
	}
}