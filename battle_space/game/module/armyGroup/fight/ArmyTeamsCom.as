package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.FightTeamsViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ArmyTeamsCom
	 * author:huhaiming
	 * ArmyTeamsCom.as 2017-11-27 下午5:53:15
	 * version 1.0
	 *
	 */
	public class ArmyTeamsCom extends BaseDialog
	{
		public function ArmyTeamsCom()
		{
			super();
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.flowIn(this);
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_TEAM),this, onGetTeam);
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_FIGHT_TEAM,[]);
		}
		
		private function onGetTeam(...args):void{
			view.list1.array = args[1];
			view.list2.array = args[2];
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			_view = new FightTeamsViewUI();
			this.addChild(_view);
			
			view.list1.itemRender = view.list2.itemRender =ArmyTeamsItem;
			view.list1.vScrollBarSkin = view.list2.vScrollBarSkin = "";
			view.list1.array = view.list2.array = [];
			this.closeOnBlank = true;
		}
		
		public function get view():FightTeamsViewUI{
			return this._view as FightTeamsViewUI
		}
	}
}