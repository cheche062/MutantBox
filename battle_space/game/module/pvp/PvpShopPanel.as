package game.module.pvp
{
	import MornUI.fightingChapter.ChapterLevelInfoViewUI;
	import MornUI.pvpFight.PvpShopViewUI;
	
	import game.common.AnimationUtil;
	import game.common.UIHelp;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.pvpShopItemVo;
	import game.module.bag.cell.ItemCell4;
	import game.module.bag.cell.needItemCell;
	import game.module.pvp.cell.PvpShopCell;
	
	import laya.events.Event;
	
	public class PvpShopPanel extends BaseDialog
	{
		public var needCell:needItemCell;
		public function PvpShopPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		
		public function get view():PvpShopViewUI{
			if(!_view)
				_view = new PvpShopViewUI();
			return _view as PvpShopViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			
			view.shopList.repeatX = 4;
			view.shopList.repeatY = 2;
			view.shopList.itemRender = PvpShopCell;
//			view.shopList.spaceX = 3;
//			view.shopList.spaceY = 3;
			view.shopList.array = [];
			view.shopList.scrollBar.height = 279;
			view.shopList.scrollBar.pos(784,1);
			view.shopList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.shopList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			
			needCell = new needItemCell();
			view.needBox.addChild(needCell);
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			view.shopList.array = GameConfigManager.pvpShopItemVos;
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			Signal.intance.on(PvpManager.PVP_TOKENNUMBER_CHANGE_EVENT,this,tokennumChange);
			tokennumChange();
			
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			Signal.intance.off(PvpManager.PVP_TOKENNUMBER_CHANGE_EVENT,this,tokennumChange);
		}
		
		private function tokennumChange(e:Event = null):void{
//			view.numLbl.text = PvpManager.intance.tokenNumber;
			var idata:ItemData = new ItemData();
			idata.iid = DBItem.PVP_TOKEN;
			idata.inum = User.getInstance().token;
			needCell.data = idata;
			UIHelp.crossLayout(view.needBox);
			view.needBox.x = view.bBox.width - view.needBox.width >> 1;
			var ar:Array =  GameConfigManager.pvpShopItemVos;
			if(ar)
			{
				ar.sort(shopListSort);
				view.shopList.refresh();
			}
			
		}
		
		private function shopListSort(v1:pvpShopItemVo,v2:pvpShopItemVo):Number{
			if(v1.state > v2.state) 
				return -1;
			else if(v1.state < v2.state) 
				return 1;
			if(v1.id > v2.id) 
				return 1;
			else if(v1.id < v2.id) 
				return -1;
			return 0;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			needCell = null;
			super.destroy(destroyChild);
		}
		
		
	}
}