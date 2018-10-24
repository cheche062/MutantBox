package game.module.guild
{
	import MornUI.guild.GuildTalkItemUI;

	import game.common.XFacade;
	import game.global.ModuleName;
	import game.module.fighting.mgr.FightingManager;

	import laya.events.Event;
	import laya.ui.Box;

	/**
	 * ...
	 * @author ...
	 */
	public class GuildChatItem extends Box
	{

		private var itemMC:GuildTalkItemUI;
		private var _data:Object;

		public function GuildChatItem()
		{
			super();
			init();
		}

		private function init():void
		{
			this.itemMC=new GuildTalkItemUI();
			this.addChild(itemMC);

			this.itemMC.myWordTF.wordWrap=true;
			this.itemMC.myWordTF.fontSize=16;

			this.itemMC.oWordTF.wordWrap=true;
			this.itemMC.oWordTF.fontSize=16;

			this.itemMC.wordTF.fontSize=16;

			this.itemMC.helpBtn.visible=false;
			this.itemMC.helpBtn.on(Event.CLICK, this, this.gotoHelp);


		}

		private function gotoHelp():void
		{
			trace("前去帮忙" + data.params[0]);
			//FightingManager.intance.getSquad(112,好友ID,Handler); 
			switch (data.type)
			{
				case "dh":
					FightingManager.intance.getSquad(112, data.params[0]);
					break;
				case "tm":
					XFacade.instance.openModule(ModuleName.TeamCopyMainView, data.params[0]);
					break;
				default:
					break;
			}
			XFacade.instance.closeModule(GuildChatView);
			XFacade.instance.closeModule(GuildMainView);

		}

		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{

			this._data=value;
			trace("消息数据~~~~~~~~~~~~~~");
			if (!data)
			{
				return;
			}

			itemMC.sysWord.visible=false;
			itemMC.otherWord.visible=false;
			itemMC.selfWord.visible=false;
			itemMC.helpBtn.visible=false;
			itemMC.sysBg.height=60;
			itemMC.myWordTF.text="";
			this.height=100;

			switch (data.type)
			{
				case "sys":
					itemMC.sysWord.visible=true;
					itemMC.wordTF.text=data.time + "  " + data.name + " " + data.word;
					break;
				case "other":
					itemMC.otherWord.visible=true;
					itemMC.oSenderTF.text=data.name;
					itemMC.oTimeTF.text=data.time;
					itemMC.oWordTF.text=data.word;
					if (itemMC.oWordTF.textHeight > 50)
					{
						this.height=this.itemMC.oBg.height=45 + itemMC.oWordTF.textHeight;
					}

					break;
				case "self":
					itemMC.selfWord.visible=true;
					itemMC.senderTF.text=data.name;
					itemMC.timeTF.text=data.time;
					itemMC.myWordTF.text=data.word;
					if (itemMC.myWordTF.textHeight > 50)
					{
						this.height=this.itemMC.mBg.height=45 + itemMC.myWordTF.textHeight;
					}
					break;
				case "tm":
				case "dh":
					itemMC.sysWord.visible=true;
					itemMC.wordTF.text=data.time + "  " + data.name + " " + data.word;
					itemMC.helpBtn.visible=true;
					this.height=120;
					itemMC.sysBg.height=115;
					break;

				default:
					break;
			}
		}

		public function get data():Object
		{
			return this._data;
		}

		private function get view():GuildTalkItemUI
		{
			return itemMC;
		}
	}

}
