/***
 *作者：罗维
 */
package game.common
{
	import game.global.util.TimeUtil;
	
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	public class CountdownLabel
	{
		public var textLbl:Label;
		public function CountdownLabel(lbl:Label)
		{
			textLbl = lbl;
		}
		
		private var _timerValue:Number = 0;
		private var _overHandel:Handler = null;

		public function get overHandel():Handler
		{
			return _overHandel;
		}

		public function set overHandel(value:Handler):void
		{
			_overHandel = value;
		}

		public function get timerValue():Number
		{
			if(_timerValue > Browser.now())
				return _timerValue - Browser.now();
			return 0;
		}

		public function set timerValue(value:Number):void
		{
			_timerValue = value + Browser.now();
			
			if(timerValue)
				start();
		}
		
		public var formatFun:Function;
		
		public function start():void{
			stop();
			var n:Number = timerValue;
			if(formatFun == null)
				textLbl.text = TimeUtil.getTimeStr(n);
			else
				textLbl.text = formatFun(n);
//			trace(text+"~~~");
			if(!n)
			{
				if(overHandel)overHandel.run();
			}
			textLbl.timer.once(500,this,start);
		}
		
		public function stop():void
		{
			textLbl.timer.clear(this,start);
		}
		
		public function destroy():void{
			stop();
			_timerValue = 0;
			_overHandel = null;
			formatFun = null;
			textLbl = null;
		}
		

	}
}