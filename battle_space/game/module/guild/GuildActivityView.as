package game.module.guild
{
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.net.socket.WebSocketNetService;
	import MornUI.guild.GuildActivityViewUI;
	
	import game.common.base.BaseView;
	
	import laya.events.Event;
	
	public class GuildActivityView extends BaseView
	{
		
		private var bossArr:Array = [];
		
		public function GuildActivityView()
		{
			super();
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
			
		}
		
		private function addToStageHandler():void 
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_BOSS_INIT),this,serviceResultHandler,[ServiceConst.GUILD_BOSS_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_GUILD_BOSS), this, serviceResultHandler, [ServiceConst.OPEN_GUILD_BOSS]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(GuildEvent.REFRESH_GUILD_BOSS,this,refreshBossData);
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
		}
		
		private function removeFromStageHandler():void 
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_BOSS_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_GUILD_BOSS), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(GuildEvent.REFRESH_GUILD_BOSS, this, refreshBossData);
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				
				
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("guildboss: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GUILD_BOSS_INIT:
					
					
					bossArr[0] = args[1].free;
					bossArr[0].type = "free";
					bossArr[0].ft = args[2]["free"];
					
					bossArr[1] = args[1].pay1;
					bossArr[1].type = "pay1";
					bossArr[1].ft = args[2]["pay1"];
					
					bossArr[2] = args[1].pay2;
					bossArr[2].type = "pay2";
					bossArr[2].ft = args[2]["pay2"];
					
					view.activityContainer.array = bossArr;	
					view.activityContainer.refresh();
					break;
				case ServiceConst.OPEN_GUILD_BOSS:
					switch(args[1][0])
					{
						case "free":
							bossArr[0].status = 1;
							break;
						case "pay1":
							bossArr[1].status = 1;
							break;
						case "pay2":
							bossArr[2].status = 1;
							break;
						default:
							break;
					}
					view.activityContainer.array = bossArr;	
					view.activityContainer.refresh();
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
					break;
				default:
					break;
			}
		}
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function refreshBossData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
		}
		
		override public function show(...args):void{
			super.show();
			
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildActivityViewUI();
			this.addChild(_view);
			_view.x=5;
			_view.y=45;
			
			view.leftBtn.visible = view.rightBtn.visible = false;
			
			view.activityContainer.itemRender=GuildBossItem;
			view.activityContainer.selectEnable = true;
			//view.activityContainer.array = testData;
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():GuildActivityViewUI{
			return _view;
		}
	}
}