package game.module.gene
{
	import MornUI.gene.GenenHanceUI;
	
	import game.common.ResourceManager;
	import game.common.UIRegisteredMgr;
	import game.common.UnpackMgr;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.DBGeneList;
	import game.global.data.DBItem;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.module.tips.GeneTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.debug.tools.comps.Rect;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	/**
	 * GenEnhanceView 基因强化面板
	 * author:huhaiming
	 * GenEnhanceView.as 2017-3-28 下午7:10:22
	 * version 1.0
	 *
	 */
	public class GenEnhanceView extends BaseDialog
	{
		private var _data:Object;;
		//选中的单元格
		private var _selectedItems:Array=[];
		private const MIN_NUM:Number = 20;
		private var BAR_W:Number;
		private var BAR_H:Number;
		private var _curLv:int;
		private var _delLv:int = 1;
		private var _canLvUp:Boolean = false;
		
		private var _frameAni:Animation;
		private var _lightAni:Animation;
		/**常量-属性数量*/
		private const PRO_NUM:int = 1;
		public function GenEnhanceView()
		{
			super();
		}
		
		private function formatGene():void{
//			trace("formatGene:::::::::::::::::::",_data);
			var geneInfo:Object;
			var nextInfo:Object;
			var curExp:Number;
			_canLvUp = false;
			if(_data is ItemData){
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.iid, _data.exPro.level);
				nextInfo = DBGeneList.getGeneInfoByItemId(_data.iid, parseInt(_data.exPro.level)+_delLv);
				_curLv = _data.exPro.level || 1
				curExp = _data.exPro.exp;
			}else{
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.genenId, _data.level);
				nextInfo = DBGeneList.getGeneInfoByItemId(_data.genenId, parseInt(_data.level)+_delLv);
				_curLv = _data.level
				curExp = _data.exp
			}
			view.lvTF_0.text = "Lv."+_curLv;
			view.lvTF_1.text = "";
			if(geneInfo){
//				trace("geneInfo-------------------------",geneInfo);
				var totalExp:Number = parseInt(geneInfo.exp);
				view.expTF.text = curExp+"/"+totalExp;
				//进度条
				var per:Number = curExp/totalExp;
				this.view.expBar.scrollRect = new Rectangle(0,0, BAR_W*per,	BAR_H);
				
				var pro:Object = DBGeneList.parsePro(geneInfo.attribute);
				if(nextInfo){
					var nextPro:Object = DBGeneList.parsePro(nextInfo.attribute);
					view.lvTF_1.text = "Lv."+(_curLv+_delLv);
					_canLvUp = true;
				}
				
				var index:int = 0;
				for(var i:String in (nextPro || pro)){
					view["p_"+index].skin = "common/icons/"+XUtils.getIconName(i)+".png";
					view["vTF_"+index].text = (pro[i] || 0)+"";
					view["p_"+index].visible = true;
					view["vTF_"+index].visible = true;
					
					view["vTF_"+index+"_1"].text = (nextPro?nextPro[i]:"");
					view["a_"+index].visible = true;
					view["vTF_"+index+"_1"].visible = true;
					index ++;
					//
					if(index >= PRO_NUM){
						break;
					}
				}
				for(var j:int = index; j<PRO_NUM; j++){
					view["p_"+j].visible = false
					view["p_"+j].visible = false
					view["a_"+j].visible = false;
					view["vTF_"+j+"_1"].visible = false;
					view["vTF_"+j].visible = false;
				}
				
				if(!nextInfo){
					view.lvTF_1.text = GameLanguage.getLangByKey("L_A_38052");
					view.expTF.text = GameLanguage.getLangByKey("L_A_38052");
					view.vTF_0_1.text = GameLanguage.getLangByKey("L_A_38052");
				}
			}
			
			this.view.preBar.scrollRect = new Rectangle(0,0, 0,	BAR_H);
			var vo:ItemVo = DBItem.getItemData(_data.iid || _data.genenId);
			view.nameTF.text = GameLanguage.getLangByKey(vo.name);
			view.geneBg.skin = "common/i"+(vo.quality-1)+".png";
			
			//
			view.icon.graphics.clear();
			view.icon.loadImage("appRes/icon/itemIcon/"+vo.icon+".png");
			if(!_canLvUp){
				this.view.enhanceBtn.disabled = true;
			}
		}
		
		private function onResult(cmd:int, ...args):void{
			trace("G_Enhance_OnResult",args);
			switch(cmd){
				case ServiceConst.G_ENHANCE:
					_delLv = 1;
					//var lvUp:Boolean = false;
					var info:Object = args[1];
					if(_data is ItemData){
						/*if(_curLv < parseInt(info[2])){
							lvUp = true;
						}*/
						this._data.exPro.exp = info[1];
						this._data.exPro.level = info[2];
					}else{
						/*if(_curLv < parseInt(info[2])){
							lvUp = true;
						}*/
						this._data.exp = info[1];
						this._data.level = info[2];
						Signal.intance.event(GeneEquipView.UPDATE);
					}
					for(var i:int=0; i<_selectedItems.length; i++){
						_selectedItems[i].clicked = false;
					}
					_selectedItems.length = 0;
					view.enhanceBtn.disabled = true;
					
					formatGene();
					
					//if(lvUp){
						if(!_frameAni){
							_frameAni = new Animation();
							_frameAni.pos(173,310);
						}
						view.addChild(_frameAni);
						_frameAni.loadAtlas("appRes/atlas/geneEquip/effect/frame.json");
						_frameAni.autoPlay = true;
						XUtils.autoRecyle(_frameAni)
						
						
						if(!_lightAni){
							_lightAni = new Animation();
							_lightAni.pos(173,310);
						}
						view.addChild(_lightAni);
						_lightAni.loadAtlas("appRes/atlas/geneEquip/effect/light.json");
						_lightAni.autoPlay = true;
						XUtils.autoRecyle(_lightAni)
					//}
					break;
			}
			
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case this.view.closeBtn:
				case this.view.backBtn:
					this.close();
					break;
				case this.view.enhanceBtn:
					var ids:String = "";
					for(var i:uint=0; i<this._selectedItems.length; i++){
						var data:ItemData = this._selectedItems[i];
						if(data){
							if(ids == ""){
								ids = data.key;
							}else{
								ids += "-"+data.key;
							}
						}
					}
					if(_data is ItemData){
						if(ids){
							WebSocketNetService.instance.sendData(ServiceConst.G_ENHANCE, [ids,_data.key]);
						}
					}else{
						if(ids){
							var geneInfo:Object = DBGeneList.getGeneInfoByItemId(_data.genenId, _data.level);
							WebSocketNetService.instance.sendData(ServiceConst.G_ENHANCE, [ids,0,GeneEquipView.curSoldier.unitId,geneInfo.location]);
						}
					}
					break;
			}
		}
		
		private function onBagEvent():void{
			var list:Array = BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_GENE],[ItemConst.GENE_STYPE_1,ItemConst.GENE_STYPE_2,ItemConst.GENE_STYPE_3,ItemConst.GENE_STYPE_4]);
			//TODO:排除自己
			if(_data is ItemData){
				for(var i:int=0; i< list.length; i++){
					if(list[i] == _data){
						list.splice(i, 1);
						break;
					}
				}
			}
			list.sort(onSort);
			var size:Number = Math.ceil(list.length/4) * 4;
			size = Math.max(MIN_NUM, size);
			for(i = list.length; i<size; i++){
				list.push(null);
			}
			this.view.itemList.array = list;
		}
		
		private function onSort(obj1:Object, obj2:Object):int{
			if(obj1.iid < obj2.iid){
				return -1;
			}
			return 1;
		}
		
		private function onRender(cell:Box,index:int):void{
			var item:GeneItemCell = cell as GeneItemCell;
			if(item.clicked){
				if(_selectedItems.indexOf(item.data) == -1){
					item.clicked = false;
				}
			}else{
				if(_selectedItems.indexOf(item.data) != -1){
					item.clicked = true;
				}
			}
		}
		
		private function onItemClick(e:Event, index:Number):void{
			if(e.type == Event.CLICK){
				var data:Object = view.itemList.getItem(index);
				if(!data){
					return;
				}
				var item:GeneItemCell = view.itemList.getCell(index) as GeneItemCell;
				var data:Object = view.itemList.getItem(index);
				if(item.clicked){
					item.clicked = false;
					delItem(data);
					if(_selectedItems.length == 0){
						view.enhanceBtn.disabled = true;
					}
				}else{
					item.clicked = true;
					_selectedItems.push(data);
					_canLvUp && (view.enhanceBtn.disabled = false);
					
					if (!User.getInstance().isInGuilding)
					{
						XTipManager.showTip([item.data,GeneTip.ONLY_SHOW], GeneTip, false);
						if(XTipManager.curTip){
							XTipManager.curTip.x -= 40;
						}
					}
					
					
				}
				caculateExp();
			}
		}
		
		private function caculateExp():void{
			var exp:int = 0;
			var data:ItemData;
			var geneInfo:Object;
			var curExp:Number;
			for(var i:Number=0; i<_selectedItems.length; i++){
				data = _selectedItems[i];
				exp += parseInt(data.exPro.exp);
				geneInfo = DBGeneList.getGeneInfoByItemId(data.iid, data.exPro.level);
				exp += parseInt(geneInfo.base_exp);
			}
			
			trace("exp.......................",exp);
			
			//=====================
			var lv:Number;
			var id:Number;
			if(_data is ItemData){
				curExp = parseInt(_data.exPro.exp)+exp;
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.iid, _data.exPro.level);
				lv = _data.exPro.level;
				id = _data.iid
			}else{
				curExp = parseInt(_data.exp)+exp;
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.genenId, _data.level);
				lv = _data.level;
				id = _data.genenId
			}
			
			//计算升级效果
			var info:Object = DBGeneList.getLvInfo(lv, id, curExp);
			var nextGeneInfo:Object;
			nextGeneInfo = info.info;
			
			_delLv = Math.max(1, nextGeneInfo.level - geneInfo.level);
			formatGene();
			
			var totalExp:Number = parseInt(geneInfo.exp);
			//
			view.expTF.text = curExp+"/"+totalExp;
			
			//进度条
			var per:Number = curExp/totalExp
			this.view.preBar.scrollRect = new Rectangle(0,0, BAR_W*per,	BAR_H);
		}
		
		private function delItem(data:Object):void{
			for(var i:uint=0; i<this._selectedItems.length; i++){
				if(_selectedItems[i] == data){
					_selectedItems.splice(i,1);
					break;
				}
			}
		}
		
		override public function show(...args):void{
			super.show();
			this._data = args[0];
			_delLv = 1;
			formatGene();
			var list:Array = BagManager.instance.getItemListByType();
			if(!list){
				Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, onBagEvent);
			}else{
				onBagEvent();
			}
			view.enhanceBtn.disabled = true;
		}
		
		override public function close():void{
			for(var i:int=0; i<_selectedItems.length; i++){
				_selectedItems[i].clicked = false;
			}
			_selectedItems.length = 0;
			_frameAni && _frameAni.clear();
			_frameAni && _lightAni.clear();
			Loader.clearRes("appRes/atlas/geneEquip/effect/frame.json");
			Loader.clearRes("appRes/atlas/geneEquip/effect/light.json");
			super.close();
		}
		
		//重写回收
		override public function dispose():void{
			this.destroy();
			UIRegisteredMgr.DelUi("EnhanceRight");
			UIRegisteredMgr.DelUi("EnhanceLeft");
			UIRegisteredMgr.DelUi("GeneBack");
			UIRegisteredMgr.DelUi("GeneEnhanceBtn");
			UIRegisteredMgr.DelUi("GeneEnhanceCloseBtn");
			UIRegisteredMgr.DelUi("GenList");
		}
		
		override public function createUI():void{
			this._view = new GenenHanceUI();
			this.addChild(this._view);
			
			view.itemList.itemRender = GeneItemCell;
			view.itemList.mouseHandler = new Handler(this, this.onItemClick);
			view.itemList.vScrollBarSkin=""
				
			BAR_W = view.expBar.width;
			BAR_H = view.expBar.height;
			
			UIRegisteredMgr.AddUI(view.bagBox,"EnhanceRight");
			UIRegisteredMgr.AddUI(view.leftBg,"EnhanceLeft");
			UIRegisteredMgr.AddUI(view.backBtn,"GeneBack");
			UIRegisteredMgr.AddUI(view.enhanceBtn,"GeneEnhanceBtn");
			UIRegisteredMgr.AddUI(view.closeBtn,"GeneEnhanceCloseBtn");
			UIRegisteredMgr.AddUI(view.itemList,"GenList");
		}
		
		override public function addEvent():void{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.G_ENHANCE),this,onResult,[ServiceConst.G_ENHANCE]);
			this.view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, onBagEvent);
			view.itemList.renderHandler = Handler.create(this, this.onRender, null, false)
			super.addEvent();
		}
		
		override public function removeEvent():void{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.G_ENHANCE),this,onResult);
			view.itemList.renderHandler = null
			this.view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, onBagEvent);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, onBagEvent);
			super.removeEvent();
		}
		
		private function get view():GenenHanceUI{
			return this._view as GenenHanceUI;
		}
	}
}