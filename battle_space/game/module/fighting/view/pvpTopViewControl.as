package game.module.fighting.view
{
	import MornUI.fightingViewPvp.pvpTopViewUI;
	
	import game.common.CountdownLabel;
	import game.common.ResourceManager;
	import game.global.consts.ServiceConst;
	import game.module.pvp.PvpManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Handler;
	
	public class pvpTopViewControl extends pvpTopViewUI
	{
		private var _timerText:CountdownLabel;
		public function pvpTopViewControl()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_timerText = new CountdownLabel(this.timerLbl);
			_timerText.formatFun = formatTimer;
			djsTest.text = "";
			
		}
		
		private function formatTimer(n:Number):void
		{
			PvpManager.curTime = 30 - Math.ceil(n / 1000);
			return String(Math.ceil(n / 1000))
		}
		
		public function stop():void
		{
			_timerText.stop();
			timer.clear(this,sendServer);
		}
		
		public function start():void
		{
			var csTm:Number = 30;
			var _json:* = ResourceManager.instance.getResByURL("config/pvp_param.json");
			if(_json)
			{
				csTm = Number(_json[2].value);
			}
			var n:Number = Math.floor(3000+(6000-3000+1)*Math.random());
			_timerText.timerValue = csTm * 1000;
			djsTest.text = "";
			var djs:Number = (csTm  * 1000) + n;
			timer.clear(this,sendServer);
			timer.once(djs,this,sendServer);
			trace(1,"倒计时：",djs);
		}
		
		private function sendServer():void{
			WebSocketNetService.instance.sendData(ServiceConst.PVP_ALLF,[]);
		}
		
		public function start2(n:Number ,hander:Handler):void
		{
			djsTest.text = n == 0 ?"start":n;
			
			if(n == 0) {
				if(hander)
					hander.run();	
				return ;
			}
			timer.once(1000,this,start2,[n - 1,hander]);
		}
		
		public function addEvent():void
		{
		}
		
		public function removeEvent():void
		{
			timer.clearAll(this);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			
			_timerText.destroy();
			_timerText = null;
			super.destroy(destroyChild);
		}
	}
}