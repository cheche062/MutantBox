package game.module.fighting.panel
{
	import MornUI.fightResults.FightReportOverUI;
	import MornUI.panels.BagViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class FightReportOverView extends BaseDialog
	{
		public function FightReportOverView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
		}
		
		private var han1:Handler;
		override public function show(...args):void{
			super.show(args);
			var ar:Array = args[0];
			han1 = ar && ar.length > 0 ? ar[0] : null;
		}
		
		public function get view():FightReportOverUI{
			if(!_view){
				_view = new FightReportOverUI();
			}
			return _view as FightReportOverUI;
		}
		
		override public function addEvent():void{
			super.addEvent();

			view.closeBtn.on(Event.CLICK,this,close);
			view.cbBtn.on(Event.CLICK,this,cbFun);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.cbBtn.off(Event.CLICK,this,cbFun);
		}
		
		public override function close():void{
			if(han1 != null)
			{
				var cpH:Handler = han1;
				han1  =  null;
				cpH.runWith(0);
			}
			
			super.close();
		}
		
		private function cbFun(e:Event):void
		{
			if(han1 != null)
			{
				var cpH:Handler = han1;
				han1  =  null;
				cpH.runWith(1);
			}
			
			super.close();
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightReportOverView");
			han1 = null;
			
			super.destroy(destroyChild);
		}
	}
}