package game.module.bossFight
{
	import MornUI.bossFight.BossFightRankViewUI;
	import MornUI.bossFight.RankingRewardViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.friend.MailCell;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class RankingRewardView extends BaseDialog
	{
		public function RankingRewardView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new RankingRewardViewUI();
			this.addChild(_view);
			onInitUI();
		}
		
		/**初始化ui*/
		private function onInitUI():void
		{
			this.view.TilteText.text=GameLanguage.getLangByKey("L_A_46030");
			this.view.TitleText0.text=GameLanguage.getLangByKey("L_A_46030");
			this.view.TitleText1.text=GameLanguage.getLangByKey("L_A_46026");
			this.view.TitleText2.text=GameLanguage.getLangByKey("L_A_46002");
			this.view.RankList.itemRender=BossFightBossDropCell;
			this.view.RankList.renderHandler = new Handler(this, updateItem);
			this.view.RankList.vScrollBarSkin="";
			this.view.RankList.selectEnable=true;
			this.view.RankList.array=GameConfigManager.boss_level_arr;
		}
		
		private function updateItem(p_cell:BossFightBossDropCell,p_index:int):void
		{
			// TODO Auto Generated method stub
			
		}
		
		/**
		 * 添加监听
		 */
		override public function addEvent():void
		{
			this.on(Event.CLICK,this,this.onClickHander);
		}
		
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					this.close();
					break
			}
		}		
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
		}
		
		private function get view():RankingRewardViewUI{
			return _view as RankingRewardViewUI;
		}
	}
}