package game.module 
{
	import MornUI.newerGuide.GuiderViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.LayerManager;
	import game.common.ModuleManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	import game.module.camp.CampView;
	import game.module.camp.UnitInfoView;
	import game.module.chests.ChestsMainView;
	import game.module.fighting.mgr.FightSimulationManger;
	import game.module.fighting.panel.PTChapterLevelPanel;
	import game.module.fighting.scene.FightingMapScene;
	import game.module.fighting.scene.PveFightingScane;
	import game.module.fighting.view.FightingView;
	import game.module.fighting.view.PveFightingView;
	import game.module.fighting.view.PvpFightingView;
	import game.module.mainScene.BaseArticle;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainMenuView;
	import game.module.mainui.MainView;
	import game.module.story.StoryManager;
	import game.module.story.StoryView;
	import game.module.train.TrainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.system.System;
	import laya.ui.Image;
	import laya.ui.Panel;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	/**
	 * 新手引导
	 * @author ...
	 */
	public class newerGuideView extends BaseView 
	{
		
		private var guildAlpha = 0.01;
		
		private var guideStep:int = 0;
		
		private var fightData:Array = [];
		
		private var blankArea:Sprite;
		private var tagetSprite:Sprite;
		private var _guideBg:Sprite;
		private var imgHitArea:HitArea;
		private var soilderNum:int = 0;
		private var hasMoved:Boolean = false;
		
		private var buildSprite:Sprite;
		
		private var tfMask:Sprite;
		
		private var stopShade:Sprite;
		
		private var fakeBlock:Sprite;
		private var fakeBlockTwo:Sprite;
		private var fakeResource:Sprite;
		
		private var needDelayCall:Boolean = false;
		private var stopAll:Boolean = false;
		
		private var circleEffect:Animation;
		
		private var ts:Sprite;
		
		public function newerGuideView() 
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
			this.m_iPositionType = LayerManager.LEFTUP;
		}
		
		override public function show(...args):void{
			super.show();
			_tweenPlay = false;
			trace("lastStep:", User.getInstance().guideStep);
			User.getInstance().canAutoFight = false;
			////from(view.introWithMan, { x: -980 },500);
			
			guideStep = User.getInstance().guideStep;
			//guideStep = 201;
			switch(guideStep)
			{
				case 101:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case 103:
					WebSocketNetService.instance.sendData(ServiceConst.B_ONCE, [0]);
					guildeEventhandler(NewerGuildeEvent.SPEED_UP_BUILDING);
					break;
				case 107:
					guideStep = 107;
					XFacade.instance.openModule("TrainView");
					break;
				case 108:
					WebSocketNetService.instance.sendData(ServiceConst.T_SPEED, ['guideSpeedUp']);
					guildeEventhandler(NewerGuildeEvent.CLICK_SPEED_UP)
					break;
				case 109:
					missonStepHandler();
					break;
				case 201:
					soilderNum = 2;
					view.introWithMan.visible = false;
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP); 
					stopAll = true;
					Laya.timer.once(500, this, function() {
						stopAll = false;
						onClick();
						});
					break;
				case 250:
					soilderNum = 3;
					onClick();
					break;
				case 260:
					soilderNum = 3;
					missonStepHandler();
					break;
				case 275:
				case 292:
				case 293:
					guideStep = 293;
					soilderNum = 3;
					missonStepHandler();
					break;
				case 296:
					soilderNum = 3;
					WebSocketNetService.instance.sendData(ServiceConst.T_SPEED, ['guideSpeedUp']);
					onClick();
					break;
				case 310:
					onClick();
					break;
				case 324:
					onClick();
					break;
				default:
					break;
			}
		}
		
		public function TFMotion():void
		{
			stopAll = true;
			view.des1.y = 0;
			from(view.des1, { y: -100 }, 500);
			Laya.timer.once(750, this, function() {stopAll = false; } );
		}
		
		public function onClick(e:Event=null):void
		{
			if(_tweenPlay)return ;
			
			if (this.mouseThrough || view.mouseThrough || stopAll)
			{
				/*trace("mouseThrough:", mouseThrough);
				trace("stopAll:", stopAll);*/
				return;
			}
			/*if (needDelayCall)
			{
				Laya.timer.once(1000, this, function() {
					needDelayCall = false;
					onClick();
					});
				return;
			}*/
			
			this.hitArea = null;
			this.mouseThrough = view.mouseThrough  = false;
			view.arrowMotion.rotation = 0;
			guideStep++;
			
			//view.normalDes.visible = false;
			if(guideStep<100)
			{
				view.guideNpc.skin = "";
				view.introWithMan.visible = false;
			}
			else
			{
				view.guideNpc.skin = "appRes/icon/guideNpc/p1.png";
			}
			
			view.introWithMan.x = 0;
			
			view.guideNpc.x = 0;
			view.des2.height = view.des2.textHeight = 30;
			view.middleBg.height = 80;
			
			trace("++++++++++++++ guideStep: ", guideStep);
			var p:Point;
			hideBlankArea();
			switch(guideStep)
			{
				case 1:
					
					
					/*this.mouseThrough = view.mouseThrough  = false;
					view.des1.text = GameLanguage.getLangByKey("L_A_39079"); //"我们刚建立了一些基础设施,没想到这么快就遇到了入侵者";
					TFMotion();*/
					//AndroidPlatform.instance.FGM_CustumEvent("10_1_battle_dia1");
					//onClick();
					
					/*guideStep = 2;
					*/
					
					/*view.introWithMan.visible = true;
					bg.visible = true;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 330;
					view.arrowMotion.y = 250;*/
					//break;
				case 2:
					guideStep = 2;
					view.guideNpc.skin = "appRes/icon/guideNpc/p6.png";
					view.guideNpc.x = 600;
					view.introWithMan.x = Laya.stage.width - 975;
					view.introWithMan.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("20_1_battle_dia2");
					view.des1.text = GameLanguage.getLangByKey("L_A_39084");
					this._guideBg.visible = false;
					TFMotion();
					
					break;
				case 3:
					/*view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					view.des1.text = GameLanguage.getLangByKey("L_A_39003");//"蓝色区域表示这个单位的攻击范围，黄色区域表示伤害范围";
					view.introWithMan.visible = true;
					view.normalDes.visible = false;
					
					TFMotion();
					break;*/
				case 4:
					guideStep = 4;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					AndroidPlatform.instance.FGM_CustumEvent("30_1_battle_atk1");
					view.des2.text = GameLanguage.getLangByKey("L_A_39004");//"点击这个敌人进行攻击";
					
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					p = drawBlankArea(pveFightingScane.tileList['point_' + fightData[2]],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 800;
					view.arrowMotion.y = 530;
					view.arrowMotion.visible = true;
					showCircelAnimation(770, 310);
					
					break;
				case 5:
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FIRST_ACT);
					this.mouseThrough = view.mouseThrough  = false;
					stopAll = true;
					break;
				case 6:
					view.normalDes.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("40_1_battle_dia3");
					view.des1.text = GameLanguage.getLangByKey("L_A_39005");
					TFMotion();
					view.guideNpc.skin = "appRes/icon/guideNpc/p1.png"
					view.introWithMan.visible = true;
					//from(view.introWithMan, { x: -980 },500);
					break;
				case 7:
					view.guideNpc.skin = "appRes/icon/guideNpc/p5.png";
					view.guideNpc.x = 600;
					view.introWithMan.x = Laya.stage.width - 975;
					view.introWithMan.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("50_1_battle_dia4");
					view.des1.text = GameLanguage.getLangByKey("L_A_39006");//"嗨，我是来帮忙的，让我们助你一臂之力！";
					TFMotion();
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FIRST_ACT);
					//FightSimulationManger.intance.pushBu();
					this.mouseThrough = view.mouseThrough  = false;
					stopAll = true;					
					
					break;
				case 8:
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					AndroidPlatform.instance.FGM_CustumEvent("60_1_battle_atk2");
					view.des2.text = GameLanguage.getLangByKey("L_A_39004");//"点击这个敌人进行攻击";
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 700;
					view.arrowMotion.y = 470;
					view.arrowMotion.visible = true;
					showCircelAnimation(670, 250);
					break;
				/*case 99996:
					view.guideNpc.skin = "appRes/icon/guideNpc/p4.png"
					view.normalDes.visible = false;
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FIRST_ACT);
					this.mouseThrough = view.mouseThrough  = false;
					stopAll = true;
					break;
				case 999997:
					view.guideNpc.skin = "appRes/icon/guideNpc/p2.png"
					view.normalDes.visible = false;
					view.des1.text = GameLanguage.getLangByKey("L_A_39081");//"想不到敌人这么强，怎么办?";
					view.introWithMan.visible = true;
					//from(view.introWithMan, { x: -980 }, 500);
					guideStep = 9;
					break;
				case 999998:
					view.guideNpc.skin = "appRes/icon/guideNpc/p2.png"
					view.des1.text = GameLanguage.getLangByKey("L_A_39006");//"什么声音？？ 难道又有敌人出现了？？"
					TFMotion();;
					break;*/
				
				case 9:					
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FIRST_ACT);
					this.mouseThrough = view.mouseThrough  = false;
					break;
				case 11:
				case 12:
					//view.introWithMan.visible = false;
					
					this.mouseThrough = view.mouseThrough  = true;
					stopAll = true;
					break;
				case 101:
					view.guideNpc.skin = "appRes/icon/guideNpc/p1.png"
					view.introWithMan.visible = true;
					//from(view.introWithMan, { x: -980 },500);
					view.des1.text = GameLanguage.getLangByKey("L_A_39008");//"刚才的战斗太惊险了，如果不是那个神秘人帮忙，我们估计就要被全灭了";
					TFMotion();
					AndroidPlatform.instance.FGM_CustumEvent("70_base_dia1");
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [101]);
					break;
				case 102:
					view.guideNpc.skin = "appRes/icon/guideNpc/p5.png";
					view.guideNpc.x = 600;
					view.introWithMan.x = Laya.stage.width - 975;
					//from(view.introWithMan, { x:Laya.stage.width + 893 }, 500);
					view.des1.text = GameLanguage.getLangByKey("L_A_39086");
					AndroidPlatform.instance.FGM_CustumEvent("80_base_dia2");
					TFMotion();
					view.introWithMan.visible = true;
					////from(view.introWithMan, { x: -980 },500);
					
					/*view.des1.text = GameLanguage.getLangByKey("L_A_39009");//"让我们建立一个训练营来补充一点战斗中损失的部队";
					TFMotion();*/
					break;
				case 103:
					/*p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
					this.mouseThrough = view.mouseThrough  = true;
					guideStep = 103;*/
					/*view.des1.text = GameLanguage.getLangByKey("L_A_39087");
					TFMotion();
					break;*/
				case 104:
					
					AndroidPlatform.instance.FGM_CustumEvent("90_base_dia3");
					view.guideNpc.skin = "appRes/icon/guideNpc/p1.png"
					view.introWithMan.visible = true;
					guideStep = 104;
					view.des1.text = GameLanguage.getLangByKey("L_A_39087");
				
					TFMotion();
					break
				case 105:
					this.mouseThrough = view.mouseThrough  = true;
					XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD,"12"]);
					missonStepHandler("");
					break;
				case 107:
					
					AndroidPlatform.instance.FGM_CustumEvent("120_etr_trn");
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("L_A_39016");//"点击进入训练营";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = false;
					
					var aa:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_TRAIN);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(aa);
					this._guideBg.visible = true;
					
					stopAll = true;
					Laya.timer.once(500, this, function() {
						p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width / 2, 
											p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.height / 2);
					
						this._guideBg.visible = false;
						this.mouseThrough = view.mouseThrough  = true;
						stopAll = false;
						})
					
					
					break;
				case 108:
					/*view.des1.text = GameLanguage.getLangByKey("L_A_39018");//"让我们来训练一个防爆兵，补充一下队伍";
					TFMotion();
					this._guideBg.visible = false;
					
					var fBlock = new Sprite();
					fBlock.width = 180;
					fBlock.height = 200;
					fBlock.x = 200;
					//fBlock.y = 135;
					fBlock.y = LayerManager.instence.stageHeight*0.5-185;
					
					fBlock.graphics.drawRect(0, 0, 180, 200, "#f0f0f0");
					fBlock.alpha = 0.01;
					fBlock.mouseEnabled = false;
					view.addChild(fBlock);
					
					//p = drawBlankArea((XFacade.instance.getView(TrainView) as TrainView).view.list.getChildAt(0).getChildAt(0));
					p = drawBlankArea(fBlock);
					view.arrowMotion.x = p.x+125;
					view.arrowMotion.y = p.y+300;
					view.arrowMotion.rotation = 180;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 85, p.y + 100);
					
					this.mouseThrough = view.mouseThrough  = true;
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [105]);*/
					
					//1016修改
					guildeEventhandler(NewerGuildeEvent.SELECT_SOILDER);
					//AndroidPlatform.instance.FGM_CustumEvent("130_trn_dia1");
					
					break;
				case 109:
					XFacade.instance.closeModule(TrainView);
					view.normalDes.visible = false;
					/*view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39021");//"领了这份奖励，我们继续探索";
					TFMotion();
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;*/
					
					//1016修改
					missonStepHandler();
					
					break;
				case 110:
					view.introWithMan.visible = true;
					view.normalDes.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("190_stg1_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39111");
					TFMotion();
					//view.arrowMotion.visible = true;
					//view.arrowMotion.x = LayerManager.instence.stageWidth*0.85;
					//view.arrowMotion.y = LayerManager.instence.stageHeight*0.5;
					//view.des1.text = GameLanguage.getLangByKey("");//"每个单位都会占用一定数量的人口，这里显示的是目前已经使用的人口和最大人口数";
					break;
				case 111:
					view.introWithMan.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("200_clk_pro");
					pveFightiView.selectUnitView.unitTypeTab.selectedIndex = 1;
					
					
					view.des2.text = GameLanguage.getLangByKey("L_A_39023");//"点击士兵图片上阵";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					view.introWithMan.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					
					p = drawBlankArea(fakeBlockTwo);
					view.arrowMotion.x = p.x+(fakeBlockTwo.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + fakeBlockTwo.width / 2, 
										p.y + fakeBlockTwo.height / 2);
					break;
				case 112:
					onClick();
					break;
				case 113:
					
					ts = pveFightiView.selectUnitView.fightBtn;
					ts.on(Event.CLICK, this, showBg);
					
					p = drawBlankArea(pveFightiView.selectUnitView.fightBtn);
					view.arrowMotion.x = p.x + (pveFightiView.selectUnitView.fightBtn.width - view.arrowMotion.width) / 2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					this._guideBg.visible = false;
					
					showCircelAnimation(p.x + pveFightiView.selectUnitView.fightBtn.width / 2, 
										p.y + pveFightiView.selectUnitView.fightBtn.height / 2);
					
					view.normalDes.visible = true;
					view.arrowMotion.visible = true;
					view.introWithMan.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("220_clk_start");
					view.des2.text = GameLanguage.getLangByKey("L_A_39024");//"点击开战按钮开始战斗";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 114:
					/*view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39025");//"现在让我们来干掉这些家伙";
					TFMotion();*/
					view.introWithMan.visible = false;
				
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [201]);
					_guideBg.visible = true;
					onClick();
					break;
				case 115:
					/*view.introWithMan.visible = false;
					bg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;*/
					_guideBg.visible = false;
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					view.introWithMan.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("230_clk_mov");
					view.des2.text = GameLanguage.getLangByKey("L_A_39026");//"当攻击范围内没有敌人时，可以通过移动来更换位置，点击移动按钮";
					p = drawBlankArea(pveFightiView.rightBottomView.MoveBtn);
					view.arrowMotion.x = p.x+(pveFightiView.rightBottomView.MoveBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + pveFightiView.rightBottomView.MoveBtn.width / 2, 
										p.y + pveFightiView.rightBottomView.MoveBtn.height / 2);
					
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					Signal.intance.off(NewerGuildeEvent.START_MOVE_GUIDE, this, this.guildeEventhandler);
					break;
				case 116:
					view.introWithMan.visible = false;
					
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					AndroidPlatform.instance.FGM_CustumEvent("260_clk_atk1");
					view.des2.text = GameLanguage.getLangByKey("L_A_39067");//点击攻击这个敌人
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					p = drawBlankArea(pveFightingScane.tileList['point_213'],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = p.x+90;
					view.arrowMotion.y = p.y+250;
					view.arrowMotion.visible = true;
					this.mouseThrough = view.mouseThrough  = true;
					
					showCircelAnimation(p.x+50,p.y+25);
					break;
				case 117:
					/*view.des2.text = GameLanguage.getLangByKey("");//"让我们结束这场，继续探索";
					this.mouseThrough = view.mouseThrough  = true;*/
					
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					view.des2.text = GameLanguage.getLangByKey("L_A_39068");//点击攻击这个敌人
					AndroidPlatform.instance.FGM_CustumEvent("270_clk_atk2");
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					p = drawBlankArea(pveFightingScane.tileList['point_214'],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = p.x+90;
					view.arrowMotion.y = p.y+250;
					view.arrowMotion.visible = true;
					this.mouseThrough = view.mouseThrough  = true;
					
					showCircelAnimation(p.x+50,p.y+25);
					break;
				case 118:
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 201:
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("290_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39090");
					TFMotion();
					break;
				case 202:
					view.introWithMan.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("300_dia2");
					view.des1.text = GameLanguage.getLangByKey("L_A_39091");
					TFMotion();
					break;
				case 203:
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					view.normalDes.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("310_clk_stg2");
					view.des2.text = GameLanguage.getLangByKey("L_A_39029");//"让我们来探索下一个目标";
					if (!(XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('2') || 
						!(XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('2').displayedInStage)
					{
						//p = drawBlankArea((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('2'));
						guideStep--;
						
						stopAll = true;
						_guideBg.visible = true;
						
						Laya.timer.once(500, this, function() {
							stopAll = false;
							_guideBg.visible = false;
							onClick();
							});
						return;
					}
					/*else
					{
						var fakeG:Sprite;
						fakeG = new Sprite();
						fakeG.width = 135;
						fakeG.height = 160;
						fakeG.x = 203;
						fakeG.y = 230;
						fakeG.graphics.drawRect(0, 0, 135, 160, "#f0f0f0");
						fakeG.alpha = 0.01;
						fakeG.mouseEnabled = false;
						view.addChild(fakeG);
						p = drawBlankArea(fakeG);
					}*/
					
					
					//AndroidPlatform.instance.FGM_CustumEvent("203_quest_1_battle_click_back");
					
					p = drawBlankArea((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('2'));
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = p.x+110;
					view.arrowMotion.y = p.y+310;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 75, p.y + 80);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 204:
					view.normalDes.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("330_stg2_dia3");
					view.des1.text = GameLanguage.getLangByKey("L_A_39030");//"后面的战斗会越来越困难，让我来协助你一起战斗吧";
					TFMotion();
					view.introWithMan.visible = true;
					this.mouseThrough = view.mouseThrough  = false;
					break;
				case 205:
					
					AndroidPlatform.instance.FGM_CustumEvent("340_clk_hero");
					pveFightiView.selectUnitView.unitTypeTab.selectedIndex = 0;
					view.des2.text = GameLanguage.getLangByKey("L_A_39031");//"点击英雄图片上阵，英雄不会占用你的上阵人口";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					view.introWithMan.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					
					/*p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).selectUnitView.m_list.getCell(0));
					view.arrowMotion.x = p.x+(XFacade.instance.getView(FightingView).selectUnitView.m_list.getCell(0).width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;*/
					
					
					
					p = drawBlankArea(fakeBlockTwo);
					view.arrowMotion.x = p.x+(fakeBlockTwo.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + fakeBlockTwo.width / 2, 
										p.y + fakeBlockTwo.height / 2);
					
					break;
				case 206:
					guideStep = 206;
					onClick();
					break;
					/*view.des2.text = "点击标签，让我们继续派出士兵";
					p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).selectUnitView.unitTypeTab.getChildAt(1));
					view.arrowMotion.x = p.x+(XFacade.instance.getView(FightingView).selectUnitView.m_list.getCell(0).width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					this.mouseThrough = view.mouseThrough  = false;
					break;*/
				case 206:
					/*(XFacade.instance.getView(FightingView) as FightingView).selectUnitView.unitTypeTab.selectedIndex = 1;
					view.des2.text = "我们再派出两个士兵";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					view.introWithMan.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					
					p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).selectUnitView.m_list.getCell(0));
					view.arrowMotion.x = p.x+(XFacade.instance.getView(FightingView).selectUnitView.m_list.getCell(0).width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					break;*/
				case 207:
					
					AndroidPlatform.instance.FGM_CustumEvent("350_clk_start");
					
					ts = pveFightiView.selectUnitView.fightBtn;
					ts.on(Event.CLICK, this, showBg);
					
					p = drawBlankArea(pveFightiView.selectUnitView.fightBtn);
					view.arrowMotion.x = p.x+(pveFightiView.selectUnitView.fightBtn.width-view.arrowMotion.width)/2;;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					this._guideBg.visible = false;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + pveFightiView.selectUnitView.fightBtn.width / 2, 
										p.y + pveFightiView.selectUnitView.fightBtn.height / 2);
					
					view.normalDes.visible = true;
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("L_A_39032");//"让我们看看英雄单位的威力";
					//TFMotion();
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 208:
					
					trace("**************************guideStep208**********************")
					
					this._guideBg.visible = true;
					view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39093");//"英雄单位不但比一般的单位更强大，并且拥有多个主动技能，现在让我们使用一下英雄的主技能";
					TFMotion();
					AndroidPlatform.instance.FGM_CustumEvent("360_stg2_dia4");
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [250]);
					//p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).rightBottomView.AttackBtn);
					/*view.arrowMotion.x = p.x+((XFacade.instance.getView(FightingView) as FightingView).rightBottomView.AttackBtn-view.arrowMotion.width)/2;;
					view.arrowMotion.y = p.y - view.arrowMotion.height;*/
					//view.arrowMotion.x = p.x+20;
					//view.arrowMotion.y = p.y-200;
					//view.arrowMotion.visible = true;
					//this.mouseThrough = view.mouseThrough  = true;
					break;
				case 209:
					trace("**************************guideStep209**********************")
					this._guideBg.visible = false;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					AndroidPlatform.instance.FGM_CustumEvent("370_clk_atk");
					view.des2.text = GameLanguage.getLangByKey("L_A_39034");//"黄色区域标识技能伤害范围，选择一个敌人释放";
					view.normalDes.visible = true;
					view.introWithMan.visible = false;
					p = drawBlankArea(pveFightingScane.tileList['point_210'],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 700;
					view.arrowMotion.y = 475;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(670, 250);
					
					this.mouseThrough = view.mouseThrough  = true;
					//Laya.timer.once(2000, this, function() { view.normalDes.visible = false} );
					break;
				case 210:
					
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("380_stg2_dia5");
					view.des1.text = GameLanguage.getLangByKey("L_A_39094");
					TFMotion();
					break;
				case 211:
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("390_stg2_dia6");
					view.des1.text = GameLanguage.getLangByKey("L_A_39035");//"现在让我们来使用一下英雄的辅技能";
					TFMotion();
					p = drawBlankArea(pveFightiView.rightBottomView.AttackBtn1);
					/*view.arrowMotion.x = p.x+((XFacade.instance.getView(FightingView) as FightingView).rightBottomView.AttackBtn-view.arrowMotion.width)/2;;
					view.arrowMotion.y = p.y - view.arrowMotion.height;*/
					view.arrowMotion.x = p.x+10;
					view.arrowMotion.y = p.y-200;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + pveFightiView.rightBottomView.AttackBtn1.width / 2, 
										p.y + pveFightiView.rightBottomView.AttackBtn1.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 212:
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("395_stg2_dia7");
					view.des1.text = GameLanguage.getLangByKey("L_A_39096");
					TFMotion();
					break;
				case 213:
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("400_clk_atk2");
					view.des2.text = GameLanguage.getLangByKey("L_A_39097");//"选择一个敌人试试威力";
					p = drawBlankArea(pveFightingScane.tileList['point_210'],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 700;
					view.arrowMotion.y = 475;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(670, 250);
					
					this.mouseThrough = view.mouseThrough  = true;
					//Laya.timer.once(2000, this, function() { view.normalDes.visible = false, view.arrowMotion.visible = false; } );
					//Laya.timer.once(1000, this, function() { view.normalDes.visible = false } );
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 214:
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("420_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39098");
					TFMotion();
					break;
				case 215:
					
					AndroidPlatform.instance.FGM_CustumEvent("430_dia2");
					
					User.getInstance().lockMove = false;
					view.des1.text = GameLanguage.getLangByKey("L_A_39036");//"现在让我们返回主基地";
					TFMotion();
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.backBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainView) as MainView).view.backBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.backBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.backBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 251:
					/*view.des1.text = GameLanguage.getLangByKey("L_A_39037");//"领取过关奖励";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = true;
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;*/
					
					//1016修改
					guideStep = 260;
					missonStepHandler();
					break;
				case 252:
					/*view.des1.text = GameLanguage.getLangByKey("");//"现在我们需要建造一个兵营，获得的新单位可以在这里激活";
					TFMotion();
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					bg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;*/
					break;
				case 261:
					view.introWithMan.visible = false;
					
					AndroidPlatform.instance.FGM_CustumEvent("460_clk_tow");
					view.des2.text = GameLanguage.getLangByKey("L_A_39064");//"点击进入搜索塔";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = false;
					
					p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y-view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 271:
					onClick();
					break;
					/*view.normalDes.visible = false;
					view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39039");//"在这里可以搜索新单位的信息，搜集到足够的单位信息后即可进行招募，但是运气好的话也可能直接招募到哦";
					//from(view.introWithMan, { x: -980 }, 500);
					AndroidPlatform.instance.FGM_CustumEvent("300_click enter for draw card");
					
					stopAll = true;
					Laya.timer.once(500, this, function() { stopAll = false; } );
					break;*/
				case 272:
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					stopAll = true;
					
					Laya.timer.once(500, this, function() { stopAll = false; } );
					
					AndroidPlatform.instance.FGM_CustumEvent("470_clk_exp");
					view.des2.text = GameLanguage.getLangByKey("L_A_39040");//"点击高级搜索";
					view.normalDes.visible = true;
					
					p = drawBlankArea((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y-view.arrowMotion.height;
					view.arrowMotion.visible = true;
					this.mouseThrough = view.mouseThrough  = false;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.width / 2, 
										p.y + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.height / 2);
					
					break;
				case 273:
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					AndroidPlatform.instance.FGM_CustumEvent("480_clk_drw");
					view.des2.text = GameLanguage.getLangByKey("L_A_39041");//"点击十连抽抽奖";
					(XFacade.instance.getView(ChestsMainView) as ChestsMainView).selectCard1();
					
					stopAll = true;
					
					Laya.timer.once(500, this, function() { 
						p = drawBlankArea((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.TenTimeBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.TenTimeBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						this.mouseThrough = view.mouseThrough  = true;
						
						showCircelAnimation(p.x + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.TenTimeBtn.width / 2, 
											p.y + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.cardItem01.TenTimeBtn.height / 2);
						
//						stopAll = false;
						} );
					
					break;
				case 274:
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					
					view.des1.text = GameLanguage.getLangByKey("L_A_39042");//"哇！指挥官你的运气正式太好了，第一次搜索就已经招募到了一个完整的单位！";
					TFMotion();
					
					this.mouseThrough = view.mouseThrough  = false;
					AndroidPlatform.instance.FGM_CustumEvent("490_tow_dia2");
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [275]);
					break;
				case 275:
					view.introWithMan.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					this._guideBg.visible = true;
					stopAll = true;
					(XFacade.instance.getView(ChestsMainView) as ChestsMainView).HideShowPlayerBox();
					
					Laya.timer.once(4000, this, function() {
						
						view.normalDes.visible = true;
						
						AndroidPlatform.instance.FGM_CustumEvent("500_clk_can");
						view.des2.text = GameLanguage.getLangByKey("L_A_39043");//"现在让我们离开搜索塔";
						view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
						p = drawBlankArea((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.ChannelBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.ChannelBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						
						showCircelAnimation(p.x + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.ChannelBtn.width / 2, 
										p.y + (XFacade.instance.getView(ChestsMainView) as ChestsMainView).view.ChannelBtn.height / 2);
						
						this.mouseThrough = view.mouseThrough  = false;
						this._guideBg.visible = true;
						stopAll = false;
						} );
					
					
					break;
				case 276:
					XFacade.instance.closeModule(ChestsMainView);
					view.normalDes.visible = false;
					
					/*view.introWithMan.visible = true
					view.des1.text = GameLanguage.getLangByKey("L_A_39044");//"指挥官你的运气太好了，先让我们把任务领了~";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = true;
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;	
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					guideStep = 293;*/
					
					//1016修改
					guideStep = 293;
					onClick();
					break;
				case 281:
					
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("");//"点击进入兵营";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = false;
					
					var aa:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_CAMP);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(aa);
					
					Laya.timer.once(500, this, function() {
						p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						
						showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.height / 2);
						
						})
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 282:
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("");//"点击解锁狙击手";
					view.normalDes.visible = true;
					
					this.mouseThrough = view.mouseThrough  = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					p = drawBlankArea((XFacade.instance.getView(UnitInfoView) as (UnitInfoView)).view.upgradeBtn);
					
					view.arrowMotion.x = p.x + ((XFacade.instance.getView(UnitInfoView) as UnitInfoView).view.upgradeBtn.width - view.arrowMotion.width) / 2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(UnitInfoView) as (UnitInfoView)).view.upgradeBtn.width / 2, 
										p.y + (XFacade.instance.getView(UnitInfoView) as (UnitInfoView)).view.upgradeBtn.height / 2);
					
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 292:
					
					break;
				case 293:
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [293]);
					XFacade.instance.closeModule(TrainView);
					view.normalDes.visible = false;
					view.introWithMan.visisble = true
					view.des1.text = GameLanguage.getLangByKey("");//"还真是奖励多多啊";
					this._guideBg.visible = true;
					this.mouseThrough = view.mouseThrough  = false;
					/*p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;*/
					break;
				case 294:
					view.introWithMan.visible = true
					
					AndroidPlatform.instance.FGM_CustumEvent("510_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39045");//"让我们回到训练营，训练个狙击兵";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = false;
					break;
				case 295:
					view.introWithMan.visible = false;
					
					AndroidPlatform.instance.FGM_CustumEvent("520_etr_trn");
					view.des2.text = GameLanguage.getLangByKey("L_A_39046");//"进入训练营";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = true;
					
					var aa:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_TRAIN);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(aa);
					this.mouseThrough = view.mouseThrough  = true;
					Laya.timer.once(500, this, function() {
						p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						this._guideBg.visible = false;
						showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.enterBtn.height / 2);
						
						})
					break;
				case 296:
					
					User.getInstance().guideStep = 296;
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					AndroidPlatform.instance.FGM_CustumEvent("530_clk_sni");
					view.des2.text = GameLanguage.getLangByKey("L_A_39048");//"选择狙击兵";
					TFMotion();
					
					this._guideBg.visible = false;
					
					var fBlock = new Sprite();
					fBlock.width = 180;
					fBlock.height = 200;
					fBlock.x = 560;
					//fBlock.y = 135;
					fBlock.y = LayerManager.instence.stageHeight*0.5-185;
					fBlock.graphics.drawRect(0, 0, 180, 200, "#f0f0f0");
					fBlock.alpha = 0.01;
					fBlock.mouseEnabled = false;
					view.addChild(fBlock);
					
					//p = drawBlankArea((XFacade.instance.getView(TrainView) as TrainView).view.list.getChildAt(0).getChildAt(2));
					p = drawBlankArea(fBlock);					
					view.arrowMotion.x = p.x+130;
					view.arrowMotion.y = p.y+300;
					view.arrowMotion.rotation = 180;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 95, p.y + 100);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 297:
					view.normalDes.visible = false;
					
					XFacade.instance.closeModule(TrainView);
					guideStep = 300;
					/*view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39065");//"那就让我们看看下个任务是啥吧";
					//from(view.introWithMan, { x: -980 },500);
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
										
					this.mouseThrough = view.mouseThrough  = true;*/
					
					//1017修改
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("560_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39069");
					TFMotion();
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.copyBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainView) as MainView).view.copyBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.copyBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.copyBtn.height / 2);
					_guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					break
				case 301:
					
					if (!((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('3')) ||
						!((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('3').displayedInStage))
					{
						guideStep--;
						
						stopAll = true;
						_guideBg.visible = true;
						
						Laya.timer.once(500, this, function() {
							stopAll = false;
							_guideBg.visible = false;
							onClick();
							});
						return;
					}
					
					AndroidPlatform.instance.FGM_CustumEvent("570_clk_stg3");
					
					stopAll = false;
					view.introWithMan.visible = false;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					view.normalDes.visible = true;
					view.des2.text = GameLanguage.getLangByKey("L_A_39100");//"让我们去这里试试狙击手的威力";
					p = drawBlankArea((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('3'));
					
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = p.x+110;
					view.arrowMotion.y = p.y+310;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 75, p.y + 80);
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 302:
					
					AndroidPlatform.instance.FGM_CustumEvent("590_clk_hero");
					
					pveFightiView.selectUnitView.unitTypeTab.selectedIndex = 0;
					view.des2.text = GameLanguage.getLangByKey("L_A_39053");//"先派出我们的英雄";
					view.normalDes.visible = false;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					view.introWithMan.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					
					/*p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).selectUnitView.m_list.getCell(0));
					view.arrowMotion.x = p.x+(XFacade.instance.getView(FightingView).selectUnitView.m_list.getCell(0).width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;*/
					p = drawBlankArea(fakeBlockTwo);
					view.arrowMotion.x = p.x+(fakeBlockTwo.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + fakeBlockTwo.width / 2, 
										p.y + fakeBlockTwo.height / 2);
					
					break;
				case 303:
					//view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					
					view.arrowMotion.rotation = 0;
					view.arrowMotion.x = 680;
					view.arrowMotion.y = -10;
					view.arrowMotion.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("600_stg3_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39054");//"星际游侠攻击无法穿透敌人前排的重甲单位，所以你无法攻击到重甲身后的单位";
					TFMotion();
					break;
				case 304:
					view.arrowMotion.rotation = 0;
					view.arrowMotion.x = 600;
					view.arrowMotion.y = 0;
					view.arrowMotion.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("610_stg3_dia2");
					view.des1.text = GameLanguage.getLangByKey("L_A_39110");//"星际游侠攻击无法穿透敌人前排的重甲单位，所以你无法攻击到重甲身后的单位";
					TFMotion();
					break;
				case 305:
					
					AndroidPlatform.instance.FGM_CustumEvent("620_clk_pro");					
					view.arrowMotion.visible = false;
					view.introWithMan.visible = false;
					view.normalDes.visible = false;
					pveFightiView.selectUnitView.unitTypeTab.selectedIndex = 1;
					
					p = drawBlankArea(fakeBlockTwo);
					view.arrowMotion.x = p.x+(fakeBlockTwo.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + fakeBlockTwo.width / 2, 
										p.y + fakeBlockTwo.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 306:
					
					
					view.arrowMotion.rotation = 0;
					view.arrowMotion.x = 680;
					view.arrowMotion.y = -10;
					view.arrowMotion.visible = true;
					
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					//from(view.introWithMan, { x: -980 },500);
					view.des1.text = GameLanguage.getLangByKey("L_A_39055");//"狙击手的攻击类型是穿透，其一大特性就是能够无视重甲的阻隔属性";
					TFMotion();
					
					AndroidPlatform.instance.FGM_CustumEvent("650_stg3_dia3");
					break;
				case 307:
					//view.des1.text = "战斗中优先击杀伤害输出较高的敌人是非常关键的技巧，请指挥官务必牢记";
					//break;
				case 308:
					
					//AndroidPlatform.instance.FGM_CustumEvent("308_quest_3_battle_sniper_dialog");	
					
					guideStep = 308;
					view.arrowMotion.visible = false;
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("660_clk_start");
					view.des2.text = GameLanguage.getLangByKey("L_A_39102");//"试试狙击手的威力吧";
					
					ts = pveFightiView.selectUnitView.fightBtn;
					ts.on(Event.CLICK, this, showBg);
					
					p = drawBlankArea(pveFightiView.selectUnitView.fightBtn);
					view.arrowMotion.x = p.x+(pveFightiView.selectUnitView.fightBtn.width-view.arrowMotion.width)/2;;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					this._guideBg.visible = false;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + pveFightiView.selectUnitView.fightBtn.width / 2, 
										p.y + pveFightiView.selectUnitView.fightBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 309:
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					view.normalDes.visible = false;
					stopAll = true;
					this.mouseThrough = view.mouseThrough  = true;
					//AndroidPlatform.instance.FGM_CustumEvent("670_clk_back");
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [324]);
					break;
				case 310:
					
					AndroidPlatform.instance.FGM_CustumEvent("680_dia1");
					
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39103");//"酣畅淋漓的战斗，回基地我给你介绍一下我们在你昏迷的时候已经完成的设施情况吧";
					TFMotion();
					break;
				case 311:
					
					AndroidPlatform.instance.FGM_CustumEvent("690_dia2");
					view.des1.text = GameLanguage.getLangByKey("L_A_39104");
					TFMotion();
					
					break;
				case 312:
					view.normalDes.visible = true;
					view.introWithMan.visible = false;
					
					AndroidPlatform.instance.FGM_CustumEvent("700_clk_back");
					view.des2.text = GameLanguage.getLangByKey("L_A_39105");
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.backBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainView) as MainView).view.backBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.backBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.backBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 313:
					//1016修改
					guideStep = 324;
					onClick();
					break;
				case 321:
					buildSprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_FOOD_F);
					
					if (!buildSprite ||!buildSprite.displayedInStage)
					{
						guideStep--;
						
						stopAll = true;
						_guideBg.visible = true;
						
						Laya.timer.once(500, this, function() {
							stopAll = false;
							_guideBg.visible = false;
							onClick();
						});
						return;
					}
					
					Laya.timer.once(250, this, drawBuildingBlock);
					
					view.des1.text = GameLanguage.getLangByKey("L_A_39059");//"点击收取食物";
					TFMotion();
					this._guideBg.visible = false;
					
					break;
				case 322:
					WebSocketNetService.instance.sendData(ServiceConst.B_HARVEST, [buildSprite._data.id]);
					AndroidPlatform.instance.FGM_CustumEvent("322_calim_resource");
					if ((buildSprite as BaseArticle).harvestIcon)
					{
						var pp:Point = new Point((buildSprite as BaseArticle).harvestIcon.x,(buildSprite as BaseArticle).harvestIcon.y)
						pp = (buildSprite as BaseArticle).localToGlobal(pp)
						//收获动画
						ItemUtil.showHarvestAni((buildSprite as BaseArticle).harvestIcon.icon.skin,pp);
						(buildSprite as BaseArticle).data.resource = "2=0";
						(buildSprite as BaseArticle).showHarvest(false)
					}
					view.des1.text = GameLanguage.getLangByKey("L_A_39060");//"食物用于战斗，黄金用于在训练营中训练单位，石材用于建造和升级基地的各项设施";
					TFMotion();
					break;
					/*WebSocketNetService.instance.sendData(ServiceConst.B_HARVEST, [buildSprite._data.id]);
					buildSprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_GOLD_F);
					Laya.timer.once(250, this, drawBuildingBlock);
					
					view.des1.text = "点击收取黄金，黄金用于在训练营中训练单位";
					
					break;*/
				case 323:
					/*WebSocketNetService.instance.sendData(ServiceConst.B_HARVEST, [buildSprite._data.id]);
					buildSprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_STONE_F);
					Laya.timer.once(250, this, drawBuildingBlock);
					
					view.des1.text = "点击收取石材，石材用于建造和升级基地的各项设施";
					break;*/
				case 324:
					view.des1.text = GameLanguage.getLangByKey("L_A_39061");//"建造和升级建筑都能够提升我们的科技等级，当科技等级达到一定程度时可以升级我们的大本营，从而解锁更多新建筑和功能";
					TFMotion();
					guideStep = 324;
					break;
				case 325:
					
					AndroidPlatform.instance.FGM_CustumEvent("710_clk_dia3");
					/*view.des1.text = GameLanguage.getLangByKey("L_A_39062");//"来为我们的舰队取个名字吧"
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [324]);*/
					
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					
					view.des1.text = GameLanguage.getLangByKey("L_A_39106");
					TFMotion();
					
					/*guildAlpha = 0.8;
					drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.topBar);
					this.setChildIndex(view, this.numChildren - 1);*/
//					view.arrowMotion.x = Laya.stage.width*0.7;
//					view.arrowMotion.y = 200;
//					view.arrowMotion.visible = true;
//					view.arrowMotion.rotation = 180;
					
					/*p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;*/
//					if(GameSetting.IsRelease)
//					{
//						view.arrowMotion.x *= 0.8;
//						trace("325发布版引导坐标："+view.arrowMotion.x);
//					}else
//					{
//						trace("325本地版引导坐标："+view.arrowMotion.x);
//					}
					break;
				case 326:
					
					view.normalDes.visible = false;
					this.setChildIndex(view, 0);
					//guildAlpha = 0.01;
					view.introWithMan.visible = true;
					
					AndroidPlatform.instance.FGM_CustumEvent("715_clk_dia4");
					view.des1.text = GameLanguage.getLangByKey("L_A_39107");
					TFMotion();
					var l_p:Point = new Point((XFacade.instance.getView(MainView) as MainView).view.stoneIcon.x,(XFacade.instance.getView(MainView) as MainView).view.stoneIcon.y);
					var g_p:Point = localToGlobal(l_p);
					view.arrowMotion.x = Laya.stage.width*0.75;
					view.arrowMotion.y = 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					if(GameSetting.IsRelease)
					{
						view.arrowMotion.x *= 0.8;
						trace("326发布版引导坐标："+view.arrowMotion.x);
					}else
					{
						trace("326本地版引导坐标："+view.arrowMotion.x);
					}
					
					
					/*AndroidPlatform.instance.FGM_CustumEvent("460_createnickname_dialog");
					
					this._guideBg.visible = false;
					stopAll = true;
					this.mouseThrough = view.mouseThrough  = true;
					view.introWithMan.visible = false;
					XFacade.instance.openModule(ModuleName.SetPlayerNameView);*/
//					close();
					break;
				case 327:
					view.introWithMan.visible = false;
					view.normalDes.visible = true;
					hideBlankArea();
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					
					AndroidPlatform.instance.FGM_CustumEvent("720_clk_con");
					view.des2.text =  GameLanguage.getLangByKey("L_A_39072");
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.constructBtn);
					
					view.arrowMotion.x = p.x+(XFacade.instance.getView(MainView) as MainView).view.constructBtn.width/3;
					view.arrowMotion.y = p.y-200;
					view.arrowMotion.visible = true;
					
					this._guideBg.visible = false;
					
					this.mouseThrough = view.mouseThrough  = true;
					/*AndroidPlatform.instance.FGM_CustumEvent("560_guidance_end");
					AndroidPlatform.instance.FGM_EventCompletedTutorial();
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [999]);
					XFacade.instance.openModule(ModuleName.ActivityMainView,"1");
					User.getInstance().hasFinishGuide = true;
					User.getInstance().canAutoFight = true;
					close();*/
					break;
				case 328:
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("770_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39108");
					TFMotion();
					break;
				case 329:
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("780_dia2");
					view.des1.text = GameLanguage.getLangByKey("L_A_39109");
					TFMotion();
					break;
				case 330:
					
					removeFightEvent();
					
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					view.introWithMan.visible = false;
					
					
//					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [327]);
			
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.btn_more);
					
					view.arrowMotion.x = p.x + 250;
					view.arrowMotion.y = p.y + 20;
					view.arrowMotion.rotation = 90;
					view.arrowMotion.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("800_help_dia");
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.btn_more.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.btn_more.height / 2);
					
//					view.introWithMan.visible = true;
//					view.guideNpc.skin = "appRes/icon/guideNpc/p5.png";
//					view.guideNpc.x = 600;
//					view.introWithMan.x = Laya.stage.width - 975;
//					view.des1.text = GameLanguage.getLangByKey("L_A_39112");
//					TFMotion();
//					User.getInstance().guideStep = 330;
					
					break;
				case 331:
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					
//					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [327]);
//					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.helpBtn);
//					
//					view.arrowMotion.x = p.x + 250;
//					view.arrowMotion.y = p.y + 20;
//					view.arrowMotion.rotation = 90;
//					view.arrowMotion.visible = true;
//					AndroidPlatform.instance.FGM_CustumEvent("800_help_dia");
//					
//					view.introWithMan.visible = true;
//					view.guideNpc.skin = "appRes/icon/guideNpc/p5.png";
//					view.guideNpc.x = 600;
//					view.introWithMan.x = Laya.stage.width - 975;
//					view.des1.text = GameLanguage.getLangByKey("L_A_39112");
//					TFMotion();
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.helpBtn);
					
					view.arrowMotion.x = p.x + 250;
					view.arrowMotion.y = p.y + 20;
					view.arrowMotion.rotation = 90;
					view.arrowMotion.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("800_help_dia");
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.helpBtn.width / 2, 
						p.y + (XFacade.instance.getView(MainView) as MainView).view.helpBtn.height / 2);
					
					view.introWithMan.visible = true;
					view.guideNpc.skin = "appRes/icon/guideNpc/p5.png";
					view.guideNpc.x = 600;
					view.introWithMan.x = Laya.stage.width - 975;
					view.des1.text = GameLanguage.getLangByKey("L_A_39112");
					TFMotion();
					User.getInstance().guideStep = 331;
					break;
				case 332:
					AndroidPlatform.instance.FGM_CustumEvent("790_help_ui");
					AndroidPlatform.instance.FGM_CustumEvent("999_guidance_end");
					AndroidPlatform.instance.FGM_EventCompletedTutorial();
					User.getInstance().hasFinishGuide = true;
					User.getInstance().canAutoFight = true;
					close();
					StoryManager.intance.showStoryModule(StoryManager.STORY_PANNEL);
					break;
				default:
					break;
			}
			
			fixMiddleBg();
		}
		
		private function showBg(e:Event):void
		{
			(e.target as EventDispatcher).off(Event.CLICK,showBg);
			_guideBg.visible = true;
		}
		
		private function drawBuildingBlock():void
		{
			var p:Point = drawBlankArea(buildSprite,true);
			view.arrowMotion.visible = true;
			view.arrowMotion.rotation = 180;
			view.arrowMotion.x = p.x+70;
			view.arrowMotion.y = p.y + 270;
			showCircelAnimation(p.x + buildSprite.width / 2+35, p.y + buildSprite.height / 2+15);
			//this.mouseThrough = view.mouseThrough  = true;
		}
		
		private function missonStepHandler(cmd:String="", ...args):void 
		{
			var p:Point;
			hideBlankArea();
			view.arrowMotion.rotation = 0;
			trace("misssGoBtn:", guideStep);
			view.des2.height = view.des2.textHeight = 30;
			view.middleBg.height = 80
			trace("missonStepHandler:", cmd);
			switch(guideStep)
			{
				case 105:
					
					AndroidPlatform.instance.FGM_CustumEvent("100_clk_bui");
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("L_A_39011");//"选择训练营";
					view.normalDes.visible = true;
					
					this._guideBg.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					Laya.timer.once(500, this, function() {
						
						//p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(0));
						p = drawBlankArea(fakeBlock);
						
						//view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(3).width-view.arrowMotion.width)/2;
						view.arrowMotion.x = 180;
						view.arrowMotion.y = LayerManager.instence.stageHeight;
						view.arrowMotion.visible = true;
						view.arrowMotion.rotation = 180;
						showCircelAnimation(fakeBlock.width / 2+10, fakeBlock.y + fakeBlock.height / 2);
						this._guideBg.visible = false;
						})
						
					break;
				
				case 106:
					
					stopAll = true;
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [107]);
					Laya.timer.once(500, this, function() { 
											this.mouseThrough = view.mouseThrough  = false;
											stopAll = false;
											guideStep = 106
											onClick();} );
					
					break;
				case 107:
					
					view.guideNpc.skin = "appRes/icon/guideNpc/p1.png"
					view.introWithMan.visible = true;
					AndroidPlatform.instance.FGM_CustumEvent("130_trn_dia1");
					view.des1.text = GameLanguage.getLangByKey("L_A_39017");//"凡是在战斗中损失的部队，都可以在训练营中通过训练来重新获得";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = true;
					this._guideBg.visible = true;
					
					Laya.timer.once(500, this, function() {
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						});
					
					
					break;
				case 109:
					
					AndroidPlatform.instance.FGM_CustumEvent("160_clk_spc");
					
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [109]);
					view.des1.text = GameLanguage.getLangByKey("L_A_39022");//"现在让我们来看看这个星系里有点什么吧";
					TFMotion();
					view.introWithMan.visible = true;
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.copyBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainView) as MainView).view.copyBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.copyBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.copyBtn.height / 2);
					_guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 251:
					/*this.mouseThrough = view.mouseThrough  = false;
					onClick();*/
					this.mouseThrough = view.mouseThrough  = false
					guideStep = 260;
					missonStepHandler();
					break;
				case 252:
					view.introWithMan.visible = false;
					view.des2.text = GameLanguage.getLangByKey("");//"选择兵营";
					view.normalDes.visible = true;
					
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					
					Laya.timer.once(750, this, function() {
						p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(1));
						view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(3).width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y;
						/*view.arrowMotion.x = 450;
						view.arrowMotion.y = LayerManager.instence.stageHeight;
						view.arrowMotion.rotation = 180;*/
						view.arrowMotion.visible = true;
						
						
						
						})
					break;
				case 260:			
					var aa:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_BOX);
					if(!aa){
						stopAll = true;
						_guideBg.visible = true;
						
						Laya.timer.once(500, this, function() {
							stopAll = false;
							_guideBg.visible = false;
							missonStepHandler();
						});
						return;
					}
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(aa);
					
					//AndroidPlatform.instance.FGM_CustumEvent("calim_rewards");
					AndroidPlatform.instance.FGM_CustumEvent("450_tow_dia1");
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [260]);
					view.normalDes.visible = false;
					view.des1.text = GameLanguage.getLangByKey("L_A_39038");//"是时候去搜索塔看看有没有什么发现";
					TFMotion();
					
					//var aa:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_BOX);
					//HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(aa);
					
					/*this.mouseThrough = view.mouseThrough  = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD]);
					
					Laya.timer.once(750, this, function() {
						p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(2));
						//view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(3).width-view.arrowMotion.width)/2;
						view.arrowMotion.x = 700;
						view.arrowMotion.y = LayerManager.instence.stageHeight;
						view.arrowMotion.visible = true;
						view.arrowMotion.rotation = 180;
						
						bg.visible = false;
						})*/
					break;
				case 280:
					view.des1.text = GameLanguage.getLangByKey("");//"我们去看看新兵种是啥？";
					var bb:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_CAMP);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(bb);
					this.mouseThrough = view.mouseThrough  = false;
					break;
				case 290:
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					view.des1.text = GameLanguage.getLangByKey("L_A_39037");//"领取这个奖励";
					TFMotion();
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					guideStep++;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
										
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case 291:
					//XFacade.instance.openModule("TrainView");
					guideStep = 311;
					missonStepHandler("asdf");
					break;
				case 293:
					this.mouseThrough = view.mouseThrough  = false;
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [293]);
					onClick();
					break;
				case 300:
					this._guideBg.visible = false;
					view.des2.text = GameLanguage.getLangByKey("L_A_39100");
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					Laya.timer.once(200, this, function() {
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						});
					break;
				case 311:
					guideStep = 320;
					this.mouseThrough = view.mouseThrough  = false;
					view.des1.text = GameLanguage.getLangByKey("");//"让我们来看看我们所拥有的资源";
					break;
				default:
					break;
			}
			fixMiddleBg();
		}
		
		
		public function guildeEventhandler(cmd:String,...args):void 
		{
			trace("新手引导事件:", cmd,"当前引导步骤：",guideStep);
			var p:Point;
			if(cmd!= NewerGuildeEvent.CREATE_SOILDER)
			{
				hideBlankArea();
				view.arrowMotion.rotation = 0;
			}
			view.des2.height = view.des2.textHeight = 30;
			view.middleBg.height = 80
			switch(cmd)
			{
				case NewerGuildeEvent.GUIDE_ATTACK_FINISH:
					
					fightData = args;
					
					
					if (args[0] == 999)
					{
						view.introWithMan.visible = false;
						view.normalDes.visible = false;
						view.arrowMotion.visible = false;
						return;
					}
					trace("============fightData:=============", fightData);
					if (guideStep > 0)
					{
						this.mouseThrough = view.mouseThrough  = false;
						stopAll = false;
						
						if (args[0] == 6)
						{
							onClick();
						}
						
						if (args[3] == 1)
						{
							onClick();
						}
						
						if (args[3] == 3)
						{
							//onClick();
						}
						
						if (args == 4)
						{
							guideStep = 100;
							onClick();
						}
						
					}
					break;
				case NewerGuildeEvent.SELECT_ACT_BAR:
					view.des1.text = GameLanguage.getLangByKey("L_A_39003");//"蓝色区域表示你的攻击范围，黄色区域表示伤害范围";
					TFMotion();
					this.mouseThrough = view.mouseThrough  = false;
					break;
				case NewerGuildeEvent.PUT_BUILDING_OK:
					if (guideStep > 300)
					{
						view.des2.text = GameLanguage.getLangByKey("L_A_39075");
						AndroidPlatform.instance.FGM_CustumEvent("750_clk_cfn");
						
					}
					else
					{
						view.normalDes.visible = true;
						view.des2.text = GameLanguage.getLangByKey("L_A_39012");//"点击确定";
						AndroidPlatform.instance.FGM_CustumEvent("110_clk_cfn");
						
					}
					
					p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.yesBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.yesBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.yesBtn.width / 2, 
											p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.yesBtn.height / 2);					
					break;
				case NewerGuildeEvent.CONFIRM_BUILDING:
					if (guideStep > 300)
					{
						view.des2.text = GameLanguage.getLangByKey("L_A_39082");//"点击加速";
						
						AndroidPlatform.instance.FGM_CustumEvent("760_clk_spd");
						WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [999]);
					}
					else if (guideStep > 250)
					{
						view.des2.text = GameLanguage.getLangByKey("L_A_39050");//"点击加速";
					}
					else
					{
						/*
						WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [103]);
						view.des2.text = GameLanguage.getLangByKey("L_A_39013");//"可以点击下方加速按钮进行加速，如果剩余时间小于10分钟则免费";*/
						
						//1016修改 直接完成建筑
						//AndroidPlatform.instance.FGM_CustumEvent("110_clk_cfn");
						WebSocketNetService.instance.sendData(ServiceConst.B_ONCE, [0]);
						guildeEventhandler(NewerGuildeEvent.SPEED_UP_BUILDING);
						return;
					}
					
					Laya.timer.once(500, this, function() { 
						/*p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.speedBtn);
						trace("p:",p);
						
						view.arrowMotion.x = p.x+(107-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						
						trace("x:",view.arrowMotion.x);
						trace("y:",view.arrowMotion.y);
						
						showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.speedBtn.width / 2, 
												p.y + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.speedBtn.height / 2);*/
						view.arrowMotion.visible = true;
						
						} );
					
					
					Laya.timer.once(3590000, this, this.guildeEventhandler, [NewerGuildeEvent.SPEED_UP_BUILDING]);
					break;
				case NewerGuildeEvent.SPEED_UP_BUILDING:
					Laya.timer.clear(this, this.guildeEventhandler);
					
					view.normalDes.visible = false;
					view.introWithMan.visible = true;
					
					if (guideStep > 300)
					{
						//AndroidPlatform.instance.FGM_CustumEvent("327_Click speed");
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						return;
					}
					else if (guideStep >= 260)
					{
						this.mouseThrough = view.mouseThrough  = false;
						view.normalDes.visible = true;
						view.des2.text = GameLanguage.getLangByKey("3");//"进入搜索塔";
						view.introWithMan.visible = false;
						onClick();
						return;
					}
					else if (guideStep > 250)
					{
						view.des1.text = GameLanguage.getLangByKey("2");//"兵营建好了,领取奖励";
						TFMotion();
						guideStep = 260;
					}
					else
					{
						//view.des1.text = GameLanguage.getLangByKey("L_A_39014");//"训练营已经建好了,我们先来领取奖励吧";
						view.introWithMan.visible = false;
						guideStep = 106;
						missonStepHandler();
						return;
						/*onClick();
						return;*/
					}
					
					p = drawBlankArea((XFacade.instance.getView(MainView) as MainView).view.goBtn);
					
					view.arrowMotion.x = p.x + 100;
					view.arrowMotion.y = p.y + 200;
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 180;
					this._guideBg.visible = false;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(MainView) as MainView).view.goBtn.width / 2, 
										p.y + (XFacade.instance.getView(MainView) as MainView).view.goBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					
					//
					break;
				case NewerGuildeEvent.ENTER_TRAIN_VIEW:
					
					hideBlankArea();
					view.normalDes.visible = false;
					if (guideStep == 295)
					{
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						return;
						//view.des1.text = GameLanguage.getLangByKey("L_A_39047");//"现在让我们训练一个狙击兵";
						//onClick();
					}
					else
					{
						//1016修改
						missonStepHandler(NewerGuildeEvent.SELECT_SOILDER);
					}
					view.introWithMan.visible = true;
					this._guideBg.visible = true;
					this.mouseThrough = view.mouseThrough  = false;
					//WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [999]);
					break;
				case NewerGuildeEvent.SELECT_SOILDER:
					view.introWithMan.visible = false;
					AndroidPlatform.instance.FGM_CustumEvent("140_clk_trn");
					view.des2.text = GameLanguage.getLangByKey("L_A_39019");// "点击训练";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = false;
					
					var p:Point = new Point();
					p = drawBlankArea((XFacade.instance.getView(TrainView) as TrainView).view.trainBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(TrainView) as TrainView).view.trainBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y-view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(TrainView) as TrainView).view.trainBtn.width / 2, 
										p.y + (XFacade.instance.getView(TrainView) as TrainView).view.trainBtn.height / 2);
					
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case NewerGuildeEvent.CLICK_TRAIN_BTN:
					switch(guideStep)
					{
						case 108:
							AndroidPlatform.instance.FGM_CustumEvent("150_clk_spd");
							WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [108]);
							view.des2.text = GameLanguage.getLangByKey("L_A_39020");//"训练士兵需要花费一点时间，现在让我们点击一下加速试试";
							break;
						case 296:
							AndroidPlatform.instance.FGM_CustumEvent("550_clk_spd");
							view.des2.text = GameLanguage.getLangByKey("L_A_39050");//"点击加速";
							WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [296]);
							break;
					}
					view.introWithMan.visible = false;
					//view.des2.text = "训练士兵需要花费一点时间，现在让我们点击一下加速试试";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					this._guideBg.visible = false;
					
					p = drawBlankArea((XFacade.instance.getView(TrainView) as TrainView).view.speedBtn);
					view.arrowMotion.x = p.x+((XFacade.instance.getView(TrainView) as TrainView).view.speedBtn.width-view.arrowMotion.width)/2;
					view.arrowMotion.y = p.y - view.arrowMotion.height;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + (XFacade.instance.getView(TrainView) as TrainView).view.speedBtn.width / 2, 
										p.y + (XFacade.instance.getView(TrainView) as TrainView).view.speedBtn.height / 2);
					
					// 自动过去   30秒兵已造好
					Laya.timer.once(30000, this, this.guildeEventhandler, [NewerGuildeEvent.CLICK_SPEED_UP]);
					
					break;
				case NewerGuildeEvent.CLICK_SPEED_UP:
					
					Laya.timer.clear(this, this.guildeEventhandler);
					
					if (guideStep == 296)
					{
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [296]);
						return;
					}
					hideBlankArea();
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [109]);
					
					break;
				case NewerGuildeEvent.AUTO_FINISH_TRAIN:
					//trace("兵种倒计时完毕");
					break;
				case NewerGuildeEvent.ENTER_FIGHT_MAP:
					
					if (guideStep >= 200)
					{
						
						missonStepHandler();
						return;
					}
					
					view.des2.text = GameLanguage.getLangByKey("L_A_39088");
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					
					AndroidPlatform.instance.FGM_CustumEvent("170_clk_stg1");
					view.introWithMan.visible = false;
					p = drawBlankArea((XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn('1'));
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = p.x+110;
					view.arrowMotion.y = p.y+310;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 75, p.y + 80);
					
					this._guideBg.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case NewerGuildeEvent.SHOW_CHAPTER_PANEL:
					stopAll = true;
					view.normalDes.visible = false;
					
					view.des2.text = GameLanguage.getLangByKey("L_A_39089");
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					//trace("打开面板的步骤:", guideStep);
					switch(guideStep)
					{
						case 109:
							AndroidPlatform.instance.FGM_CustumEvent("180_clk_atk_stg1");
							break;
						case 203:
							AndroidPlatform.instance.FGM_CustumEvent("320_clk_atk_stg2");
							break;
						case 301:
							AndroidPlatform.instance.FGM_CustumEvent("580_clk_atk_stg3");
							break;
						default:
							break;
					}
					
					Laya.timer.once(500, this, function() {
						stopAll = false;
						p = drawBlankArea(pTChapterLevelPanel.view.ackBtn);
						view.arrowMotion.x = p.x + 60;
						view.arrowMotion.y = p.y - 180;
						view.arrowMotion.visible = true;
						
						showCircelAnimation(p.x + pTChapterLevelPanel.view.ackBtn.width / 2, 
											p.y + pTChapterLevelPanel.view.ackBtn.height / 2);
						} );
					
					
					
					break;
				case NewerGuildeEvent.FIGHT_CHAPTER_ONE:
					if (!pveFightiView.selectUnitView.unitTypeTab ||
						!pveFightiView.selectUnitView.unitTypeTab.displayedInStage)
					{
						Laya.timer.once(500, this, guildeEventhandler, [NewerGuildeEvent.FIGHT_CHAPTER_ONE]);
						return;
					}
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					
					break;
				case NewerGuildeEvent.CREATE_SOILDER:
					soilderNum++;
					/*trace("上兵当前步骤为：", guideStep);
					trace("soilderNum: ", soilderNum);*/
					
					switch(guideStep)
					{
						case 111:
							if (soilderNum == 1)
							{
								AndroidPlatform.instance.FGM_CustumEvent("210_clk_gun");
							}
							if (soilderNum == 2)
							{
								//AndroidPlatform.instance.FGM_CustumEvent("210_clk_gun");
							}
							break;
						case 305:
							if(soilderNum == 5)
							{
								AndroidPlatform.instance.FGM_CustumEvent("630_clk_gun");	
							}
							
							if (soilderNum == 6)
							{
								AndroidPlatform.instance.FGM_CustumEvent("640_clk_sni");	
							}
							break;
						default:
							break;
					}
					
					if (soilderNum == 2)
					{
						/*hideBlankArea();
						bg.visible = true;
						view.normalDes.visible = false;
						this.mouseThrough = view.mouseThrough  = false;
						view.des1.text = "开战前你有充足的时间调整布阵，通过拖动已上阵的单位可以更换他们的位置，拖出阵型则为下阵";
						view.introWithMan.visible = true;*/
						this.mouseThrough = view.mouseThrough  = false;
						guideStep = 111;
						onClick();
					}
					if (soilderNum == 3 || soilderNum == 4 || soilderNum == 7 || guideStep == 302)// || soilderNum == 6 || soilderNum == 9)
					{
						if (guideStep == 302)
						{
							soilderNum = 4;
						}
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
					}
					
					break;
				case NewerGuildeEvent.START_BATTLE:
					//trace("开始战斗抖抖抖抖");
					this.mouseThrough = view.mouseThrough  = true;
//					ts.off(Event.CLICK,this,showBg)
					if (guideStep > 100)
					{
						_guideBg.visible = true;
						stopAll = true;
						Laya.timer.once(2000, this, function() {
							
							_guideBg.visible = false;
							stopAll = false;
							
							this.mouseThrough = view.mouseThrough  = false;
							onClick();
							});
					}
					else
					{
						onClick();
					}
					break;
				case NewerGuildeEvent.SELECT_MOVE:
					if (hasMoved || guideStep>120)
					{
						return;
					}
					
					AndroidPlatform.instance.FGM_CustumEvent("240_cfn_mov");
					hasMoved = true;
					this.hitArea = null;
					hideBlankArea();
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					view.des2.text = GameLanguage.getLangByKey("L_A_39027");//"蓝色格子表明了这个你能移动的范围，点击格子移动该单位";
					this._guideBg.visible = false;
					view.introWithMan.visible = false;
					p = drawBlankArea(pveFightingScane.tileList['point_123'],false,true);
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = 225;
					view.arrowMotion.y = 550;
					view.arrowMotion.visible = true;
					this.mouseThrough = view.mouseThrough  = true;
					
					showCircelAnimation(185,310);
					
					break;
				case NewerGuildeEvent.SHIELD_SOILDER_ACT:
					if (guideStep == 115)
					{
						view.introWithMan.visible = false;
						view.normalDes.visible = true;;
						this.mouseThrough = view.mouseThrough  = false;
						view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
						view.des2.text = GameLanguage.getLangByKey("L_A_39028");//"防爆兵一个肉盾单位,主要作用是为后排单位吸收伤害,点击防御提升防御力,同时跳过本回合";
						AndroidPlatform.instance.FGM_CustumEvent("250_clk_def");
						
						this.mouseThrough = view.mouseThrough  = true;
						this._guideBg.visible = false;
						p = drawBlankArea(pveFightiView.rightBottomView.DefenceBtn);
						view.arrowMotion.x = p.x+(pveFightiView.rightBottomView.DefenceBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y - view.arrowMotion.height;
						view.arrowMotion.visible = true;
						Signal.intance.off(NewerGuildeEvent.SHIELD_SOILDER_ACT, this, this.guildeEventhandler);
						
						showCircelAnimation(p.x + pveFightiView.rightBottomView.DefenceBtn.width / 2, 
										p.y + pveFightiView.rightBottomView.DefenceBtn.height / 2);
					}
					
					break;
				case NewerGuildeEvent.SELECT_DEFENCE:
					if (guideStep == 115)
					{
						//AndroidPlatform.instance.FGM_CustumEvent("113_quest_1_battle_click_defense");
						User.getInstance().lockMove = true;
						view.introWithMan.visible = false;
						view.normalDes.visible = false;
						this.mouseThrough = view.mouseThrough  = true;
						this.hitArea = null;
						Laya.timer.once(1000, this, function() { 
							/*this.view.introWithMan.visible = true;
							this.view.des1.text = GameLanguage.getLangByKey("L_A_39066");
							this.mouseThrough = view.mouseThrough  = false;*/
							
							//1016修改
							this.mouseThrough = view.mouseThrough  = false;
							onClick();
							
							} );
					}
					break;
				case NewerGuildeEvent.START_MOVE_GUIDE:
					//trace("开始移动引导", guideStep);
					/*if (guideStep == 110)
					{
						view.des2.text = "当攻击范围内没有敌人时，可以通过移动来更换位置，点击移动按钮";
						p = drawBlankArea((XFacade.instance.getView(FightingView) as FightingView).rightBottomView.MoveBtn);
						view.arrowMotion.x = p.x+((XFacade.instance.getView(FightingView) as FightingView).rightBottomView.MoveBtn.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = p.y - view.arrowMotion.height;
						view.arrowMotion.visible = true;
						bg.visible = false;
						this.mouseThrough = view.mouseThrough  = true;
						Signal.intance.off(NewerGuildeEvent.START_MOVE_GUIDE, this, this.guildeEventhandler);
					}*/
					
					break;
				case NewerGuildeEvent.MOVE_OVER:
					if (guideStep < 100)
					{
						return;
					}
					
					if (guideStep < 200)
					{
						//AndroidPlatform.instance.FGM_CustumEvent("113_quest_1_battle_move");
					}
					view.normalDes.visible = false;
					this.hitArea = null;
					this.mouseThrough = view.mouseThrough  = true;
					break;
				case NewerGuildeEvent.FIGHT_CHANGE_ROUND:
					if (guideStep == 116)
					{
						view.normalDes.visible = false;
						Laya.timer.once(2000, this, function() { 
							this.mouseThrough = view.mouseThrough  = false;
							onClick();
						} );
					}
					break;
				case NewerGuildeEvent.CHAPTER_ONE_OVER:
						
					view.normalDes.visible = false;
					if (guideStep > 200)
					{
						if(guideStep<300)
						{
							AndroidPlatform.instance.FGM_CustumEvent("410_clk_back");
							WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [250]);
						}
						else
						{
							User.getInstance().guideStep = 310;
							AndroidPlatform.instance.FGM_CustumEvent("670_clk_back");
							WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [324]);
						}
						stopAll = false;
						this.mouseThrough = view.mouseThrough  = true;
						this.hitArea = null;
						return;
					}
					/*view.normalDes.visible = true;
					view.des2.text = "此处显示的是战斗获得的奖励";
					view.arrowMotion.visible = true;
					view.arrowMotion.rotation = 90;
					view.arrowMotion.x = 850;
					view.arrowMotion.y = 245;
					this.mouseThrough = view.mouseThrough  = false;*/
					hideBlankArea();
					view.normalDes.visible = false;
					
					AndroidPlatform.instance.FGM_CustumEvent("280_clk_back");
					//guideStep = 113;
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					WebSocketNetService.instance.sendData(ServiceConst.SET_NEWER_GUIDE, [201]);
					break;
				case NewerGuildeEvent.BATTLE_GUILD_FINISH:
					//trace("round 2");
					
					this.mouseThrough = view.mouseThrough  = false;
					if (guideStep < 200)
					{
						guideStep = 200;
					}
					
					stopAll = true;
					Laya.timer.once(500, this, function() {
						stopAll = false;
						onClick();
						});
					//onClick();
					break;
				case NewerGuildeEvent.FIGHT_CHAPTER_TWO:
					//AndroidPlatform.instance.FGM_CustumEvent("203_quest_2_battle_click_attack");
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.HERO_FIGHT:
					//trace("英雄行动nowStep:", guideStep);
					if (guideStep == 207 || guideStep == 208 || guideStep == 209)
					{
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
					}
					
					if (guideStep == 309)
					{
						view.normalDes.visible = false;
						//p = drawBlankArea(pveFightingScane.tileList['point_210'],false,true);
						view.arrowMotion.rotation = 0;
						view.arrowMotion.x = 600;
						view.arrowMotion.y = 0;
						view.arrowMotion.visible = true;
					}
					
					break;
					break;
				case NewerGuildeEvent.USE_SKILL_TWO:
					//trace("guideStep:", guideStep);
					if (guideStep > 211)
					{
						return;
					}
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.START_LOTTLE_GUIDE:
					if (guideStep > 300)
					{
						//bg.visible = false;
						this.mouseThrough = view.mouseThrough  = false;
						onClick();
						return;
					}
					guideStep = 250;
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.ENTER_LOTTER_VIEW:
					//trace("进入抽奖");
					guideStep = 270;
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.SELECT_NORMAL_LOTTER:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.GET_LOTTER_RESULT:
					stopAll = false; 
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.SELECT_SNAPER:
					//trace("选择狙击手");
					
					view.des2.text = GameLanguage.getLangByKey("L_A_39048");//"选择狙击手";
					view.normalDes.visible = true;
					view.normalDes.y = LayerManager.instence.stageHeight*0.3;
					
					p = drawBlankArea((XFacade.instance.getView(CampView) as CampView).view.dom_list.getChildAt(0).getChildAt(3));
					view.arrowMotion.x = p.x+140;
					view.arrowMotion.y = p.y+300;
					view.arrowMotion.rotation = 180;
					view.arrowMotion.visible = true;
					
					showCircelAnimation(p.x + 85, p.y + 100);
					
					break;
				case NewerGuildeEvent.ENTER_CAMP_VIEW:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.RELEASE_SNAPER:
					XFacade.instance.closeModule(CampView);
					XFacade.instance.closeModule(UnitInfoView);
					guideStep = 290;
					//trace("收到解锁");
					missonStepHandler("adsf");
					/*this.mouseThrough = view.mouseThrough  = false;
					onClick();*/
					break;
				case NewerGuildeEvent.SET_NAME_OK:
					stopAll = false;
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					
					break;
				case NewerGuildeEvent.FIGHT_CHAPTER_THREE:
					//trace("进入战斗三");
				case NewerGuildeEvent.LAST_STEP:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.HANK_CLICK:
					this.mouseThrough = view.mouseThrough = true;
					this._guideBg.visible = true;
					break;
				case NewerGuildeEvent.OPEN_CONTRIBUTE_LIST:
					if (guideStep > 300)
					{
						AndroidPlatform.instance.FGM_CustumEvent("730_clk_res");
						view.des2.text = GameLanguage.getLangByKey("L_A_39073");
						this._guideBg.visible = false;
						
						//p = drawBlankArea((XFacade.instance.getView(MainMenuView) as MainMenuView).view.tab.getChildAt(2));
						p = drawBlankArea(fakeResource);
						
						view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.tab.getChildAt(2).width-view.arrowMotion.width)/2;
						view.arrowMotion.y = Laya.stage.height - 66 - view.arrowMotion.height;						
						view.arrowMotion.visible = true;
						
						
						showCircelAnimation(p.x + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.tab.getChildAt(2).width / 2, 
											Laya.stage.height - 66 + (XFacade.instance.getView(MainMenuView) as MainMenuView).view.tab.getChildAt(2).height / 2);
					}
					break;
				case NewerGuildeEvent.CHANGE_CONTRIBUTE_LIST:
					if (guideStep > 300)
					{
						AndroidPlatform.instance.FGM_CustumEvent("740_clk_alloy");
						p = drawBlankArea(fakeBlock);
						//view.arrowMotion.x = p.x+((XFacade.instance.getView(MainMenuView) as MainMenuView).view.pane.getChildAt(3).width-view.arrowMotion.width)/2;
						view.des2.text = GameLanguage.getLangByKey("L_A_39074");
						view.arrowMotion.x = 180;
						view.arrowMotion.y = LayerManager.instence.stageHeight;
						view.arrowMotion.visible = true;
						view.arrowMotion.rotation = 180;
						showCircelAnimation(fakeBlock.width / 2+10, fakeBlock.y + fakeBlock.height / 2);
						this._guideBg.visible = false;
					}
					break;
				case NewerGuildeEvent.OPEN_HELP_NOTE:
					hideBlankArea();
					view.introWithMan.visible = false;
					view.arrowMotion.visible = false;
					this.mouseThrough = view.mouseThrough  = true;
					this._guideBg.visible = false;
					this.hitArea = null;
					(XFacade.instance.getView(MainView) as MainView).view.dom_more_box.visible = false;
					var red_point:Node =(XFacade.instance.getView(MainView) as MainView).view.dom_more_box.getChildAt(0);
					red_point.visible = false;
					break;
				case NewerGuildeEvent.CLOSE_HELP_NOTE:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
					break;
				case NewerGuildeEvent.OPEN_SET_NOTE:
					this.mouseThrough = view.mouseThrough  = false;
					onClick();
				default:
					break;
					
			}
			
			fixMiddleBg();
		}
		
		private function showCircelAnimation(tx:Number,ty:Number):void
		{
			circleEffect.x = tx - 256;
			circleEffect.y = ty - 256;
			circleEffect.play(0);
			circleEffect.visible = true;
		}
		
		private function hideBlankArea():void
		{
			//trace("adsfasdfasdfdasfasd");
			this.blankArea.visible = false;
			//this.hitArea = null;
			view.arrowMotion.visible = false;
			circleEffect.stop();
			circleEffect.visible = false;
		}
		
		
		private function drawBlankArea(target:*, bdBlock:Boolean = false, isTile:Boolean = false):Point
		{
			tagetSprite = target as Sprite;
			var pi:Point = new Point(0, 0);
			//trace("t:", tagetSprite.width);
			//trace("td:", tagetSprite.displayedInStage);
			if (tagetSprite && tagetSprite.displayedInStage)
			{
				pi = new Point(tagetSprite.x,tagetSprite.y);
				var pp:Sprite = tagetSprite.parent as Sprite;
				if(pp && pp is Sprite)
				{
					pp.localToGlobal(pi);
				}
				
				this.size(Laya.stage.width , Laya.stage.height);
				var w:Number = tagetSprite.width * tagetSprite.globalScaleX;
				var h:Number = tagetSprite.height * tagetSprite.globalScaleY;
				
				if (bdBlock)
				{
					w = 60;
					h = 80;
					pi.x -= 30;
					pi.y -= 100;
				}
				
				if (isTile)
				{
					w *= 0.5;
					h *= 0.5;
					pi.x += 55;
					pi.y += 25;
				}
				
				blankArea.graphics.clear();
				blankArea.graphics.alpha(guildAlpha);
				
				blankArea.graphics.drawPoly(pi.x,pi.y,[
					w >> 1, 0,
					w >> 1, 0 - pi.y,
					0 - pi.x , 0 - pi.y,
					0 - pi.x , height - pi.y,
					width - pi.x , height - pi.y,
					width - pi.x , 0 - pi.y,
					w >> 1 , 0 - pi.y,
					w >> 1, 0,
					w , 0 ,
					w , h,
					0, h,
					0, 0				
				],"#000000");
				
				
				imgHitArea.hit.clear();
				imgHitArea.hit.drawPoly(pi.x,pi.y,[
					w >> 1, 0,
					w >> 1, 0 - pi.y,
					0 - pi.x , 0 - pi.y,
					0 - pi.x , height - pi.y,
					width - pi.x , height - pi.y,
					width - pi.x , 0 - pi.y,
					w >> 1 , 0 - pi.y,
					w >> 1, 0,
					w , 0 ,
					w , h,
					0, h,
					0, 0					
				],"#000000");
				
				this.hitArea = imgHitArea;
				this.blankArea.visible = true;
			}
			return pi
		}
		
		override public function onStageResize():void {
			
			view.width = LayerManager.instence.stageWidth;
			view.height = LayerManager.instence.stageHeight;
			
			view.normalDes.x = (LayerManager.instence.stageWidth - view.normalDes.width) / 2;
			view.normalDes.y = LayerManager.instence.stageHeight*0.7;
			
			view.introWithMan.y = LayerManager.instence.stageHeight - view.introWithMan.height;
			this._guideBg.size(LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			super.onStageResize();
		}
		
		override public function close():void {
			super.close();
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		
		override public function createUI():void {
			this._guideBg  = new Sprite();
			/*trace("bg:", this._bg);
			trace("bg:", this._bg.graphics);*/
			//this._bg.graphics.alpha(0.5);
			this._guideBg.graphics.drawRect(0, 0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight,"#ffffff");
			this._guideBg.alpha = guildAlpha;
			this._guideBg.mouseEnabled = true;
			this.addChild(_guideBg);
			
			this._view = new GuiderViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			circleEffect = new Animation();
			circleEffect.loadAtlas("appRes/atlas/effects/guideEffect.json");
			circleEffect.play(0)
			//circleEffect.stop();
			//circleEffect.visible = false;
			view.addChild(circleEffect);
			
			blankArea = new Sprite();
			this.addChild(blankArea);
			
			imgHitArea = new HitArea();
			
			this.view.normalDes.mouseEnabled = false;
			this.view.des1.mouseEnabled = false;
			this.view.normalDes.visible = false;
			this.view.arrowMotion.visible = false;
			
			this.view.introWithMan.visible = true;
			this.view.introWithMan.mouseEnabled = false;
			view.guideNpc.skin = "appRes/icon/guideNpc/p1.png"
			this.view.des1.text = GameLanguage.getLangByKey("L_A_39079").replace(/##/g,"\n");//"指挥官你终于醒来了，我们的飞船坠毁在这个星球了";
			
			tfMask = new Sprite();
			tfMask.graphics.drawRect(view.des1.x, view.des1.y, view.des1.width, view.des1.height, "#ff00ff");
			
			//TFMotion();
			
			view.des1.parent.mask = tfMask;
			
			view.des2.fontSize = 24;
			view.des2.wordWrap = true;
			
			view.arrowMotion.mouseEnabled = false;
			
			fakeBlock = new Sprite();
			fakeBlock.width = 260;
			fakeBlock.height = 350;
			fakeBlock.x = 0;
			//fakeBlock.y = 210;
			fakeBlock.y = LayerManager.instence.stageHeight - 430;
			fakeBlock.graphics.drawRect(0, 0, 260, 350, "#f0f0f0");
			fakeBlock.alpha = 0.01;
			fakeBlock.mouseEnabled = false;
			view.addChild(fakeBlock);
			
			fakeBlockTwo = new Sprite();
			fakeBlockTwo.width = 140;
			fakeBlockTwo.height = 150;
			fakeBlockTwo.x = 20;
			//fakeBlockTwo.y = 482;
			fakeBlockTwo.y = LayerManager.instence.stageHeight - 158;
			fakeBlockTwo.graphics.drawRect(0, 0, 140, 150, "#f0f0f0");
			fakeBlockTwo.alpha = 0.01;
			fakeBlockTwo.mouseEnabled = false;
			view.addChild(fakeBlockTwo);
			
			fakeResource = new Sprite();
			fakeResource.width = 240;
			fakeResource.height = 50;
			fakeResource.x = 555;
			fakeResource.y = LayerManager.instence.stageHeight - 55;
			fakeResource.graphics.drawRect(0, 0, 240, 50, "#f0f0f0");
			fakeResource.alpha = 0.01;
			fakeResource.mouseEnabled = false;
			view.addChild(fakeResource);
			
			view.btnTips.visible = false;
			view.leftBtnTips.visible = false;
			view.downBtnTips.visible = false;
			view.rightBtnTips.visible = false;
			
			this.onStageResize();
			
		}
		
		private function fixMiddleBg():void
		{
			if (view.des2.textHeight > 30)
			{
				view.middleBg.height = view.des2.textHeight + 50;
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			this._guideBg.on(Event.CLICK, this, this.onClick);
			//stopShade.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(NewerGuildeEvent.GUIDE_ATTACK_FINISH, this, this.guildeEventhandler, [NewerGuildeEvent.GUIDE_ATTACK_FINISH]);
			Signal.intance.on(NewerGuildeEvent.SHOW_ATTACK_ARROW, this, this.guildeEventhandler, [NewerGuildeEvent.SHOW_ATTACK_ARROW]);
			Signal.intance.on(NewerGuildeEvent.FIGHT_CHANGE_ROUND, this, this.guildeEventhandler, [NewerGuildeEvent.FIGHT_CHANGE_ROUND]);
			//Signal.intance.on(NewerGuildeEvent.ENTER_BATTLE_SCENCE, this, this.guildeEventhandler, [NewerGuildeEvent.ENTER_BATTLE_SCENCE]);
			Signal.intance.on(NewerGuildeEvent.CREATE_SOILDER, this, this.guildeEventhandler, [NewerGuildeEvent.CREATE_SOILDER]);
			Signal.intance.on(NewerGuildeEvent.START_BATTLE, this, this.guildeEventhandler, [NewerGuildeEvent.START_BATTLE]);
			Signal.intance.on(NewerGuildeEvent.SHIELD_SOILDER_ACT, this, this.guildeEventhandler, [NewerGuildeEvent.SHIELD_SOILDER_ACT]);
			Signal.intance.on(NewerGuildeEvent.SELECT_DEFENCE, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_DEFENCE]);
			Signal.intance.on(NewerGuildeEvent.START_MOVE_GUIDE, this, this.guildeEventhandler, [NewerGuildeEvent.START_MOVE_GUIDE]);
			Signal.intance.on(NewerGuildeEvent.SELECT_MOVE, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_MOVE]);
			Signal.intance.on(NewerGuildeEvent.MOVE_OVER, this, this.guildeEventhandler, [NewerGuildeEvent.MOVE_OVER]);
			Signal.intance.on(NewerGuildeEvent.BATTLE_GUILD_FINISH, this, this.guildeEventhandler, [NewerGuildeEvent.BATTLE_GUILD_FINISH]);
			Signal.intance.on(NewerGuildeEvent.OPEN_CONTRIBUTE_LIST, this, this.guildeEventhandler, [NewerGuildeEvent.OPEN_CONTRIBUTE_LIST]);
			Signal.intance.on(NewerGuildeEvent.CHANGE_CONTRIBUTE_LIST, this, this.guildeEventhandler, [NewerGuildeEvent.CHANGE_CONTRIBUTE_LIST]);
			Signal.intance.on(NewerGuildeEvent.PUT_BUILDING_OK, this, this.guildeEventhandler, [NewerGuildeEvent.PUT_BUILDING_OK]);
			Signal.intance.on(NewerGuildeEvent.CONFIRM_BUILDING, this, this.guildeEventhandler, [NewerGuildeEvent.CONFIRM_BUILDING]);
			Signal.intance.on(NewerGuildeEvent.SPEED_UP_BUILDING, this, this.guildeEventhandler, [NewerGuildeEvent.SPEED_UP_BUILDING]);
			Signal.intance.on(NewerGuildeEvent.ENTER_TRAIN_VIEW, this, this.guildeEventhandler, [NewerGuildeEvent.ENTER_TRAIN_VIEW]);
			Signal.intance.on(NewerGuildeEvent.CLICK_TRAIN_BTN, this, this.guildeEventhandler, [NewerGuildeEvent.CLICK_TRAIN_BTN]);
			Signal.intance.on(NewerGuildeEvent.AUTO_FINISH_TRAIN, this, this.guildeEventhandler, [NewerGuildeEvent.AUTO_FINISH_TRAIN]);
			Signal.intance.on(NewerGuildeEvent.CLICK_SPEED_UP, this, this.guildeEventhandler, [NewerGuildeEvent.CLICK_SPEED_UP]);
			Signal.intance.on(NewerGuildeEvent.SELECT_SOILDER, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_SOILDER]);
			Signal.intance.on(NewerGuildeEvent.ENTER_FIGHT_MAP, this, this.guildeEventhandler, [NewerGuildeEvent.ENTER_FIGHT_MAP]);
			Signal.intance.on(NewerGuildeEvent.SHOW_CHAPTER_PANEL, this, this.guildeEventhandler, [NewerGuildeEvent.SHOW_CHAPTER_PANEL]);
			Signal.intance.on(NewerGuildeEvent.FIGHT_CHAPTER_ONE, this, this.guildeEventhandler, [NewerGuildeEvent.FIGHT_CHAPTER_ONE]);
			//Signal.intance.on(NewerGuildeEvent.SELECT_ACT_BAR, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_ACT_BAR]);
			Signal.intance.on(NewerGuildeEvent.CHAPTER_ONE_OVER, this, this.guildeEventhandler, [NewerGuildeEvent.CHAPTER_ONE_OVER]);
			Signal.intance.on(NewerGuildeEvent.FIGHT_CHAPTER_TWO, this, this.guildeEventhandler, [NewerGuildeEvent.FIGHT_CHAPTER_TWO]);
			Signal.intance.on(NewerGuildeEvent.USE_SKILL_TWO, this, this.guildeEventhandler, [NewerGuildeEvent.USE_SKILL_TWO]);
			Signal.intance.on(NewerGuildeEvent.HERO_FIGHT, this, this.guildeEventhandler, [NewerGuildeEvent.HERO_FIGHT]);
			Signal.intance.on(NewerGuildeEvent.START_LOTTLE_GUIDE, this, this.guildeEventhandler, [NewerGuildeEvent.START_LOTTLE_GUIDE]);
			Signal.intance.on(NewerGuildeEvent.ENTER_LOTTER_VIEW, this, this.guildeEventhandler, [NewerGuildeEvent.ENTER_LOTTER_VIEW]);
			Signal.intance.on(NewerGuildeEvent.SELECT_NORMAL_LOTTER, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_NORMAL_LOTTER]);
			Signal.intance.on(NewerGuildeEvent.GET_LOTTER_RESULT, this, this.guildeEventhandler, [NewerGuildeEvent.GET_LOTTER_RESULT]);
			Signal.intance.on(NewerGuildeEvent.ENTER_CAMP_VIEW, this, this.guildeEventhandler, [NewerGuildeEvent.ENTER_CAMP_VIEW]);
			Signal.intance.on(NewerGuildeEvent.RELEASE_SNAPER, this, this.guildeEventhandler, [NewerGuildeEvent.RELEASE_SNAPER]);
			Signal.intance.on(NewerGuildeEvent.FIGHT_CHAPTER_THREE, this, this.guildeEventhandler, [NewerGuildeEvent.FIGHT_CHAPTER_THREE]);
			Signal.intance.on(NewerGuildeEvent.LAST_STEP, this, this.guildeEventhandler, [NewerGuildeEvent.LAST_STEP]);
			Signal.intance.on(NewerGuildeEvent.HANK_CLICK, this, this.guildeEventhandler, [NewerGuildeEvent.HANK_CLICK]);
			Signal.intance.on(NewerGuildeEvent.SELECT_SNAPER, this, this.guildeEventhandler, [NewerGuildeEvent.SELECT_SNAPER]);
			Signal.intance.on(NewerGuildeEvent.SET_NAME_OK, this, this.guildeEventhandler, [NewerGuildeEvent.SET_NAME_OK]);
			Signal.intance.on(NewerGuildeEvent.OPEN_HELP_NOTE, this, this.guildeEventhandler, [NewerGuildeEvent.OPEN_HELP_NOTE]);
			Signal.intance.on(NewerGuildeEvent.CLOSE_HELP_NOTE, this, this.guildeEventhandler, [NewerGuildeEvent.CLOSE_HELP_NOTE]);
			Signal.intance.on(NewerGuildeEvent.OPEN_SET_NOTE, this, this.guildeEventhandler, [NewerGuildeEvent.OPEN_SET_NOTE]);
			
			Signal.intance.on(NewerGuildeEvent.CLICK_GO_BTN, this, this.missonStepHandler, [NewerGuildeEvent.CLICK_GO_BTN]);
			super.addEvent();
		}
		
		/**保留*/
		override public function dispose():void{
			
		}
		
		private function removeFightEvent():void
		{
			Signal.intance.off(NewerGuildeEvent.FIGHT_CHANGE_ROUND, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CHAPTER_ONE_OVER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.START_BATTLE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_SOILDER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SHIELD_SOILDER_ACT, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_DEFENCE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.START_MOVE_GUIDE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_MOVE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.MOVE_OVER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.BATTLE_GUILD_FINISH, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.USE_SKILL_TWO, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.HERO_FIGHT, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.RELEASE_SNAPER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_SNAPER, this, this.guildeEventhandler);
			
		}
		
		override public function destroy():Rectangle 
		{
			
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			this._guideBg.off(Event.CLICK, this, this.onClick);
			//stopShade.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(NewerGuildeEvent.GUIDE_ATTACK_FINISH, this, this.guildeEventhandler);
			//Signal.intance.off(NewerGuildeEvent.SELECT_ACT_BAR, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SHOW_ATTACK_ARROW, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.FIGHT_CHANGE_ROUND, this, this.guildeEventhandler);
			//Signal.intance.off(NewerGuildeEvent.ENTER_BATTLE_SCENCE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CREATE_SOILDER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.START_BATTLE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_SOILDER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SHIELD_SOILDER_ACT, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_DEFENCE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.START_MOVE_GUIDE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_MOVE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.MOVE_OVER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.BATTLE_GUILD_FINISH, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.OPEN_CONTRIBUTE_LIST, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CHANGE_CONTRIBUTE_LIST, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.PUT_BUILDING_OK, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CONFIRM_BUILDING, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.ENTER_TRAIN_VIEW, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CLICK_TRAIN_BTN, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.AUTO_FINISH_TRAIN, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CLICK_SPEED_UP, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_SOILDER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.ENTER_FIGHT_MAP, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SHOW_CHAPTER_PANEL, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.FIGHT_CHAPTER_ONE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CHAPTER_ONE_OVER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.FIGHT_CHAPTER_TWO, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.USE_SKILL_TWO, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.HERO_FIGHT, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.START_LOTTLE_GUIDE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.ENTER_LOTTER_VIEW, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_NORMAL_LOTTER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.GET_LOTTER_RESULT, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.ENTER_CAMP_VIEW, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.RELEASE_SNAPER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.FIGHT_CHAPTER_THREE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.LAST_STEP, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.HANK_CLICK, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SELECT_SNAPER, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.SET_NAME_OK, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.OPEN_HELP_NOTE, this, this.guildeEventhandler);
			Signal.intance.off(NewerGuildeEvent.CLOSE_HELP_NOTE, this, this.guildeEventhandler);
			
			Signal.intance.off(NewerGuildeEvent.CLICK_GO_BTN, this, this.missonStepHandler);
			
			super.removeEvent();
		}
		
		private function get view():GuiderViewUI{
			return _view;
		}
		
		protected function get pvpFightiView():PvpFightingView{
			return XFacade.instance.getView(PvpFightingView);
		}
		protected function get pveFightiView():PveFightingView{
			return XFacade.instance.getView(PveFightingView);
		}
		protected function get pveFightingScane():PveFightingScane{
			return XFacade.instance.getView(PveFightingScane);
		}
		protected function get pTChapterLevelPanel():PTChapterLevelPanel{
			return XFacade.instance.getView(PTChapterLevelPanel);
		}
		
		private var _tweenPlay:Boolean;
		protected function from(target:*, props:Object, duration:int):Tween {
//			_tweenPlay = true;
			return Tween.from(target,props,duration,null
//				,Handler.create(null,function(){
//										_tweenPlay = false;
//									}
//				)
			);
		}
		
	}

}