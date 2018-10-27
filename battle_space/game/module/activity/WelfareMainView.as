package game.module.activity 
{
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
	import game.global.vo.User;
	import game.module.friendCode.FriendCodeView;
	import game.module.levelGift.LevelGiftView;
	import game.module.lvFundation.LvFundationView;
	import game.module.weekCardCom.WeekCardView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WelfareMainView extends BaseDialog 
	{
		private var _actList:Array = [];
		
		private var actViewPool:Object;
		
		public static var CURRENT_ACT_NAME:String = "";
		
		private var helpKey:Object = { };
		private var _selectedActTypeItem:ActTypeItem; //左侧tab
		
		/**总的福利顺序列表*/
		private var shunxuList:Array;
		
		
		/**签到类型  "daily", "month"*/
		private var _signType:String;
		
		private var _isFirstEnter:Boolean = true;
		
		public function WelfareMainView() 
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
			
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new ActivityMainViewUI();
			this.addChild(_view);
			
			view.titleLabel.text = GameLanguage.getLangByKey("L_A_56095");
			
			view.activityList.itemRender = WelfareTypeItem;
			view.activityList.selectEnable = true;
			view.activityList.repeatX = 1;
			view.activityList.repeatY = 6;
			view.activityList.vScrollBarSkin = "";
			view.activityList.array = null;
			
			GameConfigManager.intance.initActivityList();
			
			actViewPool = { };
			
			// 周卡
			actViewPool['dayCard'] = new WeekCardView();
			// 7日目标
			actViewPool['7daysObjective'] = new SevenDaysAct();
			// 等级礼包
			actViewPool['levelGift'] = new LevelGiftView();
			// 基金
			actViewPool['fund'] = new LvFundationView();
			// 好友邀请
			actViewPool['invite'] = new FriendCodeView();
			//限时礼包
			actViewPool['giftbag4newplayer'] = new TimeLimitView();
			//限时任务
			actViewPool['timelimitedtask'] = new TimelimitedtaskView();
			
			shunxuList = [
				'clock', 
				'giftbag4newplayer',
				'timelimitedtask',
				'7daysObjective',
				'levelGift',
				'fund',
				'dayCard',
				'invite'
			];
			
			helpKey = {};
			helpKey['clock'] = "L_A_56014";
		}
		
		/**
		 *根据名字打开，与运营活动不一样 
		 */
		override public function show(...args):void
		{
			if(args[0])//确定打开的活动id
			{
				CURRENT_ACT_NAME = String(args[0]);
			}
			
			super.show();
			AnimationUtil.flowIn(this);
			view.noActArea.visible = true;
			stageSizeChange();
			
			WebSocketNetService.instance.sendData(ServiceConst.SIGNIN_OPEN);
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.helpBtn:
					if(helpKey[CURRENT_ACT_NAME])
					{
						XTipManager.showTip(GameLanguage.getLangByKey(helpKey[CURRENT_ACT_NAME]));
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
		private function serviceResultHandler(...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(args[0])
			{
				case ServiceConst.WELFARE_ACT_LIST:
					trace("福利活动列表数据：", args[1])
					_actList = [];
					var actInfo:Object = args[1];
					var stateInfo:Object = args[1].status;
					i = 0;
					for (var n in actInfo) {
						if (n == "status") continue;
						if (actInfo[n]) {
							_actList.push({ 
								name:n, 
								displayName:n, 
								index:i, 
								status:stateInfo[n]? stateInfo[n] : 0,
								isSelected: false
							});
							i++
						}
					}
					
					var rightShunxuList:Array = [];
					shunxuList.forEach(function(item) {
						var _act = ToolFunc.find(_actList, function(itemAct) {
							return itemAct.name == item;
						});
						if (_act) rightShunxuList.push(_act);
					});
					_actList = rightShunxuList;
					
					view.activityList.array = _actList;
					view.activityList.selectedIndex = -1;
					
					_signType = "";
					if (_actList.length > 0) {
						CURRENT_ACT_NAME = CURRENT_ACT_NAME || _actList[0].name;
						var sIndex:int = ToolFunc.findIndex(view.activityList.array, function (item) {
							return item.name == CURRENT_ACT_NAME;
						});
						
						view.noActArea.visible = false;
						activityEventHandler(ActivityEvent.SELECT_WELFARE, CURRENT_ACT_NAME, sIndex);
					}
					
					break;
				
				case ServiceConst.SIGNIN_OPEN:
					_signType = args[1]["step"];
					actViewPool['clock'] = _signType == "daily" ? new DailySignInView() : new MonthSigninView();
					
					WebSocketNetService.instance.sendData(ServiceConst.WELFARE_ACT_LIST, []);
					
					break;
			}
		}
		
		private function activityEventHandler(cmd:String, ...args):void 
		{
			
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ActivityEvent.SELECT_WELFARE:
					//trace("Tab页选中返回数据:"+args);
					//设置选中tab
//					selectedActTypeItem = view.activityList.content.getChildAt(args[1]);
					
					view.activityList.selectedIndex = args[1];
					
					if (_isFirstEnter) {
						Laya.timer.once(500, this, renderViewContainer, [args[0], args[1]]);
						_isFirstEnter = false;
					} else {
						renderViewContainer(args[0], args[1]);
					}
					break;
			}
		}
		
		private function renderViewContainer(name, index):void {
			view.viewContainer.removeChildren();
			CURRENT_ACT_NAME = name;
			var childView = actViewPool[CURRENT_ACT_NAME];
			
			Laya.timer.once(200, this, function(){
				childView.x = (view.viewContainer.width - childView.width) / 2;
				childView.y = (view.viewContainer.height - childView.height) / 2;								
				view.viewContainer.addChild(childView);
			});
			
			//第一次进入是渲染选中标签会有延迟导致选中态不显示，故在此处再补一下选中态设置
//			selectedActTypeItem = view.activityList.content.getChildAt(index);
			view.activityList.selectedIndex = index;
		}
		
		/**
		 * 设置左侧选中tab项
		 */
		private function set selectedActTypeItem(item:WelfareTypeItem):void {
			
			var len:int = view.activityList.array.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (view.activityList.content.getChildAt(i) == item)
				{
					view.activityList.content.getChildAt(i).selected = true;
				}
				else
				{
					view.activityList.content.getChildAt(i).selected = false;
				}
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
			view.viewContainer.y = ( Laya.stage.height - 580 ) / 2;
			
			view.activityList.y = ( Laya.stage.height - view.activityList.height * scaleNum ) * 2 / 3+20;
			view.noActArea.x = (Laya.stage.width - 445) / 2;
		}
		
		override public function close():void
		{
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
			
			_selectedActTypeItem = null;
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function tabsSelectHandler(index):void {
			if (index == -1) return;
			view.activityList.array.forEach(function(item, i) {
				item["isSelected"] = i == index;
			});
			
			view.activityList.refresh();
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			view.activityList.selectHandler = new Handler(this, tabsSelectHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WELFARE_ACT_LIST), this, serviceResultHandler);
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, serviceResultHandler);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(ActivityEvent.SELECT_WELFARE, this, this.activityEventHandler, [ActivityEvent.SELECT_WELFARE]);
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			if (!view || !view.off) return;
			view.off(Event.CLICK, this, this.onClick);
			view.activityList.selectHandler.recover();
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WELFARE_ACT_LIST), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SIGNIN_OPEN), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(ActivityEvent.SELECT_WELFARE,this,this.activityEventHandler);
			
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
		}
		
		
		private function get view():ActivityMainViewUI{
			return _view;
		}
	}

}