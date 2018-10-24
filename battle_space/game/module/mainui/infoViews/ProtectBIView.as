package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B14UI;
	
	import game.common.XUtils;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	/**
	 * ProtectBIView
	 * author:huhaiming
	 * ProtectBIView.as 2017-4-19 上午10:47:04
	 * version 1.0
	 *
	 */
	public class ProtectBIView extends BaseBUpView
	{
		public function ProtectBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			
			var tmp:Array = _lvData.buldng_capacty.split("|")
			trace("_lvData--------->>",_lvData)
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			this.view.vTF_0.innerHTML = XUtils.toFixed(parseFloat(_lvData.param1)*100)+"%";
			BaseBUpView.formatPro(view.bar_0,_lvData.param1,null,maxVo.param1);
			
			var maxArr:Array = maxVo.buldng_capacty.split("|");
			this.view.vTF_1.innerHTML = tmp[0]+""
			BaseBUpView.formatPro(view.bar_1,tmp[0], null, maxArr[0]);
			
			this.view.vTF_2.innerHTML = tmp[1]+"";
			BaseBUpView.formatPro(view.bar_2,tmp[1], null, maxArr[1]);
			
			
			
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B14UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B14UI{
			return this._view as BuildingUpgrade_B14UI;
		}
	}
}