package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_B10UI;
	
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.data.DBBuildingUpgrade;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	
	import laya.events.Event;

	/**
	 * CampBUView
	 * author:huhaiming
	 * CampBUView.as 2017-4-18 下午5:40:02
	 * version 1.0
	 *
	 */
	public class CampBUView extends BaseBUpView
	{
		public function CampBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			var unitList:Array = DBBuildingUpgrade.getNewUnit(this._data.level);
			if(unitList.length == 0){
				this.view.newLabel.visible = false;
				this.view.item_0.visible = false;
				this.view.item_1.visible = false;
				this.view.icon.x = 170;
			}else{
				this.view.icon.x = 10;
				this.view.newLabel.visible = true;
				for(var i:int=0; i<2; i++){
					if(unitList[i]){
						var vo:FightUnitVo = GameConfigManager.unit_dic[unitList[i]];
						if(vo){
							this.view["item_"+i].icon.skin = UnitPicUtil.getUintPic(unitList[i], UnitPicUtil.ICON_SKEW)
						}
						this.view["item_"+i].visible = true;
					}else{
						this.view["item_"+i].icon.skin = "";
						this.view["item_"+i].visible = false;
					}
					this.view["item_"+i].name = unitList[i];
				}
			}
		}
		
		override protected function onClick(e:Event):void{
			super.onClick(e);
			if(XUtils.checkHit(this.view.item_0) && this.view.item_0.name){
				XFacade.instance.openModule("UnitInfoView", [{unitId:this.view.item_0.name}]);
			}else if(XUtils.checkHit(this.view.item_1) && this.view.item_1.name){
				XFacade.instance.openModule("UnitInfoView", [{unitId:this.view.item_1.name}]);
			}
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B10UI();
			this.addChild(_view);
			
			this.view.item_0.numTF.visible = false;
			this.view.item_0.minusBtn.visible = false;
			this.view.item_0.numTF2.visible = false;
			
			this.view.item_1.numTF.visible = false;
			this.view.item_1.minusBtn.visible = false;
			this.view.item_1.numTF2.visible = false;
		}
		
		private function get view():BuildingUpgrade_B10UI{
			return this._view as BuildingUpgrade_B10UI;
		}
	}
}