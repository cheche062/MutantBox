package game.module.mainui.upgradeViews
{
	import game.common.XFacade;
	import game.global.data.DBBuilding;
	import game.module.mainScene.ArticleData;

	/**
	 * UpViewFactory 建筑升级工厂
	 * author:huhaiming
	 * UpViewFactory.as 2017-4-18 上午10:04:06
	 * version 1.0
	 *
	 */
	public class UpViewFactory
	{
		public function UpViewFactory()
		{
		}
		
		public static function showLvUp(data:ArticleData):void{
			var id:String = data.buildId.replace("B","");
			switch(id){
				case DBBuilding.B_BASE:
					XFacade.instance.showModule(MainBUpView,data);
					break;
				case DBBuilding.B_PROTECT:
					XFacade.instance.showModule(ProtectBUview,data);
					break;
				case DBBuilding.B_BOX:
					XFacade.instance.showModule(BoxBUView,data);
					break;
				case DBBuilding.B_TRAIN:
					XFacade.instance.showModule(TrainBUView,data);
					break;
				case DBBuilding.B_CAMP:
					XFacade.instance.showModule(CampBUView,data);
					break;
				case DBBuilding.B_TRANSPORT:
					XFacade.instance.showModule(RadarBUView,data);
					break;
				default:
					var vo:Object = DBBuilding.getBuildingById(data.buildId);
					if(vo.building_type == DBBuilding.TYPE_FARM){
						XFacade.instance.showModule(FarmBUView,data);
					}else if(vo.building_type == DBBuilding.TYPE_DEFEND){
						XFacade.instance.showModule(DefendBUView,data);
					}
					break;
			}
		}
	}
}