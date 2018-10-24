package game.module.techTree 
{
	import game.common.FilterTool;
	import game.common.XTipManager;
	import game.global.event.Signal;
	import game.global.event.TechEvent;
	import game.global.GameConfigManager;
	import game.global.vo.tech.TechUpdateVo;
	import game.global.vo.User;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TechBlock extends Box 
	{
		
		private var _bg:Image;
		private var _icon:Image;
		private var _line:Image;
		private var _techIcon:Sprite;
		private var _levelFlagBg:Vector.<Sprite> = new Vector.<Sprite>();
		private var _levelFlag:Vector.<Image> = new Vector.<Image>();
		private var _techID:String = "";
		private var _techData:TechUpdateVo;
		private var _isEnd:Boolean = false;
		private var _isGray:Boolean = false;
		private var _selectState:Image;
		
		private var user:User = User.getInstance();
		
		private var _levelNormalPos:Array = [0, 43.5, 40, 36.5, 33, 29.5];
		private var _levelFillPos:Array = [0, 45, 41.75, 38.5, 34.75, 31];
		
		
		private var _lvBg:Image;
		private var _lvTF:Text;
		private var _maxImg:Image;
		
		
		public function TechBlock() 
		{
			super();
			
			_bg = new Image();
			_bg.skin = "appRes/tech/iconbg_3.png";
			this.addChild(_bg);
			
			_icon = new Image();
			this.addChild(_icon);
			
			_selectState = new Image();
			_selectState.skin = "appRes/tech/bg_select.png";
			this.addChild(_selectState);
			_selectState.visible = false;
			
			_lvBg = new Image();
			_lvBg.skin = "appRes/tech/skill_bg_1.png";
			_lvBg.x = -8;
			_lvBg.y = -8.5;
			this.addChild(_lvBg);
			
			_maxImg = new Image();
			_maxImg.skin = "appRes/tech/bg_max.png";
			this.addChild(_maxImg)
			
			_lvTF = new Text();
			_lvTF.font = "Futura";
			_lvTF.fontSize = 18;
			_lvTF.color = "#ffffff";
			_lvTF.text = 99;
			_lvTF.width = 18;
			_lvTF.align = "center";
			this.addChild(_lvTF);
			
			
			
			_line = new Image();
			this.addChild(_line);
			
			this._bg.on(Event.CLICK, this, this.clickItem);
			
		}
		
		public function updateData():void 
		{
			//trace("***************************");
			if (!GameConfigManager.intance.getTechUpdateInfo(_techID, 1))
			{
				//trace("没有找到ID：", _techID);
				return;
			}
			_bg.skin = "appRes/tech/iconbg_3.png";
			
			var len:int = parseInt(_techData.max);
			var curLv:int = 0;
			
			//trace("teData: ", _techData);
			
			if (user.getUserTech(_techID))
			{
				curLv = user.getUserTech(_techID).lv;
			}
			
			if (_techData.condition == "" || !_techData.condition)
			{
				_bg.skin = "appRes/tech/iconbg_2.png";
			}
			else if(user.getUserTech(_techData.condition.split(":")[0]))
			{
				if (user.getUserTech(_techData.condition.split(":")[0]).lv>= GameConfigManager.intance.getTechUpdateInfo(_techData.condition.split(":")[0],1).max)
				{
					_bg.skin = "appRes/tech/iconbg_2.png";
				}
				
			}
			
			if (_techData.tier>1)
			{
				if (user.getUserAllTechPoint() < GameConfigManager.intance.getLowLayerFinishPoint(_techData.tier - 1))
				{
					_bg.skin = "appRes/tech/iconbg_3.png";
				}
			}
			
			_lvTF.text = "";
			_lvBg.visible = false;
			if (curLv >= 1)
			{
				_lvTF.text = curLv;
				_lvBg.visible = true;
				_bg.skin = "appRes/tech/iconbg_1.png";
			}
			
			hideLevelFlag();
			/**等级标识**/
			/*for (var i:int = 0; i < len; i++)  	
			{
				if (!_levelFlag[i])
				{
					_levelFlag[i] = new Image;
					this.addChild(_levelFlag[i]);
				}
				
				_levelFlag[i].visible = true;
				
				if (i < curLv)
				{
					
					_levelFlag[i].skin = "appRes/tech/lvbg_2.png";
					_levelFlag[i].x = _levelNormalPos[len] + 7 * i;
					_levelFlag[i].y = 73.5;
				}
				else
				{
					_levelFlag[i].skin="appRes/tech/lvbg_1.png";
					_levelFlag[i].x = _levelFillPos[len] + 7 * i;
					_levelFlag[i].y = 76;
				}
			}*/
			
			if (curLv >= _techData.max)
			{
				_line.skin="appRes/tech/line_2.png";
				_line.scaleY = 10;
				_line.x = 41;
				_line.y = 85;
				_maxImg.visible = true;
			}
			else
			{
				_line.skin = "appRes/tech/line_1.png";
				_line.scaleY = 10;
				_line.x = 43;
				_line.y = 85;
				_maxImg.visible = false;
			}
			
			if (_bg.skin == "appRes/tech/iconbg_3.png")
			{
				_isGray = true;
				_icon.filters = [FilterTool.grayscaleFilter];
			}
			else
			{
				_isGray = false;
				_icon.filters = [];
			}
		}
		
		private function hideLevelFlag():void
		{
			var len:int = _levelFlag.length;
			for (var i:int = 0; i < len; i++) 
			{
				_levelFlag[i].visible = false;
			}
		}
		
		public function hideSelectState():void
		{
			_selectState.visible = false;
		}
		
		public function clickItem():void
		{
			Signal.intance.event(TechEvent.SELECT_TECH, [_techID, _isGray]);
			_selectState.visible = true;
			
		}
		
		public function setData(id:String,isEnd:Boolean):void
		//override public function set dataSource(value:*):void
		{
			_techID = id;
			_isEnd = isEnd;
			/*this._data = value;
			if(!data)
			{
				return;
			}
			
			trace("this.x: ", this.x);
			trace("this.y: ", this.y);
			trace("");
			_techID = data.id;
			_isEnd = data.isEnd;*/
			
			if (_isEnd)
			{
				this.removeChild(_line);
			}
			_techData = null;
			_techData = GameConfigManager.intance.getTechUpdateInfo(_techID, 1);
			
			
			var curLv:int = 0;
			if (user.getUserTech(_techID))
			{
				curLv = user.getUserTech(_techID).lv;
			}
			
			_bg.skin = "appRes/tech/iconbg_3.png";
			_icon.skin = "appRes/tech/techIcon/" + _techID + ".png";
			_icon.x = _icon.y = 13;
			updateData();
		}
		
		public function get data():Object{
			return this._data;
		}
		
		public function get bg():Image 
		{
			return _bg;
		}
		
	}

}