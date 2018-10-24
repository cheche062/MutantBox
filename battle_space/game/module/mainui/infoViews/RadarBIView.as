package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B18UI;
	
	import game.module.mainui.upgradeViews.BaseBUpView;
	import game.module.mainui.upgradeViews.RadarBUView;
	
	/**
	 * RadarBIView
	 * author:huhaiming
	 * RadarBIView.as 2017-5-12 下午1:42:57
	 * version 1.0
	 *
	 */
	public class RadarBIView extends BaseBUpView
	{
		public function RadarBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			
			this.view.infoTF.text = _buildVo.dec+"";
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B18UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B18UI{
			return this._view as BuildingUpgrade_B18UI;
		}
	}
}