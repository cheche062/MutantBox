package game.module.equipFight.panel
{
	import MornUI.equipFight.EquipFightSelectMyArmyViewUI;
	import MornUI.panels.BagViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ImageTab;
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.data.DBUnit;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.module.equipFight.EquipFightInfoView;
	import game.module.equipFight.cell.EquipHeroArmyCell;
	import game.module.equipFight.data.equipFightChapterData;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.HScrollBar;
	import laya.ui.List;
	import laya.utils.Handler;
	
	public class EquipSelMyArmyPanel extends BaseDialog
	{
		private var _rList:RewardList;
		private var infoData:Object;
		private var selectHero:Array = [null];
		private var selectSoldier:Array = [];
		private var allHero:Array = [];
		private var allSoldier:Array = [];
		
		private var selectD:equipFightChapterData;
		private var buyJson:Object;
		//人口
		private var syPop:Number = 0;
		
		public function EquipSelMyArmyPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			view.m_list1.itemRender = EquipHeroArmyCell;
			view.m_list1.repeatX = 3;
			view.m_list1.repeatY = 3;
//			view.m_list1.scrollBar = new HScrollBar();
//			view.m_list1.scrollBar.visible = false;
//			view.m_list1.scrollEnable = true
//			view.m_list1.mouseEnabled = view.m_list1.mouseThrough = true;
			
			view.m_list2.itemRender = EquipHeroArmyCell;
			view.m_list2.repeatX = 5;
			view.m_list2.repeatY = 2;
//			view.m_list2.scrollBar = new HScrollBar();
//			view.m_list2.scrollBar.visible = false;
//			view.m_list2.scrollEnable = true
			view.m_list2.array = selectSoldier;
		
			
			
			view.m_list3.itemRender = EquipHeroArmyCell;
			view.m_list3.repeatX = 1;
			view.m_list3.repeatY = 1;
			view.m_list3.array = selectHero;
			
			
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			view.rBox.addChild(_rList);
			
//			this.closeOnBlank = true;
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			
			infoData = args[0][0];
			selectD = args[0][1];
			allHero = [];
			allSoldier = [];
			var obj:Object;
			var amData:ArmyData;
			var i:int;
			selectHero[0] = null;
			if(selectSoldier.length)
				selectSoldier.splice(0,selectSoldier.length);
			for (i = 0; i < infoData.units.hero.length; i++) 
			{
				obj = infoData.units.hero[i];
				amData = ArmyData.create(obj);
				if( (!amData.save  || amData.save * 1000 <= TimeUtil.now )  && !amData.state)
					allHero.push(amData);
			}
			for (var i:int = 0; i < infoData.units.soldier.length; i++) 
			{
				obj = infoData.units.soldier[i];
				amData = ArmyData.create(obj);
				allSoldier.push(amData);
			}
			bindSelectUnitViewData();
			
			listsRefresh();
			
			var fNum:Number = Number(infoData.freeTimes);
			if(fNum > 0)
			{
				var bText:String = GameLanguage.getLangByKey("L_A_44028");
				bText = StringUtil.substitute(bText,fNum);
				view.mfLbl.text = bText;
				view.bbox.visible = false;
			}else
			{
				view.mfLbl.text = "";
				view.bbox.visible = true;
				view.wNumLbl.text = getBuyWNum(
					Number(infoData.totalBoughtTimes) + 1
				).toString();
			}
			
			_rList.array = selectD.vo.showReward;
//			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
			
//			view.htmlDiv.innerHTML ="<span color='#b7ffc1' font='30px BigNoodleToo'>ddfafaf</span><span color='#ffb154' font='30px Futura'>ddfafaf</span>"
//			var hStr:String = GameLanguage.getLangByKey("L_A_44006");
////			hStr = "{2}产出{3}{4}{0}的Lvl.{1}{5}{2}装备和装备养成材料{3}";
//			hStr = StringUtil.substitute(hStr,
//				GameLanguage.getLangByKey(selectD.vo.unitVo.name),   // 0
//				selectD.vo.open_level,                                 //1
//				"<span color='#b7ffc1' style='font:18px Futura;'>",   //2
//				"</span>",              //3
//				"<span color='#ffb154' style='font:18px Futura;'>", //4
//				"</span>"
//			);
//			view.htmlDiv.innerHTML = hStr;
//			var s:String = "<span color='#b7ffc1' style='font:30px BigNoodleToo;'>ddfafaf</span>";
//			view.x = view.width - view.htmlDiv.contextWidth >> 1;
		}
		
		
		
		private function getBuyWNum(v:Number):Number{
			if(!buyJson)
			{
				buyJson = ResourceManager.instance.getResByURL("config/galaxy_buy.json");
			}
			
			if(!buyJson)
				return 0;
			var c:Object;
			for each (c in buyJson) 
			{
				var downNum:Number = Number(c.down);
				var upNum:Number = Number(c.up);
				var priceNum:Number = Number(c.price.split("=")[1]);
				if( v >= downNum && v <= upNum)
					return priceNum;
			}
			return 0;
		}
		
		private function listsRefresh():void
		{
			view.m_list1.refresh();
			view.m_list2.refresh();
			view.m_list3.refresh();
			bindSelectUnitViewData();
			
			var n:Number = 0;
			for (var i:int = 0; i < selectSoldier.length; i++) 
			{
				var d:ArmyData = selectSoldier[i];
				n+= d.unitVo.population * d.num;
			}
			
			if(selectHero[0])
				n+= selectHero[0].unitVo.population;
			
//			var tStr:String = GameLanguage.getLangByKey("L_A_44008");
//			tStr = StringUtil.substitute(tStr, n+"/"+selectD.vo.population);
			var tStr:String = n+"/"+selectD.vo.population;
			view.zyLbl.text = tStr;
			
			syPop = selectD.vo.population - n ;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		public function get view():EquipFightSelectMyArmyViewUI{
			if(!_view){
				_view = new EquipFightSelectMyArmyViewUI();
			}
			return _view as EquipFightSelectMyArmyViewUI;
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			view.unitTypeTab.on(Event.CHANGE,this,bindSelectUnitViewData);
			view.closeBtn.on(Event.CLICK,this,close);
			view.m_list1.on(Event.CLICK,this,addClickFun);
			view.m_list2.on(Event.CLICK,this,delClickFun);
			view.m_list3.on(Event.CLICK,this,delClickFun2);
			view.fightBtn.on(Event.CLICK,this,fightBtnClick);
		}
		public override function removeEvent():void{
			super.removeEvent();
			view.unitTypeTab.off(Event.CHANGE,this,bindSelectUnitViewData);
			view.closeBtn.off(Event.CLICK,this,close);
			view.m_list1.off(Event.CLICK,this,addClickFun);
			view.m_list2.off(Event.CLICK,this,delClickFun);
			view.m_list3.off(Event.CLICK,this,delClickFun2);
			view.fightBtn.off(Event.CLICK,this,fightBtnClick);
		}
		
		private function fightBtnClick(e:Event):void
		{
			if(!infoData)return ;
			var fNum:Number = Number(infoData.freeTimes);
//			sendFight();
			var fNum:Number = Number(infoData.freeTimes);
			if(fNum > 0)
			{
				sendFight();
				return ;
			}
			
			var idata:ItemData = new ItemData();
			idata.iid = DBItem.WATER;
			idata.inum = getBuyWNum(
				Number(infoData.totalBoughtTimes) + 1
			);
			ConsumeHelp.Consume([idata],Handler.create(this,sendFight),GameLanguage.getLangByKey("L_A_44850"));
		}
		
		
		private function sendFight():void{
			
			var hidStr:String;
			var sidStr:String;
			var Ids:Array = [];
			var i:int = 0;
			var armyData:ArmyData;
			for (i = 0; i < selectHero.length; i++) 
			{
				armyData = selectHero[i];
				if(armyData)
					Ids.push(armyData.unitId);
			}
			hidStr = Ids.join(":");
			Ids = [];
			for (i = 0; i < selectSoldier.length; i++) 
			{
				armyData = selectSoldier[i];
				if(armyData)
					Ids.push(armyData.unitId +"*"+armyData.num);
			}
			if(!Ids.length)
			{
				XTip.showTip("L_A_44013");
				return ;
			}
			sidStr = Ids.join(":");
			
			WebSocketNetService.instance.sendData(ServiceConst.EQUIP_FIGHT_FIGHT,[
				selectD.chapterId,
				hidStr,
				sidStr
			]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_FIGHT),
				this,sendFightBack);
		}
		
		private function sendFightBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendFightBack);
			var backObj:Object = args[1];
			var efiv:EquipFightInfoView = XFacade.instance.getView(EquipFightInfoView);
			if(efiv) efiv.bindZhangJie(Number(backObj.chapter));
			this.close();
		}
		
		
		private function delClickFun(e:Event):void
		{
			if(e && e.target is EquipHeroArmyCell)
			{
				var d:ArmyData = (e.target as EquipHeroArmyCell).data;
				if(d )
				{
					d.num --;
					if(!d.num)
					{
						var ar:Array = (e.currentTarget as List).array;
						ar.splice(ar.indexOf(d) , 1);
					}
				}
				listsRefresh();
			}
		}
		
		private function delClickFun2(e:Event):void
		{
			if(e && e.target is EquipHeroArmyCell)
			{
				var d:ArmyData = (e.target as EquipHeroArmyCell).data;
				if(d )
				{
					d.num --;
					if(!d.num)
					{
						var ar:Array = (e.currentTarget as List).array;
						ar.splice(ar.indexOf(d) , 1);
					}
				}
				listsRefresh();
			}
		}
		
		private function addClickFun(e:Event):void
		{
			if(e && e.target is EquipHeroArmyCell)
			{
				var d:ArmyData = (e.target as EquipHeroArmyCell).data;
				if(d )
				{
					if(d.unitVo.population > syPop)
					{
						XTip.showTip("L_A_65");
						return;
					}
					
					addArmyFun(d);
				}
			}
		}
		
		
		private function addArmyFun(d:ArmyData):void
		{
			if(d.unitVo.isHero)
			{
				selectHero[0] = d.copy();
			}else
			{
				var b:Boolean;
				var data:ArmyData
				for (var i:int = 0; i < selectSoldier.length; i++) 
				{
					data = selectSoldier[i];
					if(data.unitId == d.unitId)
					{
						data.num ++;
						b = true;
					}
				}
				
				if(!b)
				{
					data = d.copy();
					data.num = 1;
					selectSoldier.push(data);
				}
				
			}
			
			listsRefresh();
		}
		
		
		
		public function bindSelectUnitViewData():void
		{
			var sIdx:uint = view.unitTypeTab.selectedIndex;
			view.tabSelLbl.text = ["L_A_45019",
				"L_A_45020",
				"L_A_45021",
				"L_A_45022",
				"L_A_45023",
				"L_A_45024",][sIdx];
			
			switch(sIdx)
			{
				case 0:
				{
					view.m_list1.array = golv(allHero.concat(allSoldier));
					break;
				}
				case 1:
				{
					view.m_list1.array = golv(allHero);
					break;
				}	
				default:
				{
					view.m_list1.array = golv(getSoldierType(sIdx - 1));
					break;
				}
			}
		}
		
		private function golv(ar:Array):Array{
			var rtAr:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
				var d:ArmyData = ar[i];
				var d2:ArmyData = new ArmyData();
				d2.unitId = d.unitId;
				d2.num = d.num;
				d2.disabled = d.disabled;
				var rtD:ArmyData = getSelAData(d.unitId);
				if(rtD)
				{
					d2.num -= rtD.num;
					
					var db:Object = DBUnit.getUnitInfo(rtD.unitId);
					if(rtD.num >= db.num_limit){
						d2.disabled = true;
					}
				}
				d2.state2 = 0;
				if(!d2.num)
				{
					d2.state2 = ArmyData.STATE_NOT_NUMBER; 
				}else if(d2.limit > 0 && d2.limit <=  rtD.num)
				{
					d2.state2 = ArmyData.STATE_NOT_ADD;
				}
//				if(d2.num)
					rtAr.push(d2);
			}
			return rtAr.sort(ArmyData.armySort);
		}
		
		private function getSelAData(uid:uint):ArmyData{
			var d:ArmyData;
			for (var i:int = 0; i < selectHero.length; i++) 
			{
				d = selectHero[i];
				if(d && d.unitId == uid)
					return d;
			}
			for (var i:int = 0; i < selectSoldier.length; i++) 
			{
				d = selectSoldier[i];
				if(d && d.unitId == uid)
					return d;
			}
			return null;
		}
		
		public function getSoldierType(type:Number):Array{
			var d:ArmyData;
			var ar:Array = [];
			for (var i:int = 0; i < allSoldier.length; i++) 
			{
				d = allSoldier[i];
				if(d.unitVo.defense_type == type){
					ar.push(d);
				}
			}
			return ar;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipSelMyArmyPanel");
			_rList = null;
			infoData = null;
			selectHero = null;
			selectSoldier = null;
			allSoldier = null;
			selectD = null;
			buyJson = null;
			
			super.destroy(destroyChild);
		}
		
	}
}