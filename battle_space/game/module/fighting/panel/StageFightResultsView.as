/***
 *作者：罗维
 */
package game.module.fighting.panel
{
	import game.global.vo.User;
	import MornUI.fightResults.OrdinaryResultsUI;
	import MornUI.fightResults.StageFightResultsUIUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.SoundMgr;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.cond.ConditionsManger;
	import game.global.data.bag.ItemCell;
	import game.global.fighting.BaseUnit;
	import game.global.vo.StageLevelVo;
	import game.global.vo.requirementVo;
	import game.module.bag.BagPanel;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.cell.RequirementCell;
	import game.module.fighting.cell.failureCell;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.ui.UIUtils;
	import laya.utils.Handler;

	public class StageFightResultsView extends BaseFightResultsView
	{
		protected var rewardList:RewardList;
		protected var failureList:RewardList;
		protected var mV:StageFightResultsUIUI;
		protected var sList:RewardList;
		protected var soldierData:Array;
		protected var stars:Array = [];
		
		protected var ect1:Animation;
		protected var ect2:Animation;
		private var _cellList:Array = [];
		private var _sCellList:List;
		private var starEcts:Array = [null,null,null];
		
		public function StageFightResultsView()
		{
			super();
			rewardList = new RewardList();
			failureList = new RewardList();
		}
		
		public override function init():void
		{
			
			mV = new StageFightResultsUIUI();
			addChild(mV);
			this.closeBtn = mV.closeBtn;
			this.tileImg = mV.tileImg;
			this.tileImg.y = -15;
			this.bgImg = mV.bgImg;
			_sCellList = mV.sCellList;
			_sCellList.pos( mV.lrBox.x , mV.lrBox.y);
			_sCellList.itemRender = RequirementCell;
			
			mV.lrBox.removeSelf();
			
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
			
			sList = new RewardList();
			sList.itemRender = FightResultsSoldierCell;
			sList.itemWidth = FightResultsSoldierCell.itemWidth;
			sList.itemHeight = FightResultsSoldierCell.itemHeight;
//			sList.spaceX = -7;
//			sList.repeatY = 1;
//			sList.repeatX = 10;
//			sList.
			mV.pi2.parent.addChild(sList);
//			sList.x = 138;
			sList.y = mV.pi2.y;
			mV.pi2.removeSelf();
			mV.piImg.removeSelf();
			
			for (var i:int = 1; i <= 3; i++) 
			{
				stars.push(mV.getChildByName("star"+i));
			}
			
		}
		
		public override function bindData():void
		{
			closeBtn.label =  data.turnCard ? "Lucky":"BACK";
			bgImg.filters = mV.starBg.filters = data.isWin ? null: [ColorFilter.GRAY];
			tileImg.graphics.clear();
			tileImg.loadImage(
				ResourceManager.instance.getLangImageUrl(data.isWin ? "victory.png":"lose.png")
				,0,0,0,0,
				Handler.create(this,tileLoadeBack)
			);
			
			
			if(data.isWin)
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
				
				if(!ect1)
				{
					ect1 = new Animation();
					ect1.interval = BaseUnit.animationInterval;
					var jsonStr:String = "appRes/effects/liuguang_eff.json";
					ect1.loadAtlas(jsonStr);
					ect1.pivot(175,40);
					ect1.scaleX = -1;
				}
				mV.starBg.addChild(ect1);
				ect1.pos(0,0);
				ect1.play();
				
				if(!ect2)
				{
					ect2 = new Animation();
					ect2.interval = BaseUnit.animationInterval;
					var jsonStr:String = "appRes/effects/liuguang_eff.json";
					ect2.loadAtlas(jsonStr);
					ect2.pivot(175,40);
				}
				mV.starBg.addChild(ect2);
				ect2.pos(mV.starBg.width , 0);
				ect2.play();
			}else
			{
				if(ect1)
				{
					ect1.stop();
					ect1.removeSelf();
				}
				if(ect2)
				{
					ect2.stop();
					ect2.removeSelf();
				}
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
							trace("失败状态：", c);
							fAr.push(c);
						}
					}
				}
				
				if (User.getInstance().chargeNum > 0)
				{
					fAr.unshift({condition:"0=1",icon:"icon_hd",id:"7",name:"L_A_56093"});
				}
				else
				{
					fAr.unshift({condition:"0=1",icon:"icon_sc",id:"6",name:"L_A_56000"});
				}
				if (fAr.length > 5)
				{
					fAr.splice(5);
				}
				failureList.array = fAr;
				failureList.x = width - failureList.width >> 1;
			}
			
			bindStageData();
			
			sList.array = [];
			
			soldierData = data.soldierData;
//			data.soldierData
//			showSoldier();
			sList.array = BaseFightResultsView.filterSoldierData(soldierData);
			sList.x = width - sList.width >> 1;
			
			mV.noDie.visible = !sList.array.length;
		}
		
		
		public function bindStageData():void{
			
			
			var sldic:Object = data.type == FightingResultsData.TYPE_STAGE ? GameConfigManager.stage_level_dic : GameConfigManager.stage_level_jy_dic;
			var vo:StageLevelVo = sldic[data.checkpointData.sid];
			var status:Array = data.checkpointData.status;
			status ||= [];
			
			var listAr:Array = [];
			var maxStar:Number = 0;
			for (var j:int = 0; j < vo.requirementList.length; j++) 
			{
				var rvo:requirementVo = vo.requirementList[j];
				var condition:Number = 0;
				if(status.length > j )
				{
					condition = Number(status[j]);
				}
				listAr.push([rvo,condition,j + 1]);
				
				if(condition)
					maxStar = j + 1;
			}
			_sCellList.array = listAr;
			
			for (var i:int = 0; i < stars.length; i++) 
			{
				var starImg:Image = stars[i];
//				starImg.filters = i < maxStar ? null : ;
				starImg.filters = [UIUtils.grayFilter];
			}
			
			for (var k:int = 0; k < starEcts.length; k++) 
			{
				var ect:Animation = starEcts[k];
				if(ect)
				{
					ect.stop();
					ect.visible = false;
				}
			}
			
			if(maxStar)
			{
				timer.clear(this,showStarOP);
				timer.once(100,this,showStarOP,[maxStar]);
			}
		}	
		
		private function showStarOP(star:Number):void
		{
			showStarEct(star);
		}
		
		private function showStarEct(star:Number,showI:Number = 0):void{
			if(showI >= star)
			{
				return ;
			}
			
			var ect:Animation = getStarEct(showI);
			if(!ect)return ;
			
			var starImg:Image = stars[showI];
			ect.visible = true;
			ect.play();
			ect.on(Event.COMPLETE,this,frameEnd,[ect,starImg]);
			
			var f:Function=function():void{
				var mp3Url:String = ResourceManager.getSoundUrl("ui_victory_star","uiSound");
				SoundMgr.instance.playSound(mp3Url);
			};
			timer.once(200,this,f);
			
			showI++;
			timer.once(300,this,showStarEct,[star,showI]);
		}
		
		private function frameEnd(ect:Animation,starImg:Image):void
		{
			ect.stop();
			ect.visible = false;
//			starImg.visible  = true;
			starImg.filters = null;
		}
	
		
		protected function getStarEct(idx:Number):Animation{
			
			if(starEcts[idx] != null) return starEcts[idx];
			
			var starImg:Image = stars[idx];
			if(!starImg)return null;
			var ect:Animation = new Animation();
			
			ect.interval = BaseUnit.animationInterval;
			var jsonStr:String = "appRes/effects/jiesuan_star.json";
			ect.loadAtlas(jsonStr);
			ect.scaleX = starImg.scaleX;
			ect.scaleY = starImg.scaleY;
			ect.pivot(160.5,115);
			starImg.parent.addChild(ect);
			ect.pos(starImg.x + starImg.width * starImg.scaleX / 2 ,starImg.y + starImg.height * starImg.scaleY / 2 );
			
			starEcts[idx] = ect;
			return ect;
//			return ect;
		} 
		
		override public function destroy(destroyChild:Boolean=true):void{
			soldierData = null;
			stars = null;
			failureList = null;
			rewardList = null;
			sList = null;
			mV = null;
			ect1 = null;
			ect2 = null;
			_cellList = null;
			_sCellList = null;
			starEcts = null;
			super.destroy(destroyChild);
		}
	}
}