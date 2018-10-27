package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_1UI;
	import MornUI.homeScenceView.BuildingUpgrade_B1UI;
	
	import game.global.GameLanguage;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;

	/**
	 * FarmBUView
	 * author:huhaiming
	 * FarmBUView.as 2017-4-18 下午3:30:12
	 * version 1.0
	 *
	 */
	public class FarmBUView extends BaseBUpView
	{
		public function FarmBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			var nextVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			var delNum:Number;
			var now:Number;
			var next:Number
			var max:Number
			if(_lvData.buldng_output){
				this.view.vTF_1.visible = true;
				this.view.lb_1.visible = true;
				this.view.bar_1.visible = true;
				
				this.view.lb_0.text = GameLanguage.getLangByKey("L_A_26");
					
				now = parseFloat((_lvData.buldng_output+"").split("=")[1])
				next = parseFloat((nextVo.buldng_output+"").split("=")[1])
				max = parseFloat((maxVo.buldng_output+"").split("=")[1])
				delNum = next - now; 
				this.view.vTF_0.innerHTML = Math.round(now)+"/M <font color='#79ff8f'>+"+Math.round(delNum)+"</font>";
				BaseBUpView.formatPro(this.view.bar_0, now, next, max);
				
				now = parseFloat((_lvData.buldng_capacty+"").split("=")[1])
				next = parseFloat((nextVo.buldng_capacty+"").split("=")[1])
				max = parseFloat((maxVo.buldng_capacty+"").split("=")[1])
				delNum = next - now; 
				this.view.vTF_1.innerHTML = (now)+" <font color='#79ff8f'>+"+delNum+"</font>";
				BaseBUpView.formatPro(this.view.bar_1, now, next, max);
				
			}else{
				this.view.vTF_1.visible = false;
				this.view.lb_1.visible = false;
				this.view.bar_1.visible = false;
				
				this.view.lb_0.text = "L_A_72"
					
				now = parseFloat((_lvData.buldng_capacty+"").split("=")[1])
				next = parseFloat((nextVo.buldng_capacty+"").split("=")[1])
				max = parseFloat((maxVo.buldng_capacty+"").split("=")[1])
				delNum = next - now; 
				this.view.vTF_0.innerHTML = now+"\t<font color='#79ff8f'>+"+delNum+"</font>";
				BaseBUpView.formatPro(this.view.bar_0, now, next, max);
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