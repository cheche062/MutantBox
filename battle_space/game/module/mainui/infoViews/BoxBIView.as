package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B11UI;
	
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * BoxBIView
	 * author:huhaiming
	 * BoxBIView.as 2017-4-19 上午10:42:03
	 * version 1.0
	 *
	 */
	public class BoxBIView extends BaseBUpView
	{
		public static const WORDS:Object = 
			{
				1:["L_A_45028", "L_A_45029"],
				2:["L_A_45030", "L_A_45031"],
				3:["L_A_45032", "L_A_45033"]
			}
		public function BoxBIView()
		{
			super();
		}
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			/*
			var arr:Array = WORDS[_data.level];
			if(arr){
				view.nTF_0.text = arr[0];
				view.aTF_0.text = arr[1];
			}*/
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B11UI();
			this.addChild(_view);
			
			/*this.view.arr0.visible = false;
			this.view.arr1.visible = false;
			this.view.nTF_1.visible = false;
			this.view.aTF_1.visible = false;*/
		}
		
		private function get view():BuildingUpgrade_B11UI{
			return this._view as BuildingUpgrade_B11UI;
		}
	}
}