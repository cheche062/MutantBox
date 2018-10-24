package game.module.fighting.scene
{
	import game.global.ModuleName;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.view.FightingView;
	import game.module.fighting.view.PvpFightingView;

	public class PvpFightingScene extends FightingScene
	{
		public function PvpFightingScene(URL:String="", isCanDrag:Boolean=true)
		{
			super(URL, isCanDrag);
		}
		
		override public function initScence():void
		{
			super.initScence();
			this.m_SceneResource="PvPFightingScene";
		}
		
		protected override function get fightingViewMName():String{
			return ModuleName.FightingView_PVP;
		}
		
		public function onAdded(data:*):void
		{
			super.onAdded(data);
			if(data is FightingView)
			{
				(fightingView as PvpFightingView).pvpTopView.start();
				fightingView.dataPool = [];
				FightingManager.intance.addFightingEvent();
			}
		}
	}
}