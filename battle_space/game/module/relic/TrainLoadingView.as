package game.module.relic
{
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.relic.TransportBaseInfo;
	import game.net.socket.WebSocketNetService;
	
	public class TrainLoadingView extends BaseDialog
	{
		private var m_state:int;
		
		
		public function TrainLoadingView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_state=0;
			if(args!=null)
			{
				m_state=args[0];
			}
			initUI();
		}
		
		private function initUI():void
		{
			trace("ServiceConst.TRAN_GETTRANSPORTTYPE");
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETTRANSPORTTYPE,[]);
		}
		
		override public function addEvent():void{
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE),this,onResult,[ServiceConst.TRAN_GETTRANSPORTTYPE]);
			
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.TRAN_GETTRANSPORTTYPE:
					var l_info:Object=args[1];
					var l_data:TransportBaseInfo=new TransportBaseInfo();
					l_data.status=l_info.status;
					l_data.endTime=l_info.endTime;
					l_data.state=m_state;
					XFacade.instance.openModule("EscortMainView",l_data);
					close();
					break;
				default:
				{
					break;
				}
			}
		}
		
		override public function removeEvent():void{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE),this,onResult);
		}
		
		
	}
}