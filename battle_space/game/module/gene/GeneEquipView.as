package game.module.gene
{
	import MornUI.gene.GeneEquipViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XGroup;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.starBar;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBGeneList;
	import game.global.data.DBGeneRequire;
	import game.global.data.DBGeneSuit;
	import game.global.data.DBItem;
	import game.global.data.DBUintUpgradeExp;
	import game.global.data.DBUnitStar;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.module.alert.XAlert;
	import game.module.camp.CampData;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.tips.GeneTip;
	import game.module.train.TrainItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	/**
	 * GeneEquipView 基因装备
	 * author:huhaiming
	 * GeneEquipView.as 2017-3-24 下午2:39:42
	 * version 1.0
	 *
	 */
	public class GeneEquipView extends BaseDialog
	{
		private var _soldierInfo:Object;
		private var _geneInfo:Object;
		//
		private var _starLv:starBar;
		private var _idx:Number = 0;
		private var _selectedItem:TrainItem;
		private var _nowItem:ItemCell
		private var _onShow:Boolean = false;
		//
		private var _group:XGroup;
		//最小格子数
		private const MIN_GRID_NUM:int = 20;
		//
		public static var curSoldier:Object;
		/**更新基因信息*/
		public static const UPDATE:String = "update"
		public function GeneEquipView()
		{
			super();
		}
		
		private function onResult(cmd:int, ...args):void{
			trace("G_E_OnResult",args);
			switch(cmd){
				case ServiceConst.G_EQ_INFO:
					this._geneInfo = (args[1]||{});
					formatGene();
					break;
				case ServiceConst.G_EQ_EQUIP:
					this._geneInfo = (args[1]||{});
					formatGene();
					
					var target:Sprite = view.xImg;
					if(view.yImg.visible){
						target = view.yImg;
					}else if(view.zImg.visible){
						target = view.zImg;
					}
					
					var ani:Animation = new Animation();
					ani.loadAtlas("appRes/atlas/geneEquip/effect/equip.json");
					view.addChild(ani);
					ani.pos(target.x-40, target.y-93);
					ani.interval = 100;
					ani.autoPlay = true;
					XUtils.autoRecyle(ani);
					
					break;
				case ServiceConst.G_EQ_UNEQ:
					this._geneInfo = (args[1]||{});
					formatGene();
					break;
			}
		}
		
		/*private function format():void{
			if(this._soldierInfo){
				var info:Object = this._soldierInfo;
				var arr:Array = [];
				for(var i:String in info.solier_list){
					arr.push(info.solier_list[i]);
				}
				arr.sort(onSort);
				view.list.array = arr;
				
				Laya.timer.once(200,this,onSelect,[_idx]);
			}
		}*/
		
		private function onSort(obj1:Object, obj2:Object):int{
			if(obj1.power < obj2.power){
				return 1;
			}
			return -1;
		}
		
		private function onSelect(index:int):void
		{
			_idx = index;
			var data:Object = view.list.getItem(index);
			GeneEquipView.curSoldier = data;
			
			if(data){
				//DataLoading.instance.show();
				WebSocketNetService.instance.sendData(ServiceConst.G_EQ_INFO, [data.unitId]);
			}
			
			selectedItem = view.list.getCell(index) as TrainItem;
			formatSoldierInfo(data);
			if(view.bagBox.visible){
				this.onChangeType();
			}
		}
		
		private function formatSoldierInfo(data:Object):void{
			if(data){
				var vo:Object = DBUnitStar.getStarData(data.starId)
				_starLv.barValue = vo.star_level;
				_starLv.visible = true;
				
				var db:Object = GameConfigManager.unit_json[data.unitId];
				_starLv.maxStar = db.star;
				if(_starLv.maxStar > 5){
					this._starLv.y = 145;
				}else{
					this._starLv.y = 156;
				}
				
				//兼容原始数据
				view.dataInfo.attackTF.innerHTML = (data.attack || vo.ATK)+"";
				view.dataInfo.critTF.innerHTML = (data.crit || vo.crit) +"";
				view.dataInfo.critDamageTF.innerHTML = (data.critDamage || vo.CDMG)+"";
				view.dataInfo.critDamReductTF.innerHTML = (data.critDamReduct|| vo.CDMGR)+"";
				view.dataInfo.defenseTF.innerHTML = (data.defense || vo.DEF)+"";
				view.dataInfo.dodgeTF.innerHTML = (data.dodge || vo.dodge)+"";
				view.dataInfo.hitTF.innerHTML = (data.hit || vo.hit)+"";
				view.dataInfo.hpTF.innerHTML = (data.hp || vo.HP)+"";
				view.dataInfo.resilienceTF.innerHTML = (data.resilience || vo.RES)+"";
				view.dataInfo.speedTF.innerHTML = (data.speed || vo.SPEED)+"";
				
				var vo2:Object = GameConfigManager.unit_json[data.unitId || data.unit_id];;
				
				//头像
				if(view.pic.skin != UnitPicUtil.getUintPic(data.unitId || data.unit_id,UnitPicUtil.PIC_FULL)){
					Loader.clearRes(view.pic.skin);
				}
				view.pic.skin = UnitPicUtil.getUintPic(data.unitId || data.unit_id,UnitPicUtil.PIC_FULL)
				
				if(vo2){
					view.nameTF.text = vo2.name+"";
				}
				ProTipUtil.addTip(view.dataInfo,data);
				view.kpiTF.text = data.power+"";
			}else{
				_starLv.visible = false;
				view.dataInfo.attackTF.innerHTML = "";
				view.dataInfo.critTF.innerHTML = "";
				view.dataInfo.critDamageTF.innerHTML = "";
				view.dataInfo.critDamReductTF.innerHTML = "";
				view.dataInfo.defenseTF.innerHTML = "";
				view.dataInfo.dodgeTF.innerHTML = "";
				view.dataInfo.hitTF.innerHTML = "";
				view.dataInfo.hpTF.innerHTML = "";
				view.dataInfo.resilienceTF.innerHTML = "";
				view.dataInfo.speedTF.innerHTML = "";
				
				view.nameTF.text = "";
				view.pic.skin = "";
				view.kpiTF.text = "";
				ProTipUtil.removeTip(view.dataInfo)
			}
		}
		
		private function formatGene():void{
			//还原数据状态
			var data:Object = view.list.getItem(_idx);
			
			var info:Object
			var genInfo:Object;
			var proInfo:Object;
			var totalPro:Object;
			var suitList:Array = [];
			trace(".................__",_geneInfo);
			for(var i:uint=0; i< 3; i++){
				info = _geneInfo[i+1];
				view["icon_"+i].graphics.clear();
				if(info){
					//图标
					var vo:ItemVo = DBItem.getItemData(info.genenId)
					view["icon_"+i].loadImage("appRes/icon/itemIcon/"+vo.icon+".png");
					
					view["icon_"+i].mouseEnabled = true;
					genInfo = DBGeneList.getGeneInfoByItemId(info.genenId, info.level);
					suitList.push(genInfo.suit_id);
					if(genInfo.attribute){
						proInfo = DBGeneList.parsePro(genInfo.attribute);
					}
					if(!totalPro){
						totalPro = proInfo;
					}else{
						totalPro =  XUtils.mergeObj(totalPro,proInfo);
					}
				}else{
					view["icon_"+i].mouseEnabled = false;
				}
			}
			
			//获取套装属性
			var suitInfo:Object = getSuitId(suitList);
			var suitPro:Object;
			if(suitInfo){
				var suitProStr:String = DBGeneSuit.getSuitInfo(suitInfo.id,suitInfo.num);
				suitPro = DBGeneList.parsePro(suitProStr);
			}
			totalPro =  XUtils.mergeObj(totalPro,suitPro);
			
			//需要剪掉基因加成
			if(!data.separate){
				data.separate = true;
				data = XUtils.separateObj(data,totalPro);
			}
			
			
			view.dataInfo.attackTF.innerHTML = data.attack +"";
			view.dataInfo.critTF.innerHTML = data.crit +"";
			view.dataInfo.critDamageTF.innerHTML = data.critDamage +"";
			view.dataInfo.critDamReductTF.innerHTML = data.critDamReduct +"";
			view.dataInfo.defenseTF.innerHTML = data.defense +"";
			view.dataInfo.dodgeTF.innerHTML = data.dodge +"";
			view.dataInfo.hitTF.innerHTML = data.hit +"";
			view.dataInfo.hpTF.innerHTML = data.hp +"";
			view.dataInfo.resilienceTF.innerHTML = data.resilience +"";
			view.dataInfo.speedTF.innerHTML = data.speed+"";
			
			//属性显示===============================================
			var str:String
			for(var m:String in totalPro){
				trace("m------------------------------",m)
				var sign:String = "+";
				if(totalPro[m] < 0){
					sign = "-"
				}
				str = "<font color='#abff47'>"+sign+totalPro[m]+"</font>" 
				view.dataInfo[m+"TF"].appendHTML(str);
			}
		}
		
		/**
		 * 获取套装ID和件数,穷举
		 * return {id:sId1,num:2}
		 * */
		private function getSuitId(arr:Array):Object{
			var sId0:String = arr[0];
			var sId1:String = arr[1];
			var sId2:String = arr[2];
			if(sId0 == sId1){
				if(sId0 == sId2){
					return {id:sId0,num:3}
				}
				return {id:sId0,num:2}
			}else if(sId0 == sId2){
				return {id:sId0,num:2}
			}else if(sId1 == sId2){
				return {id:sId1,num:2}
			}
			return null;
		}
		
		private function onItemClick(e:Event, index:Number):void{
			if(e.type == Event.CLICK){
				var data:Object = view.itemList.getItem(index);
				trace("data======================>>",data);
				nowItem = view.itemList.getCell(index) as ItemCell
				if(data){
					XTipManager.showTip([data], GeneTip, false);
				}
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				case view.equipBtn_0:
					showBag(ItemConst.GENE_STYPE_1);
					break;
				case view.equipBtn_1:
					showBag(ItemConst.GENE_STYPE_2);
					break;
				case view.equipBtn_2:
					showBag(ItemConst.GENE_STYPE_3);
					break;
				case view.switchBtn:
					var v:Boolean = this.view.bagBox.visible;
					this.view.bagBox.visible = !v;
					this.view.infoBox.visible = v;
					onChangeType();
					if(this.view.infoBox.visible){
						view.xImg.visible = view.yImg.visible = view.zImg.visible = false;
					}
					break;
				case view.icon_0:
					if(_geneInfo && _geneInfo[1]){
						XTipManager.showTip([_geneInfo[1],GeneTip.TAKEOFF], GeneTip, false);
					}
					//if(view.bagBox.visible){
						showBag(ItemConst.GENE_STYPE_1);
					//}
					break;
				case view.icon_1:
					if(_geneInfo && _geneInfo[2]){
						XTipManager.showTip([_geneInfo[2],GeneTip.TAKEOFF], GeneTip, false);
					}
					//if(view.bagBox.visible){
						showBag(ItemConst.GENE_STYPE_2);
					//}
					break;
				case view.icon_2:
					if(_geneInfo && _geneInfo[3]){
						XTipManager.showTip([_geneInfo[3],GeneTip.TAKEOFF], GeneTip, false);
					}
					//if(view.bagBox.visible){
						showBag(ItemConst.GENE_STYPE_3);
					//}
					break;
				default:
					if(XUtils.checkHit(view.kpiIcon) || XUtils.checkHit(view.kpiTF)){
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
					}
					break;
			}
		}
		
		private function onChangeType():void{
			var dType:Array
			view.xImg.visible = view.yImg.visible = view.zImg.visible = false;
			if(view.typeTab.selectedIndex>0){
				dType = [view.typeTab.selectedIndex];
				if(dType == 1){
					view.xImg.visible = true;
				}else if(dType == 2){
					view.yImg.visible = true;
				}else{
					view.zImg.visible = true;
				}
			}else{
				dType = [1,2,3]
			}
			var data:Array = [];
			var tmp:Array = (BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_GENE], dType) || []);
			var vo:Object = view.list.getItem(view.list.selectedIndex);
			var uId:int = (vo && vo.unitId)
			for(var i:int=0; i<tmp.length; i++){
				if(DBGeneRequire.check(tmp[i].iid, uId)){
					data.push(tmp[i]);
				}
			}
			var n:int = Math.ceil(data.length/view.itemList.repeatX);
			var itemNum:Number = Math.max(MIN_GRID_NUM,n*view.itemList.repeatX)
			for(i = data.length; i<itemNum; i++){
				data.push(null);
			}
			this.view.itemList.array = data;
		}
		
		private var _geneType:int;
		private function showBag(stype:Number):void{
			_geneType = stype;
			view.typeTab.selectedIndex = _geneType;
			
			/*var data:Array = BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_GENE], [stype]);
			var n:int = Math.ceil(data.length/view.itemList.repeatX);
			var itemNum:Number = Math.max(MIN_GRID_NUM,n*view.itemList.repeatX)
			for(var i:Number = data.length; i<itemNum; i++){
				data.push(null);
			}
			this.view.itemList.array = data;*/
			
			this.view.bagBox.visible = true;
			this.view.infoBox.visible = false;
		}
		
		private function onBagInit():void{
			//显示不同的道具
			onChangeType();
			/*if(this._soldierInfo){
				var data:Object = view.list.getItem(_idx);
				formatSoldierInfo(data);
			}*/
		}
		
		private function onBageChange():void{
			if(this.view.bagBox.visible){
				onChangeType();
			}
		}
		
		private function onChange(reset:Boolean = true):void{
			var index:int = _group.selectedIndex;
			var arr:Array;
			if(index == 0){
				arr  = CampData.getUnitList(2);
				this.view.curTF.text = GameLanguage.getLangByKey("L_A_36001");
			}else if(index == 1){
				arr = CampData.getUnitList(2,1);
				this.view.curTF.text = GameLanguage.getLangByKey("L_A_34077");
			}else if(index == 2){
				arr = CampData.getUnitList(2,2);
				this.view.curTF.text = GameLanguage.getLangByKey("L_A_34078");
			}else if(index == 3){
				arr = CampData.getUnitList(2,3);
				this.view.curTF.text = GameLanguage.getLangByKey("L_A_34079");
			}else if(index == 4){
				arr = CampData.getUnitList(2,4);
				this.view.curTF.text = GameLanguage.getLangByKey("L_A_34080");
			}
			this.view.list.array = arr.sort(onSort);
			this.view.list.refresh();
			
			if(reset || !_selectedItem){
				this.view.list.selectedIndex = 0;
				this.selectedItem = this.view.list.getCell(0) as UnitItem;
			}
			this.onSelect(this.view.list.selectedIndex);
		}
		
		private function onEquip(type:String,data:Object):void{
			if(_selectedItem.data){
				var unitId:String = _selectedItem.data.unitId;
				var gInfo:Object;
				switch(type){
					case GeneTip.EQUIP:
						gInfo = DBGeneList.getGeneInfoByItemId(data.iid,data.exPro && data.exPro.level);
						var location:String = gInfo.location
						if(_geneInfo[location]){
							gInfo = DBGeneList.getGeneInfo(_geneInfo[location].genenId);
							//替换装备 
							var hander:Handler = Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData, [ServiceConst.G_EQ_EQUIP, [data.key, unitId,location]])
							//todo——-语言包。。
							var str:String = GameLanguage.getLangByKey("L_A_38041");
							str = str.replace(/{(\d+)}/,(gInfo.cost+"").split("=")[1])
							//XAlert.showAlert(str, hander)
							
							var arr:Array = (gInfo.cost+"").split("=")
							var tmp:ItemData = new ItemData;
							tmp.iid = arr[0];
							tmp.inum = arr[1];
							
							var conHandler:Handler = Handler.create(ConsumeHelp,ConsumeHelp.Consume,[[tmp],hander,str]);
							//ConsumeHelp.Consume([data],hander,str)
							XAlert.showAlert(str, conHandler);
						}else{
							WebSocketNetService.instance.sendData(ServiceConst.G_EQ_EQUIP, [data.key, unitId,gInfo.location]);
						}
						break;
					case GeneTip.TAKEOFF:
						gInfo = DBGeneList.getGeneInfoByItemId(data.genenId,data.level);
						var hander:Handler = Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData, [ServiceConst.G_EQ_UNEQ, [unitId,gInfo.location]])
						//WebSocketNetService.instance.sendData(ServiceConst.G_EQ_UNEQ, [unitId,gInfo.location]);
						str = GameLanguage.getLangByKey("L_A_38041");
						str = str.replace(/{(\d+)}/,(gInfo.cost+"").split("=")[1])
						//XAlert.showAlert(str, hander)
						
						var arr:Array = (gInfo.cost+"").split("=")
						var tmp:ItemData = new ItemData;
						tmp.iid = arr[0];
						tmp.inum = arr[1];
						var conHandler:Handler = Handler.create(ConsumeHelp,ConsumeHelp.Consume,[[tmp],hander,str]);
						XAlert.showAlert(str, conHandler)
						break;
				}
			}
		}
		
		private function onRender(cell:Box,index:int):void{
			if(index == view.list.selectedIndex){
				cell.selected = true;
			}else{
				cell.selected = false;
			}
		}
		
		private function onRender2(cell:Box,index:int):void{
			(cell as ItemCell).showTip = false;
		}
		
		override public function show(...args):void{
			super.show();
			if(!_onShow){
				_onShow = true;
				onChange();
				view.bagBox.visible = false;
				view.infoBox.visible = true;
				if (!User.getInstance().isInGuilding)
				{
					AnimationUtil.flowIn(this);
				}
			}
		}
		
		override public function close():void{
			_idx = 0;
			if(_selectedItem){
				_selectedItem.selected = false;
				_selectedItem = null;
			}
			this._soldierInfo = null;
			this._geneInfo = null;
			this.view.typeTab.selectedIndex = 0;
			GeneEquipView.curSoldier = null;
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			_onShow = false;
			super.close();
		}
		
		private function set selectedItem(item:TrainItem):void{
			if(this._selectedItem){
				this._selectedItem.selected = false;
			}
			this._selectedItem = item;
			if(this._selectedItem){
				this._selectedItem.selected = true;
			}
		}
		
		private function set nowItem(item:ItemCell):void{
			if(this._nowItem){
				_nowItem.selected = false;
			}
			_nowItem = item;
			if(_nowItem){
				_nowItem.selected = true;
			}
		}
		
		override public function createUI():void{
			this._view = new GeneEquipViewUI();
			this.addChild(_view);
			view.xImg.visible = view.yImg.visible = view.zImg.visible = false;
			
			view.list.hScrollBarSkin=""
			view.list.itemRender = TrainItem;
			view.list.selectEnable = true;
			
			this._starLv = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10, 5);
			this.view.infoBox.addChild(this._starLv);
			this._starLv.pos(420,156)
			_starLv.scaleX = _starLv.scaleY = 0.8;
			
			view.list.selectHandler = new Handler(this, this.onSelect);
			
			view.itemList.itemRender = ItemCell;
			view.itemList.selectEnable = true;
			view.itemList.mouseHandler = new Handler(this, this.onItemClick);
			view.itemList.vScrollBarSkin=""
			view.bagBox.visible = false;
			
			for(var i:String in view.dataInfo){
				if(view.dataInfo[i] is HTMLDivElement){
					view.dataInfo[i].style.fontFamily = XFacade.FT_Futura;
					view.dataInfo[i].style.fontSize = 16;
					view.dataInfo[i].style.color = "#ffffff";
					view.dataInfo[i].style.align = "right";
				}
			}
			
			var btns:Array = [];
			for(var j:int=0; j<5; j++){
				btns.push(view["btn_"+j]);
			}
			_group = new XGroup(btns);
			_group.selectedBtn = btns[0];
			
			closeOnBlank = true;
			
			view.infoBox.cacheAsBitmap = true;
			UIRegisteredMgr.AddUI(view.switchBtn,"GeneChange");
			UIRegisteredMgr.AddUI(view.icon_0,"XGen");
			UIRegisteredMgr.AddUI(view.itemList,"GeneList");
			UIRegisteredMgr.AddUI(view.closeBtn,"CloseGen");
		}
		
		override public function dispose():void{
			Loader.clearRes(view.pic.skin);
			Laya.loader.clearRes("geneEquip/bg5.png");
			
			UIRegisteredMgr.DelUi("GeneChange");
			UIRegisteredMgr.DelUi("XGen");
			UIRegisteredMgr.DelUi("GeneList");
			UIRegisteredMgr.DelUi("CloseGen");
			
			super.dispose();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			view.typeTab.on(Event.CHANGE, this, this.onChangeType);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, onBageChange);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			_group.on(Event.CHANGE, this, this.onChange);
			Signal.intance.on(GeneTip.EQUIP, this, this.onEquip,[GeneTip.EQUIP]);
			Signal.intance.on(GeneTip.TAKEOFF, this, this.onEquip,[GeneTip.TAKEOFF]);
			Signal.intance.on(GeneEquipView.UPDATE, this, this.formatGene);
			view.list.renderHandler = Handler.create(this, this.onRender,null, false);
			view.itemList.renderHandler = Handler.create(this, this.onRender2,null, false);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.G_EQ_INFO),this,onResult,[ServiceConst.G_EQ_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.G_EQ_EQUIP),this,onResult,[ServiceConst.G_EQ_EQUIP]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.G_EQ_UNEQ),this,onResult,[ServiceConst.G_EQ_UNEQ]);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			view.typeTab.off(Event.CHANGE, this, this.onChangeType);
			view.list.renderHandler = null;
			view.itemList.renderHandler = null
			_group.off(Event.CHANGE, this, this.onChange);
			Signal.intance.off(GeneTip.TAKEOFF, this, this.onEquip);
			Signal.intance.off(GeneTip.EQUIP, this, this.onEquip);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, onBageChange);
			Signal.intance.off(GeneEquipView.UPDATE, this, this.formatGene);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.G_EQ_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.G_EQ_EQUIP),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.G_EQ_UNEQ),this,onResult);
			ProTipUtil.removeTip(view.dataInfo)
		}
		
		private function get view():GeneEquipViewUI{
			return this._view as GeneEquipViewUI;
		}
	}
}