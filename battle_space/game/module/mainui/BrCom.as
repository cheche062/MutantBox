package game.module.mainui
{
	import MornUI.mainView.BRViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBUnit;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.camp.CampData;
	
	import laya.events.Event;
	
	/**
	 * BrCom
	 * author:huhaiming
	 * BrCom.as 2018-1-23 上午11:47:25
	 * version 1.0
	 *
	 */
	public class BrCom extends BaseDialog
	{
		public function BrCom()
		{
			super();
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.flowIn(this);
			
			var kpi:int = 0
			var list:Array = CampData.getUnitList(DBUnit.TYPE_HERO);
			if(list.length){
				list.sort(onSort);
				view.lb_1.text = list[0].power
				kpi = list[0].power;
			}
			
			
			list = CampData.getUnitList(DBUnit.TYPE_SOLDIER);
			if(list.length){
				list.sort(onSort);
				view.lb_0.text = list[0].power
				
			}
			
			var vo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_BASE, User.getInstance().sceneInfo.getBaseLv());
			var capacty:int = vo.buldng_capacty;
			var tmp:Object;
			var index:int = 0;
			for(var i=0; i<list.length; i++){
				if(index < capacty){
					tmp = DBUnit.getUnitInfo(list[i]["unitId"]);
					var num_limit:int = tmp.num_limit;
					for(var j:int=0; j<num_limit; j++){
						kpi += list[i].power;
						index ++;
						if(index >= capacty){
							break;
						}
					}
				}else{
					break;
				}
			}
			view.lb_2.text = kpi+"";
			
			view.lb_3.text = User.getInstance().KPI;	
				
			function onSort(obj1:Object, obj2:Object):int{
				if(obj1.power < obj2.power){
					return 1;
				}
				return -1;
			}
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		override public function createUI():void{
			this._view = new BRViewUI();
			this.addChild(_view);
			this.closeOnBlank = true;
		}
		
		private function get view():BRViewUI{
			return this._view;
		}
	}
}