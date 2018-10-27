package game.module.fighting.panel
{
	import game.global.GameConfigManager;
	import game.global.vo.User;
	import game.module.arena.ArenaMainView;
	import MornUI.fightResults.ArenasResultsUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.UIHelp;
	import game.global.StringUtil;
	import game.global.cond.ConditionsManger;
	import game.global.data.bag.ItemCell;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.cell.RequirementCell;
	import game.module.fighting.cell.failureCell;
	
	import laya.filters.ColorFilter;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;

	public class AreansResultsView extends BaseFightResultsView
	{
		protected var rewardList:RewardList;
		protected var sList:RewardList;
		private var arUi:ArenasResultsUI 
		
		
		public function AreansResultsView()
		{
			super();
			rewardList = new RewardList();
		}
		
		public override function init():void
		{
			arUi = new ArenasResultsUI();
			addChild(arUi);
			this.closeBtn = arUi.closeBtn;
			this.tileImg = arUi.tileImg;
			this.tileImg.y = -15;
			this.bgImg = arUi.bgImg;
			
			rewardList.itemRender = ItemCell;
			rewardList.itemWidth = ItemCell.itemWidth;
			rewardList.itemHeight = ItemCell.itemHeight;
			rewardList.y = arUi.pi1.y;
			rewardList.x = arUi.pi1.x;
			addChild(rewardList);
			
			arUi.pi1.removeSelf();
			
			sList = new RewardList();
			sList.itemRender = FightResultsSoldierCell;
			sList.itemWidth = FightResultsSoldierCell.itemWidth;
			sList.itemHeight = FightResultsSoldierCell.itemHeight;
			arUi.pi2.parent.addChild(sList);
			sList.y = arUi.pi2.y;
			arUi.pi2.removeSelf();
			
//			_scoreLbl = arUi.scoreLbl;
			
		}
		
		
		public override function bindData():void
		{
			closeBtn.label =  data.turnCard ? "Lucky":"BACK";
			bgImg.filters = data.isWin ? null: [ColorFilter.GRAY];
			
			tileImg.graphics.clear();
			tileImg.loadImage(
				ResourceManager.instance.getLangImageUrl(data.isWin ? "victory.png":"lose.png")
				,0,0,0,0,
				Handler.create(this,tileLoadeBack)
			);
			
			if (data.isWin && data.newRank != data.oldRank)
			{
				ArenaMainView.NEED_REFRESH_LIST = true;
			}
			
			
			if(data.reward && data.reward.length)
			{
				rewardList.visible = true;
				rewardList.array = data.reward;
//				rewardList.x = width - rewardList.width >> 1;
			}else
			{
				rewardList.visible = false;
			}
			
//			if(data.point)
//			{
//				_scoreLbl.visible =true;
//				_scoreLbl.text = "+"+data.point;
//			}else
//			{
//				_scoreLbl.visible =false;
//			}
			
			if(data.newRank)
			{
				if(data.newRank == data.oldRank)
				{
					arUi.rankadLbl.visible = arUi.rankadImg.visible = false;
					arUi.rankLbl2.text = StringUtil.substitute("{0}(--)",data.newRank);
				}else
				{
					arUi.rankadLbl.visible = arUi.rankadImg.visible = true;
					arUi.rankLbl2.text = StringUtil.substitute("{0}(", data.newRank);
					if (parseInt(data.oldRank) == 0)
					{
						arUi.rankadLbl.text = StringUtil.substitute("{0})", GameConfigManager.arena_group_vec[User.getInstance().arenaGroup - 1].all - data.newRank + 1);
					}
					else
					{
						arUi.rankadLbl.text = StringUtil.substitute("{0})", data.oldRank - data.newRank);
					}
					
					arUi.rankadImg.x = arUi.rankLbl2.x + arUi.rankLbl2.textField.textWidth;
					arUi.rankadLbl.x = arUi.rankadImg.x + 40;
				}
				UIHelp.crossLayout(arUi.rankBox);
			}
			
			sList.array = [];
			
			//			soldierData = data.soldierData;
			sList.array = BaseFightResultsView.filterSoldierData(data.soldierData);
			sList.x = width - sList.width >> 1;
			
			arUi.noDie.visible = !sList.array.length;
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			rewardList = null;
			sList = null;
			arUi = null;
			
			super.destroy(destroyChild);
		}
	}
}