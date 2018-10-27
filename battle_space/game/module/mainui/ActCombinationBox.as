package game.module.mainui 
{
	import MornUI.mainView.ActCombinationBoxUI;
	
	import game.RedPointManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.mission.MissionStateVo;
	import game.module.klotski.KlotskiView;
	import game.module.story.StoryManager;
	import game.module.story.StoryView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ActCombinationBox extends BaseView 
	{
		
		public static const OPEN_FIRST_CHARGE:String = "openFirstChage";
		
		final var FIRSH_CHARGE:int = 0;
		final var MAIN_STORY:int = 1;
		final var DAILY_ACT:int = 2;
		final var WEL_ACT:int = 3;
		final var WORLD_BOSS:int = 4;
		final var LOOP_ACT:int = 5;
		final var THREE_GIFT:int = 6;
		final var DISCOUNT_SHOP:int = 7; 
		//首充，主线，日常，福利，世界boss，轮换活动
		public var _btnVec:Vector.<Button> = new Vector.<Button>();
		public var _btnStateVec:Array = [false,false,false,true,false,false,false];
		
		private var _todayAct:String = "";
		
		private var _timeCount:int = 0;
		
		private var _isShow:Boolean = false;
		
		private var _hasAct:Boolean = true;
		
		private var _firstChargeActID:int = 0;
		
		private var _arrFarPos:int = 530;
		private var _arrClosePos:int = 0;

		private var allChapterData:Array;

		private var _timeCount1:Number;

		private var min:Number;
		
		// 此处外界需要访问
		public static var _threeGiftID:String = "";
		private var _discountShopID:String = "";
		private var _threeGiftTime:String = "";
		private var _discountTime:String = "";
		/**所有活动的详细数据*/
		private var activityData:Array;
		
		public function ActCombinationBox() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			var arr:Array = [];
			var str:String = "";
			var i:int = 0;
			switch(e.target)
			{
				
				case view.norActBtn:
					this.view.actTips.visible = false;
					XFacade.instance.openModule(ModuleName.ActivityMainView);
					break;
				case view.firstChargeBtn:
					XFacade.instance.openModule(ModuleName.FirstChargeView,_firstChargeActID);
					break;
				case view.dayActBtn:
					openTodayAct();
					break;
				case view.welfareBtn:
					this.view.welfareTips.visible=false;
					XFacade.instance.openModule(ModuleName.WelfareMainView);
//					XFacade.instance.openModule(ModuleName.TigerMachine);
//					XFacade.instance.openModule(ModuleName.TigerRankView);
					break;
				case view.codeBtn:
					XFacade.instance.openModule(ModuleName.MysteryCodeView);
					break;
				case view.arrBtn:
					if(!_isShow)
					{
						hideBtns();
					}
					Tween.to(view.arrBtn, { x:_isShow?_arrFarPos:_arrClosePos }, 250, Ease.linearNone, new Handler(this, moveOver ));
					break;
				case view.storyBtn:
					StoryManager.intance.showStoryModule(StoryManager.TASK_PANNEL);
					break;
				case view.WBBtn:
					XFacade.instance.openModule(ModuleName.WorldBossEnterView);
					break;
				case view.threeGiftBtn:
					XFacade.instance.openModule(ModuleName.ThreeGiftView,_threeGiftID);
					break;
				case view.discountBtn:
					XFacade.instance.openModule(ModuleName.ActivityMainView,_discountShopID);
					break;
				default:
					break;
				
			}
		}
		
		private function moveOver():void
		{
			_isShow = !_isShow;
			if (!_isShow)
			{
				view.arrBtn.skin = "mainUi/mission/btn_arrow_mirror.png";
				showBtns();
				view.arrTips.visible = false;
				
			}
			else
			{
				view.arrBtn.skin = "mainUi/mission/btn_arrow.png"; 
			}
		}
		 
		private function openTodayAct():void
		{ 

//			XFacade.instance.openModule(ModuleName.PeopleFallOffView);
//			return;
			switch(_todayAct) 
			{ 
				case "baolei":
					var baoleiData = ToolFunc.find(activityData, function(item) {
						return item["tid"] == "15";
					});
					XFacade.instance.openModule(ModuleName.FortressActivityView, [baoleiData.id]);
					break;
				case "singleHero":
					XFacade.instance.openModule(ModuleName.LoneHeroView);
					break; 
				case "jiejian":
					XFacade.instance.openModule(ModuleName.GrassShipView);
					break;
				case "random":
					XFacade.instance.openModule(ModuleName.RandomConditionView);
					break; 
				case "shuaijian":
					XFacade.instance.openModule(ModuleName.PeopleFallOffView);
					break;
				case "bagua":
					XFacade.instance.openModule(ModuleName.BaguaView);
					break;
				case "banpick":
					XFacade.instance.openModule("KlotskiView");
					break;
				default: 
					break;
			} 
		}
		
		private function timeCountHandler():void
		{
			_timeCount--;
			if (_timeCount <= 0)
			{
				_timeCount = 86400;
				WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
			}
			view.timeCountLabel.text = TimeUtil.getTimeCountDownStr(_timeCount, false);
			view.discountCountLabel.text = TimeUtil.getTimeCountDownStr(_timeCount, false);
			_threeGiftTime--;
			if (_threeGiftTime <= 0)
			{
				_threeGiftTime = 999999;
				_btnStateVec[THREE_GIFT] = false;
				_btnVec[THREE_GIFT].visible = false;
				
			}
			view.tgLabel.text = TimeUtil.getTimeCountDownStr(_threeGiftTime, false);
			
		}
		
		private function adjustBtnPos():void
		{
			var len:int = _btnVec.length;
			var showNum:int = 0;
			
			for (var i:int = 0; i < len; i++) 
			{
				_btnVec[i].visible = _btnStateVec[i];
				_btnVec[i].x = 3 + showNum * 90;
				if (_btnVec[i].visible)
				{
					showNum++;
				}
			}
			
			_arrFarPos = showNum * 90;
			
			view.arrBtn.x = _arrFarPos;
			if (showNum == 0)
			{
				view.arrBtn.x = _arrClosePos;
			}
			
		}
		
		private function openFirst():void
		{
			if (_btnVec[0].visible)
			{
				XFacade.instance.openModule(ModuleName.FirstChargeView,_firstChargeActID);
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
//			trace("actListInfo: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int = 0;
			var cData:Object = { };
			switch(cmd)
			{
				// 获取当前活动列表
				case ServiceConst.GET_ACT_LIST:
					//trace("actList:"+JSON.stringify(args));
					trace("actList:",args);
					trace("args[1]:",args[1]);
					activityData = args[1].activity; 
					_timeCount = args[1].dayEndSec;
					
					
					_btnStateVec[DAILY_ACT] = false;
					_btnVec[DAILY_ACT].visible = false;
					if (activityData.length > 0)
					{
						_btnStateVec[DAILY_ACT] = true;
						_btnVec[DAILY_ACT].visible = true;
					}
					
					if (args[1].lunhuan.length == 0)
					{
						_btnStateVec[LOOP_ACT] = false;
						_btnVec[LOOP_ACT].visible = false;
					}
					else
					{
						_btnStateVec[LOOP_ACT] = true;
						_btnVec[LOOP_ACT].visible = true;
						_todayAct = args[1].lunhuan[0];
						view.dayActBtn.skin = "mainUi/icon_"+_todayAct+".png";
					}
					
					_btnStateVec[THREE_GIFT] = false;
					_btnVec[THREE_GIFT].visible = false;
					_btnStateVec[DISCOUNT_SHOP] = false;
					_btnVec[DISCOUNT_SHOP].visible = false;
					if (args[1].activity2)
					{
						for each(var obj:Object in args[1].activity2)
						{
						    if(obj["tid"]==13)
							{
								_btnStateVec[THREE_GIFT] = true;
								_btnVec[THREE_GIFT].visible = true;
								_threeGiftID = obj["id"];
								
								_threeGiftTime = parseInt(obj["end_date_time"]) - parseInt(TimeUtil.now / 1000);
							}else if(obj["tid"]==19)
							{
								
									_btnStateVec[DISCOUNT_SHOP] = true;
									_btnVec[DISCOUNT_SHOP].visible = true;
									_discountShopID = obj["id"];
							}
						}
					
					
					}
					
					_btnStateVec[WORLD_BOSS] = Boolean(args[1].worldBoss);
					_btnVec[WORLD_BOSS].visible = _btnStateVec[WORLD_BOSS];
					adjustBtnPos();
					
					
					
					break;
				case ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE:
					
					if (parseInt(args[1].status) == 2)
					{
						_btnStateVec[FIRSH_CHARGE] = false;
						_btnVec[FIRSH_CHARGE].visible = false;
						
					}
					else
					{
						_btnStateVec[FIRSH_CHARGE] = true;
						_btnVec[FIRSH_CHARGE].visible = true;
					}
					adjustBtnPos();
					break;
				case ServiceConst.WELFARE_ACT_LIST:
					this.view.welfareTips.visible = false;
					var actInfo:Object = args[1];
					var stateInfo:Object = args[1].status;
					
					i = 0;
					for (var n in stateInfo)
					{
						if (stateInfo[n] && parseInt(stateInfo[n])==1)
						{
							this.view.welfareTips.visible = true;
							break;
						}
					}
					break;
				case ServiceConst.STORY_VIEW:
					if(args[1] == false)
					{
						_btnStateVec[MAIN_STORY] = false;
						_btnVec[MAIN_STORY].visible = false;
						adjustBtnPos();
						return;
					}else
					{
						_btnStateVec[MAIN_STORY] = true;
						_btnVec[MAIN_STORY].visible = true;
					}
					
					allChapterData = []; 
					for (var key:String in args[1])
					{
						//				trace("每一章节的数据："+JSON.stringify(args[0][key]));
						allChapterData.push(args[1][key]);
					}
					var activeStoryRed:Boolean;
					activeStoryRed = false; 
					//					trace("长度:"+allChapterData.length);
					for(var i:int=0;i<allChapterData.length;i++)
					{
						var curCharacterData:Object = allChapterData[i];
						var curCharacterTask:Object = curCharacterData["task"];
						//						listData = [];
						//									trace("当前章节任务:"+JSON.stringify(curCharacterTask));
						
						for(var key:String in curCharacterTask)
						{
							var state:int = parseInt(curCharacterTask[key][0]);
							if(state==1)
							{
								activeStoryRed = true;
								break;
							}
						}
					}
					if(!activeStoryRed)
					{
						for(var i:int=0;i<allChapterData.length-1;i++)
						{
							var curCharacterData:Object = allChapterData[i];
							if(curCharacterData["rewardsGeted"]==0)
							{
								var chapterCan:Boolean = true;
								var curCharacterTask:Object = curCharacterData["task"];
								for(var key:String in curCharacterTask)
								{
									var taskState:int = parseInt(curCharacterTask[key][0]);
									if(taskState==0)
									{
										chapterCan = false;
									}
								}
								if(chapterCan)
								{
									activeStoryRed = true;
									break;
								}
							}
						}
					}
					adjustBtnPos();
					showRed(activeStoryRed);
					setTime();
					break;
				default:
					break;
			}
		}
		
		private function setTime():void
		{
			var expireArr:Array = [];
			for(var i:int=0;i<allChapterData.length;i++)
			{
				var curCharacterData:Object = allChapterData[i];
				var expiresTime:Number = parseInt(curCharacterData["expiresTime"])*1000;
				_timeCount1 = (expiresTime-TimeUtil.now)/1000;
				if(curCharacterData["isUnlocked"]==1&&_timeCount1>0)
				{
					expireArr.push(_timeCount1); 
				}
			}
			if(expireArr.length==0) 
			{
				Laya.timer.clear(this, timeCountHandler1);
				view.timeCountLabel1.text = GameLanguage.getLangByKey("L_A_83000");
				return;
			}else
			{
				min = expireArr[0];
				for(var i:int=0;i<expireArr.length;i++)
				{
					if(expireArr[i]<min)
					{
						min = expireArr[i]; 
					}
				}
				Laya.timer.clear(this, timeCountHandler1);	
				Laya.timer.loop(1000, this, timeCountHandler1);
				var leftStr:String = TimeUtil.getTimeCountDownStr(min,false);
				view.timeCountLabel1.text = leftStr;
			}
		}
		
		private function showBtns():void
		{
			var len:int = _btnVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				_btnVec[i].visible = _btnStateVec[i];
			}
		}
		
		private function hideBtns():void
		{
			var len:int = _btnVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				_btnVec[i].visible = false;
			}
		}
		
		private function timeCountHandler1():void
		{
			if(min<=0)
			{
				//				_timeCount = 0;
				Laya.timer.clear(this, timeCountHandler);
				setTime();
			}else
			{
				min--;
				var leftStr:String = TimeUtil.getTimeCountDownStr(min,false);
				view.timeCountLabel1.text = leftStr;
			}
		}
		
		override public function createUI():void{
			this._view = new ActCombinationBoxUI();
			this.addChild(_view);
			addEvent();
			
			_btnVec[0] = view.firstChargeBtn;
			_btnVec[1] = view.storyBtn;
			_btnVec[2] = view.norActBtn;
			_btnVec[3] = view.welfareBtn;
			_btnVec[4] = view.WBBtn;
			_btnVec[5] = view.dayActBtn;
			_btnVec[6] = view.threeGiftBtn;
			_btnVec[7] = view.discountBtn;
			
			this.view.arrTips.visible = false;
			this.view.actTips.visible = false;
			this.view.welfareTips.visible = false;
			
			WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
			WebSocketNetService.instance.sendData(ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE);
			WebSocketNetService.instance.sendData(ServiceConst.STORY_VIEW);
			Laya.timer.once(500, this, function()
			{
				WebSocketNetService.instance.sendData(ServiceConst.WELFARE_ACT_LIST);
			});
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, this.serviceResultHandler, [ServiceConst.GET_ACT_LIST]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE), this, this.serviceResultHandler, [ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WELFARE_ACT_LIST), this, serviceResultHandler, [ServiceConst.WELFARE_ACT_LIST]);
			Signal.intance.on(RedPointManager.STORY_MISSION_RED_CHANGE,this,showRed);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, serviceResultHandler, [ServiceConst.STORY_VIEW]);
			
			Signal.intance.on(OPEN_FIRST_CHARGE, this, openFirst);
			Laya.timer.loop(1000, this, timeCountHandler);
			
			super.addEvent();
		}
		
		private function showRed(activeStoryRed:Boolean):void
		{
			view.storyRed.visible = activeStoryRed;
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CHECK_HAS_FINISH_FIRST_CHARGE), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WELFARE_ACT_LIST), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, serviceResultHandler);
			
			Signal.intance.off(OPEN_FIRST_CHARGE, this, openFirst);
			
			Signal.intance.off(RedPointManager.STORY_MISSION_RED_CHANGE,this,showRed);
			Laya.timer.clear(this, timeCountHandler);
			
			super.removeEvent();
		}
		
		public function get view():ActCombinationBoxUI{
			return _view;
		}
	}

}