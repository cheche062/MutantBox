package game.module.bingBook 
{
	import game.common.ItemTips;
	import game.global.data.DBItem;
	import game.global.GameConfigManager;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ItemContainer extends Sprite 
	{
		private var _itemID:String;
		
		private var _bg:Image;
		
		private var _quailtyBar:Image;
		
		private var _itemIcon:Image;
		
		private var _numTF:TextArea;
		
		private var _otherTF:TextArea;
		
		private var _rewardNum:int;
		
		private var _extraRate:Number = 1;
		
		private var _iconPath:String = "";
		
		private var _needTips:Boolean = true;
		
		private var _userCircleBg:Boolean = false;
		
		public function ItemContainer() 
		{
			super();
			this.width = 80;
			this.height = 80;
			
			_bg = new Image();
			_bg.skin = "common/item_bar0.png";
			this.addChild(_bg);
			
			_quailtyBar = new Image();
			_quailtyBar.skin = "common/item_bar0.png";
			_quailtyBar.x = (_bg.width - _quailtyBar.width) / 2;
			_quailtyBar.y = 3;
			this.addChild(_quailtyBar);
			
			_itemIcon = new Image();
			_itemIcon.skin = "appRes/icon/itemIcon/8.png";
			_itemIcon.x = -10;
			_itemIcon.y = -10;
			//_itemIcon.width = _itemIcon.height = 80;
			_itemIcon.on(Event.CLICK, this, this.showItemTips);
			this.addChild(_itemIcon);
			
			_numTF = new TextArea();
			_numTF.mouseEnabled = false;
			_numTF.font = "Futura";
			_numTF.fontSize = 14;
			_numTF.width = 40;
			_numTF.text = "100";
			_numTF.color = "#ffffff";
			_numTF.x = 0;
			_numTF.y = 55;
			_numTF.align = "right";
			_numTF.stroke = 2;
			_numTF.strokeColor = "#000000";
			
			this.addChild(_numTF);
			
			_otherTF = new TextArea();
			_otherTF.mouseEnabled = false;
			_otherTF.font = "Futura";
			_otherTF.fontSize = 14;
			_otherTF.width = 40;
			_otherTF.text = "+0";
			_otherTF.color = "#16ee16";
			_otherTF.x = 40;
			_otherTF.y = 55;
			_otherTF.align = "left";
			this.addChild(_otherTF);
			
			needOtherNum = false;
		}
		
		public function set needOtherNum(need:Boolean):void
		{
			_otherTF.visible = need;
			if (need)
			{
				_numTF.width = 40;
			}
			else
			{
				_numTF.width = 70;
			}
		}
		
		private function showItemTips():void
		{
			if(needTips)
			{
				ItemTips.showTip(_itemID);
			}
		}
		
		public function set dataSource(value:*):void {
			
			if(value){
				setData(value.id, value.num);
			}
		}
		
		public function setData(id:String, num:int=0, isDouble:Boolean = false):void
		{
			_itemID = id;
			if (!_itemID || _itemID == "")
			{
				return;
			}
			
			
			if (_userCircleBg)
			{
				_quailtyBar.skin = "";
				_bg.skin = "common/i" + DBItem.getItemData(id).quality + ".png";
			}
			else
			{
				if (!DBItem.getItemData(id))
				{
					trace("物品查找失败:", id);
					return;
				}
				_quailtyBar.skin = "";
				_bg.skin = "common/item_bar" + (DBItem.getItemData(id).quality-1) + ".png";
			}
			
			_itemIcon.skin = GameConfigManager.getItemImgPath(id);
			
			_numTF.text = num + "";
			if (isDouble)
			{
				_otherTF.text = "+"+num;
			}
			else
			{
				_otherTF.text = "+0";
			}
			_rewardNum = num;
		}
		
		public function doubleReward():void
		{
			_otherTF.text = "+"+_rewardNum*extraRate;
		}
		
		public function get numTF():TextArea 
		{
			return _numTF;
		}
		
		public function set extraRate(value:Number):void 
		{
			_extraRate = value;
		}
		
		public function get extraRate():Number 
		{
			return _extraRate;
		}
		
		public function get needTips():Boolean 
		{
			return _needTips;
		}
		
		public function set needTips(value:Boolean):void 
		{
			_needTips = value;
		}
		
		public function set userCircleBg(value:Boolean):void 
		{
			_userCircleBg = value;
		}
		
		public function set needBg(value:Boolean):void
		{
			_bg.visible = value;
			_quailtyBar.visible = value;
		}
		
	}

}