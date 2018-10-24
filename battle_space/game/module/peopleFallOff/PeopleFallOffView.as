package game.module.peopleFallOff
{
	import MornUI.PeopleFallOff.PeopleFallOffUI;
	
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
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class PeopleFallOffView extends BaseDialog
	{
		private var itemArr:Array; 

		private var curRate:String;  
		private var outEffect:Animation;
		public function PeopleFallOffView()
		{
			super();
		}
		override public function createUI():void
		{
			super.createUI();
			this.closeOnBlank = true;
			isModel = true;
			addChild(view); 
			_maxAnimation = new Animation();
			_maxAnimation.interval = 150;
			_maxAnimation.x = 130;
			_maxAnimation.y = 304;
			_maxAnimation.loadAtlas("appRes/atlas/effects/LH_max.json");
			_maxAnimation.visible = false;
			_maxAnimation.stop();
			view.addChild(_maxAnimation);
			
			outEffect = new Animation();
			outEffect.interval = 150;
			outEffect.x = 130-72;
			outEffect.y = 304+5;
			outEffect.loadAtlas("appRes/atlas/effects/PeopleFallOffEffect1.json");
//			outEffect.visible = false;
			outEffect.play();
			view.addChild(outEffect);
			view.btn_battle.on(Event.CLICK,this,onFight);	
		}
		private function onFight():void
		{
//			trace(curPassBox.dataSource["passId"]);
			FightingManager.intance.getSquad(FightingManager.PEOPLE_FALL_OFF,[],Handler.create(this,fightOver));
			XFacade.instance.closeModule(PeopleFallOffView);
		}
		private function fightOver():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			XFacade.instance.openModule(ModuleName.PeopleFallOffView);
		}
		public function get view():PeopleFallOffUI{
			if(!_view)
			{
				_view ||= new PeopleFallOffUI;
			}
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,this.close);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PEOPLE_FALL_OFF_PANNEL), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PEOPLE_FALL_OFF_RESET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PEOPLE_FALL_OFF_RATE), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PEOPLE_FALL_OFF_ADDPOS), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			view.btn_infor.on(Event.CLICK,this,onShowHelp);
		}
		private function onShowHelp():void
		{
			XTipManager.showTip(GameLanguage.getLangByKey("L_A_80606"));
		}
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			onClose();
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				case ServiceConst.PEOPLE_FALL_OFF_PANNEL:
				{
					trace("打开人数衰减面板：");
					trace("面板数据预览:"+JSON.stringify(args[1]));
					var curPass:int = args[1]["level"];
					curFinish = args[1]["finished"]==0?false:true;
//					curRate = args[1]["rewardRate"];
//					refreshTime = args[1]["awardTimes"];
					setPass(curPass,curFinish,args[1]["npcHead"]);
					setResetBtn(curPass,curFinish,args[1]["resetTimes"]);
					setReward(args[1]["rewards"]);
//					setReward("13=1000;13=1000");
					setRate(args[1]["rewardRate"],args[1]["awardTimes"],true);
					setRightTxt(args[1]["npcLevel"],args[1]["unitNum"]);
					setAddMemberBtn(args[1]["unitNum"]);
					setBattleBtn();
//					_motionTarget = args[1]["rewardRate"];
//					onReset(args[1]["resetTimes"]);
//					onRandom(args[1]["awardTimes"]);
					break;
				}
				case ServiceConst.PEOPLE_FALL_OFF_RESET:
				{
					sendData(ServiceConst.PEOPLE_FALL_OFF_PANNEL);
					break;
				}
				case ServiceConst.PEOPLE_FALL_OFF_RATE:
				{
//					trace("刷新概率返回数据"+JSON.stringify(args[1]));
					setRate(args[1],args[2],false);
//					_motionTarget = args[1];
//					sendData(ServiceConst.PEOPLE_FALL_OFF_PANNEL);
					break;
				}
				case ServiceConst.PEOPLE_FALL_OFF_ADDPOS:
				{
//					trace("增加位置借口返回数据:"+JSON.stringify(args[1]));
					setMaxNum(args[1]);//这个方法会复用
					break;
				}
			}
		}
		
		private function setBattleBtn():void
		{
			if(curFinish)
			{
				view.btn_battle.disabled = true;
			}else
			{
				view.btn_battle.disabled = false;
			}
		}
		
		private function setAddMemberBtn(unitNum:int):void
		{
			var paramObject:Object = ResourceManager.instance.getResByURL(PEOPLE_OFF_PARAM);
		
			var costStr:String = paramObject["1"]["value"];
//			trace("加位置消耗:"+costStr);
			var costArr:Array = costStr.split("=");
			view.itemIcon.skin = GameConfigManager.getItemImgPath(costArr[0]);
			view.numTf.text = costArr[1];
			if(unitNum>=6||curFinish)
			{ 
				view.btn_addPos1.visible = false;
				view.itemIcon.visible = false;
				view.numTf.visible = false;
				view.btn_addPos.disabled = true;
			}else 
			{
				view.btn_addPos1.visible = true;
				view.itemIcon.visible = true;
				view.numTf.visible = true;
				view.btn_addPos.disabled = true;
			}
			view.btn_addPos1.label = "       "+GameLanguage.getLangByKey("L_A_80603");
			view.btn_addPos1.on(Event.CLICK,this,onAddPosCost,[costArr[0],Number(costArr[1])]);
		}
		
		private function onAddPosCost(propId:int,propNum:Number):void
		{
			var item:ItemData = new ItemData();
			item.iid = propId;
			item.inum =  propNum;
			if(propNum>0)
			{
				ConsumeHelp.Consume([item],Handler.create(this,onAddPos),GameLanguage.getLangByKey("L_A_80607"));
			}	
		}
		
		private function onAddPos():void
		{
			sendData(ServiceConst.PEOPLE_FALL_OFF_ADDPOS);
		}
		
		private function setRightTxt(npclv:int,unitNum:int):void
		{
			view.tf_enemyLevel.text = GameLanguage.getLangByKey("L_A_80604")+npclv;
			setMaxNum(unitNum);//这个方法会复用
			
		}
		
		private function setMaxNum(unitNum:int):void
		{
			view.tf_memberAllow.text = GameLanguage.getLangByKey("L_A_80605")+unitNum;
			setAddMemberBtn(unitNum);
		}
		private var _motionArr:Array = ["1","1.5", "2", "2.5"];
		private var _motionIndex:int = 0;
//		private var _motionTarget:Number = 2.5;
		private function playRateMotion(_motionTarget:Number):void
		{
			view.maxImg.visible = false;
			setRateTxt(_motionArr[_motionIndex%4]);
			_motionIndex++;
			view.btn_random.disabled = true;
			if (_motionIndex < 20)
			{
				Laya.timer.once(50, this, playRateMotion,[_motionTarget]);
				
			}
			else
			{
				_motionIndex = 0;
				view.btn_random.disabled = false;
//				view.maxImg.disabled = false;
				setRateTxt(_motionTarget);
				
				if (_motionTarget == 3)
				{
					_maxAnimation.visible = true;
					_maxAnimation.play(0, false);
					Laya.timer.once(750, this, function() {_maxAnimation.visible=false;view.maxImg.visible = true} );
				}
			}
		}
		private function setRateTxt(rate:String):void
		{
			var color:String = "";
			view.maxImg.visible = false;
			view.btn_random.visible = true;
			switch(rate.toString())
			{
				case "1":
					view.xImg.skin = "peopleFallOff/x1.png"
					view.n1Txt.text = 1;
					view.n3Txt.text = 0;
					color = "#79D3FF";
					break;
				case "1.5":
					view.xImg.skin = "peopleFallOff/x1.png"
					view.n1Txt.text = 1;
					view.n3Txt.text = 5;
					color = "#79D3FF";
					break;
				case "2":
					view.xImg.skin = "peopleFallOff/x4.png"
					view.n1Txt.text = 2;
					view.n3Txt.text = 0;
					color = "#FF6DEE";					
					break; 
				case "2.5":
					view.xImg.skin = "peopleFallOff/x2.png"
					view.n1Txt.text = 2;
					view.n3Txt.text = 5;
					color = "#02CC49";
					break;
				case "3":
					view.xImg.skin = "peopleFallOff/x3.png"
					view.n1Txt.text = 3;
					view.n3Txt.text = 0;
					view.maxImg.visible = true;
					view.btn_random.visible = false;
					color = "#FF4041";
					break;
			}
			view.n1Txt.color = view.n2Txt.color = view.n3Txt.color = color;
		}
		private function setRate(rate:String,refreshTime:String,pannel:Boolean):void
		{
			trace("是否是panel:"+pannel);
//			view.btn_mask.visible = false;
//			view.btn_random.disabled = false;
//			switch(rate.toString())
//			{
//				case "1":
//					view.tf_int.text = 1;
//					view.tf_number.text = 0;
//					break;
//				case "1.5":
//					view.tf_int.text = 1;
//					view.tf_number.text = 5;
//					break;
//				case "2":
//					view.tf_int.text = 2;
//					view.tf_number.text = 0;			
//					break;
//				case "2.5":
//					view.tf_int.text = 2;
//					view.tf_number.text = 5;
//					break;
//				case "3":
//					view.tf_int.text = 3;
//					view.tf_number.text = 0;
//					//					view.btn_mask.visible = true;
//					view.btn_random.disabled = true;
//					if(pannel)
//					{
//						view.btn_mask.visible = true;
//					}else
//					{
//						playMaxEffect();
//					}
//					break;
//			}
			if(pannel)
			{
				setRateTxt(rate);
				trace("面板倍率："+rate);
			}else
			{
				playRateMotion(rate);
//				trace("0000000000000000000000000000000000");
			}
		
			refreshTime = refreshTime+1;
			var refreshPrice:Object = ResourceManager.instance.getResByURL(PEOPLE_OFF_REFRESH);
			var priS:String;
			var priArr:Array;
			for each(var pri:Object in refreshPrice)
			{
				if(refreshTime>=pri["down"]&&refreshTime<=pri["up"])
				{
					priS =  pri["price"];
					priArr = priS.split("=");
				}
			}
			view.itemIcon2.skin = GameConfigManager.getItemImgPath( priArr[0]);
			view.numTf2.text = priArr[1];
			view.btn_random.on(Event.CLICK,this,onRandom,[refreshTime,priArr[0],Number(priArr[1])]);
			if(curFinish)
			{
				view.btn_random.disabled = true;
			}else
			{
				view.btn_random.disabled = false;
			}
		
		}
		private var _maxAnimation:Animation;
		private function playMaxEffect():void
		{
//			_maxAnimation.visible = true;
//			_maxAnimation.play(0, false);
//			Laya.timer.once(750, this, function() {_maxAnimation.visible=false;view.btn_mask.visible = true; } );
		}
		private var PEOPLE_OFF_REFRESH:String = "config/shuaijian_refresh.json";//刷新价格
		private var PEOPLE_OFF_RESET:String = "config/shuaijian_reset.json";//刷新价格
		private var PEOPLE_OFF_PARAM:String = "config/shuaijian_param.json";//刷新价格
		private var PEOPLE_OFF_NPC:String = "config/shuaijian_npc.json";//npc表,用来读npc图片
		private var refreshTime:String;

		private var curFinish:Boolean;
		private function onRandom(times:int,propId:int,propNum:Number):void
		{
		
			var item:ItemData = new ItemData();
			item.iid = propId;
			item.inum =  propNum;
			if(propNum>0)
			{
				ConsumeHelp.Consume([item],Handler.create(this,refreshSend),GameLanguage.getLangByKey("L_A_80002"));
			}	
//			view.btn_random.
		}
		private function refreshSend():void
		{
			sendData(ServiceConst.PEOPLE_FALL_OFF_RATE);
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
				itemC.x = i*(itemC.width+5);
			}
//			trace("view.refer.width"+view.refer.width);
			view.rewardBox.x = view.refer.x + (view.refer.width-view.rewardBox.width)/2;
		}
		private function setResetBtn(curPass:int,curFinish:Boolean,resetTimes:int):void
		{
			if(curPass==1&&!curFinish)
			{
				view.btn_reset.disabled = true;
			}else
			{
				view.btn_reset.disabled = false;
			}
			view.btn_reset.label = "   "+GameLanguage.getLangByKey("L_A_80601");
			resetTimes = resetTimes+1;
			var resetPrice:Object = ResourceManager.instance.getResByURL(PEOPLE_OFF_RESET);
			var priS:String;
			var priArr:Array;
			for each(var pri:Object in resetPrice)
			{
				if(resetTimes>=pri["down"]&&resetTimes<=pri["up"])
				{
					priS =  pri["price"];
					priArr = priS.split("=");
				}
			}
			view.itemIcon1.skin = GameConfigManager.getItemImgPath( priArr[0]);
			view.numTf1.text = priArr[1];
			view.btn_reset.on(Event.CLICK,this,onReset,[resetTimes,priArr[0],Number(priArr[1])]);
			
		}
		
		private function onReset(times:int,propId:int,propNum:Number):void
		{
			var item:ItemData = new ItemData();
			item.iid = propId;
			item.inum =  propNum;
			if(propNum>0)
			{
				ConsumeHelp.Consume([item],Handler.create(this,resetSend),GameLanguage.getLangByKey("L_A_80500"));
			}	
			else
			{
				sendData(ServiceConst.PEOPLE_FALL_OFF_RESET);
			}
		}
		
		private function resetSend():void
		{
			sendData(ServiceConst.PEOPLE_FALL_OFF_RESET);
		}
		
		private function setPass(curPass:int,curFinish:Boolean,npcArr:Array):void
		{
			
			var passName:String;
			var diName:String;
			var lImg:Image;
			var lsImg:Image;
			var aImg:Image;
			var asImg:Image;
			var aDi:Image;
			var lDi:Image;
			var finishBox:Box;
			var heroImg:Image;
			//设置npc图片
			var npc:Object = ResourceManager.instance.getResByURL(PEOPLE_OFF_NPC);
			for(var i:int=0;i<npcArr.length;i++)
			{
				var j:int = i+1;
				passName = "box"+j; 
				heroImg = (view[passName] as Box).getChildByName("heroImg");
				for each(var obj:Object in npc)
				{
					if(obj["npc_id"]==npcArr[i])
					{
						var unitId:String = obj["unit_id"];
						heroImg.skin = 	UnitPicUtil.getUintPic(unitId,UnitPicUtil.PIC_HALF);
					}
				}
				//				trace("npc"+i+":"+npcArr[i]);
			}
			//设置默认状态
			for(var i:int=1;i<=5;i++)
			{
				passName = "box"+i; 
				diName = "di"+i;
				lImg = (view[passName] as Box).getChildByName("lightBg");
				lsImg = (view[passName] as Box).getChildByName("lightSelect");
				aImg = (view[passName] as Box).getChildByName("anBg");
				asImg = (view[passName] as Box).getChildByName("anSelect");
				finishBox =  (view[passName] as Box).getChildByName("finishBox");
				lDi = (view[diName] as Box).getChildByName("light");
				aDi = (view[diName] as Box).getChildByName("an");
				lImg.visible = true;
				lsImg.visible = true;
				aImg.visible = true;
				asImg.visible = true;
				finishBox.visible = true;
				(view[passName] as Box).disabled = false;
				(view[diName] as Box).visible = false;
				lDi.visible = false;
				aDi.visible = false;
			}
			//将当前关卡之前关卡设置为已完成 
			for(var i:int=1;i<curPass;i++)
			{ 
				passName = "box"+i; 
				diName = "di"+i;
				lImg = (view[passName] as Box).getChildByName("lightBg");
				lsImg = (view[passName] as Box).getChildByName("lightSelect");
				aImg = (view[passName] as Box).getChildByName("anBg");
				asImg = (view[passName] as Box).getChildByName("anSelect");
				finishBox =  (view[passName] as Box).getChildByName("finishBox");
				lDi = (view[diName] as Box).getChildByName("light");
				aDi = (view[diName] as Box).getChildByName("an");
				lImg.visible = false;
				lsImg.visible = false;
				aImg.visible = true;
				asImg.visible = true;
				finishBox.visible = true;
				(view[diName] as Box).visible = true;
				lDi.visible = false;
				aDi.visible = true;
			}
			//将当前关卡设置为服务器数据状态
			passName = "box"+curPass;
			diName = "di"+curPass;
			lImg = (view[passName] as Box).getChildByName("lightBg");
			lsImg = (view[passName] as Box).getChildByName("lightSelect");
			aImg = (view[passName] as Box).getChildByName("anBg");
			asImg = (view[passName] as Box).getChildByName("anSelect");
			finishBox =  (view[passName] as Box).getChildByName("finishBox");
			lDi = (view[diName] as Box).getChildByName("light");
			aDi = (view[diName] as Box).getChildByName("an");
			(view[diName] as Box).visible = true;
			if(!curFinish)
			{
				lImg.visible = true;
				lsImg.visible = true;
				aImg.visible = false;
				asImg.visible = false;
				finishBox.visible = false;
				lDi.visible = true;
				aDi.visible = false;
			}else
			{
				lImg.visible = false;
				lsImg.visible = false;
				aImg.visible = true;
				asImg.visible = true;
				finishBox.visible = true;
				lDi.visible = false;
				aDi.visible = true;
			}
			//讲当前关卡之后的关卡设置为未开启状态
			for(var j:int=5;j>curPass;j--)
			{
				passName = "box"+j;
				diName = "di"+j;
				lImg = (view[passName] as Box).getChildByName("lightBg");
				lsImg = (view[passName] as Box).getChildByName("lightSelect");
				aImg = (view[passName] as Box).getChildByName("anBg");
				asImg = (view[passName] as Box).getChildByName("anSelect");
				finishBox =  (view[passName] as Box).getChildByName("finishBox");
//				lDi = (view[diName] as Box).getChildByName("light");
//				aDi = (view[diName] as Box).getChildByName("an");
				lImg.visible = false;
				lsImg.visible = false;
				aImg.visible = true;
				asImg.visible = true;
				finishBox.visible = false;
				(view[passName] as Box).disabled = true;
				(view[diName] as Box).visible = true;
				heroImg = (view[passName] as Box).getChildByName("heroImg");
				heroImg.skin = 	UnitPicUtil.getUintPic("0000",UnitPicUtil.PIC_HALF);
			}
		}
	
		override public function show(...args):void
		{
			super.show(args);
			sendData(ServiceConst.PEOPLE_FALL_OFF_PANNEL);	
			AnimationUtil.flowIn(this);	
		}
		override public function removeEvent():void
		{
			
		}
		override public function close():void
		{
			_motionIndex = 0;
			// TODO Auto Generated method stub
			AnimationUtil.flowOut(this, this.onClose);
		}
		private function onClose():void{
			super.close();
		}
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
	}
}