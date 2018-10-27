package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B1UI;
	
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * MainBIView 主界面信息界面，与升级界面UI相同
	 * author:huhaiming
	 * MainBIView.as 2017-4-19 上午10:31:59
	 * version 1.0
	 *
	 */
	public class MainBIView extends BaseBUpView
	{
		public function MainBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.newLabel.visible = false;
			this.view.new_0.skin = "";
			this.view.new_1.skin = "";
			
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.vTF_0.innerHTML = _lvData.buldng_capacty+"";
			
			this.view.infoTF.text = _buildVo.dec+"";
			
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			BaseBUpView.formatPro(view.bar_0,_lvData.buldng_capacty, null, maxVo.buldng_capacty)
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B1UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B1UI{
			return this._view as BuildingUpgrade_B1UI;
		}
	}
}