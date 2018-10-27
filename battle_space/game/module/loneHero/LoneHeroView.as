package game.module.loneHero 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.consts.ServiceConst;
	import game.global.data.DBSkill2;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.util.UnitPicUtil;
	import game.global.vo.SkillBuffVo;
	import game.global.vo.SkillVo;
	import game.module.bingBook.ItemContainer;
	import game.module.camp.CampData;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
	import MornUI.loneHero.loneHeroViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LoneHeroView extends BaseDialog 
	{
		
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>(3);
		private var _stageBtnVec:Vector.<Button> = new Vector.<Button>(7);
		private var _plantAniVec:Vector.<Animation> = new Vector.<Animation>(7);
		private var _frameAni:Animation;
		
		private var _refreshHeroTime:int = 0;
		private var _refreshRateTime:int = 0;
		private var _resetTime:int = 0;
		
		private var _s0Img:Image;
		private var _s1Img:Image;
		
		private var _skill0:SkillVo;
		private var _skill1:SkillVo;
		
		private var _motionArr:Array = ["1", "1.5", "2", "2.5", "3"];
		private var _motionIndex:int = 0;
		private var _motionTarget:Number = 2.5;
		
		private var _heroNeedAlert:Boolean = false;
		private var _resetNeedAlert:Boolean = false;
		private var _rateNeedAlert:Boolean = false;
		
		private var _maxAnimation:Animation;
		
		public function LoneHeroView() 
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
				case view.closeBtn:
					close();
					break;
				case _s0Img:
					//trace("_skill0:", _skill0);
					arr = (_skill0.skill_value+"").split("|");
					str = GameLanguage.getLangByKey(_skill0.skill_describe);
					for(i=0; i<arr.length; i++){
						str = str.replace(/{(\d+)}/, XUtils.toFixed(arr[i]));
					}
					XTipManager.showTip(GameLanguage.getLangByKey(str));
					break;
				case _s1Img:
					//trace("_skill1:", _skill1);
					arr = (_skill1.skill_value+"").split("|");
					str = GameLanguage.getLangByKey(_skill1.skill_describe);
					for(i=0; i<arr.length; i++){
						str = str.replace(/{(\d+)}/, XUtils.toFixed(arr[i]));
					}
					XTipManager.showTip(GameLanguage.getLangByKey(str));
					break;
				case view.refreshHeroBtn:
					if (_heroNeedAlert)
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_80000"),
																			1,
																			parseInt(view.heroResetTxt.text),
																			function(){									
																				WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_REFRESH_HERO);
																			}]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_REFRESH_HERO);
					}
					break;
				case view.resetBtn:
					if (_resetNeedAlert)
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_80001"),
																			1,
																			parseInt(view.fightResetTxt.text),
																			function(){									
																				WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_RESET_STAGE);
																			}]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_RESET_STAGE);
					}
					break;
				case view.refreshRateBtn:
					if (_rateNeedAlert)
					{
						XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_80002"),
																			1,
																			parseInt(view.ratePriceTxt.text),
																			function(){									
																				WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_REFRESH_RATE);
																			}]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_REFRESH_RATE);
					}
					break;
				case view.fightBtn:
					close();
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_LONEHERO, null,Handler.create(this, onFightOver));
					break;
				case view.infoBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_80005"));
					break;
				default:
					break;
				
			}
		}
		
		private function onFightOver():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			XFacade.instance.openModule(ModuleName.LoneHeroView);
		}
		
		private function playRateMotion():void
		{
			setRate(_motionArr[_motionIndex%5]);
			_motionIndex++;
			
			if (_motionIndex < 20)
			{
				Laya.timer.once(50, this, playRateMotion);
			}
			else
			{
				view.refreshRateBtn.disabled = false;
				setRate(_motionTarget);
				
				if (_motionTarget == 3)
				{
					_maxAnimation.visible = true;
					_maxAnimation.play(0, false);
					Laya.timer.once(750, this, function() {_maxAnimation.visible=false } );
				}
			}
		}
		
		private function setRate(rate:String):void
		{
			var color:String = "";
			view.maxImg.visible = false;
			view.refreshRateBtn.visible = true;
			switch(rate.toString())
			{
				case "1":
					view.xImg.skin = "loneHero/x.png"
					view.n1Txt.text = 1;
					view.n3Txt.text = 0;
					color = "#ffffff";
					break;
				case "1.5":
					view.xImg.skin = "loneHero/xlv.png"
					view.n1Txt.text = 1;
					view.n3Txt.text = 5;
					color = "#02CC49";
					break;
				case "2":
					view.xImg.skin = "loneHero/xl.png"
					view.n1Txt.text = 2;
					view.n3Txt.text = 0;
					color = "#79D3FF";					
					break;
				case "2.5":
					view.xImg.skin = "loneHero/xzi.png"
					view.n1Txt.text = 2;
					view.n3Txt.text = 5;
					color = "#ff6DEE";
					break;
				case "3":
					view.xImg.skin = "loneHero/xred.png"
					view.n1Txt.text = 3;
					view.n3Txt.text = 0;
					view.maxImg.visible = true;
					view.refreshRateBtn.visible = false;
					color = "#ff4041";
					break;
			}
			view.n1Txt.color = view.n2Txt.color = view.n3Txt.color = color;
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			 trace("loneHero: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int = 0;
			var cData:Object = { };
			switch(cmd)
			{
				case ServiceConst.LONEHERO_INIT:
				case ServiceConst.LONEHERO_RESET_STAGE:
					var reArr:Array = GameConfigManager.LoneHeroReward[args[1].hqLevel + "-" + args[1].level].reward.split(";");
					len = 3;
					for (i = 0; i < len; i++ )
					{
						_rewardVec[i].setData(reArr[i].split("=")[0], reArr[i].split("=")[1]);
					}
					
					_refreshHeroTime = args[1].refreshTimes;
					_resetTime = args[1].resetTimes;
					cData = GameConfigManager.unit_json[args[1].team];
					/*trace("cData:", cData);
					trace("head:", UnitPicUtil.getUintPic(cData.unitId, UnitPicUtil.ICON));*/
					view.headImg.skin = UnitPicUtil.getUintPic(cData.unit_id, UnitPicUtil.ICON);
					view.attackIcon.skin = "common/icons/a_" + cData.attack_type+".png";
					view.defendIcon.skin = "common/icons/b_" + cData.defense_type+".png";
					
					_skill0 = GameConfigManager.unit_skill_dic[cData.skill_id.split("|")[0]];
					_skill1 = DBSkill2.getSkillInfo(cData.skill2_id.split("|")[0]);
					
					_s0Img.skin = _skill0.iconUrl;
					_s1Img.skin = "appRes/icon/skillIcon/"+_skill1.skill_icon+".png";
					/*trace("_skill0:", _skill0);
					trace("_skill1:", _skill1);*/
					
					var nowLevel:int = parseInt(args[1].level) - 1;
					
					view.fightBtn.disabled = false;
					view.refreshHeroBtn.disabled = false;
					if (args[1].finished == "1")
					{
						nowLevel = 8;
						view.fightBtn.disabled = true;
						view.refreshHeroBtn.disabled = true;
					}
					
					for (i = 0; i < 7; i++ )
					{
						//_stageBtnVec[i].disabled = false;
						if (i < nowLevel)
						{
							if (!_plantAniVec[i])
							{
								_plantAniVec[i] = new Animation();
								_plantAniVec[i].interval = 100;
								_plantAniVec[i].x = _stageBtnVec[i].x - 7;
								_plantAniVec[i].y = _stageBtnVec[i].y - 7;
								view.addChild(_plantAniVec[i]);
							}
							_plantAniVec[i].visible = true;
							_plantAniVec[i].loadAtlas("appRes/atlas/effects/LH_BPlant.json");
							_plantAniVec[i].play();
							//_stageBtnVec[i].skin = "loneHero/lan.png"
							_stageBtnVec[i].skin = ""
							_stageBtnVec[i].visible = false;
						}
						else if (i == nowLevel)
						{
							if (!_plantAniVec[i])
							{
								_plantAniVec[i] = new Animation();
								_plantAniVec[i].interval = 100;
								_plantAniVec[i].x = _stageBtnVec[i].x - 7;
								_plantAniVec[i].y = _stageBtnVec[i].y - 7;
								view.addChild(_plantAniVec[i]);
							}
							_plantAniVec[i].visible = true;
							_plantAniVec[i].loadAtlas("appRes/atlas/effects/LH_YPlant.json");
							_plantAniVec[i].play();
							//_stageBtnVec[i].skin = "loneHero/huang.png"
							_stageBtnVec[i].skin = ""
							_stageBtnVec[i].visible = false;
						}
						else
						{
							if (_plantAniVec[i])
							{
								_plantAniVec[i].stop();
								_plantAniVec[i].visible = false;
							}
							
							_stageBtnVec[i].skin = "loneHero/hui.png";
							_stageBtnVec[i].visible = true;
						}
					}
					
					view.resetBtn.disabled = Boolean(args[1].level == "1");
					
					_heroNeedAlert = Boolean(parseInt(args[1].refreshTimes) == 0);
					_resetNeedAlert = Boolean(parseInt(args[1].resetTimes) == 0);
					_rateNeedAlert = Boolean(parseInt(args[1].awardTimes) == 0);
					
					view.heroResetTxt.text = GameConfigManager.intance.getLoneHeroRefreshPrice(parseInt(args[1].refreshTimes));
					view.ratePriceTxt.text = GameConfigManager.intance.getLoneHeroRefreshRate(parseInt(args[1].awardTimes));
					view.fightResetTxt.text = GameConfigManager.intance.getLoneHeroResetPrice(parseInt(args[1].resetTimes));
					
					setRate(args[1].rewardRate);
					break;
				case ServiceConst.LONEHERO_REFRESH_HERO:
					cData = GameConfigManager.unit_json[args[1].team];
					view.headImg.skin = UnitPicUtil.getUintPic(cData.unit_id, UnitPicUtil.ICON);
					view.attackIcon.skin = "common/icons/a_" + cData.attack_type+".png";
					view.defendIcon.skin = "common/icons/b_" + cData.defense_type+".png";
					
					_skill0 = GameConfigManager.unit_skill_dic[cData.skill_id.split("|")[0]];
					_skill1 = DBSkill2.getSkillInfo(cData.skill2_id.split("|")[0]);
					
					_s0Img.skin = _skill0.iconUrl;
					_s1Img.skin = "appRes/icon/skillIcon/" + _skill1.skill_icon + ".png";
					
					view.heroResetTxt.text = GameConfigManager.intance.getLoneHeroRefreshPrice(parseInt(args[1].refreshTimes));
					break;
				case ServiceConst.LONEHERO_REFRESH_RATE:
					view.refreshRateBtn.disabled = true;
					_motionIndex = 0;
					playRateMotion();
					_motionTarget = args[1];
					_rateNeedAlert = Boolean(parseInt(args[2].awardTimes) == 0);
					view.ratePriceTxt.text = GameConfigManager.intance.getLoneHeroRefreshRate(parseInt(args[2]));
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(...args):void{
			super.show();
			this.view.visible = true;
			AnimationUtil.flowIn(this);
			
			view.maxImg.visible = false;
			view.refreshRateBtn.visible = true;
			
			
			WebSocketNetService.instance.sendData(ServiceConst.LONEHERO_INIT);
			
		}
		
		override public function close():void{
			
			view.refreshRateBtn.disabled = false;
			_motionIndex = 99;
			
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new loneHeroViewUI();
			this.addChild(_view);
			GameConfigManager.intance.initLoneHero();
			
			this.closeOnBlank = true;
			
			_frameAni = new Animation();
			_frameAni.interval = 150;
			_frameAni.x = 376;
			_frameAni.y = 167;
			_frameAni.loadAtlas("appRes/atlas/effects/LH_Frame.json");
			_frameAni.play();
			view.addChildAt(_frameAni,5);
			
			var i:int = 0;
			for (i = 0; i < 3;i++ )
			{
				_rewardVec[i] = new ItemContainer();
				_rewardVec[i].x = 415+88*i;
				_rewardVec[i].y = 210;
				view.addChild(_rewardVec[i]);
			}
			
			_maxAnimation = new Animation();
			_maxAnimation.interval = 150;
			_maxAnimation.x = 500;
			_maxAnimation.y = 166;
			_maxAnimation.loadAtlas("appRes/atlas/effects/LH_max.json");
			_maxAnimation.visible = false;
			_maxAnimation.stop();
			view.addChild(_maxAnimation);
			
			_s0Img = new Image();
			_s0Img.width = _s0Img.height = 40;
			_s0Img.x = 465;
			_s0Img.y = 90;
			_s0Img.mouseEnabled = true;
			view.addChild(_s0Img);
			
			_s1Img = new Image();
			_s1Img.width = _s1Img.height = 40;
			_s1Img.x = 465;
			_s1Img.y = 137;
			_s1Img.mouseEnabled = true;
			view.addChild(_s1Img);
			
			for (i = 0; i < 7; i++ )
			{
				_stageBtnVec[i] = view["stage_" + i];
				//_stageBtnVec[i].disabled = true;
			}
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_INIT), this, this.serviceResultHandler,[ServiceConst.LONEHERO_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_RESET_STAGE), this, this.serviceResultHandler,[ServiceConst.LONEHERO_RESET_STAGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_REFRESH_HERO), this, this.serviceResultHandler,[ServiceConst.LONEHERO_REFRESH_HERO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_REFRESH_RATE), this, this.serviceResultHandler,[ServiceConst.LONEHERO_REFRESH_RATE]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_INIT), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_RESET_STAGE), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_REFRESH_HERO), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LONEHERO_REFRESH_RATE), this, this.serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		public function get view():loneHeroViewUI{
			return _view;
		}
	}

}