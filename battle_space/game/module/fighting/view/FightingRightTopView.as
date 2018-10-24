package game.module.fighting.view
{
	import MornUI.fightingView.FightingRightTopView1UI;
	
	import game.common.BossHpProgressBar;
	import game.global.vo.FightUnitVo;
	
	public class FightingRightTopView extends FightingRightTopView1UI
	{
		public var bossHp:BossHpProgressBar;
		
		public function FightingRightTopView()
		{
			super();
			mouseEnabled = mouseThrough = true;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			bossHp = new BossHpProgressBar();
			bossHp.pos(this.hpBox.x , this.hpBox.y);
			addChild(bossHp);
			hpBox.removeSelf();
		}
		
		public function showBoss(vo:FightUnitVo):BossHpProgressBar{
			bossHp.visible = false;
			if(vo)
			{
				bossHp.bindUnitVo(vo);
				bossHp.visible = true;
			}
			this.btnBox.y = bossHp.visible ? 105 : 0;
			return bossHp;
		}
	}
}