package game.module.guild
{
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.net.socket.WebSocketNetService;
	import MornUI.guild.GuildDonationViewUI;
	import MornUI.guild.GuildRankViewUI;
	
	import game.common.base.BaseView;
	
	import laya.events.Event;
	
	public class GuildRankView extends BaseView
	{
		private var _rankArr:Array = [];
		
		public function GuildRankView()
		{
			super();
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
		}
		private function addToStageHandler():void 
		{
			view.rankList.array = null;
			addEvent();
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_RANK_LIST);
		}
		
		private function removeFromStageHandler():void 
		{
			removeEvent();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				
			}
		}
		
		private function onResult(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int = 0;
			switch(cmd){
				case ServiceConst.GUILD_RANK_LIST:
					var arr:Array = args[1];
					len = arr.length;
					_rankArr = [];
					
					
					
					for (i = 0; i < len; i++ )
					{
						var rd:Object = { };
						rd['id'] = arr[i].id;
						rd['rank'] = arr[i].rank;
						rd['rName'] = arr[i].name;
						rd['exp'] = arr[i].exp;
						rd['aLv'] = arr[i].level;
						rd['memberNum'] = arr[i].members_count;						
						rd['maxNum'] = GameConfigManager.guild_info_vec[arr[i].level].max_member;
						
						_rankArr.push(rd);
					}
					
					_rankArr = _rankArr.sort(function(a, b) {
						return Number(b["exp"]) - Number(a["exp"]); 
					}).map(function(item, index) {
						item["rank"] = index + 1;
						return item;
					});
					
					view.rankList.array = _rankArr;
					view.rankList.refresh();
					break;
				default:
					break;
			}
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
			this._view = new GuildRankViewUI();
			this.addChild(_view);
			_view.x=5;
			_view.y=45;
			
			/*var testData:Array=[{rank:"1",rName:"asdfsad",aLv:"10",honorNum:"100",memberNum:"50",maxNum:"120"},
				{rank:"2",rName:"asgdasg",aLv:"10",honorNum:"100",memberNum:"50",maxNum:"120"},
				{rank:"3",rName:"asdfsda",aLv:"10",honorNum:"100",memberNum:"50",maxNum:"120"},
				{rank:"4",rName:"fasdf",aLv:"10",honorNum:"100",memberNum:"50",maxNum:"120"},
				{rank:"5",rName:"asdfsda",aLv:"10",honorNum:"100",memberNum:"50",maxNum:"120"}];*/
			//init scrollbar
			
			view.rankList.itemRender=GuildRankItem;
			view.rankList.selectEnable = true;
			view.rankList.scrollBar.sizeGrid = "6,0,6,0";
			
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_RANK_LIST), this, onResult, [ServiceConst.GUILD_RANK_LIST]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_RANK_LIST),this,onResult);
			
			super.removeEvent();
		}
		
		private function get view():GuildRankViewUI{
			return _view;
		}
	}
}