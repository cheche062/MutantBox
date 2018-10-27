package game.module.pvp.cell
{
	import MornUI.pvpFight.PvpRewardCell2UI;
	
	import game.common.RewardList;
	import game.global.data.bag.ItemCell;
	import game.global.vo.PvpLevelVo;
	import game.global.vo.PvpRewardVo;
	import game.module.pvp.PvpManager;
	
	import laya.ui.UIUtils;
	
	public class PvpRewardCell2 extends PvpRewardCell2UI
	{
		private var _rList:RewardList;
		private var _data:PvpLevelVo;
		
		public function PvpRewardCell2()
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
		}
		
		
		
		override public function set dataSource(value:*):void{
			super.dataSource = _data = value;
			if(_data)
			{
				var myVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
					Number(PvpManager.intance.userInfo.integral)
				);
				
				this.bgImg.skin = myVo == _data ?"pvpReward/bg14_1.png": "pvpReward/bg14.png";
				this.sNumLbl.color = myVo == _data ?"#83ff9d":"#85c0ed";
				
				this.sNumLbl.text =PvpManager.intance.userInfo.integral +"/"+ _data.down ;
				_rList.array = _data.rewardList;
				_rList.pos(this.rBox.width - _rList.width >> 1,this.rBox.height - _rList.height >> 1);
				this.rankFace.skin = _data.rankIcon;
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void
		{
			_data = null;
			_rList = null;
			super.destroy(destroyChild);
		}
	}
}