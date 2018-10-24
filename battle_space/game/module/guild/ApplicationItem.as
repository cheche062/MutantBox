package game.module.guild
{
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.guild.ApplicationItemUI;
	import MornUI.guild.RequireListItemUI;
	
	import laya.display.Sprite;
	import laya.ui.Box;

	public class ApplicationItem extends Box
	{
		
		private var itemMC:ApplicationItemUI;
		private var _data:Object;
		
		
		public function ApplicationItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new ApplicationItemUI();
			this.addChild(itemMC);
			
			itemMC.confirmBtn.on(Event.CLICK, this, this.btnEventHandler);
			itemMC.denyBtn.on(Event.CLICK, this, this.btnEventHandler);
			
		}
		
		private function btnEventHandler(e:Event):void 
		{
			switch(e.currentTarget)
			{
				case itemMC.confirmBtn:
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CONFIRM_APPLY, [data.uid]);
					Signal.intance.event(GuildEvent.DELECT_APPLY_MEMBER, [data.uid]);
					break;
				case itemMC.denyBtn:
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_DENY_APPLY, [data.uid]);
					Signal.intance.event(GuildEvent.DELECT_APPLY_MEMBER, [data.uid]);
					break;
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			
			if(!data||!data.name)
			{
				return;
			}
			
			itemMC.nameTF.text = data.name;
			itemMC.lvTF.text = data.lv;
			
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():ApplicationItemUI{
			return itemMC;
		}
	}
}