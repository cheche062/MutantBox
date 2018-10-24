package game.module.mainui
{
	import MornUI.homeScenceView.BuildingInfoUI;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	
	/**
	 * BuildingInfoView 建筑信息
	 * author:huhaiming
	 * BuildingInfoView.as 2017-3-16 下午7:26:49
	 * version 1.0
	 *
	 */
	public class BuildingInfoView extends BaseBUpView
	{
		public function BuildingInfoView()
		{
			super();
		}
		override protected function format():void{
			super.format();
			this.view.infoTF.text = _buildVo.dec+"";
			view.upBox.visible = false;
		}
		
		override public function createUI():void{
			this._view = new BuildingInfoUI();
			this.addChild(_view);
			view.upBox.visible = false;
			
		}
		
		private function get view():BuildingInfoUI{
			return this._view as BuildingInfoUI;
		}
	}
}