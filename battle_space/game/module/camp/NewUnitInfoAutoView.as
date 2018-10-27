package game.module.camp
{
	import MornUI.camp.NewUnitInfoViewUI;
	
	import game.common.List2;
	import game.common.ListPanel;
	import game.common.ResourceManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBUnit;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.module.advance.AdvanceView;
	import game.module.camp.avatar.HeroAvatarCom;
	import game.module.camp.data.JueXingMange;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.view.BaseChapetrView;
	import game.module.mainui.SceneVo;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.List;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class NewUnitInfoAutoView extends BaseChapetrView
	{
		public var autoSelectIndex:uint = 0;
		public var muUi:NewUnitInfoViewUI;
		public var typeList:Array = [0,1,2,3,4,5];  //所有 英雄 重甲 重甲 轻甲 无甲
		public var iconList:Array = [
			"common/buttons/tab_6.png",
			"common/buttons/tab_5.png",
			"common/buttons/tab_2.png",
			"common/buttons/tab_3.png",
			"common/buttons/tab_4.png",
			"common/buttons/tab_1.png",
		];
		public var iconBtnList:Array = [];
		public var selectType:Number = -1;
		public var unitIdList:Array = [];
		private var m_list:List;
		/**右侧tab*/
		private var m_tabList:List;
		private var _listPanel:ListPanel;
		private var _ani:Animation;
		private var _selectAmData:ArmyData;
		
		private var heroSkin:Object = 
		{
			icon:"newUnitInfo/btn_tab2.png"
		}
		public function NewUnitInfoAutoView()
		{
			super();
			
			bgImg.skin = "appRes/fightingMapImg/pvpBg.jpg";
			
			muUi = new NewUnitInfoViewUI();
			contentBox.addChild(muUi);
			muUi.selBtn.text.visible = false;
			var bPBox:Box = muUi.selBtn.parent;
			bPBox.mouseEnabled = bPBox.mouseThrough = true;
			iconBtnList.push(muUi.selBtn);
			var leftN:Number = 60;
			var btnW:Number = 77;
			var btnJg:Number = 8;
			var maxW:Number = 0;
			for (var i:int = 0; i < typeList.length - 1; i++) 
			{
				var btn:Button = new Button();
				iconBtnList.push(btn);
				muUi.typeListCCBox.addChild(btn);
				btn.x = leftN +  i * (btnW + btnJg) ;
				btn.text.visible = false;
				maxW = (btn.x +btnW);
			}
			muUi.typeListBg.width = muUi.typeListBox.width = muUi.typeListCCBox.width  = maxW + 20;
			
			var sp:Sprite = new Sprite();
			sp.cacheAsBitmap = true;
			sp.graphics.drawRect(0,0,muUi.typeListBox.width,muUi.typeListBox.height,"#ffffff");
			muUi.typeListBox.mask = sp;
			sp.mouseEnabled = false;
			muUi.mouseThrough = true;
			
			m_list = new List2();
			m_list.pos( muUi.unitList.x , muUi.unitList.y);
			m_list.size( muUi.unitList.width , muUi.unitList.height);
			
			muUi.unitList.parent.addChildAt(m_list , muUi.unitList.parent.getChildIndex(muUi.unitList));
			muUi.unitList.removeSelf();
			
			m_list.vScrollBarSkin = "common/vscrollBarr.png";
			m_list.selectEnable = true;
			m_list.repeatX = 1;
			m_list.repeatY = 6;
			m_list.itemRender = NewUnitInfoArmyCell;
			m_list.spaceY = 3;
			m_list.array = [];
			m_list.scrollBar.visible = false;
			m_list.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			m_list.scrollBar.elasticDistance = 50;
			
			m_tabList = new List2();
			muUi.tabListBox.addChild(m_tabList);
			muUi.tabListBox.size(84 , muUi.unitListBox.height);
			m_tabList.size(muUi.tabListBox.width , muUi.tabListBox.height);
			
			m_tabList.vScrollBarSkin = "common/vscrollBarr.png";
			m_tabList.selectEnable = true;
			m_tabList.repeatX = 1;
			m_tabList.repeatY = 5;
			m_tabList.itemRender = NewUnitInfoTabCell;
			m_tabList.spaceY = 3;
			
			UIRegisteredMgr.AddUI(m_tabList,"CampTabList");
			
			var _arr = getTabListAr();
			m_tabList.array = _arr;
			m_tabList.scrollBar.visible = false;
			m_tabList.getCell(2).visible = false;
			m_tabList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			m_tabList.scrollBar.elasticDistance = 50;
			

			//trace('tabListAr: ', tabListAr);
		
			_listPanel = new ListPanel([NewUnitInfoOperView, NewUnitJuexingView, AdvanceView, HeroAvatarCom]);
			_listPanel.mouseThrough = true;
			muUi.selectUnitBox.parent.addChildAt(_listPanel,muUi.selectUnitTopBox.parent.getChildIndex(muUi.selectUnitTopBox));
			
			this._ani = new Animation();
			this._ani.pos(muUi.unitFace.x,muUi.unitFace.y + 12);
			this._ani.scale(1.5,1.5);
			muUi.selectUnitBox.addChild(_ani);
			
			for(var key:String in muUi.dom_newInfo){
				if(muUi.dom_newInfo[key] is HTMLDivElement){
					muUi.dom_newInfo[key].style.fontFamily = XFacade.FT_Futura;
					muUi.dom_newInfo[key].style.fontSize = 16;
					muUi.dom_newInfo[key].style.color = "#ffffff";
					muUi.dom_newInfo[key].style.align = "right";
				}
			}
		}
		
		private function show():void {
			
		}
		
		private function seleType(t:Number):void{
			if(selectType != t)
			{
				selectType = t;
				var tList:Array = typeList.concat();
				var idx:Number = tList.indexOf(t);
				tList.splice(idx,1);
				tList.unshift(t);
				
				for (var i:int = 0; i < iconBtnList.length; i++) 
				{
					var btn:Button = iconBtnList[i];
					btn.dataSource = tList[i];
					btn.skin = iconList[tList[i]];
				}
				
				trace("选择列表类型：")
				m_list.array = getUnitByType(t);
				
				bindAmData();
			}
		}
		
		public function refreshList():void
		{
			selectType = -1;
			seleType(0);
		}
		
		private function showMineFightView():void {
			XFacade.instance.closeModule(NewUnitInfoView);
			XFacade.instance.closeModule(CampView);
			
			XFacade.instance.openModule(ModuleName.NewPataView);
		}
		
		private function showPowerTip(e:Event):void
		{
			XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
		}
		
		private function onResult():void{
			if(!selectAmData)return ;
			this._ani.clear();
			if(selectAmData.unitVo.isHero == 1){
				this._ani.loadAtlas("appRes/atlas/effects/heroEffect.json");
			}else{
				this._ani.loadAtlas("appRes/atlas/effects/soliderEffect.json");
			}		
			this._ani.play(1, false);
			unitIdList.sort(ArmyData.armySort);
			bindAmData();
			
			m_list.refresh();
		}
		
		
		private function adiiconclick(e:Event):void
		{
			if(!selectAmData)return ;
			switch(e.target)
			{
				case muUi.attackIcon:
				{
					ProTipUtil.showAttTip(selectAmData.unitId);
					break;
				}
				case muUi.defendIcon:
				{
					ProTipUtil.showDenTip(selectAmData.unitId);
					break;
				}
			}
		}
		
		public function selectUnitById(uid:Number):void
		{
			var ar:Array = m_list.array;
			if(uid)
			{
				for (var i:int = 0; i < ar.length; i++) 
				{
					var amData:ArmyData = ar[i];
					if(amData.unitId == uid)
					{
						selectAmData = amData;
						break;
					}
				}
				
			}else
			{
				selectAmData = ar[0];
			}
			
			bindAmData();
			m_tabList.tweenTo(0);
			m_tabList.selectedIndex = autoSelectIndex;
			autoSelectIndex = 0;
		}
		
		
		private function listMouseHandler(index:int):void
		{
			var ar:Array = m_list.array;
			if(!ar || ar.length <= index)
				return ;
			selectAmData = ar[index];
		}
		
		private function helpBtnClick(e:Event):void
		{
			var bv:BaseChapetrView =  _listPanel.getPanel(_listPanel.selIndex);
			if(!bv)return ;
			if(bv is NewUnitJuexingView)
			{
				var st:String = GameLanguage.getLangByKey("L_A_73109");
				st = st.replace(/##/g,"<br />");
				XFacade.instance.openModule(ModuleName.IntroducePanel,st);
			}
		}
		
		/**右侧tab选择页签*/
		private function listMouseHandler2(index:int):void
		{
			_listPanel.selIndex = index;
			var bv:* = _listPanel.getPanel(index);
			if(!bv)return ;
			
			switch (true){
				case (bv is NewUnitInfoOperView):
					var _bv:NewUnitInfoOperView = (bv as NewUnitInfoOperView);
					if(_bv){
						_bv.selectAmData = selectAmData;
					}
					muUi.lvBox.visible = false;
					muUi.powerBox.y = 465;
					muUi.powerBox.visible = true;
					muUi.psBox.visible = false;
					muUi.topLeftBox.visible = false;
					muUi.dom_newInfo_box.visible = false;
					
					break;
				
				case (bv is NewUnitJuexingView):
					var _bv2:NewUnitJuexingView = (bv as NewUnitJuexingView);
					if(_bv2){
						_bv2.selectAmData = selectAmData;
					}
					muUi.lvBox.visible = true;
					muUi.powerBox.y = 317;
					muUi.powerBox.visible = true;
					muUi.psBox.visible = true;
					muUi.topLeftBox.visible = true;
					muUi.dom_newInfo_box.visible = false;
					
					break;
				
				case (bv is HeroAvatarCom):
					var v:HeroAvatarCom = bv;
					v.format(_selectAmData.unitId);
					
					muUi.lvBox.visible = false;
					muUi.powerBox.y = 465;
					muUi.powerBox.visible = true;
					muUi.psBox.visible = false;
					muUi.topLeftBox.visible = false;
					muUi.dom_newInfo_box.visible = false;
					
					break;
				
				case (bv is AdvanceView):
					var _bv3:AdvanceView = bv;
					var _this:NewUnitInfoAutoView = this;
					var _id = selectAmData.unitId;
					_bv3.show(_id, function () {
						_this.autoSelectIndex = 2;
						_this.refreshList();
						_this.selectUnitById(_id);
						_this.updateNewInfo();
					});
					
					updateNewInfo();
					
					ProTipUtil.addTip(muUi.dom_newInfo, selectAmData.serverData ? selectAmData.serverData : selectAmData.unitVo);
					muUi.lvBox.visible = true;
					muUi.powerBox.y = 465;
					muUi.powerBox.visible = false;
					muUi.psBox.visible = false;
					muUi.topLeftBox.visible = false;
					muUi.dom_newInfo_box.visible = true;
					
					break;
			}
		}
		
		/**更新左侧基本信息*/
		public function updateNewInfo():void {
			var _info = selectAmData.getInfoObj();
			muUi.dom_newInfo.attackTF.innerHTML = _info["attack"];
			muUi.dom_newInfo.critTF.innerHTML = _info["crit"];
			muUi.dom_newInfo.critDamageTF.innerHTML = _info["critDamage"];
			muUi.dom_newInfo.critDamReductTF.innerHTML = _info["critDamReduct"];
			muUi.dom_newInfo.defenseTF.innerHTML = _info["defense"];
			muUi.dom_newInfo.dodgeTF.innerHTML = _info["dodge"];
			muUi.dom_newInfo.hitTF.innerHTML = _info["hit"];
			muUi.dom_newInfo.hpTF.innerHTML = _info["hp"];
			muUi.dom_newInfo.resilienceTF.innerHTML = _info["resilience"];
			muUi.dom_newInfo.speedTF.innerHTML = _info["speed"];
		}
		
		public function get selectAmData():ArmyData
		{
			return _selectAmData;
		}
		
		public function set selectAmData(v:ArmyData):void
		{
			if(_selectAmData != v)
			{
				_selectAmData = v;
				bindAmData();
			}
		}
		
		/**动态获取右侧页签数据*/
		private function getTabListAr():Array {
			var json:Object = ResourceManager.instance.getResByURL("config/awaken_param.json");
			var data:String = ResourceManager.instance.getResByURL("config/pvepata_config.json");
			var _info:Array = data["2"]["value"].split("=");
			//是否不够
			var isNoBuild = User.getInstance().sceneInfo.getBuildingLv(_info[0]) < _info[1];
			if(!isNoBuild)//如果等级够了，判断是否还在建造
			{
				if(User.getInstance().sceneInfo.getBuildingLv(_info[0]) == _info[1])
				{
					var vo:SceneVo = User.getInstance().sceneInfo;
					var ifBuilding:Boolean = vo.hasBuildingInQueue(DBBuilding.B_CAMP);
					if(ifBuilding)
					{
						trace("兵营还在建造，不能进入");
						isNoBuild = true;
					}
				}
			}
		
			return [
				{
					icon:"newUnitInfo/btn_tab.png"
				},
				{
					icon:"newUnitInfo/btn_tab1.png",
					cond: json[1].value
				},
				{
					icon:"newUnitInfo/btn_tab3.png",
					isNoBuild: isNoBuild  
				}
			];
		}
		
		private function bindAmData():void
		{
			if(selectAmData)
			{
				//英雄皮肤处理
				var data:Object = DBUnit.getUnitInfo(selectAmData.unitId);
				m_tabList.array = getTabListAr().concat(heroSkin);
//				if(data.unit_type == DBUnit.TYPE_HERO){
//					m_tabList.array = getTabListAr().concat(heroSkin);
//				}else{
//					if(m_tabList.selectedIndex == 3){
//						m_tabList.selectedIndex = 0;
//					}
//					m_tabList.array = getTabListAr();
//				}
				
				var ar:Array = m_list.array;
				if(!ar.length)
				{
					selectAmData = null;
					return ;
				}
				else
				{
					var idx:Number = ar.indexOf(selectAmData);
					if(idx < 0)
					{
						m_list.selectedIndex = 0;
						listMouseHandler(0);
						m_list.scrollTo(0);
						return;
					}else if(m_list.selectedIndex != idx)
					{
						m_list.selectedIndex = idx;
						listMouseHandler(idx);
						m_list.scrollTo(idx);
						return;
					}
				}
			
				muUi.unitFace.gray = !selectAmData.serverData;
				muUi.unitFace.skin = UnitPicUtil.getUintPic(selectAmData.unitVo.model,UnitPicUtil.PIC_FULL);
				muUi.camp.skin = "newUnitInfo/camp_"+selectAmData.unitVo.camp+".png"
				
				
				muUi.attackIcon.visible = muUi.defendIcon.visible = muUi.attackTF.visible = muUi.defendTF.visible = muUi.levelTF.visible = true;
				muUi.attackIcon.skin = "common/icons/a_"+selectAmData.unitVo.attack_type+".png"
				muUi.defendIcon.skin = "common/icons/b_"+selectAmData.unitVo.defense_type+".png";
				muUi.attackTF.text = UnitInfoView.AttDic[selectAmData.unitVo.attack_type];
				muUi.defendTF.text = UnitInfoView.DefDic[selectAmData.unitVo.defense_type];
				muUi.levelTF.text = "Lv."+(selectAmData.serverData ? selectAmData.serverData.level : 1);
				
				listMouseHandler2(m_tabList.selectedIndex);
				bindPower();
				
			}else
			{
				muUi.unitFace.gray = false;
				muUi.unitFace.skin = UnitPicUtil.getUintPic("0000",UnitPicUtil.PIC_FULL);
				muUi.powerTF.text = "???";
				
				muUi.attackIcon.visible = muUi.defendIcon.visible = muUi.attackTF.visible = muUi.defendTF.visible = muUi.levelTF.visible = false;
			}
		}
		
		
		private function bindPower():void{
			var _rightA:Array = [0,0,0,0];
			var cData:Object = CampData.getUintById(selectAmData.unitId);
			if(cData)
			{
				_rightA[0] = Number(cData.hp);  //血量
				_rightA[1] = Number(cData.attack);  //攻击
				_rightA[2] = Number(cData.defense);  //防御
				_rightA[3] = Number(cData.speed);  //速度
			}
			NewJuexingTupoView.bindPs(muUi.psBox,_rightA,0);
			ProTipUtil.addTip(muUi.psBox,selectAmData.unitId,true);
			
			var _txt = selectAmData.serverData ? selectAmData.serverData.power : selectAmData.unitVo.br;
			muUi.powerTF.text = _txt;
			muUi.dom_text.text = _txt;
//			m_list.refresh();
		}
		
		private function onDressUp():void{
			bindAmData();
		}
		
		private function initUnitList():void
		{
			unitIdList.splice(0,unitIdList.length);
			for each (var fuvo:FightUnitVo in GameConfigManager.unit_dic) 
			{
//				var uLel:Object = CampData.getUintById(fuvo.unit_id);
				if(fuvo.visible) 
				{
					var amData:ArmyData = new ArmyData();
					amData.unitId = fuvo.unit_id;
					unitIdList.push(amData);
				}
			}
			unitIdList.sort(ArmyData.armySort);
		}
		
		private function getUnitByType(t:Number):Array{
			var rtAr:Array = [];
			if( t == 0 )  //所有
				return unitIdList.concat();
			for (var i:int = 0; i < unitIdList.length; i++) 
			{
				var amData:ArmyData = unitIdList[i];
				if( t == 1 && amData.unitVo.isHero)  //英雄
					rtAr.push(amData);
				else if(amData.unitVo.defense_type == t - 1)
				{
					rtAr.push(amData);
				}
			}
			return rtAr;
		}
		
		
		private var typeListIsShow:Boolean;
		private function showTypeList(e:Event):void
		{
			if(typeListIsShow) return hideTypeList(e);
			typeListIsShow = true;
			muUi.typeListBox.visible = true;
			Tween.clearAll(muUi.typeListCCBox);
			Tween.to(muUi.typeListCCBox,{x:0},200);
			e.stopPropagation();
		}
		
		/**
		 * 隐藏底部横向侧拉 
		 * @param e
		 * 
		 */
		private function hideTypeList(e:Event):void
		{
			typeListIsShow = false;
			if(e && e.target && e.target is Button)
			{
				var btn:Button = e.target as Button;
				var idx:Number = iconBtnList.indexOf(btn);
				if( idx > 0)
					seleType(btn.dataSource);
			}
			var tw:Boolean = e != null;
			Tween.clearAll(muUi.typeListCCBox);
			if(tw)
			{
				Tween.to(muUi.typeListCCBox,{x:0 - muUi.typeListCCBox.width},100,null,Handler.create(this,hideTLOver));
			}else
			{
				muUi.typeListCCBox.x = 0 - muUi.typeListCCBox.width;
				muUi.typeListBox.visible = false;
			}
		}
		
		private function hideTLOver():void{
			muUi.typeListBox.visible = false;
		}
		
		
		public function get closeBtn():Button{
			return muUi.closeBtn;
		}
		
		override public function addEvent():void
		{
			super.addEvent();
			muUi.selBtn.on(Event.CLICK,this,showTypeList);
			muUi.helpBtn.on(Event.CLICK,this,helpBtnClick);
			muUi.powerBox.on(Event.CLICK,this,showPowerTip);
			muUi.dom_text.on(Event.CLICK,this,showPowerTip);
			muUi.btn_mine.on(Event.CLICK,this, showMineFightView);
			stage.on(Event.CLICK,this,hideTypeList);
			initUnitList();
			seleType(0);
			hideTypeList(null);
			m_list.selectHandler = Handler.create(this,listMouseHandler,null,false);
			m_tabList.selectHandler =  Handler.create(this,listMouseHandler2,null,false);
			muUi.attackIcon.on(Event.CLICK,this,adiiconclick);
			muUi.defendIcon.on(Event.CLICK,this,adiiconclick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.on(JueXingMange.JUEXING_CHANGE,this,bindPower);
			Signal.intance.on(JueXingMange.TEXING_CHANGE,this,bindPower);
			Signal.intance.on(HeroAvatarCom.DRESS_UP, this, this.onDressUp);
			
			m_tabList.refresh();
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			muUi.selBtn.off(Event.CLICK,this,showTypeList);
			muUi.helpBtn.off(Event.CLICK,this,helpBtnClick);
			muUi.powerBox.off(Event.CLICK,this,showPowerTip);
			muUi.dom_text.off(Event.CLICK,this,showPowerTip);
			muUi.btn_mine.off(Event.CLICK,this, showMineFightView);
			stage.off(Event.CLICK,this,hideTypeList);
			m_list.selectHandler = null;
			m_tabList.selectHandler = null;
			muUi.attackIcon.off(Event.CLICK,this,adiiconclick);
			muUi.defendIcon.off(Event.CLICK,this,adiiconclick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.off(JueXingMange.JUEXING_CHANGE,this,bindPower);
			Signal.intance.off(JueXingMange.TEXING_CHANGE,this,bindPower);
			Signal.intance.off(HeroAvatarCom.DRESS_UP, this, this.onDressUp);
		}
		
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			muUi.size(width,height);
			muUi.topLeftBox.pos(0,0);
			muUi.topBox.pos(width - muUi.topBox.width >>1 , 0);
			muUi.topRigthBox.pos(width - muUi.topRigthBox.width , 0);
			muUi.unitListBox.pos(0, (height - muUi.topLeftBox.height - muUi.unitListBox.height) / 2 + muUi.topLeftBox.height);
			muUi.selectUnitBox.pos( width / 2 - muUi.selectUnitBox.width - 50 ,  height - muUi.selectUnitBox.height >> 1);
			muUi.tabListBox.pos(width - muUi.tabListBox.width , muUi.unitListBox.y);
			muUi.selectUnitTopBox.pos(muUi.selectUnitBox.x - 100,muUi.selectUnitBox.y);
			muUi.dom_newInfo_box.x = (muUi.selectUnitBox.x + muUi.selectUnitBox.width / 2) - muUi.dom_newInfo_box.width / 2; 
			muUi.dom_newInfo_box.y = muUi.selectUnitTopBox.y + 320;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			
			super.destroy(destroyChild);
			muUi = null;
			typeList = null;
			iconList = null;
			iconBtnList = null;
			unitIdList = null;
			m_list = null;
			m_tabList = null;
			_listPanel = null;
			_ani = null;
			_selectAmData = null;
			UIRegisteredMgr.DelUi("CampTabList");
		}
	}
}