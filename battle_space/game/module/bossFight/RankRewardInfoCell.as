package game.module.bossFight
{
	import MornUI.bossFight.RankRewardInfoCellUI;
	import MornUI.bossFight.RankingRewardViewUI;
	import MornUI.train.TrainingItemUI;
	
	import game.common.RewardList;
	import game.global.vo.worldBoss.BossRankVo;
	import game.global.vo.worldBoss.RewardVo;
	import game.module.bag.cell.RewardCellMin;
	
	import laya.display.Text;
	import laya.ui.Box;
	
	public class RankRewardInfoCell extends Box
	{
		private var m_ui:RankRewardInfoCellUI;
		private var m_data:BossRankVo;
		private var _rList:RewardList;
		public function RankRewardInfoCell(p_ui:RankRewardInfoCellUI)
		{
			super();
			this.m_ui = p_ui;
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			initUI();
		}
		
		/**
		 * 初始化 
		 */
		private function initUI():void
		{
			if(m_data!=null)
			{
				this.m_ui.RankText.text= m_data.rankTile();
				var l_arr:Array=m_data.getRewardList();
//				for(var i:int=0;i<l_arr.length;i++)
//				{
//					var l_text:Text=this.m_ui.getChildByName("RankText"+i)as Text;
//					var l_vo:RewardVo=l_arr[i];
//					l_text.text=l_vo.num.toString();
//				}
				_rList.array = l_arr;
				_rList.x  = Box(_rList.parent).width - _rList.width >> 1;
			}
		}
		
		public function get data():Object{
			return this.m_data;
		}
		
		/**
		 *  
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new RankRewardInfoCellUI();
				this.addChild(m_ui);
				
				_rList = new RewardList();
				_rList.itemRender = RewardCellMin;
				_rList.itemWidth = RewardCellMin.itemWidth;
				_rList.itemHeight = RewardCellMin.itemHeight;
				m_ui.rewardBox.addChild(_rList);
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy RankRewardInfoCell");
			m_ui = null;
			m_data = null;
			_rList = null;
			super.destroy(destroyChild);
		} 
	}
}