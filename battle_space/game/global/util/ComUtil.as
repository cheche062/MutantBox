package game.global.util
{
	import game.global.GameSetting;
	import game.net.socket.WebSocketNetService;
	
	import laya.net.URL;
	import laya.utils.Browser;

	public class ComUtil
	{
		private static var  param:Object;
		/**初始化参数*/
		public static function initParms():void
		{
			if(Browser.window['location'])
			{
				var str:String = Browser.window.location.search.substr(1);
				var r:Array = Browser.window.location.search.substr(1).split("&");
				
				if(str.length > 1){
					GameSetting.IsRelease = true;
				}
				param = {};
				for (var i:int = 0; i < r.length; i++) {
					var arr:Array = r[i].split("=");
					param[arr[0]] = arr[1];
				}
				//设定版本号
				if(param["version"]){
					GameSetting.Version = param["version"];
				}
				if(param["tag"]){
					GameSetting.tag = param["tag"];
				}
				var d:* = param["data"];
				if(d){
					d = decodeURIComponent(d)
					str = __JS__('base64DeCode(d)');
					r = str.split("&");
					param = {};
					for (i = 0; i < r.length; i++) {
						arr = r[i].split("=");
						param[arr[0]] = arr[1];
					}
				}
				
				if(param["url"] && param["url"]!="")
				{
					WebSocketNetService.instance.SOCKET_HOST = param["url"];
				}
				//
				if(param["uid"] && param["uid"]!="")
				{
					GameSetting.Login_UID = param["uid"]
				}
				if(param["time"] && param["time"]!=""){
					GameSetting.Time = parseFloat(param["time"])+"";
				}
				if(param["token"] && param["token"]!=""){
					GameSetting.Login_Token = param["token"];
				}
				if(param["platform"] && param["platform"]!=""){
					GameSetting.Platform = param["platform"];
				}
				if(param["server_id"] && param["server_id"]!=""){
					GameSetting.ServerId = param["server_id"];
				}
				if(param["game_id"] && param["game_id"]!=""){
					GameSetting.gameId = param["game_id"];
				}
				if(param["open_id"] && param["open_id"]!=""){
					GameSetting.openId = param["open_id"];
				}
				if(param["login_ip"] && param["login_ip"]!=""){
					GameSetting.loginIp = param["login_ip"];
				}
				if(param["lang"] && param["lang"]!=""){
					GameSetting.lang = param["lang"];
				}
			}
		}
	}
}