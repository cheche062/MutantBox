package game.module.bag.alert
{
	import MornUI.panels.ConsumptionErrorUIUI;
	import MornUI.panels.PurchasePanelUI;
	
	import game.common.RewardList;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.module.chargeView.ChargeView;
	
	import laya.events.Event;
	
	/**
	 *弃用 
	 */
	public class PurchasePanel extends BaseDialog
	{
		public function PurchasePanel()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
		}
		
		public function get view():PurchasePanelUI{
			if(!_view){
				_view = new PurchasePanelUI();
			}
			return _view as PurchasePanelUI;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.sBtn.on(Event.CLICK,this,sFun);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.sBtn.off(Event.CLICK,this,sFun);
		}
		
		private function sFun():void
		{
			XFacade.instance.showModule(ChargeView);
			this.close();
		}
		
	}
}