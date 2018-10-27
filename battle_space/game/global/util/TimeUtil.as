package game.global.util
{
	import game.global.StringUtil;
	
	import laya.utils.Browser;

	public class TimeUtil
	{
		public static const OneDaySceond:int = 24 * 3600;
	    public static const OneHourSceond:int = 3600;
		public static const OneMiniuteSecond:int = 60;
	 	/***/
		private static var _timeOff:Number;
		/**美西时间*/
		public static var timeStr:String="";
		
		public function TimeUtil()
		{
		}
		
		/**
		 *同步服务器时间戳 
		 * @param time 服务端时间戳,注意服务端的时间单位是秒
		 */
		public static function syncSrvTime(time:Number):void{
			var now:Number = Browser.now();
			_timeOff = time*1000 - now;
		}
		
		/**获取当前时间戳*/
		public static function get now():Number{
			return Browser.now() + _timeOff;
		}
		
		/**获取当前时间戳（和服务端保持单位一致）*/
		public static function get nowServerTime():Number{
			return Math.floor((Browser.now() + _timeOff) / 1000);
		}
		
		public static function getTrainTimeStr(time:Number):String
		{
			if(time<= 0){
				return "0S";
			}
			//先转换城秒
			time = Math.floor(time);
			var str:String = "";
			var d:int = Math.floor(time / OneDaySceond);
			time -= d*OneDaySceond;
			var h:int = Math.floor(time / OneHourSceond);
			time -= h*OneHourSceond;
			var m:int = Math.floor(time / OneMiniuteSecond);
			//trace("m: "+m);
			time -= m*OneMiniuteSecond;
			var s:Number = time;
			//trace("s: "+s);
			if (d > 0)
			{
				str += d + "D";
			}
			
			if (h > 0)
			{
				if (h < 10&&d>0)
				{
					str += "0";
				}
				str += h + "H ";
			}else if (d > 0)
			{
				str += "0H ";
			}
			
			if (m > 0)
			{
				if (m < 10&&h>0)
				{
					str += "0";
				}
				str += m + "M ";
			}else if (s > 0)
			{
				str += "0M ";
			}
			
			if (s > 0)
			{
				if (s < 10)
				{
					str += "0";
				}
				str += s + "S";
			}
			return str;
			
		}
		
		
		public static function getBossFightTimeStr(time:Number):String
		{
			if(time<= 0){
				return "0S";
			}
			//先转换城秒
			time = Math.floor(time/1000);
			var str:String = "";
//			var d:int = Math.floor(time / OneDaySceond);
//			time -= d*OneDaySceond;
			var h:int = Math.floor(time / OneHourSceond);
			time -= h*OneHourSceond;
			var m:int = Math.floor(time / OneMiniuteSecond);
			//trace("m: "+m);
			time -= m*OneMiniuteSecond;
			var s:Number = time;
			if (h > 0)
			{
				if (h < 10)
				{
					str += "0";
				}
				str += h + "H ";
			}
			
				if (m > 0)
				{
					if (m < 10)
					{
						str += "0";
					}
					str += m + "M ";
				}else if (h > 0)
				{
					str += "0M ";
				}
				if (s > 0)
				{
					if (s < 10)
					{
						str += "0";
					}
					str += s + "S";
				}
				else if (m > 0)
				{
					str += "00S";
				}
			
			
			
			return str;
		}
		
		
		
		
		
		/**
		 * 根据时间获得显示内容
		 * @param time 时间单位为毫秒 ,文本需要配置
		 */
		//todo文本需要配置HDMS
		public static function getTimeStr(time:Number):String{
			if(time<= 0){
				return "0S";
			}
			//先转换城秒
			time = Math.floor(time/1000);
			var str:String = "";
			var d:int = Math.floor(time / OneDaySceond);
			time -= d*OneDaySceond;
			var h:int = Math.floor(time / OneHourSceond);
			time -= h*OneHourSceond;
			var m:int = Math.floor(time / OneMiniuteSecond);
			//trace("m: "+m);
			time -= m*OneMiniuteSecond;
			var s:Number = time;
			//trace("s: "+s);
			if (d > 0)
			{
				str += d + "D";
			}
			if (h > 0)
			{
				if (h < 10)
				{
					str += "0";
				}
				str += h + "H ";
			}else if (d > 0)
			{
				str += "0H ";
			}
			
			if (m > 0)
			{
				if (m < 10)
				{
					str += "0";
				}
				str += m + "M ";
			}else if (h > 0)
			{
				str += "0M ";
			}
			
			if (s > 0)
			{
				if (s < 10)
				{
					str += "0";
				}
				str += s + "S";
			}
			else if (m > 0)
			{
				str += "00S";
			}
			
			return str;
			
			
			/*if(d > 0){
				if(h>0){
					str = d+"D"+h+"H";
				}else{
					str = d+"D";
				}
			}else if(h>0){
				if(m>0){
					str = h+"H"+m+"M";
				}else{
					str = h+"H";
				}
			}else if (m > 0) {
				trace("000");
				if (s > 0) {
					trace("11");
					str = m+"M"+s+"S";
				}else {
					trace("22: "+ s);
					str = m+"M";
				}
			}else{
				str = s+"S";
			}
			return str;*/
		}
		
		/**
		 * 根据时间获得显示短内容，最多显示2个时间单位。
		 * @param time 时间单位为毫秒 ,文本需要配置
		 */
		//todo文本需要配置HDMS
		public static function getShortTimeStr(time:Number, splitChar:String=""):String{
			if(time<= 0){
				return "0S";
			}
			//先转换城秒
			time = Math.floor(time/1000);
			var str:String = "";
			var d:int = Math.floor(time / OneDaySceond);
			time -= d*OneDaySceond;
			var h:int = Math.floor(time / OneHourSceond);
			time -= h*OneHourSceond;
			var m:int = Math.floor(time / OneMiniuteSecond);
			//trace("m: "+m);
			time -= m*OneMiniuteSecond;
			var s:Number = time;
			
			if(d > 0){
				if(h>0){
					str = d+"D"+splitChar+h+"H";
				}else{
					str = d+"D";
				}
			}else if(h>0){
				if(m>0){
					str = h+"H"+splitChar+m+"M";
				}else{
					str = h+"H";
				}
			}else if (m > 0) {
				if (s > 0) {
					str = m+"M"+splitChar+s+"S";
				}else {
					str = m+"M";
				}
			}else{
				str = s+"S";
			}
			return str;
		}
		
		/***
		 * 倒计时从小时算起
		 */
		public static function getTimeCountDownStr(p_time:Number,needDay:Boolean = true):String
		{
			if(p_time<= 0){
				return "00:00:00";
			}
			//先转换城秒
			p_time = Math.floor(p_time);
			var str:String = "";
			if(needDay)
			{
				var d:int = Math.floor(p_time / OneDaySceond);
				str+=d+"Day";	
				p_time -= d*OneDaySceond 
			}
			
			var h:int = Math.floor(p_time / OneHourSceond);
			p_time -= h*OneHourSceond 
			var m:int = Math.floor(p_time / OneMiniuteSecond);
			p_time -= m*OneMiniuteSecond;
			var s:Number = p_time;
			if(h>=10)
			{
				str+=h+":";	
			}
			else
			{
				str+="0"+h+":";
			}
			if(m>=10)
			{
				str+=m+":";
			}
			else
			{
				str+="0"+m+":";
			}
			if(s>=10)
			{
				str+=s;
			}
			else
			{
				str+="0"+s;
			}
			return str;
		}
		
		/***
		 * 倒计时从小时算起,格式为"0 day, 00 H: 00 min: 00 s";needDay是否换算day
		 */
		public static function getTimeCountDownStr_New(p_time:Number,needDay:Boolean = true):String
		{
			if(p_time<= 0){
				return "0 day, 00 H: 00 min: 00 s";
			}
			//先转换城秒
			p_time = Math.floor(p_time);
			var str:String = "";
			if(needDay)
			{
				var d:int = Math.floor(p_time / OneDaySceond);
				if(d<=1){
					str+=d+" day, ";
				}
				else{
					str+=d+" days, ";
				}
				p_time -= d*OneDaySceond 
			}
			
			var h:int = Math.floor(p_time / OneHourSceond);
			p_time -= h*OneHourSceond;
			var m:int = Math.floor(p_time / OneMiniuteSecond);
			p_time -= m*OneMiniuteSecond;
			var s:Number = p_time;
			if(h>=10)
			{
				str+=h+" H: ";	
			}
			else
			{
				str+="0"+h+" H: ";
			}
			if(m>=10)
			{
				str+=m+" min: ";
			}
			else
			{
				str+="0"+m+" min: ";
			}
			if(s>=10)
			{
				str+=s+" s";
			}
			else
			{
				str+="0"+s+" s";
			}
			return str;
		}
		
		
		/***
		 * 格式 00:00
		 */
		public static function formatStopwatch(time:Number):String{
			var sNum:Number = Math.ceil(time / 1000);
			var mNum:Number = Math.floor(sNum / 60);
			sNum = sNum % 60;
			var str:String = "{0}:{1}";
			var sStr:String = String(sNum);
			sStr = sStr.length == 2? sStr : "0" + sStr;
			var mStr:String = String(mNum);
			mStr = mStr.length == 2? mStr : "0" + mStr;
			return StringUtil.substitute(str,mStr,sStr);
		}
		
		
		/**
		 * 根据CD时间获取收费信息
		 * @ param time CD时间
		 * */
		public static function getFeeForTime(time:Number):Number{
			return 100
		}
		
		/**
		 * 将文本格式化为Date可以解析的字符串
		 * @param	dateStr
		 * @return
		 */
		public static function convertDateStr(dateStr:String):String{  
			var strArr:Array = dateStr.split(" ");  
			var fStr:String = "{0} {1} {2}";  
			return format(fStr, (strArr[0] as String).split("-").join("/"), strArr[1], "GMT");  
		}  
		  
		/**以前的format文章中的方法*/  
		public static function format(str:String, ...args):String{  
			for(var i:int = 0; i<args.length; i++){  
				str = str.replace(new RegExp("\\{" + i + "\\}", "gm"), args[i]);  
			}  
			return str;  
		}  
		
		/**
		 * 格式化时间，获取utc特殊格式
		 * */
		private static var date:Date = new Date();
		public static function getUTC():String{
			return timeStr+"\n(US WEST)";
			
			//
			date = getLocalTime(-7);
			var str:String = (date.getMonth()+1)+"/"+date.getDate()+" ";
			str += date.getHours()+":"+date.getMinutes();
			//str += "\nUTC"+date.getTimezoneOffset()/60;
			str += "\n(US WEST)";
			return str
		}
		//得到标准时区的时间的函数
		public static function getLocalTime(i) {
			//参数i为时区值数字，比如北京为东八区则输进8,纽约为西5区输入-5
			if (typeof i !== 'number') return;
			var d = new Date(Browser.now() + _timeOff);
			//得到1970年一月一日到现在的秒数
			var len = d.getTime();
			//本地时间与GMT时间的时间偏移差
			var offset = d.getTimezoneOffset() * 60000;
			//得到现在的格林尼治时间
			var utcTime = len + offset;
			return new Date(utcTime + 3600000 * i);
		}
		
		/**
		 * 把秒数转化成 *日*时*分*秒 对象
		 * @param num 秒数
		 * @return {days： *, hours: *, minutes: *, seconds: *}
		 * 
		 */
		public static function toDetailTime(num):String{
			var time = Number(num);
			var days = Math.floor(time / 1440 / 60);
			var hours = Math.floor((time - days * 1440 * 60) / 3600);
			var minutes = Math.floor((time - days * 1440 * 60 - hours * 3600) / 60);
			var seconds = (time - days * 1440 * 60 - hours * 3600 - minutes * 60);
			var result = {};
			result["days"] = days;
			result["hours"] = hours;
			result["minutes"] = minutes;
			result["seconds"] = seconds;
			
			return result;
		}
		
		/**将时间对象转为文案
		 * @param obj: {days： *, hours: *, minutes: *, seconds: *}
		 * @return 0d 0h 0m 0s
		 * 
		 */
		public static function timeToTextLetter(obj):String {
			if (obj.days != 0) {
				return obj.days + 'd ' + obj.hours + 'h';
			}
			if (obj.hours != 0) {
				return obj.hours + 'h ' + obj.minutes + 'm';
			}
			return obj.minutes + 'm' + obj.seconds + 's';
		}
		
		/**将时间对象转为文案
		 * @param obj: {days： *, hours: *, minutes: *, seconds: *}
		 * @return 0d 0h 0m 0s
		 * 
		 */
		public static function timeToTextLetter2(obj):String {
			return obj.days + 'd ' + obj.hours + 'h' + obj.minutes + 'm' + obj.seconds + 's';
		}
		
		/**
		 * 将时间对象转为文案
		 * @param obj: {days： *, hours: *, minutes: *, seconds: *}
		 * @return 03:22:06;
		 * 
		 */
		public static function timeToText(obj):String {
			var text:String = "";
			if (obj.days) text += (obj.days + ":");
			text += (compleToTwo(obj.hours) + ":");
			text += (compleToTwo(obj.minutes) + ":");
			text += (compleToTwo(obj.seconds));
			return text;
		}
		
		/**补足两位*/		
		public static function compleToTwo(str):String {
			var str:String = String(str);
			return str.length >= 2 ? str : "0" + str;
		}
		
		/**获取时间字符   time:1234234500   17:38:06 */
		public static function getHMS(time:Number):String {
			var date:Date = new Date(time);
			return compleToTwo(date.getHours()) + ":" + compleToTwo(date.getMinutes()) + ":" + compleToTwo(date.getSeconds());
		}
		
		/**获取当天几点整的时间戳*/
		public static function getCurrentTimeToStampByHours(h:int):int {
			return new Date(new Date().toLocaleDateString()).getTime() + h * 60 * 60 * 1000;
		}
	}
}