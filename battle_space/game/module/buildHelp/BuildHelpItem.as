package game.module.buildHelp 
{
	import game.common.base.BaseView;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.vo.BuildingLevelVo;
	import laya.events.Event;
	import laya.ui.Box;
	import MornUI.buildHelp.BuildHelpItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BuildHelpItem extends Box 
	{
		private var itemMC:BuildHelpItemUI;
		
		private var helpData:Object = { };
		
		public function BuildHelpItem() 
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new BuildHelpItemUI();
			this.addChild(itemMC);
			
			itemMC.goHelpBtn.on(Event.CLICK, this, this.btnEventHandle);
		}
		
		private function btnEventHandle():void 
		{
			
			
			Signal.intance.event(BuildHelpView.HELP_BUILD, [helpData.bid]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(!value)
			{
				return;
			}
			//trace("helpData:", value);
			helpData = value;
			var buInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(value.build_base_id.split("_")[0], 1);
			//trace("buInfo:", DBBuilding.getBuildingById(buInfo.building_id).name);
			itemMC.pNameTxt.text = GameLanguage.getLangByKey("L_A_84206").replace("{0}", value.user_name);// +"需要帮助";
			itemMC.buildInfo.innerHTML = "<div style='width:350px;font-size:24px;color:#b1d9fe'>" + GameLanguage.getLangByKey(DBBuilding.getBuildingById(buInfo.building_id).name)+"<span style='color:#ffffff;font-weight:bold'>&nbsp;(" + value.number + "/" + value.max_number + ")</span>" + "</div>";
			//itemMC.buildInfo.innerHTML = DBBuilding.getBuildingById(buInfo.building_id).name;
			
		}
		
		private function get view():BuildHelpItemUI{
			return itemMC;
		}
		
		
	}

}