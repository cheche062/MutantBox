package game.module.fortress
{
	import MornUI.fortress.rankItemUI;
	
	import game.module.bingBook.ItemContainer;
	
	import laya.ui.View;
	
	public class RankItemView extends rankItemUI
	{
		public function RankItemView()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			if(!value) return;
			
			var _this:rankItemUI = this;
			var dom_HBox_data:String = value["dom_HBox_data"];
			var scaleNum:Number = 0.6;
			var baseWidth:Number;
			
			if(dom_HBox_data){
				_this.dom_HBox.destroyChildren();
				var dataArr:Array = dom_HBox_data.split(";");
				dataArr.forEach(function(item:String, index:int):void{
					var arr:Array = item.split("=");
					// 添加小icon
					var child:ItemContainer = new ItemContainer();
					child.scale(scaleNum, scaleNum);
					child.setData(arr[0], arr[1]);
					
					_this.dom_HBox.addChild(child);
					
					baseWidth = child.width;
				})
			}
			
			// 调整奖励icon位置
			dom_HBox.x = (550 - dom_HBox.numChildren * (scaleNum * baseWidth + dom_HBox.space));
			
			super.dataSource = value;
//			trace("dataSource:", value)
		}
	}
}