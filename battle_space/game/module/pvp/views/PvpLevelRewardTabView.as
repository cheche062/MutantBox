package game.module.pvp.views
{
	import MornUI.pvpFight.pvpRewardT2UI;
	
	import game.common.ITabPanel;
	import game.global.GameConfigManager;
	import game.global.vo.PvpLevelVo;
	import game.module.pvp.cell.PvpRewardCell1;
	import game.module.pvp.cell.PvpRewardCell2;
	
	public class PvpLevelRewardTabView extends pvpRewardT2UI implements ITabPanel
	{
		public function PvpLevelRewardTabView()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this.rList.repeatX = 1;
			this.rList.repeatY = 4;
			this.rList.itemRender = PvpRewardCell2;
			this.rList.spaceY = 10;
			var ar:Array = GameConfigManager.pvpLevelVoList;
			var ar2:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
				var vo:PvpLevelVo = ar[i];
				if(vo.rewardList)
				{
					ar2.push(vo);
				}
			}
			
			this.rList.array = ar2;
			this.rList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			this.rList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
		}
		
		public function addEvent():void
		{
			this.rList.refresh();
		}
		
		public function removeEvent():void
		{
		}
	}
}