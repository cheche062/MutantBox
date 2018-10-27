package game.common
{
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.fighting.BaseUnit;
	import game.module.alert.XAlert;
	import game.module.login.UpdateView;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.View;
	import laya.utils.Browser;
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	import laya.utils.Timer;

	public class ResourceManager
	{	
		/**
		 * 初始化资源
		 */		
		public var m_arrInitResource:Array = [];
		
		/**
		 * ui模块资源
		 * 模块名modeleName:ModuleName.PackViewController
		 * 资源地址URL: "res/atlas/comp.json" 
		 */		
		public var m_objModuleReource:Object = {};
		
		/**app版本更新信息*/
		private  var _appInfo:Object;
		
		private var _handle:Handler;
		
		private static var _instance:ResourceManager;
		public function ResourceManager()
		{
			if(_instance){				
				throw new Error("ResourceManager是单例,不可new.");
			}
			_instance = this;
		}
		
		public static function get instance():ResourceManager{
			if(!_instance){
				_instance = new ResourceManager();
			}
			return _instance;
		}
		
		/**
		 * 加载资源配置表
		 *  
		 */		
		public function init(handle:Handler):void
		{ 
			_handle = handle;
			Laya.loader.load(GameSetting.GameResource_URL, Handler.create(this, onConfigLoaded));
			// 侦听加载失败
			Laya.loader.once(Event.ERROR, this, onError);
		}
		
		private function onError(err:String):void
		{
			trace("GameResource加载失败:  " + err);
		}  
		
		private function onConfigLoaded(data:Object):void
		{			
			Laya.loader.off(Event.ERROR, this, onError);
			var m_arrPreResource:Array = data["initPreload"];//进入游戏之前加载
			m_arrInitResource = data["initGame"];//进入游戏时加载
			m_objModuleReource = data["initModule"];//进入某个界面时加载
			//缓存公共地址
			initResourceURL(m_arrPreResource, true);
			initResourceURL(m_arrInitResource, true);
			
			_appInfo = data["appVersion"];
			
			Laya.loader.load(m_arrPreResource, Handler.create(this, onPreAssetLoaded));
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////
		///////// 预加载---登录游戏之前,解析基础配置数据
		/////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function onPreAssetLoaded():void
		{
			var obj:Object = Loader.getRes("appRes/uiXML.json");
			//初始化UIXML
			View.uiMap = obj;
			//解析未打包资源
			obj=ResourceManager.instance.getResByURL("unpackUI/unpack.json");
			UnpackMgr.instance.initUnpackRes(obj);
			//缓存模块地址
			initResourceURL(m_objModuleReource);
			
			//语言包
			obj=ResourceManager.instance.getResByURL("config/english.json");
			GameLanguageMgr.instance.initConfigLan(obj);
			
//			for (var url:String in Loader.loadedMap)
//			{
//				trace("加载的资源url:"+url);
//			}
			/**强制更新*/
			if(GameSetting.isApp){
//			if(!GameSetting.isApp){
				var versinInfo:Object;
				if(Browser.onIOS){
					versinInfo = _appInfo["ios"]
				}else{
					versinInfo = _appInfo["andriond"]
				}
				if(versinInfo.update || versinInfo.tip){
					AndroidPlatform.instance.FGM_GetAppVersion(Handler.create(this, onGetVersion));
				}else{
					callback();
				}
			}else{
				callback();
			}
		}
		
		/***/
		private function onGetVersion(ver:*):void{
			ver = (ver+"").replace(/\./g,"")
			var version:int = parseInt(ver+"");
			
			var versinInfo:Object;
			if(Browser.onIOS){
				versinInfo = _appInfo["ios"]
			}else{
				versinInfo = _appInfo["andriond"]
			}
			
			var targeVer:int = versinInfo["ver"];
			trace("ver::"+ver+"__targetVer::"+targeVer)
			if(ver < targeVer){
				XFacade.instance.showModule(UpdateView,[versinInfo,Handler.create(this,callback)])
			}else{
				callback();
			}
		}
		
		private function callback():void{
			//配置解析完成，执行回调
			_handle.run();
			_handle.recover();
			_handle = null;
		}

		
		/**
		 * 根据平台设置资源地址 
		 * @param data
		 * 
		 */		
		private function initResourceURL(data:*):void
		{
			if(data is Array){
				setResURLArr(data);
			}else if(data is Object){
				for each (var key:Array in data) {
					setResURLArr(key);
				}				
			}
		}
		
		/**
		 * 根据当前平台设置资源地址 
		 * @param url 资源地址数组
		 * @return
		 * 
		 */	
		public function setResURLArr(data:Array, type:String = '', pri:int=1):void
		{
			var defaultType:String;
			var url:String;
			for (var i:int = 0; i < data.length; i++) {
				url = setResURL(data[i]);
				defaultType = getTypeFromUrl(url);
				if(type && defaultType == Loader.JSON){
					defaultType = type;
				}
				data[i] ={url:url, type: defaultType, size: 1, priority: pri};
			}				
		}
		
		private static var _extReg:RegExp =/*[STATIC SAFE]*/ /\.(\w+)\??/g;
		/**
		 * 获取指定资源地址的数据类型。
		 * @param	url 资源地址。
		 * @return 数据类型。
		 */
		public function getTypeFromUrl(url:String):String {
			_extReg.lastIndex = url.lastIndexOf(".");
			var result:Array = _extReg.exec(url);
			if (result && result.length > 1) {
//				trace("result[0]:"+result[0]);
				var type:String = Loader.typeMap[result[1].toLowerCase()];
				if(type== Loader.JSON)
				{
					if(checkAtlas(url)){
						type = Loader.ATLAS;
					}
				}
				return type;
			}
			trace("Not recognize the resources suffix", url);
			return "text";
		}
		
		private function checkAtlas(key:*):Boolean{
			if(key is String){
				if(key.indexOf("/atlas") != -1){
					return true;
				}else if(key.indexOf("/heroModel")!=-1){
					return true;
				}else if(key.indexOf("/buffEffect")!=-1){
					return true;
				}else if(key.indexOf("/effects")!=-1){
					return true;
				}else if(key.indexOf("/skillEffect")!=-1){
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 根据当前平台设置资源地址 
		 * @param url 资源地址
		 * @return
		 * 
		 */		
		public function setResURL(url:String):String
		{
			if(UnpackMgr.instance.unpackResDic && UnpackMgr.instance.unpackResDic[url] != null)
				return UnpackMgr.instance.unpackResDic[url];
			return resRoot + url;
		}
		
		public function get resRoot():String{
			var resRoot:String;
			resRoot = "appRes/";
			return resRoot;
		}
		
		
		/**
		 * 根据GameResource配置的url获取资源 ,注意，图集里面的是RES不能用这个获取，直接用Loader.getRes
		 * @param url
		 * @return 
		 */		
		public function getResByURL(url:String):*
		{
			var targetURL:String = ResourceManager.instance.setResURL(url);
			var data:* = Loader.getRes(targetURL);
			return data;
		}
		
		private var ii:int = 100;
		/**
		 * 加载GameResource指定资源。
		 * @param	name 地址，或者资源对象数 GameResource.json配置的名字
		 * @param	complete 结束回调，如果加载失败，则返回 null 。
		 * @param	progress 进度回调，回调参数为当前文件加载的进度信息(0-1)。
		 * @param	type 资源类型。
		 * @param	priority 优先级，0-4，五个优先级，0优先级最高，默认为1。
		 * @param	cache 是否缓存加载结果。
		 * @return 此 LoaderManager 对象。
		 */
		public function load(name:*, complete:Handler=null, type:String=null, priority:int=1, cache:Boolean=true, showLoading:Boolean = true):void
		{
			ii++;
			var urlArr:Array = ResourceManager.instance.m_objModuleReource[name];	
			if(urlArr==null || urlArr.length<1)
			{
				trace("ModuleName:"+name+"  URL:null");
				complete.run();
				return;
			}
//			showLoading && BufferView.instance.show();
			trace("ModuleName:"+name+"  URL:"+urlArr);
			ModuleLoading.instance.show();
			Laya.loader.load(urlArr,Handler.create(this,loadItemComplete,[complete,showLoading]),Handler.create(this, onLoadProgress,[name], false),type,priority,cache, ii.toString());
		}
		
		private function loadItemComplete(value:Handler,showLoading:Boolean=true):void{
			ModuleLoading.instance.close();
//			showLoading && BufferView.instance.close();
			value && value.run();
		}
		
		private function onLoadProgress(name:String,progress:Number):void
		{
//			trace("ModuleManager--->onLoadProgress : "+name +"  progress:  "+progress);
		}
		
		
		public function getSoundURL(name:String):String
		{
			var url:String = setResURL("mp3/" + name + ".mp3");
			return url;
		}
		
		
		public function getLangImageUrl(imageName:String):String{
//			return "appRes/LangImage/"+GameLanguage.LANGNAME+"/"+imageName ;
				
			return "appRes/LangImage/"+GameConfigManager.thisLangCig.name+"/"+imageName ;
		}
		
//		public function getHeroFaceUrl(fName:String,sType:String = "min"):String{
//			return "appRes/heroFace/"+sType+"/"+fName ;
//		}
		
		public static function getSoundUrl(sName:String,sType:String = "fighting"):String{
			sName = formatSoundName(sName);
			return "appRes/"+SoundMgr.soundType+"/"+sType+"/"+sName;
		}
		
		
		public static function formatSoundName(sName:String):String
		{
			return sName + "." + SoundMgr.soundType;
		}
		
		public static function getUnitMp3(uid:* , action:String):String{
			var actToact:Object = {};
			actToact[BaseUnit.ACTION_SHOW] = "Appearance";
			actToact[BaseUnit.ACTION_DIE] = "death";
			actToact[BaseUnit.ACTION_MOVE] = "move";
			if(actToact[action])
				return uid + "_" + actToact[action] ;
			return null;
		}
		
		public function clearResByGroup(gname:String):void
		{
			Laya.timer.once(500,this,function():void{
				Loader.clearResByGroup(gname);
			});
		}
	}
}