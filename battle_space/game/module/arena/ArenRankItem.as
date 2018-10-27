package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.vo.arena.ArenaNPCVo;
	import game.global.vo.arena.ArenaRankRewardVo;
	import game.module.bingBook.ItemContainer;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.arena.ArenRankItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenRankItem extends BaseView 
	{
		
		private var _data:Object;
		public function ArenRankItem() 
		{
			super();
			
		}
		
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				
				default:
					break;
			}
		}
		
		public function setRankData(value:*):void
		{
			
			
			if (!value)
			{
				return;
			}
			_data = value;
			
			view.lvTF.text = value.data.level;
			view.powerTF.text = value.data.power;
			
			/*if (_data.type == "robot")
			{
				var npcData:ArenaNPCVo = GameConfigManager.arena_npc_vec[value.data.arena_fight_level];
				view.powerTF.text = npcData.br;
				view.lvTF.text = npcData.level;
			}
			else
			{
				view.lvTF.text = value.data.level;
				view.powerTF.text = value.data.power;
			}*/
			
			switch(_data.will_advance)
			{
				case 1:
					/*view.stateTF.text = "晋级";
					view.stateTF.color = "#8fffa9"*/
					view.stateIcon.skin = "arena/icon_up.png";
					view.rankBg.skin = "arena/bg16.png";
					break
				case 0:
					/*view.stateTF.text = "保级";
					view.stateTF.color = "#add3ff"*/
					view.stateIcon.skin = "arena/icon_ping.png";
					view.rankBg.skin = "arena/bg16_1.png"
					break;
				case -1:
					/*view.stateTF.text = "降级";
					view.stateTF.color = "#ff9999"*/
					view.stateIcon.skin = "arena/icon_down.png";
					view.rankBg.skin = "arena/bg16_2.png"
					break;
			}
			
			view.nameTF.text = value.data.name;
			
			view.rkTF.text = value.rank;
			
			/*view.nameTF.text = value.name;
			
			view.rkTF.text = value.rank;
			view.powerTF.text = "9999";*/
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			
			
		}
		
		override public function createUI():void
		{
			this._view = new ArenRankItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():ArenRankItemUI{
			return _view;
		}
		
	}

}