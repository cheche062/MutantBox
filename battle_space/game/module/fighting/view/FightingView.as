/***
 *作者：罗维
 */
package game.module.fighting.view
{
	import MornUI.fightingView.FightingLeftTopViewUI;
	import MornUI.fightingView.FightingRightBottomViewUI;
	import MornUI.fightingView.FightingSelectUnitViewUI;
	import MornUI.fightingView.FightingTopViewUI;
	import MornUI.fightingView.KpiComUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.DataLoading;
	import game.common.EffectBar;
	import game.common.ImageButton;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.StringUtil;
	import game.global.cond.ConditionsManger;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.data.DBUnit;
	import game.global.data.bag.ItemData;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingSceneManager;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.global.vo.heroUsedVo;
	import game.module.camp.CampData;
	import game.module.camp.avatar.DBSkin;
	import game.module.camp.avatar.SkinProVo;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.cell.FightingFaceCell;
	import game.module.fighting.cell.FightingTile;
	import game.module.fighting.cell.ISelectUnitCell;
	import game.module.fighting.cell.SelectUnitCell;
	import game.module.fighting.cell.SelectUnitItemCell;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.scene.FightingScene;
	import game.module.pvp.PvpManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.ClassUtils;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class FightingView extends BaseView
	{
		public static var showRKMaxNum:Number = 0;
		public static var showAutoBtn:Boolean = true;
		
		public var leftTopView:FightingLeftTopViewUI;
		private var kpiCom:KpiComUI;
		
		public var selectUnitView:FightingSelectUnitViewUI;
		public var rightBottomView:FightingRightBottomViewUI;
		public var rightTopView1:FightingRightTopView;
		public var topView:FightingTopViewUI;
		public var timerBar:EffectBar = new EffectBar("timerBar");
		public var leftRank:Array;
		public var selectPos:String;
		public var  scence:FightingScene;
		public var dataPool:Array;
		public var dataBBAr:Array;
		public var selectUitem:BaseUnit;
		public var selectDa:Object;
		protected var _trIsMaxshow:Boolean;
		protected var _chaValue:Number;
		protected var _selectOver:Boolean;
		protected var _showType:uint;
		protected var _myunits:Object = {};
		protected var allFood:Number;
		protected var isMaxRk:Boolean;
		protected var _h:Handler;
		protected var _s:Number;
		protected var jcFood:Number = 0;
		private var _unitFood:String;
		protected var foodType:* = 5;
		protected var rigthFace:FightingFaceCell;
		protected var faceList:Array = [];
		
		public function FightingView()
		{
			super();
			m_iLayerType	= LayerManager.M_FIX;
			m_iPositionType = LayerManager.LEFTUP;
			
			this.mouseEnabled = this.mouseThrough = true;
		}
	

		public function get showType():uint
		{
			return _showType;
		}

		private function changeLeftTopShow(isMake:Boolean):void{
			_trIsMaxshow = isMake; 
			leftTopView.bgImage.width = _trIsMaxshow ? 500 : 370;
			leftTopView.cellBox.size( leftTopView.bgImage.width , leftTopView.bgImage.height);
			leftTopView.upBtn.visible = !_trIsMaxshow;
			leftTopView.upBtn2.visible = _trIsMaxshow;
			leftTopView.upBtn.x = leftTopView.upBtn2.x = leftTopView.bgImage.width - 50;
			leftTopView.cellBox.x = leftTopView.bgImage.width - _chaValue;
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			leftTopView = new FightingLeftTopViewUI();
			leftTopView.boxItem.visible = false;
			
			this.addChild(leftTopView);
			leftTopView.mouseEnabled = leftTopView.mouseThrough = true;
			leftTopView.bgImage.mouseEnabled = false;
			_chaValue = leftTopView.bgImage.width;
			changeLeftTopShow(false);
			
			kpiCom = new KpiComUI();
			this.addChild(kpiCom);
			kpiCom.visible = false;
			
			
			topView = new FightingTopViewUI();
			this.addChild(topView);
			topView.addChild(timerBar);
			timerBar.barValue = 10;
			timerBar.x = 100;
			timerBar.y = 21;
			
			
			selectUnitView = new FightingSelectUnitViewUI();
			selectUnitView.mouseEnabled = selectUnitView.mouseThrough = true;
			selectUnitView.m_list.mouseEnabled = true;
			this.addChild(selectUnitView);
			selectUnitView.fightBtn['clickSound'] = ResourceManager.getSoundUrl("begin_battle","uiSound");
			
			
			rightBottomView = new FightingRightBottomViewUI();
			rightBottomView.btnContainer.mouseEnabled = rightBottomView.btnContainer.mouseThrough = true;
			rightBottomView.mouseEnabled = rightBottomView.mouseThrough = true;
			this.addChild(rightBottomView);
			
			
			rightTopView1 = new FightingRightTopView();
			
			this.addChild(rightTopView1);
//			rightTopView1.velocityBtn.visible = false;
			rightTopView1.velocityBtn.label = "x"+FightingManager.velocity ;
//			rightTopView1.x = Laya.stage.width - rightTopView1.width;
			
			
			selectUnitView.m_list.repeatX = 6;
			selectUnitView.m_list.repeatY = 1;
			selectUnitView.m_list.itemRender = SelectUnitCell;
			selectUnitView.m_list.spaceX = 10;
			selectUnitView.m_list.spaceY = 10;
			
			var ar:Array = [];
			selectUnitView.m_list.array = ar;
			
			selectUnitView.m_list.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			selectUnitView.m_list.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			selectUnitView.m_list.scrollBar.slider.min = -1;
			
			selectUnitView.m_list.scrollBar.hide = true;
//			var bts:Array = selectUnitView.unitTypeTab.items;
//			if(bts && bts.length){
//				for each (var btn:Button in bts) 
//				{
//					btn.labelFont = "BigNoodleToo";
//				}
//			}
			
			
			leftTopView.visible = selectUnitView.visible = false;
			rightBottomView.visible = false;
			rightTopView1.visible = false;
			topView.visible = false;
			
			size(Laya.stage.width ,Laya.stage.height);
		}
		
		private function autoBtnClick(e:Event):void {
//			if (!User.getInstance().hasFinishGuide)
//			{
//				return;
//			}
			auboBtnSelect = !auboBtnSelect;
			if(auboBtnSelect)
			{
				scence.autoFighting();
			}
		}
		
		
		public function get auboBtnSelect():Boolean
		{
			return rightTopView1.auboBtn.selected;
		}
		
		public function set auboBtnSelect(value:Boolean):void
		{
			rightTopView1.auboBtn.selected = value;
			
			rightTopView1.velocityBtn.visible = value && (this is PveFightingView) ;
			
			changeRightBtnYs();
			
			if(!value) FightingManager.velocity = 1;
		}
		
		private function escapeBtnClick(e:Event):void{
			
			if (!User.getInstance().hasFinishGuide && User.getInstance().guideStep < 300)
			{
				return;
			}
			
			if(e.target == rightTopView1.backBtn)
			{
				FightingManager.intance.backFun();
			}
			else
				FightingManager.intance.sendEscape();
		}
		
		private function skipBtnClick():void{
			//30166
			FightingManager.intance.skip();
			rightTopView1.skipBtn.disabled = true;
		}
		
		public override function show(...args):void{
			
			super.show();
			stageSizeChange();
			auboBtnSelect = false;
			this.selectUnitView.unitTypeTab.selectedIndex = 0;
			rightTopView1.skipBtn.disabled = false;
			this.leftTopView.boxItem.visible = (FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_SHIPWAR);
			_hurtNum = 0;
			this.leftTopView.tfNum.text = "0";
			rightBottomView.bgRange.visible = false
		}
		
		private var _hurtNum:int = 0;
		public function showItem(n:int):void{
			//ceil(\$damage/(5+\$level*2))
			_hurtNum += n;
			trace("showItem::::::::::::::::",n)
			this.leftTopView.tfNum.text = Math.ceil(_hurtNum/(5+User.getInstance().level*2))+"";
		}
		
		private function rightBtnClick(e:Event):void{
			var btn:Button = e.target as Button;
			if(btn.selected)
			{
				
				return;
			}
			switch(btn)
			{
				case rightBottomView.DefenceBtn:
				{
					if (User.getInstance().lockMove)
					{
						return;
					}
					selectRightBottomBtn(1);
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.SELECT_DEFENCE);
					}
					break;
				}
				case rightBottomView.MoveBtn:
				{
					if (User.getInstance().lockMove)
					{
						return;
					}
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.SELECT_MOVE);
					}
					selectRightBottomBtn(2);
					break;
				}
				case rightBottomView.AttackBtn:
				{
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.USE_SKILL_ONE);
					}
					selectRightBottomBtn(3);
					break;
				}
				case rightBottomView.AttackBtn1:
				{
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.USE_SKILL_TWO);
					}
					selectRightBottomBtn(4);
					break;
				}
				case rightBottomView.AttackBtn2:
				{
					selectRightBottomBtn(5);
					break;
				}
			}
		}
		
		protected function fightBtnClick(e:Event):void
		{
//			return ;
			if(_showType == SHOWTYPE_5)
			{
				FightingManager.intance.sendStart();
				return ;
			}
		
			
//			gotoSendStartBack();return ;
			
			if(!scence.mySelectUnitIds.length)
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_44855");
				return;
			} 
			var msg:String = scence.squadMsg();
			if(!isMaxRk && User.getInstance().hasFinishGuide)
			{
				// 单英雄活动战斗不提示队伍未满
				if (FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_LONEHERO ||
					FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_SHIPWAR || 
					FightingManager.intance.fightingType == FightingManager.PEOPLE_FALL_OFF)
				{
					gotoSendStart();
				}
				else
				{
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_20505",0,function(v:uint):void{
																									if(v == AlertType.RETURN_YES)
																									{
																										gotoSendStart();
																									}
																								});
				}
			}else
			{
				gotoSendStart();
				if (!User.getInstance().hasFinishGuide)
				{
					Signal.intance.event(NewerGuildeEvent.START_BATTLE);
				}
			}
		}
		
		public function gotoSendStart():void{
			trace("gotoSendStart================")
			if(foodType == DBItem.ARMY_GROUP_FOOD){//消耗军粮
				if(User.getInstance().getResNumByItem(DBItem.ARMY_GROUP_FOOD) < allFood){
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_20921",0,function(v:uint):void{
						if(v == AlertType.RETURN_YES)
						{
							gotoSendStartBack();
						}
					});
				}else{
					gotoSendStartBack();
				}
			}else{
				var itemD:ItemData = new ItemData();
				itemD.iid = foodType;
				itemD.inum = allFood;
				ConsumeHelp.Consume([itemD],Handler.create(this,gotoSendStartBack));
			}
		}
		
		public function gotoSendStartBack():void{
//			setType(4);
//			this.timer.once(1000,this,function():void{
//			selectUnitView.fightBtn.disabled = true;
			dataPool = [];
			
			if(FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_PVP)
			{
				var robotTime:int = Math.ceil(Math.random()*14+6);
				trace("robotTime========>>",robotTime)
				var time:Number = robotTime - PvpManager.curTime;
				if(PvpManager.isRobot && time > 0){
					Laya.timer.once(time * 1000,FightingManager.intance, FightingManager.intance.sendStart);
					selectUnitView.fightBtn.disabled = true;
					selectUnitView.m_list.mouseEnabled = false;
				}else{
					FightingManager.intance.sendStart()
				}
				//return sendStartPvp();
			}else{
				FightingManager.intance.sendStart()
			}
//			});
		}
		
		/**生成战斗角色*/
		public function gotoSendStartBackData(ar:Array):void{
			var type:int = this._showType;
			setType(FightingView.SHOWTYPE_4,true);
			this._showType = type;
			dataBBAr = ar;
			if(dataPool)
				this.timer.once(1000,this,gotoSendStartBackDataTimer);
			else
				gotoSendStartBackDataTimer();
		}
		
		private function gotoSendStartBackDataTimer():void
		{
			FightingManager.intance.playF(dataBBAr.concat());
			dataBBAr = null;
			var copyPool:Array = dataPool;
			dataPool = null;
			
			//给场面上所有物体生成唯一ID
			scence.generateKey();
			
			
			if(copyPool)
			{
				for (var i:int = 0; i < copyPool.length; i++) 
				{
					var ar:Array = copyPool[i];
					/*var f:Function = */FightingManager.intance.fightingDataBack.apply(FightingManager.intance,ar);
				}
			}
			
			
			this.rightTopView1.auboBtn.visible = showAutoBtn;
			this.rightTopView1.escapeBtn.visible = User.getInstance().hasFinishGuide;
			this.rightTopView1.skipBtn.visible = (_showType == SHOWTYPE_9 && User.getInstance().level > 4);
			if(_showType == SHOWTYPE_13)
			{
				this.rightTopView1.skipBtn.visible = true;
			}
			changeRightBtnYs();
		} 
		
		public function selectUnitViewRefresh():void{
			bindSelectUnitViewData();
		}
		
		private function listDown(e:Event , index:int):void
		{
			var cell:ISelectUnitCell = selectUnitView.m_list.getCell(index);
			if(cell && cell.data.num)
			{
				trace("listDown");
				if(!cell.getEnabled())return ;
				if(cell.data)
				{
					var uData:fightUnitData = new fightUnitData();
					uData.unitId = cell.data.unitId;
					uData.maxHp = cell.data.maxHp;
					uData.hp = cell.data.hp;
					uData.wyid = cell.data.wyid;
					uData.direction = uData.unitVo.isBadItem ? 2:1;
					
					//绑定皮肤
					var heroVo:Object = CampData.getUintById(uData.unitId);
					if(heroVo){
						uData.skin = heroVo.skin;
					}
					selectUitem = new BaseUnit();
					selectUitem.data = uData;
					selectUitem.playAction(BaseUnit.ACTION_HOLDING);
					scence.unitLayer.addChild(selectUitem);
					scence.unitLayer.mouseEnabled = false;
					selectUitem.x =  e.stageX - scence.m_sprMap.x - FightingScene.tileW / 2;
					selectUitem.y =  e.stageY - scence.m_sprMap.y - FightingScene.tileH / 2;
					selectDa = cell.data;
					
					Laya.stage.on(Event.MOUSE_MOVE,this,stageMove);
					Laya.stage.on(Event.MOUSE_UP,this,stageUp);
					
					selectUnitView.on(Event.MOUSE_OVER,this,mouseOverOfOut);
					selectUnitView.on(Event.MOUSE_OUT,this,mouseOverOfOut);
					mouseOverOfOut(null);
					selectUitem.visible = false;
				}
			}
		}
		
		private function mouseOverOfOut(e:Event = null):void
		{
			_selectOver = e == null || e.type == Event.MOUSE_OVER;
		}
		
		private function stageMove(e:Event):void
		{		
			selectUitem.visible = !_selectOver;
			
			var pii:Point = new Point(e.stageX,e.stageY);
			pii = scence.unitLayer.globalToLocal(pii);
			pii.x -= FightingScene.tileW / 2;
			pii.y -= FightingScene.tileH / 2;
			
//			selectUitem.x =  (e.stageX - scence.m_sprMap.x )/scence.mapScaleX - FightingScene.tileW / 2;
//			selectUitem.y =  (e.stageY - scence.m_sprMap.y )/scence.mapScaleY - FightingScene.tileH / 2;
			selectUitem.x = pii.x;
			selectUitem.y = pii.y;
			
			if(e.target is FightingTile)
			{
				scence.changeTileType( e.target as FightingTile , selectUitem.data)
			}else
			{
				scence.changeTileType();
			}
		}
		
		private function stageUp(e:Event):void
		{
			Laya.stage.off(Event.MOUSE_MOVE,this,stageMove);
			Laya.stage.off(Event.MOUSE_UP,this,stageUp);
			selectUnitView.off(Event.MOUSE_OVER,this,mouseOverOfOut);
			selectUnitView.off(Event.MOUSE_OUT,this,mouseOverOfOut);
			if(e.target is FightingTile)
			{
				var t:FightingTile = e.target as FightingTile;
//				if(t.cellType == FightingTile.CELLTYPE5)
				if(scence.isDownByUnitData(selectUitem.data,t.key))
				{
					var unData:fightUnitData = selectUitem.data;
					var f:Function = function():void{
						if(scence.addUnit(unData,true,t.key,true))
						{
							bindSelectUnitViewData();
						}
					};
					var f2:Function = function(tit:FightingTile):void{
						tit.cellType = FightingTile.CELLTYPE1;
					} 
					FightingManager.intance.unitOperation(1,unData.unitId,t.key,"",unData.wyid,Handler.create(this,f),Handler.create(this,f2,[t]));
					
				}else
				{
					t.cellType = FightingTile.CELLTYPE1;
				}
			}
			
			
			if(selectUitem)
			{
				if(selectUitem.parent)
					selectUitem.parent.removeChild(selectUitem);
				selectUitem.destroy();
				selectUitem = null;
			}
			selectDa = null;
			scence.unitLayer.mouseEnabled = true;
			
//			scence.jianche();
		}
		
		private function listClick(index:int):void
		{
			var cell:ISelectUnitCell = selectUnitView.m_list.getCell(index);
			if(cell && cell.data.num)
			{
				
				if(!cell.getEnabled(true)) return ;
				var uData:fightUnitData = new fightUnitData();
				uData.unitId = cell.data.unitId;
				uData.maxHp = cell.data.maxHp;
				uData.hp = cell.data.hp;
				uData.direction = uData.unitVo.isBadItem ? 2:1;
				uData.wyid = cell.data.wyid;
				var pstr:String  = FightingSceneManager.intance.getNewUnitPoint(uData,scence.tileMapData);
				//绑定皮肤
				var heroVo:Object = CampData.getUintById(uData.unitId);
				if(heroVo){
					uData.skin = heroVo.skin;
				}
				
				if(!pstr)
				{
					XTip.showTip("L_A_71014");
					return ;
				}
				
				if(cell.data)
				{
					var f:Function = function():void{
						var bu:BaseUnit = scence.addUnit(uData,true,pstr,true);
						if(bu)
						{
							bindSelectUnitViewData();
							
							scence.changeTileType( scence.tileList[pstr] , bu.data ,true);
							
							if(!User.getInstance().hasFinishGuide)  //玩家点击上阵成功
								Signal.intance.event(NewerGuildeEvent.CREATE_SOILDER);
						}
					};
					
					FightingManager.intance.unitOperation(1,cell.data.unitId,pstr,"",cell.data.wyid,Handler.create(this,f));
				}
			}
		}
		
		public static const SHOWTYPE_2:Number = 2;  //战报播放
		public static const SHOWTYPE_3:Number = 3;  //战斗过程中选人
		public static const SHOWTYPE_5:Number = 5;  //选人 - 预先布阵
		public static const SHOWTYPE_7:Number = 7;  //选人 - pvp
		public static const SHOWTYPE_4:Number = 4;  //手动战斗
		public static const SHOWTYPE_6:Number = 6;  //模拟战斗
		public static const SHOWTYPE_8:Number = 8;	//公会战
		public static const SHOWTYPE_9:Number = 9;	//雷达战
		public static const SHOWTYPE_10:int = 10;//堡垒战斗
		public static const SHOWTYPE_11:int = 11;//随机条件
		public static const SHOWTYPE_12:int = 12;//人数衰减
		public static const SHOWTYPE_13:int = 13;//爬塔
		public function setType(type:uint , isMove:Boolean = false):void
		{
			if(_showType != type)
			{
				leftTopView.visible  = false;
				kpiCom.visible = true;
				rightBottomView.visible = false;
				rightTopView1.visible = false;
				topView.visible = false;
				timerBar.visible = false;
				rightTopView1.escapeBtn.visible = rightTopView1.auboBtn.visible = rightTopView1.backBtn.visible = false
				rightTopView1.velocityBtn.visible = rightTopView1.skipBtn.visible = false;
				if(isMove && _showType != SHOWTYPE_6)
				{
					selectUnitView.mouseEnabled = false;
					selectUnitView.visible = true
					Tween.to(selectUnitView,{y:selectUnitView.y+210},1000,null, Handler.create(this, onActCom))
				}else{
					selectUnitView.visible = false
				}
				_showType = type;
				
				
				rightTopView1.backBtn.label = "L_A_49016";
				rightTopView1.backBtn.getChildByName("iconImg").skin = "fightingUI/icon_escape.png";
				
				switch(_showType)
				{
					case SHOWTYPE_2:   //战报播放
					{
						leftTopView.visible = true;
						kpiCom.visible = false;
						topView.visible = true;
						timerBar.visible = false;
						rightTopView1.visible = true;
						rightTopView1.backBtn.visible = true;
						// 暂时伪装一下皮肤
						rightTopView1.backBtn.label = "L_A_117";
						rightTopView1.backBtn.getChildByName("iconImg").skin = "fightingUI/icon_end.png";
						scence.mapScale1 = 1;
						break;
					}
					case SHOWTYPE_3: //选人
					case SHOWTYPE_5: //选人 - 预先布阵
					case SHOWTYPE_7: //选人 - pvp
					case SHOWTYPE_8:
					case SHOWTYPE_10:
					case SHOWTYPE_9:
					case SHOWTYPE_11:
					case SHOWTYPE_12:
					case SHOWTYPE_13:
					{
						selectUnitView.visible = true;
						rightTopView1.visible = true;
						rightTopView1.backBtn.visible = true;
						bindSelectUnitViewData();
						
//						scence.mapScale1 = 0.75;
						scence.mapScale1 = 0.8;
						
						//selectUnitView.fBox.visible = 	_showType == SHOWTYPE_3 || _showType == SHOWTYPE_7 || _showType == SHOWTYPE_8;
						selectUnitView.fBox.visible = 	_showType != SHOWTYPE_5
						selectUnitView.fightBtn.disabled = false;
						if(_showType == SHOWTYPE_3 || _showType == SHOWTYPE_9)
							selectUnitView.fightBtn.label = "L_A_2569";
						else if(_showType == SHOWTYPE_5 || _showType == SHOWTYPE_8)
							selectUnitView.fightBtn.label = "L_A_48047";
						else if(_showType == SHOWTYPE_7)
							selectUnitView.fightBtn.label = "L_A_70067";
//						else if(_showType == SHOWTYPE_13)
//							rightTopView1.skipBtn.visible = true;
						break;
					}
					case SHOWTYPE_4: //手动战斗
					case SHOWTYPE_6: //模拟战斗
					{
						leftTopView.visible = true;
						kpiCom.visible = false;
//						rightBottomView.visible = true;
//						rightBottomView.mouseEnabled = false;
						rightTopView1.visible = _showType != SHOWTYPE_6;
//						rightTopView1.velocityBtn.visible = true;
//						rightTopView1.escapeBtn.visible = rightTopView1.auboBtn.visible = true;
						topView.visible = true;
						timerBar.visible = true;
//						Tween.(scence,{mapScale:1},200);
						Tween.to(scence,{mapScale1:1},1000);
						break;
					}
					default:
					{
						break;
					}
				}
				changeRightBtnYs();
			}
		}
		
		private function onActCom():void{
			selectUnitView.visible = false;
			selectUnitView.mouseEnabled = true;
			selectUnitView.y = Laya.stage.height - selectUnitView.height;
		}
		
		
		private function changeRightBtnYs():void
		{
			var btns:Array = [
				rightTopView1.escapeBtn,
				rightTopView1.skipBtn,
				rightTopView1.backBtn,
				rightTopView1.auboBtn,
				rightTopView1.velocityBtn
			];
			var yy:Number = 10;  //起点
			var jg:Number = 100; //间隔
			for (var i:int = 0; i < btns.length; i++) 
			{
				var btn:Button = btns[i];
				if(btn.visible)
				{
					btn.y = yy;
					yy += jg;
				}
			}
			
		}
		
		private function getSkillCd(skillId:Number , obj:Object):Number{
			if(!skillId || !obj)
				return 0;
			var cds:Array = obj.skillCD;
			if(!cds)
				return 0;
			for (var i:int = 0; i < cds.length; i++) 
			{
				var o:Object = cds[i];
				if(o.sId == skillId)
					return o.cd[0];
			}
			return 0;
			
		}
		
		public function refreshAtk():void
		{
			if(scence && scence.useFightingUnit)
			{
				trace("绑定兵种:",scence.useFightingUnit.data);
				rightBottomView.AttackBox1.visible = scence.useFightingUnit.data.skillVos.length > 1;
				rightBottomView.AttackBox2.visible = scence.useFightingUnit.data.skillVos.length > 2;
				var obj:Object = leftRank[0];
				var cdN:Number;
				var skill:SkillVo;
				
				/*if(scence.useFightingUnit.data.skillVos.length > 2){
					scence.useFightingUnit.data.skillVos = scence.useFightingUnit.data.skillVos.reverse();
				}*/
				
				if(scence.useFightingUnit.data.skillVos.length > 0)
				{
					skill = scence.useFightingUnit.data.skillVos[0];
					if(skill)
					{
						rightBottomView.skillIMG.graphics.clear();
						rightBottomView.skillIMG.loadImage(skill.iconUrl);
						cdN = getSkillCd(skill.skill_id,obj);
						trace("skill1:::",skill.iconUrl)
						rightBottomView.AttackBtn.disabled = cdN;
						rightBottomView.cdLbl.text = cdN ? cdN.toString() : "";
					}
				}
				if(scence.useFightingUnit.data.skillVos.length > 1)
				{
					skill = scence.useFightingUnit.data.skillVos[1];
					if(skill)
					{
						rightBottomView.skillIMG1.graphics.clear();
						rightBottomView.skillIMG1.loadImage(skill.iconUrl);
						cdN = getSkillCd(skill.skill_id,obj);
						trace("skill2:::",skill.iconUrl)
						rightBottomView.AttackBtn1.disabled = cdN;
						rightBottomView.cdLbl1.text = cdN ? cdN.toString() : "";
					}
					
					//皮肤
					/*var heroVo:Object = CampData.getUintById(scence.useFightingUnit.data.unitId);
					if(heroVo && heroVo.skin){
						var skinLv:int = heroVo.skins[heroVo.skin][0]
						var skinVo:SkinProVo = DBSkin.getSkin(heroVo.skin);
						var skinPro:SkinProVo = DBSkin.getSkinPro(skinLv, skinVo.node);
						if(skinPro && skinPro.skill){
							var skillId:String = skinPro.skill.split("=")[1]
							skill = GameConfigManager.unit_skill_dic[skillId];
							trace("skill::",skinPro.skill,skill)
							//scence.useFightingUnit.data.skillVos[2] = skill;
							if(skill){
								rightBottomView.AttackBox2.visible = true;
								rightBottomView.skillIMG2.graphics.clear();
								rightBottomView.skillIMG2.loadImage(skill.iconUrl);
								cdN = getSkillCd(skill.skill_id,obj);
								trace("skill3:::",skill.iconUrl)
								rightBottomView.AttackBtn2.disabled = cdN;
								rightBottomView.cdLbl2.text = cdN ? cdN.toString() : "";
							}
						}
					}*/
				}
				if(scence.useFightingUnit.data.skillVos.length > 2)
				{
					skill = scence.useFightingUnit.data.skillVos[2];
					if(skill)
					{
						rightBottomView.skillIMG2.graphics.clear();
						rightBottomView.skillIMG2.loadImage(skill.iconUrl);
						trace("skill3:::",skill.iconUrl)
						cdN = getSkillCd(skill.skill_id,obj);
						rightBottomView.AttackBtn2.disabled = cdN;
						rightBottomView.cdLbl2.text = cdN ? cdN.toString() : "";
					}
				}
				
				if(scence.useFightingUnit.silence)
				{
					rightBottomView.AttackBtn.disabled = true;
					rightBottomView.AttackBtn1.disabled = true;
					rightBottomView.AttackBtn2.disabled = true;
				}
				
				rightBottomView.MoveBtn.disabled = scence.useFightingUnit.imprisoned;
				
			}
		}
		
		public function selectRightBottomBtn(v:uint):void{
			
			if(!v)
			{
				if(!rightBottomView.AttackBtn.disabled)
					v = 3;
				else if(!rightBottomView.AttackBtn1.disabled && rightBottomView.AttackBox1.visible)
					v = 4;
				else if(!rightBottomView.AttackBtn2.disabled && rightBottomView.AttackBox2.visible)
					v = 5;
				else if(!rightBottomView.MoveBtn.disabled)
					v = 2;
				else
					v = 1;
			}
			
			
			rightBottomView.DefenceBtn.selected = v == 1;
			rightBottomView.MoveBtn.selected = v == 2;
			rightBottomView.AttackBtn.selected = v == 3;
			rightBottomView.AttackBtn1.selected = v == 4;
			rightBottomView.AttackBtn2.selected = v == 5;
			
			if(v >= 3)
			{
				var xx:Number = v - 3;
				scence.useFightingUnit.data.selectSkill = scence.useFightingUnit.data.skillVos[xx];
				v = 3;
			}
			
			scence.useType(v);
		}
		
		/**绑定选择*/
		public function bindSelectUnitViewData():void
		{
			if(_showType != SHOWTYPE_3 && 
				_showType != SHOWTYPE_5 && 
				_showType != SHOWTYPE_7 && 
				_showType != SHOWTYPE_8 && 
				_showType != SHOWTYPE_9 && 
				_showType != SHOWTYPE_10 && 
				_showType != SHOWTYPE_11 && 
				_showType != SHOWTYPE_12 &&
				_showType != SHOWTYPE_13){
				return;
			}
			var types:Array = [];
			var sIdx:uint = selectUnitView.unitTypeTab.selectedIndex;
			if(_myunits[sIdx] == null)
			{
				switch(selectUnitView.unitTypeTab.selectedIndex)// 选中英雄
				{
					case 0:
					{
						_myunits[sIdx] = FightingManager.intance.heroList;
						break;
					}
					case 1:
					{ 
						_myunits[sIdx] = FightingManager.intance.soldierList;
						break;
					}
					case 2:
					{
						_myunits[sIdx] = FightingManager.intance.itemList;
						break;
					}
				}
			}
			var maxRK:Number = 0 ; //人口容量
			var shengRk:Number = 0; //人口剩余
			var thisRK:Number = 0;  //当前人口
			var blvo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_BASE,User.getInstance().sceneInfo.getBaseLv());
			if(blvo)
			{
				maxRK = shengRk = blvo.buldng_capacty;
			}
			if(showRKMaxNum)
			{
				maxRK = shengRk = showRKMaxNum;
			}
			
			selectUnitView.hlNumLbl.visible = true;
			//单英雄战斗 不显示上阵剩余数量
			if (FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_LONEHERO)
			{
				selectUnitView.hlNumLbl.visible = false;
			}
			
//			showRKMaxNum = 0;
			var unitFood:Number = 0;  //士兵粮耗
			var evalStr1:String = "";  //英雄粮耗公式
			var evalStr2:String = "";  //兵种粮耗公式
			var parameterJson:* = ResourceManager.instance.getResByURL("config/unit_parameter.json");
			if(parameterJson)
			{
				var key:String = "s_food_a_"+foodType;
				//evalStr1 = parameterJson["s_food_a"]["value"];
				//evalStr2 = parameterJson["s_food_a"]["value"];
				
				evalStr1 = parameterJson[key]["value"];
				evalStr2 = parameterJson[key]["value"];
			}else
			{
				trace("config/unit_parameter.json未载入");
			}
			
			var kpi:int = 0;
			trace("绑定选择:"+scence.mySelectUnitIds);
			for (var z:int = 0; z < scence.mySelectUnitIds.length; z++) 
			{
				var ssss:String  =scence.mySelectUnitIds[z];
				var unitVo:FightUnitVo = GameConfigManager.unit_dic[ssss.split("*")[0]];
				if(unitVo.unit_type != 1 && unitVo.unit_type != 2){
					
					continue;
				}
//				trace("unit_type:"+unitVo.unit_type);
//				if(_showType == SHOWTYPE_12&&unitVo.unit_type == 1)//针对新的
//				{
//					thisRK += 1;
//				}
				thisRK += unitVo.population;
				
				var uLel:Object = CampData.getUintById(unitVo.unit_id);
				kpi += uLel.power;
				var es1:String;
				if(unitVo.isHero)
				{
					es1 = evalStr1.replace("\\$param1",uLel.power);
				}else if(unitVo.isSoldier){
					es1 = evalStr2.replace("\\$param1",uLel.power);
					es1 = es1.replace("\\$param2",unitVo.population);
				}
				if(es1)
					unitFood += __JS__("eval(es1)");
			}
//			trace("绑定数量:"+thisRK);
			shengRk = maxRK - thisRK;
			isMaxRk = !shengRk;
			kpiCom.hKpiLB.text = kpi+"";
			
			var ar:Array = _myunits[sIdx];
			var ar2:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
				var obj:ArmyData = ar[i];
				obj.num = obj.maxNum;
				var adNum:Number = 0;
				for (var j:int = 0; j < scence.mySelectUnitIds.length; j++) 
				{
					if(scence.mySelectUnitIds[j] == (obj.unitId + "*" +obj.wyid))
					{
						obj.num -- ;
						adNum ++;
					}
				}
				obj.lcState = obj.unitVo.population <= shengRk ? 0 : 1;
				obj.state2 = 0;
				if(!obj.num)
				{
					obj.state2 = ArmyData.STATE_NOT_NUMBER; 
				}else if(obj.limit > 0 && obj.limit <= adNum)
				{
					obj.state2 = ArmyData.STATE_NOT_ADD;
				}
				if(obj.num > 0 || !obj.unitVo.isItem)
					ar2.push(obj);
			}
			selectUnitView.m_list.itemRender = sIdx == 2 ? SelectUnitItemCell : SelectUnitCell;
			selectUnitView.m_list.array  = ar2.sort(ArmyData.armySort);
			selectUnitView.m_list.refresh();
			selectUnitView.hlNumLbl.text = ":"+thisRK+"/"+maxRK;
			if(_unitFood == "0"){
				unitFood = 0;
			}
			allFood = Number(unitFood) + Number(jcFood);
			selectUnitView.needFoodLbl.text = allFood.toString();
			
			/**/
			var sourceNum:Number = User.getInstance().getResNumByItem(foodType)
			//selectUnitView.needFoodLbl.color = User.getInstance().food < allFood ? "#ff0000" : "#fffffe";
			selectUnitView.needFoodLbl.color = sourceNum < allFood ? "#ff0000" : "#fffffe";
			
			//限制上阵
			checkLimit();
		}
		
		private function checkLimit():void{
			var info:Object = {};
			for (var i:int = 0; i < scence.mySelectUnitIds.length; i++) 
			{
				var unitStr:String = scence.mySelectUnitIds[i];
				var unitId:* = unitStr.split("*")[0]
				var unitVo:FightUnitVo = GameConfigManager.unit_dic[unitId];
				if(!info[unitId]){
					info[unitId] = 1;
				}else{
					info[unitId] = parseInt(info[unitId]) + 1;
				}
			}
			for(var j:String in info){
				unitId = j;
				var unitVo:FightUnitVo = GameConfigManager.unit_dic[unitId];
				if(info[j] >= unitVo.num_limit){
					//上阵限制了
					var arr:Array = selectUnitView.m_list.array;
					for(i=0; i<arr.length; i++){
						if(arr[i].unitId == unitId){
							var db:* = DBUnit.getUnitInfo(unitId);
							if(db.unit_type == DBUnit.TYPE_HERO){
								arr[i].state2 = ArmyData.STATE_NOT_NUMBER
							}else{
								arr[i].state2 = ArmyData.STATE_NOT_ADD
							}
							break;
						}
					}
					selectUnitView.m_list.array = arr.sort(ArmyData.armySort);
					selectUnitView.m_list.refresh();
				}
			}
		}
		
		public function get autoFighting():Boolean{
			 return auboBtnSelect;
		}
		
		public function set turn(v:*):void
		{
			var vn:Number = Number(v);
			if(!vn)vn = 1;
			var s:String = GameLanguage.getLangByKey("L_A_59002");
			topView.turnText.text = StringUtil.substitute(s,vn);
		}
		
		public function countdown(v:*,h:Handler):void
		{
			_s = v;
			_h = h;
			timerBar.barValue = _s; 
			this.timer.clear(this,timerChange);
			if(_s)
			{
				this.timer.once(1000,this,timerChange);
			}
		}
		
		public function timerChange():void{
			if(!_s)
			{
				if(_h != null)
					_h.run();
				return ;
			}
			_s-- ;
			timerBar.barValue = _s; 
			this.timer.once(1000,this,timerChange);	
		}
		
		public function stopTimerChange():void{
			this.timer.clear(this,timerChange);
		}
		
		private function leftBtnClick(e:Event):void
		{
			switch(e.target)
			{
				case leftTopView.upBtn:
				{
					changeLeftTopShow(true);
					break;
				}
				case leftTopView.upBtn2:
				{
					changeLeftTopShow();
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function showTip():void{
			XFacade.instance.openModule("CampTip");
		}
		
		
		
		private function listMouseHandler(e:Event,index:int):void{
			//trace(e.type);
			switch(e.type)
			{
				case Event.CLICK:
				{
					listClick(index);
					break;
				}
				case Event.MOUSE_DOWN:
				{
					listDown(e,index);
					break;
				}
			}
		}
		
		public override function addEvent():void
		{
			super.addEvent();
			leftTopView.upBtn.on(Event.CLICK,this,leftBtnClick);
			
			leftTopView.upBtn2.on(Event.CLICK,this,leftBtnClick);
			leftTopView.btnInfo.on(Event.CLICK,this,showTip);
			kpiCom.btnInfo.on(Event.CLICK,this,showTip);
			
			rightBottomView.DefenceBtn.on(Event.CLICK,this,rightBtnClick);
			rightBottomView.MoveBtn.on(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn.on(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn1.on(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn2.on(Event.CLICK,this,rightBtnClick);
			rightTopView1.auboBtn.on(Event.CLICK,this,autoBtnClick);
			rightTopView1.escapeBtn.on(Event.CLICK,this,escapeBtnClick);
			rightTopView1.backBtn.on(Event.CLICK,this,escapeBtnClick);
			rightTopView1.velocityBtn.on(Event.CLICK,this,velocityBtnClick);
			rightTopView1.skipBtn.on(Event.CLICK,this,skipBtnClick);
			selectUnitView.m_list.mouseHandler = Handler.create(this,listMouseHandler,null,false);
			//			selectUnitView.m_list.on(Event.MOUSE_DOWN,this,listDown);
			//			selectUnitView.m_list.on(Event.CLICK,this,listClick);
			selectUnitView.fightBtn.on(Event.CLICK,this,fightBtnClick);
			selectUnitView.unitTypeTab.on(Event.CHANGE,this,bindSelectUnitViewData);
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			
		}
		
		public override function removeEvent():void
		{
			super.removeEvent();
			
			leftTopView.upBtn.off(Event.CLICK,this,leftBtnClick);
			leftTopView.upBtn2.off(Event.CLICK,this,leftBtnClick);
			
			leftTopView.btnInfo.off(Event.CLICK,this,showTip);
			kpiCom.btnInfo.off(Event.CLICK,this,showTip);
			
			rightBottomView.DefenceBtn.off(Event.CLICK,this,rightBtnClick);
			rightBottomView.MoveBtn.off(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn.off(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn1.off(Event.CLICK,this,rightBtnClick);
			rightBottomView.AttackBtn2.off(Event.CLICK,this,rightBtnClick);
			rightTopView1.skipBtn.off(Event.CLICK,this,skipBtnClick);
			rightTopView1.auboBtn.off(Event.CLICK,this,autoBtnClick);
			rightTopView1.escapeBtn.off(Event.CLICK,this,escapeBtnClick);
			rightTopView1.backBtn.off(Event.CLICK,this,escapeBtnClick);
			rightTopView1.velocityBtn.off(Event.CLICK,this,velocityBtnClick);
//			selectUnitView.m_list.off(Event.MOUSE_DOWN,this,listDown);
//			selectUnitView.m_list.off(Event.CLICK,this,listClick);
			var h:Handler = selectUnitView.m_list.mouseHandler;
			if(h)
			{
				trace("list mouseHandler not null");
				h.recover();
			}
			selectUnitView.m_list.mouseHandler = null;
			selectUnitView.fightBtn.off(Event.CLICK,this,fightBtnClick);
			selectUnitView.unitTypeTab.off(Event.CHANGE,this,bindSelectUnitViewData);
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
		}
		
		private function velocityBtnClick(e:Event = null):void
		{
			var velocity:Number =FightingManager.cacheVelocity ? FightingManager.cacheVelocity:FightingManager.velocity;
			velocity = velocity == 1 ? 2:1;
			FightingManager.velocity  = velocity;
			rightTopView1.velocityBtn.label = "x"+velocity;
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			if(GameSetting.isIPhoneX){
				selectUnitView.width = Laya.stage.width;
				selectUnitView.bgBar.width = Laya.stage.width;
				selectUnitView.rightBox.x = (Laya.stage.width-selectUnitView.rightBox.width - 20);
				selectUnitView.m_list.width = Laya.stage.width
			}
			
			topView.x = Laya.stage.width - topView.width >> 1;
			selectUnitView.y = Laya.stage.height - selectUnitView.height;
			selectUnitView.x = Laya.stage.width - selectUnitView.width >> 1;
			rightBottomView.y = Laya.stage.height - rightBottomView.height;
			rightBottomView.x = Laya.stage.width - rightBottomView.width;
			rightTopView1.x = Laya.stage.width - rightTopView1.width;
		}
		
		override public function close():void{
			super.close();
			this.scence = null;
			this._myunits = {};
			this.timerBar.barValue = 10;
			selectUnitView.fightBtn.disabled = false;
			if(rigthFace)
			{
				rigthFace.removeSelf();
				rigthFace.destroy();
				rigthFace = null;
			}
			if(faceList && faceList.length)
			{
				for (var i:int = faceList.length - 1; i >= 0; i--) 
				{
					var ff:FightingFaceCell = faceList[i];
					ff.removeSelf();
					ff.destroy();
					faceList.pop();
				}
				
			}
			this.selectPos = null;
			
			FightingManager.velocity = 1;
			
			XFacade.instance.disposeView(this);
		}
		
		public function bindNeedFood(type:*,nfn:Number,unitFood:String):void
		{
//			selectUnitView.needFoodLbl.text = String(nfn);
			jcFood = nfn;
			_unitFood = unitFood;
			
			if(type && type != "undefined"){
				foodType = type
			}
			var data:Object = DBItem.getItemData(foodType);
			if(data){
				selectUnitView.foodIcon.skin = "common/icons/"+data.icon+".png";
//				trace("data.icon:"+data.icon);
			}
		}
		
		public function bindOtherKpi(kpi:int):void{
			kpiCom.aKpiLb.text = Math.round(kpi)+"";
		}
		
		public function rankData(v:Array , move:Boolean = false,handler:Handler = null):void
		{
			trace("rankData=====",v)
			if(!v)
			{
			   trace("行动队列为空");
			}
			leftRank = v;
			
			var isCZ:Boolean;
			for (var i2:int = 0; i2 < v.length; i2++) 
			{
				if(v[i2].pos == selectPos)
				{
					isCZ = true;
					break;
				}
			}
			if(!isCZ)
				selectPos = null;
			
//			move = false;
			if(move)
			{
				Tween.to(rigthFace,{x:-500},300,null,Handler.create(this,rankData,[v,false,handler]));
				for (var k:int = 0; k < faceList.length; k++) 
				{
					var face:FightingFaceCell = faceList[k];
					if(k == 0)
						Tween.to(face,{x:rigthFace.x},200);
					else
						Tween.to(face,{x:faceList[k-1].x},200);
				}
				
				return ;
			}
			
			for (var j:int = 0; j < faceList.length; j++) 
			{
				(faceList[j] as FightingFaceCell).visible = false;
			}
			
			for (var i:int = 0; i < v.length; i++) 
			{
				if(i == 0)
				{
					rigthFace ||= new FightingFaceCell();
					rigthFace.facetype = 1;
					rigthFace.scaleX = rigthFace.scaleY = .75;
					rigthFace.scene = scence;
					leftTopView.cellBox.addChild(rigthFace);
					rigthFace.data = v[i];
					rigthFace.x = _chaValue - rigthFace.width - 30;
					rigthFace.y = 4;
				}else
				{
					var f:FightingFaceCell;
					if( faceList.length > i - 1 )
					{
						f = faceList[i - 1];
					}else
					{
						faceList[i - 1] = f = new FightingFaceCell();
						f.scaleX = f.scaleY = .7;
						f.scene = scence;
						leftTopView.cellBox.addChild(f);
					}
					f.visible = true;
					f.x = rigthFace.x - 51 - (i - 1) * 52;
					f.y = 5;					
//					f.x = 400;
					f.data = v[i]
				}
			}
			
			if(handler != null)
				handler.run();
		}
	
		public override function destroy(destroyChild:Boolean=true):void{
			
			leftTopView = null;
			selectUnitView = null;
			rightBottomView = null;
			rightTopView1 = null;
			topView = null;
			timerBar.destroy();
			leftRank = null;
			selectPos = null;
			scence = null;
			dataPool = null;
			dataBBAr = null;
			selectUitem = null;
			selectDa = null;
			_chaValue = null;
			_myunits = null;
			_h = null;
			rigthFace = null;
			faceList = null;
			
			super.destroy(destroyChild);
			
			//trace(1,"FightingView ~~~~  destroy");
		}
	}
}