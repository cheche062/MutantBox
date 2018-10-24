package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B14UI;
	
	import game.common.XUtils;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	
	import laya.ani.bone.Templet;

	/**
	 * ProtectBUview 基地互动
	 * author:huhaiming
	 * ProtectBUview.as 2017-4-18 下午4:33:41
	 * version 1.0
	 *
	 */
	public class ProtectBUview extends BaseBUpView
	{
		public function ProtectBUview()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			var tmp:Array = _lvData.buldng_capacty.split("|")
				trace("_lvData--------->>",_lvData)
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			var nextVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			var delNum:Number = Math.round((parseFloat(nextVo.param1) - parseFloat(_lvData.param1))*100);
			this.view.vTF_0.innerHTML = XUtils.toFixed(parseFloat(_lvData.param1)*100)+"%\t<font color='#79ff8f'>+"+delNum+"</font>";
			BaseBUpView.formatPro(view.bar_0,_lvData.param1,nextVo.param1,maxVo.param1);
			
			var temArr:Array = nextVo.buldng_capacty.split("|");
			var maxArr:Array = maxVo.buldng_capacty.split("|");
			delNum = parseFloat(temArr[0]) - parseFloat(tmp[0])
			this.view.vTF_1.innerHTML = tmp[0]+"\t<font color='#79ff8f'>+"+delNum+"</font>"
			BaseBUpView.formatPro(view.bar_1,tmp[0], temArr[0], maxArr[0]);
			
			delNum = parseFloat(temArr[1]) - parseFloat(tmp[1])
			this.view.vTF_2.innerHTML = tmp[1]+"\t<font color='#79ff8f'>+"+delNum+"</font>";
			BaseBUpView.formatPro(view.bar_2,tmp[1], temArr[1], maxArr[1]);
			
			
			
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