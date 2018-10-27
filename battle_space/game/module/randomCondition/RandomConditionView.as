package game.module.randomCondition
{
	import MornUI.randomCondition.RandomConditionViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.module.bag.mgr.ItemManager;
	import game.module.bingBook.BingBookMainView;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	
	public class RandomConditionView extends BaseDialog
	{
		/**数据表*/
		private var JSON_RANDOM_RESET:String = "config/random_refresh.json";//重置价格
		private var JSON_RANDOM_REFRESH:String = "config/random_condition.json";//重置条件
		private var JSON_RANDOM_REFRESH_PRICE:String = "config/random_price.json";//重置条件

		private var curPassBox:Box;

		private var pannelData:Object;
		
		public function RandomConditionView()
		{
			super();
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent(); 
		
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.RANDOM_CONDITION_PANEL), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.RANDOM_CONDITION_RESET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.RANDOM_CONDITION_REFRESH), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			view.btn_close.on(Event.CLICK,this,close);
			view.btn_infor.on(Event.CLICK,this,onShowHelp);
		}
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			onClose();
		}
		private function onShowHelp():void
		{
			XTipManager.showTip(GameLanguage.getLangByKey("L_A_80202"));
		}
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}	
		private function onClose():void{
			super.close();
		}
		
		
		private function onRefresh(propId:int,num:Number,passId:int,firstTime:Boolean):void
		{
			var item:ItemData = new ItemData();
			item.iid = propId;
			item.inum = num;
//			trace("11111111111111111111"+num);
//			ItemManager.StringToReward(price)
			if(firstTime)
			{
//				ConsumeHelp.Consume([item],Handler.create(this,refreshSend,[passId]));
				ConsumeHelp.Consume([item],Handler.create(this,refreshSend,[passId]),GameLanguage.getLangByKey("L_A_80238"));
//				trace(JSON.stringify(item));
			}
			else
			{
				refreshSend(passId);
			}
		}
		
		private function refreshSend(passId:int):void
		{
			trace("关卡id:"+passId);
			sendData(ServiceConst.RANDOM_CONDITION_REFRESH,[passId]);	
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.RANDOM_CONDITION_PANEL:
				{
					trace("打开随机条件面板");
					trace("打开随机条件面板返回数据"+JSON.stringify(args[1]));
					pannelData = args[1];
					setResetBtn(args[1]["levels"]);
					clearRight();
					refreshBall(args[1]);
					resetPrice(args[1]["resetTimes"]);
					break;
				} 
				case ServiceConst.RANDOM_CONDITION_RESET:
				{
					sendData(ServiceConst.RANDOM_CONDITION_PANEL);	
					break;
				}
				case ServiceConst.RANDOM_CONDITION_REFRESH:
				{
					trace("刷新条件:"+JSON.stringify(args[1]));
					refreshCondition(args[2],args[3],args[1]);
					curPassBox.dataSource["condition"] = args[2];
					pannelData["refreshTimes"] = args[3];
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function setResetBtn(passObj:Object):void
		{
			var reset:Boolean = false;//默认不能重置
			for each(var data:Object in passObj)
			{
				if(data["pass"]==1)
				{
					reset = true;//只要有一个通关就可以重置
				}
			}
			view.btn_reset.disabled = !reset;
		}
		
		private function clearRight():void
		{
			view.btn_refresh.disabled = true;
			view.btn_battle.disabled = true;
			view.numTF1.text  = "";
			view.conDes.text = "";
//			view.conTitle.text = "";
			view.itemIcon1.skin = "";
			view.rewardBox.removeChildren();
		} 
		 
		private function resetPrice(time:int):void
		{
			trace(time); 
			time = time+1;//根据已经重置的次数，计算将要重置次数（配置表是将要重置的次数）
			var resetPriceObj:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_RESET);
//			trace("重置价格:"+JSON.stringify(resetPriceObj));
			var firstCost:Boolean;
//			trace("time:"+time);
			var reachRestMaxTimes:Boolean = true;
			for each(var price:Object in resetPriceObj)
			{
				if(time>=price["down"]&&time<=price["up"])
				{
					reachRestMaxTimes = false;
					var pri:String =  price["price"];
					var priArr:Array = pri.split("=");
					view.itemIcon.skin = GameConfigManager.getItemImgPath(priArr[0]);
					view.numTF.text = priArr[1];
					if(priArr[1]>0)
					{
						if(time==1)
						{
							firstCost = true;
						}else
						{ 
							var preTime1:int = time-1;
							//							trace("preTime"+preTime);
							for each(var pri3:Object in resetPriceObj)
							{		
								if(preTime1>=pri3["down"]&&preTime1<=pri3["up"])
								{
									var priS3:String =  pri3["price"];
									var priArr3:Array = priS3.split("=");
									//									trace("上一次花费:"+priArr2[1]);
									if(priArr3[1]==0)
									{
										firstCost = true;
									}
									else
									{
										firstCost = false;
									}
								}
							}
						}	
					}
				}
			}
			if(!reachRestMaxTimes)
			{
				view.btn_reset.on(Event.CLICK,this,onReset,[priArr[0],Number(priArr[1]),firstCost]);
			}else
			{
				view.btn_reset.disabled = true;
				view.itemIcon.skin = GameConfigManager.getItemImgPath(1);
				view.numTF.text = "99999999";
			}
		}
		
		private function onReset(propId:int,num:Number,firstCost:Boolean):void
		{
			var item:ItemData = new ItemData();
			item.iid = propId;
			item.inum = num; 
			if(firstCost)
			{
				ConsumeHelp.Consume([item],Handler.create(this,resetSend),GameLanguage.getLangByKey("L_A_80239"));
			}else
			{
				resetSend();
			}
		}
		
		private function resetSend():void
		{
			sendData(ServiceConst.RANDOM_CONDITION_RESET);	
		}
		
		private function refreshBall(data:Object):void
		{
			var box:Box;
			var passObj:Object = data["levels"];
//			trace("关卡数据:"+JSON.stringify(passObj));
			var selected:Image;
			var unselected:Image;
			var pass6Open:Boolean=true;//第6关默认能打，但前5关只要有一个能打，他就不能打
			for(var i:int=1;i<=6;i++)
			{
				var ballName:String = "pass"+i;
//				trace("星球名字:"+ballName);
				box = view[ballName];
				box.off(Event.CLICK,this,onClickBall);
				selected = box.getChildByName("selected") as Image;
				unselected= box.getChildByName("unselected") as Image;
				selected.visible = false;
				unselected.visible = false;
				passObj[i].passId = i; 
				box.dataSource = passObj[i];
				box.on(Event.CLICK,this,onClickBall);
//				trace("关卡是否能打"+passObj[i].pass);
			
				if(i<=5&&passObj[i].pass == 0)
				{
					pass6Open = false;
				}
				if(passObj[i].pass == 0)//1不能打，0可以打
				{
					if(i!=6)
					{
						unselected.visible = false;
						passObj[i].canHit = true;
						//					box.dataSource = 
//						box.on(Event.CLICK,this,onClickBall);
					}
					else
					{
						if(pass6Open)
						{
							unselected.visible = false;
							passObj[i].canHit = true;
							//					box.dataSource = 
							
						
						}else
						{
							unselected.visible = true;
							passObj[i].canHit = false;
//							box.off(Event.CLICK,this,onClickBall);
						}
					}
				}else
				{
					unselected.visible = true;
				
//					box.off(Event.CLICK,this,onClickBall);
				}
			}
			var allHited:Boolean = true;//默认全部打了，如果发现有一关没大就为false
			//默认选中第一个未打的副本
			for(var j:int=1;j<=6;j++)
			{
				var ballName:String = "pass"+j;
							
				box = view[ballName];
				if(box.dataSource&&box.dataSource["pass"]==0)
				{
					trace("默认选中的关卡:"+ballName);
					trace("默认选中的关卡数据box.dataSource[pass]:"+JSON.stringify(box.dataSource));
					allHited = false;
					curPassBox = box;
					setPass(curPassBox.dataSource);
					selected = box.getChildByName("selected") as Image;
					selected.visible = true;
					view.btn_refresh.disabled = false;
					view.btn_battle.disabled = false;
					break; 
				}
			}
			if(allHited)
			{
				setPass(view["pass6"].dataSource);
				box = view["pass6"];
				selected = box.getChildByName("selected") as Image;
				selected.visible = true;
			}
		}
		  
		private function onClickBall(e:Event):void
		{
			var box:Box;
			for(var i:int=1;i<=6;i++)
			{
				var ballName:String = "pass"+i;
				//				trace("星球名字:"+ballName);
				box = view[ballName];
//				box.off(Event.CLICK,this,onClickBall);
				var selected:Image = box.getChildByName("selected") as Image;
				selected.visible = false;
			}
			var target:Box = (e.target as Box);
//			trace("当前关卡数据:"+JSON.stringify(target.dataSource));
			var selected:Image = target.getChildByName("selected") as Image;
			selected.visible = true;
			if(target.dataSource)
			{
				view.btn_refresh.disabled = false;
				view.btn_battle.disabled = false;
				curPassBox = target;
				setPass(target.dataSource);		
			}
			
		}
		
		private function setPass(data:Object):void
		{
			resetBtnStatus(data.canHit);
			refreshCondition(data.condition,pannelData["refreshTimes"],data.passId);//刷新条件
			setReward(data.rewards);//设置奖励
		}
		
		private function resetBtnStatus(canHit:Boolean):void
		{
//			var passObj:Object = pannelData["levels"];
			if(!canHit)
			{
				view.btn_battle.disabled = true;
				view.btn_refresh.disabled = true;
			}else
			{
				view.btn_battle.disabled = false;
				view.btn_refresh.disabled = false;
			}
		}
		
		private function setReward(rewards:String):void
		{
			trace("奖励字符串："+rewards);
			view.rewardBox.removeChildren();
			var strArr:Array = rewards.split(";");
			var itemC:ItemCell3;
			var propStr:String;
			var propArr:Array;
			var itemD:ItemData;
			for(var i:int=0;i<strArr.length;i++)
			{
				propStr = strArr[i];
				propArr = propStr.split("=");
				itemD = new ItemData();
				itemD.iid = propArr[0];
				itemD.inum = propArr[1];
				itemC = new ItemCell3();
				itemC.data = itemD;
				view.rewardBox.addChild(itemC);
				itemC.x = i*(itemC.width+10);
			}
		}
		
		private function refreshCondition(id:int,times:int,passId:int):void
		{
			var conditionObj:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_REFRESH);
//			trace("重置条件:"+JSON.stringify(conditionObj)); 
			for each(var con:Object in conditionObj)
			{
				if(con["id"] == id)
				{
					view.conDes.text = con["TJMS"];
				}
			}
			var refreshPrice:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_REFRESH_PRICE);
//			trace("重置价格"+JSON.stringify(refreshPrice));
			times = times+1;
//			trace("第"+times+"次重置条件:");
			var firstTime:Boolean;
			for each(var pri:Object in refreshPrice)
			{
//				trace(JSON.stringify(pri));
				if(times>=pri["down"]&&times<=pri["up"])
				{
					var priS:String =  pri["price"];
					var priArr:Array = priS.split("=");
					view.itemIcon1.skin = GameConfigManager.getItemImgPath(priArr[0]);
					view.numTF1.text = priArr[1];
					if(priArr[1]>0)
					{
						if(times==1)
						{
							firstTime = true;
						}else
						{
							var preTime:int = times-1;
//							trace("preTime"+preTime);
							for each(var pri2:Object in refreshPrice)
							{
							
								if(preTime>=pri2["down"]&&preTime<=pri2["up"])
								{
									var priS2:String =  pri2["price"];
									var priArr2:Array = priS2.split("=");
//									trace("上一次花费:"+priArr2[1]);
									if(priArr2[1]==0)
									{
										firstTime = true;
									}
									else
									{
										firstTime = false;
									}
								}
							}
						}	
					}
				}	
			}
			view.btn_refresh.on(Event.CLICK,this,onRefresh,[priArr[0],Number(priArr[1]),passId,firstTime])
		}
		
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
		}
		
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args); 
			sendData(ServiceConst.RANDOM_CONDITION_PANEL);	
			AnimationUtil.flowIn(this);
		}
		private var _maxAnimation:Animation;
		override public function createUI():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			this.addChild(view);
//			_maxAnimation = new Animation();
//			_maxAnimation.interval = 150;
//			_maxAnimation.x = 500;
//			_maxAnimation.y = 166;
//			_maxAnimation.loadAtlas("appRes/atlas/effects/LH_max.json");
////			_maxAnimation.visible = false;
////			_maxAnimation.stop();
//			_maxAnimation.play(0, false);
//			Laya.timer.once(750, this, function() {_maxAnimation.visible=true } );
//			view.addChild(_maxAnimation);
			this.closeOnBlank = true;
			view.btn_battle.on(Event.CLICK,this,onFight);
		}
		
		private function onFight():void
		{
			trace(curPassBox.dataSource["passId"]);
			FightingManager.intance.getSquad(FightingManager.RANDOM_CONDITION,curPassBox.dataSource["passId"],Handler.create(this,fightOver));
			XFacade.instance.closeModule(BingBookMainView);
		}
		
		private function fightOver():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			XFacade.instance.openModule(ModuleName.RandomConditionView);
		}
		
		public function get view():RandomConditionViewUI{
			_view = _view || new RandomConditionViewUI();
			return _view;
		}
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
	}
}