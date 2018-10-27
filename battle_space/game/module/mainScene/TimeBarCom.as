package game.module.mainScene
{
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuildingUpgrade;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.module.camp.CampData;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.ui.ProgressBar;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	/**
	 * TimeBarCom 建筑的时间条关联信息==
	 * author:huhaiming
	 * TimeBarCom.as 2017-3-17 上午9:29:11
	 * version 1.0
	 *
	 */
	public class TimeBarCom extends Sprite
	{
		private var _bar:ProgressBar;
		private var _timeTF:Text;
		private var _time:Number;
		private var _id:*;
		private var _totalTime:Number;
		private var _handler:Handler;
		/**常量-刷新时间*/
		private static const FRESH_TIME:Number = 1000
		public function TimeBarCom()
		{
			super();
			init();
		}
		
		
		public function updateTime(time:Number, totalTime:Number,handler:Handler, bid:*=null):void{
			this._handler = handler
			this._time = time*1000;
			_id = bid;
			//trace("updateTime"+_time+"_"+TimeUtil.now);
			this._totalTime = totalTime;
			this.onUpdate();
			Laya.timer.loop(FRESH_TIME, this, this.onUpdate);
		}
		
		private function onUpdate():void{
			var leftTime:Number = _time - TimeUtil.now;
			_timeTF.text  = TimeUtil.getShortTimeStr(leftTime, " ")+"";
			_bar.value = 1-leftTime/_totalTime;
			//trace("value",leftTime,_totalTime,leftTime/_totalTime);
			if(leftTime<0){
				Laya.timer.clear(this, this.onUpdate);
				if(_handler != null){
					_handler.run();
					//重新获取建筑信息
					WebSocketNetService.instance.sendData(ServiceConst.B_TIMEOVER,[_id]);
				}
			}
		}
		
		public function close():void{
			if(_handler){
				_handler.recover();
				_handler = null;
			}
			this.removeSelf();
			Laya.timer.clear(this, this.onUpdate);
		}
		
		private function init():void{
			_bar = new ProgressBar("mainUi/progress3.png");
			//_bar.pos(0,0);
			this.addChild(_bar);
			
			_timeTF = new Text();
			_timeTF.y = 1
			this.addChild(_timeTF);
			_timeTF.width = 160
			_timeTF.fontSize = 18;
			_timeTF.align = "center"
			_timeTF.font = XFacade.FT_Futura;
			_timeTF.color = "#ffffff"
		}
	}
}