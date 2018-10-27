package game.module.mineFight 
{
	import game.common.base.BaseView;
	import laya.events.Event;
	import laya.ui.View;
	import MornUI.mineFight.FiveStarAreaUI;
	import MornUI.mineFight.FourStarAreaUI;
	import MornUI.mineFight.FreeMineAreaUI;
	import MornUI.mineFight.OneStarAreaUI;
	import MornUI.mineFight.ThreeStarAreaUI;
	import MornUI.mineFight.TwoStarAreaUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineContainer extends BaseView 
	{
		
		private var _currentArea:View;
		private var _mineAreaVec:Vector.<View> = new Vector.<View>(5);
		
		private var _smallMineInfo:Array = [];
		private var _middleMineInfo:Array = [];
		private var _superMineInfo:Array = [];
		
		private var _smallMineVec:Vector.<MineDetail> = new Vector.<MineDetail>();
		private var _middleMineVec:Vector.<MineDetail> = new Vector.<MineDetail>();
		private var _superMineVec:Vector.<MineDetail> = new Vector.<MineDetail>();
		
		private var _mineData:Object = { };
		private var _mineArr:Array = [];
		
		public function MineContainer() 
		{
			super();
			this.width = 1050;
			this.height = 495;
			this.x = 40;
			this.y = 50;
			
			this.mouseThrough = true;
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			if (!value || !value.mine_star)
			{
				return;
			}
			
			_mineData = value;
			while(this.numChildren)
			{
				this.removeChildAt(0);
			}
			currentArea = null;
			
			this._currentArea = _mineAreaVec[_mineData.mine_star-1];
			currentArea.mouseThrough = true;
			this.addChild(currentArea);
			
			for (var i:int = 0; i < 18; i++) 
			{
				if (currentArea['s_' + i])
				{
					if (!_smallMineVec[i])
					{
						_smallMineVec[i] = new MineDetail();
					}
					_smallMineVec[i].setMC(currentArea['s_' + i]);
				}
				
				if (currentArea['m_' + i])
				{
					if (!_middleMineVec[i])
					{
						_middleMineVec[i] = new MineDetail();
					}
					_middleMineVec[i].setMC(currentArea['m_' + i]);
				}
				
				if (currentArea['b_' + i])
				{
					if (!_superMineVec[i])
					{
						_superMineVec[i] = new MineDetail();
					}
					_superMineVec[i].setMC(currentArea['b_' + i]);
				}
			}
			
		}
		
		public function setMineDetail(ar:Array):void
		{
			_mineArr = ar;
			
			_smallMineInfo = [];
			_middleMineInfo = [];
			_superMineInfo = [];
			
			var len:int = _mineArr.length;
			var i:int = 0;
			for ( i = 0; i < len; i++) 
			{
				switch(_mineArr[i].type)
				{
					case 1:
						_smallMineInfo.push(_mineArr[i]);
						break;
					case 2:
						_middleMineInfo.push(_mineArr[i]);
						break;
					case 3:
						_superMineInfo.push(_mineArr[i]);
						break;
					default:
						break;
				}
			}
			
			for (i = 0; i < 18; i++) 
			{
				if (_smallMineInfo[i])
				{
					
					_smallMineVec[i].dataSource = _smallMineInfo[i];
				}
				
				if (_middleMineInfo[i])
				{
					_middleMineVec[i].dataSource = _middleMineInfo[i];
				}
				
				if (_superMineInfo[i])
				{
					_superMineVec[i].dataSource = _superMineInfo[i];
				}
			}
		}
		
		override public function createUI():void
		{
			
			_mineAreaVec[0] = new OneStarAreaUI();
			_mineAreaVec[1] = new TwoStarAreaUI();
			_mineAreaVec[2] = new ThreeStarAreaUI();
			_mineAreaVec[3] = new FourStarAreaUI();
			_mineAreaVec[4] = new FiveStarAreaUI();
			
			this._currentArea = _mineAreaVec[0];
			this.addChild(this._currentArea);
			
		}
		
		public function clear():void{
			removeEvent();
			this.removeChild(currentArea);
			currentArea = null;
			
		}
		
		override public function addEvent():void{
			//view.on(Event.CLICK, this, this.onClick);
			
			//Signal.intance.on(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler,[GuildEvent.CHANGE_GUILD_DESC]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			//view.off(Event.CLICK, this, this.onClick);
			
			//Signal.intance.off(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler);
			
			super.removeEvent();
		}
		
		public function get currentArea():View 
		{
			return _currentArea;
		}
		
	}

}