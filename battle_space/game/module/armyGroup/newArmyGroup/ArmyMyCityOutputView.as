package game.module.armyGroup.newArmyGroup
{
	import MornUI.armyGroup.newArmyGroup.ArmyMyCityOutputViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.module.armyGroup.ArmyGroupMapView;
	
	import laya.events.Event;
	
	/**
	 * 军团产出（新的） 
	 * @author hejianbo
	 * 
	 */
	public class ArmyMyCityOutputView extends BaseDialog
	{
		public function ArmyMyCityOutputView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void {
			this.addChild(view);
			view.dom_list.itemRender = OutputItem;
			view.dom_list.array = null;
		}
		
		override public function show(... args):void {
			super.show();
			AnimationUtil.flowIn(this);
			
			sendData(ServiceConst.ARMY_GROUP_OUTPUT_INFO);
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.btn_close:
					close();
					break;
				
			}
		}
		
		private function onServerResult(... args):void {
			var cmd = args[0];
			var server_data = args[1];
			trace('%c 军团产出：：', 'color: green', cmd, server_data);
			switch (cmd) {
				case ServiceConst.ARMY_GROUP_OUTPUT_INFO:
					var result:Array = [];
					var _this = this;
					var callBack = function(id) {
						trace("跳城市", id)
						Signal.intance.event(ArmyGroupEvent.JUMP_PLANT, [id]);
						_this.close();
					}
					for (var key in server_data) {
						var data:StarVo = ArmyGroupMapView.open_planet_data[key];
						data.protection_time = server_data[key]["protection_time"];
						result.push({
							"city_id": key,
							"name": data.name,
							"state": data.getCityState(),
							"rewards": data.award,
							"access_time": data.access_time,
							"callBack": callBack
						});					
					}
					
					view.dom_list.array = result;
					
					break;
			}
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_OUTPUT_INFO), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_OUTPUT_INFO), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.removeEvent();
		}
		
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
			
			view.dom_list.array = null;
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view(): ArmyMyCityOutputViewUI{
			_view = _view || new ArmyMyCityOutputViewUI();
			return _view;
		}
	}
}