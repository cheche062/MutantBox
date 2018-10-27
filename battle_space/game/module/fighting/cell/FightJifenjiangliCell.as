package game.module.fighting.cell
{
	import MornUI.fightingChapter.FightJifenjiangliCellUI;
	
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.event.Signal;
	import game.global.vo.StageChapterRewardVo;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.mgr.FightingStageManger;
	import game.module.fighting.sData.stageChapetrData;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class FightJifenjiangliCell extends FightJifenjiangliCellUI
	{
		public static const itemWidth:Number = 198;
		public static const itemHeight:Number = 282;
		
		public function FightJifenjiangliCell()
		{
			super();
		}
		
		private var _rList:RewardList;
		private var vo:StageChapterRewardVo;
		override public function createChildren():void
		{
			super.createChildren();
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			rBox.addChild(_rList);
			
			
			rBtn.on(Event.CLICK,this,thisClick);
		}
		
		private function thisClick(e:Event):void
		{
			if(!vo)return ;
			var sconst:Number  = vo.isJY ? ServiceConst.FIGHTING_MAP_GET_REWARD_JY : ServiceConst.FIGHTING_MAP_GET_REWARD;
			WebSocketNetService.instance.sendData(sconst,[vo.cid,vo.index]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(sconst),
				this,getRewardBack);
			
			e.stopPropagation();
		}
		
		
		protected function getRewardBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getRewardBack);
			
			var s:String = args[1];
			var arr:Array = ItemManager.StringToReward(s);
			XFacade.instance.openModule(ModuleName.ShowRewardPanel,[arr]);
		}
		
		
		public override function set dataSource(value:*):void{
			super.dataSource =  value;
			if(value)
			{
				vo = value;
				this._rList.array = vo.chapterReward;
				this._rList.x = this.rBox.width - this._rList.width >> 1;
				this._rList.y = this.rBox.height - this._rList.height >> 1;
				
				starNum.text = "X "+ vo.point_condition;
				
				var scData:stageChapetrData = FightingStageManger.intance.getChapetrData(vo.cid,vo.isJY);
				var state:Number = 0;
				var rewardGetState:Array = scData.rewardGetState;
				var idx:Number = vo.index - 1;
				if(rewardGetState.length > idx)
					state = rewardGetState[idx];
				rBtn.visible = state != 2;
				rBtn.disabled = starBox.disabled = state == 0;
				rLbl.visible = state == 2;
				
				
				
				if(!rBtn.disabled)
					rBtn["clickSound"] = ResourceManager.getSoundUrl('ui_collect_resource','uiSound');
				else
					rBtn["clickSound"] = null;
				UIRegisteredMgr.AddUI(rBtn,"FightRewardCell_rBtn"+vo.index);
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("FightRewardCell_rBtn"+1);
			UIRegisteredMgr.DelUi("FightRewardCell_rBtn"+2);
			UIRegisteredMgr.DelUi("FightRewardCell_rBtn"+3);
			_rList = null;
			vo = null;
			rBtn.off(Event.CLICK,this,thisClick);
			super.destroy(destroyChild);
			
		}
		
	}
}