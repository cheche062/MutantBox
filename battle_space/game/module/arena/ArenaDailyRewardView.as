package game.module.arena 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.arena.ArenaRankVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.List;
	import MornUI.arena.ArenaDailyRewardViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaDailyRewardView extends BaseDialog 
	{
		
		private var _rewardList:Vector.<ArenaRankVo> = new Vector.<ArenaRankVo>();
		
		public static const IS_MY_RANK:Boolean = false;
		
		public function ArenaDailyRewardView() 
		{
			super();
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("dailyReward: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
				case ServiceConst.ARENA_REWARD_STATE:
					
					/*len = args[1].length;
					for (i = 0; i < len ; i++)
					{
						updateGetState(args[1][i].id, args[1][i].num);
					}
					view.rewardList.refresh();*/
					
					view.rewardList.dataSource = args[1]['rankReward'];
					view.rewardList.refresh();
					view.rewardList.selectedIndex = 0;
					break;
				default:
					break;
			}
		}
		
		private function updateGetState(id:int):void
		{
			var len:int = GameConfigManager.arena_point_vec.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (GameConfigManager.arena_point_vec[i].point == id)
				{
					GameConfigManager.arena_point_vec[i].hasRecived = true;
				}
			}
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
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
					view.selectImg.y = e.target.y;
					var index:int = parseInt(e.target.name.split("_")[1]);
					
					IS_MY_RANK = false;
					if (index == User.getInstance().arenaGroup - 1)
					{
						IS_MY_RANK = true;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.ARENA_REWARD_STATE, [index+1]);
					
					break
				case view.closeBtn:
					close();
					break;
				case view.infoBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_53090"));
					break;
				default:
					
					break;
			}
		}
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			var index:int = User.getInstance().arenaGroup - 1;
			view.selectImg.x = view["rank_" + index].x;
			
			IS_MY_RANK = true;
			
			view.myRnTF.x = index * 90;
			view.myRnTF.text = GameLanguage.getLangByKey("L_A_53059") + " " + (parseInt(User.getInstance().arenaRank) > 0?User.getInstance().arenaRank:ArenaMainView.RANK_MAX_NUM + "+");
			
			_rewardList = null;
			_rewardList = new Vector.<ArenaRankVo>();
			
			/*for (var i:int = 0; i < 7; i++) 
			{
				_rewardList.push(GameConfigManager.arena_rankRewawrd_vec[(index * 7) + i]);
			}
			
			view.rewardList.dataSource = _rewardList;
			view.rewardList.refresh();
			view.rewardList.selectedIndex = 0;*/
			
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_REWARD_STATE, [User.getInstance().arenaGroup]);
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
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
			this._view = new ArenaDailyRewardViewUI();
			this.addChild(_view);
			
			this.closeOnBlank = true;
			
			_rewardList = null;
			_rewardList = new Vector.<ArenaRankVo>();
			
			for (var i:int = 0; i < 7; i++) 
			{
				_rewardList.push(GameConfigManager.arena_rankRewawrd_vec[i]);
			}
			
			view.rewardList.itemRender = ArenaRDItem;
			view.rewardList.dataSource = [];
			view.rewardList.scrollBar.sizeGrid = "6,0,6,0";
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_REWARD_STATE),this,serviceResultHandler,[ServiceConst.ARENA_REWARD_STATE]);
			//Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_DAILY_REWARD),this,serviceResultHandler,[ServiceConst.ARENA_DAILY_REWARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_REWARD_STATE),this,serviceResultHandler);
			//Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_DAILY_REWARD),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		
		
		private function get view():ArenaDailyRewardViewUI{
			return _view;
		}
		
	}

}