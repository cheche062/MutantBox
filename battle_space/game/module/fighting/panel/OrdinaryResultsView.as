package game.module.fighting.panel
{
	import MornUI.fightResults.OrdinaryResultsUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.cond.ConditionsManger;
	import game.global.data.bag.ItemCell;
	import game.global.vo.SkillBuffVo;
	import game.global.vo.StageLevelVo;
	import game.global.vo.VoHasTool;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.cell.failureCell;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.filters.ColorFilter;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.utils.Handler;

	public class OrdinaryResultsView extends BaseFightResultsView
	{
		
		protected var rewardList:RewardList;
		protected var failureList:RewardList;
		protected var sList:RewardList;
		protected var mV:OrdinaryResultsUI;
		public function OrdinaryResultsView()
		{
			super();
			rewardList = new RewardList();
			failureList = new RewardList();
		}
		
		public override function init():void
		{
			mV = new OrdinaryResultsUI();
			addChild(mV);
			this.closeBtn = mV.closeBtn;
			this.tileImg = mV.tileImg;
			this.tileImg.y = -15;
			this.bgImg = mV.bgImg;
			
			rewardList.itemRender = ItemCell;
			rewardList.itemWidth = ItemCell.itemWidth;
			rewardList.itemHeight = ItemCell.itemHeight;
			rewardList.y = mV.piImg.y;
			addChild(rewardList);
			
			failureList.itemRender = failureCell;
			failureList.itemWidth = failureCell.itemWidth;
			failureList.itemHeight = failureCell.itemHeight;
			failureList.y = rewardList.y - 14;
			addChild(failureList);
//			failureList.itemRender
			
			mV.piImg.removeSelf();
			
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
			mV.zkLbl.visible = data.type == FightingResultsData.TYPE_MINE &&  data.isWin;
			if(mV.zkLbl.visible) mV.zkLbl.text = "L_A_54020";
			if(data.type == FightingResultsData.TYPE_BAGUA){
				var str:String = GameLanguage.getLangByKey("L_A_76018");
				str = str.replace(/{(\d+)}/, data.rate);
				mV.tfEx.text = str;
			}else{
				mV.tfEx.text = ""
			}
			//星际迷航特殊处理
			if(FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_STAR && data.isWin){
				mV.zkLbl.visible = true;
				mV.zkLbl.text = "L_A_76219";
			}
			
			tileImg.graphics.clear();
			tileImg.loadImage(
				ResourceManager.instance.getLangImageUrl(data.isWin ? "victory.png":"lose.png")
				,0,0,0,0,
				Handler.create(this,tileLoadeBack)
			);
			var showResult:Boolean = (FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_SHIPWAR)
			if(data.isWin || showResult)
			{
				if(data.reward && data.reward.length)
				{
					rewardList.visible = true;
					rewardList.array = data.reward;
					rewardList.x = width - rewardList.width >> 1;
				}else
				{
					rewardList.visible = false;
				}
				failureList.visible = false;
			}else
			{
				rewardList.visible = false;
				failureList.visible = true;
				
				var json:Object = ResourceManager.instance.getResByURL("config/failure.json");
				var fAr:Array = [];
				if(json)
				{
					for each (var c:Object in json) 
					{
						if(!ConditionsManger.cond(c.condition))
						{
							fAr.push(c);
						}
					}
				}
				failureList.array = fAr;
				failureList.x = width - failureList.width >> 1;
			}
			sList.array = [];
			
//			soldierData = data.soldierData;
			sList.array = BaseFightResultsView.filterSoldierData(data.soldierData);
			sList.x = width - sList.width >> 1;
			
			mV.noDie.visible = !sList.array.length;
		}
		
//		private function showSoldier():void
//		{
//			if(!soldierData || !soldierData.length)
//				return ;
//			sList.addItem(soldierData.shift());
//			trace("sList.addItem");
//			this.timer.once(300,this,showSoldier);
//		}
		
		
		override public function destroy(destroyChild:Boolean=true):void{
			
			rewardList = null;
			failureList = null;
			sList = null;
			mV = null;
			super.destroy(destroyChild);
		}
	}
}