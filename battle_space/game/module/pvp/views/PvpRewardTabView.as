package game.module.pvp.views
{
	import MornUI.pvpFight.pvpRewardT1UI;
	
	import game.common.ITabPanel;
	import game.common.UIHelp;
	import game.global.GameConfigManager;
	import game.global.event.Signal;
	import game.global.vo.PvpRewardVo;
	import game.global.vo.pvpShopItemVo;
	import game.module.pvp.PvpManager;
	import game.module.pvp.cell.PvpLogCell;
	import game.module.pvp.cell.PvpRewardCell1;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.View;
	
	public class PvpRewardTabView extends pvpRewardT1UI implements ITabPanel
	{
		public function PvpRewardTabView()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this.rList.repeatX = 1;
			this.rList.repeatY = 4;
			this.rList.itemRender = PvpRewardCell1;
			this.rList.spaceY = 10;
			this.rList.array = GameConfigManager.pvpRewardVos;
			this.rList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			this.rList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
		}
		
		public function addEvent():void
		{
			Signal.intance.on(PvpManager.REWARDCHANGE_EVENT,this,bindData);
			bindData();
		}
		public function removeEvent():void
		{
			Signal.intance.off(PvpManager.REWARDCHANGE_EVENT,this,bindData);
		}
		
		private function bindData():void{
			this.ftimerLbl.text = PvpManager.intance.userInfo.matchTimes;
			//UIHelp.crossLayout(this.Nbox);
			//this.Nbox.x = (this.Nbox.parent as Image).width - this.Nbox.width >> 1;
			var ar:Array = GameConfigManager.pvpRewardVos;
			ar.sort(sortFun)
			this.rList.refresh();
		}
		
		
		private function sortFun(v1:PvpRewardVo,v2:PvpRewardVo):Number{
			if(v1.state > v2.state) 
				return 1;
			else if(v1.state < v2.state) 
				return -1;
			if(v1.num > v2.num) 
				return 1;
			else if(v1.num < v2.num) 
				return -1;
			return 0;
		}
	}
}