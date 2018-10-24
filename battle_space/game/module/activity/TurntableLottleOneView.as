package game.module.activity 
{
	import game.common.base.BaseView;
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import MornUI.TurntableLottleOne.TurntableLottleOneUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TurntableLottleOneView extends BaseView 
	{
		
		private var lottleRewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>(8);
		
		private var rankRewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var rotArr:Array = [[473, 58], [603, 114], [642, 230], [602, 349], 
									[473, 399], [350, 349],[302, 230], [352, 114]];
		
		private var rotIndex:int = 0;
		private var targetIndex:int = 30;
		
		
		private var getOneItemData:ItemData = new ItemData();
		private var rewardArr:Array = [];
		private var rankReward:Array = [];
		private var rankArr:Array = [];
		private var scoreReward:Array = [];
		private var myScore:int = 0;
		private var maxScore:int = 0;
		private var reIndex = 0;
		private var myReward:String = "";
		
		private var remainTime:int = 0;
		private var canLottle:Boolean = true;
		
		private var lottleItemID:int = 60006;
		private var itemPriceOne:int = 0;
		private var itemPriceTen:int = 0;
		private var onePrice:int = 0;
		private var tenPrice:int = 0;
		private var bagNum:int;
		
		public function TurntableLottleOneView() 
		{
			super();
			
			
			this.width = 880;
			this.height = 580;
			
			ResourceManager.instance.load(ModuleName.TurntableLottleOneView,Handler.create(this, resLoader));
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.oneBtn:
					
					if (!canLottle)
					{
						return;
					}
					
					if (bagNum>=itemPriceOne)
					{
						WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_DO_LOTTLE, [ActivityMainView.CURRENT_ACT_ID,"1",1]);
					}
					else
					{
						if (User.getInstance().water < onePrice)
						{
							XFacade.instance.openModule(ModuleName.ChargeView);
							return;
						}
						WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_DO_LOTTLE, [ActivityMainView.CURRENT_ACT_ID,"1",2]);
					}
					break;
				case view.tenBtn:
					
					if (!canLottle)
					{
						return;
					}
					
					if (bagNum>=itemPriceTen)
					{
						WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_DO_LOTTLE, [ActivityMainView.CURRENT_ACT_ID,"10",1]);
					}
					else
					{
						if (User.getInstance().water < tenPrice)
						{
							XFacade.instance.openModule(ModuleName.ChargeView);
							return;
						}
						WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_DO_LOTTLE, [ActivityMainView.CURRENT_ACT_ID,"10",2]);
					}
					
					break;
				case view.rankBtn:
					XFacade.instance.openModule(ModuleName.TurntableOneRankView,[myScore,rankReward]);
					break;
				case view.re_0:
				case view.re_1:
				case view.re_2:
				case view.re_3:
				case view.re_4:
					/*reIndex = e.target.name.split("_")[1];
					if (scoreReward[reIndex].status == 1)
					{
						WebSocketNetService.instance.sendData(ServiceConst.COMMON_GET_REWARD, [ActivityMainView.CURRENT_ACT_ID,scoreReward[reIndex].condition]);
					}
					else
					{
						var rw:Array = scoreReward[reIndex].reward.split(";");
						var ar:Array = [];
						var len:int = rw.length;
						for (var i:int = 0; i < len; i++)
						{
							var i2:ItemData = new ItemData();
							i2.iid = rw[i].split("=")[0];
							i2.inum = rw[i].split("=")[1];
							ar.push(i2);
						}
						XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar,true]);
					}*/
					break;
				case view.getRankReward:
					WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_RANK_REWARD, [ActivityMainView.CURRENT_ACT_ID]);
					break;
				case view.imgI0:
					ItemTips.showTip(lottleItemID);
					break;
				case view.imgI1:
					ItemTips.showTip(1);
					break;
				default:
					break;
			}
			
		}
		
		private function rotateImg():void
		{
			if (!this.view.displayedInStage)
			{
				return;
			}
			rotIndex++;
			
			view.rotatImg.x = rotArr[rotIndex%8][0];
			view.rotatImg.y = rotArr[rotIndex%8][1];
			if (rotIndex >= targetIndex)
			{
				rotIndex = targetIndex;
				canLottle = true;
				Laya.timer.once(750, this, function() {
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[[this.getOneItemData]]);
					})
				
				return;
			}
			var t = 20;
			if (rotIndex > 5)
			{
				t = 10;
			}
			
			if (rotIndex > 30)
			{
				t = 30;
			}
			
			if (rotIndex > 40)
			{
				t = 200;
			}
			
			if ((targetIndex - rotIndex) < 5)
			{
				t = 500;
			}
			
			Laya.timer.once(t, this, rotateImg);
		}
		
		private function initData():void
		{
			for (var i:int = 0; i < 8; i++) 
			{
				if (!lottleRewardVec[i])
				{
					lottleRewardVec[i] = new ItemContainer();
					lottleRewardVec[i].needBg = false;
					view["r_" + i].addChild(lottleRewardVec[i]);
				}
				
				if (rewardArr[i])
				{
					lottleRewardVec[i].setData(rewardArr[i].item.split("=")[0], rewardArr[i].item.split("=")[1]);
				}
				else
				{
					lottleRewardVec[i].setData(i, i + 1);
				}
				
				
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			if (!view.displayedInStage)
			{
				return;
			}
			trace("lottle:", args);
			
			var len:int = 0;
			var i:int = 0;
			var rw,ar:Array = [];
			switch(cmd)
			{
				case ServiceConst.TURNTABLE_ONE_INIT:
					
					rewardArr = []
					for each(var r1 in args[0].config.lucky_item) 
					{
						rewardArr.push(r1);
					}
					
					rankReward = []
					for each(var r2 in args[0].config.lucky_rank_reward) 
					{
						rankReward.push(r2);
					}
					
					
					lottleItemID = args[0].config.lucky_param[1].value.split("=")[0];
					
					itemPriceOne = args[0].config.lucky_param[1].value.split("=")[1];
					onePrice = args[0].config.lucky_param[3].value.split("=")[1];
					
					itemPriceTen = args[0].config.lucky_param[2].value.split("=")[1];			
					tenPrice = args[0].config.lucky_param[4].value.split("=")[1];
					
					view.oneTxt.text = "x" + onePrice;
					view.tenTxt.text = "x" + tenPrice;
					
					//scoreReward = args[0].config;
					//maxScore = scoreReward[4].condition;
					
					myScore = args[0].score;
					
					//
					
					remainTime = parseInt(args[0].basic.end_date_time) - parseInt(TimeUtil.now / 1000);
					
					if (remainTime < 0)
					{
						remainTime = parseInt(args[0].basic.last_reward_date_time) - parseInt(TimeUtil.now / 1000);
						view.lottleArea.visible = false;
						view.getArea.visible = true;
						view.noRewardTips.visible = true;
						view.rotatImg.visible = false;
						view.oneBtn.visible = false;
						view.tenBtn.visible = false;
						
						/*view.getRankReward.disabled = false;
						if (args[0].wheel_rank_reward_status == 1)
						{
							view.getRankReward.disabled = true;
						}*/
						
						showRankReward(args[0].myrank);
					}
					
					initData();
					remainTimeCount();
					checkRewardState();
					checkLottlePrice();
					break
				case ServiceConst.TURNTABLE_ONE_DO_LOTTLE:
					rw = args[0].items;
					
					if (args[0].num == 1)
					{
						targetIndex = parseInt(args[0].id)-1 + 32;
						getOneItemData.iid = rw[0][0];
						getOneItemData.inum = rw[0][1];
						rotIndex %= 8;
						/*rotIndex = 0;
						view.rotatImg.x = rotArr[rotIndex][0];
						view.rotatImg.y = rotArr[rotIndex][1];*/
						canLottle = false;
						rotateImg();
					}
					else
					{
						ar = [];
						len = rw.length;
						for (i = 0; i < len; i++)
						{
							var i1:ItemData = new ItemData();
							i1.iid = rw[i][0];
							i1.inum = rw[i][1];
							ar.push(i1);
						}
						
						XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					}
					
					myScore+= parseInt(args[0].score);
					WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_INIT, ActivityMainView.CURRENT_ACT_ID);
					
					break;
				case ServiceConst.COMMON_GET_REWARD:
					
					rw = scoreReward[reIndex].reward.split(";");
					ar = [];
					len = rw.length;
					for (i = 0; i < len; i++)
					{
						var i2:ItemData = new ItemData();
						i2.iid = rw[i].split("=")[0];
						i2.inum = rw[i].split("=")[1];
						ar.push(i2);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					scoreReward[reIndex].status = 2;
					checkRewardState();
					break;
				case ServiceConst.TURNTABLE_ONE_RANK_REWARD:
					
					rw = myReward.split(";");
					ar = [];
					len = rw.length;
					for (i = 0; i < len; i++)
					{
						var i3:ItemData = new ItemData();
						i3.iid = rw[i].split("=")[0];
						i3.inum = rw[i].split("=")[1];
						ar.push(i3);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					view.getRankReward.disabled = true;
					break;
				default:
					break;
			}
		}
		
		private function showRankReward(myrank:int):void
		{
			//rankRewardVec
			
			var len:int = 0;
			var i:int = 0;
			
			var ar:Array = rankReward;
			len = ar.length;
			
			var down:int = 1;
			for (i = 0; i < len; i++) 
			{
				//var rank:Array = ar[i].split("|")[0].split("-");
				
				if (myrank <= ar[i].down)
				{
					myReward = ar[i].reward
					break;
				}
			}
			
			view.finalRankTxt.text = myrank;
			
			if (myrank == 0 || myrank > 100)
			{
				myReward = "";
				view.getRankReward.disabled = true;
			}
			else
			{
				
				var arr:Array = myReward.split(";");
				len = arr.length;
				for (i = 0; i < len; i++) 
				{
					view.noRewardTips.visible = false;
					if (!rankRewardVec[i])
					{
						rankRewardVec[i] = new ItemContainer();
						rankRewardVec[i].scaleX = rankRewardVec[i].scaleY = 0.8;
						view.getArea.addChild(rankRewardVec[i]);
					}
					
					if (len < 4)
					{
						rankRewardVec[i].y = 120;// + view.getArea.y;
					}
					else
					{
						rankRewardVec[i].y = 80+80 * parseInt(i / 3);// + view.getArea.y;
					}
					
					rankRewardVec[i].x = 40 + 95 * parseInt(i % 3);
					
					rankRewardVec[i].setData(arr[i].split("=")[0], arr[i].split("=")[1]);
					
				}
			}
			
			
			
			//view.getArea.visible = false;
		}
		
		override public function dispose():void		
		{
			
		}
		
		private function checkRewardState():void
		{
			view.myScoreTxt.text = GameLanguage.getLangByKey("L_A_49053") + myScore;
			
			
		}
		
		private function remainTimeCount():void
		{
			remainTime--;
			if (remainTime <= 0)
			{
				view.timeTxt.text = "00:00:00";
				return;
			}
			view.timeTxt.text = TimeUtil.getTimeCountDownStr(remainTime,false);
		}
		
		private function checkLottlePrice():void
		{
			bagNum = BagManager.instance.getItemNumByID(lottleItemID);
			
			view.imgI0.skin = GameConfigManager.getItemImgPath(lottleItemID);
			view.itemBagNum.text = bagNum;
			view.waterNum.text = User.getInstance().water;
			
			if (bagNum>=itemPriceOne)
			{
				view.lottleImg0.skin = GameConfigManager.getItemImgPath(lottleItemID);
				view.oneTxt.text = "x"+itemPriceOne;
			}
			else
			{
				view.lottleImg0.skin = GameConfigManager.getItemImgPath(1);
				view.oneTxt.text = "x"+onePrice;
			}
			
			if (bagNum>=itemPriceTen)
			{
				view.lottleImg1.skin = GameConfigManager.getItemImgPath(lottleItemID);
				view.tenTxt.text = "x"+itemPriceTen;
			}
			else
			{
				view.lottleImg1.skin = GameConfigManager.getItemImgPath(1);
				view.tenTxt.text = "x"+tenPrice;
			}
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function addToStageEvent():void 
		{
			rotIndex = 0;
			canLottle = true
			view.rotatImg.x = rotArr[rotIndex][0];
			view.rotatImg.y = rotArr[rotIndex][1];
			
			
			view.on(Event.CLICK, this, this.onClick);
			
			WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_INIT, ActivityMainView.CURRENT_ACT_ID);
			Laya.timer.loop(1000, this, this.remainTimeCount);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_INIT), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_DO_LOTTLE), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.COMMON_GET_REWARD), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_RANK_REWARD), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, checkLottlePrice);
			Signal.intance.on(User.PRO_CHANGED, this, checkLottlePrice);
			
		}
		
		private function removeFromStageEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			rotIndex = targetIndex;
			Laya.timer.clear(this, this.remainTimeCount);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_INIT), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.COMMON_GET_REWARD), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_DO_LOTTLE), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_RANK_REWARD), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, checkLottlePrice);
			Signal.intance.off(User.PRO_CHANGED, this, checkLottlePrice);
		}
		
		override public function show(...args):void{
			super.show();
			
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function resLoader():void
		{
			this._view = new TurntableLottleOneUI();
			//view.cacheAsBitmap = true;
			this.addChild(_view);
			
			
			view.imgI0.skin = GameConfigManager.getItemImgPath(lottleItemID);
			view.imgI0.mouseEnabled = true;
			
			view.imgI1.skin = GameConfigManager.getItemImgPath(1);
			view.imgI1.mouseEnabled = true;
			
			view.rotatArrow.visible = false;
			view.getArea.visible = false;
			
			
			addEvent();
			initData();
			
			if (view.displayedInStage)
			{
				addToStageEvent();
			}
		}
		
		override public function createUI():void{			
			
		}
		
		override public function addEvent():void {
			
			if (!view)
			{
				return;
			}
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			
			super.removeEvent();
		}
		
		private function get view():TurntableLottleOneUI{
			return _view;
		}
	}

}