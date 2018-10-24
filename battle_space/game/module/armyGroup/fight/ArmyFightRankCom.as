package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightRankUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ArmyFightRankCom
	 * author:huhaiming
	 * ArmyFightRankCom.as 2017-11-27 下午6:34:36
	 * version 1.0
	 *
	 */
	public class ArmyFightRankCom extends BaseDialog
	{
		public function ArmyFightRankCom()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
			}
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.flowIn(this);
			
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_RANK),this, onGetLog);
			
//			1：页码固定传， 1：城战个人击杀榜
			sendData(ServiceConst.ARMY_GROUP_GET_RANK, [1, 1]);
			
		}
		
		private function onGetLog(...args): void{
			var dataList: Array = args[1][1];
			view.list.array = dataList;
			view.list.refresh();
			
			view.numTF.text = args[2].killnum;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
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
			_view = new ArmyFightRankUI();
			this.addChild(_view);
			this.closeOnBlank = true;
			
			view.list.itemRender = ArmyFightRankItem;
			view.list.vScrollBarSkin = "";
			view.list.array = [];
		}
		
		private function get view():ArmyFightRankUI{
			return this._view as ArmyFightRankUI;
		}
	}
}