package game.module.pvp.views
{
	import game.common.UIRegisteredMgr;
	import MornUI.pvpFight.pvpMainMeuUI;
	import MornUI.pvpFight.pvpMainViewUI;
	
	import game.common.ListPanel;
	import game.common.RewardList;
	import game.common.UIHelp;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.PvpLevelVo;
	import game.global.vo.PvpMathCostVo;
	import game.global.vo.User;
	import game.module.bag.cell.needItemCell;
	import game.module.bag.cell.showMoneyCell;
	import game.module.camp.CampData;
	import game.module.fighting.view.BaseChapetrView;
	import game.module.pvp.PvpMainPanel;
	import game.module.pvp.PvpManager;
	import game.module.pvp.cell.MathHeroCell;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class PvpMainView extends BaseChapetrView
	{
		public var bgUi:pvpMainViewUI;
		public var muUi:pvpMainMeuUI;
		private var _pvpMathCost:PvpMathCostVo;
		private var _heroList1:RewardList;
		private var _heroList2:RewardList;
		private var _needCell:needItemCell;
		private var _showMoneyCell1:showMoneyCell;
		private var _showMoneyCell2:showMoneyCell;
		private var _showMoneyCell3:showMoneyCell;
		
		
		public function PvpMainView()
		{
			super();
			bgUi = new pvpMainViewUI();
			bgBox.addChild(bgUi);
			bgImg.skin = "appRes/fightingMapImg/pvpBg.jpg";
			
			muUi = new pvpMainMeuUI();
			contentBox.addChild(muUi);
			
			var lblJg:Number = 5;
			var lblW1:Number = muUi.tileLbl1.textField.textWidth;
			var lblW2:Number = muUi.tileLbl2.textField.textWidth;
			var maxLblW:Number = lblW1 + lblW2 + lblJg;
			muUi.tileLbl1.x = muUi.todayHeroListBox.width - maxLblW >> 1;
			muUi.tileLbl2.x = muUi.tileLbl1.x + lblW1 + lblJg;
			
			lblW1 = muUi.tileLbl3.textField.textWidth;
			lblW2 = muUi.tileLbl4.textField.textWidth;
			maxLblW = lblW1 + lblW2 + lblJg;
			muUi.tileLbl3.x = muUi.todayHeroListBox.width - maxLblW >> 1;
			muUi.tileLbl4.x = muUi.tileLbl3.x + lblW1 + lblJg;
			
			_heroList1 = new RewardList();
			_heroList1.itemRender = MathHeroCell;
			_heroList1.itemWidth = MathHeroCell.itemWidth;
			_heroList1.itemHeight = MathHeroCell.itemHeight;
			muUi.listBox1.addChild(_heroList1);
			_heroList1.array = [null,null];
			_heroList1.x = muUi.listBox1.width - _heroList1.width >> 1;
			
			_heroList2 = new RewardList();
			_heroList2.itemRender = MathHeroCell;
			_heroList2.itemWidth = MathHeroCell.itemWidth;
			_heroList2.itemHeight = MathHeroCell.itemHeight;
			muUi.listBox2.addChild(_heroList2);
			_heroList2.array = [null,null];
			_heroList2.x = muUi.listBox2.width - _heroList2.width >> 1;
			
			UIHelp.crossLayout(muUi.tileBox1,true,0,5);
			muUi.tileBox1.x = muUi.todayHeroListBox.width - muUi.tileBox1.width >> 1;
			UIHelp.crossLayout(muUi.tileBox2,true,0,5);
			muUi.tileBox2.x = muUi.todayHeroListBox.width - muUi.tileBox2.width >> 1;
			
			_needCell = new needItemCell();
			muUi.needBox.addChild(_needCell);
			
			_showMoneyCell1 = new showMoneyCell(DBItem.PVP_TOKEN,"#ffffff",XFacade.FT_Futura,18,0,9,false,60,"right");
			_showMoneyCell2 = new showMoneyCell(DBItem.FOOD,"#ffffff",XFacade.FT_Futura,18,0,9,false,60,"right");
			_showMoneyCell3 = new showMoneyCell(DBItem.WATER,"#ffffff",XFacade.FT_Futura,18,0,9,false,60,"right");
			muUi.showMoneyImg.addChild(_showMoneyCell1);
			muUi.showMoneyImg.addChild(_showMoneyCell2);
			muUi.showMoneyImg.addChild(_showMoneyCell3);
			_showMoneyCell1.pos(10,5);
			_showMoneyCell2.pos(10,35);
			_showMoneyCell3.pos(10,65);
			
			
			UIRegisteredMgr.AddUI(muUi.todayHeroListBox, "PvpInfoArea");
			UIRegisteredMgr.AddUI(muUi.bottomBox, "PvpMatchArea");
			
			this.pvpMathCost = null;
			
		}
		
		public function addEvent():void
		{
			super.addEvent();
			muUi.closeBtn.on(Event.CLICK,this,thisClose);
			muUi.pipeiBtn.on(Event.CLICK,this,pipeiFun);
			muUi.shopBtn.on(Event.CLICK,this,thisShop);
			muUi.rankBtn.on(Event.CLICK,this,rankFun);
			muUi.logBtn.on(Event.CLICK,this,logFun);
			muUi.rewardBtn.on(Event.CLICK,this,rewardFun);
			muUi.helpBtn.on(Event.CLICK,this,helpFun);
			Signal.intance.on(PvpManager.MAININFOCHANGE_EVENT,this,bindMainInfo);
			Signal.intance.on(PvpManager.REWARDCHANGE_EVENT,this,changeReward);
//			Signal.intance.on(User.PRO_CHANGED, this,userChange);
			PvpManager.intance.getMainInfoData();
//			userChange();
		}
		public function removeEvent():void
		{
			super.removeEvent();
			muUi.closeBtn.off(Event.CLICK,this,thisClose);
			muUi.pipeiBtn.off(Event.CLICK,this,pipeiFun);
			muUi.shopBtn.off(Event.CLICK,this,thisShop);
			muUi.rankBtn.off(Event.CLICK,this,rankFun);
			muUi.logBtn.off(Event.CLICK,this,logFun);
			muUi.rewardBtn.off(Event.CLICK,this,rewardFun);
			muUi.helpBtn.off(Event.CLICK,this,helpFun);
			Signal.intance.off(PvpManager.MAININFOCHANGE_EVENT,this,bindMainInfo);
			Signal.intance.off(PvpManager.REWARDCHANGE_EVENT,this,changeReward);
		}
		
//		private function userChange():void{
//			muUi.mNumLbl1.text = User.getInstance().getResNumByItem(DBItem.PVP_TOKEN);
//			muUi.mNumLbl2.text = User.getInstance().getResNumByItem(DBItem.FOOD);
//			muUi.mNumLbl3.text = User.getInstance().getResNumByItem(DBItem.WATER);
//		}
		
		private function thisClose(e:Event):void{
			XFacade.instance.closeModule(PvpMainPanel);
			
		}
		private function logFun(e:Event):void{
			XFacade.instance.openModule(ModuleName.pvpLogPanel);
			
		}
		private function thisShop(e:Event):void{
			XFacade.instance.openModule(ModuleName.PvpShopPanel);
			
		}
		private function rankFun(e:Event):void{
			XFacade.instance.openModule(ModuleName.pvpRankPanel);
			
		}
		private function rewardFun(e:Event):void{
			XFacade.instance.openModule(ModuleName.PvpRewardPanel);
		}
		
		private function changeReward(e:Event = null):void{
			muUi.hdImg.visible = PvpManager.intance.refrechGetNum > 0;
			muUi.hdNum.text = PvpManager.intance.refrechGetNum ;
		}
		
		private function helpFun(e:Event):void{
			var st:String = GameLanguage.getLangByKey("L_A_70055");
			st = st.replace(/##/g,"<br />");
			XFacade.instance.openModule(ModuleName.IntroducePanel,st);
		}
		
		
		
		
		private function bindMainInfo():void{
			muUi.myNameLbl.text = GlobalRoleDataManger.instance.user.name;
			var levelVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
				Number(PvpManager.intance.userInfo.integral)
			);
			if(levelVo)
			{
				muUi.levelNameLbl.text= levelVo.name;
				pvpMathCost = PvpManager.intance.getPvpMathCostVo(levelVo.id,Number(PvpManager.intance.userInfo.matchTimes) + 1);
				muUi.rankFace.skin = levelVo.rankIcon;
				var heroList:Array = [];
				for (var i:int = 0; i < levelVo.hotUnits.length; i++) 
				{
					var hId:Number = levelVo.hotUnits[i];
					var data:Object = CampData.getUintById(hId);
					if(data)
					{
						heroList.push([hId,true]);
					}else
					{
						heroList.push([hId,false]);
					}
				}
				
				var n:Number = 2 - heroList.length;
				if(n>0){
					for (var j:int = 0; j < n; j++) 
					{
						heroList.push(null);
					}
				}
				_heroList2.array = heroList;
			}
			
			var heroList:Array = [];
			var hotIds:Array = PvpManager.intance.todayUnits;
			if(!hotIds) hotIds = [];
			for (var i:int = 0; i <  hotIds.length; i++) 
			{
				var hId:Number = hotIds[i];
				var data:Object = CampData.getUintById(hId);
				if(data)
				{
					heroList.push([hId,true]);
				}else
				{
					heroList.push([hId,false]);
				}
			}
			
			var n:Number = 2 - heroList.length;
			if(n>0){
				for (var j:int = 0; j < n; j++) 
				{
					heroList.push(null);
				}
			}
			_heroList1.array = heroList;
			
			muUi.integralLbl.text = PvpManager.intance.userInfo.integral;
			UIHelp.crossLayout(muUi.inBox,true,-10,-10,20);
			muUi.inBox.x = muUi.bgimg001.width - muUi.inBox.width >> 1;
			
			var topHero:Number = 0;
			var power:Number = 0;
			var myHeroList:Array = CampData.getUnitList(1);
			for (var k:int = 0; k < myHeroList.length; k++) 
			{
				if(myHeroList[k].power > power)
				{
					power = myHeroList[k].power;
					topHero = myHeroList[k].unitId;
				}
			}
			var fvo:FightUnitVo = GameConfigManager.unit_dic[topHero];
			muUi.heroMaxFace.skin = UnitPicUtil.getUintPic(fvo.model,UnitPicUtil.PIC_FULL);
			
			changeReward();
		}
		
		public function get pvpMathCost():PvpMathCostVo
		{
			return _pvpMathCost;
		}
		
		public function set pvpMathCost(value:PvpMathCostVo):void
		{
			_pvpMathCost = value;
			muUi.pipeiBtn.disabled = !_pvpMathCost;
//			muUi.xhLbl1.text = _pvpMathCost ? _pvpMathCost.cost[0].inum : "0";
			muUi.needBox.visible = muUi.maxFNum.visible = false;
			if(_pvpMathCost)
			{
				muUi.needBox.visible = true;
				_needCell.data = _pvpMathCost.cost[0];
				_needCell.x = muUi.needBox.width - _needCell.width >> 1;
			}else
			{
				muUi.maxFNum.visible = true;
			}
		}
		
		private function pipeiFun(e:Event):void
		{
			ConsumeHelp.Consume(pvpMathCost.cost,Handler.create(this,getPiPeiBack));
		}
		
		private function getPiPeiBack():void
		{
			var listP:ListPanel = this.parent;
			if(listP)
			{
				listP.selIndex = 1;
			}
			
		}
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			muUi.size(width,height);
			muUi.topLeftBox.pos(0,0);
			muUi.topBox.pos(width - muUi.topBox.width >>1 , 0);
			muUi.topRightBox.pos(width - muUi.topRightBox.width , 0);
			muUi.leftBottomBox.pos(0 , height - muUi.leftBottomBox.height);
			muUi.rightBottomBox.pos(width - muUi.rightBottomBox.width , height - muUi.rightBottomBox.height);
			muUi.bottomBox.pos(width - muUi.bottomBox.width >>1 , height - muUi.bottomBox.height);
			muUi.userInfoBox.pos(170,height - muUi.userInfoBox.height>>1);
			muUi.todayHeroListBox.pos(width - muUi.todayHeroListBox.width - 150,height - muUi.todayHeroListBox.height>>1);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			
			super.destroy(destroyChild);
			
			bgUi = null;
			muUi = null;
			_pvpMathCost = null;
			_heroList1 = null;
			_heroList2 = null;
			_needCell = null;
			_showMoneyCell1 = null;
			_showMoneyCell2 = null;
			_showMoneyCell3 = null;
		}
		
	}
}