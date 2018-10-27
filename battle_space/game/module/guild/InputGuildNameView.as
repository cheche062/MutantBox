package game.module.guild 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.vo.User;
	import game.module.tips.CommTip;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.guild.EnterGuildNameUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class InputGuildNameView extends BaseDialog 
	{
		
		private var _iconIndex:int = 0;
		private var _createCost:int = 0;
		
		public function InputGuildNameView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case this.view.helpBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_2511"), CommTip);
					break;
				case this.view.iconImg:
//					XFacade.instance.openModule(ModuleName.GuildIconView);
					break;
				case this.view.createBtn:
					if (this.view.inputNameTF.text.length == 0)
					{
						return;
					}
					
					if (User.getInstance().water < _createCost)
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
						return;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CREATE_GUILD,[this.view.inputNameTF.text,_iconIndex]);
					break;
				case this.view.closeBtn:
					
					close();
					break;
				
			}
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			addEvent();
			//trace("fasdf:", GameConfigManager.guild_params[2]);
			if (GameConfigManager.guild_params[2].value)
			{
				_createCost = parseInt(GameConfigManager.guild_params[2].value.split("=")[1]);
			}
			
			view.priceTF.text = _createCost;
		}
		
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			//trace("CreateGuildSocket",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
				case ServiceConst.GUILD_CREATE_GUILD:
					//trace("创建公会成功");
					close();
					XFacade.instance.closeModule(ModuleName.CreateGuildView);
					User.getInstance().guildID = args[1].guild_id;
					
					XFacade.instance.closeModule(CreateGuildView);
					XFacade.instance.openModule(ModuleName.GuildMainView);
					
					break;
				default:
					break;
			}
		}
		
		private function guildEventHandle(cmd:String, ...args):void 
		{
			switch(cmd)
			{
				case GuildEvent.SELECT_GUILD_ICON:
					_iconIndex = args[0];
					GameConfigManager.setGuildLogoSkin(this.view.iconImg, _iconIndex, 1);
					break;
				default:
					break;
			}
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
			removeEvent();
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new EnterGuildNameUI();
			this.addChild(_view);
			
			this.view.inputNameTF.maxChars = 12;
			GameConfigManager.setGuildLogoSkin(this.view.iconImg, _iconIndex, 1);
					
			this.view.inputNameTF.on(Event.INPUT, this, this.checkInput);
			
			this.view.iconImg.on(Event.CLICK, this, this.onClick);
			
			this.view.costImg.skin = GameConfigManager.getItemImgPath("1");
			
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		private function checkInput(e:Event):void 
		{
			var str:String = StringUtil.removeBlank(this.view.inputNameTF.text);
			this.view.inputNameTF.text = str.substr(0, 30);
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_CREATE_GUILD),this,onResult,[ServiceConst.GUILD_CREATE_GUILD]);
			Signal.intance.on(GuildEvent.SELECT_GUILD_ICON, this, guildEventHandle, [GuildEvent.SELECT_GUILD_ICON]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_CREATE_GUILD), this, onResult);
			Signal.intance.off(GuildEvent.SELECT_GUILD_ICON, this, guildEventHandle);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			super.removeEvent();
		}
		
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function get view():EnterGuildNameUI{
			return _view;
		}
		
	}

}