package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightReportUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ArmyFightReportCom
	 * author:huhaiming
	 * ArmyFightReportCom.as 2017-11-27 下午7:02:30
	 * version 1.0
	 *
	 */
	public class ArmyFightReportCom extends BaseDialog
	{
		public function ArmyFightReportCom()
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
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_LOG),this, onGetLog);
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_FIGHT_LOG,[]);
		}
		
		private function onGetLog(...args):void{
			//args = [35856,["[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10007=4\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10008=5\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10008=5\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10007=4\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10004=1\"]","[0,1,1,\"L_A_xxxxxx\",\"1=1;2=1;3=1;10008=5\"]"]]
			//[35855,1,26,[0,1,"L_A_xxxxxx","1=1;2=1;3=1;10008=5"]]
			view.list.array = args[1]
			//trace("onGetLog::",args);
		}
		
		private function onGetNotice(...args):void{
			var arr:Array  = view.list.array;
			arr.unshift(args[3]);
			view.list.array = arr;
			view.list.refresh();
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
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_NOTICE),this, onGetNotice);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_FIGHT_NOTICE),this, onGetNotice);
		}
		
		override public function createUI():void{
			_view = new ArmyFightReportUI();
			this.addChild(_view);
			this.closeOnBlank = true;
			
			view.list.itemRender = ArmyFightReportItem;
			view.list.vScrollBarSkin = '';
			view.list.array = [];
		}
		
		private function get view():ArmyFightReportUI{
			return this._view as ArmyFightReportUI;
		}
	}
}