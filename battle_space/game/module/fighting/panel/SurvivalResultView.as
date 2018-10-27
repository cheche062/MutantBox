package game.module.fighting.panel
{
	import MornUI.fightResults.SurvivalResultUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.global.GameLanguage;
	import game.global.cond.ConditionsManger;
	import game.global.data.bag.ItemCell;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.cell.failureCell;
	import game.module.fighting.scene.FightingScene;
	
	import laya.filters.ColorFilter;
	import laya.utils.Handler;

	/**
	 * SurvivalResultView
	 * author:huhaiming
	 * SurvivalResultView.as 2018-1-19 下午4:23:12
	 * version 1.0
	 *
	 */
	public class SurvivalResultView extends BaseFightResultsView
	{
		protected var sList:RewardList;
		protected var mV:SurvivalResultUI;
		public function SurvivalResultView()
		{
			super();
		}
		
		public override function init():void
		{
			mV = new SurvivalResultUI();
			addChild(mV);
			this.closeBtn = mV.closeBtn;
			this.tileImg = mV.tileImg;
			this.tileImg.y = -15;
			this.bgImg = mV.bgImg;
			
			sList = new RewardList();
			sList.itemRender = FightResultsSoldierCell;
			sList.itemWidth = FightResultsSoldierCell.itemWidth;
			sList.itemHeight = FightResultsSoldierCell.itemHeight;
			mV.pi2.parent.addChild(sList);
			sList.y = mV.pi2.y;
			mV.pi2.removeSelf();
			
		}
		
		public override function bindData():void
		{
			closeBtn.label =  data.turnCard ? "Lucky":"BACK";
			bgImg.filters = data.isWin ? null: [ColorFilter.GRAY];
			var str:String = GameLanguage.getLangByKey("L_A_79009")+(FightingScene.waveNum-1)
			mV.zkLbl.text = str;
			tileImg.graphics.clear();
			tileImg.loadImage(
				ResourceManager.instance.getLangImageUrl(data.isWin ? "victory.png":"lose.png")
				,0,0,0,0,
				Handler.create(this,tileLoadeBack)
			);
			
			sList.array = [];
			
			//			soldierData = data.soldierData;
			sList.array = BaseFightResultsView.filterSoldierData(data.soldierData);
			sList.x = width - sList.width >> 1;
			
			mV.noDie.visible = !sList.array.length;
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			
			sList = null;
			mV = null;
			super.destroy(destroyChild);
		}
	}
}