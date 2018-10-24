package game.module.fighting.scene
{
	import game.global.ModuleName;

	public class PveFightingScane extends FightingScene
	{
		public function PveFightingScane(URL:String="", isCanDrag:Boolean=true)
		{
			super(URL, isCanDrag);
		}
		
//		protected override function get fightingViewMName():String{
//			return ModuleName.FightingView_PVP;
//		}
//		
//		override public function initScence():void
//		{
//			super.initScence();
//			this.m_SceneResource="PvPFightingScene";
//		}
	}
}