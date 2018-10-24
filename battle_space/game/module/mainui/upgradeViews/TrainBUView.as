package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B12UI;
	
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;

	/**
	 * TrainBUView
	 * author:huhaiming
	 * TrainBUView.as 2017-4-18 下午5:42:49
	 * version 1.0
	 *
	 */
	public class TrainBUView extends BaseBUpView
	{
		public function TrainBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			
			var nextVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			var del:Number = parseInt(nextVo.buldng_capacty) - parseInt(_lvData.buldng_capacty);
			this.view.vTF_0.innerHTML = _lvData.buldng_capacty+"\t<font color='#79ff8f'>+"+del+"</font>";
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			BaseBUpView.formatPro(view.bar_0,_lvData.buldng_capacty, nextVo.buldng_capacty, maxVo.buldng_capacty)
				
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