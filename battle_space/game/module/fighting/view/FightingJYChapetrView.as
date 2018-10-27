package game.module.fighting.view
{
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.module.fighting.cell.JYGuanQiaCell;

	public class FightingJYChapetrView extends FightingChapetrView
	{
		public static var newOpenStageLevelID:Number = 0;
		
		public function FightingJYChapetrView()
		{
			super();
			isJy = true;
			_rewardBtn.skin = "fightingMap/bg10_1.png";
			
		}
	
		
		protected override function get stageChapterArr():Array{
			return GameConfigManager.stage_chapter_jy_arr;
		}
		
		protected override function get btnClass():Class{
			return JYGuanQiaCell;
		}
		
		protected override function get errStr():String{
			var s:String = GameLanguage.getLangByKey("L_A_50");
			return StringUtil.substitute(s,_data.chapter_condition);
		}
		
		protected override function get newOpenId():Number{
			return FightingJYChapetrView.newOpenStageLevelID;
		}
		protected override function set newOpenId(v:Number):void{
			FightingJYChapetrView.newOpenStageLevelID = v;
		}
	}
}