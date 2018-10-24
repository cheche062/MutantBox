package game.module.newPata
{
	import mx.modules.ModuleManager;
	
	import MornUI.newPaTa.NewPaTaUI;
	import MornUI.newPaTa.RewardItem1UI;
	import MornUI.newPaTa.RewardItem2UI;
	import MornUI.newPaTa.RewardItem3UI;
	
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	import game.common.ToolFunc;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class NewPataView extends BaseDialog
	{
		public function NewPataView()
		{
			super();
			this.bg.alpha = 1;
		}
		private function get view():NewPaTaUI {
			_view = _view || new NewPaTaUI();
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
//			trace("111111111");
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,close);
			view.map.on(Event.MOUSE_DOWN, this, onStartDrag);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_ENTER), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_ENTER_BATTLE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_BATTLE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_SAODANG), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_GET_ZHANGJIE), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PATA_RESET), this, onServerResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			sel.on(Event.CLICK,this,enterFight);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,playAni);
			view.btn_reset.on(Event.CLICK,this,onReset);
			view.btn_sweep.on(Event.CLICK,this,onSweep);
			view.btn_i.on(Event.CLICK,this,showInfo);
			Signal.intance.on("EnterPataFighting",this,requestFighting);
			
		}
		
		private function onSweep():void
		{
			sendData(ServiceConst.PATA_SAODANG);
		}
		
		private function playAni():void
		{
			if(!isPlayAni){
				return;
			}
			isPlayAni = false;
			trace("领取奖励");
			trace("reward_log:"+reward_log);
			trace("curRewardArr:"+curRewardArr);
			if(reward_log.length<3&&deleteArr.length>0&&(reward_log.length==deleteArr.length
				||reward_log.length-deleteArr.length==1))
			{
			
					Tween.to(view.box1,{alpha:0,x:view.box1.x-view.box1.width},550,Ease.circIn,null);
					Tween.to(view.box2,{alpha:0,x:view.box2.x-view.box2.width},550,Ease.circIn,null,50);
					Tween.to(view.box3,{alpha:0,x:view.box3.x-view.box3.width},550,Ease.circIn,Handler.create(this,onCom),100);
			}else
			{
				refresh();
			}
			function onCom():void
			{
				refresh();
			}
		}
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
			sel.off(Event.COMPLETE, this, this.onComplete);
			view.btn_close.off(Event.CLICK,this,close);
			view.map.off(Event.MOUSE_DOWN, this, onStartDrag);
			sel.off(Event.CLICK,this,enterFight);	
			Signal.intance.off(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,playAni);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_ENTER), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_ENTER_BATTLE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_BATTLE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_SAODANG), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_GET_ZHANGJIE), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PATA_RESET), this, onServerResult);
			view.btn_reset.off(Event.CLICK,this,onReset);
			view.btn_i.off(Event.CLICK,this,showInfo);
			if(end)
			{
				end.off(Event.CLICK,this,onComplete1);	
			}
		}
		
		private function showInfo():void
		{
			var text = GameLanguage.getLangByKey("L_A_88148").replace(/##/g, "\n");
			XTipManager.showTip(text);
		}
		
		private function onReset():void
		{
			if(leftRest==0)
			{
//				var resetPrice:Object = ResourceManager.instance.getResByURL(PATA_SWEEP_CONFIG);
//				//			trace("重置价格"+JSON.stringify(refreshPrice));
//				var times:int = (resetTimes-totelRest)+1;
//				//			trace("第"+times+"次重置条件:");
//				for each(var pri:Object in resetPrice)
//				{
//					//				trace(JSON.stringify(pri));
//					if(times>=pri["down"]&&times<=pri["up"])
//					{
//						var priS:String =  pri["price"];
//						var priArr:Array = priS.split("=");
//						var item:ItemData = new ItemData();
//						item.iid = priArr[0];
//						item.inum = Number(priArr[1]);
//						ConsumeHelp.Consume([item],Handler.create(this,resetSend),GameLanguage.getLangByKey("L_A_80238"));
//					}	
//				}
				
				XTip.showTip("L_A_76019");
				
			}else if(leftRest>0)
			{
				sendData(ServiceConst.PATA_RESET);
			}
			
		}
		
		private function resetSend():void
		{
			sendData(ServiceConst.PATA_RESET);
		}
		private function enterFight():void
		{
			XFacade.instance.openModule(ModuleName.NewPataPreView,[curId,batte_group]);
//			close();
		}
		
		private function requestFighting():void
		{
			// 战斗结束后的回调
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_PATA, [curId], Handler.create(this, function(args){
					SceneManager.intance.setCurrentScene(currSceneName, true , 1, [1]);
					XFacade.instance.openModule(ModuleName.NewPataView);
					playEndAni();
					trace('【爬塔】 战斗回调', args);
				}));
			
			close();
		}
		
		private function playEndAni():void
		{
			if(NewPataData.intance.passId==30)
			{
				trace("播放全部通关动画");
				if(!end)
				{
					end = new Animation(); 
				}
				end.loadAtlas("appRes/atlas/newPaTa/effect/endEffect.json");
				end.play(0,false);
				end.on(Event.COMPLETE, this, this.onComplete1); 
				end.width = 600;
				end.height = 166;
			
				end.pivotX = end.width/2;
				end.pivotY = end.height/2;
				end.x = view.width/2+10;
				end.y = view.height/2-100;
				
				aniImage = new Image(); 
				aniImage.skin = "newPaTa/bg7.png";
				aniImage.pivotX = 537/2; 
				aniImage.pivotY = 186/2;
				aniImage.x = view.width/2-20+10;
				aniImage.y = view.height/2-50;
				
				aniBg = new Box(); 
//				aniBg.size(Laya.stage.width, Laya.stage.height);
				this.aniBg.size(Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight));
				aniBg.graphics.clear();
				aniBg.graphics.drawRect(0,0,Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight), "#000000");
				aniBg.alpha = 0.5;
				aniBg.mouseThrough = false;
				aniBg.mouseEnabled = true;
				view.addChild(aniBg);
				view.addChild(aniImage);
				view.addChild(end);
				
			}
		}
		public function removeEndAni():void
		{
			if(aniBg)
			{
				aniBg.removeSelf();
			}
			if(aniImage)
			{
				aniImage.removeSelf();
			}
			if(end)
			{
				end.removeSelf();
			}
		
		}
		private function onComplete1():void
		{
			end.off(Event.COMPLETE, this, this.onComplete1);
			removeEndAni();
		}
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		/**
		 * 请求回来的数据处理
		 * @param args
		 * 
		 */
		private function onServerResult(...args):void{
			var cmd = Number(args[0]);
			var data = args[1];
			trace('%c 【爬塔】：', 'color: green', cmd, data);
			
			switch(cmd) {
				case ServiceConst.PATA_ENTER:
					curId = Number(data["stage_id"]);
					reward_log = data["stage_reward_log"];
					leftSweep = data["residue_sweep_times"];
					leftRest =  data["residue_reset_times"];
					resetTimes = data["reset_times"];
					maxId = data["highest_stage_id"];
					batte_group = data["battle_type"]; 
					initView();
					break;
				
				case ServiceConst.PATA_RESET:
					sendData(ServiceConst.PATA_ENTER);
					break;
				
				case ServiceConst.PATA_SAODANG:
//					if(data.rewards)
//					{
//						XFacade.instance.openModule(ModuleName.ShowRewardPanel,data);
//					}
					showRewards(data.rewards);
					sendData(ServiceConst.PATA_ENTER);
					break;
				
				case ServiceConst.PATA_GET_ZHANGJIE:
					if(curTarBox)
					{
						curTarBox.skin = "newPaTa/box_2.png";
					}
					if(curBoxEff)
					{
						curBoxEff.removeSelf();
					}
					reward_log = data["stage_reward_log"];
					setBox(); 
					playBoomAni(data["rewards"]);
				
					
					break;
			}
		}
		
		private function playBoomAni(reward:Array):void
		{
			
			if(!boom)
			{
				boom =  new Animation();
			}
			
			//					trace("cd.name:"+cd.name);
			boom.loadAtlas("appRes/atlas/newPaTa/effect/baokai.json");
			boom.on(Event.COMPLETE, this, this.onBoomComplete,[reward]);
			boom.play(0,false);
			boom.width = 1200;
			boom.height = 1200;
			boom.pivotX = boom.width/2;
			boom.pivotY = boom.height/2;
			boom.x = view.width/2;
			boom.y = view.height/2;
			if(!aniBg)
			{
				aniBg = new Box(); 
			}
			this.aniBg.size(Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight));
			aniBg.graphics.clear();
			aniBg.graphics.drawRect(0,0,Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight), "#000000");
			aniBg.alpha = 0.5;
			aniBg.mouseThrough = false;
			aniBg.mouseEnabled = true;
			
			view.addChild(aniBg);
			view.addChild(boom);
		}
		
		private function onBoomComplete(reward:Array):void
		{
			trace("reward:"+reward);
			showRewards(reward);
			removeBoomAni();
		}
		
		private function removeBoomAni():void
		{
			if(aniBg)
			{
				aniBg.removeSelf();
			}
			if(boom)
			{
				boom.removeSelf();
			}
		}
		private function showRewards(rewards:Array):void {
			var childList:Array = createRewardPanel(rewards);
			XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
		}
		/**创建奖励小图的方法*/
		private function createRewardPanel(data:Array):Array{
			// 领取成功的提示弹框
			var childList = data.map(function(item, index){
				var child:ItemData = new ItemData();
				child.iid = item[0];
				child.inum = item[1];
				return child;
			})
			return childList;
		}
	
//		private function onClickHandler(e:Event):void {
//			switch (e.target) {
//				case view.:
//			}
//		}
		public  var dragRegion:Rectangle;

		private var sel:Animation;
		private var _scrollRect:Rectangle;
		private function onStartDrag():void
		{
			this._scrollRect = new Rectangle(0,0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			this.scrollRect = _scrollRect;
				showDragRegion();
				view.map.startDrag(dragRegion,true, 0);
		}
		protected function showDragRegion():void
		{
			var dragWidthLimit:int = view.map.width *  view.map.scaleX;
			var dragHeightLimit:int = 0;
			dragRegion = new Rectangle(-(dragWidthLimit-view.width),view.map.y, dragWidthLimit-view.width, dragHeightLimit);
		}
		override public function close():void
		{
			// TODO Auto Generated method stub
			super.close();
//			trace("22222222222");
			if(end)
			{
				end.stop();
			}
			if(sel)
			{
				sel.stop();
				sel.removeSelf();
			}
			removeEndAni();
			removeBoxAni();
			removeBoomAni();
			removeItem();
		}
		
		private function removeBoxAni():void
		{
			if(boxArr)
			{
				for(var i:int=0;i<boxArr.length;i++)
				{
					var ani:Animation = boxArr[i];
					ani.removeSelf();
				}
				boxArr = [];
			}
		}
		private function removeItem():void
		{
			if(itemArr)
			{
				for(var i:int=0;i<itemArr.length;i++)
				{
					var item:* = itemArr[i];
					item.removeSelf();
				}
				itemArr = [];
			}
		}
		override public function createUI():void
		{
			addChild(view);
			// TODO Auto Generated method stub
			super.createUI();
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
			sel = null;
			end = null;
			boxArr = null;
			curBoxEff = null;
			boom = null;
			aniImage = null;
			aniBg = null;
			UIRegisteredMgr.DelUi("PataTip1");
			UIRegisteredMgr.DelUi("PataTip2");
			UIRegisteredMgr.DelUi("PataTip3");
			UIRegisteredMgr.DelUi("PaTaSelBtn");
			UIRegisteredMgr.DelUi("ClosePataViewBtn");
		}
		
		private var currSceneName;
		
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			currSceneName = SceneManager.intance.currSceneName;
			this.bg.alpha = 1;
			onStageResize();
			boxArr = []; 
			itemArr = []; 
			//创建动画
			if(!sel)
			{
				sel = new Animation(); 
				sel.name = "ani";
			}
		
		//					trace("cd.name:"+cd.name);
			sel.loadAtlas("appRes/atlas/newPaTa/effect/selEffect.json");
			sel.play(0,false);
			sel.on(Event.COMPLETE, this, this.onComplete);
			sel.width = 162;
			sel.height = 162;
			sel.pivotX = sel.width/2;
			sel.pivotY = sel.height/2;
			NewPataData.intance.init();
			sendData(ServiceConst.PATA_ENTER);	
//			curId = 25;
			
//			initView();
			super.show(args);
			UIRegisteredMgr.AddUI(view.guide1,"PataTip1");
			UIRegisteredMgr.AddUI(view.guide2,"PataTip2");
			UIRegisteredMgr.AddUI(view.guide3,"PataTip3");
			UIRegisteredMgr.AddUI(sel,"PaTaSelBtn");
			UIRegisteredMgr.AddUI(view.btn_close,"ClosePataViewBtn");
		}
		
		private function initView():void
		{
			setRewards();
			setCurSel(curId);
			setBox();
			refresh();
			setTimes();//设置次数
		}
		
		private function setTimes():void
		{
			var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
			//			trace("levelObj:"+JSON.stringify(levelObj));
			var c_name:String;
			var max_name:String;
			trace("maxId:"+maxId);
			
			var canshu:Object = ResourceManager.instance.getResByURL(PATA_CANSHU_CONFIG);
			trace("canshu:"+JSON.stringify(canshu));
			
			for(var key:String in canshu)
			{
				if(Number(key)==1)
				{
					totelRest = canshu[key]["value"]
				}
				if(Number(key)==3)
				{
					totelSweep = canshu[key]["value"]
				}
				if(Number(key)==4)
				{
					limitSweep = canshu[key]["value"] 
				} 
			}
			
			//扫荡所需的道具ID
			var sweepingNeedId = 1;
			//扫荡所需的道具数量
			var sweepingNeedNum = 0;
			
			for(var key:String in levelObj)
			{
				var id1:Number = Number(key);
				trace("id1:"+id1);
				if(id1 == curId)
				{
//					trace("stage_name:"+levelObj[key]["stage_name"]);
					c_name = levelObj[key]["stage_name"];
				}else if(curId>30)
				{
					c_name = levelObj["30"]["stage_name"]; 
				}
				if(id1 == maxId)
				{
					max_name = levelObj[key]["stage_name"];
					trace("-----------------------------------max_name:"+max_name);
					break;
				}
				if(id1<=maxId - limitSweep){
					var str_sweep_cost = levelObj[key]["sweep_cost"]; 
					if(str_sweep_cost &&str_sweep_cost.length){
						sweepingNeedId = Number(str_sweep_cost.split("=")[0]);
						sweepingNeedNum += Number(str_sweep_cost.split("=")[1]);
					}
				}
			}
			trace("max_name:"+max_name);
			view.day1.text = GameLanguage.getLangByKey("L_A_88142")+GameLanguage.getLangByKey(c_name);
			view.day2.text =GameLanguage.getLangByKey("L_A_88143")+GameLanguage.getLangByKey(max_name);
			
			
			view.resetNum.text = leftRest +"/"+totelRest;
			var toSweep:Number = maxId - limitSweep; //计算可以扫荡到哪一关,最大关卡-表里的限制
			var toSweepName:String = "";
			if(toSweep<=0)
			{
				toSweepName = "";
			}else
			{
				for(var key:String in levelObj)
				{
					var id1:Number = Number(key);
					if(id1 == toSweep)
					{
						//					trace("stage_name:"+levelObj[key]["stage_name"]);
						toSweepName = levelObj[key]["stage_name"];
					}
				}
				if(toSweepName == "")
				{
					trace("没有找到扫荡关卡:"+toSweep);
					toSweepName = "";
				}
			}
			view.sweepNum.text = GameLanguage.getLangByKey("L_A_88144")+GameLanguage.getLangByKey(toSweepName);
			view.sweepNum1.text = sweepingNeedNum;
			//道具图片
			view.imgNeed.skin = 'common/icons/jczy'+sweepingNeedId+'.png';
		}
		
		/**
		 *设置宝箱状态 
		 * 
		 */
		private function setBox():void
		{
			rewardArr = []; //保存所有可以领宝箱的关卡id
			var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
			//			trace("levelObj:"+JSON.stringify(levelObj));
			for(var key:String in levelObj)
			{
				var id:Number = Number(key);
				var rstr:String = levelObj[key]["reward_box"];
				if(rstr&&rstr!="")
				{
					rewardArr.push(id);
				}
			}
			trace("rewardArr:"+rewardArr);
			rewardDic = new Object(); //记录rewardArr里所有关卡的宝箱状态,0:不能领，1可以领，2已经领
			for(var i:int=0;i<rewardArr.length;i++)
			{
				var key:String = rewardArr[i];
				rewardDic[key] = 0;//默认不能领
			}
		
			for(var key:String in rewardDic)
			{
				if(Number(key)<curId)
				{
					rewardDic[key] = 1;//设置可以领
				}
			}
//			reward_log = [5,15]; //当前奖励领取记录
			for(var i:int=0;i<reward_log.length;i++)
			{
				var key:String = reward_log[i];
				rewardDic[key] = 2;//设置已经领
			}
			trace("rewardDic:"+JSON.stringify(rewardDic));
			
			curRewardArr = rewardArr.concat(); 
			trace("curRewardArr:"+curRewardArr);
			deleteArr = []; 
			for(var i:int=0;i<curRewardArr.length;i++)
			{
				var key:String = curRewardArr[i];
				if(rewardDic[key]==2)
				{
					deleteArr.push(Number(key));
				}else
				{
					break;//第一个不是已经取，就结束
				}
			}
			trace("deleteArr:"+deleteArr);
			pos2 = [428,563,701]; 
			//删除当前奖励数组里，排在前面的已经取的关卡
			for(var i:int=0;i<deleteArr.length;i++)
			{
				var _id:int = deleteArr[i];
				for(var j:int=curRewardArr.length-1;j>=0;j--)
				{
					if(curRewardArr[j] == _id)
					{
						if(curRewardArr.length == 3)
						{
							break;//当前奖励，至少保留3个
						}
						curRewardArr.splice(j,1);
					}
				}
			}
			trace("curRewardArr删除后:"+curRewardArr);
		}
		
		private	function refresh():void
		{
			removeBoxAni();
			view.box1.x = pos2[0];
			view.box1.alpha = 1;
			view.box2.x = pos2[1];
			view.box2.alpha = 1;
			view.box3.x = pos2[2];
			view.box3.alpha = 1;
			for(var i:int=0;i<=2;i++)
			{
				var na:String = "box"+(i+1);
				var na1:String = "s"+(i+1);
				var na2:String = "l"+(i+1);
				var id:Number = curRewardArr[i];
				var status:int = rewardDic[id];
				var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
//							trace("levelObj:"+JSON.stringify(levelObj));
				for(var key:String in levelObj)
				{
					var id1:Number = Number(key);
					if(id1 == id)
					{
						trace("stage_name:"+levelObj[key]["stage_name"]);
						(view[na1] as Label).text = levelObj[key]["stage_name"];
					}
					
				}
				//当没有奖励的时候改为预览
				//(view[na] as Image).disabled = status==0?true:false;
			
				if(status == 0)
				{
					(view[na] as Image).skin = "newPaTa/box_"+1+".png";
					(view[na2] as Image).visible = false;
				}else
				{
					(view[na] as Image).skin = "newPaTa/box_"+status+".png";
					(view[na2] as Image).visible = status==1?true:false;
					if(status==1)
					{
						trace("添加宝箱特效");
						var boxEff:Animation = new Animation()
						boxEff.loadAtlas("appRes/atlas/newPaTa/effect/guang.json");
						boxEff.play(0,true);
						boxEff.width = 300;
						boxEff.height = 300;
						boxEff.pivotX = boxEff.width/2;
						boxEff.pivotY = boxEff.height/2;
						boxEff.x = pos2[i]+64/2;
						boxEff.y = 578 + (view[na2] as Image).displayHeight/2;
						view.addChildAt(boxEff,view[na2].parent.getChildIndex(view[na2]));
						boxArr.push(boxEff);
						boxEff.name = i+1;
					}
				}
				view[na].name = status+"_"+id+"_"+(i+1);
				(view[na] as Image).on(Event.CLICK,this,pickUpReward);
			}
		}
		private function pickUpReward(e:Event):void
		{
			var status:Number = Number(e.target.name.split("_")[0]);
			var id:Number = Number(e.target.name.split("_")[1]);
			var boxId:Number = Number(e.target.name.split("_")[2]);
			//当没有奖励的时候按钮改为预览
			var isReward:int = rewardDic[id];
			if(isReward == 0){
				var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
				ToolFunc.showRewardsHandler(levelObj[id].reward_box);
				return;
			}
			isPlayAni = true;
			trace("e.target.name:"+e.target.name);
			trace("status:"+status+","+"id:"+id);
			trace("boxId:"+boxId);
			if(status==1)
			{
				curTarBox   = (e.target as Image); 
				curBoxEff = view.getChildByName(boxId); 
				sendData(ServiceConst.PATA_GET_ZHANGJIE,[id]);	
			}
		}
		
		private var PATA_LEVEL_CONFIG:String = "config/pvepata_level.json";
		private var PATA_CANSHU_CONFIG:String = "config/pvepata_config.json";
		private var PATA_SWEEP_CONFIG:String = "config/pvepata_sweep.json";
		private var curId:Number;
		private var maxId:Number;
		private var rewardArr:Array;

		private var rewardDic:Object;

		private var reward_log:Array;

		private var leftRest:Number;

		private var leftSweep:Number;

		private var limitSweep:Number;

		private var curRewardArr:Array;

		private var curTarBox  :Image;

		private var pos2:Array;

		private var deleteArr:Array;

		private var resetTimes:Number;

		private var totelRest:Number;

		private var totelSweep:Number;

		private var end:Animation;

		private var aniImage:Image;

		private var aniBg:Box;

		private var boxArr:Array;

		private var curBoxEff:Animation;

		private var boom:Animation;

		private var itemArr:Array;
		
		private var isPlayAni:Boolean = false;

		private var batte_group:String;
		private function setRewards():void 
		{
			removeItem();
			var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
//			trace("levelObj:"+JSON.stringify(levelObj));
			for(var key:String in levelObj)
			{
				var id:Number = Number(key);
				var rstr:String = levelObj[key]["reward_show"];
				var s_name:String = levelObj[key]["stage_name"];
				showReward(id,rstr,s_name);
			}
		}
		
		
		/**
		 * 
		 * @param id 关卡id
		 * @param rstr  关卡奖励字符串
		 * @param s_name 关卡名字
		 * @param canHit 关卡是否可打
		 * 
		 */
		private function showReward(id:Number, rstr:String,s_name:String):void
		{

			if(rstr&&rstr!="")
			{
				var na:String = "p"+id;
				var rarr:Array = rstr.split(";");
				
				if(rarr.length == 1)
				{
					trace("s_name---------"+s_name);
					var rItem1:RewardItem1UI = new RewardItem1UI();
					rItem1.width = 191;
					rItem1.height = 88;
					rItem1.sName.text = s_name;
					rItem1.icon.skin = GameConfigManager.getItemImgPath(rarr[0].split("=")[0]);
					rItem1.num.text = rarr[0].split("=")[1];
					rItem1.x = view[na].width;
					rItem1.y = view[na].height/2 - rItem1.height/2;
					rItem1.name = "reward1";
					itemArr.push(rItem1);
					if(id==curId)
					{
						rItem1.nor.gray = false;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else if(id>curId)
					{
						rItem1.nor.gray = true;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else
					{
						rItem1.sel.visible = true;
						rItem1.nor.gray = false;
						rItem1.gou.visible = true;
					}
					view[na].addChild(rItem1);
				}
				if(rarr.length == 2)
				{
					var rItem2:RewardItem2UI = new RewardItem2UI();
					rItem2.width = 186;
					rItem2.height = 149;
					//					rItem1.pivotX = 0;
					//					rItem1.pivotY = rItem1.height/2;
					rItem2.sName.text = s_name;
					rItem2.icon1.skin = GameConfigManager.getItemImgPath(rarr[0].split("=")[0]);
					rItem2.num1.text = rarr[0].split("=")[1];
					
					rItem2.icon2.skin = GameConfigManager.getItemImgPath(rarr[1].split("=")[0]);
					rItem2.num2.text = rarr[1].split("=")[1];
					
					rItem2.x = view[na].width;
					rItem2.y = view[na].height/2 - rItem2.height/2;
					view[na].addChild(rItem2);
//					rItem2.name = "reward";
					itemArr.push(rItem2);
					if(id==curId)
					{
						rItem1.nor.gray = false;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else if(id>curId)
					{
						rItem1.nor.gray = true;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else
					{
						rItem1.sel.visible = true;
						rItem1.nor.gray = false;
						rItem1.gou.visible = true;
					}
				}
				if(rarr.length == 3)
				{
					var rItem3:RewardItem3UI = new RewardItem3UI();
					rItem3.width = 186;
					rItem3.height = 149;
					//					rItem1.pivotX = 0;
					//					rItem1.pivotY = rItem1.height/2;
					rItem3.sName.text = s_name;
					rItem3.icon1.skin = GameConfigManager.getItemImgPath(rarr[0].split("=")[0]);
					rItem3.num1.text = rarr[0].split("=")[1];
					
					rItem3.icon2.skin = GameConfigManager.getItemImgPath(rarr[1].split("=")[0]);
					rItem3.num2.text = rarr[1].split("=")[1];
					
					rItem3.icon3.skin = GameConfigManager.getItemImgPath(rarr[2].split("=")[0]);
					rItem3.num3.text = rarr[2].split("=")[1];
					rItem3.x = view[na].width;
					rItem3.y = view[na].height/2 - rItem3.height/2;
					view[na].addChild(rItem3);
					itemArr.push(rItem3);
//					rItem3.name = "reward";
					if(id==curId)
					{
						rItem1.nor.gray = false;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else if(id>curId)
					{
						rItem1.nor.gray = true;
						rItem1.sel.visible = false;
						rItem1.gou.visible = false;
					}else
					{
						rItem1.sel.visible = true;
						rItem1.nor.gray = false;
						rItem1.gou.visible = true;
					}
				}
			}else
			{
				trace("当前关卡"+id+"奖励字符串为空");
			}
		}
		
		/**
		 * 
		 * @param id 关卡id
		 * 
		 */
		private function setCurSel(id:int):void
		{
			if(id<=30)
			{
				var na:String = "p"+id;
				sel.x = view[na].width/2;
				sel.y = view[na].height/2;
				view[na].addChild(sel);
				rePosMap(id);
			}
			else
			{
				trace("通关");
				rePosMap(id);
			}
		}
		
		/**
		 *根据关卡id重定位地图 
		 * @param id
		 * 
		 */
		private function rePosMap(id:int):void
		{
			if(id>30)
			{
				view.map.x = -(view.map.width*view.map.scaleX-view.width);
				return;
			}
			var p:Point;
			var na:String = "p"+id;
			var tar:Image =  view[na] as Image;
			var globalX:Number = tar.x+view.map.x;
//			trace("globalX:"+globalX);
//			trace("stage.width/2:"+stage.width/2);
			if(globalX>stage.width/2+80)
			{
				var dx:Number = globalX-(stage.width/2+80);//移动指定的位移
//				trace("dx:"+dx);
				view.map.x -= dx;
				if(view.map.x<=-(view.map.width*view.map.scaleX-view.width))//边界检测
				{
//					trace("越界");
//					trace("view.map.width:"+view.map.width);
					view.map.x = -(view.map.width*view.map.scaleX-view.width);
//					trace("越界调整view.map.x:"+view.map.x);
				}
			}else if(globalX<0)
			{
				view.map.x = 0;
			}
			
		}
		
		private function onComplete():void
		{
//			trace("aaaaaaaaaaa");
			sel.wrapMode = sel.wrapMode == 0 ? 1:0;
			sel.play(sel.index,false);
		}
		
		override public function onStageResize():void
		{
			// TODO Auto Generated method stub
			
//			this.size(1136 , 640);
			var scalex:Number =  Laya.stage.width / 1136; 
			var scaley:Number =  Laya.stage.height / 768; 
			if(scaley<1)
			{
				view.scaleY = scaley;
			}
			
//			view.top.scale(scalex,scaley);
//			view.size(  Laya.stage.width,Laya.stage.height);
//			reset();
//			
//			//针对页游处理
//			if(GameSetting.IsRelease){
//				this.x = ( Laya.stage.width - 1024*scaleNum) / 2;
//			}
			super.onStageResize();
			if(aniBg)
			{
				this.aniBg.size(Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight));
			}
			
//			this.y = ( Laya.stage.height - this.height*scaley) / 2;
		}
		
		private function reset():void
		{
			
		}
		
	}
}