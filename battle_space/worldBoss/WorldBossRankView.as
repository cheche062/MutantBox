package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossRankItem2UI;
	import MornUI.worldBoss.WorldBossRankItemUI;
	import MornUI.worldBoss.WorldBossRankUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class WorldBossRankView extends BaseDialog
	{
		private var _rankData:Array;
		private var _items:Vector.<WorldBossRankItem>;
		private var _curPage:int;
		private var _bossId:int;
		
		private static const PAGE_SIZE:int = 6;
		public function WorldBossRankView()
		{
			super();
		}
		
		private function format(data:Object):void{
			this.view.tfRank.text = data.myRank+"";
			_rankData = data.users;
			var mydata:Object = getMyData();
			if(mydata){
				this.view.tfKill.text = mydata.kill+"";
			}else{
				this.view.tfKill.text = "0";
			}
			showPage(1);
		}
		
		private function showPage(index:int):void{
			_curPage = index;
			var total:int = getTotalPage();
			view.tfPage.text = _curPage+"/"+total;
			view.btnPre.disabled = _curPage == 1;
			view.btnNext.disabled = _curPage == total;
			
			var start:int = (index-1)*PAGE_SIZE;
			var end:int = Math.min(index*PAGE_SIZE,_rankData.length);
			var src:Array = _rankData.slice(start, end);
			
			var type:String = (_bossId+"").charAt(0)
			for(var i:int=0; i<PAGE_SIZE; i++){
				this._items[i].format(src[i], type);
			}
		}
		
		private function getMyData():Object{
			for(var i:String in _rankData){
				if(_rankData[i].uid == User.getInstance().uid){
					return _rankData[i];
				}
			}
			return null;
		}
		
		private function getTotalPage():int{
			if(!this._rankData || this._rankData.length == 0){
				return 1;
			}
			return Math.ceil(this._rankData.length/PAGE_SIZE)
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.btnClose:
					close();
					break;
				default:
					trace(e.target.name);
					break;
			}
		}
		
		private function serviceResultHandler(cmd:int,... args):void {
			trace("serviceResultHandler::",cmd,args)
			//var cmd = args[0];
			switch (cmd) {
				case ServiceConst.BOSS_RANK_INFO:
					format(args[0])
					break;
				default:
					break;
			}
		}
		

		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			_bossId = args[0][0];			
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.BOSS_RANK_INFO), this, serviceResultHandler);
			WebSocketNetService.instance.sendData(ServiceConst.BOSS_RANK_INFO, [_bossId]);
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
			this._closeOnBlank = true;
			
			_items = new Vector.<WorldBossRankItem>();
			for(var i:int=0; i<6; i++){
				_items.push(new WorldBossRankItem(view["item_"+i]));
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			super.removeEvent();
		}
		
		private function get view():WorldBossRankUI
		{
			_view = _view || new WorldBossRankUI();
			return _view;
		}
		
		
		/**静态数据*/
		private static var _rankConfig:Object
		private static function get rankConfig():Object{
			if(!_rankConfig){
				_rankConfig = ResourceManager.instance.getResByURL("config/p_boss/p_boss_rank.json");
			}
			return _rankConfig;
		}
		
		/**静态方法-根据类型和排行获取排行数据*/
		public static function getRankData(type:*, rank:int):Object{
			for(var i:String in rankConfig){
				if(rankConfig[i].type == type && rankConfig[i].down <= rank && rankConfig[i].up >= rank){
					return rankConfig[i];
				}
			}
			return null;
		}
	}
}