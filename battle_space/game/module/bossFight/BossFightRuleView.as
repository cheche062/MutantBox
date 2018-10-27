package game.module.bossFight
{
	import MornUI.bossFight.BossFightRuleViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.vo.WorldBossBaseParamVo;
	import game.global.vo.worldBoss.BossFightInfoVo;
	
	import laya.events.Event;
	
	public class BossFightRuleView extends BaseDialog
	{
		private var m_fightBoss:BossFightInfoVo;
		private var m_worldBossBaseParamVo:WorldBossBaseParamVo;
		public function BossFightRuleView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new BossFightRuleViewUI();
			this.addChild(_view);
			onInitUI();
		}
		
		/**初始化ui*/
		private function onInitUI():void
		{
			// TODO Auto Generated method stub
			m_worldBossBaseParamVo=GameConfigManager.boss_param;
			this.view.RuleText0.text="1.Once your camp reaches Level "+m_worldBossBaseParamVo.openLevel+", you can fight the boss.";
			this.view.RuleText1.text="2.The boss battle occurs once every "+"1"+" weeks at "+m_worldBossBaseParamVo.openDay+", and continues for "+m_worldBossBaseParamVo.continueDay+" days.";
			this.view.RuleText2.text="3.Once the event begins, players get "+m_worldBossBaseParamVo.freeFightTime+" free daily chances to fight the boss.";
		}		
		
		/**加入监听*/
		override public function addEvent():void
		{
			this.on(Event.CLICK,this,this.onClickHander);
		}
		
		
		/**移除监听*/
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
		}
		
		/**
		 * 点击监听
		 * @param e
		 * 
		 */
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					this.close();
					break;
			}
		}
		
		private function get view():BossFightRuleViewUI{
			return _view as BossFightRuleViewUI;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			//trace(1,"destroy BossFightRuleView");
			m_fightBoss = null;
			m_worldBossBaseParamVo = null;
			super.destroy(destroyChild);
		} 
	}
}