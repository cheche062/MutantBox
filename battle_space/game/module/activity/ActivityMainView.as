package game.module.activity 
{
	import game.module.waterLottery.WaterLotteryView;
	import MornUI.acitivity.ActivityMainViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.ActivityEvent;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.User;
	import game.module.activity.GiftPackOneView;
	import game.module.activity.SuperSaleOne.SuperSaleOneView;
	import game.module.discountShop.DiscountShopView;
	import game.module.fortress.FortressActivityView;
	import game.module.grassShip.GrassShipView;
	import game.module.kapai.KapaiView;
	import game.module.singleRecharge.SingleRechargeView;
	import game.module.tigerMachine.TigerMachine;
	import game.module.turnCards.TurnCardsView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	import org.flexunit.runner.manipulation.ISort;
	
	/**
	 * ...运营活动
	 * @author ...	
	 */
	public class ActivityMainView extends BaseDialog 
	{
		
		private var _actList:Array = [];
		
		private var actViewPool:Object;
		
		public static var CURRENT_ACT_ID:String = "-1";
		
		private var helpKey:Object = { };
		private var _selectedActTypeItem:ActTypeItem; //左侧tab
		
		private var _canChangeAct:Boolean = true;
		
		public function ActivityMainView() 
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.helpBtn:
					// tid 是每个活动的唯一标志符
					if(helpKey[curTid])
					{
						XTipManager.showTip(GameLanguage.getLangByKey(helpKey[curTid]));
					}
					break;
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
			//trace("activity: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GET_ACT_LIST:
//					CURRENT_ACT_ID = "-1";
					leftTime = args[1].dayEndSec; 
					trace("刷新时间:"+leftTime);
					var activity_data = args[1].activity;
					_actList = [];
					for(var i = 0;i<activity_data.length;i++){
						//打折商店合并，十连抽活动，在这里不显示
						if(activity_data[i].tid != 19 && activity_data[i].tid != 21){
							_actList.push(activity_data[i]);
						}
					}
					_actList.sort(sortByTID);
					_actList.forEach(function(item:Object, index:int){
						//添加初始化索引数据
						item.itemIndex = index;
					}) 
					//trace("dataSource:"+JSON.stringify(_actList));
					trace("dataSource:",_actList);
					view.activityList.array = _actList;
					while (view.viewContainer.numChildren > 0)
					{
						view.viewContainer.removeChildAt(0);
					}
					actViewInit();
					
					if (_actList.length > 0)
					{
						if(index == -1)//没有传递显示的活动id
						{
							CURRENT_ACT_ID = _actList[0].id;
							
							selectedActTypeItem = view.activityList.content.getChildAt(0);
						}else
						{
							CURRENT_ACT_ID = index;
							for(var i:int=0;i<view.activityList.array.length;i++)
							{
								var item:Object =  view.activityList.array[i];
								trace("item.actID:"+item.id);
								if(item.id == index)
								{
									selectedActTypeItem = view.activityList.content.getChildAt(i);
								}
							}
						}
					
						
						if (actViewPool[CURRENT_ACT_ID]){
							actViewPool[CURRENT_ACT_ID].x = (view.viewContainer.width - actViewPool[CURRENT_ACT_ID].width) / 2;
							actViewPool[CURRENT_ACT_ID].y = (view.viewContainer.height - actViewPool[CURRENT_ACT_ID].height) / 2;
							view.viewContainer.addChild(actViewPool[CURRENT_ACT_ID]);
						}
					}
					
					view.noActArea.visible = _actList.length==0;
					
					break;
				default:
					break;
			}
		}
		
		private function actViewInit():void
		{
			var i:int = 0;
			var len:int = _actList.length;
			for (i = 0; i < len; i++) 
			{
				if (!actViewPool[_actList[i].id])
				{
					curTid = parseInt(_actList[i].tid); 
					switch(curTid)
					{
						
						case 1://累计消耗
							actViewPool[_actList[i].id] = new CostActOne();
							break;
						case 2://单笔充值
							actViewPool[_actList[i].id] = new SingleRechargeView();
							break;
						case 3://累计充值
							actViewPool[_actList[i].id] = new ChargeActOne();
							break;
						case 4:
							
							break;
						case 5://礼包（前置购买限制）
							actViewPool[_actList[i].id] = new GiftPackOneView();
							break;
						case 6://礼包（无限制）
							break;
						case 7://七日目标
							actViewPool[_actList[i].id] = new SevenDaysAct();
							break;
						case 8://点赞活动
							actViewPool[_actList[i].id] = new FBLikeView();
							break;
						case 9://转盘
							actViewPool[_actList[i].id] = new TurntableLottleOneView();
							break;
						case 10://神秘商店
							actViewPool[_actList[i].id] = new SuperSaleOneView();
							break;
						case 11://意见反馈
							actViewPool[_actList[i].id] = new FeedBackView();
							break;
						case 12://抽宝箱
							break;
						case 13://直购礼包
							break;
						case 14://翻牌子
							actViewPool[_actList[i].id] = new TurnCardsView(_actList[i].last_reward_date_time);
							break;
						case 15://堡垒
							actViewPool[_actList[i].id] = actViewPool[_actList[i].id] || new FortressActivityView(_actList[i]);
							break;
						case 16://草船借箭
							actViewPool[_actList[i].id] = actViewPool[_actList[i].id] || new GrassShipView(_actList[i]);
							break;
						case 17://老虎机
//							trace("老虎机");
							actViewPool[_actList[i].id] = new TigerMachine(_actList[i].end_date_time,_actList[i].last_reward_date_time);
							break;
						case 18: // 卡牌大师
							actViewPool[_actList[i].id] = actViewPool[_actList[i].id] || new KapaiView(_actList[i]);
							break;
						case 19://折扣商店
							actViewPool[_actList[i].id] = new DiscountShopView(leftTime);
							break;
						case 20://宝石老虎机
							actViewPool[_actList[i].id] = new WaterLotteryView(_actList[i].last_reward_date_time);
							break;
						default:
							break;
					}
				}
			}
		}
		
		private function activityEventHandler(cmd:String, ...args):void 
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ActivityEvent.SELECT_ACTIVITY:
					trace("Tab页选中返回数据:"+JSON.stringify(args));
					//设置选中tab
					selectedActTypeItem = view.activityList.content.getChildAt(args[2]);
					
					if (CURRENT_ACT_ID === args[0])
					{
						return;
					}
					
					
					
					/*view.viewContainer.addChild(actViewPool['9']);
					return;*/
					_canChangeAct = false;
					Laya.timer.once(500, this, function() {
							CURRENT_ACT_ID = args[0];
							_canChangeAct = true;
							
							while (view.viewContainer.numChildren > 0)
							{
								view.viewContainer.removeChildAt(0);
							}
							
							if (actViewPool[CURRENT_ACT_ID])
							{
								actViewPool[CURRENT_ACT_ID].x = (view.viewContainer.width - actViewPool[CURRENT_ACT_ID].width) / 2;
								actViewPool[CURRENT_ACT_ID].y = (view.viewContainer.height - actViewPool[CURRENT_ACT_ID].height) / 2;
								view.viewContainer.addChild(actViewPool[CURRENT_ACT_ID]);
							}
						})
					
					
					break;
				default:
					break;
			}
		}
		
		/**
		 * 设置左侧选中tab项
		 */
		private function set selectedActTypeItem(item:ActTypeItem):void{
			if(item && this._selectedActTypeItem !== item){
				if(this._selectedActTypeItem){
					this._selectedActTypeItem.selected = false;
				}
				
				item.selected = true;
				this._selectedActTypeItem = item;
			}
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			view.size(Laya.stage.width , Laya.stage.height);
			var scaleNum:Number =  Laya.stage.width / view.actBG.width;
			
			view.actBG.scaleX = view.actBG.scaleY = scaleNum;
			view.actBG.y = ( Laya.stage.height - view.actBG.height * scaleNum ) / 2;
			
			view.titleArea.x = (Laya.stage.width - 1022) / 2;
			
			view.closeBtn.x = Laya.stage.width;
			
			view.viewContainer.x = Laya.stage.width - 880;
			//view.viewContainer.y = ( Laya.stage.height - view.viewContainer.height * scaleNum )*3 / 4;
			view.viewContainer.y = ( Laya.stage.height - 580 ) / 2;
			
			view.activityList.y = ( Laya.stage.height - view.activityList.height * scaleNum ) * 2 / 3+20;
			
			
			view.noActArea.x = (Laya.stage.width - 445) / 2;
			
			/*view.selectTypeArea.x = (Laya.stage.width - 978) / 2;
			_typeAreaY = view.selectTypeArea.y = (Laya.stage.height - 497) / 2;	
			
			view.leftArea.y = ( Laya.stage.height - 489) / 2;
			
			_rightAreaX = view.rightArea.x = Laya.stage.width - 377;
			view.rightArea.y = ( Laya.stage.height - 431 ) / 2;
			
			view.unitArea.scaleX = view.unitArea.scaleY = scaleNum;
			_unitAreaY = view.unitArea.y = Laya.stage.height - 310;
			view.unitArea.y = Laya.stage.height + 300;*/
		}
		
		override public function show(...args):void
		{
			if(args[0])//确定打开的活动id
			{
				index = args[0];
			}else
			{
				index = -1; 
			}
			//trace("index:"+index);
			super.show();
			AnimationUtil.flowIn(this);
			view.noActArea.visible = true;
			stageSizeChange();
			_canChangeAct  = true;
			WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST, []);
			//WebSocketNetService.instance.sendData(ServiceConst.CHECK_ACT_STATE, []);
			selectedActTypeItem = view.activityList.content.getChildAt(0);
		}
		public static const  ACTIVITY_MAIN_CLOSE:String;

		private var curTid:int;

		private var leftTime:int;

		private var index:int;
		override public function close():void
		{
			Signal.intance.event(ActivityMainView.ACTIVITY_MAIN_CLOSE);
			while (view.viewContainer.numChildren > 0)
			{
				view.viewContainer.removeChildAt(0);
			}
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
			//新手期间特殊处理,huhaiming
			if(User.getInstance().level < 3){
				super.dispose();
				XFacade.instance.disposeView(this);
			}
			
			if (_selectedActTypeItem)
			{
				_selectedActTypeItem.selected = false;
				_selectedActTypeItem = null;
			}
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new ActivityMainViewUI();
			this.addChild(_view);
			
			
			view.activityList.itemRender = ActTypeItem;
			view.activityList.repeatX = 1;
			view.activityList.repeatY = 6;
			view.activityList.vScrollBarSkin = "";
			
			GameConfigManager.intance.initActivityList();
			
			actViewPool = { };
			/*actViewPool['1'] = new FirstChargeView();
			actViewPool['2'] = new SingleRechargeView();
			actViewPool['3'] = new ChargeActOne();
			actViewPool['4'] = new CostActOne();
			actViewPool['5'] = new GiftPackOneView();
			actViewPool['8'] = new FBLikeView();
			actViewPool['9'] = new TurntableLottleOneView();
			actViewPool['10'] = new SuperSaleOneView();
			actViewPool['11'] = new FeedBackView();
			
			
			helpKey = { };
			helpKey['1'] = "L_A_56014";
			helpKey['3'] = "L_A_56015";
			helpKey['4'] = "L_A_56016";
			helpKey['5'] = "L_A_56017";
			helpKey['6'] = "L_A_84000";*/
			
			helpKey['18'] = "L_A_87064"; // 卡牌大师
			
			/*CURRENT_ACT_ID = '1';
			view.viewContainer.addChild(actViewPool['1']);*/
		}
		
		protected function sortByTID(a:Object,b:Object):int
		{
			if (parseInt(a.tid) < parseInt(b.tid))
			{
				return -1;
			}
			return 1;
		}
		
		/**保留*/
		override public function dispose():void{
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, serviceResultHandler, [ServiceConst.GET_ACT_LIST]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(ActivityEvent.SELECT_ACTIVITY, this, this.activityEventHandler, [ActivityEvent.SELECT_ACTIVITY]);
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(ActivityEvent.SELECT_ACTIVITY,this,this.activityEventHandler);
			
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
			super.removeEvent();
		}
		
		
		private function get view():ActivityMainViewUI{
			return _view;
		}
		
		
		

		
	}

}