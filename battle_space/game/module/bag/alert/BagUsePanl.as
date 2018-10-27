package game.module.bag.alert
{
	import MornUI.fightingChapter.ShaoDangViewUI;
	import MornUI.panels.BagSellViewUI;
	import MornUI.panels.BagUseViewUI;
	
	import game.common.AnimationUtil;
	import game.common.InputSetCommon;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.ModuleName;
	import game.global.consts.ItemConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	
	import laya.events.Event;
	
	public class BagUsePanl extends BaseDialog
	{
		private var _itemCell:ItemCell;
		private var _inputSC:InputSetCommon;
		private var _itemData:ItemData;
		
		public function BagUsePanl()
		{
			super();
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			_itemData = ar[0];
			bindData();
			trace("show:::-->",args);
		} 
		
		private function bindData():void
		{
			if(_itemData)
			{
				_inputSC.minNum = 1;
				_inputSC.maxNum = _itemData.inum;
				_inputSC.text = 1;
				
				_itemCell.dataSource = _itemData;
				this.view.tileLbl.text = _itemData.vo.name;
			}
		}
		
		
		public function get view():BagUseViewUI{
			if(!_view){
				_view = new BagUseViewUI();
			}
			return _view as BagUseViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			_inputSC = InputSetCommon.create( view.numInput ,
				view.leftBtn,
				view.rightBtn
			);
			
			_itemCell = new ItemCell();
			addChild(_itemCell);
			_itemCell.pos(view.pi.x,view.pi.y);
			view.pi.removeSelf();
			
			
		}
		
		
		private function okBtnFun(e:Event):void{
			switch(_itemData.vo.type)
			{
				case ItemConst.ITEM_TYPE_GIFTBAG:
				{
					BagManager.instance.useItem(_itemData.key,_inputSC.text);
					break;
				}
				case ItemConst.ITEM_TYPE_RANDOM:
				{
					BagManager.instance.useItem2(_itemData.key,_inputSC.text);
					break;
				}
			}
				
			this.close();
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.okBtn.on(Event.CLICK,this,okBtnFun);
			_inputSC.addEvent();
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.okBtn.off(Event.CLICK,this,okBtnFun);
			_inputSC.removeEvent();
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BagUsePanl");
			_inputSC.dispose();
			_itemCell = null;
			_inputSC = null;
			_itemData = null;
			
			super.destroy(destroyChild);
		} 
	}
}