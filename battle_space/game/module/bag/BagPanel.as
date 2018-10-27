/***
 *作者：罗维
 */
package game.module.bag
{
	import MornUI.panels.BagViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ImageTab;
	import game.common.List2;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.data.ItemCell2;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.module.bag.cell.ItemCell4;
	import game.module.mission.MissionItem;
	
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.List;
	import laya.utils.Handler;
	
	public class BagPanel extends BaseView
	{
		private var _tab:ImageTab;
		private var m_list:List;
		private var tabDataList:Array = [];
		private var selItemC:ItemCell;
		private var _selectData:ItemData;
		private var _leftSelectIndex:int;
		
		public function BagPanel(obj:Object)
		{
//			if(obj)
//			{
//				alert(obj.msg);
//			}
			super();
//			this._m_iPositionType = LayerManager.LEFTUP;
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			
			onStageResize();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
	
		override public function onStageResize():void{
			view.height = stage.height;
			
			// 1024  768
			view.bg.height = view.height;
			view.bg.width = Math.max(1024 / 768 * view.bg.height, view.width);
			
		}
		public function get view():BagViewUI{
			if(!_view){
				_view = new BagViewUI();
			}
			return _view as BagViewUI;
		}
		
		
		private function finishingListData(ar:Array):Array{
			var maxNum:Number = m_list.repeatX * m_list.repeatY;
			var bq:Number;
			if(ar.length < maxNum)
			{
				bq = maxNum - ar.length;
			}else
			{
				bq = m_list.repeatX - ar.length % m_list.repeatX;
			}
			
			if(bq){
				for (var j:int = 0; j < bq; j++) 
				{
					ar.push(null);
				}
			}
			return ar;
		}
		
		override public function createUI():void
		{
			GameConfigManager.intance.getEquipParam();
			super.createUI();
			
			this.addChild(view);
			
			var tabjson:Object = ResourceManager.instance.getResByURL("config/bagTabList.json");
			trace("背包标签配置:"+JSON.stringify(tabjson));
			var labels:Array = [];
			if(tabjson)
			{
				for each(var c:* in tabjson) 
				{
					tabDataList.push(c);
					labels.push(c.tabImg);
				}
			}
//			trace("背包配置:"+tabjson);
//			trace("背包分页labels:"+labels);
			view.bg.skin = "appRes/fightingMapImg/pvpBg.jpg";
			
			m_list = new List2();
			m_list.pos( view.m_list.x , view.m_list.y);
			
			m_list.vScrollBarSkin = view.m_list.vScrollBarSkin;
			view.m_list.parent.addChild(m_list);
			view.m_list.removeSelf();
			
			m_list.selectEnable = true;
			m_list.repeatX = 5;
			m_list.repeatY = 5;
			m_list.itemRender = ItemCell4;
			m_list.spaceX = 10;
			m_list.spaceY = 10;
			m_list.array = finishingListData([]);
			m_list.scrollBar.sizeGrid = "6,0,6,0";
			m_list.scrollBar.height = 320;
			m_list.scrollBar.pos(450,7);
			m_list.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			m_list.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			view.dom_info.visible = view.itemNameLbl.visible = false;
//			view.useBtn.disabled = view.sellBtn.disabled = true;
			view.useBtn.visible = false;
			
			_tab = new ImageTab();
			_tab.x = view.c_pos.x-30;
			_tab.y = m_list.y-20;
			_tab.labels = labels.join(",");
			_tab.space = 0;
			_tab.direction = "vertical";
			_tab.selectedIndex = 0;
			(_view as BagViewUI).mainBox.addChild(_tab);
			
			selItemC = new ItemCell2();
			view.itemPi.parent.addChild(selItemC);
			selItemC.pos(view.itemPi.x , view.itemPi.y);
			selItemC.scale(1.5,1.5);
			view.itemPi.removeSelf();
			selItemC.visible = false;
//			this.closeOnBlank = true;
			trace("view.x+"+view.x);
			trace("view.y+"+view.y);
			onStageResize();
		}
		
		override public function addEvent():void{
			super.addEvent();
			m_list.selectEnable = true;
//			m_list.mouseHandler = Handler.create(this,listMouseHandler,null,false);
			m_list.selectHandler = Handler.create(this,listMouseHandler,null,false);
			_tab.selectHandler = Handler.create(this,tabSelectHandler,null,false);
			view.sellBtn.on(Event.CLICK,this,viewBtnClick);
			view.useBtn.on(Event.CLICK,this,viewBtnClick);
			view.sortingBtn.on(Event.CLICK,this,viewSortingBtnClick);
			view.closeBtn.on(Event.CLICK,this,close);
			tabSelectHandler(_tab.selectedIndex,true);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE,this,itemInitBack);
			Signal.intance.on(BagEvent.BAG_EVENT_DEL, this, itemDel);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
//			m_list.mouseHandler = null;
			m_list.selectHandler = null;
			_tab.selectHandler = null;
			view.sellBtn.off(Event.CLICK,this,viewBtnClick);
			view.useBtn.off(Event.CLICK,this,viewBtnClick);
			view.sortingBtn.off(Event.CLICK,this,viewSortingBtnClick);
			view.closeBtn.off(Event.CLICK,this,close);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE,this,itemInitBack);
			Signal.intance.off(BagEvent.BAG_EVENT_DEL, this, itemDel);
		}
		
		private function itemDel(key:String):void
		{
			trace(1,"delete item",key);
			if(_selectData && _selectData.key == key)
			{
				selectIData(null);
			}
//			tabSelectHandler(_tab.selectedIndex,true);
		}
		
		
		private function viewSortingBtnClick(e:Event):void{
			if(BagManager.instance.Sorting())
			{
				tabSelectHandler(_tab.selectedIndex,true);
			}
		}
		
		private function viewBtnClick(e:Event):void{
			if(!_selectData)
				return ;
			switch(e.target)
			{
				case view.sellBtn:
				{
					AlertManager.instance().AlertByType(AlertType.BAGSELLALERT,_selectData,0,function(alertRt:uint,n:Number =0):void{
						if(alertRt == AlertType.RETURN_YES)
						{
							BagManager.instance.sellItem(_selectData.key,n);
						}
					});
					break;
				}
				case view.useBtn:
				{
//					_selectData.inum = 1000;
					if(_selectData)
					{
						if(_selectData.vo.useType == ItemVo.USETYPE_USE)
						{
							XFacade.instance.openModule("BagUsePanl",[_selectData]);
							return;
						}
						if(_selectData.vo.useType == ItemVo.USETYPE_SELECT)
						{
							BagManager.instance.useItemGetRs(_selectData.key);
							return;
						}
						if(_selectData.vo.useType == ItemVo.USETYPE_CHANGENAME)
						{
							XFacade.instance.openModule(ModuleName.SetPlayerNameView,[_selectData.iid]);
							break;
						}
						
						if(_selectData.vo.useMsgPs.length)
						{
//							MissionItem.functionLink(_selectData.vo.useMsg[0],_selectData.vo.useMsg[1]);
							MissionItem.functionLink.apply(this,_selectData.vo.useMsgPs);
							trace("物品使用",_selectData.vo.useMsgPs);
							return ;
						}
					}
					
					break;
				}	
				default:
				{
					break;
				}
			}
		}
		
		
		
		private function listMouseHandler(index:int):void
		{
//			if(evn.type != Event.CLICK)
//				return ;
			
			var ar:Array = m_list.array;
			if(!ar || ar.length <= index)
				return ;
			var idata:ItemData = ar[index];
			selectIData(idata);
//			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[idata.iid];
//			
//			if(l_equipVo!=null)
//			{
//				m_EquipTips=ItemTipManager.getTips(idata,null,null);
//				this.addChild(m_EquipTips);	
//			}
			
			
			
//			for (var i:int = 0; i < m_list.cells.length; i++) 
//			{
//				m_list.cells[i].selected = i == index;
//			}
		}
		
	
		private function selectIData(idata:ItemData):void{
			if(_selectData == idata)
				return ;
			_selectData = idata;
			
			if(!_selectData)
			{
				view.dom_info.visible = view.itemNameLbl.visible =  selItemC.visible = false;
//				view.useBtn.disabled = view.sellBtn.disabled = true;
				view.useBtn.visible = false;
				return;
			}
			
			view.dom_info.visible = view.itemNameLbl.visible =  selItemC.visible = true;
//			selItemC.selected = true;
//			view.useBtn.disabled = view.sellBtn.disabled = false;
			view.sellBtn.disabled = !_selectData.vo.isSell;
			view.useBtn.visible = _selectData.vo.useType || _selectData.vo.useMsgPs.length;
			
			var htmlStr:String = GameLanguage.getLangByKey(_selectData.vo.des);
			htmlStr = GameLanguage.getLangByKey(htmlStr).replace(/##/g,"\n");
			view.dom_info.text = htmlStr;
			view.itemNameLbl.text = GameLanguage.getLangByKey(_selectData.vo.name);
			selItemC.data = _selectData;
			view.light.skin = "bag/c"+(_selectData.vo.quality-1)+".png";
		}
		
		
		
		private function tabSelectHandler(index:int , mandatory:Boolean = false):void
		{
			if(_leftSelectIndex == index && !mandatory)
				return ;
			_leftSelectIndex = index;
			trace("选中标签"+index);
			if(!tabDataList || index >= tabDataList.length)
				return ;
			
			var tabD:Object = tabDataList[index];
			if(!tabD)
				return ;
			
			var ar:Array = [];
			var typeStr:String = tabD.typeList;
			var typeList:Array = typeStr.split(",");
			for (var i:int = 0; i < typeList.length; i++) 
			{
				var tt:Number = Number(typeList[i]);
				if(tt)
					ar.push(tt);
			}
			var itemDataList:Array = BagManager.instance.getItemListByType(ar.length ? ar:null );
			if(!itemDataList)
			{
				Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,itemInitBack);
				return ;
			}
			var s_b:Boolean;
			if(_selectData)
			{
				var sidx:int = itemDataList.indexOf(_selectData);
				if(sidx != -1)
				{
					m_list.selectedIndex  = sidx;
					selectIData(_selectData);
					s_b = true;
				}
			}
			if(!s_b){
				selectIData(_selectData = null);
				m_list.selectedIndex = -1;
			}
			
			m_list.array = finishingListData(itemDataList);
			trace("当前页签下背包数据:"+itemDataList);
		}
		
	
		private function itemInitBack():void{
			tabSelectHandler(_leftSelectIndex,true);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT,this,itemInitBack);
			var selIdx:Number = 0;
			if(_selectData)
			{
				var ii:Number = m_list.array.indexOf(_selectData);
				if(ii != -1)
					selIdx = ii;
			}
			m_list.selectedIndex = selIdx;
			m_list.refresh();
			listMouseHandler(m_list.selectedIndex);
			
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BagPanel");
			_tab = null;
			m_list = null;
			tabDataList = null;
			selItemC = null;
			_selectData = null;
			
			super.destroy(destroyChild);
		}
	}
}