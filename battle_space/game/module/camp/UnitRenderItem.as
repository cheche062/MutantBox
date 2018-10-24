package game.module.camp
{
	import MornUI.camp.UnitRenderItemUI;
	
	import game.global.GameLanguage;
	
	/**
	 * UnitRenderItem
	 * author:huhaiming
	 * UnitRenderItem.as 2017-7-3 上午11:25:04
	 * version 1.0
	 *
	 */
	public class UnitRenderItem extends UnitRenderItemUI
	{
		public var data:Object;
		public function UnitRenderItem()
		{
			super();
			this.mouseEnabled = true;
		}
		
		override public function set dataSource(value:*):void{
			this.data = value;
			if(value){
				this.desTF.text = GameLanguage.getLangByKey(value.des);
			}
		}
	}
}