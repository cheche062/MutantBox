package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.ItemTips;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.vo.arena.ArenaRankVo;
	import game.global.vo.arena.ArenaScoreVo;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.arena.AreaDRItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaRDItem extends BaseView 
	{
		private var _rewardData:ArenaScoreVo;
		
		private var _seasonRewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var _rewardArr:Array = [];
		
		private var _data:ArenaRankVo;
		
		private var _pos1:Object = { };
		
		private var _pos2:Object = { };
		
		public function ArenaRDItem() 
		{
			super();
			
			_pos1["1"] = 180;
			_pos1["2"] = 120;
			
			_pos2["4"] = 335;//95
			_pos2["3"] = 370;
			_pos2["2"] = 430;
			_pos2["1"] = 475;
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			if (!value)
			{
				return;
			}
			//trace("dafdas:",value);
			_data = value as ArenaRankVo;
			
			if (_data.up == _data.down)
			{
				view.rankTF.text = _data.up;
			}
			else
			{
				view.rankTF.text = _data.down+"--"+_data.up;
			}
			
			view.myRankTips.visible = false;
			
			if (User.getInstance().arenaRank >= _data.down && User.getInstance().arenaRank <= _data.up && ArenaDailyRewardView.IS_MY_RANK)
			{
				view.myRankTips.visible = true;
			}
			
			var r1:Array = _data.reward.split(";");
			var len:int = r1.length;
			var i:int = 0;
			
			for (i = 0; i <4 ; i++) 
			{
				if (!r1[i])
				{
					_seasonRewardVec[i].visible = false;
				}
				else
				{
					_seasonRewardVec[i].x = _pos2[len]-100 + i * 95;
					_seasonRewardVec[i].visible = true;
					_seasonRewardVec[i].setData(r1[i].split("=")[0],r1[i].split("=")[1]);
				}
			}
			
			switch(parseInt(_data.sjj))
			{
				case 0:
					/*view.stateTF.text = "晋级";
					view.stateTF.color = "#8fffa9"*/
					view.stateIcon.skin = "arena/icon_up.png";
					view.itemBg.skin = "arena/bg8.png";
					break
				case 1:
					/*view.stateTF.text = "保级";
					view.stateTF.color = "#add3ff"*/
					view.stateIcon.skin = "arena/icon_ping.png";
					view.itemBg.skin = "arena/bg8_1.png"
					break;
				case 2:
					/*view.stateTF.text = "降级";
					view.stateTF.color = "#ff9999"*/
					view.stateIcon.skin = "arena/icon_down.png";
					view.itemBg.skin = "arena/bg8_2.png"
					break;
			}
		}
		
		override public function createUI():void
		{
			this._view = new AreaDRItemUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			var i:int = 0;
			
			for (i = 0; i <4 ; i++) 
			{
				if (!_seasonRewardVec[i])
				{
					_seasonRewardVec[i] = new ItemContainer();
					_seasonRewardVec[i].x = _pos2["4"] + i * 100;
					_seasonRewardVec[i].y = 10;
					view.addChild(_seasonRewardVec[i]);
				}
				//_seasonRewardVec[i].setData(r1[i].split("=")[0],r1[i].split("=")[1]);
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			//Signal.intance.on(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler,[GuildEvent.CHANGE_GUILD_DESC]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			//Signal.intance.off(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler);
			
			super.removeEvent();
		}
		
		private function get view():AreaDRItemUI{
			return _view;
		}
		
	}

}