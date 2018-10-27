package game.module.guild
{
	import game.global.GameLanguage;
	import MornUI.guild.CreateGuildViewUI;
	import MornUI.guild.GuildListItemUI;
	
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.util.TraceUtils;
	import game.net.socket.WebSocketNetService;
	
	import laya.debug.tools.SingleTool;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.View;
	
	public class GuildListItem extends Box
	{
		
		private var itemMC:GuildListItemUI;
		private var _data:Object;
		
		private var _lanKeyArr:Array = ["", "L_A_2583", "L_A_2584", "不接受申请"];
		
		public function GuildListItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new GuildListItemUI();
			this.addChild(itemMC);
			
			this.itemMC.applyBtn.on(Event.CLICK,this,this.applyGuild);
		}
		
		private function applyGuild(e:Event):void
		{
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_APPLY_JOIN,[_data.id]);
			itemMC.applyBtn.visible = false;
			itemMC.stateTF.text = GameLanguage.getLangByKey("L_A_2507");
			
			Signal.intance.event(GuildEvent.APPLY_GUILD,[_data.id]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			//TraceUtils.dumpTrace(data);
			//trace("gd", data);
			
			if(!data||!data.name)
			{
				return;
			}
			//trace("gData:", data);
			itemMC.gName.text = data.name;
			itemMC.gLv.text = GameLanguage.getLangByKey("L_A_73") + data.lv;
			//itemMC.gType.text = data.type;
			itemMC.gType.text = GameLanguage.getLangByKey(_lanKeyArr[data.type]);
			itemMC.gMemeber.text = data.member + "/" + data.maxNum;
			itemMC.gJoin.text = data.join;
			itemMC.applyBtn.visible = true;
			itemMC.stateTF.text = GameLanguage.getLangByKey("L_A_2506");
			if(data.state == 1)
			{
				itemMC.applyBtn.visible = false;
				itemMC.stateTF.text = GameLanguage.getLangByKey("L_A_2507");
			}
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():GuildListItemUI{
			return itemMC;
		}
	}
}