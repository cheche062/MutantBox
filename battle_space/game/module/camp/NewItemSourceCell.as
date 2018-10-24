package game.module.camp
{
	import MornUI.camp.UnitRenderItem2UI;
	
	import game.module.bag.cell.BaseItemSourceCell;
	
	import laya.ui.UIUtils;
	
	public class NewItemSourceCell extends BaseItemSourceCell
	{
		private var mUi:UnitRenderItem2UI;
		public function NewItemSourceCell()
		{
			super();
		}
		
		protected override function init():void
		{
			mUi = new UnitRenderItem2UI();
			addChild(mUi);
			_bg = mUi._bg;
			_text = mUi._text;
			size(mUi.width,mUi.height);
		}
		
		
		protected override function bindData():void{
			super.bindData();
			if(_data)
			{
				this.filters = !_data.state ? [UIUtils.grayFilter] : null;
				mUi.lock.visible = !_data.state;
				
				_bg.visible = true;
				// 不做跳转时背景隐藏
				if (_data.type == 100) {
					_bg.visible = false;
					
				}
			}
		}
		
	}
}