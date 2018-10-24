package game.module.pvp
{
	import game.common.LayerManager;
	import game.common.ListPanel;
	import game.common.base.BaseDialog;
	import game.global.event.Signal;
	import game.module.pvp.views.PvpMainView;
	import game.module.pvp.views.PvpPiPeiView;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class PvpMainPanel extends BaseDialog
	{
		private var _listPanel:ListPanel;
		
		public function PvpMainPanel()
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
		}
		
		public override function show(...args):void{
			this.size(Laya.stage.width,Laya.stage.height);
			super.show(args);
			
			_listPanel.selIndex = 0;
		}
		
		override public function createUI():void
		{
			super.createUI();
			_listPanel = new ListPanel([PvpMainView,PvpPiPeiView]);
			addChild(_listPanel);
		}
		
		override public function close():void{
			_listPanel.selIndex = -1;
			super.close();
		}
		
		
		public override function addEvent():void
		{
			super.addEvent();
			Signal.intance.on(PvpManager.CANCELPIPEI_EVENT,this,cancelPipei);
		}
		
		public override function removeEvent():void
		{
			super.removeEvent();
			Signal.intance.off(PvpManager.CANCELPIPEI_EVENT,this,cancelPipei);
		}
		
		private function cancelPipei(e:Event):void{
			_listPanel.selIndex = 0;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy PvpMainPanel");
			_listPanel = null;
			
			super.destroy(destroyChild);
		}
	}
}