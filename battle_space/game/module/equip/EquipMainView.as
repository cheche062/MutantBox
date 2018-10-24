package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.equip.EquipMainViewUI;
	import MornUI.relic.EscortMainViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AndroidPlatform;
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.EquipEvent;
	import game.global.event.Signal;
	import game.global.vo.FightUnitVo;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.EquipmentBaptizeVo;
	import game.global.vo.equip.EquipmentBaseVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.HeroEquipVo;
	import game.module.bag.BagPanel;
	import game.module.tips.itemTip.ItemTipManager;
	import game.module.tips.itemTip.base.BaseItemTip;
	import game.module.train.TrainItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class EquipMainView extends BaseDialog
	{
		private var m_selectHeroIndex:int=0;
		private var m_selectEquipIndex:int=0;
		private var m_stageIndex:int=0;
		private var m_heroData:Object;
		private var m_heroList:Array = [];
		private var m_equipmentBaseVo:EquipmentBaseVo;
		private var m_selectItemData:ItemData;
		private var m_selectStrongEquip:Object;
		private var m_selectHeroEquip:EquipInfoVo;
		private var m_selectLocal:int;
		private var m_EquipTips:BaseItemTip;
		private var m_isAddTips:Boolean;
		private var m_EquipPlayerInfo:EquipPlayerInfo;
		private var m_showSultInfo:Boolean;
		//强化
		private var m_isBag:Boolean;
		private var m_washEquipBox:WashBagView;
		private var m_washPageType:int;
		private var m_selectHero:int;
		//
		private var m_washPropertyList:Array=[null,null,null];
		
		private var m_isWashTips:Boolean;
		private var m_isWashWinShow:Boolean;
		
		private var m_equipStrongView:EquipStrongView;
		 
		private var m_washWinType:int=0;
		private var m_selectWashEquip:Object;
		private var m_washEquipStr:String="";
		//分解
		private var m_resolveEquipList:Array;
		private var m_resolveList:Array;
		private var m_resolveBagView:ResolveBagView;	
		private var m_resolveInfoView:ResolveInfoView; 
		private var m_equipSelectQuality:EquipSelectQualityView;
		private var m_isQuickResolve:Boolean;
		private var m_selectTips:Boolean;
		private var m_quickResolveStr:String;
		private var m_resolveReward:ResolveRewardView;
		private var m_isfrist:Boolean;
		private var m_isadd:Boolean=false;
		
		private var m_equipStrongEffect:Animation;
		private var m_equipWashEffect:Animation;
		
		
		public function EquipMainView()
		{
			super();
			
			this.closeOnBlank=true;
		}
		
		override public function createUI():void
		{
			this._view = new EquipMainViewUI();
			this.addChild(_view);
			
			createHeroList();
			
			UIRegisteredMgr.AddUI(view.ItemList,"EquipList");
			UIRegisteredMgr.AddUI(view.WashBtn,"EatEquipBtn");
			UIRegisteredMgr.AddUI(view.RefreshBtn,"ResolveEquip");
			UIRegisteredMgr.AddUI(view.BattleBtn,"UpdateEquipBtn");
			UIRegisteredMgr.AddUI(view.WashEquipBox.SoldierBtn,"EquipBag");
			UIRegisteredMgr.AddUI(view.WashBox.RefreshBtn,"WashEquipBtn");
			UIRegisteredMgr.AddUI(view.WashBox.RetainBtn,"SaveProBtn");
			
			UIRegisteredMgr.AddUI(view.WashBox.EnhanceBtn,"EnhanceBtn");
			
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_stageIndex=1;
			AnimationUtil.flowIn(this);
			GameConfigManager.intance.getEquipParam();
			initUI();
			
		}
		
		override public function dispose():void{
			super.dispose();
			
			UIRegisteredMgr.DelUi("EquipList");
			UIRegisteredMgr.DelUi("EatEquipBtn");
			UIRegisteredMgr.DelUi("ResolveEquip");
			UIRegisteredMgr.DelUi("UpdateEquipBtn");
			UIRegisteredMgr.DelUi("EnhanceBtn");
			UIRegisteredMgr.DelUi("HeroList");
			UIRegisteredMgr.DelUi("EquipCell");
			UIRegisteredMgr.DelUi("EquipBag");
			UIRegisteredMgr.DelUi("WashEquipBtn");
			
			Laya.loader.clearRes("equip/bg1_1.png");
			Laya.loader.clearRes("equip/btn_bg1.png");
			m_EquipPlayerInfo && m_EquipPlayerInfo.destroy(true);
		}
		
		override public function close():void{
			if(m_EquipTips){
				m_EquipTips.removeSelf();
				m_EquipTips = null;
			}
			
			m_EquipPlayerInfo && m_EquipPlayerInfo.clearHeroSkin();
			AnimationUtil.flowOut(this, this.onClose);
			super.close();
		}
		
		/**
		 * 初始化
		 */
		private function initUI():void
		{
			DataLoading.instance.show();
//			BagManager.instance
			// TODO Auto Generated method stub
			//createFoodsList();
			m_isAddTips=false;
			m_isQuickResolve=false;
			m_equipmentBaseVo=new EquipmentBaseVo();
			m_selectHeroIndex=0;
			m_isfrist=true;
			m_isWashTips=false;
			m_isWashWinShow=false;
			this.view.StrengBtn.text.text=GameLanguage.getLangByKey("L_A_48019");
			this.view.WashBtn.text.text=GameLanguage.getLangByKey("L_A_48020");
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_48000");
			this.view.ResolveInfo.ResolveRewardText.text=GameLanguage.getLangByKey("L_A_48024");
			this.view.ResolveInfo.ResolveTipsText.text=GameLanguage.getLangByKey("L_A_48023");
			this.view.RefreshBtn.text.text=GameLanguage.getLangByKey("L_A_48056");
			this.view.EquipMentFBBtn.text.text=GameLanguage.getLangByKey("L_A_44000");
			this.view.EquipSelectQuality.visible=false;
			this.view.ResolveReward.visible=false;
			this.view.StrengBtn.gray=true;
			this.view.WashBtn.gray=true;
			this.view.RefreshBtn.gray=true;
			
			this.view.ResolveInfo.visible=false;
			this.view.ResolveBag.visible=false;
			this.view.WashEquipBox.visible=false;
			this.view.WashBox.visible=false;
			this.view.BtnBox.visible=false;
			var l_arr:Array=GameConfigManager.equipParamVo.getOpenStrongLevel();
			if(isOpenModule(l_arr,0))
			{
				this.view.StrengBtn.gray=false;
			}
			var l_arr:Array=GameConfigManager.equipParamVo.getOpenWashLevel();
			if(isOpenModule(l_arr,0))
			{
				this.view.WashBtn.gray=false;
			}
			var l_arr:Array=GameConfigManager.equipParamVo.getOpenResolveLevel();
			if(isOpenModule(l_arr,0))
			{
				this.view.RefreshBtn.gray=false;
			}

			m_showSultInfo=false;
			WebSocketNetService.instance.sendData(ServiceConst.C_INFO,[]);
		}		
		
		private function createHeroList():void
		{
			trace("createHeroList");
			this.view.HeroList.itemRender = TrainItem;
			this.view.HeroList.hScrollBarSkin="";
			this.view.HeroList.selectEnable = true;
			
			this.view.HeroList.selectHandler=new Handler(this, onHeroSelect);
			this.view.HeroList.array=m_heroList;
			this.view.HeroList.selectedIndex=0;
		}
		
		private function onHeroSelect(p_index:int):void
		{
			var ar:Array = this.view.HeroList.array;
			if(ar && ar.length > p_index){
				for(var i:int=0;i<ar.length;i++)
				{
					var l_cell:TrainItem=this.view.HeroList.getCell(i)as TrainItem;
					if(l_cell!=null)
					{
						l_cell.selected=false;
					}
				}
				m_selectHeroIndex=p_index;
				var l_herocell:TrainItem=this.view.HeroList.getCell(p_index)as TrainItem;
				if(l_herocell){
					l_herocell.selected=true;
				}
				m_heroData = this.view.HeroList.array[p_index];
				createPlayerInfo();
			}
		}
		
		//英雄装备列表
		private function createEquipList():void
		{
			var l_arr:Array=BagManager.instance.getEquipByHeroId(m_heroData.unitId);
			this.view.ItemList.array=null;
			if(l_arr==null)
			{
				this.view.ItemList.visible=false;
			}
			else
			{
				l_arr=finishEquipList(l_arr);
				this.view.ItemList.selectedIndex=-1;
				this.view.ItemList.visible=true;
				this.view.ItemList.itemRender=EquipBagCell;
				this.view.ItemList.selectEnable = true;
				this.view.ItemList.vScrollBarSkin = "";
				this.view.ItemList.selectHandler = new Handler(this, onSelect);
				this.view.ItemList.array=l_arr;
			}
		}

		private function finishEquipList(p_arr:Array):Array
		{
			var max:int=4*3;
			var l_addNum:int=0;
			if(p_arr.length<max)
			{
				l_addNum=max-p_arr.length;
			}
			else
			{
				var l_line:int=p_arr.length%4;
				l_addNum=4-l_line;
			}
			for(var i:int=0;i<l_addNum;i++)
			{
				p_arr.push(null)
			}
			return p_arr;
		}

		/**
		 * 
		 * @param p_index
		 * 
		 */		
		private function onSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			
			m_selectEquipIndex=p_index;
			if(m_stageIndex==1)
			{
				if(this.view.ItemList.array[p_index]==null)
				{
					return;
				}
				var l_cell:EquipBagCell=this.view.ItemList.getCell(p_index)as EquipBagCell;
				if(l_cell!=null)
				{
					for (var i:int = 0; i < this.view.ItemList.array.length; i++) 
					{
						var l_itemCell:EquipBagCell= this.view.ItemList.getCell(i);
						if(l_itemCell)
						{
							l_itemCell.selected=false;
						}
					}
					l_cell.selected=true;
					m_selectItemData = this.view.ItemList.getItem(p_index) as ItemData;
					var l_equip:EquipmentListVo = GameConfigManager.EquipmentList[m_selectItemData.iid]
					m_selectHeroEquip=getPlayerEquipInfo(l_equip.location);
					m_selectLocal=l_equip.location;
					var l_heroVo:HeroEquipVo=m_equipmentBaseVo.getSelectHero(m_heroData.unitId);
					if(l_heroVo!=null)
					{
						l_heroVo.level=m_heroData.level;
					}
					else
					{
						l_heroVo=new HeroEquipVo();
						l_heroVo.level=m_heroData.level;
						l_heroVo.unitId=m_heroData.unitId;
						l_heroVo.equipList=new Array();
						l_heroVo.data=m_heroData;
					}
					if(m_selectHeroEquip!=null)
					{
						m_EquipTips = ItemTipManager.getTips(this.m_selectItemData,m_selectHeroEquip,l_heroVo);
						m_selectTips=true;
					}
					else
					{
						m_EquipTips = ItemTipManager.getTips(this.m_selectItemData,null,l_heroVo);
						m_selectTips=true;
					}

					if(m_EquipTips!=null)
					{
						m_EquipTips.visible=true;
					}
					
					if(m_isAddTips==false)
					{
						m_isAddTips=true;
						this.addChild(m_EquipTips);	
					}
					this.view.ItemList.selectedIndex=-1;
				}
			}
			else if(m_stageIndex==2)
			{
				if(this.view.ResolveBag.BagItemList.array[p_index]==null)
				{
					return;
				}
				var l_itemvo:ItemData =this.view.ResolveBag.BagItemList.getItem(p_index);
				if(l_itemvo!=null)
				{
					var has:Boolean=false;
					for (var i:int = 0; i < m_resolveList.length; i++) 
					{
						if(m_resolveList[i]!=null)
						{
							if(l_itemvo.key==m_resolveList[i].key)
							{
								has=true;
							}
						}
					}
					if(has==false)
					{
						m_isQuickResolve=false;
						m_resolveList.push(l_itemvo);
					}
					var l_cell:EquipBagCell=this.view.ResolveBag.BagItemList.getCell(p_index);
					l_cell.gray=true;
					m_EquipTips = ItemTipManager.getTips(l_itemvo);
					m_selectTips=true;
					if(m_EquipTips!=null)
					{
						m_EquipTips.visible=true;
					}
					
					if(m_isAddTips==false)
					{
						m_isAddTips=true;
						this.addChild(m_EquipTips);	
					}
					m_resolveBagView.updateList(m_resolveEquipList);
					m_resolveInfoView.updateList(m_resolveList);
					this.view.ResolveBag.BagItemList.selectedIndex=-1;
				}
			}
			else if(m_stageIndex==3 || m_stageIndex==4)
			{
				
				if(m_washPageType==1)
				{
				}
				else
				{
					if(this.view.WashEquipBox.SoldierList.array[p_index]==null)
					{
						return;
					}
					if(m_stageIndex==4&&m_isWashTips==true)
					{
						m_selectWashEquip=this.view.WashEquipBox.SoldierList.getItem(p_index);
						WashTipsWin(2);
						return;
					}
					for (var i:int = 0; i < this.view.WashEquipBox.SoldierList.length; i++) 
					{
						var l_cell:EquipBagCell=this.view.WashEquipBox.SoldierList.getCell(i);
						if(l_cell!=null)
						{
							l_cell.selected=false;
						}
					}
					m_washEquipBox.selectHeroEquipCell(-1,-1);
					var l_selectCell:EquipBagCell=this.view.WashEquipBox.SoldierList.getCell(p_index);
					if(l_selectCell!=null)
					{
						l_selectCell.selected=true;
					}
					
					m_selectItemData=this.view.WashEquipBox.SoldierList.getItem(p_index);
					this.m_selectStrongEquip=this.view.WashEquipBox.SoldierList.getItem(p_index);
					m_isBag=true;
					if(m_stageIndex==3)
					{
						createStrongEquip();
						if(m_selectHeroEquip!=null)
						{
							m_EquipTips = ItemTipManager.getTips(this.m_selectItemData,m_selectHeroEquip,l_heroVo);
							m_selectTips=true;
						}
						else
						{
							m_EquipTips = ItemTipManager.getTips(this.m_selectItemData,null,l_heroVo);
							m_selectTips=true;
						}
						
						if(m_EquipTips!=null)
						{
							m_EquipTips.visible=true;
						}
						
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					else
					{
						if(view.WashBox.WashPropertyList.array!=null&&view.WashBox.WashPropertyList.array!=undefined)
						{
							for(var i:int=0;i<view.WashBox.WashPropertyList.array.length;i++)
							{
								var _l_cell:WashPropertyCell=view.WashBox.WashPropertyList.getCell(i);
								_l_cell.relaseLockType();
							}
						}
						m_washPropertyList=[null,null,null];
						initWashUI();
					}
				}
			}
		}
		
		/**
		 * 切换
		 */
		private function setStage(p_stage:int):void
		{
//			if(p_stage!=m_stageIndex)
//			{
				m_stageIndex=p_stage;
				switch(m_stageIndex)
				{
					case 1:
						this.view.PlayerInfoBox.visible=true;		
						this.view.EquipBox.visible=true;
						this.view.ResolveInfo.visible=false;
						this.view.ResolveBag.visible=false;
						this.view.WashEquipBox.visible=false;
						this.view.WashBox.visible=false;
						this.view.EquipMentFBBtn.visible=true;
						this.view.BtnBox.visible=false;
						this.view.ReturnImage.skin="equip/icon_1.png";
						this.view.BgImage.skin="equip/bg1.png";
						this.view.BattleBtn.visible=true;
						break;
					case 2:
						this.view.ResolveBag.visible=true;
						this.view.ResolveInfo.visible=true;
						this.view.PlayerInfoBox.visible=false;		
						this.view.EquipBox.visible=false;
						this.view.WashEquipBox.visible=false;
						this.view.WashBox.visible=false;
						this.view.EquipMentFBBtn.visible=false;
						this.view.BtnBox.visible=true;
						this.view.ReturnImage.skin="equip/icon_2.png";
						this.view.BgImage.skin="equip/bg1_1.png";
						this.view.BattleBtn.visible=true;
						this.view.WashBtn.selected=false;
						this.view.StrengBtn.selected=false;
						this.view.RefreshBtn.selected=true;
						createResolveUI();
						break;
					case 3:
						this.view.ResolveBag.visible=false;
						this.view.ResolveInfo.visible=false;
						this.view.PlayerInfoBox.visible=false;		
						this.view.EquipBox.visible=false;
						this.view.WashEquipBox.visible=true;
						this.view.WashBox.visible=true;
						this.view.BtnBox.visible=true;
						this.view.EquipMentFBBtn.visible=false;
						this.view.BgImage.skin="equip/bg1_1.png";
						this.view.ReturnImage.skin="equip/icon_2.png";
						this.view.BattleBtn.visible=true;
						this.view.WashBtn.selected=false;
						this.view.StrengBtn.selected=true;
						this.view.RefreshBtn.selected=false;
						if(view.WashBox.WashPropertyList.array!=null&&view.WashBox.WashPropertyList.array!=undefined)
						{
							for(var i:int=0;i<view.WashBox.WashPropertyList.array.length;i++)
							{
								var l_cell:WashPropertyCell=view.WashBox.WashPropertyList.getCell(i);
								l_cell.relaseLockType();
							}
						}
						this.view.ReturnImage.skin="equip/icon_2.png";
						createStrongEquip();
						initWashEquipBox();
						
						m_washEquipBox.update(m_equipmentBaseVo);
						break;
					case 4:
						this.view.ResolveBag.visible=false;
						this.view.ResolveInfo.visible=false;
						this.view.PlayerInfoBox.visible=false;		
						this.view.EquipBox.visible=false;
						this.view.WashEquipBox.visible=true;
						this.view.WashBox.visible=true;
						this.view.BtnBox.visible=true;
						this.view.WashBtn.selected=true;
						this.view.StrengBtn.selected=false;
						this.view.RefreshBtn.selected=false;
						this.view.EquipMentFBBtn.visible=false;
						this.view.ReturnImage.skin="equip/icon_2.png";
						this.view.BgImage.skin="equip/bg1_1.png";
						this.view.BattleBtn.visible=true;
						if(view.WashBox.WashPropertyList.array!=null&&view.WashBox.WashPropertyList.array!=undefined)
						{
							for(var i:int=0;i<view.WashBox.WashPropertyList.array.length;i++)
							{
								var l_cell:WashPropertyCell=view.WashBox.WashPropertyList.getCell(i);
								l_cell.relaseLockType();
							}
						}
						m_washPropertyList=[null,null,null];
						initWashUI();
						break;
				}
//			}
		}
		
		//洗练
		private function initWashUI():void
		{
			m_equipStrongView=new EquipStrongView(this.view.WashBox,m_selectStrongEquip,2,m_isBag);
			this.view.WashBox.WashPropertyList.selectHandler=new Handler(this,selectPropertyHandler);	
		}
		
		/**
		 * 
		 * @param p_index
		 * 
		 */		
		private function selectPropertyHandler(p_index:int):void
		{
			var l_cell:WashPropertyCell=this.view.WashBox.WashPropertyList.getCell(p_index);
			if(l_cell!=null)
			{
				var l_str:String=getWashLock();

				if(l_str=="")
				{
					m_equipStrongView.setWashCost(0);
					m_washPropertyList[p_index]=l_cell.setLock();
					this.view.WashBox.WashPropertyList.selectedIndex=-1;
				}
				else if(l_str.split("-").length==2)
				{
					m_equipStrongView.setWashCost(2);
					if(m_washPropertyList[p_index]!=null)
					{
						m_washPropertyList[p_index]=l_cell.setLock();
						this.view.WashBox.WashPropertyList.selectedIndex=-1;
					}
					else
					{
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_48051"),1,function(v:uint):void{
							if(v == AlertType.RETURN_YES)
							{
								
							}
						});
					}
				}
				else if(l_str.split("-").length==1)
				{
					m_equipStrongView.setWashCost(1);
					m_washPropertyList[p_index]=l_cell.setLock();
					this.view.WashBox.WashPropertyList.selectedIndex=-1;
				}
				l_str=getWashLock();
				if(l_str=="")
				{
					m_equipStrongView.setWashCost(0);
				}
				else if(l_str.split("-").length==2)
				{
					m_equipStrongView.setWashCost(2);
				}
				else
				{
					m_equipStrongView.setWashCost(1);
				}
			}
		}
		
		//分解
		private function createResolveUI():void
		{
			// TODO Auto Generated method stub
			m_resolveEquipList=BagManager.instance.getItemListByType([10],[1,2,3,4,5,6]);
			m_resolveBagView=new ResolveBagView(this.view.ResolveBag);
			updateListGray();
			m_resolveList = new Array();
			m_resolveInfoView=new ResolveInfoView(this.view.ResolveInfo,m_resolveList);
			this.view.ResolveBag.BagItemList.selectEnable = true;
			this.view.ResolveBag.BagItemList.selectHandler = new Handler(this, onSelect);
			this.view.ResolveInfo.ResolveItemCellList.selectHandler=new Handler(this,selectResolveCellHandler);
		}
		
		public function updateListGray():void
		{
			for (var i:int = 0; i < view.ResolveBag.BagItemList.array.length; i++) 
			{
				var cell:EquipBagCell=view.ResolveBag.BagItemList.getCell(i);
				if(cell!=null)
				{
					cell.gray=false;
				}
			}
		}
		
		/**
		 * 
		 */
		private function selectResolveCellHandler(p_index:int):void
		{
			var l_item=this.view.ResolveInfo.ResolveItemCellList.getItem(p_index)
			if(l_item!=null)
			{
				if(m_resolveList.length>1)
				{
					m_resolveList.splice(p_index,1);
				}
				else
				{
					m_resolveList=new Array();
				}
				for (var i:int = 0; i < view.ResolveBag.BagItemList.length; i++) 
				{
					var l_cell:EquipBagCell=view.ResolveBag.BagItemList.getCell(i) as EquipBagCell;
					var l_data:ItemData=view.ResolveBag.BagItemList.getItem(i) as ItemData;
					if(l_data.key==l_item.key &&l_cell!=null)
					{
						l_cell.gray=false;
					}
				}
				m_isQuickResolve=false;
				m_resolveInfoView.updateList(m_resolveList);
				m_resolveBagView.updateList(m_resolveEquipList);
				this.view.ResolveInfo.ResolveItemCellList.selectedIndex=-1;
			}
		}
		
		//英雄信息
		private function createPlayerInfo():void
		{
			if(m_EquipPlayerInfo!=null&&m_EquipPlayerInfo!=undefined)
			{
				m_EquipPlayerInfo.setSultInfo(false);
			}
			if(m_EquipPlayerInfo==null)
			{
				m_EquipPlayerInfo=new EquipPlayerInfo(this.view.PlayerInfoBox,m_heroData);
			}
			m_EquipPlayerInfo.update(m_heroData);
			
			var l_heroVo:HeroEquipVo=m_equipmentBaseVo.getSelectHero(m_heroData.unitId);
			m_EquipPlayerInfo.setEquipAddProperty(l_heroVo);
			for (var i:int = 1; i < 7; i++) 
			{
				var l_cell:EquipCellUI=this.view.PlayerInfoBox.getChildByName("EquipCell"+i) as EquipCellUI;
				var l_image:Image=this.view.PlayerInfoBox.PlayerEquipImage.getChildByName("EquipImage"+i) as Image;
				l_cell.visible=false;
				l_image.visible=true;
			}
			if(l_heroVo!=null)
			{
				for (var i:int = 0; i < l_heroVo.equipList.length; i++) 
				{
					var l_equip:EquipInfoVo=l_heroVo.equipList[i];
					var l_cell:EquipCellUI=this.view.PlayerInfoBox.getChildByName("EquipCell"+l_equip.location) as EquipCellUI;
					var l_image:Image=this.view.PlayerInfoBox.PlayerEquipImage.getChildByName("EquipImage"+l_equip.location) as Image;
					l_cell.visible=true;
					l_cell.mouseEnabled=l_cell.mouseThrough=true;
					var l_item:EquipCell=new EquipCell(l_cell,l_equip);
					l_image.visible=false;
				}
			}
			createEquipList();
		}
		
		/**
		 * 强化装备
		 * */
		private function createStrongEquip():void
		{
			m_equipStrongView=new EquipStrongView(this.view.WashBox,m_selectStrongEquip,1,m_isBag);
		}
		/**
		 * 强化装备列表
		 */
		private function initWashEquipBox():void
		{
			if(m_washEquipBox==null)
			{
				m_washEquipBox=new WashBagView(this.view.WashEquipBox,m_equipmentBaseVo);
			}
//			this.view.WashEquipBox.HeroList.selectHandler=new Handler(this, onSelect);
			this.view.WashEquipBox.SoldierList.selectHandler=new Handler(this, onSelect);
		}
		
		
		/**
		 * 监听
		 */
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_EQUIPINFO),this,onResult,[ServiceConst.EQUIP_EQUIPINFO]);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,baginit,[BagEvent.BAG_EVENT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult,[ServiceConst.C_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ADD_ITEM),this,onResult,[ServiceConst.ADD_ITEM]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_WEAR),this,onResult,[ServiceConst.EQUIP_WEAR]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_UNWEAR),this,onResult,[ServiceConst.EQUIP_UNWEAR]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_STRONG),this,onResult,[ServiceConst.EQUIP_STRONG]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_RESOLVE),this,onResult,[ServiceConst.EQUIP_RESOLVE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_QUICKRESOLVE),this,onResult,[ServiceConst.EQUIP_QUICKRESOLVE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_WASH),this,onResult,[ServiceConst.EQUIP_WASH]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EQUIP_SAVEWASH),this,onResult,[ServiceConst.EQUIP_SAVEWASH]);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE,this,onBagChange);
			Signal.intance.on(EquipEvent.EQUIP_EVENT_CLICK,this,onSelectHeroCell);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		public function baginit():void
		{
			createEquipList();	
		}
		
		/**
		 * 按键事件
		 */
		private function onClickHander(e:Event):void
		{
			switch(e.target)
			{
				case this.view.BattleBtn:
					if(m_stageIndex==4&&m_isWashTips==true)
					{
						WashTipsWin(1);
						return;
					}
					if(m_stageIndex>1)
					{
						m_selectStrongEquip=null;
						setStage(1);
						createPlayerInfo();
					}
					else
					{
						m_selectStrongEquip=null;
						setStage(3);
					}
					break;
				case this.view.StrengBtn:
					var l_arr:Array=GameConfigManager.equipParamVo.getOpenStrongLevel();
					if(isOpenModule(l_arr,1))
					{
						this.view.WashBtn.selected=false;
						this.view.StrengBtn.selected=true;
						this.view.RefreshBtn.selected=false;
						setStage(3);
					}
					
					break;
				case this.view.CloseBtn:
					if(m_stageIndex==4&&m_isWashTips==true)
					{
						WashTipsWin(0);
						return;
					}
					
					if(m_stageIndex==1)
					{
						this.close();
						return;
					}
					else
					{
						setStage(1);
						createPlayerInfo();
					}
					break;
				case this.view.WashBox.EnhanceBtn:				
					if(isEquipStrength(1))
					{
						if(m_isBag)
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_STRONG,[m_selectItemData.key,"","",1]);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_STRONG,["",m_heroData.unitId,m_selectLocal,1]);
						}
					}
					
					break;
				case this.view.WashBox.Time5EnhanceBtn:
					if(isEquipStrength(5))
					{
						if(m_isBag)
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_STRONG,[m_selectItemData.key,"","",5]);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_STRONG,["",m_heroData.unitId,m_selectLocal,5]);
						}
					}
					break;
				case this.view.WashEquipBox.SoldierBtn:
					m_washPageType=2;
					this.m_washEquipBox.setType(2);
					break;
				case this.view.WashEquipBox.HeroBtn:
					m_washPageType=1;
					this.m_washEquipBox.setType(1);
					break;
				case this.view.ResolveInfo.DecompositionBtn:
					ResolveTips();
					break;
				case this.view.ResolveInfo.AutoDecompBtn:
					this.view.EquipSelectQuality.visible=true;
					break;
				case this.view.EquipSelectQuality.QualityBtn0:
					this.view.EquipSelectQuality.GouImage0.visible=!this.view.EquipSelectQuality.GouImage0.visible;
					break;
				case this.view.EquipSelectQuality.QualityBtn1:
					this.view.EquipSelectQuality.GouImage1.visible=!this.view.EquipSelectQuality.GouImage1.visible;
					break;
				case this.view.EquipSelectQuality.QualityBtn2:
					this.view.EquipSelectQuality.GouImage2.visible=!this.view.EquipSelectQuality.GouImage2.visible;
					break;
				case this.view.EquipSelectQuality.QualityBtn3:
					this.view.EquipSelectQuality.GouImage3.visible=!this.view.EquipSelectQuality.GouImage3.visible;
					break;
				case this.view.EquipSelectQuality.QualityBtn4:
					this.view.EquipSelectQuality.GouImage4.visible=!this.view.EquipSelectQuality.GouImage4.visible;
					break;
				case this.view.EquipSelectQuality.QualityBtn5:
					this.view.EquipSelectQuality.GouImage5.visible=!this.view.EquipSelectQuality.GouImage5.visible;
					break;
				case this.view.EquipSelectQuality.CloseBtn:
					this.view.EquipSelectQuality.visible=false;
					break;
				case this.view.EquipSelectQuality.ConfirmBtn:
					quickResolve();
					this.view.EquipSelectQuality.visible=false;
					break;
				case this.view.RefreshBtn:
					var l_arr:Array=GameConfigManager.equipParamVo.getOpenResolveLevel();
					m_selectStrongEquip=null;
					if(isOpenModule(l_arr,1))
					{
						this.view.WashBtn.selected=false;
						this.view.StrengBtn.selected=false;
						this.view.RefreshBtn.selected=true;
						setStage(2);
					}
					break;
				case this.view.WashBtn:
					var l_arr:Array=GameConfigManager.equipParamVo.getOpenWashLevel();
					if(isOpenModule(l_arr,1))
					{
						this.view.WashBtn.selected=true;
						this.view.StrengBtn.selected=false;
						this.view.RefreshBtn.selected=false;
						setStage(4);
					}
					break;
				case this.view.WashBox.RefreshBtn:
					var l_str:String=getWashLock();
					if(isEquipCanWash())
					{
						if(m_isBag)
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_WASH,[m_selectItemData.key,"","",l_str]);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_WASH,["",m_heroData.unitId,m_selectLocal,l_str]);
						}
					}	
					break;
				case this.view.WashBox.RetainBtn:
					WebSocketNetService.instance.sendData(ServiceConst.EQUIP_SAVEWASH,[]);
					break;
				case this.view.PlayerInfoBox.SuitEquipTipsBtn:
					m_showSultInfo=!m_showSultInfo;
					m_EquipPlayerInfo.setSultInfo(m_showSultInfo);
					break;
				case this.view.ResolveReward.CloseBtn:
					this.view.ResolveReward.visible=false;
					break;
				case this.view.ResolveReward.ConfirmBtn:
					this.view.ResolveReward.visible=false;
					break;
				case this.view.EquipMentFBBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,2]);
					close();
					var bagPanel:BagPanel = XFacade.instance.getView(BagPanel);
					bagPanel && bagPanel.close();
					
					break;
				case this.view.WashBox.HasImage:
					ItemTips.showTip("10000");
					break;
				default:
				{
					if(e.target.name=="nowStrengBtn")
					{
						var l_arr:Array=GameConfigManager.equipParamVo.getOpenStrongLevel();
						if(isOpenModule(l_arr,1))
						{
							m_isBag=false;
							m_selectStrongEquip=m_selectHeroEquip;
							setStage(3);
							closeTips();
						}
						
					}
					else if(e.target.name=="itemStrengBtn")
					{
						var l_arr:Array=GameConfigManager.equipParamVo.getOpenStrongLevel();
						if(isOpenModule(l_arr,1))
						{
							m_isBag=true;
							m_selectStrongEquip=m_selectItemData;
							setStage(3);
							closeTips();
						}
					}
					else if(e.target.name=="nowEquipBtn")
					{
						this.m_EquipTips.visible=false;
						WebSocketNetService.instance.sendData(ServiceConst.EQUIP_UNWEAR,[m_heroData.unitId,m_selectLocal]);
						closeTips();
					}
					else if(e.target.name=="itemEquipBtn")
					{
						this.m_EquipTips.visible=false;
						var l_equipListVo:EquipmentListVo=getEquipInfo();
						closeTips();
						WebSocketNetService.instance.sendData(ServiceConst.EQUIP_WEAR,[m_selectItemData.key,m_heroData.unitId,l_equipListVo.location]);
					}
					if(m_stageIndex==3 || m_stageIndex==4)
					{
						if(e.target.parent.name.indexOf("EquipCell_")!=-1)
						{
							var l_str:String=e.target.parent.name;
							var l_arr:Array=l_str.split("_");
							
							m_washEquipStr=e.target.parent.name;
							m_heroData=m_equipmentBaseVo.getSelectHero(l_arr[1]).data;
							if(l_arr.length>0)
							{
								m_isBag=false;
								var data:Object=getPlayerEquipInfo(parseInt(l_arr[2])+1);
								if(data!=null)
								{
									if(m_stageIndex==4&&m_isWashTips==true)
									{
										WashTipsWin(3);
										return;
									}
									m_washPropertyList=[null,null,null];
									m_selectStrongEquip=data;
									m_selectHeroEquip=data;
									m_selectLocal=parseInt(l_arr[2])+1;
									m_washEquipBox.selectHeroEquipCell(l_arr[1],l_arr[2]);
									for (var i:int = 0; i < this.view.WashEquipBox.SoldierList.length; i++) 
									{
										var l_cell:EquipBagCell=this.view.WashEquipBox.SoldierList.getCell(i);
										if(l_cell!=null)
										{
											l_cell.selected=false;
										}
									}
									if(m_stageIndex==3)
									{
										createStrongEquip();
									}
									else
									{
										if(view.WashBox.WashPropertyList.array!=null&&view.WashBox.WashPropertyList.array!=undefined)
										{
											for(var i:int=0;i<view.WashBox.WashPropertyList.array.length;i++)
											{
												var _l_cell:WashPropertyCell=view.WashBox.WashPropertyList.getCell(i);
												_l_cell.relaseLockType();
											}
										}
										m_washPropertyList=[null,null,null];
										initWashUI();
									}
								}
							}
						}	
					}
				}
			}
			if(m_heroData!=null)
			{
				var l_heroVo:HeroEquipVo=m_equipmentBaseVo.getSelectHero(m_heroData.unitId);
				if(l_heroVo!=null)
				{
					l_heroVo.level=m_heroData.level;
				}
			}
			
			switch(e.target.parent)
			{
				case this.view.PlayerInfoBox.EquipCell1:
					m_selectHeroEquip=getPlayerEquipInfo(1);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=1;
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
//						this.view.NowEquipTip.visible=true;
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
				case this.view.PlayerInfoBox.EquipCell2:
					m_selectHeroEquip=getPlayerEquipInfo(2);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=2;
						
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
//						this.view.NowEquipTip.visible=true;
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
				case this.view.PlayerInfoBox.EquipCell3:
					m_selectHeroEquip=getPlayerEquipInfo(3);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=3;
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
//						this.view.NowEquipTip.visible=true;
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
				case this.view.PlayerInfoBox.EquipCell4:
					m_selectHeroEquip=getPlayerEquipInfo(4);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=4;
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
				case this.view.WashBox.SelectEquipCell:
					if(m_selectStrongEquip!=null)
					{
						var level:int;
						if(m_isBag==false)
						{
							m_EquipTips = ItemTipManager.getTips(null,m_selectStrongEquip);
							m_selectTips=true;
						}
						else
						{
							m_EquipTips = ItemTipManager.getTips(this.m_selectStrongEquip);
							m_selectTips=true;
						}
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
						this.m_EquipTips.visible=true;
					}
					break;
				case this.view.PlayerInfoBox.EquipCell5:
					m_selectHeroEquip=getPlayerEquipInfo(5);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=5;
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
						
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
				case this.view.PlayerInfoBox.EquipCell6:
					m_selectHeroEquip=getPlayerEquipInfo(6);
					m_selectTips=true;
					if(m_selectHeroEquip!=null)
					{
						m_selectLocal=6;
						m_EquipTips = ItemTipManager.getTips(null,m_selectHeroEquip,l_heroVo);
						this.m_EquipTips.visible=true;
						if(m_isAddTips==false)
						{
							m_isAddTips=true;
							this.addChild(m_EquipTips);	
						}
					}
					break;
			}
			if(e.target.name=="equipTips")
			{
				m_selectTips=true;
			}
			if(m_selectTips==false)
			{
				closeTips();
			}
			m_selectTips=false;
			// TODO Auto Generated method stub
		}
		
		private function isEquipCanWash():Boolean
		{
			// TODO Auto Generated method stub
			var l_washEquip:EquipmentBaptizeVo;
			var l_id:int=0;
			if(m_isBag)
			{
				if(m_selectItemData!=null)
				{
					l_id=m_selectItemData.iid;
				}
			}
			else
			{
				var l_equipVo:EquipInfoVo=getPlayerEquipInfo(m_selectLocal);
				if(l_equipVo!=null)
				{
					l_id=l_equipVo.equip_item_id;
				}
			}
			if(l_id!=0)
			{
				l_washEquip=m_equipmentBaseVo.getEquipWash(l_id);
				if(l_washEquip==null)
				{
					return false;
				}
				var l_str:String=getWashLock();
				var l_arr:Array;
				if(l_str=="")
				{
					l_arr=l_washEquip.getCost(0);
				}
				else if(l_str.split("-").length==2)
				{
					l_arr=l_washEquip.getCost(2);
				}
				else
				{
					l_arr=l_washEquip.getCost(1);
				}
				for (var i:int = 0; i < l_arr.length; i++) 
				{
					var itemData:ItemData=l_arr[i];
					var max:int=BagManager.instance.getItemNumByID(itemData.iid);
					if(itemData.inum>max)
					{
						var itemVo:ItemVo=GameConfigManager.items_dic[itemData.iid];
						XTip.showTip(StringUtil.substitute(GameLanguage.getLangByKey("L_A_48054"),GameLanguage.getLangByKey(itemVo.name)));
						return false;
					}
				}
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function isEquipStrength(p_type:int):Boolean
		{
			// TODO Auto Generated method stub
			var level:int;
			var l_strengthArr:Array=new Array();
			if(m_isBag)
			{
				if(m_selectItemData!=null)
				{
					if(m_selectItemData.exPro.strong_level==undefined)
					{
						level=0;
					}
					else
					{
						level=m_selectItemData.exPro.strong_level;
					}
					l_strengthArr=m_equipmentBaseVo.getStrengthArr(m_selectItemData.iid,level);
				}
			}
			else
			{
				if(m_heroData!=null)
				{
					var l_equipVo:EquipInfoVo=getPlayerEquipInfo(m_selectLocal);
					if(l_equipVo!=null)
					{
						l_strengthArr=m_equipmentBaseVo.getStrengthArr(l_equipVo.equip_item_id,l_equipVo.strong_level);
					}
				}
			}
			if(l_strengthArr.length==2)
			{
				var itemData:ItemData=l_strengthArr[0];
				if(p_type==1)
				{
					itemData=l_strengthArr[0];
				}
				else
				{
					itemData=l_strengthArr[1];
				}
				var max:int=BagManager.instance.getItemNumByID(itemData.iid);
				if(itemData.inum>max)
				{
					var itemVo:ItemVo=GameConfigManager.items_dic[itemData.iid];
					XTip.showTip(StringUtil.substitute(GameLanguage.getLangByKey("L_A_48054"),GameLanguage.getLangByKey(itemVo.name)));
					return false;
				}
				return true;
			}
			else
			{
				return false;
			}
		
		}
		
		private function isOpenModule(p_arr:Array,p_type:int):Boolean
		{
			// TODO Auto Generated method stub
			if(User.getInstance().level>=parseInt(p_arr[1]))
			{
				return true;
			}
			if(p_type==1)
			{
				XTip.showTip(StringUtil.substitute(GameLanguage.getLangByKey("L_A_48055"),p_arr[1]));	
			}
			return false;
		}
		
		private function quickResolve():void
		{
			m_quickResolveStr="";
			m_isQuickResolve=true;
			var l_arr:Array=new Array();
			for (var i:int = 0; i < 6; i++) 
			{
				var l_image:Image= this.view.EquipSelectQuality.getChildByName("GouImage"+i) as Image;
				if(l_image.visible==true)
				{
					if(m_quickResolveStr=="")
					{
						m_quickResolveStr=(parseInt(i)+1);
					}
					else
					{
						m_quickResolveStr+="-"+(parseInt(i)+1);
					}
					var quality=parseInt(i)+1;
					for (var j:int = 0; j < this.view.ResolveBag.BagItemList.length; j++) 
					{
						var l_itemdata:ItemData=this.view.ResolveBag.BagItemList.getItem(j);
						var l_cell:EquipBagCell=this.view.ResolveBag.BagItemList.getCell(j);
						if(l_itemdata!=null)
						{
							if(quality==l_itemdata.vo.quality &&l_cell!=null)
							{
								l_arr.push(l_itemdata);
								l_cell.gray=true;
							}
						}
					}
				}
			}
			m_resolveList=l_arr;
			m_resolveBagView.updateList(m_resolveEquipList);
			m_resolveInfoView.updateList(m_resolveList);
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			m_isadd=false;
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_EQUIPINFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ADD_ITEM),this,onResult);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT,this,baginit);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_WEAR),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_UNWEAR),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_STRONG),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_RESOLVE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_QUICKRESOLVE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_WASH),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EQUIP_SAVEWASH),this,onResult);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE,this,onBagChange);
			Signal.intance.off(EquipEvent.EQUIP_EVENT_CLICK,this,onSelectHeroCell);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		private function onSelectHeroCell(p_data:HeroEquipVo)
		{
			if(p_data!=null)
			{
				m_heroData=p_data.data;
				m_washEquipBox.createPanel();
			}
		}
		
		
		private function onBagChange():void
		{
			createEquipList();
			var l_str:String=getWashLock();
			if(m_equipStrongView)
			{
				if(l_str=="")
				{
					m_equipStrongView.setWashCost(0);
				}
				else if(l_str.split("-").length==2)
				{
					m_equipStrongView.setWashCost(2);
				}
				else
				{
					m_equipStrongView.setWashCost(1);
				}
			}
		}
		
		/**
		 * 接受服务器消息
		 */
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.EQUIP_EQUIPINFO:
					var l_info:Object=args[1];
					m_equipmentBaseVo.setheroList(l_info,m_heroList);
					this.view.HeroList.array=m_heroList;
					onHeroSelect(0);
					setStage(m_stageIndex);
					break;
				case ServiceConst.C_INFO:
					var l_c_info:Object=args[1];
					var fvo:Object
					var srcList:Array;//静态数据源
					var soList:Array;
					srcList = GameConfigManager.getUnitList(FightUnitVo.HERO);
					m_heroList.splice(0,m_heroList.length);
					for(var m:int=0; m<srcList.length; m++){
						//如果在返回数据中
						fvo = srcList[m];
						if(l_c_info.hero_list[fvo.unit_id+""]){
							m_heroList.push(l_c_info.hero_list[fvo.unit_id+""]);
						}
					}
					this.view.HeroList.refresh();
					if(m_isfrist==true)
					{
						m_isfrist=false;
						WebSocketNetService.instance.sendData(ServiceConst.EQUIP_EQUIPINFO,[]);
					}
					else
					{
						onHeroSelect(m_selectHeroIndex);
					}
					DataLoading.instance.close();
					break;
				case ServiceConst.EQUIP_WEAR:
				case ServiceConst.EQUIP_UNWEAR:
					var l_info:Object=args[1];
					m_equipmentBaseVo.updateHeroList(l_info,m_heroList);
					WebSocketNetService.instance.sendData(ServiceConst.C_INFO,[]);
					createPlayerInfo();
					createEquipList();
					break
				case ServiceConst.EQUIP_STRONG:
					var l_info:Object=args[1];
					if(m_isBag==false)
					{
						m_equipmentBaseVo.updateHeroList(l_info,m_heroList);
						m_selectStrongEquip=getPlayerEquipInfo(m_selectLocal);
						createStrongEquip();
					}
					else
					{
						m_selectItemData.exPro=l_info[m_selectItemData.key][2];
						m_selectStrongEquip=m_selectItemData;
						createStrongEquip();
					}
					m_washEquipBox.update(m_equipmentBaseVo);
//					setEquipStrongEffect();
					break;
				case ServiceConst.EQUIP_RESOLVE:
				case ServiceConst.EQUIP_QUICKRESOLVE:
					var l_info:Object=args[1];
					var l_arr:Array=new Array();
					for(var i:int=0;i<l_info.length;i++)
					{
						var l_itemdata:ItemData=new ItemData();
						l_itemdata.iid=l_info[i][0];
						l_itemdata.inum=l_info[i][1];
						l_arr.push(l_itemdata);
					}
					createResolveUI();
					this.view.ResolveReward.visible=true;
					m_resolveReward=new ResolveRewardView(l_arr,view.ResolveReward);
					this.m_resolveInfoView.setReward(null);
					break;
				case ServiceConst.EQUIP_WASH:
					var l_info:Object=args[1];
					m_isWashTips=true;
					this.m_equipStrongView.setWashChangeProperty(l_info,m_washPropertyList);
					setEquipWashEffect();
					break;
				case ServiceConst.EQUIP_SAVEWASH:
					var l_info:Object=args[1];
					m_isWashTips=false;
					if(m_isBag==false)
					{
						m_equipmentBaseVo.updateHeroList(l_info,m_heroList);
						m_selectStrongEquip=getPlayerEquipInfo(m_selectLocal);
						m_equipStrongView.saveWashInfo()
						//initWashUI();
					}
					else
					{
						m_selectItemData.exPro=l_info[2];
						m_selectStrongEquip=m_selectItemData;
						m_equipStrongView.saveWashInfo()
						//initWashUI();
					}
					onBagChange();
					break;
			}
		}
		
		private function closeTips():void
		{
			if(m_EquipTips!=null)
			{
				m_EquipTips.visible=false;
			}
		}
		
		/**
		 * 
		 */
		private function getEquipInfo():EquipmentListVo
		{
			for each (var j:EquipmentListVo in GameConfigManager.EquipmentList) 
			{
				if(j.equip==m_selectItemData.iid)
				{
					return j;	
				}
			}			
			return null;
		}
		
		/**
		 * 
		 */
		private function getPlayerEquipInfo(p_local:int):EquipInfoVo
		{
			var l_heroVo:HeroEquipVo=m_equipmentBaseVo.getSelectHero(m_heroData.unitId);
			if(l_heroVo!=null)
			{
				for (var i:int = 0; i < l_heroVo.equipList.length; i++) 
				{
					var l_equip:EquipInfoVo=l_heroVo.equipList[i];
					if(p_local==l_equip.location)
					{
						return l_equip;
					}
				}
			}
			return null;
		}
		
		private function getWashLock():String
		{
			var l_str:String="";
			var l_num:int=0;
			for (var i:int=0; i< m_washPropertyList.length;i++) 
			{
				if(m_washPropertyList[i]!=null)
				{
					if(l_num==0)
					{
						l_str=m_washPropertyList[i].name;
						l_num=1;
					}
					else
					{
						l_str+="-"+m_washPropertyList[i].name;
					}
				}
			}
			return l_str;
		}
		
		private function WashTipsWin(p_type:int=0):void
		{
			if(m_isWashWinShow==false)
			{
				m_isWashWinShow=true;
				if(m_isWashTips==true)
				{
					m_washWinType=p_type;
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_48049"),0,function(v:uint):void{
						if(v == AlertType.RETURN_YES)
						{
							m_isWashTips=false;
							m_isWashWinShow=false;
							if(m_washWinType==0)
							{
								closeWin();
							}
							else if(m_washWinType==1)
							{
								setStage(1);
								createPlayerInfo();
							}
							else if(m_washWinType==2)
							{
								testWin();
							}
							else if(m_washWinType==3)
							{
								var l_arr:Array=m_washEquipStr.split("_");
								m_washPropertyList=[null,null,null];
								if(l_arr.length>0)
								{
									m_isBag=false;
									var data:Object=getPlayerEquipInfo(parseInt(l_arr[2])+1);
									if(data!=null)
									{
										m_selectStrongEquip=data;
										m_selectHeroEquip=data;
										m_selectLocal=parseInt(l_arr[2])+1;
										if(m_stageIndex==3)
										{
											createStrongEquip();
										}
										else
										{
											if(view.WashBox.WashPropertyList.array!=null&&view.WashBox.WashPropertyList.array!=undefined)
											{
												for(var i:int=0;i<view.WashBox.WashPropertyList.array.length;i++)
												{
													var l_cell:WashPropertyCell=view.WashBox.WashPropertyList.getCell(i);
													l_cell.relaseLockType();
												}
											}
											m_washPropertyList=[null,null,null];
											initWashUI();
										}
									}
								}
							}
						}
						else
						{
							m_isWashWinShow=false;
						}
					});
				}
			}
		}
		
		private function testWin()
		{
			m_selectItemData=m_selectWashEquip;
			this.m_selectStrongEquip=m_selectWashEquip;
			m_isBag=true;
			if(m_stageIndex==3)
			{
				createStrongEquip();
			}
			else
			{
				m_washPropertyList=[null,null,null];
				initWashUI();
			}
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		private function closeWin()
		{
			setStage(1);
			createPlayerInfo();
		}
		
		/**
		 * 
		 * 
		 */		
		private function ResolveTips():void
		{
			var l_str="";
			for (var i:int = 0; i < m_resolveList.length; i++) 
			{
				if(i==m_resolveList.length-1)
				{
					l_str+=m_resolveList[i].key;
				}
				else
				{
					l_str+=m_resolveList[i].key+"-";
				}
			}
			var isresolve:Boolean=false;
			for (var i:int = 0; i < m_resolveList.length; i++) 
			{
				var l_item:ItemData=m_resolveList[i];
				if(l_item.vo.quality>=4)
				{
					isresolve=true;
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_48029"),0,function(v:uint):void{
						if(v == AlertType.RETURN_YES)
						{
							WebSocketNetService.instance.sendData(ServiceConst.EQUIP_RESOLVE,[l_str]);
						}
						else
						{
						}
					});
				}
			}
			if(isresolve==false)
			{
				WebSocketNetService.instance.sendData(ServiceConst.EQUIP_RESOLVE,[l_str]);	
			}
		}

		
		private function setEquipStrongEffect():void
		{
			if(m_equipStrongEffect==null)
			{
				m_equipStrongEffect=new Animation();
				var jsonStr:String = "appRes/atlas/effects/equipStrong.json";	
				m_equipStrongEffect.loadAtlas(jsonStr);
				this.view.addChild(m_equipStrongEffect);
				m_equipStrongEffect.x=182;
				m_equipStrongEffect.y=100;
			}
			m_equipStrongEffect.visible=true;
			m_equipStrongEffect.play(0,false);
			
			m_equipStrongEffect.once(Event.COMPLETE,this,onCompleteHandler,[m_equipStrongEffect]);
		}
		
		private function onCompleteHandler(...arg):void
		{
			// TODO Auto Generated method stub
			var l_ani:Animation=arg[0] as Animation;
			l_ani.visible=false;
		}
		
		private function setEquipWashEffect():void
		{
			if(m_equipWashEffect==null)
			{
				m_equipWashEffect=new Animation();
				var jsonStr:String = "appRes/atlas/effects/equipWash.json";	
				m_equipWashEffect.loadAtlas(jsonStr);
				this.view.addChild(m_equipWashEffect);
				m_equipWashEffect.x=160;
				m_equipWashEffect.y=80;
			}
			m_equipWashEffect.visible=true;
			m_equipWashEffect.play(0,false);
			
			m_equipWashEffect.once(Event.COMPLETE,this,onCompleteHandler,[m_equipWashEffect]);
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function onClose():void{
			if(m_equipWashEffect!=null)
			{
				m_equipWashEffect.clear();
			}
			if(m_equipStrongEffect!=null)
			{
				m_equipStrongEffect.clear();
			}
			m_equipWashEffect=null;
			m_equipStrongEffect=null;
//			super.close();
		}
		
		
		
		private function get view():EquipMainViewUI
		{
			return _view as EquipMainViewUI;
		}
		
	}
}