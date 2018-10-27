package game.module.kapai
{
	import MornUI.kapai.RankItemUI;
	
	import game.common.ToolFunc;
	import game.module.bingBook.ItemContainer;
	
	/**
	 *  卡牌排行的子项 
	 * @author mutantbox
	 * 
	 */
	public class KapaiRankItem extends RankItemUI
	{
		public function KapaiRankItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			if(!value) return;
			
			dom_rank.text = value["rank"];
			dom_name.text = value["name"];
			dom_score.text = value["score"];
			
			var reward:String = value["reward"];
			var scaleNum:Number = 0.6;
			
			if(reward){
				dom_HBox.destroyChildren();
				ToolFunc.rewardsDataHandler(reward, function(id, num) {
					// 添加小icon
					var child:ItemContainer = new ItemContainer();
					child.scale(scaleNum, scaleNum);
					child.setData(id, num);
					dom_HBox.addChild(child);
				});
			}
			
			super.dataSource = value;
		}
	}
}