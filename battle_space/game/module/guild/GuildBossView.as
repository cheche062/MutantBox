package game.module.guild
{
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.net.socket.WebSocketNetService;
	import MornUI.guild.CreateGuildViewUI;
	import MornUI.guild.GuildBossViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.ModuleName;
	
	import laya.events.Event;
	import laya.ui.Dialog;
	
	public class GuildBossView extends BaseDialog
	{
		private var bossArr:Array = [];
		
		public function GuildBossView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				case this.view.closeBtn:
					close();
					XFacade.instance.openModule(ModuleName.GuildMainView);
					break;
				
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
					
					
					view.bossListContainer.array = bossArr;	
					view.bossListContainer.refresh();
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
					view.bossListContainer.array = bossArr;	
					view.bossListContainer.refresh();
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
			//AnimationUtil.flowIn(this);
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
			
		}
		
		override public function close():void{
			super.close();
			
			//AnimationUtil.flowOut(this, onClose);
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function refreshBossData():void
		{
			//WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildBossViewUI();
			this.addChild(_view);
			
			view.leftBtn.visible = false;
			view.rightBtn.visible = false;
			
			/*var testData:Array=[{name:"test1",lv:"99",type:"1",member:"45",join:"25",state:1},
				{name:"test9",lv:"99",type:"3",member:"45",join:"25",state:1},
				{name:"test10",lv:"99",type:"1",member:"45",join:"25",state:1}];*/
			//init scrollbar
			
			view.bossListContainer.hScrollBarSkin="";
			view.bossListContainer.itemRender=GuildBossItem;
			view.bossListContainer.selectEnable = true;
			view.bossListContainer.array = [];
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_BOSS_INIT),this,serviceResultHandler,[ServiceConst.GUILD_BOSS_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_GUILD_BOSS), this, serviceResultHandler, [ServiceConst.OPEN_GUILD_BOSS]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(GuildEvent.REFRESH_GUILD_BOSS,this,refreshBossData);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_BOSS_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_GUILD_BOSS), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(GuildEvent.REFRESH_GUILD_BOSS, this, refreshBossData);
			
			super.removeEvent();
		}
		
		private function get view():GuildBossViewUI{
			return _view;
		}
	}
}