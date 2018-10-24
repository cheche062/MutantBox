package game.module.guild 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.guild.ChangeGuildIntroUI;
	/**
	 * ...
	 * @author ...
	 */
	public class GuildIntroChangeView  extends BaseDialog
	{
		
		public function GuildIntroChangeView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case this.view.okBtn:
					GuildMainView.setting_config = {"desc": view.inputText.text};
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CHANGE_SETTING, ["desc", view.inputText.text]);
					Signal.intance.event(GuildEvent.CHANGE_GUILD_DESC, [view.inputText.text]);
					close();
					break;
				
				case this.view.cancleBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			view.inputText.text = args[0].intro;
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ChangeGuildIntroUI();
			this.addChild(_view);
			
			this.view.inputText.maxChars = GameConfigManager.guild_params[4].value;
			this.view.inputText.wordWrap = true;
			this.view.inputText.width = 420;
			
			this.view.inputText.on(Event.INPUT, this, this.checkInput);
		}
		
		private function checkInput(e:Event):void 
		{
			var str:String = StringUtil.removeBlank(this.view.inputText.text);
			this.view.inputText.text = str.substr(0, 50);
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		private function get view():ChangeGuildIntroUI{
			return _view;
		}
	}

}