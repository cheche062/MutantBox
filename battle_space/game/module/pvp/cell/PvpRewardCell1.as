package game.module.pvp.cell
{
	import MornUI.pvpFight.PvpRewardCell1UI;
	
	import game.common.RewardList;
	import game.global.data.bag.ItemCell;
	import game.global.vo.PvpRewardVo;
	import game.module.pvp.PvpManager;
	
	import laya.events.Event;
	import laya.ui.UIUtils;
	
	public class PvpRewardCell1 extends PvpRewardCell1UI
	{
		private var _rList:RewardList;
		private var _data:PvpRewardVo;
		
		public function PvpRewardCell1()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			this.rBox.addChild(_rList);
			
			this.rBtn.on(Event.CLICK,this,rBtnClick);
		}
		
		override public function set dataSource(value:*):void{
			super.dataSource = _data = value;
			if(_data)
			{
				this.timerNum.text = _data.num;
				_rList.array = _data.showReward;
				_rList.pos(this.rBox.width - _rList.width >> 1,this.rBox.height - _rList.height >> 1);
				this.filters = _data.state == 3 ? [UIUtils.grayFilter] : null;
				this.overLbl.visible = _data.state == 3;
				this.rBtn.visible = _data.state != 3;
				this.rBtn.disabled = _data.state != 1;
			}
		}
		
		private function rBtnClick(e:Event):void
		{
			if(_data)
			{
				PvpManager.intance.getReward(_data.num);
			}
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			_data = null;
			_rList = null;
			this.rBtn.off(Event.CLICK,this,rBtnClick);
			super.destroy(destroyChild);
		}
		
	}
}