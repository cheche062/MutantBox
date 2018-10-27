package game.module.gene
{
	import game.common.ResourceManager;
	import game.global.data.bag.ItemCell;
	
	import laya.display.Sprite;
	import laya.net.Loader;
	import laya.ui.Image;
	
	/**
	 * GeneItemCell
	 * author:huhaiming
	 * GeneItemCell.as 2017-3-29 下午12:02:03
	 * version 1.0
	 *
	 */
	public class GeneItemCell extends ItemCell
	{
		private var _selectedFlag:Image;
		private var _clicked:Boolean = false;
		public function GeneItemCell()
		{
			super();
			this.showTip = false;
		}
		
		public function set clicked(value:Boolean):void{
			_clicked = value;
			if(value && this.data){
				selectEff.visible = value;
				this.addChild(selectedFlag);
			}else
			{
				if(_selectEff)
					selectEff.visible = value;
				if(_selectedFlag){
					_selectedFlag.removeSelf();
				}
			}
		}
		public function get clicked():Boolean{
			return this._clicked;
		}
		
		public override function set selected(value:Boolean):void{
			//super.selected = value;
		}
		
		private function get selectedFlag():Sprite{
			if(!_selectedFlag){
				_selectedFlag = new Image();
				_selectedFlag.skin = "common/selected.png"
				_selectedFlag.pos(36,36);
			}
			return _selectedFlag;
		}
	}
}