package game.module.equipFight
{
	import MornUI.equipFight.EquipFightSelectUIUI;
	
	import game.common.CircularTab;
	import game.common.List2;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.module.equipFight.cell.equipFightBtnCell;
	import game.module.equipFight.cell.equipFightHeroCell;
	import game.module.equipFight.data.equipFightChapterData;
	import game.module.equipFight.data.equipFightInfoData;
	import game.module.equipFight.vo.equipFightChapterVo;
	import game.module.fighting.view.BaseChapetrView;
	import game.module.gm.helpButton;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.HScrollBar;
	import laya.ui.Image;
	import laya.ui.List;
	import laya.ui.VScrollBar;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class EquipFightSelectView extends BaseChapetrView
	{
		
		private var _list:List;
		private var _listData:Array ;
		private var _ypBtnList:Array = [];
		private var _selectBtn:Button;
		private var _tUI:EquipFightSelectUIUI ;
		private var _helpB:helpButton;
		private var _leftIdx:Number = 0;
		private var cb:CircularTab = new CircularTab();
		private var _leftBtn:Button;
		private var _rightBtn:Button;
		private var infoData:Object;
		
		public function EquipFightSelectView()
		{
			super();
//			size(1136,640);
			
			
			_tUI = new EquipFightSelectUIUI();
			_tUI.mouseEnabled = _tUI.mouseThrough = true;
			contentBox.addChild(_tUI);
			
//			bgImg.loadImage("appRes/fightingMapImg/zbfb.jpg");
			
			
			_list = new List2();
			_tUI._list.parent.addChild(_list);
//			_list.pos(_tUI._list.x , _tUI._list.y);
			_list.size(_tUI._list.width , _tUI._list.height);
			var scb:VScrollBar =  new VScrollBar();
			_list.addChild(scb);
			scb.name = "scrollBar";
			_list.scrollBar = scb;
//			_list = _tUI._list;
			_tUI._list.removeSelf();
			
			_list.repeatX = 1;
			_list.repeatY = 3;
			_list.spaceY = 25;
			_list.selectEnable = true;
			_list.mouseEnabled = _list.mouseThrough = true;
			_list.itemRender = equipFightHeroCell;
			_list.array = listData;
			_list.scrollBar.visible = false;	
			
			var ar:Array = [];
			
			for (var i:int = 0; i < 5; i++) 
			{
				var btn:equipFightBtnCell = new equipFightBtnCell();
				_ypBtnList.push(btn);
				ar.push(
					[
						(90 - (i * 72) )%360,  
						btn
					]
				);
			}
			bgBox.addChild(cb);
			cb.init(327,ar,[1,.75,.30,.30,.75],.5);
//			cb.pos(240,190);
			cb.pos(__bgWidth - cb.width >> 1 , ( __bgHeight - cb.height >> 1 ) + 30);
			
			cb.on(CircularTab.CBChange,this,bindSelectBtn);

			_leftBtn = _tUI._leftBtn;
			_rightBtn = _tUI._rightBtn;
			_selectBtn = _tUI._selectBtn;
			
			
			UIRegisteredMgr.AddUI(_selectBtn,"EquipRaidSelectBtn");
			
			var st:String = GameLanguage.getLangByKey("L_A_44004").replace(/##/g, "\n");
			_helpB = new helpButton("common/btn_info2.png","",st);
			contentBox.addChild(_helpB);
//			_helpB.pos(1050,12);
		}
		
		
		private function selectBtnClick(e:Event):void{
			var _selectD:equipFightChapterData = (cb.selectBtn as equipFightBtnCell).data;
			XFacade.instance.openModule(ModuleName.EquipSelMyArmyPanel,[infoData,_selectD]);
		}
		
		
		private function thisListSelect(index:int):void
		{
//			for (var j:int = 0; j < _list.cells.length; j++) 
//			{
//				var box:Box = _list.getCell(j);
//				if(box)
//					box.selected = j == index;
//			}
			
			
			var d:equipFightInfoData = listData[_list.selectedIndex] ;
			if(!d.state && _list.selectedIndex != 0)
			{
				XTip.showTip("L_A_44853");
				_list.selectedIndex = _leftIdx;
				return ;
			}
			for (var i:int = 0; i < _ypBtnList.length; i++) 
			{
				var btn:equipFightBtnCell = _ypBtnList[i];
				btn.data = d.voList[i];
			}
			_leftIdx = _list.selectedIndex;
			bindSelectBtn();
		}
		
		private function bindSelectBtn():void
		{
			if(!cb.selectBtn)return ;
			var _selectD:equipFightChapterData = (cb.selectBtn as equipFightBtnCell).data;
			if(!_selectD) return;
			_selectBtn.disabled = !_selectD.isOpen;
			var tStr:String = GameLanguage.getLangByKey("L_A_44001");
			var uName:String = GameLanguage.getLangByKey(_selectD.vo.unitVo.name);
			tStr = StringUtil.substitute(tStr,uName);
			_tUI.heroName.text = tStr;
			_tUI.heroFace.skin = UnitPicUtil.getUintPic(_selectD.vo.unitVo.unit_id,UnitPicUtil.PIC_EF);
			bgImg.skin = "appRes/fightingMapImg/"+_selectD.vo.icon2+".jpg";
		}
		
		
		private function btnClick(e:Event):void
		{
			switch(e.target)
			{
				case _leftBtn:
				{
					
					cb.stateIndex ++;
					break;
				}
				case _rightBtn:
				{
					
					cb.stateIndex --;
					break;
				}
						
				default:
				{
					break;
				}
			}
			
//			bindSelectBtn();
		}
		
		
		
		public function get listData():Array
		{
			if(!_listData)
			{
				var d:equipFightInfoData;
				_listData = [];
				var cList:Array = GameConfigManager.equipFightChapters;
				for (var i:int = 0; i < cList.length; i++) 
				{
					var vo:equipFightChapterVo = cList[i];
					if(!d || d.heroId != vo.hero)
					{
						d= new equipFightInfoData();
						d.heroId = vo.hero;
						_listData.push(d);
					}
					
					var d2:equipFightChapterData = new equipFightChapterData();
					d2.chapterId = vo.id;
					
					d.voList.push(d2);
				}
				
			}
			
			return _listData;
		}
		
		
		public override function set parent(value:Node):void{
			super.parent = value;
			if(value)
			{
				cb.BgEotation = cb.BgEotation;
			}
		}

		public function sendInfo():void{
			WebSocketNetService.instance.sendData(ServiceConst.EQUIP_FIGHT_INFO,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_INFO),
				this,sendInfoBack);
		}
		
		
		private function sendInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendInfoBack);
			infoData = args[1];
			var ar:Array = infoData.hero;
			for (var i:int = 0; i < ar.length; i++) 
			{
				var heroId:Number = Number(ar[i]["heroId"]);
				var maxChapter:Number = Number(ar[i]["maxChapter"]);
//				var passed:Boolean = Boolean(ar[i]["passed"]);
				var passed:Boolean = false;
				var eqData:equipFightInfoData = getHeroData(heroId);
				if(!eqData)continue;
				eqData.state = passed ? 2 : 1;
				for (var j:int = 0; j <	eqData.voList.length; j++) 
				{
					var d2:equipFightChapterData = eqData.voList[j];
					d2.isOpen = d2.vo.id <= maxChapter || passed;
				}
				
			}
			_list.selectedIndex = 0;
			_list.refresh();
		}
		
		public function getHeroData(hid:Number):equipFightInfoData{
			for (var i:int = 0; i < listData.length; i++) 
			{
				var d:equipFightInfoData = listData[i];
				if(d.heroId == hid)
					return d;
			}
			return null;
		}
		
		
		protected function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			
			_tUI.size(Laya.stage.width , Laya.stage.height);
			_tUI.listBgImg.y = Laya.stage.height - _tUI.listBgImg.height >> 1;
			_tUI.btnsBg.pos( Laya.stage.width - _tUI.btnsBg.width >> 1, Laya.stage.height - _tUI.btnsBg.height - 10);
			
			_list.pos(13 , Laya.stage.height - _list.height >> 1);
			
			_helpB.pos(Laya.stage.width - 90 , 20);
			
			
//			cb.init(Laya.stage.width - cb.width >> 1 , Laya.stage.height - cb.height >> 1); 
		}
		
		
		public override function addEvent():void
		{
			super.addEvent();
			_list.selectHandler = Handler.create(this,thisListSelect,null,false);
			_leftBtn.on(Event.CLICK,this,btnClick);
			_rightBtn.on(Event.CLICK,this,btnClick);
			_selectBtn.on(Event.CLICK, this, selectBtnClick);
			sendInfo();
		}
		public override function removeEvent():void
		{
			super.removeEvent();
			_leftBtn.off(Event.CLICK,this,btnClick);
			_rightBtn.off(Event.CLICK,this,btnClick);
			_selectBtn.off(Event.CLICK, this, selectBtnClick);
			_list.selectHandler = null;
			_list.selectedIndex = -1;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipFightSelectView");
			
			super.destroy(destroyChild);
			_list = null;
			infoData = null;
			_listData = null;
			_selectBtn = null;
			_tUI = null;
			_helpB = null;
			cb = null;
			_leftBtn = null;
			_rightBtn = null;
		}

	}
}