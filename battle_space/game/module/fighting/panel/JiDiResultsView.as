package game.module.fighting.panel
{
	import MornUI.fightResults.JiDiResultsUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.UIHelp;
	import game.global.GameConfigManager;
	import game.global.StringUtil;
	import game.global.cond.ConditionsManger;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	
	import laya.filters.ColorFilter;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Handler;

	public class JiDiResultsView extends BaseFightResultsView
	{
		protected var rewardList:RewardList;
		protected var sList:RewardList;
		protected var mV:JiDiResultsUI;
		
		public function JiDiResultsView()
		{
			super();
			rewardList = new RewardList();
		}
		
		public override function init():void
		{
			mV = new JiDiResultsUI();
			addChild(mV);
			this.closeBtn = mV.closeBtn;
			this.tileImg = mV.tileImg;
			this.tileImg.y = -15;
			this.bgImg = mV.bgImg;
			
			rewardList.itemRender = ItemCell;
			rewardList.itemWidth = ItemCell.itemWidth;
			rewardList.itemHeight = ItemCell.itemHeight;
			mV.rewardBox.addChild(rewardList);
			
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
			
			tileImg.graphics.clear();
			tileImg.loadImage(
				ResourceManager.instance.getLangImageUrl(data.isWin ? "victory.png":"lose.png")
				,0,0,0,0,
				Handler.create(this,tileLoadeBack)
			);
			if(data.isWin)
			{
				var reward:Array = [];
				if(data.reward && data.reward.length)
				{
					for (var i:int = 0; i < data.reward.length; i++) 
					{
						var idata:ItemData = data.reward[i];
						if(idata.iid != 8) reward.push(idata);
					}
				}
				
				
				if(reward && reward.length)
				{
					mV.rewardBox.visible = true;
					rewardList.array = reward;
//					mV.rewardBox.width = rewardList.x + rewardList.width;
				}else
				{
					mV.rewardBox.visible = false;
				}
				mV.cubLbl2.color = "#69fa6e";
				mV.cubadImg.visible = mV.cubadLbl.visible = true;
				mV.cubLbl2.text = StringUtil.substitute("{0}(",data.old_cup + data.cup);
				mV.cubadLbl.text = StringUtil.substitute("{0})", data.cup);
//				mV.cubLbl2.x = mV.cupTile.textField.textWidth + 5;
//				mV.cubadImg.x = mV.cubLbl2.x + mV.cubLbl2.textField.textWidth;
//				mV.cubadLbl.x = mV.cubadImg.x + mV.cubadImg.width;
//				mV.cupBox.width = mV.cubadLbl.x + mV.cubadLbl.textField.textWidth;
				UIHelp.crossLayout(mV.cupBox);
				
			}else
			{
				mV.rewardBox.visible = false;
				mV.cubadImg.visible = mV.cubadLbl.visible = false;
				mV.cubLbl2.color = "#9feaff";
				mV.cubLbl2.text = StringUtil.substitute("{0}(--)",data.old_cup);
//				mV.cubLbl2.x = mV.cupTile.textField.textWidth + 5;
//				mV.cupBox.width = mV.cubLbl2.x + mV.cubLbl2.textField.textWidth;
				UIHelp.crossLayout(mV.rewardBox);
			}
			
			if(mV.rewardBox.visible){
//				mV.rewardBox.x = mV.cupBox.x + mV.cupBox.width + jg;
				rewardList.pos( mV.rewardBox.width - rewardList.width >> 1 ,  mV.rewardBox.height - rewardList.height >> 1)
			}
			mV.cupBox.x = (width - mV.cupBox.width)/2;
			sList.array = [];
			
			sList.array = BaseFightResultsView.filterSoldierData(data.soldierData);
			sList.x = width - sList.width >> 1;
			
			mV.noDie.visible = !sList.array.length;
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			rewardList = null;
			sList = null;
			mV = null;
			
			super.destroy(destroyChild);
			
		}
	}
}