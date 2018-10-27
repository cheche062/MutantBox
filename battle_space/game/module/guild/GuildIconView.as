package game.module.guild 
{
	import MornUI.guild.GuildIconViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;

	/**
	 * ...
	 * @author ...
	 */
	public class GuildIconView extends BaseDialog
	{
		private var _iconBg:Vector.<Image> = new Vector.<Image>(10);
		private var _iconVec:Vector.<Image> = new Vector.<Image>(10);
		
		private var _index:int = 0;
		
		private var _isChangeIcon:Boolean = false;
		
		public function GuildIconView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.confirmBtn:
					if (_isChangeIcon)
					{
						GuildMainView.setting_config = {"icon": _index};
						WebSocketNetService.instance.sendData(ServiceConst.GUILD_CHANGE_SETTING, ["icon", _index]);
						Signal.intance.event(GuildEvent.CHANGE_GUILD_ICON, [_index]);
					}
					else
					{
						Signal.intance.event(GuildEvent.SELECT_GUILD_ICON, [_index]);
					}
					close();
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			if (args  && args[0] == "change")
			{
				_isChangeIcon = true;
			}
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.destroy();
		}
		
		override public function createUI():void
		{
			this._view = new GuildIconViewUI();
			this.addChild(_view);
			
			for (var i:int = 0; i < 8; i++) 
			{
				_iconBg[i] = view["bg_" + i];
				_iconBg[i].on(Event.CLICK, this, this.selectIcon);
				
				_iconVec[i] = new Image();
				_iconVec[i].x = 90 + 120 * (i % 4);
				_iconVec[i].y = 120 + 120 * parseInt(i / 4);
				GameConfigManager.setGuildLogoSkin(_iconVec[i], i, 0.5);
				_iconVec[i].mouseEnabled = false;
				view.addChild(_iconVec[i]);
			}
			
			this.closeOnBlank = true;
			_iconBg[0].skin = "appRes/icon/guildIcon/ibg_s.png";
			
		}
		
		private function selectIcon(e:Event):void 
		{
			_index = e.currentTarget.name.split("_")[1];
			for (var i:int = 0; i < 8; i++) 
			{
				if (i == _index)
				{
					_iconBg[i].skin = "appRes/icon/guildIcon/ibg_s.png";
				}
				else
				{
					_iconBg[i].skin = "appRes/icon/guildIcon/ibg_n.png";
				}
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			//Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_CHANGE),this,serviceResultHandler,[ServiceConst.ARENA_SHOP_CHANGE]);
			//Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_LOG),this,serviceResultHandler,[ServiceConst.ARENA_SHOP_LOG]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			//Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_CHANGE),this,serviceResultHandler);
			//Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_SHOP_LOG),this,serviceResultHandler);
			
			super.removeEvent();
		}
		
		
		
		private function get view():GuildIconViewUI{
			return _view;
		}
	}

}