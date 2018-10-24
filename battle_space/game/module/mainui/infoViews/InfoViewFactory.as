package game.module.mainui.infoViews
{
	import game.common.XFacade;
	import game.global.data.DBBuilding;
	import game.module.mainScene.ArticleData;
	import game.module.mainui.BuildingInfoView;

	/**
	 * InfoViewFactory
	 * author:huhaiming
	 * InfoViewFactory.as 2017-4-19 上午10:37:35
	 * version 1.0
	 *
	 */
	public class InfoViewFactory
	{
		public function InfoViewFactory()
		{
		}
		
		public static function showInfo(data:ArticleData):void{
			var id:String = data.buildId.replace("B","");
			switch(id){
				case DBBuilding.B_BASE:
					XFacade.instance.showModule(MainBIView,data);
					break;
				case DBBuilding.B_PROTECT:
					XFacade.instance.showModule(ProtectBIView,data);
					break;
				case DBBuilding.B_BOX:
					XFacade.instance.showModule(BoxBIView,data);
					break;
				case DBBuilding.B_TRAIN:
					XFacade.instance.showModule(TrainBIView,data);
					break;
				case DBBuilding.B_CAMP:
					XFacade.instance.showModule(CampBIView,data);
					break;
				case DBBuilding.B_RADIO:
					XFacade.instance.showModule(RadarBIView,data);
					break;
				default:
					var vo:Object = DBBuilding.getBuildingById(data.buildId);
					if(vo.building_type == DBBuilding.TYPE_FARM){
						XFacade.instance.showModule(FarmBIView,data);
					}else if(vo.building_type == DBBuilding.TYPE_DEFEND){
						XFacade.instance.showModule(DefendBIView,data);
					}else{
						XFacade.instance.showModule(BuildingInfoView, data);
					}
					break;
			}
		}
	}
}