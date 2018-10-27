package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B18UI;

	/**
	 * RadarBUView
	 * author:huhaiming
	 * RadarBUView.as 2017-5-12 下午12:13:04
	 * version 1.0
	 *
	 */
	public class RadarBUView extends BaseBUpView
	{
		public static const lanDic:Object = 
			{
				1:"L_A_42011",2:"L_A_42012",3:"L_A_42013",
				4:"L_A_42014",5:"L_A_42015",6:"L_A_42016"
			}
		public function RadarBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
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