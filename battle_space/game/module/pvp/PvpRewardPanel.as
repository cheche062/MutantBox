package game.module.pvp
{
	import MornUI.pvpFight.PvpRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ListPanel;
	import game.common.base.BaseDialog;
	import game.module.pvp.views.PvpLevelRewardTabView;
	import game.module.pvp.views.PvpRewardTabView;
	
	import laya.events.Event;
	
	public class PvpRewardPanel extends BaseDialog
	{
		private var listP:ListPanel;
		public function PvpRewardPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function close():void{
			view.panelTab.selectedIndex = -1;
			listP.selIndex = -1;
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			
			super.close();
		}
		
		
		
		public function get view():PvpRewardViewUI{
			if(!_view)
				_view = new PvpRewardViewUI();
			return _view as PvpRewardViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			listP = new ListPanel([PvpRewardTabView,PvpLevelRewardTabView]);
			view.cBox.addChild(listP);
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			view.panelTab.selectedIndex = listP.selIndex = 0;
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.panelTab.on(Event.CHANGE,this,panelTabChange);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.panelTab.off(Event.CHANGE,this,panelTabChange);
		}
		
		private function panelTabChange(e:Event):void
		{
			listP.selIndex = view.panelTab.selectedIndex;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy PvpRewardPanel");
			listP = null;
			
			super.destroy(destroyChild);
		}
	}
}