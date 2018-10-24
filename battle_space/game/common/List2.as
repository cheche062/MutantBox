package game.common
{
	import laya.ui.Box;
	import laya.ui.Clip;
	import laya.ui.List;
	
	public class List2 extends List
	{
		public function List2()
		{
			super();
		}
		
		/**
		 * @private
		 * 改变单元格的可视状态。
		 * @param cell 单元格对象。
		 * @param visable 是否显示。
		 * @param index 单元格的属性 <code>index</code> 值。
		 */
		protected override function changeCellState(cell:Box, visable:Boolean, index:int):void {
			var selectBox:Clip = cell.getChildByName("selectBox") as Clip;
			if (selectBox) {
				selectEnable = true;
				selectBox.visible = visable;
				selectBox.index = index;
			}else{
				if(index == 1)
					cell.selected = visable;
			}
		}
	}
}