package game.module.arena 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import MornUI.arena.ArenaGetRewardViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaGetRewardView extends BaseDialog 
	{
		
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>(5);
		
		private var _posArr:Object = [];
		
		public function ArenaGetRewardView() 
		{
			super();
			
			_posArr["1"] = 213;
			_posArr["2"] = 166;
			_posArr["3"] = 119;
			_posArr["4"] = 72;
			_posArr["5"] = 25;
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				
				case view.confirmBtn:
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
			switch(args[0][0])
			{
				case "daily":
					view.rewardTitle.text = GameLanguage.getLangByKey("L_A_53086");// "昨日牌名奖励";
					view.timeTips.visible = true;;
					break;
				case "season":
					view.rewardTitle.text = GameLanguage.getLangByKey("L_A_53089");//"上赛季奖励";
					view.timeTips.visible = false;
					break;
				default:
					break;
			}
			showReward(args[0][1]);
			//WebSocketNetService.instance.sendData(ServiceConst.ARENA_DAILY_REWARD_LOG, []);
		}
		
		private function showReward(reward:String):void
		{
			var list:Array = reward.split(";");
			var len:int = list.length;
			for (var i:int = 0; i < 5; i++) 
			{
				if (list[i])
				{
					_rewardVec[i].x = _posArr[len] + i * 94;
					_rewardVec[i].visible = true;
					_rewardVec[i].setData(list[i].split("=")[0], list[i].split("=")[1]);
					if (parseInt(list[i].split("=")[0]) == 12)
					{
						User.getInstance().areanCoin += parseInt(list[i].split("=")[1]);
					}
				}
				else
				{
					_rewardVec[i].visible = false;
				}
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
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new ArenaGetRewardViewUI();
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			for (var i:int = 0; i < 5; i++) 
			{
				_rewardVec[i] = new ItemContainer();
				_rewardVec[i].x = 25 + i * 94;
				_rewardVec[i].y = 140;
				view.addChild(_rewardVec[i]);
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		
		
		private function get view():ArenaGetRewardViewUI{
			return _view;
		}
		
	}

}