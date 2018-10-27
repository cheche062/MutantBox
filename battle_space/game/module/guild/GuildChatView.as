package game.module.guild
{
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.common.LayerManager;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.GlobalRoleDataManger;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.friend.ChatInfoView;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.guild.GuildTalkViewUI;

	/**
	 * ...
	 * @author ...
	 */
	public class GuildChatView extends BaseView
	{

		private var _globalData:GlobalRoleDataManger

		public function GuildChatView()
		{
			super();
			m_iPositionType=LayerManager.RIGHT;
			this._m_iLayerType=LayerManager.M_GUIDE;

			_globalData=GlobalRoleDataManger.instance;

		}

		private function onClick(e:Event):void
		{

			switch (e.target)
			{
				case this.view.sendBtn:
					if (view.inputTF.text != "")
					{
						WebSocketNetService.instance.sendData(ServiceConst.SEND_GUILD_TALK, [view.inputTF.text]);
					}
					view.talkContainer.scrollTo(0, 99999);
					break;
				case this.view.closeBtn:
					onClose();
					break;
				default:
					break;
			}
		}

		private function guildTalkHandler(cmd:String, ... args):void
		{
			switch (cmd)
			{
				case GuildEvent.SPREAD_GUILD_TALK:
					if (args[0])
					{
						view.inputTF.text="";
					}
					view.talkContainer.addChild(_globalData.chatItemVec[_globalData.chatCount]);
					_globalData.chatCount++;

					view.talkContainer.refresh();
					view.talkContainer.vScrollBar.value=view.talkContainer.vScrollBar.max;
					break;
				default:
					break;
			}
		}

		protected function stageSizeChange(e:Event=null):void
		{
			var scaleNum:Number=Laya.stage.height / view.height;

			m_iPositionType=LayerManager.RIGHT;
			if (this.y < 0)
			{
				this.y=0;
				this.scaleY=0.85;
				this.scaleX=0.85;
			}

		}

		override public function show(... args):void
		{
			super.show();

			var len:int=_globalData.chatItemVec.length;

			while (GlobalRoleDataManger.instance.chatCount < len)
			{
				view.talkContainer.addChild(_globalData.chatItemVec[_globalData.chatCount]);
				_globalData.chatCount++;
			}
			view.talkContainer.refresh();
			view.talkContainer.vScrollBar.value=view.talkContainer.vScrollBar.max;

			stageSizeChange();

		}

		override public function close():void
		{
			super.close();

		}

		private function onClose():void
		{
			close();
		}

		override public function dispose():void
		{
			super.destroy();
		}

		override public function createUI():void
		{
			this._view=new GuildTalkViewUI();
			this.addChild(_view);

			view.talkContainer.vScrollBar.visible=false;

			this.view.inputTF.maxChars=200;
			this.view.inputTF.on(Event.INPUT, this, this.checkInputContent);
		}

		private function checkInputContent(e:Event):void
		{
			var str:String=this.view.inputTF.text;
			this.view.inputTF.text=str.substr(0, 200);
		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);

			Signal.intance.on(GuildEvent.SPREAD_GUILD_TALK, this, guildTalkHandler, [GuildEvent.SPREAD_GUILD_TALK]);
			Laya.stage.on(Event.RESIZE, this, stageSizeChange);
			super.addEvent();
		}

		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);

			Signal.intance.off(GuildEvent.SPREAD_GUILD_TALK, this, guildTalkHandler);
			Laya.stage.off(Event.RESIZE, this, stageSizeChange);
			super.removeEvent();
		}

		private function get view():GuildTalkViewUI
		{
			return _view;
		}

	}

}
