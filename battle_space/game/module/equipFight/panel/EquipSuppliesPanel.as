package game.module.equipFight.panel
{
	import MornUI.equip.EquipStrongViewUI;
	import MornUI.equipFight.EquipFightSuppliesViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.module.equipFight.cell.EquipSuppliesCell;
	import game.module.equipFight.data.EquipBuyData;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class EquipSuppliesPanel extends BaseDialog
	{
		private var _infoData:Object;
		private var _dList:Array = [];
		private var _dDic:Object = [];
		
		
		public function EquipSuppliesPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			
			var json:* = ResourceManager.instance.getResByURL("config/galaxy_supply.json");
			if(json)
			{
				for each (var c:* in json) 
				{
					var d:EquipBuyData = new EquipBuyData();
					d.sell_id = Number(c.sell_id);
					d.item = c.item;
					d.maxNum = d.num = Number(c.num);
					d.price = c.price;
					_dDic[d.sell_id] = d;
					_dList.push(d);
				}
			}
			
			
			view.m_list.repeatX = 3;
			view.m_list.repeatY = 2;
			view.m_list.itemRender = EquipSuppliesCell;
			view.m_list.array = [];
			view.m_list.scrollBar.height = 200;
			view.m_list.array = _dList;
			view.m_list.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.m_list.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			
			
			
		}
		
		public function get view():EquipFightSuppliesViewUI{
			if(!_view){
				_view = new EquipFightSuppliesViewUI();
			}
			return _view as EquipFightSuppliesViewUI;
		}
		
		
		override public function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			getInfo();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		public function getInfo():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.EQUIO_SUPPLIES_INFO,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIO_SUPPLIES_INFO),
				this,getInfoBack);
		}
		
		
		private function getInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getInfoBack);
			_infoData = args[1];
			
			for each (var d:EquipBuyData in _dList) 
			{
				d.num = d.maxNum;
			}
			
			
			var prop:Array = _infoData.prop;
			for (var i:int = 0; i < prop.length; i++) 
			{
				var d:EquipBuyData = _dDic[prop[i].id];
				if(d)
					d.num = d.maxNum - prop[i].boughtTimes;
			}
			
			
			
			bindData();
		}
		
		private function bindData():void
		{
			view.wNumLbl.text = _infoData.supply;
			
			for each (var d:EquipBuyData in _dList) 
			{
				d.state = d.priceNum > Number(_infoData.supply) ? 0 : 1;
			}
			view.m_list.refresh();
		}
		
		
		
		
		public override function addEvent():void{
			super.addEvent();
			view.dbImg.mouseEnabled = true;
			view.closeBtn.on(Event.CLICK,this,close);
			view.addBtn.on(Event.CLICK,this,addClick);
			view.dbImg.on(Event.CLICK,this,dbImgClick);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIO_SUPPLIES_BUY),
				this,buyItemBack);
		}
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.addBtn.off(Event.CLICK,this,addClick);
			view.dbImg.off(Event.CLICK,this,dbImgClick);
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.EQUIO_SUPPLIES_BUY),
				this,buyItemBack);
		}
		
		private function dbImgClick(e:Event):void
		{
			ItemTips.showTip("10");	
		}
		
		private function buyItemBack(... args):void
		{
//			XTip.showTip("L_A_68");
			var d:EquipBuyData = _dDic[args[1]];
			if(d)
			{
				d.num = d.maxNum - Number(args[4]);
				XItemTip.showTip(d.item);
			}
			_infoData.supply = args[3];
			view.m_list.refresh();
			
			bindData();
		}
		
		private function addClick(e:Event):void
		{
//			var alertStr:String = "L_A_44854";
//			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,alertStr,0,function(v:uint):void{
//				if(v == AlertType.RETURN_YES)
//				{
//					addFun();
//				}
//			});
			var item:ItemData = new ItemData();
			item.iid = DBItem.WATER;
			item.inum = 50;
			ConsumeHelp.Consume([item],Handler.create(this,addFun),GameLanguage.getLangByKey("L_A_44854"));
		}
		
		
		private function addFun():void{
			WebSocketNetService.instance.sendData(ServiceConst.EQUIO_SUPPLIES_BUYDB,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIO_SUPPLIES_BUYDB),
				this,addFunBack);
		}
		
		private function addFunBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getInfoBack);
			
			_infoData.supply = args[1];
			bindData();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_infoData = null;
			_dList = null;
			_dDic = null;
			super.destroy(destroyChild);
		}
	}
}