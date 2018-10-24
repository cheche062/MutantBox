package game.module.guild 
{
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import laya.events.Event;
	import MornUI.guild.GuildBossRewardsUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GuildBossReward extends BaseDialog 
	{
		
		private var _rewardInfo:Array = [];
		
		public function GuildBossReward() 
		{
			super();
			/*_rewardInfo =[{rank:"1",rewards:"001|30,002|30,diamond|30"},
				{rank:"2", rewards:"001|30,diamond|30" },
				{rank:"3", rewards:"001|20,diamond|30" },
				{rank:"4-10", rewards:"001|10,diamond|30" },
				{rank:"11-30", rewards:"diamond|30" },
				{rank:"31-100", rewards:"diamond|30" },
				{rank:"101-999", rewards:"diamond|30" }];*/
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case this.view.closeBtn:
					onClose();
					break;
				default:
					break;
				
			}
		}
		
		override public function show(...args):void{
			super.show();
			
			var rewardArr:Array = GameConfigManager.intance.getGuildBossInfo(args[0]).ranking_reward.split(",");
			var len:int = rewardArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				_rewardInfo[i] = { };
				_rewardInfo[i]['rewards'] = rewardArr[i].split(":");
			}
			
			view.rewardList.array = _rewardInfo;
			view.rewardList.refresh();
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		override public function createUI():void{
			this._view = new GuildBossRewardsUI();
			this.addChild(_view);	
			
			
			//init scrollbar
			
			
			view.rewardList.itemRender=BossRewardItem;
			view.rewardList.selectEnable = true;
			
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():GuildBossRewardsUI{
			return _view;
		}
		
	}

}