/***
 *作者：罗维
 */
package game.module.fighting.scene
{
	import game.global.event.GameEvent;
	import MornUI.fightingChapter.fightMapMenuUI;
	
	import game.common.BufferView;
	import game.common.ITabPanel;
	import game.common.ListPanel;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.SoundMgr;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.BaseScene;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.event.Signal;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.module.equipFight.EquipFightInfoView;
	import game.module.fighting.cell.GuanQiaCell;
	import game.module.fighting.mgr.FightingStageManger;
	import game.module.fighting.panel.JYChapterLevelPanel;
	import game.module.fighting.panel.PTChapterLevelPanel;
	import game.module.fighting.view.FightingChapetrView;
	import game.module.fighting.view.FightingJYChapetrView;
	import game.module.fighting.view.FightingOtherView;
	import game.module.fighting.view.GeneChapetrView;
	import game.module.mainui.MainView;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Tab;
	import laya.ui.UIUtils;
	
	/**
	 * 老胡修改：
	 * 类功能，控制各种关卡面板的显示。
	 */
	public class FightingMapScene extends BaseScene
	{
		/**
		 *子副本展开
		 */
		public static const SHOWPANEL_EVENT:String = "SHOWPANEL_EVENT";  
		/**
		 *基因副本展开
		 */
		public static const SHOWPANELID_GENE:uint = "0";  
		
		private var _panelList:ListPanel;
		//分类tab
		private var _panelListTb:Tab;
		private var _args:Array;
		private var _btnList:Array = [];
		//副本分类-操作面板
		private var menuview:fightMapMenuUI;
		private var _levelLayer:ListPanel;
		
		private var _oldIndex:int = 0;
		
		/**
		 * 时候选定了关卡
		 */
		private var _isSelectedChapter:Boolean = false;
		
		public function FightingMapScene(URL:String = "", isCanDrag:Boolean=true)
		{
			super(URL, isCanDrag);
			isHideLoading = false;
			
		}

		public override function show(...args):void{
			
			super.show(args);
			_args = (args[0] || [0]);
			
			if (_args.length > 0)
			{
				FightingStageManger.intance.autoSelectCID = parseInt(_args[1]) + 1;
				trace("传入关卡数据", _args);
				trace("自动选择关卡ID：", FightingStageManger.intance.autoSelectCID);
			}
			
			loadSceneResource();
			
			//打开主界面资源信息
			XFacade.instance.openModule(ModuleName.MainView,MainView.MODE_ONLY_INFO);
			SoundMgr.instance.playMusicByURL(ResourceManager.instance.getSoundURL("loading"));
		}
		
		
		/**界面加载完成*/
		protected override function onLoaded():void{
			super.onLoaded();
			
			if(!menuview)
			{
				menuview = new fightMapMenuUI(); 
				_panelListTb = menuview.tab1;
				addChild(menuview);
				menuview.pos(Laya.stage.width - menuview.width >> 1, Laya.stage.height - menuview.height);
				_oldIndex = 0;
				_panelListTb.on(Event.CHANGE,this,thisTabChange);
				
				UIRegisteredMgr.AddUI(_panelListTb.getChildAt(2),"JY_Raid");
				UIRegisteredMgr.AddUI(_panelListTb.getChildAt(1),"Challenge_Raid");
//				UIRegisteredMgr.AddUI(_panelListTb.getChildAt(3),"play_raid");
			}
			menuview.visible = true;
			initMapData();
			onStageResize();
		}
		
		
		private function initMapData():void
		{
			if(!FightingStageManger.intance.isInit)
			{
				Signal.intance.on(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
				FightingStageManger.intance.initData();
			}else
			{
				initMapDataBack();
			}
		}
		
		protected function initMapDataBack():void{
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
			
			//
			var btn:Button = _panelListTb.items[2];
			btn && (btn.filters = null);
			if(!FightingStageManger.intance.openNum(true))
			{
				btn && (btn.filters = [UIUtils.grayFilter]);
				if(_args && _args[0] == 2) {
					_args = null;
				}
			}
			// 
			
			bindArgs();
			BufferView.instance.close();
		}
		
		private function thisTabChange():void{
			var idx:Number = _panelListTb.selectedIndex;
			var btn:Button = _panelListTb.items[idx];
			if(btn && btn.filters)
			{
				XTip.showTip("L_A_51");
				
				_panelListTb.selectedIndex = _oldIndex;
				return ;
			}
			_oldIndex = idx;
			
			var itp:ITabPanel = _panelList.getPanel(idx);
			if(idx == 0 || idx == 2)
			{
				var fcv:FightingChapetrView = itp;
				if(fcv.dataIndex != -1){
					fcv.pArgs = [fcv.dataIndex];
				}
			}
			
			
			//将界面加入舞台
			_panelList.selIndex = idx;
			
			if (idx == 1)
			{
				Signal.intance.event(GameEvent.CHECK_OPEN_ST);
			}
		}
		
		private function bindArgs():void
		{
			trace("_args111:"+_args)
			if(_args && _args.length){
				if(_args.length >= 1)
				{
					var idx:Number = Number(_args.shift());
					var itp:ITabPanel = _panelList.getPanel(idx);
					if(idx == 0)
					{
						(itp as FightingChapetrView).pArgs = _args;
					}else if(idx == 1)
					{
						(itp as FightingOtherView).pArgs = _args;
					}else if(idx == 2)
					{
						(itp as FightingJYChapetrView).pArgs = _args; 
					}
					_panelListTb.selectedIndex = idx;
				}
			}else
			{
				_panelListTb.selectedIndex = 0;
			}
		}
		
		
		
		public override function close():void{
			super.close();
			XFacade.instance.closeModule(PTChapterLevelPanel);
			XFacade.instance.closeModule(JYChapterLevelPanel);
			//关闭主界面
			XFacade.instance.closeModule(MainView);
			for (var i:int = 0; i < _panelList.panelList.length; i++) 
			{
				var v:* = _panelList.panelList[i];
				if(v is FightingChapetrView)
					(v as FightingChapetrView).dataIndex = -1;
			}
			
			FightingStageManger.intance.autoSelectCID = -1;
			
			if(_panelList)_panelList.selIndex = -1;
			if(_levelLayer)_levelLayer.selIndex = -1;
			if(_panelListTb)_panelListTb.selectedIndex = -1;
			_args= null;
		}
		
		/**获取关卡按钮*/
		public function getStageBtn(Id:Number):GuanQiaCell{ 
			var fmView:FightingChapetrView = _panelList.getPanel(0);
			if(fmView)
			{
				return fmView.getStageBtn(Id);
			}
			return null;
		}
	
		override public function initScence():void
		{
			super.initScence();
			this.m_SceneResource="FightingMapScene";
			_panelList = new ListPanel([FightingChapetrView,FightingOtherView,FightingJYChapetrView]);
			this.addChild(_panelList);
			_panelList.mouseThrough = true;
			
			_levelLayer = new ListPanel([GeneChapetrView]);
			this.addChild(_levelLayer);
		}
		
		
		
		//界面逻辑==============================================by huhaiming
		private function onBack():void{
			if(_levelLayer.selIndex != -1)
			{
				_levelLayer.selIndex = -1;
				menuview.visible = true;
				return;
			}
			
			var efiv:EquipFightInfoView = XFacade.instance.getView(EquipFightInfoView);
			if(efiv && efiv.displayedInStage)
			{
				XFacade.instance.closeModule(EquipFightInfoView);
				menuview.visible = true;
				return ;
			}
			
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		private function onOpenWin():void{
			menuview.visible = false;
		}
		
		override public function addEvent():void{
			super.addEvent();
			Signal.intance.on(MainView.BACK, this, this.onBack);
			Signal.intance.on(SHOWPANEL_EVENT, this, this.showPanel);
			Signal.intance.on(FightingOtherView.OPEN_WIN, this, this.onOpenWin);
			if(_panelListTb)
			{
				_panelListTb.off(Event.CHANGE,this,thisTabChange);
				_panelListTb.on(Event.CHANGE,this,thisTabChange);
			}
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			Signal.intance.off(MainView.BACK, this, this.onBack);
			Signal.intance.off(SHOWPANEL_EVENT, this, this.showPanel);
			Signal.intance.off(FightingOtherView.OPEN_WIN, this, this.onOpenWin);
			
			if(_panelListTb){
				_panelListTb.off(Event.CHANGE,this,thisTabChange);
			}
		}
		
		private function showPanel(d:*):void{
			_levelLayer.selIndex = d;
		}
		
		override public function onStageResize():void
		{
			menuview && menuview.pos(Laya.stage.width - menuview.width >> 1, Laya.stage.height - menuview.height);
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			_panelList = null;
			_panelListTb = null;
			_btnList = null;
			menuview = null;
			_levelLayer = null;
			super.destroy(destroyChild);
		}
	}
}