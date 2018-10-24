package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.GameLanguageMgr;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.util.TimeUtil;
	import game.global.vo.arena.ArenaNPCVo;
	import game.module.fighting.mgr.FightingManager;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.arena.ReportItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class ReportItem extends BaseView
	{
		
		private var fightID:String = "";
		
		public function ReportItem() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				case view.reBtn:
					//FightingManager.intance.getFightReport([fightID],null,Handler.create(this,completeReplayHandler),null,ServiceConst.getFightReport);
					trace("展播会看：", fightID);
					FightingManager.intance.getFightReport([fightID,"arena"]);
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
			
			fightID = value.report_id;
			view.lvTF.text = value.enemy.data.level;
			
			/*if (value.enemy.type == "robot")
			{
				//var npcData:ArenaNPCVo = GameConfigManager.arena_npc_vec[value.enemy.data.arena_fight_level];
				//trace("npcData:", npcData);
				//view.playerForce.text = npcData.br;
				view.lvTF.text = value.enemy.data.level;
				
			}
			else
			{
				//view.playerForce.text = value.data.power;
				view.lvTF.text = value.enemy.data.level;
			}*/
			
			view.nameTF.text = value.enemy.data.name;
			
			view.rTF.text = value.enemy.data.rank;
			view.timeTF.text = checkFightTime(TimeUtil.now / 1000 - parseInt(value.date_time));
			view.resutlTF.text = value.is_win?GameLanguage.getLangByKey("L_A_53025"):GameLanguage.getLangByKey("L_A_53026");
			view.resutlTF.color = value.is_win?"#cbe3fe":"#f7a9a9";
		}
		
		private function checkFightTime(t:int):String
		{
			if (t < 3600)
			{
				return GameLanguage.getLangByKey("L_A_53021").replace("{0}", Math.ceil(t / 60));
			}
			
			if (t < 86400)
			{
				return GameLanguage.getLangByKey("L_A_53022").replace("{0}", Math.ceil(t / 3600));
				
			}
			
			
			return GameLanguage.getLangByKey("L_A_53023").replace("{0}", Math.ceil(t / 86400));
			
		}
		
		override public function createUI():void
		{
			this._view = new ReportItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			addEvent();
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
		
		private function get view():ReportItemUI{
			return _view;
		}
		
	}

}