package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B11UI;
	import MornUI.homeScenceView.BuildingUpgrade_B14UI;
	
	import game.module.mainui.infoViews.BoxBIView;

	/**
	 * BoxBUView
	 * author:huhaiming
	 * BoxBUView.as 2017-4-18 下午5:37:33
	 * version 1.0
	 *
	 */
	public class BoxBUView extends BaseBUpView
	{
		public function BoxBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();/*
			var arr:Array = BoxBIView.WORDS[_data.level];
			if(arr){
				view.nTF_0.text = arr[0];
				view.aTF_0.text = arr[1];
			}
			arr = BoxBIView.WORDS[_data.level+1];
			if(arr){
				view.nTF_1.text = arr[0];
				view.aTF_1.text = arr[1];
			}*/
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B11UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B11UI{
			return this._view as BuildingUpgrade_B11UI;
		}
	}
}