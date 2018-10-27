package game.module.bossFight
{
	import MornUI.bossFight.BossFightBossDropCellUI;
	import MornUI.bossFight.RankInfoCellUI;
	
	import game.common.RewardList;
	import game.global.vo.worldBoss.BossLevelVo;
	import game.global.vo.worldBoss.BossRankPlayerInfoVo;
	import game.module.bag.cell.RewardCellMin;
	
	import laya.ui.Box;
	
	public class BossFightBossDropCell extends Box
	{
		private var m_ui:BossFightBossDropCellUI;
		private var m_data:BossLevelVo;
		private var _rList:RewardList;
		private var _rList1:RewardList;
		public function BossFightBossDropCell()
		{
			super();
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			initUI();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			if(m_data!=null)
			{
				this.m_ui.RankText.text= m_data.id;
				var l_arr:Array=m_data.getLocalRewardArr();
				_rList.array = l_arr;
				_rList.x  = Box(_rList.parent).width - _rList.width >> 1;
				
				var l_arr1:Array=m_data.getRandomBossRewardArr()
				_rList1.array = l_arr1;
				_rList1.x  = Box(_rList1.parent).width - _rList1.width >> 1;
			}
		}		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new BossFightBossDropCellUI();
				this.addChild(m_ui);
				
				_rList = new RewardList();
				_rList.itemRender = RewardCellMin;
				_rList.itemWidth = RewardCellMin.itemWidth;
				_rList.itemHeight = RewardCellMin.itemHeight;
				_rList.spaceX=-10;
				m_ui.LocalRewardBox.addChild(_rList);
				
				_rList1 = new RewardList();
				_rList1.itemRender = RewardCellMin;
				_rList1.itemWidth = RewardCellMin.itemWidth;
				_rList1.itemHeight = RewardCellMin.itemHeight;
				_rList1.spaceX=-10;
				m_ui.RandomRewardBox.addChild(_rList1);
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BossFightBossDropCell");
			m_ui = null;
			m_data = null;
			_rList = null;
			_rList1 = null;
			
			super.destroy(destroyChild);
		} 
		
	}
}