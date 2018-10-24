package game.module.guild 
{
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.guild.SetGuildJoinLvUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GuildSetLvView extends BaseDialog 
	{
		
		public function GuildSetLvView() 
		{
			super();
			
		}
		private function onClick(e:Event):void
		{
			var lv:int = parseInt(this.view.lvTF.text);
			if (!lv)
			{
				lv = 0;
			}
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					break;
				case this.view.minBtn:
					lv--;
					if (lv <= 0)
					{
						lv = 0;
					}
					this.view.lvTF.text = lv;
					break;
				case this.view.addBtn:
					lv++;
					this.view.lvTF.text = lv;
					break;
				case this.view.confirmBtn:
					GuildMainView.setting_config = {"join_limit": lv};
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CHANGE_SETTING, ["join_limit", lv]);
					Signal.intance.event(GuildEvent.CHANGE_JOIN_LV, [lv]);
					close();
					break;
				default:
					break;
			}
			
		}
		
		override public function show(...args):void{
			super.show();
			//trace(args);
			
			this.view.lvTF.text = args[0].nowLv;
			
			
		}
		
		override public function close():void{
			
			super.close();
			
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		override public function createUI():void{
			this._view = new SetGuildJoinLvUI();
			this.addChild(_view);
			
			this.view.lvTF.restrict = "0-9";
			this.view.lvTF.on(Event.INPUT, this, this.checkEnterLv);
			
		}
		
		private function checkEnterLv(e:Event):void 
		{
			
			var lv:int = parseInt(this.view.lvTF.text);
			
			if (!lv)
			{
				lv = 0;
			}
			
			this.view.lvTF.text = "";
			this.view.lvTF.text = parseInt(lv) > 100?100:parseInt(lv);
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():SetGuildJoinLvUI{
			return _view;
		}
		
	}

}