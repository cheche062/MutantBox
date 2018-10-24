package game.module.pvp.views
{
	import MornUI.pvpFight.pvpPipeiMeunUI;
	import MornUI.pvpFight.pvpPipeiViewUI;
	
	import game.common.ListPanel;
	import game.common.RewardList;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.StringUtil;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.PvpLevelVo;
	import game.module.camp.CampData;
	import game.module.fighting.view.BaseChapetrView;
	import game.module.pvp.PvpManager;
	import game.module.pvp.cell.MathHeroCell;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class PvpPiPeiView extends BaseChapetrView
	{
		private var bgUi:pvpPipeiViewUI;
		private var muUi:pvpPipeiMeunUI;
		
		private var _heroList1:RewardList;
		private var _heroList2:RewardList;
		
		
		public function PvpPiPeiView()
		{
			super();
			bgUi = new pvpPipeiViewUI();
			bgBox.addChild(bgUi);
			bgImg.skin = "appRes/fightingMapImg/pvpBg.jpg";
			
			
			muUi = new pvpPipeiMeunUI();
			contentBox.addChild(muUi);
			
			
			_heroList1 = new RewardList();
			_heroList1.itemRender = MathHeroCell;
			_heroList1.itemWidth = MathHeroCell.itemWidth;
			_heroList1.itemHeight = MathHeroCell.itemHeight;
			muUi.lHerList.addChild(_heroList1);
		
			
			_heroList2 = new RewardList();
			_heroList2.itemRender = MathHeroCell;
			_heroList2.itemWidth = MathHeroCell.itemWidth;
			_heroList2.itemHeight = MathHeroCell.itemHeight;
			muUi.rHerList.addChild(_heroList2);
			
			_heroList1.scaleX = _heroList1.scaleY = _heroList2.scaleX = _heroList2.scaleY = .7;
		}
		
		public function addEvent():void
		{
			muUi.cancelBtn.on(Event.CLICK,this,cancelPipei);
			super.addEvent();
			startTimer();
			
			bindLeftData();
			bindData(null,false);
			changeRightRankFace();
			PvpManager.intance.pipei(Handler.create(this,getPiPeiBack),Handler.create(this,getPiPeiBackCS));
			muUi.cancelBtn.disabled = false;
		}
		
		private function changeRightRankFace():void
		{
//			var faceAr:Array = ["appRes/icon/rankIcon/rank_2.png","appRes/icon/rankIcon/rank_1.png"];
			var faceAr:Array = [];
			for (var i:int = 0; i < GameConfigManager.pvpLevelVoList.length; i++) 
			{
				var vo:PvpLevelVo = GameConfigManager.pvpLevelVoList[i];
				faceAr.push(vo.rankIcon);
			}
			
			showFace(faceAr);
		}
		
		private function showFace(ar:Array):void
		{
			var idx:Number = Math.floor(1+(ar.length-1+1)*Math.random());
			idx--;
			
			muUi.rrankFace.skin = ar[idx];
			Laya.timer.once(300,this,showFace,[ar]);
		}
		
		public function removeEvent():void
		{
			muUi.cancelBtn.off(Event.CLICK,this,cancelPipei);
			super.removeEvent();
			stopTimer();
		}
		
		private function cancelPipei(e:Event):void{
			PvpManager.intance.cancelPipei();
		}
		
		private function getPiPeiBackCS():void
		{
			muUi.cancelBtn.disabled = true;
		}
		
		private function getPiPeiBack(... args):void
		{
			if(Number(args[0]) == 1)
			{
				muUi.cancelBtn.disabled = true;
				try
				{
					bindRightData();
				} 
				catch(error:Error) 
				{
					XTip.showTip("rightDataError")
				}
				
				timer.once(1000,this,function():void{
					PvpManager.intance.userStart();
				});
			}else
			{
//				XTip.showTip("匹配超时");
				var listP:ListPanel = this.parent;
				if(listP)
				{
					listP.selIndex = 0;
				}
			}
		}
		
		
		
		
		public function bindLeftData():void
		{
			var d:Object = {};
			d.name = GlobalRoleDataManger.instance.user.name;
			d.level = GlobalRoleDataManger.instance.user.level;
			
			var levelVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
				Number(PvpManager.intance.userInfo.integral)
			);
			var heroList:Array = [];
			if(levelVo)
			{
				for (var i:int = 0; i < levelVo.hotUnits.length; i++) 
				{
					var hId:Number = levelVo.hotUnits[i];
					heroList.push([hId,false]);
				}
				d.rankLevel = levelVo.id;
			}
			
			var hotIds:Array = PvpManager.intance.todayUnits;
			for (var i:int = 0; i <  hotIds.length; i++) 
			{
				heroList.push([Number(hotIds[i]),false]);
			}
			
			for (var j:int = 0; j < heroList.length; j++) 
			{
				var data:Object = CampData.getUintById(heroList[j][0]);
				if(data)heroList[j][1] = true;
			}
			
			d.heroList = heroList;
			
			var myHeroList:Array = CampData.getUnitList(1);
			var topHero:Number = 0;
			var power:Number = 0;
			for (var k:int = 0; k < myHeroList.length; k++) 
			{
				if(myHeroList[k].power > power)
				{
					power = myHeroList[k].power;
					topHero = myHeroList[k].unitId;
				}
			}
			d.topHero = topHero;
			
			bindData(d,true);
		}
		
		public function bindRightData():void
		{
			Laya.timer.clear(this,showFace);
			var obj:Object = PvpManager.intance.enemyInfo;
			var d:Object = {};
			d.name = obj.name;
			d.level = obj.userLevel;
			d.topHero = obj.topUnit;
			
			var levelVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
				Number(obj.integral)
			);
			var heroList:Array = [];
			if(levelVo)
			{
				for (var i:int = 0; i < levelVo.hotUnits.length; i++) 
				{
					var hId:Number = levelVo.hotUnits[i];
					heroList.push([hId,false]);
				}
				d.rankLevel = levelVo.id;
			}
			
			var hotIds:Array = PvpManager.intance.todayUnits;
			for (var i:int = 0; i <  hotIds.length; i++) 
			{
				heroList.push([Number(hotIds[i]),false]);
			}
			var userHeros:Array = obj.heros;
			for (var j:int = 0; j < heroList.length; j++) 
			{
				if(userHeros.indexOf(heroList[j][0]) != -1)
					heroList[j][1] = true;
			}
			
			d.heroList = heroList;
			
			bindData(d,false);
		}
		
		public function bindData(d:Object,left:Boolean):void
		{
			var face:Image = left ? muUi.lheroMaxFace : muUi.rheroMaxFace;
			var nameLbl:Label = left ? muUi.lHeroNameLbl : muUi.rHeroNameLbl;
			var heroList:RewardList = left ? _heroList1 : _heroList2;
			var rankFace:Image = left ? muUi.lrankFace : muUi.rrankFace;
			nameLbl.text = "???";
			heroList.array = [];
			heroList.visible = false;
			if(d)
			{
				heroList.visible = true;
				heroList.array = d.heroList;
				heroList.x = left ? 0 : (heroList.parent as Box).width - heroList.width * heroList.scaleX;
				nameLbl.text = StringUtil.substitute("{0}   "+GameLanguage.getLangByKey("L_A_73")+"{1}",d.name,d.level);
				var vo:PvpLevelVo = PvpManager.intance.getPvpLevelVoByLevel(d.rankLevel);
				if(vo)
				{
					rankFace.skin = vo.rankIcon;
				}
				var fvo:FightUnitVo = GameConfigManager.unit_dic[d.topHero];
				face.skin = UnitPicUtil.getUintPic(fvo.model,UnitPicUtil.PIC_FULL);
			}else
			{
				face.skin = UnitPicUtil.getUintPic("0000",UnitPicUtil.PIC_FULL);
			}
			
		}
		
		
		public function startTimer():void
		{
			stopTimer();
			muUi.timerLbl.text =  TimeUtil.formatStopwatch(0);
			timer.once(1000,this,changTimer,[1]);
		}
		
		public function stopTimer():void
		{
			timer.clear(this,changTimer);
		}
		
		private function changTimer(n:Number):void
		{
			muUi.timerLbl.text =  TimeUtil.formatStopwatch(n * 1000);
			n++;
			timer.once(1000,this,changTimer,[n]);
		}
		
	
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			muUi.size(width,height);
			muUi.topBox.pos(width - muUi.topBox.width >>1 , 0);
			muUi.bottomBox.pos(width - muUi.bottomBox.width >>1 , height - muUi.bottomBox.height);
			muUi.leftUserBox.pos(75,height - muUi.leftUserBox.height>>1);
			muUi.rightUserBox.pos(width - muUi.rightUserBox.width - 75,height - muUi.rightUserBox.height>>1);
			muUi.vsImg.pos(width - muUi.vsImg.width >> 1 , height - muUi.vsImg.height >> 1);
		}
	
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy PvpPiPeiView");
			
			super.destroy(destroyChild);
			
			bgUi = null;
			muUi = null;
			_heroList1 = null;
			_heroList2 = null;
			
		}
	}
}