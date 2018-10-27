package game.module.invasion
{
	import MornUI.invasion.InvasionItemUI;
	
	import game.global.data.DBItem;
	import game.global.util.ItemUtil;

	/**
	 * HarvestItem
	 * author:huhaiming
	 * HarvestItem.as 2017-4-27 下午2:22:04
	 * version 1.0
	 *
	 */
	public class InvasionItem extends InvasionItemUI
	{
		private var _selected:Boolean = false;
		public function InvasionItem()
		{
			
		}
		
		public function showDB(num:Number, itemStr:String):void{
			if(num>0){
				ItemUtil.formatIcon(icon, itemStr);
				this.visible = true;
				this.numTF.text = num+"";
			}
		}
		
		override public function set selected(v:Boolean):void{
			this._selected = v;
			if(_selected){
				this.bg.skin = "invasion/bg2.png"
			}else{
				this.bg.skin = "invasion/bg2_1.png"
			}
		}
		
		override public function get selected():Boolean{
			return this._selected;
		}
	}
}