package game.module.train
{
	import MornUI.train.TrainingItemUI;
	
	import game.global.util.UnitPicUtil;
	
	import laya.display.Sprite;
	import laya.ui.Box;
	
	/**
	 * TrainingItem
	 * author:huhaiming
	 * TrainingItem.as 2017-3-17 下午3:53:21
	 * version 1.0
	 *
	 */
	public class TrainingItem extends Box
	{
		private var _ui:TrainingItemUI;
		private var _data:Object;
		public function TrainingItem(ui:TrainingItemUI)
		{
			super();
			this._ui = ui;
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			this._data = value;
			if(this._data){
				if(this._data.make_number > 0){
					_ui.numTF.text = this._data.make_number+"";
				}
				this._ui.icon.graphics.clear();
				this._ui.icon.loadImage(UnitPicUtil.getUintPic(_data.unitId || _data.unit_id,UnitPicUtil.ICON));
			}else{
				_ui.numTF.text = ""
			}
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function init():void{
			if(!_ui){
				_ui = new TrainingItemUI();
				this.addChild(_ui);
			}
		}
		
		override public function get width():Number{
			return 70;
		}
		
		override public function get height():Number{
			return 86;
		}
	}
}