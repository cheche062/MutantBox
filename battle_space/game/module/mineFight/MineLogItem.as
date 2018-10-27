package game.module.mineFight 
{
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.util.TimeUtil;
	import game.module.fighting.mgr.FightingManager;
	import laya.events.Event;
	import MornUI.mineFight.MineLogItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class MineLogItem extends BaseView
	{
		
		private var fightID:String = "";
		
		public function MineLogItem() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.reBtn:
					FightingManager.intance.getFightReport([fightID,"mine_fight"]);
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
				return;
			}
			//trace("va: ", value);
			
			//var dt:int = 
			
			//trace("dt:", dt);
			
			view.resutlTF.text = value.is_win?"win":"lose";
			
			fightID = value.report_id;
			if(value.enemy.name)
			{
				view.nameTF.text = value.enemy.name;
				view.lvTF.text = value.enemy.level;
			}
			else
			{
				view.nameTF.text = GameLanguage.getLangByKey("L_A_54025");
				view.lvTF.text = "1";
			}
			
			view.timeTF.text = checkFightTime(TimeUtil.now / 1000 - parseInt(value.date_time));
		}
		
		private function checkFightTime(t:int):String
		{
			if (t < 3600)
			{
				return Math.ceil(t / 60) + "minuts ago";
			}
			
			if (t < 86400)
			{
				return Math.ceil(t / 3600) + "hours ago";
			}
			
			
			return Math.ceil(t / 86400) + "days ago";
		}
		
		override public function createUI():void
		{
			this._view = new MineLogItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
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
		
		private function get view():MineLogItemUI{
			return _view;
		}
		
	}

}