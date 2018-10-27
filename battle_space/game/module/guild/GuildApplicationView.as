package game.module.guild
{
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	import MornUI.guild.GuildApplicationViewUI;
	
	import game.common.base.BaseView;
	
	import laya.events.Event;
	
	public class GuildApplicationView extends BaseView
	{
		private var _applyList:Array = [];
		
		public function GuildApplicationView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				
			}
		}
		
		public function getListData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_GET_ALL_APPLICATION);
		}
		
		override public function show(...args):void{
			super.show();
		}
		
		override public function close():void{
			
		}
		
		private function guildEventHandler(cmd:int, ...args):void 
		{
			
			switch(cmd)
			{
				case GuildEvent.DELECT_APPLY_MEMBER:
					delMember(args);
					break;
				default:
					break;
			}
		}
		
		private function delMember(uid:String)
		{
			var len:int = _applyList.length;
			for(var i:int=0;i<len;i++)
			{
				if(_applyList[i].uid == uid)
				{
					_applyList.splice(i, 1);
					i--;
					len--;
				}
			}
			view.applicationList.array = _applyList;
			view.applicationList.refresh();
		}
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GUILD_GET_ALL_APPLICATION:
					trace("aaaaaaa:", args);
					_applyList = [];
					len = args[1].length;
					for (i = 0; i < len; i++) 
					{
						_applyList.push( {
							name:args[1][i].name,
							lv:args[1][i].level,
							state:args[1][i].state,
							uid:args[1][i].uid,
							timeFlag:args[1][i].expire
						});
					}
					
					view.applicationList.array = _applyList;
					
					view.noTips.visible = Boolean(_applyList.length == 0);
					view.applicationList.refresh();
					break;
				default:
					break;
			}
		}
		
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildApplicationViewUI();
			this.addChild(_view);
			_view.x=5;
			_view.y=45;
			
			
			//init scrollbar			
			view.applicationList.itemRender=ApplicationItem;
			view.applicationList.selectEnable = true;
			view.applicationList.scrollBar.sizeGrid = "6,0,6,0";
			view.applicationList.array = [];
			
			addEvent();
			
		}
		
		override public function addEvent():void {
			
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_APPLICATION), this, onResult, [ServiceConst.GUILD_GET_ALL_APPLICATION]);
			
			Signal.intance.on(GuildEvent.DELECT_APPLY_MEMBER, this, this.guildEventHandler, [GuildEvent.DELECT_APPLY_MEMBER]);
			
			super.addEvent();
		}
		
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_APPLICATION),this,onResult);
			
			Signal.intance.on(GuildEvent.DELECT_APPLY_MEMBER, this, this.guildEventHandler, [GuildEvent.DELECT_APPLY_MEMBER]);
			
			super.removeEvent();
		}
		
		private function get view():GuildApplicationViewUI{
			return _view;
		}
	}
}