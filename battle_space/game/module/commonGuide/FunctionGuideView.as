package game.module.commonGuide 
{
	import MornUI.newerGuide.GuiderViewUI;
	
	import game.common.LayerManager;
	import game.common.ModuleManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.vo.CommonGuideVo;
	import game.global.vo.User;
	import game.module.fighting.scene.FightingMapScene;
	import game.module.mainScene.HomeScene;
	import game.module.mission.MissionMainView;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Tween;
	
	/**
	 * 功能引导
	 * @author ...
	 */
	public class FunctionGuideView extends BaseView 
	{
		
		private var guildAlpha:Number = 0.01;
		private var blankMaskAlpha:Number = 0.75;
		
		private var stopAll:Boolean = false;
		
		/**
		 * 背景底
		 */
		private var _guideBg:Sprite;
		/**
		 * 遮罩区域
		 */
		private var blankArea:Sprite;
		
		/**
		 * 人物对话遮罩
		 */
		private var tfMask:Sprite;
		
		private var tagetSprite:Sprite;
		
		private var fakeSprite:Sprite;
		
		private var imgHitArea:HitArea;
		
		private var _guideInfo:CommonGuideVo;
		
		private var _guideIndex:int;
		
		private var _isMaskGuide:Boolean = false;
		
		private var circleEffect:Animation;
		
		/**
		 * 响应目标坐标
		 */
		private var tp:Point;
		private var useFakeBtn:Boolean;
		
		
		
		public function FunctionGuideView() 
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
			this.m_iPositionType = LayerManager.LEFTUP;
			this.name = "FunctionGuideView";
		}
		
		override public function show(...args):void
		{
			super.show();
			//trace("打开功能引导:", args);
			User.getInstance().isInGuilding = true;
			_guideIndex = args[0];
			doGuide();
			
			XFacade.instance.closeModule(MissionMainView);
		}
		
		public function doGuide():void
		{
			_guideInfo = GameConfigManager.common_guide_vec[_guideIndex];
			trace("_guideIndex: ", _guideIndex);
			trace("_guideInfo: ", _guideInfo);
			resetState();
			guideBg.visible = true;
			_isMaskGuide = false;
			blankMaskAlpha = 0.01;
			useFakeBtn = false;
			var sx:int = 1;
			var sy:int = 1;
			var pi:Point;
			var pp:Sprite;
			
			if (_guideInfo.special)
			{
				switch(_guideInfo.special)
				{
					case "FakeBackBtn":
					case "FakeEnterBtn":
					case "FakeRaidBtn":
					case "FakeEnterBtn2":
					case "FakeEnterBtn3":
					case "FakeSoilderBtn":
					case "Fake44":
					case "Fake55":
						useFakeBtn = true;
						break;
					case "MaskNotice":
						_isMaskGuide = true;
						blankMaskAlpha = 0.75;
						break;
					default:
						break;
				}
			}
			
			
			
			switch(_guideInfo.form)
			{
				case 1:
					view.introWithMan.visible = true;
					var desStr:String = GameLanguage.getLangByKey(_guideInfo.des);
					desStr = desStr.replace(/##/g, "\n");
					view.des1.text = desStr;
					TFMotion();
					break;
				case 2:
					view.normalDes.visible = true;
					if (_guideInfo.pos && _guideInfo.pos == 2)
					{
						view.normalDes.y = LayerManager.instence.stageHeight * 0.3;
					}
					else
					{
						view.normalDes.y = LayerManager.instence.stageHeight * 0.1;
					}
					view.des2.text = GameLanguage.getLangByKey(_guideInfo.des);
					fixMiddleBg();
					break;
				case 3:
					break;
				case 4:
					view.btnTips.visible = true;
					view.des3.text = GameLanguage.getLangByKey(_guideInfo.des);
					fixTopBtnTips();
					break;
				case  5:
					view.leftBtnTips.visible = true;
					view.des4.text = GameLanguage.getLangByKey(_guideInfo.des);
					fixLeftBtnTips();
					break;
				case  6:
					view.downBtnTips.visible = true;
					view.des5.text = GameLanguage.getLangByKey(_guideInfo.des);
					fixDownBtnTips();
					break;
				case  7:
					view.rightBtnTips.visible = true;
					view.des6.text = GameLanguage.getLangByKey(_guideInfo.des);
					fixRightBtnTips();
					break
				default:
					break;
			}
			
			
			
			if (_guideInfo.targe && _guideInfo.targe != "" && !_guideInfo.buildID)
			{
				trace("tn:", _guideInfo.targe);
				
				if (_guideInfo.targe.split("|").length == 1)
				{
					tagetSprite = UIRegisteredMgr.getTargetUI(_guideInfo.targe);
				}
				else
				{
					
					if (!UIRegisteredMgr.getTargetUI(_guideInfo.targe.split("|")[0])||!UIRegisteredMgr.getTargetUI(_guideInfo.targe.split("|")[0]).displayedInStage)
					{
						stopAll = true;
						Laya.timer.once(500, this, doGuide);
						return;
					}
					
					tagetSprite = UIRegisteredMgr.getTargetUI(_guideInfo.targe.split("|")[0]).getChildAt(0).getChildAt(parseInt(_guideInfo.targe.split("|")[1]));
				}
				
				if (_guideInfo.targe.split("_")[0] == "Chapter")
				{
					tagetSprite = (XFacade.instance.getView(FightingMapScene) as FightingMapScene).getStageBtn(_guideInfo.targe.split("_")[1]);
				}
				
				if (_guideInfo.targe.split("|")[0] == "HeroList")
				{
					//tagetSprite = (tagetSprite as EquipHeroCell).getHeroBtn();
					sy = 0.3;
				}
				
				if (_guideInfo.targe == "MilitarySArea")
				{
					Signal.intance.event(GuildEvent.HIDE_MILITARYHOUSE_UNIT_LIST);
				}
				
				if (useFakeBtn)
				{
					if (fakeSprite)
					{
						view.removeChild(fakeSprite);
						fakeSprite = null;
					}
					
					fakeSprite = new Sprite();
					
					switch(_guideInfo.special)
					{
						case "FakeSoilderBtn":
							fakeSprite.width = 180;
							fakeSprite.height = 240;			
							fakeSprite.x = 133.5;
							//fakeSprite.y = 152.5;
							fakeSprite.y = LayerManager.instence.stageHeight / 2 - 167.5;
							fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
							break;
						case "FakeBackBtn":
							fakeSprite.width = 49;
							fakeSprite.height = 90;			
							fakeSprite.x = 20;
							//fakeSprite.y = 297;
							fakeSprite.y = LayerManager.instence.stageHeight*0.5-45;
							fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
							break;
						case "Fake44":
						case "Fake55":
							pi = new Point(tagetSprite.x,tagetSprite.y);
							pp = tagetSprite.parent as Sprite;
							pp.localToGlobal(pi);
							
							fakeSprite.width = 80;
							fakeSprite.height = 60;
							fakeSprite.x = pi.x;
							fakeSprite.y = pi.y;// + 10;
							fakeSprite.graphics.drawRect(0, 0, 49, 60, "#f0f0f0");
							break;
						default:
							break;
					}
					fakeSprite.alpha = 0.01;
					fakeSprite.mouseEnabled = false;
					view.addChild(fakeSprite);
					
					tp = drawBlankArea(fakeSprite, sx, sy);
				}
				else
				{
					switch(_guideInfo.targe)
					{
						case "StarBlock44":
						case "StarBlock55":
							//trace("tagetSprite:", tagetSprite.localToGlobal(new Point(tagetSprite.x,tagetSprite.y)).x, tagetSprite.localToGlobal(new Point(tagetSprite.x,tagetSprite.y)).y, tagetSprite.width, tagetSprite.height);
							break;
						default:
							break;
					}
					tp = drawBlankArea(tagetSprite,sx,sy);
				}
				
				if (!tagetSprite||!tagetSprite.displayedInStage)
				{
					stopAll = true;
					Laya.timer.once(500, this, doGuide);
					return;
				}
				
				//trace("guideTarget:", tagetSprite);
				var gp:Point = new Point();
				tagetSprite.localToGlobal(gp);
				/*trace("x:", gp.x);
				trace("y:", gp.y);
				trace("w:", tagetSprite.width);
				trace("h:", tagetSprite.height);*/
				
				tagetSprite.on(Event.CLICK, this, onClick);
				
				view.arrowMotion.x = tp.x + (tagetSprite.width * sx - view.arrowMotion.width) / 2;
				view.arrowMotion.y = tp.y - view.arrowMotion.height;
				view.arrowMotion.visible = true;
				
				trace("x:", view.arrowMotion.x, "y:", view.arrowMotion.y);
				if (_guideInfo.targe == "MilitaryCloseBtn" || 
					_guideInfo.targe == "UnitInfoClose" ||
					_guideInfo.targe == "CampCloseBtn" ||
					_guideInfo.targe == "AG_helpBtn" ||
					_guideInfo.targe == "TeamRoomBtnClose"||
					_guideInfo.targe == "pataBtn"||
					_guideInfo.targe == "$MineFightCloseBtn"||
					_guideInfo.targe == "ClosePataViewBtn"	)
				{
					view.arrowMotion.rotation = 180;
					view.arrowMotion.x = tp.x + tagetSprite.width * sx;// -50;
					view.arrowMotion.y = tp.y + tagetSprite.height * sy / 2+200;
					if(_guideInfo.targe == "pataBtn")
					{
						view.arrowMotion.x = tp.x + tagetSprite.width * sx -100;
					}
				}
			
				guideBg.visible = _isMaskGuide;
				
				view.btnTips.x = tp.x + (tagetSprite.width * sx - view.btnTips.width) / 2;
				view.btnTips.y = tp.y - view.btnTips.height;
				
				view.leftBtnTips.x = tp.x - view.leftBtnTips.width;
				view.leftBtnTips.y = tp.y + (tagetSprite.height * sx - view.leftBtnTips.height) / 2;
				
				view.downBtnTips.x =  tp.x + (tagetSprite.width * sx - view.downBtnTips.width) / 2;
				view.downBtnTips.y =  tp.y  + (tagetSprite.height * sy);// / 2 + view.downBtnTips.height;
				
				view.rightBtnTips.x = tp.x + (tagetSprite.width * sx)/2 + view.rightBtnTips.width;
				view.rightBtnTips.y = tp.y + (tagetSprite.height * sy - view.rightBtnTips.height) / 2;
				
				if(!_isMaskGuide)
				{
					showCircelAnimation(tp.x + tagetSprite.width * sx / 2, tp.y + tagetSprite.height * sy / 2);
				}
				else
				{
					view.arrowMotion.visible = false;
				}
			}
			
			if (_guideInfo.buildID)
			{
				stopAll = true;
				var bs:Sprite = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(_guideInfo.buildID);
				HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(bs);
				
				if (_guideInfo.targe)
				{
					
					Laya.timer.once(500, this, function() {
						
						
						
						tagetSprite = UIRegisteredMgr.getTargetUI(_guideInfo.targe);
						tagetSprite.on(Event.CLICK, this, onClick);
						
						fakeSprite = new Sprite();
						
						switch(_guideInfo.special)
						{
							case "FakeEnterBtn2":
								fakeSprite.width = 107;
								fakeSprite.height = 107;			
								fakeSprite.x = 588.5;
								//fakeSprite.y = 512;
								fakeSprite.y = LayerManager.instence.stageHeight-128;
								fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
								fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
								break;
							case "FakeEnterBtn3":
								fakeSprite.width = 107;
								fakeSprite.height = 107;			
								fakeSprite.x = 520;
								//fakeSprite.y = 512;
								fakeSprite.y = LayerManager.instence.stageHeight-128;
								fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
								break;
							case "FakeRaidBtn":
								fakeSprite.width = 107;
								fakeSprite.height = 107;			
								fakeSprite.x = 516;
								//fakeSprite.y = 512;
								fakeSprite.y = LayerManager.instence.stageHeight-128;
								fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
								break;
							case "FakeEnterBtn":
								fakeSprite.width = 107;
								fakeSprite.height = 107;			
								fakeSprite.x = 681;
								//fakeSprite.y = 512;
								fakeSprite.y = LayerManager.instence.stageHeight-128;
								fakeSprite.graphics.drawRect(0, 0, 49, 90, "#f0f0f0");
								break;
							case "":
								break;
							default:
								break;
						}
						fakeSprite.alpha = 0.01;
						fakeSprite.mouseEnabled = false;
						view.addChild(fakeSprite);
						
						if (useFakeBtn)
						{
							tp = drawBlankArea(fakeSprite, sx, sy);
						}
						else
						{
							tp = drawBlankArea(tagetSprite);
						}
						//---------------
						
						view.arrowMotion.x = tp.x+(tagetSprite.width-view.arrowMotion.width)/2;
						view.arrowMotion.y = tp.y-view.arrowMotion.height;
						view.arrowMotion.visible = true;
						guideBg.visible = _isMaskGuide;
						stopAll = false;
						
						view.btnTips.x = tp.x + (tagetSprite.width * sx - view.btnTips.width) / 2;
						view.btnTips.y = tp.y - view.btnTips.height;
						
						//------测试获取坐标用--------
						/*var gp:Point = new Point();
						tagetSprite.localToGlobal(gp);
						trace("guideTarget:", tagetSprite);
						trace("x:", gp.x);
						trace("y:", gp.y);
						trace("w:", tagetSprite.width);
						trace("h:", tagetSprite.height);*/
						//------------------------------
						
						if(!_isMaskGuide)
						{
							showCircelAnimation(tp.x + tagetSprite.width / 2, tp.y + tagetSprite.height / 2);
						}
						else
						{
							view.arrowMotion.visible = false;
						}
					})
				}
				else
				{
					guideBg.visible = true;
					stopAll = false;
				}
			}
		}
		
		private function fixMiddleBg():void
		{
			if (view.des2.textHeight > 30)
			{
				//trace("des2Height:", view.des2.textHeight);
				view.middleBg.height = view.des2.textHeight + 50;
			}
		}
		
		private function fixTopBtnTips():void
		{
			if (view.des3.textHeight > 50)
			{
				//trace("des3Height:", view.des3.textHeight);
				view.upBg.height = view.des3.textHeight + 102;
			}
		}
		
		private function fixLeftBtnTips():void
		{
			/*trace("des4:", view.des4.textHeight);
			trace("des4:", view.des4.textWidth);
			trace("des4:", view.des4.width);
			trace("des4:", view.des4.height);*/
			if (view.des4.textHeight > 30)
			{
				//trace("des2Height:", view.des2.textHeight);
				view.leftBg.height = view.des4.textHeight + 50;
				//view.leftArrow.y = (view.leftBtnTips.height - view.leftArrow.height) / 2;
			}
		}
		
		private function fixDownBtnTips():void
		{
			if (view.des5.textHeight > 30)
			{
				view.downBg.height = view.des5.textHeight + 50;
			}
		}
		
		private function fixRightBtnTips():void
		{
			if (view.des6.textHeight > 30)
			{
				//trace("des2Height:", view.des2.textHeight);
				view.rightBg.height = view.des6.textHeight + 50;
				//view.leftArrow.y = (view.leftBtnTips.height - view.leftArrow.height) / 2;
			}
		}
		
		private function showCircelAnimation(tx:Number,ty:Number):void
		{
			circleEffect.x = tx - 256;
			circleEffect.y = ty - 256;
			circleEffect.play(0);
			circleEffect.visible = true;
		}
		
		private function resetState():void
		{
			if(tagetSprite)
			{
				tagetSprite.off(Event.CLICK, this, onClick);
			}
			circleEffect.visible = false;
			tagetSprite = null;
			view.introWithMan.visible = false;
			view.des1.text = "";
			
			view.normalDes.visible = false;
			view.des2.text = "";
			view.des2.height = view.des2.textHeight = 30;
			view.middleBg.height = 80;
			
			view.btnTips.visible = false;
			view.des3.text = "";
			view.des3.height = view.des3.textHeight = 50;
			view.upBg.height = 152;
			
			view.leftBtnTips.visible = false;
			view.des4.text = "";
			view.des4.height = view.des4.textHeight = 30;
			view.leftBg.height = 80;
			
			view.downBtnTips.visible = false;
			view.des5.text = "";
			view.des5.height = view.des5.textHeight = 30;
			view.downBg.height = 80;
			
			view.rightBtnTips.visible = false;
			view.des6.text = "";
			view.des6.height = view.des6.textHeight = 30;
			view.rightBg.height = 80;
			
			view.arrowMotion.visible = false;
			
			guideBg.visible = false;
			
			this.blankArea.visible = false;
			stopAll = false;
		}
		
		private function onClick(e:Event=null):void
		{
			//trace("ssssttttoooopppp: ", stopAll);
			if (stopAll)
			{
				trace("stopAll! stopAll! stopAll! ");
				return;
			}
			this.hitArea = null;
			//this.mouseThrough = view.mouseThrough  = false; 
			view.arrowMotion.rotation = 0;
			
			
			User.getInstance().forbidBlankClose = false;
			if (_guideInfo.id == 707 ||
				_guideInfo.id == 716)
			{
				User.getInstance().forbidBlankClose = true;
			}
			
			trace("点击引导层:",tagetSprite);
			trace("_guideInfo.targe:"+_guideInfo.targe);
			if(_guideInfo.targe == "SweepFiveBtn")
			{
				trace("发送扫荡事件");
				Signal.intance.event("SweepFiveBtn",tagetSprite);
			}
			
			if (_guideInfo.isFinish == 1)
			{
				User.getInstance().curGuideArr.shift();
				//trace("关闭引导");
				User.getInstance().isInGuilding = false;
				User.getInstance().checkHasNextGuide();
				resetState();
				close();
				return;
			}
			_guideIndex++;
			
			guideBg.visible = true;
			stopAll = true;
			
			if(_guideInfo.delayTime && _guideInfo.delayTime>0)
			{
				Laya.timer.once(_guideInfo.delayTime, this, doGuide);
			}
			else
			{
				Laya.timer.once(500, this, doGuide);
			}
			
			//doGuide();
		}
		
		private function hideBlankArea():void
		{
			this.blankArea.visible = false;
			//this.hitArea = null;
			view.arrowMotion.visible = false;
		}
		
		private function drawBlankArea(target:*,sx:Number=1,sy:Number=1):Point
		{
			//tagetSprite = target as Sprite;
			var ts:Sprite = target as Sprite;
			var pi:Point = new Point(0, 0);
			//trace("t:", tagetSprite);
			//trace("td:", tagetSprite.displayedInStage);
			if (ts && ts.displayedInStage)
			{
				if(_guideInfo.targe == "PaTaSelBtn")
				{
					pi = new Point(ts.x-ts.width/2,ts.y-ts.height/2);
				}else
				{
					pi = new Point(ts.x,ts.y);
				}
			
				var pp:Sprite = ts.parent as Sprite;
				if(pp && pp is Sprite)
				{
					pp.localToGlobal(pi);
				}
				
				this.size(Laya.stage.width , Laya.stage.height);
				var w:Number = ts.width * ts.globalScaleX;
				var h:Number = ts.height * ts.globalScaleY;
				
				w *= sx;
				h *= sy;
				
				/*if (bdBlock)
				{
					w = 60;
					h = 80;
					pi.x -= 30;
					pi.y -= 100;
				}
				
				if (isTile)
				{
					w *= 0.40;
					h *= 0.40;
					pi.x += 55;
					pi.y += 25;
				}*/
				blankArea.size(Laya.stage.width , Laya.stage.height);
				blankArea.graphics.clear();
//				blankArea.graphics.alpha(blankMaskAlpha);
				blankArea.alpha = blankMaskAlpha;
				
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
			
			view.normalDes.x = (LayerManager.instence.stageWidth - view.normalDes.width) / 2;
			view.normalDes.y = LayerManager.instence.stageHeight*0.7;
			
			view.introWithMan.y = LayerManager.instence.stageHeight - view.introWithMan.height;
			this._guideBg.size(LayerManager.instence.stageWidth, LayerManager.instence.stageHeight);
			super.onStageResize();
		}
		
		public function TFMotion():void
		{
			stopAll = true;
			view.des1.y = -100;
			Tween.to(view.des1, { y: 0 }, 500, null, Handler.create(this, function() {
				Laya.timer.once(200, this, function() {stopAll = false;});
			}));
		}
		
		override public function close():void{
			super.close();
			
			//AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			close();
		}
		
		override public function createUI():void {
			
			this._guideBg = new Sprite();
			this._guideBg.size(99,99);
			
			this._guideBg.graphics.drawRect(0, 0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight,"#ffffff");
			this._guideBg.alpha = guildAlpha;
			this._guideBg.mouseEnabled = true;
			this.addChild(_guideBg);
			guideBg.mouseThrough = true;
			guideBg.name = "guideBg";
			
			blankArea = new Sprite();
			blankArea.mouseEnabled = false;
			this.addChild(blankArea);
			
			this._view = new GuiderViewUI();
			this.addChild(_view);
			
			circleEffect = new Animation();
			circleEffect.loadAtlas("appRes/atlas/effects/guideEffect.json");
			circleEffect.play(0);
			view.addChild(circleEffect);
			
			blankArea.mouseThrough = _view.mouseThrough = true;
			
			imgHitArea = new HitArea();
			
			tfMask = new Sprite();
			tfMask.graphics.drawRect(view.des1.x,view.des1.y, view.des1.width, view.des1.height, "#ff00ff");
			
			view.des1.parent.mask = tfMask;
			view.des2.fontSize = 24;
			view.des2.wordWrap = true;
			
			view.des3.fontSize = 24;
			view.des3.wordWrap = true;
			
			view.des4.fontSize = 24;
			view.des4.wordWrap = true;
			
			view.des5.fontSize = 24;
			view.des5.wordWrap = true;
			
			view.des6.fontSize = 24;
			view.des6.wordWrap = true;
			
			resetState();
			
			view.btnTips.visible = false;
			
			this.mouseThrough = view.mouseThrough  = true;
			
			this.onStageResize();
			
		}
		
		override public function dispose():void{
			
		}
		
		
		public function get guideBg():Sprite 
		{
			return _guideBg;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			guideBg.on(Event.CLICK, this, this.onClick);
			blankArea.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			guideBg.off(Event.CLICK, this, this.onClick);
			blankArea.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():GuiderViewUI{
			return _view;
		}
		
	}

}