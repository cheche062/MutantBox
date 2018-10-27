package game.module.camp
{
	import MornUI.camp.CampViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XGroup;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnit;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	/**
	 * CampView
	 * author:huhaiming
	 * CampView.as 2017-3-20 上午10:44:27
	 * version 1.0
	 *
	 */
	public class CampView extends BaseView
	{
		private var _group:XGroup;
		private var _data:Object;
		private var _redPot:Image;
		private var _redPot2:Image;
		private var _selectedItem:UnitItem;
		
		private var _uniteList:Array = [];
		private var _srcList:Array = [];
		public function CampView()
		{
			super();
			this._m_iLayerType = LayerManager.M_POP;
			
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			view.dom_list.scrollBar.touchScrollEnable = true;
			view.dom_list.scrollBar.mouseWheelEnable = true;
			if (User.getInstance().isInGuilding)
			{
				view.typeTab.selectedIndex = 0;
				view.dom_list.scrollBar.touchScrollEnable = false;
				view.dom_list.scrollBar.mouseWheelEnable = false;
			}
			
			//背包数据
			var list:Array = BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_SOLDIER]);
			if(!list){
				Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			}else{
				view.mouseEnabled = false;
				WebSocketNetService.instance.sendData(ServiceConst.C_INFO, null);
			}
			
			onStageResize();
			
			if (!User.getInstance().hasFinishGuide)
			{
				Laya.timer.once(500, this, function() { 
					Signal.intance.event(NewerGuildeEvent.SELECT_SNAPER)
				} );
				
			}
		}
		
		//ui需要配置
		override public function createUI():void{
			this._view = new CampViewUI();
			this.addChild(this._view);
			view.mouseEnabled = true;
			view.dom_list.vScrollBarSkin = "";
			view.dom_list.itemRender = UnitItem;
			view.dom_list.array = null;
			
			view.dom_list.selectEnable = true;
			
			view.bg.skin = "appRes/fightingMapImg/pvpBg.jpg";
			
			var btns:Array = [];
			for(var i:int=0; i<5; i++){
				btns.push(view["btn_"+i]);
			}
			_group = new XGroup(btns);
			_group.selectedBtn = btns[0];
			
			var btns:Array = view.typeTab.items;
			for(i=0; i<btns.length; i++){
				Button(btns[i]).labelFont = XFacade.FT_BigNoodleToo;
			}
			
			UIRegisteredMgr.AddUI(this.view.dom_list,"CampSoilderList");
			UIRegisteredMgr.AddUI(this.view.closeBtn,"CampCloseBtn");
			_redPot = new Image("common/redot.png");
			_redPot2 = new Image("common/redot.png");
			this.view.typeTab.items[0].addChild(_redPot);
			this.view.typeTab.items[1].addChild(_redPot2);
			_redPot.visible = _redPot2.visible = false;
		}
		
		private function onResult(cmd:int, ...args):void{
			trace("C_OnResult",args);
			switch(cmd){
				case ServiceConst.C_INFO:
					this._data = args[1];
					CampData.update(this._data);
					initList();
					format();
					checkUp();
					
					view.mouseEnabled = true;
					
					break;
				case ServiceConst.C_Star:
					//覆盖数据=================================
					var info:Object = args[1];
					
					var tmpId:String = info.unitId;
					if(this._data.solier_list[tmpId]){
						this._data.solier_list[tmpId] = info;
					}else if(this._data.hero_list[tmpId]){
						this._data.hero_list[tmpId] = info;
					}
					replaceData(tmpId,info);
					//
					CampData.updateUnit(tmpId, info);
					format();
					//同步建筑状态
					DBUnit.isAnyCanUp();
					checkUp()
					break;
				case ServiceConst.C_COMPOSE:
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.RELEASE_SNAPER);
						return;
					}
					WebSocketNetService.instance.sendData(ServiceConst.C_INFO, null);
					//同步建筑状态
					DBUnit.isAnyCanUp();
					checkUp()
					break;
				case ServiceConst.JUEXING_TUPO:
					CampData.updateUnit(tmpId, info);
					format();
					break;
			}
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.closeBtn:
					this.close();
					break
				case view.infoBtn:
					XFacade.instance.openModule("CampTip");
					break;
			}
		}
		
		private function onChange():void{
			var index:int = _group.selectedIndex;
			var id:int = view.typeTab.selectedIndex;
			var type:int = id == 0 ? 2 : 1;
			
			if(index == 0){
				this.view.dom_list.array = getList(-1,type);
			}else if(index == 1){
				this.view.dom_list.array = getList(1,type);
			}else if(index == 2){
				this.view.dom_list.array = getList(2,type);
			}else if(index == 3){
				this.view.dom_list.array = getList(3,type);
			}else if(index == 4){
				this.view.dom_list.array = getList(4,type);
			}
			
			this.view.dom_list.refresh();
			this.view.dom_list.selectedIndex = 0;
			selectedItem = null;
		}
		
		private function checkUp():Boolean{
			this._redPot.visible = this._redPot2.visible = false;
			var arr:Array  = getList(-1,1);
			for(var i:int=0; i<arr.length; i++){
				if(DBUnit.check(arr[i].id) > 1){
					this._redPot2.visible = true;
					break;
				}
			}
			arr  = getList(-1,2);
			for(i=0; i<arr.length; i++){
				if(DBUnit.check(arr[i].id) > 1){
					this._redPot.visible = true;
					break;
				}
			}
		}
		
		private function onChangeType():void{
			onChange();
		}
		
		private function onRender(cell:Box,index:int):void{
			if(index == view.dom_list.selectedIndex){
				cell.selected = true;
			}else{
				cell.selected = false;
			}
		}
		
		/**unitType单位类型，1表示英雄*/
		private function getList(armType:int, unitType:int = 2):Array{
			var arr:Array = [];
			var tmp:Array = [];
			for(var i:int=0; i<_uniteList.length; i++){
				if(_srcList[i].unit_type == unitType){
					if(armType == -1){
						arr.push(_uniteList[i]);
					}else if(_srcList[i].defense_type == armType){
						arr.push(_uniteList[i]);
					}
				}
			}
			arr.sort(onSort);
			var tmp:Array = [];
			for(i=0; i<arr.length; i++){
				if(arr[i].order != 2){
					break;
				}else{
					tmp.push(arr[i]);
				}
			}
			//已激活的单位
			var tmp2:Array = [];
			for(i; i<arr.length; i++){
				if(arr[i].order != 1){
					break;
				}else{
					tmp2.push(arr[i]);
				}
			}
			tmp2.sort(onSort2);
			
			var tmp3:Array = [];
			if(i > 0){
				tmp3 = arr.slice(i);
				tmp3.sort(onSort2);
				arr = tmp.concat(tmp2).concat(tmp3);
			}else{
				arr.sort(onSort2);
			}
			
			return arr;
		}
		
		private function onBagInit():void{
			WebSocketNetService.instance.sendData(ServiceConst.C_INFO, null);
		}
		
		/**初始化*/
		private function initList():void{
			//unit的类型（1代表英雄，2代表兵，3代表伤害类道具，4加益道具,5死后存在的废体，6建筑物）
			var arr:Array = [];
			_srcList = [];
			var types:Array = [1,2];
			var tmp:Object;
			var order:int;
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i]
				if(types.indexOf(parseInt(tmp.unit_type)) != -1 && tmp.visible != 0){
					order = DBUnit.check(tmp.unit_id)
					arr.push({id:tmp.unit_id, su:true, order:order});
					_srcList.push(tmp);
				}
			}
			this._uniteList = arr;
		}
		
		private function onSort(obj1:Object, obj2:Object):int{
			if(obj1.order < obj2.order){
				return 1;
			}
			return -1;
		}
		
		private function onSort2(obj1:Object, obj2:Object):int{
			var tmp:Object = GameConfigManager.unit_json[obj1.id]
			var tmp1:Object = GameConfigManager.unit_json[obj2.id]
			if(parseInt(tmp.rarity) > parseInt(tmp1.rarity)){
				return 1;
			}
			return -1;
			
		}
		
		/**数据员替换*/
		private function replaceData(id:*, data:Object):void{
			for(var i:int=0; i<this._uniteList.length; i++){
				if(this._uniteList[i].unitId == id){
					data.defense_type = this._uniteList[i].defense_type;
					data.unit_id = this._uniteList[i].unit_id;
					data.unit_type = this._uniteList[i].unit_type;
					this._uniteList[i] = data;
				}else if(this._uniteList[i].unit_id == id){
					data.defense_type = this._uniteList[i].defense_type;
					data.unit_id = this._uniteList[i].unit_id;
					data.unit_type = this._uniteList[i].unit_type;
					this._uniteList[i] = data;
				}
			}
		}
		
		private function format():void{
			//替换掉数据源中数据
			var tmp:Array = _data.hero_list;
			for(var i:String in tmp){
				replaceData(i, tmp[i]);
			}
			
			tmp = _data.solier_list;
			for(var i:String in tmp){
				replaceData(i, tmp[i]);
			}
			this.onChange();
		}
		
		
		
		private function onSelectSoldier(e:Event,index:int):void
		{
			if(e.type == Event.CLICK){
				var item:Object = view.dom_list.getItem(index);
				this.selectedItem = view.dom_list.getCell(index) as UnitItem;
				if(XUtils.checkHit(_selectedItem.attackIcon)){
					ProTipUtil.showAttTip(_selectedItem.data.id);
				}else if(XUtils.checkHit(_selectedItem.defendIcon)){
					ProTipUtil.showDenTip(_selectedItem.data.id);
				}else{
					if(XUtils.checkHit(_selectedItem.rebornBtn)){
					}else{
//						XFacade.instance.openModule("UnitInfoView", [item, getIds(item.id)]);
						view.dom_list.scrollBar.touchScrollEnable = true;
						view.dom_list.scrollBar.mouseWheelEnable = true;
						XFacade.instance.openModule(ModuleName.NewUnitInfoView,[item.id]);
					}
				}
			}
		}
		
		private function getIds(id:*):Array{
			var ids:Array = [];
			var len:int = this.view.dom_list.array.length
			for(var i:int=0; i<len; i++){
				ids.push(this.view.dom_list.array[i].id);
			}
			return ids;
		}
		
		private function set selectedItem(item:UnitItem):void{
			if(this._selectedItem){
				this._selectedItem.selected = false;
			}
			this._selectedItem = item;
			if(this._selectedItem){
				this._selectedItem.selected = true;
			}
		}
		
		override public function onStageResize():void{
			var delScale:Number = LayerManager.fixScale;
			if(delScale > 1){
				this.view.bg.scale(delScale,delScale);
			}
			
			view.width = Laya.stage.width;
			view.height = Laya.stage.height;
			view.barBg.width = Laya.stage.width;
			view.titlTF.x = (Laya.stage.width - view.titlTF.width)/2;
			view.closeBtn.x = Laya.stage.width - view.closeBtn.width;
			view.content.x = (Laya.stage.width - view.content.width)/2;
			view.content.y = (Laya.stage.height - view.content.height)/2;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("CampSoilderList");
			UIRegisteredMgr.DelUi("CampCloseBtn");
			super.destroy(destroyChild);
		}
		
		override public function close():void{
			this._data = null;
			this.view.dom_list.array = null;
			this._uniteList = this._srcList = null;
			selectedItem = null;
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("camp/bg13 (2).png");
			super.dispose();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			this._group.on(Event.CHANGE, this, this.onChange);
			view.typeTab.on(Event.CHANGE, this, this.onChangeType);
			view.dom_list.mouseHandler = Handler.create(this,onSelectSoldier, null, false);
			view.dom_list.renderHandler = Handler.create(this, this.onRender, null, false)
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult,[ServiceConst.C_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult,[ServiceConst.C_Star]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult,[ServiceConst.C_COMPOSE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.JUEXING_TUPO),this,onResult,[ServiceConst.JUEXING_TUPO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			view.typeTab.off(Event.CHANGE, this, this.onChangeType);
			view.dom_list.renderHandler = null;
			view.dom_list.mouseHandler = null; 
			this._group.off(Event.CHANGE, this, this.onChange);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.JUEXING_TUPO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			super.removeEvent();
		}
		
		
		public function get view():CampViewUI{
			return this._view as CampViewUI;
		}
	}
}