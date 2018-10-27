package game.module.military
{
	import MornUI.military.MilitaryViewUI;
	import MornUI.military.ShieldItem1UI;
	
	import game.common.DataLoading;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBMilitary;
	import game.global.data.DBShield;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.camp.UnitItem;
	import game.module.invasion.shield.ShieldItem;
	import game.module.invasion.shield.ShieldVo;
	import game.module.mainScene.HomeSceneUtil;
	import game.module.mainui.MainMenuView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;

	/**
	 * BuffCom
	 * author:huhaiming
	 * BuffCom.as 2017-4-28 上午11:25:43
	 * version 1.0
	 *
	 */
	public class DefendCom implements IMilitaryCom
	{
		private var _ui:*;
		private var _view:MilitaryViewUI;
		//
		public static var onShow:Boolean = false;
		public function DefendCom(ui:*, view:MilitaryViewUI)
		{
			this._ui = ui;
			this._view = view;
			init();
		}
		
		private function format(arr:Object):void{
			var tmp:Array = [];
			if(arr){
				for(var i:String in arr){
					tmp.push({id:i,num:arr[i], hs:true})
				}
			}
			this._view.armyList.array = tmp;
		}
		
		private function getData(id:*):ShieldVo{
			var list:Array = DBShield.getShieldList();
			for(var i:String in list){
				if(list[i].id == id){
					return list[i]
				}
			}
			return null;
		}
		
		public function show(...args):void
		{
			this._ui.visible = true;
			_view.armyList.mouseHandler = Handler.create(this, this.onSelectItem,null, false);
			_view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ShieldView.UPDATE, this, this.onUpdate);
			
			format(MilitaryView.data.arm_list)
			
			var lv:int = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT)
			var bVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_PROTECT, lv);
			
			_view.kpiTF.text = MilitaryView.data.power+"";
			var delTime:Number = MilitaryView.data.base_rob_info.shield_last_time*1000 - TimeUtil.now;
			if(delTime > 0){
				_view.timeTF.text = HomeSceneUtil.formatTime(delTime);
			}else{
				_view.timeTF.text = GameLanguage.getLangByKey("L_A_49048");
			}
		}
		
		public function close():void
		{
			_view.armyList.mouseHandler = null;
			_view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ShieldView.UPDATE, this, this.onUpdate);
			this._ui.visible = false;
		}
		
		private function onUpdate():void{
			var delTime:Number = MilitaryView.data.base_rob_info.shield_last_time*1000 - TimeUtil.now;
			if(delTime > 0){
				_view.timeTF.text = HomeSceneUtil.formatTime(delTime);
			}else{
				_view.timeTF.text = GameLanguage.getLangByKey("L_A_49048");
			}
		}
		      
		private function onClick(e:Event):void{
			switch(e.target){
				case _view.deployBtn:
					Signal.intance.event(MilitaryView.CLOSE);
					(XFacade.instance.getView(MainMenuView) as MainMenuView).showDefend();
					break;
				case _view.logBtn2:
					XFacade.instance.openModule("ReplayView");
					break;
				case _view.shieldBtn:
					XFacade.instance.showModule(ShieldView);
					break;
				default:
					if(e.target.name == "infoBtn"){
						var tipStr:String = GameLanguage.getLangByKey("L_A_49020");
						tipStr = tipStr.replace(/##/g,"\n");
						XTipManager.showTip(tipStr);
					}
					break;
			}
		}
		
		private function onSelectItem(e:Event, index:int):void{
			if(e.type == Event.CLICK){
				XFacade.instance.openModule("UnitInfoView", [_view.armyList.getItem(index)]);
			}
		}
		
		private function init():void{
			_view.armyList.itemRender = UnitItem;
			_view.armyList.vScrollBarSkin="";
		}
	}
}