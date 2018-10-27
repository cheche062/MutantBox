package game.module.mainui
{
	import MornUI.homeScenceView.homeMenuViewUI;
	
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.SoundMgr;
	import game.common.ToolFunc;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingCD;
	import game.global.data.DBBuildingUpgrade;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.PreloadUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.global.vo.reVo;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainScene.ArticleData;
	import game.module.mainui.infoViews.InfoViewFactory;
	import game.module.mainui.upgradeViews.UpViewFactory;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	
	/**
	 * MainMenuView
	 * author:huhaiming
	 * MainMenuView.as 2017-3-3 下午3:16:13
	 * version 1.0
	 *
	 */
	public class MainMenuView extends BaseDialog
	{
		/**常量-菜单类型-建筑*/
		public static const MENU_BUILD:int = 0;
		/**常理-菜单类型-升级*/
		public static const MENU_LVUP:int = 1;
		/**常量-菜单类型-确认*/
		public static const MENU_CONFIRM:int = 2;
		/**常量-菜单类型-加速*/
		public static const MENU_SPEED:int = 3;
		/**常量-菜单类型-怪物入侵*/
		public static const MENU_MONSTER:int = 4;
		
		/**缓存数据*/
		private var _data:Object;
		//
		private var _viewH:Number;
		private var _onStage:Boolean;
		private var _menuType:int;
		private var _allBtns:Array;
		//
		private var _redot0:Image;
		private var _redot1:Image;
		private var _redot2:Image;
		private var _redot3:Image;
		//坐标
		private var _pos:Object = { 1:[180],2:[86, 240], 3:[3, 168, 333], 4:[3, 113, 223, 333], 5:[3, 113, 223, 333, 443] };
		
		public function MainMenuView()
		{
			super();
			this._m_iLayerType = LayerManager.M_POP;
			this._m_iPositionType = LayerManager.LEFTDOWN;
			this.name = "MainMenuView";
		}
		
		/**
		 * 显示
		 * @param align 对齐方式，常量定义在LayerManager
		 */
		override public function show(...args):void{
			super.show();
			this.canBuild = true;
			this._data = args[0];
			
			trace("显示下方列表数据:", args);
			showMenu(this._data[0]);
			onStageResize();
			/**
			 * 根据新手引导是否完成来决定建筑物列表时候可以拖动
			 */
			view.pane.hScrollBar.touchScrollEnable = User.getInstance().hasFinishGuide;
			view.pane.hScrollBar.mouseWheelEnable = User.getInstance().hasFinishGuide;
			
			//定义进入动画
			if(!_onStage){
				_onStage = true;
				var tarY:Number = this.y;
				this.y += _viewH;
				this.alpha = 0;
				Tween.to(this, {y:tarY, alpha:1}, 200);
			}
			
			//预加载第一场战斗
			PreloadUtil.preloadFirstBattle();
		}
		
		private function showMenu(menuType:int):void{
			_menuType = menuType;
			view.noBtn.disabled = false;
			unlockBtns();
			
			switch(menuType){
				case MainMenuView.MENU_BUILD:
					view.build.visible = true;
					view.lvUp.visible  = false;
					this.isModel = true;
					
					//根据建筑ID切换到不同的页签
					if(this._data[1]){
						var vo:Object = DBBuilding.getBuildingById(this._data[1]);
						if(vo){
							this.view.tab.selectedIndex = parseInt(vo.building_type) - 1
						}else if(this._data[1] < 0){//如果没有，则表示充值；
							this.view.tab.selectedIndex = 3;
						}
					}
					
					initBuildView();
					if(User.getInstance().hasFinishGuide)
					{
						this.closeOnBlank = true;
					}
					else
					{
						this.closeOnBlank = false;
					}
					_viewH = 456;//配合动画，人肉设定
					view.infoTF.text = "";
					//显示建筑提示。。。。
					this._redot0.visible = DBBuildingUpgrade.check(DBBuilding.TYPE_FUN);
					this._redot1.visible = DBBuildingUpgrade.check(DBBuilding.TYPE_DEFEND);
					this._redot2.visible = DBBuildingUpgrade.check(DBBuilding.TYPE_FARM);
					this._redot3.visible = DBBuildingUpgrade.check(DBBuilding.TYPE_DEC);
					//派发进入事件
					Signal.intance.event(BuildEvent.BUILD_ENTER);
					break;
				case MainMenuView.MENU_LVUP:
					view.build.visible = false;
					view.lvUp.visible  = true;
					
					this.isModel = false;
					var arr:Array = [view.infoBtn]
					var bvo:Object = DBBuilding.getBuildingById(this._data[1].buildId);
					if(parseInt(bvo.level_limit)>1){
						arr.push(view.lvUpBtn);
						if(this._data[1].level < parseInt(bvo.level_limit)){
							view.lvUpBtn.gray = false;
						}else{
							view.lvUpBtn.gray = true;
						}
						
					}
					// 进入按钮皮肤
					BtnDecorate.setSkin(view.enterBtn, "buildingMenu/icon_enter.png");
					view.enterBtn.label = "L_A_25";
					if(bvo.building_type == DBBuilding.TYPE_FUN){
						if(bvo.building_id == DBBuilding.B_PROTECT){
							arr.push(view.defendBtn, view.shop1Btn, view.enterBtn);
						}else if(bvo.building_id == DBBuilding.B_HOTRL){
							arr.push(view.equipCopyBtn,view.enhanceBtn);
						}else if(bvo.building_id == DBBuilding.B_MINE){
							arr.push(view.jfBtn, view.mineBtn);
//							arr.push(/*view.growthBtn,*/view.mineBtn);
						}else if(bvo.building_id == DBBuilding.B_TRAIN){ 
//							arr.push(view.formatBtn);
							arr.push(view.enterBtn);
						}else if(bvo.building_id == DBBuilding.B_GENE){
							arr.push(view.geneCopyBtn,view.enterBtn);
						}else if(bvo.building_id == DBBuilding.B_RADIO){
							arr.push(view.radarBtn,view.techBtn); 
						}else if(bvo.building_id == DBBuilding.B_TRANSPORT){
							arr.push(/*view.unitLvupBtn,*/view.transportBtn);
						}else if(bvo.building_id == DBBuilding.B_TEAMCOPY){
							arr.push(view.teamBtn);
						}else if (bvo.building_id == DBBuilding.B_GUILD) {
							arr.push(view.guidFightBtn, view.enterBtn);
							
						}else if(bvo.building_id == DBBuilding.B_STORE){
							arr.push(/*view.supplyBtn, */view.enterBtn);
						}else if(bvo.building_id == DBBuilding.B_BASE){
							arr.push(view.gameRankBtn);
							// 原先是科技的     添加酿酒  （科技放入酿酒内了）
						}else if(bvo.building_id == DBBuilding.B_BOX){
							var result = ResourceManager.instance.getResByURL("config/tech_smelting_param.json");
							var _level = ToolFunc.getTargetItemData(result, "id", "25")["value"].split("=")[1];
							// 大本营等级要足够
							if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BOX) >= _level) {
								arr.push(view.unitLvupBtn);
							}
							arr.push(view.enterBtn);
							// 进入按钮皮肤特殊处理
							BtnDecorate.setSkin(view.enterBtn, "buildingMenu/icon_search1.png");
							view.enterBtn.label = "EXPLORE";
						}
						else{
							if(bvo.building_id != DBBuilding.B_BASE && bvo.building_id != DBBuilding.B_PVP){
								arr.push(view.enterBtn);
							}
						}
					}
					setBtnPos(arr);
					
					this.closeOnBlank = false;
					_viewH = 260;//配合动画，人肉设定
					this.view.infoTF.text = GameLanguage.getLangByKey(bvo.name) + "	Lv"+ this._data[1].level;
					this.view.titleBG.visible = true;
					
					break;
				case MainMenuView.MENU_CONFIRM:
					view.build.visible = false;
					view.lvUp.visible  = true;
					
					setBtnPos([view.noBtn, view.yesBtn]);
					
					this.isModel = false;
					this.closeOnBlank = false;
					_viewH = 260;//配合动画，人肉设定
					this.view.infoTF.text = GameLanguage.getLangByKey(this._data[1].name) + "	"+GameLanguage.getLangByKey("L_A_73")+"1";
					this.view.titleBG.visible = true;
					break;
				case MainMenuView.MENU_SPEED:
					
					view.build.visible = false;
					view.lvUp.visible  = true;
					
					var cost:Number = DBBuildingCD.cost(User.getInstance().sceneInfo.getQueueTime(_data[1].id));
					if (cost > 0)
					{
						view.speedBtn.label = "L_A_26"
						
						/*if (User.getInstance().sceneInfo.getCanHelp(_data[1].id))
						{
							view.speedBtn.label = "帮助";
						}
						else
						{
							view.speedBtn.label = "L_A_26"
						}*/
					}else{
						view.speedBtn.label = "L_A_27"
					}
					
					//
					arr = [view.noBtn,view.speedBtn]
					var bvo:Object = DBBuilding.getBuildingById(this._data[1].buildId);
					
					var lvVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(this._data[1].buildId, 1)
					if(lvVo.ornot == 1){
						view.noBtn.disabled = false;
					}else{
						view.noBtn.disabled = true;
					}
					
					
					if(bvo.building_type == DBBuilding.TYPE_FUN){
						if(bvo.building_id == DBBuilding.B_PROTECT){
							arr.push(view.defendBtn, view.enterBtn);
						}else{
							if(bvo.building_id != DBBuilding.B_BASE){
								arr.push(view.enterBtn);
							}
						}
						for(var i=2; i<arr.length; i++){
							if(this._data[1].level == 1){
								arr[i].disabled = true;
							}else{
								arr[i].disabled = false;
							}
						}
						
					}
//					this.view.enterBtn.disabled = true;
					setBtnPos(arr);
					
					
					this.isModel = false;
					this.closeOnBlank = false;
					_viewH = 260;//配合动画，人肉设定
					
					var bvo:Object = DBBuilding.getBuildingById(this._data[1].buildId);
					this.view.infoTF.text = GameLanguage.getLangByKey(bvo.name) + "	"+GameLanguage.getLangByKey("L_A_73")+ this._data[1].level;
					this.view.titleBG.visible = true;
					break;
				case MainMenuView.MENU_MONSTER:
					view.build.visible = false;
					view.lvUp.visible  = true;
					
					setBtnPos([view.infoBtn,view.attackBtn]);
					
					this.isModel = false;
					this.closeOnBlank = false;
					_viewH = 260;//配合动画，人肉设定
					
					this.view.infoTF.text = "";
					//this.view.titleBG.visible = false;
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.SHOW_ATTACK_ARROW);
					}
					break;
			}
		}
		
		private function setBtnPos(arr:Array):void{
			var btn:Button;
			for(var i:Number=0; i<this._allBtns.length; i++){
				btn = _allBtns[i];
				if(arr.indexOf(btn) != -1){
					btn.visible = true;
				}else{
					btn.visible = false;
				}
			}
			var pos:Array = _pos[arr.length];
			if(pos){
				for(var i:Number=0; i<arr.length; i++){
					arr[i].x = pos[i];
				}
			}
		}
		
		private function unlockBtns():void{
			var btn:Button;
			for(var i:Number=0; i<this._allBtns.length; i++){
				btn = _allBtns[i];
				if(btn) {
					btn.disabled = false;
				}
			}
		}
		
		
		//for test
		private function initBuildView(type:String=""):void{
			recyle();
			//获取配置数据=====>
			var list:Array = [];
			list=DBBuilding.getBuildListByType(this.view.tab.selectedIndex+1);
			var item:BuildingItem;
			var arr:Array = [];
			var arr1:Array = [];
			var arr2:Array = [];
			for(var i:Number=0; i<list.length; i++){
				item = Pool.getItemByClass("BuildingItem",BuildingItem);
				item.data = list[i];
				item.on(Event.CLICK, this, this.onC);
				if(item.canBuild){
					arr.push(item);
				}else{
					if(item.isMaxNum){
						arr2.push(item);
					}
					else{
						arr1.push(item);
					}
				}
				/*this.view.pane.addChild(item);
				item.x = i* BuildingItem.WIDTH;*/
			}
			arr = arr.concat(arr1);
			arr = arr.concat(arr2);
			for(i=0; i<arr.length; i++){
				item = arr[i];
				this.view.pane.addChild(item);
				if(GameSetting.IsRelease){
					item.scale(0.9,0.9);
					item.x = i* BuildingItem.WIDTH*0.9;
					//item.y = BuildingItem.HEIGHT*(1-0.9);
				}else{
					item.x = i* BuildingItem.WIDTH;
				}
			}
			if(GameSetting.IsRelease){
				view.pane.y = -296 + BuildingItem.HEIGHT*(1-0.9)
			}else{
				view.pane.y = -296
			}
			
			//
			view.pane.scrollTo();
			view.pane.hScrollBar.visible = false;
			
			if (!User.getInstance().hasFinishGuide && type == Event.CHANGE)
			{
				Signal.intance.event(NewerGuildeEvent.CHANGE_CONTRIBUTE_LIST);
			}
		}
		
		private function recyle():void{
			while(view.pane.content.numChildren){
				var item:BuildingItem = view.pane.content.removeChildAt(0) as BuildingItem;
				if(item!=null)
				{
					item.off(Event.CLICK, this, this.onC);
					Pool.recover("BuildingItem", item);
				}
			}
		}
		
		private function onC(event:Event):void{
			var item:BuildingItem = event.target as BuildingItem;
			
				if (event.target.name == "infoBtn") {
					if (!User.getInstance().hasFinishGuide)
					{
						return;
					}
					item = event.target.parent as BuildingItem;
					var bdData:ArticleData = new ArticleData();
					bdData.buildId  = item.data.building_id;
					//bdData.level = (User.getInstance().sceneInfo.getBuildingLv(bdData.buildId) || 1);
					bdData.level = 1;
					InfoViewFactory.showInfo(bdData);
					return;
				}
				//条件判定===
				var buildLvVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(item.data.building_id, 1);
				var canUp:Boolean = DBBuildingUpgrade.checkCanUp(parseInt(item.data.building_id), 0)
				trace("canUp----------,",canUp,item.isMax);
				if(canUp && !item.isMax){
					Signal.intance.event(BuildEvent.BUILD_START, item.data);
					this._data = item.data
					
					if (!User.getInstance().hasFinishGuide)
					{
						Laya.timer.once(200,this, function() { 
							Signal.intance.event(NewerGuildeEvent.PUT_BUILDING_OK);
						} );
					}
				}else{
					//XTip.showTip("Maybe later~");
				}
		}
		
		override public function close():void {
			if (!User.getInstance().hasFinishGuide && _menuType == MainMenuView.MENU_BUILD)
			{
				return;
			}
			this._data = null;
			//定义出场动画
			var tarY:Number = this.y;
			Tween.to(this, {y:tarY+_viewH, alpha:0}, 120,null,Handler.create(this, onClose));
		}
		
		private function onClose():void{
			this.recyle();
			super.close();
			view.infoTF.text = "";
			_onStage = false;
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("buildingMenu/bg3.png");
			super.dispose();
		}
		
		override public function createUI():void{
			this._view = new homeMenuViewUI();
			this.addChild(_view);
			this.mouseThrough = _view.mouseThrough = true;
			view.pane.hScrollBar.skin = "";
			
			this._allBtns = [];
			this._allBtns.push(view.yesBtn,view.noBtn, view.infoBtn, view.lvUpBtn, view.speedBtn, view.enterBtn,view.attackBtn,view.defendBtn, view.equipCopyBtn);
			this._allBtns.push(view.geneCopyBtn, view.growthBtn, view.radarBtn, view.techBtn, view.unitLvupBtn,view.transportBtn,view.enhanceBtn,view.mineBtn);
			this._allBtns.push(view.teamBtn, view.jfBtn, view.guidFightBtn, view.supplyBtn,view.gameRankBtn,view.formatBtn,view.shop1Btn);
			BtnDecorate.decorate(view.yesBtn,"buildingMenu/icon_confirm.png");
			BtnDecorate.decorate(view.noBtn,"buildingMenu/icon_cancel.png");
			BtnDecorate.decorate(view.speedBtn,"buildingMenu/icon_speed.png");
			BtnDecorate.decorate(view.infoBtn,"buildingMenu/icon_info.png");
			BtnDecorate.decorate(view.lvUpBtn,"buildingMenu/icon_upgrade.png");
			BtnDecorate.decorate(view.enterBtn,"buildingMenu/icon_enter.png");
			BtnDecorate.decorate(view.attackBtn,"buildingMenu/icon_attack.png");
			BtnDecorate.decorate(view.defendBtn,"buildingMenu/icon_defence.png");
			BtnDecorate.decorate(view.equipCopyBtn, "buildingMenu/icon_equipfb.png");//
			BtnDecorate.decorate(view.techBtn, "buildingMenu/icon_up.png");
			BtnDecorate.decorate(view.radarBtn, "buildingMenu/leida.png");
			// 冶炼（酿酒）
			BtnDecorate.decorate(view.unitLvupBtn, "buildingMenu/keji.png");
			BtnDecorate.decorate(view.transportBtn, "buildingMenu/icon_yunbiao.png");
			BtnDecorate.decorate(view.geneCopyBtn, "buildingMenu/icon_genefb.png");
			BtnDecorate.decorate(view.enhanceBtn, "buildingMenu/icon_3.png");
			BtnDecorate.decorate(view.growthBtn, "buildingMenu/icon_tie.png");
			BtnDecorate.decorate(view.mineBtn, "buildingMenu/icon_mine.png");
			BtnDecorate.decorate(view.teamBtn, "buildingMenu/icon_team.png");
			BtnDecorate.decorate(view.formatBtn, "buildingMenu/icon_format.png");
			this._redot0 = new Image("common/redot.png");
			this._redot1 = new Image("common/redot.png");
			this._redot2 = new Image("common/redot.png");
			this._redot3 = new Image("common/redot.png");
			
			var btns:Array = view.tab.items;
			for(var i:int=0; i<btns.length; i++){
				btns[i].labelFont = XFacade.FT_BigNoodleToo;
				if(this["_redot"+i]){
					btns[i].addChild(this["_redot"+i]);
					this["_redot"+i].pos(180,8);
				}
			}
			
			UIRegisteredMgr.AddUI(view.techBtn,"EnterLvUpBtn");
			UIRegisteredMgr.AddUI(view.enterBtn,"MenuEnterBtn");
			UIRegisteredMgr.AddUI(view.defendBtn,"MenuDefBtn");
			UIRegisteredMgr.AddUI(view.transportBtn,"TransportBtn");
			UIRegisteredMgr.AddUI(view.unitLvupBtn,"EnterTechBtn");
			UIRegisteredMgr.AddUI(view.equipCopyBtn,"EquipRaidBtn");
			UIRegisteredMgr.AddUI(view.enhanceBtn,"EnterEquipBtn");
			UIRegisteredMgr.AddUI(view.mineBtn,"GoToMine");
			UIRegisteredMgr.AddUI(view.growthBtn,"AdvEnter");
			UIRegisteredMgr.AddUI(view.jfBtn,"junFuEnter");
			UIRegisteredMgr.AddUI(view.teamBtn,"teamFightEnter");
			UIRegisteredMgr.AddUI(view.unitLvupBtn,"lianjinEnter");
			
			this.onStageResize();
			//cacheAsBitmap = true;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("EnterLvUpBtn");
			UIRegisteredMgr.DelUi("MenuEnterBtn");
			UIRegisteredMgr.DelUi("MenuDefBtn");
			UIRegisteredMgr.DelUi("TransportBtn");
			UIRegisteredMgr.DelUi("EnterTechBtn");
			UIRegisteredMgr.DelUi("EquipRaidBtn");
			UIRegisteredMgr.DelUi("EnterEquipBtn");
			UIRegisteredMgr.DelUi("GoToMine");
			UIRegisteredMgr.DelUi("AdvEnter");
			UIRegisteredMgr.DelUi("junFuEnter");
			UIRegisteredMgr.DelUi("teamFightEnter");
			UIRegisteredMgr.DelUi("lianjinEnter");
			super.destroy(destroyChild);
		}
		
		override public function onStageResize():void{
			//this.y  = LayerManager.instence.stageHeight - this.height;
			this.view.bg.width = LayerManager.instence.stageWidth;
			
			view.pane.width  = LayerManager.instence.stageWidth;
			view.pane.height = BuildingItem.HEIGHT;
			view.tab.x = (view.pane.width-view.tab.width)/2;
			
			view.lvUp.x = (LayerManager.instence.stageWidth - view.lvUp.width)/2;
			
			super.onStageResize();
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case this.view.yesBtn:
					Signal.intance.event(BuildEvent.BUILD_DONE);
					if (!User.getInstance().hasFinishGuide)
					{
						Laya.timer.once(100, this, function() {
							Signal.intance.event(NewerGuildeEvent.CONFIRM_BUILDING);
							})
						
					}
					break;
				case this.view.noBtn:
					if(_menuType == MENU_CONFIRM){
						Signal.intance.event(BuildEvent.BUILD_CANCEL);
						this.close();
					}else{
						Signal.intance.event(BuildEvent.BUILD_RUIN);
					}
					break;
				case this.view.lvUpBtn:
					//SoundMgr.instance.playSound(ResourceManager.getSoundUrl("ui_levelup",'uiSound'));
					if(view.lvUpBtn.gray){
						//XTip.showTip("哇咔咔，这个建筑已经升级到满级了");
					}else{
						UpViewFactory.showLvUp(this._data[1]);
					}
					
					break;
				case this.view.infoBtn:
					var articleData:ArticleData = this._data[1];
					if(articleData.type == ArticleData.TYPE_MONSTER){
						XFacade.instance.openModule("MonsterRiotView", this._data);
					}else if(articleData.type == ArticleData.TYPE_BUILDING){
						InfoViewFactory.showInfo(this._data[1]);
						//XFacade.instance.showModule(BuildingInfoView, this._data);
					}
					break;
				case this.view.enterBtn:
					enterBuilding();
					this.close();
					break;
				case this.view.speedBtn:
					Signal.intance.event(BuildEvent.BUILD_SPEED);
					if (!User.getInstance().hasFinishGuide)
					{
						Laya.timer.once(100, this, function() {
							Signal.intance.event(NewerGuildeEvent.SPEED_UP_BUILDING);
							})
						
					}
					break;
				case this.view.attackBtn:
					attack(this._data[1].id)
					//FightingManager.intance.getSquad(4, this._data[1].id, Handler.create(this, this.onFightOver));
					break;
				case this.view.defendBtn:
					//FightingManager.intance.getSquad(110, null, Handler.create(this, this.onFightOver));
					this.showDefend();
					break;
				case this.view.equipCopyBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,2]);
					//XFacade.instance.openModule("EquipMainView",3);
					break;
				case view.enhanceBtn:
					XFacade.instance.openModule("EquipMainView",1);
					break;
				case this.view.growthBtn:
					XFacade.instance.openModule(ModuleName.AdvanceView);
					break;
				case this.view.geneCopyBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,1]);
					break;
				case this.view.radarBtn:
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					break;
				case this.view.techBtn:
					XFacade.instance.openModule("LevelUpView");
					break;
				// 酿酒
				case this.view.unitLvupBtn:
					XFacade.instance.openModule(ModuleName.LiangjiuView);
					break;
				case this.view.transportBtn:
					XFacade.instance.openModule(ModuleName.TrainLoadingView);
					break;
				case this.view.mineBtn:
					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				case this.view.teamBtn:
					this.close();
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				case this.view.jfBtn:
					this.close();
					XFacade.instance.openModule(ModuleName.MilitartHouseView);
					break;
				case view.guidFightBtn:
					var juntuan_canshu = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
					var _gz_lv = Number(juntuan_canshu["72"].value);
					// 玩家等级不足国战开放条件
					if (User.getInstance().level < _gz_lv) {
						var _text = GameLanguage.getLangByKey("L_A_158").replace("{0}", _gz_lv);
						return XTip.showTip(_text);
					}
					// 公会等级不足开放条件
					var _gh_lvArr = juntuan_canshu["74"].value.split("=");
					if(User.getInstance().sceneInfo.getBuildingLv(_gh_lvArr[0]) < Number(_gh_lvArr[1])) {
						return XTip.showTip(GameLanguage.getLangByKey("L_A_157"));
					}
					
					if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) == 1 &&
						User.getInstance().sceneInfo.hasBuildingInQueue(DBBuilding.B_GUILD)
					) {
						XTip.showTip(GameLanguage.getLangByKey("L_A_157"));
					} else {	
						XFacade.instance.openModule("ArmyGroupMapView");
						this.close();
					}
				
					break;
				case view.supplyBtn:
					XFacade.instance.openModule("TrophyRoomView");
					this.close();
					break;
				case view.gameRankBtn:
					XFacade.instance.openModule(ModuleName.GameRankView);
					this.close();
					break;
				case view.formatBtn:
					XFacade.instance.openModule(ModuleName.FormatView);
					this.close();
					break;
				case view.shop1Btn://互动商店
					var arr = [];
					XFacade.instance.openModule("StoreView",[0,1]);
					this.close();
					break;
				default:
					if(event.target.name.indexOf("Buy_")!=-1)
					{
						var l_str:String=event.target.name;
						var l_arr:Array=l_str.split("_");
						var l_data:reVo;
						for (var i:int = 0; i < GameConfigManager.re_list.length; i++) 
						{
							if(l_arr[1]==GameConfigManager.re_list[i].id)
							{
								l_data=GameConfigManager.re_list[i];
								GlobalRoleDataManger.instance.ItemPayHandler(l_data);
								break;
							}
						}
					}
					break;
			}
		}
		
		
		private function enterBuilding():void{
			var data:ArticleData = this._data[1];
			var id:String  = data.buildId;
			id = id.replace("B","");
			trace("buildingID: " + id);
			switch(id){
				case DBBuilding.B_TRAIN:
					XFacade.instance.openModule("TrainView");
					break;
				case DBBuilding.B_CAMP:
					XFacade.instance.openModule("CampView");
					break;
				case DBBuilding.B_BASE:
					//XFacade.instance.openModule("MonsterRiotView");
					//XFacade.instance.openModule("StoreView");
					//XFacade.instance.openModule("EquipMainView");
					break;
				case DBBuilding.B_BOX:
					XFacade.instance.openModule("ChestsMainView");
//					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_ARMYGROUP);
//					XFacade.instance.openModule("ArmyGroupMapView");
					break;
				case DBBuilding.B_GENE:
					XFacade.instance.openModule("GeneEquipView");
					break;
				case DBBuilding.B_GUILD:
					if(User.getInstance().guildID != "")
					{
						XFacade.instance.openModule(ModuleName.GuildMainView);
					}
					else
					{
						XFacade.instance.openModule(ModuleName.CreateGuildView);
					}
					break;
				case DBBuilding.B_RELIC:
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETTRANSPORTTYPE,[]);
					//XFacade.instance.openModule("EscortMainView");
					break;
				case DBBuilding.B_RADIO:
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					//XFacade.instance.openModule(ModuleName.TechTreeMainView);
					break;
				case DBBuilding.B_STORE:
					XFacade.instance.openModule("StoreView",[0,0]);
					break;
				case DBBuilding.B_TRANSPORT:
//					XFacade.instance.openModule(ModuleName.TrainLoadingView,3);
					break;
				case DBBuilding.B_PROTECT:
					XFacade.instance.openModule("MilitaryView");
					break;
				case DBBuilding.B_MINE:
					XFacade.instance.openModule(ModuleName.MineFightView);					
					break;
				case DBBuilding.B_ARENA:
					XFacade.instance.openModule(ModuleName.ArenaMainView);
					//SceneManager.intance.setCurrentScene(SceneType.M_SCENE_ARENA);
					break;
				case DBBuilding.B_PVP:
					XFacade.instance.openModule(ModuleName.PvpMainPanel);
					break;
				case DBBuilding.B_TEAMCOPY:
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				default:
					XTip.showTip("coding");
					break;
			}
		}
		
		/**杀一只怪物*/
		public function attack(id:*):void{
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_HOME, id, Handler.create(this, this.onFightOver));
		}
		
		/**进入防御布阵*/
		public function showDefend():void{
			FightingManager.intance.getSquad(110, null, Handler.create(this, this.onFightOver));
		}
		
		private function onFightOver():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		//确认状态，是否可以建筑
		private var _canBuild:Boolean
		private function onBuildChange(b:Boolean):void{
			canBuild = b;
		}
		
		private function set canBuild(v:Boolean):void{
			if(this._canBuild != v){
				this._canBuild = v;
				if(this._canBuild){
					this.view.yesBtn && (this.view.yesBtn.disabled = false);
				}else{
					this.view.yesBtn && (this.view.yesBtn.disabled = true);
				}
			}
		}

		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			this.view.tab.on(Event.CHANGE, this, this.initBuildView,[Event.CHANGE]);
			Signal.intance.on(BuildEvent.BUILD_RESULT, this, this.onBuildChange);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WATER),this,onResult,[ServiceConst.GET_WATER]);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			this.view.tab.off(Event.CHANGE, this, this.initBuildView);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WATER),this,onResult);
			Signal.intance.off(BuildEvent.BUILD_RESULT, this, this.onBuildChange);
			super.removeEvent();
		}
		
//		private function onResult(cmd:int, ...args):void
//		{
//			// TODO Auto Generated method stub
//			switch(cmd)
//			{
//				case ServiceConst.GET_WATER:
//					var user:User = GlobalRoleDataManger.instance.user;
//					user.water=args[1];
//					MainView(XFacade.instance.getView(MainView)).UpdateWater();
//					break;
//				default:
//				{
//					break;
//				}
//			}
//		}
		
		private function get view():homeMenuViewUI{
			return this._view as homeMenuViewUI;
		}
	}
}