package game.module.fighting.panel
{
	import MornUI.fightResults.guildeBossResultsUI;
	
	import game.common.starBar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.guild.GuildBossVo;
	
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.ProgressBar;
	
	public class GuildBossRewardsView extends BaseFightResultsView
	{
		private var mV:guildeBossResultsUI;
		private var star:starBar;
		public function GuildBossRewardsView()
		{
			super();
		}
		
		public override function init():void
		{
			mV = new guildeBossResultsUI();
			addChild(mV);
			this.closeBtn = mV.closeBtn;
//			this.tileImg.y = -15;
			this.bgImg = mV.bgImg;
			star = new starBar("fightingResult/xx.png","fightingResult/xxx.png",31,35,0,5);
			mV.klPi.parent.addChild(star);
			
			star.y = mV.klPi.y;
			star.x = (star.parent as Box).width - star.width >> 1
				
			mV.klPi.removeSelf();
		}
		
		public override function bindData():void
		{
			var vo:GuildBossVo = GameConfigManager.intance.getGuildBossInfo(data.id);
			if(vo)
			{
				mV.BossFace.skin = "appRes/icon/guildIcon/"+vo.icon+".png";
				star.barValue = vo.level;
			}
			var s:String = GameLanguage.getLangByKey("L_A_2577");
			mV.hpLbl.text = StringUtil.substitute(s,data.hurt);
			mV.hpBar.value = data.hp / data.maxHp;
			mV.bossHpLbl.text = data.hp +"/"+ data.maxHp;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			star = null;
			mV = null;
			super.destroy(destroyChild);
		}
		
	}
}