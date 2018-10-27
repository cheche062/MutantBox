package game.module.guild
{
	import MornUI.guild.GuildActivityItmeUI;
	
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	
	import laya.events.Event;
	import laya.ui.Box;
	
	public class GuildActivityItem extends Box
	{
		private var itemMC:GuildActivityItmeUI;
		private var _data:Object;
		public function GuildActivityItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new GuildActivityItmeUI();
			this.addChild(itemMC);
			
			itemMC.enterBtn.on(Event.CLICK,this,enterBossView);
			
			view.enterBtn['clickSound'] = ResourceManager.getSoundUrl("ui_guild_select_enter",'uiSound')
		}
		
		private function enterBossView(e:Event):void
		{
			XFacade.instance.closeModule(GuildMainView);
			XFacade.instance.openModule(ModuleName.GuildBossView);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			
			if(!data||!data.name)
			{
				return;
			}
			
			itemMC.blueBg.visible = true;
			
			
			itemMC.actNameTF.text= GameLanguage.getLangByKey(data.name);
			//itemMC.lockTF.text = "[ASSOCIATION LEVEL "+ data.lv +" UNLOCK]";
			itemMC.lockTF.text = "";
			//itemMC.actDesTF.text = data.des;
			
			
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():GuildActivityItmeUI{
			return itemMC;
		}
	}
}