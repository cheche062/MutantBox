package game.module.arena 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.arena.AreanRankViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaRankView extends BaseDialog 
	{
		private var _rankType:int = 1;
		
		private var _rankList:Array = [];
		private var _nowPage:int = 1;
		private var _maxPage:int = 1;
		
		private var _rankItemVec:Vector.<ArenRankItem> = new Vector.<ArenRankItem>(5);
		
		public function ArenaRankView() 
		{
			super();
			this.on(Event.ADDED, this, getRankData);
			
			var len:int = GameConfigManager.arena_rankRewawrd_vec
			
		}
		
		private function getRankData():void
		{
			
		}
		
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.ARENA_RANK_LIST:
					//trace("ranklist:", args);
					_nowPage = 1;
					_rankList = args[1].users;
					var len:int = _rankList.length;
					if (len % 5 == 0)
					{
						_maxPage = len / 5;
					}
					else
					{
						_maxPage = parseInt(len / 5) + 1;
					}
					
					if (_maxPage == 0)
					{
						_nowPage = 0;
					}
					
					refreshData();
					break;
				default:
					break;
			}
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.rank_0:
				case view.rank_1:
				case view.rank_2:
				case view.rank_3:
				case view.rank_4:
				case view.rank_5:
				case view.rank_6:
				case view.rank_7:
				case view.rank_8:
				case view.rank_9:
					view.selectImg.x = e.target.x;
					var index:int = parseInt(e.target.name.split("_")[1]);
					
					WebSocketNetService.instance.sendData(ServiceConst.ARENA_RANK_LIST,(index+1));
					
					break
				case view.prevBtn:
					if (_maxPage == 0)
					{
						return;
					}
					_nowPage--;
					if (_nowPage <= 1)
					{
						_nowPage = 1;
					}
					refreshData();
					break;
				case view.nextBtn:
					if (_maxPage == 0)
					{
						return;
					}
					_nowPage++;
					if (_nowPage >= _maxPage)
					{
						_nowPage = _maxPage;
					}
					refreshData();
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		public function refreshData():void
		{
			for (var i:int = 0; i < 5; i++) 
			{
				if (_rankList[parseInt((_nowPage-1) * 5) + i])
				{
					_rankItemVec[i].setRankData(_rankList[parseInt((_nowPage-1) * 5) + i]);
					_rankItemVec[i].visible = true;
				}
				else
				{
					_rankItemVec[i].visible = false;
				}
			}
			
			view.pageTF.text = _nowPage+"/" + _maxPage;
		}
		
		override public function show(...args):void
		{
			super.show();
			
			this.closeOnBlank = true;
			
			AnimationUtil.flowIn(this);
			
			switch(args[0][1])
			{
				case 1:
					view.myState.skin = "arena/icon_up.png";
					break
				case 0:
					view.myState.skin = "arena/icon_ping.png";
					break;
				case -1:
					view.myState.skin = "arena/icon_down.png";
					break;
			}
			
			view.myLvTF.text = User.getInstance().level;
			view.myNameTF.text = User.getInstance().name;
			view.myRkTF.text = User.getInstance().arenaRank;
			view.myPowerTF.text =  args[0][0];
			
			view.selectImg.x = view["rank_" + (User.getInstance().arenaGroup - 1)].x;
			
			view.myRankIcon.skin = "arena/r" + User.getInstance().arenaGroup + ".png";
			
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_RANK_LIST,User.getInstance().arenaGroup);
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
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new AreanRankViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			for (var i:int = 0; i < 5; i++) 
			{
				_rankItemVec[i] = new ArenRankItem();
				_rankItemVec[i].x = 117;
				_rankItemVec[i].y = 190 + i * 50;
				view.addChild(_rankItemVec[i]);
			}
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_RANK_LIST), this, this.serviceResultHandler,[ServiceConst.ARENA_RANK_LIST]);
			super.addEvent();
		}
		
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_RANK_LIST), this, this.serviceResultHandler);
			
			super.removeEvent();
		}
		
		private function get view():AreanRankViewUI{
			return _view;
		}
		
	}

}