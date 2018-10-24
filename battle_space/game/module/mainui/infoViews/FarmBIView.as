package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_1UI;
	
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * FarmIView
	 * author:huhaiming
	 * FarmIView.as 2017-4-19 上午10:45:08
	 * version 1.0
	 *
	 */
	public class FarmBIView extends BaseBUpView
	{
		public function FarmBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			var now:Number;
			var max:Number
			if(_lvData.buldng_output){
				this.view.vTF_1.visible = true;
				this.view.lb_1.visible = true;
				this.view.bar_1.visible = true;
				
				this.view.lb_0.text = "L_A_80"
				
				now = parseFloat((_lvData.buldng_output+"").split("=")[1])
				max = parseFloat((maxVo.buldng_output+"").split("=")[1])
				this.view.vTF_0.innerHTML = Math.round(now)+"/M";
				BaseBUpView.formatPro(this.view.bar_0, now, null, max);
				
				now = parseFloat((_lvData.buldng_capacty+"").split("=")[1])
				max = parseFloat((maxVo.buldng_capacty+"").split("=")[1])
				this.view.vTF_1.innerHTML = now+"";
				BaseBUpView.formatPro(this.view.bar_1, now, null, max);
				
			}else{
				this.view.vTF_1.visible = false;
				this.view.lb_1.visible = false;
				this.view.bar_1.visible = false;
				
				this.view.lb_0.text = "L_A_72"
				
				now = parseFloat((_lvData.buldng_capacty+"").split("=")[1])
				max = parseFloat((maxVo.buldng_capacty+"").split("=")[1])
				this.view.vTF_0.innerHTML = now+"";
				BaseBUpView.formatPro(this.view.bar_0, now, null, max);
			}
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_1UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_1UI{
			return this._view as BuildingUpgrade_1UI;
		}
	}
}