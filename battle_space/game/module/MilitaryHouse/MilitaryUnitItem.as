package game.module.MilitaryHouse 
{
	import MornUI.militaryHouse.MilitartUnitItemUI;
	
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.event.MilitartHouseEvent;
	import game.global.event.Signal;
	import game.global.vo.FightUnitVo;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MilitaryUnitItem extends BaseView 
	{
		
		private var _itemMc:MilitartUnitItemUI;
		
		private var data:Object;
		
		private var _heroImg:Image;
		private var _quiltyBar:Image;
		private var _lvTF:Text;
		private var _score:Text;
		
		private var _openItem:Image;
		
		private var _scaleNum:Number = 0.8;
		
		private var _blockState:int = -1;
		
		private var _blockType:int = 0;	//默认为所有兵种列表，1为军府上阵框
		
		private var _blockID:int = 0;
		
		public function MilitaryUnitItem() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			//trace("选中兵种")
			//sound
			SoundMgr.instance.playSound(ResourceManager.getSoundUrl("ui_common_click",'uiSound'));
			if (_blockType == 0)
			{
				Signal.intance.event(MilitartHouseEvent.SELECT_UNIT, [data.unitId]);
				return;
			}
			
			switch(e.target)
			{
				case view.delBtn:
					Signal.intance.event(MilitartHouseEvent.DEL_UNIT_LIST, [data.unitId,_blockID]);
					//view.delBtn.visible = false;
					view.selectFrame.visible = false;
					break;
				default:
					break;
			}
			//trace("_blockState:", _blockState);
			switch(_blockState)
			{
				case 1:
					Signal.intance.event(MilitartHouseEvent.OPEN_UNIT_LIST,[_blockID]);
					break;
				case 2:
					Signal.intance.event(MilitartHouseEvent.BUY_BLOCK);
					break;
				case 3:
					Signal.intance.event(MilitartHouseEvent.OPEN_UNIT_LIST,[_blockID]);
					
					break;
				default:
					break;
			}
		}
		
		public function setSelectedState(state:Boolean = false):void
		{
			if (_blockType == 0)
			{
				return;
			}
			//view.delBtn.visible = false;
			view.selectFrame.visible = state;
			//view.delBtn.visible = true;
			/*if (_blockState == 3 && state)
			{
				view.delBtn.visible = true;
			}*/
		}
		
		
		
		public function setMC(vv:MilitartUnitItemUI,blockID:int):void
		{
			_scaleNum = 1;
			_itemMc = vv;
			
			_itemMc.openPirceTF.visible = false;
			_itemMc.unlockBtn.visible = false;
			
			view.delBtn.visible = false;
			view.selectFrame.visible = false;
			
			_blockID = blockID;
			_blockType = 1;
			
			_itemMc.unitBg.mouseEnabled = true;
			
			if(!_openItem)
			{
				_openItem = new Image();
				_openItem.width = _openItem.height = 80;
				_openItem.x = 2;
				_openItem.y = 110;
				_openItem.skin = GameConfigManager.getItemImgPath(1);
				_itemMc.addChild(_openItem);
				_openItem.visible = false;
			}
			addEvent();
		}
		
		
		public function setState(state:int,op:String="1=10"):void
		{
			
			_blockState = state;
			//trace("_blockState:", _blockState);
			if (_heroImg)
			{
				_heroImg.visible = false;
				_quiltyBar.visible = false;
			}
			_itemMc.lvTF.visible = _itemMc.scoreTF.visible = _itemMc.sTF.visible = false;
			_itemMc.stateImg.visible = true;
			_itemMc.disabled = false;
			_openItem.visible = false;
			_itemMc.unitBg.gray = false;
			view.delBtn.visible = false;
			view.selectFrame.visible = false;
			_itemMc.openPirceTF.visible = false;
			view.unitBg.skin = "common/bg6_1.png";
			view.unlockBtn.visible = false;
			
			switch(state)
			{
				case 0:
					_itemMc.stateImg.skin = "militaryHouse/icon_lock.png";
					_itemMc.disabled = true;
					break;
				case 1:
					
					_itemMc.stateImg.skin = "militaryHouse/icon_add.png";
					_itemMc.stateImg.visible = true;
					_itemMc.disabled = false;
					break;
				case 2:
					_itemMc.stateImg.skin = "militaryHouse/icon_lock.png";
					_itemMc.unitBg.gray = true;
					_itemMc.disabled = false;
					/*_openItem.skin = GameConfigManager.getItemImgPath(op.split("=")[0]);
					_itemMc.openPirceTF.text = op.split("=")[1];
					_itemMc.openPirceTF.visible = true;
					_openItem.visible = true;*/
					view.unlockBtn.visible = true;
					break;
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				this.visible = false;
				return;
			}
			
			_blockState = 3;
			data = value;
			view.delBtn.visible = false;
			view.selectFrame.visible = false;
			
			
			//trace("unitData:",data);
			
			view.unitBg.skin = "common/bg6_1.png";
			view.stateImg.visible = false;
			_itemMc.disabled = false;
			if (!_heroImg)
			{
				_heroImg = new Image();
				_heroImg.scaleX = _heroImg.scaleY = _scaleNum;
				_heroImg.y = 5;
				_itemMc.addChildAt(_heroImg,1);
				
				_quiltyBar = new Image();
				_quiltyBar.scaleX = _quiltyBar.scaleY = _scaleNum;
				_quiltyBar.y = 2;
				_itemMc.addChildAt(_quiltyBar, 1);
				
			}
			//trace("_blockState:", _blockState);
			if (_blockState == 3 && _blockType == 1)
			{
				view.delBtn.visible = true;
			}
			
			/*if (_blockType == 1)
			{
				trace("unitData:",data);
				trace("_scaleNum:",_scaleNum);
				trace("_heroImg.scaleX:",_heroImg.scaleX);
			}*/
			
			_itemMc.lvTF.visible = _itemMc.scoreTF.visible = _itemMc.sTF.visible = true;
			
			_itemMc.lvTF.text = "LVL." + data.level;
			_itemMc.scoreTF.text = data.militaryScore;
			
			
			_quiltyBar.skin = "common/l" + (GameConfigManager.unit_dic[data.unitId] as FightUnitVo).rarity + "_1.png";
			_quiltyBar.x = (view.unitBg.width - _quiltyBar.width) * _scaleNum / 2;
			
			_heroImg.skin = "appRes/icon/unitPic/" + data.unitId + "_c.png";
			_heroImg.x = (view.unitBg.width - 155) * _scaleNum / 2;
			_heroImg.visible = true;
			
			view.unitBg.skin = "common/bg6_" + ((GameConfigManager.unit_dic[data.unitId] as FightUnitVo).rarity) + ".png";
			
			if (parseInt(data['qy']) == 0)
			{
				_itemMc.disabled = true;
			}
		}
		
		
		override public function createUI():void
		{
			_itemMc = new MilitartUnitItemUI();
			this.addChild(_itemMc);
			
			view.unlockBtn.visible = false;
			view.delBtn.visible = false;
			view.selectFrame.visible = false;
			
			_itemMc.unitBg.mouseEnabled = true;
			
			_itemMc.scaleX = _itemMc.scaleY = _scaleNum;
			_itemMc.unitBg.scaleX = _itemMc.unitBg.scaleY = _scaleNum;
			
			_itemMc.lvTF.scaleX = _itemMc.lvTF.scaleY = _scaleNum;
			_itemMc.lvTF.y = _itemMc.unitBg.height * _scaleNum * 0.65;
			
			_itemMc.sTF.scaleX = _itemMc.sTF.scaleY = _scaleNum;
			_itemMc.sTF.y = _itemMc.unitBg.height * _scaleNum * 0.8;
			
			_itemMc.scoreTF.scaleX = _itemMc.scoreTF.scaleY = _scaleNum;
			_itemMc.scoreTF.y = _itemMc.unitBg.height * _scaleNum * 0.8;
			_itemMc.scoreTF.x = _itemMc.unitBg.width * _scaleNum * 0.33;
			
			_itemMc.openPirceTF.visible = false;
			
			addEvent();
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		public function get view():MilitartUnitItemUI{
			return _itemMc;
		}
	}

}