package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B10UI;
	
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * CampBIView
	 * author:huhaiming
	 * CampBIView.as 2017-4-19 上午10:43:17
	 * version 1.0
	 *
	 */
	public class CampBIView extends BaseBUpView
	{
		public function CampBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			//
			this.view.icon.x = 170;
			this.view.newLabel.visible = false;
			this.view.item_0.visible = false;
			this.view.item_1.visible = false
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B10UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B10UI{
			return this._view as BuildingUpgrade_B10UI;
		}
	}
}