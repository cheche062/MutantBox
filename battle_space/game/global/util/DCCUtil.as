package game.global.util
{
	import game.common.ResourceManager;
	import game.global.GameSetting;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.net.LocalStorage;
	import laya.net.URL;
	import laya.utils.Browser;
	import laya.utils.Handler;

	/**
	 * DCCUtil
	 * author:huhaiming
	 * DCCUtil.as 2017-10-9 下午2:27:35
	 * version 1.0
	 *
	 */
	public class DCCUtil
	{
		private static var _loader:Loader;
		private static var _handler:Handler;
		//dcc 列表
		public static var dccList:Array;
		public function DCCUtil()
		{
			
		}
		
		/**更新DCC*/
		public static function updateDcc(handler:Handler):void {
			_handler = handler;
			_loader = new Loader();
			_loader.on(Event.COMPLETE, null, onC)
				
			var url:String = "";
			try{
				url  = Browser.window.location.href
			}catch(e:Error){
				
			}
//			trace("Browser.window.location.href:"+Browser.window.location.href);
			if(url.indexOf("qa") != -1){
				_loader.load("manifest.jpg?v="+Math.random(), Loader.BUFFER); 
				trace("mmmmmmm");
				trace("url:"+url);
			}else{
				_loader.load("manifest.jpg?v="+GameSetting.Version, Loader.BUFFER); 
				trace("nnnnnnn");
			}
		}
		
		/**-----------热更-----------*/
		public static function updateRes(comHandler:Handler, proHandler:Handler):void{
			if(dccList && dccList.length > 0){
				ResourceManager.instance.setResURLArr(dccList);
				trace("updateRes------------------------")
				trace(JSON.stringify(dccList));
				Laya.loader.load(dccList, Handler.create(null, done), proHandler);
			}else{
				dccList = null;
				comHandler.run();
			}
			
			//删除缓存
			function done():void{
				var url:String;
				for(var i:String in dccList){
					url = dccList[i].url;
					if(url.indexOf("preload.jpg") == -1 || url.indexOf("login.png") == -1){
						Laya.loader.clearRes(dccList[i].url);
					}
					
				}
				LocalStorage.setItem("dcc", JSON.stringify(URL.version));
				comHandler.run();
				dccList  =null;
			}
		}
		
		private static function onC(data:*):void{
			var str:String = __JS__("decompressFile(data, 'manifest.json')")+""
			URL.version = JSON.parse(str);
//			trace("URL.version:"+JSON.stringify(URL.version));
			var dccStr:String = LocalStorage.getItem("dcc");
//			trace("oldDccData:"+JSON.stringify(dccStr));
			if(!dccStr || dccStr.length < 20){
				LocalStorage.setItem("dcc", JSON.stringify(URL.version));
			}else{
				var curDcc:Object = URL.version;
				var oldDcc:Object = JSON.parse(dccStr);
				dccList = parseDcc(curDcc, oldDcc);
			}
//			trace("dccList:"+JSON.stringify(dccList));
			_handler.run();
			_handler = null;
			_loader.off(Event.COMPLETE, null, onC);
			_loader = null;
		}
		
		/**分析DCC*/
		private static function parseDcc(curDcc:Object, oldDcc:Object):Array{
			var arr:Array = [];
			for(var i:String in curDcc){
				if(curDcc[i] != oldDcc[i]){
					if(curDcc[i] is String){
						if(checkKey(i)){
							arr.push(i.replace("appRes/", ""))
						}
					}
				}
			}
			return arr;
			
			function checkKey(key:*):Boolean{
				if(key is String){
					if(key.indexOf("/atlas") != -1 && key.indexOf(".json")!=-1){
						return true;
					}else if(key.indexOf("/heroModel")!=-1 && key.indexOf(".json")!=-1){
						return true;
					}else if(key.indexOf("/buffEffect")!=-1 && key.indexOf(".json")!=-1){
						return true;
					}else if(key.indexOf("/effects")!=-1 && key.indexOf(".json")!=-1){
						return true;
					}else if(key.indexOf("/skillEffect")!=-1 && key.indexOf(".json")!=-1){
						return true;
					}else if(key.indexOf("/config") != -1){
						return true;
					}else if(key.indexOf("/unpackUI") != -1){
						return true;
					}
				}
				return false;
			}
		}
	}
}