package game.module.bag.alert
{
	import MornUI.panels.ConsumptionErrorUIUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.base.BaseDialog;
	import game.global.data.ConsumeHelp;
	import game.module.bag.cell.CurrencyCell;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class ConsumeHelpPanel extends BaseDialog
	{
		private var _rList:RewardList;
		private var _wNum:Number = 0;
		private var _handler:Handler;
		
		public function ConsumeHelpPanel()
		{
			super();
		}
		
		
		override public function show(...args):void{
			super.show(args);
//			AnimationUtil.popIn(this);
			var _rAr:Array = args[0][0];
			_wNum = args[0][1];
			_handler = args[0][2];
			
			_rList.array = _rAr;
			_rList.x = view.cBox.width - _rList.width >> 1;
			view.wnum.text = _wNum.toString();
		}
		
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			_rList = new RewardList();
			_rList.itemRender = CurrencyCell;
			_rList.itemWidth = CurrencyCell.itemWidth;
			_rList.itemHeight = CurrencyCell.itemHeight;
			view.cBox.addChild(_rList);
		}
		
		public function get view():ConsumptionErrorUIUI{
			if(!_view){
				_view = new ConsumptionErrorUIUI();
			}
			return _view as ConsumptionErrorUIUI;
		}
		
		
		override public function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.sBtn.on(Event.CLICK,this,sBtnClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.sBtn.off(Event.CLICK,this,sBtnClick);
		}
		
		private function sBtnClick(e:Event):void
		{
			ConsumeHelp.ConsumeWater(_wNum,_handler);
			_handler = null;
			close();
		}
		
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy ConsumeHelpPanel");
			_rList = null;
			_handler = null;
			
			super.destroy(destroyChild);
		} 
	}
}