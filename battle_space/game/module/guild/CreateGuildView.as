package game.module.guild
{
	import mx.utils.object_proxy;
	
	import MornUI.guild.CreateGuildViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.event.BagEvent;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.train.TrainItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.View;
	
	public class CreateGuildView extends BaseDialog
	{
		private var guildListArray:Array=[];
		
		
		public function CreateGuildView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case this.view.createBtn:
					XFacade.instance.openModule(ModuleName.InputGuildNameView);
					break;
				case this.view.searchBtn:
					if (this.view.searchInput.text.length > 0)
					{
						WebSocketNetService.instance.sendData(ServiceConst.GUILD_GET_ALL_GUILD_LIST,[this.view.searchInput.text]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.GUILD_GET_ALL_GUILD_LIST,[]);
					}
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
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_GET_ALL_GUILD_LIST, []);
			
			//GameConfigManager.intance.getGuildInitData();
			
		}
		
		private function guildEventHandler(cmd:int,...args):void
		{
			switch(cmd)
			{
				case GuildEvent.APPLY_GUILD:
					appyGuild(args);
					
					break;
				default:
					break;
			}
		}
		
		private function appyGuild(gid:String):void
		{
			var len:int = guildListArray.length;
			for(var i:int=0;i<len;i++)
			{
				if(guildListArray[i].id == gid)
				{
					guildListArray[i].state=1;
				}
			}
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
				case ServiceConst.GUILD_GET_ALL_GUILD_LIST:
					guildListArray = [];
					len = args[1].guild_list.length;
					var canApply:Boolean = args[1].can_apply;
					//trace("canApply", canApply);
					for	(i=0;i<len;i++)
					{
						var gData:Object={};
						guildListArray.push({
							id:args[1].guild_list[i].id,
							name:args[1].guild_list[i].name,
							type:args[1].guild_list[i].join_type,
							lv:args[1].guild_list[i].level,
							member:args[1].guild_list[i].members_count,
							join:args[1].guild_list[i].join,
							state:canApply?args[1].guild_list[i].is_apply:1,
							maxNum:args[1].guild_list[i].max_member
						})
					}
					view.guildListContainer.array = guildListArray;
					break;
				default:
					break;
			}
		}
		private function checkInput(e:Event):void 
		{
			var str:String = StringUtil.removeBlank(this.view.searchInput.text);
			this.view.searchInput.text = str.substr(0, 30);
			
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
			removeEvent();
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function dispose():void{
			//do nothing
			if(User.getInstance().guildID == "")
			{//如果没有工会，废掉
				super.dispose();
				Loader.clearRes("guild/guildActivityView/wkk.png");
				Loader.clearRes("guild/guildStoreView/bgg.png");
				Loader.clearRes("guild/guildDonateView/kxx.png");
				Loader.clearRes("guild/guildMainView/menu_bg.png");
				Loader.clearRes("guild/guildApplicationView/bgg.png");
			}
		}
		
		override public function createUI():void{
			this._view = new CreateGuildViewUI();
			this.addChild(_view);
			
			
			//init scrollbar
			
			//view.guildListContainer.vScrollBarSkin="";
			view.guildListContainer.itemRender=GuildListItem;
			view.guildListContainer.selectEnable = true;
			
			this.view.searchInput.maxChars = 30;
			this.view.searchInput.on(Event.INPUT, this, this.checkInput);
			view.createBtn['clickSound'] = ResourceManager.getSoundUrl("ui_guild_apply_join",'uiSound')
			
//			var testData:Array=[{name:"test1",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test2",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test3",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test4",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test5",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test6",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test7",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test8",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test9",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1},
//				{name:"test10",lv:"99",type:"NEED REQUIRE",member:"45",join:"25",state:1}];
//			view.guildListContainer.array = testData;
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_GUILD_LIST),this,onResult,[ServiceConst.GUILD_GET_ALL_GUILD_LIST]);
			
			Signal.intance.on(GuildEvent.APPLY_GUILD,this,this.guildEventHandler,[GuildEvent.APPLY_GUILD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_GUILD_LIST),this,onResult);
			
			Signal.intance.off(GuildEvent.APPLY_GUILD,this,this.guildEventHandler);
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
		
		private function get view():CreateGuildViewUI{
			return _view;
		}
	}
}