package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B12UI;
	
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * TrainBIView
	 * author:huhaiming
	 * TrainBIView.as 2017-4-19 上午10:49:11
	 * version 1.0
	 *
	 */
	public class TrainBIView extends BaseBUpView
	{
		public function TrainBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			this.view.vTF_0.innerHTML = _lvData.buldng_capacty+"";
			
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			BaseBUpView.formatPro(view.bar_0,_lvData.buldng_capacty, null, maxVo.buldng_capacty)
				
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B12UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B12UI{
			return this._view as BuildingUpgrade_B12UI;
		}
	}
}