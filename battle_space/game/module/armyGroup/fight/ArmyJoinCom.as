package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightRankUI;
	import MornUI.armyGroupFight.ArmyJoinViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ArmyJoinCom
	 * author:huhaiming
	 * ArmyJoinCom.as 2017-11-28 下午7:00:51
	 * version 1.0
	 *
	 */
	public class ArmyJoinCom extends BaseDialog
	{
		private var _data:Object;
		/**事件-加入阵营*/
		public static const TEAM_CAHNGE:String = "TEAM_CAHNGE";
		/**事件-等待加入*/
		public static const TEAM_WAIT:String = "wait";
		public function ArmyJoinCom()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.attBtn:
					selectRole(1);
					break;
				case view.defBtn:
					selectRole(2);
					break;
				case view.laterBtn:
					this.close();
					Signal.intance.event(TEAM_WAIT);
					break;
			}
		}
		
		private function selectRole(type:int):void{
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SELECT),this, onSelectRole);
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SELECT,[type]);
		}
		
		override public function show(...args):void{
			_data = args[0];
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
		}
		
		private function onSelectRole(...args):void{
			_data.role = args[1];
			Signal.intance.event(TEAM_CAHNGE);
			this.close();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			this._view  =new ArmyJoinViewUI();
			this.addChild(_view);
		}
		
		private function get view():ArmyJoinViewUI{
			return this._view as ArmyJoinViewUI;
		}
	}
}