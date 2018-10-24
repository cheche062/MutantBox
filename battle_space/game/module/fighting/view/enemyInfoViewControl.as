package game.module.fighting.view
{
	import MornUI.fightingViewPvp.enemyInfoViewUI;
	
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.module.pvp.PvpManager;
	
	public class enemyInfoViewControl extends enemyInfoViewUI
	{
		public function enemyInfoViewControl()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
		}
		
		
		public function bindEnemyInfo():void
		{
			if(PvpManager.intance.enemyInfo)
			{
				var obj:Object = PvpManager.intance.enemyInfo;
				nameLbl.text = obj.name;
				heroFace.graphics.clear();
				heroFace.loadImage(UnitPicUtil.getUintPic(obj.topUnit,UnitPicUtil.ICON));
				readyLbl.visible = PvpManager.intance.enemyReady;
				notreadyLbl.visible = !PvpManager.intance.enemyReady;
			}
		}
		
		public function addEvent():void
		{
			Signal.intance.on(PvpManager.ENEMYINFO_EVENT,this,bindEnemyInfo);
		}
		
		public function removeEvent():void
		{
			Signal.intance.off(PvpManager.ENEMYINFO_EVENT,this,bindEnemyInfo);
		}
	}
}