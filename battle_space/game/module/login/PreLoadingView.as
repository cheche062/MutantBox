package game.module.login
{
	import MornUI.login.PreLoadingViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.ErrorPopManager;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.event.Signal;
	import game.global.util.DCCUtil;
	import game.global.util.PreloadUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.net.HttpRequest;
	import laya.net.Loader;
	import laya.net.LocalStorage;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	public class PreLoadingView extends BaseView
	{
		/***/
		private var _bg:Sprite;
		//
		private var _assetLoaded:Boolean = false;
		//
		private var _hasLogin:Boolean = false;
		//
		private var _hasLanLoaded:Boolean = false;
		
		private var m_bLoginSDKBack:Boolean;
		/**事件-准备好*/
		public static const RDY:String = "rdy";
		
		public var ServerId:String="";
		public var id:String="";
		private var m_obj:Object;
		private var isKaiFu:Boolean = false;
		private var m_systemStr:String;
		
		
		public function PreLoadingView()
		{
			super();
			this._m_iLayerType = LayerManager.M_TOP;
		}
		
		override public function show(...args):void{
			super.show();
			this.parent.addChildAt(_bg, this.parent.getChildIndex(this));
			AndroidPlatform.instance.FGM_ReportDataEvents("https://cdn.mutantbox.com/cdntest.png");
			if(!GameSetting.IsRelease){
				SoundMgr.instance.playMusicByURL(ResourceManager.instance.getSoundURL("loading"));
			}
			
			//
			if(GameSetting.isApp || GameSetting.IsRelease){
				view.btnLogin.visible=false;
				view.idTF.visible = false;
				view.ipCox.visible = false;
				if(GameSetting.isApp){
					GameSetting.getAppLan();
					this.view.switchBtn.visible = true;
				}
			}
			GameConfigManager.intance.initLan(false);
			this.view.SwtchLogin.visible=false;
			view.verTF.text= GameSetting.Version+"";
			onStageResize();
			
			if(GameSetting.isApp){
				//loadRes();
				DCCUtil.updateRes(Handler.create(this, loadRes), Handler.create(this, onLoading, ["Updating"], false))
			}else{
				loadRes();
			}
		}
		
		/**加载资源*/
		private function loadRes():void{
			onLoading("",0);
			Laya.loader.load(ResourceManager.instance.m_arrInitResource, Handler.create(this, onAssetLoaded), Handler.create(this, onLoading, ["Loading"], false));
		}
		
		
		private function getWedIP():void
		{
			var xhr:HttpRequest = new HttpRequest();
			xhr.http.timeout = 10000;//设置超时时间；
			xhr.once(Event.COMPLETE,this,completeHandler);
			xhr.once(Event.ERROR,this,errorHandler);
			xhr.send("https://ip.mutantbox.com/getip.php","","get","text");
		 }
		
		private function completeHandler(data:Object):void
		{
			id=data;
			AndroidPlatform.instance.FGM_GetGameServiceList(GameSetting.ServerId,Handler.create(this,getGameServiceHandler));
		}
		private function errorHandler(e:Object):void
		{
			AndroidPlatform.instance.FGM_GetGameServiceList(GameSetting.ServerId,Handler.create(this,getGameServiceHandler));
		}
		
		private function getGameServiceHandler(p_str:String):void
		{
			// TODO Auto Generated method stub
			var l_whiteArr:Array=new Array();
			m_systemStr="web";
			if(Browser.onAndriod)
			{
				m_systemStr="android";
			}
			else if(Browser.onIOS)
			{
				m_systemStr="ios";
			}
			
			if(p_str!=null)
			{
				var l_obj:Object=JSON.parse(p_str);
				if(l_obj!=null)
				{
					if(l_obj.data!=null&&l_obj.data!=undefined)
					{
						if(l_obj.data[0]!=null)
						{
							if(l_obj.data[0].server_status!=null)
							{
								if(parseInt(l_obj.data[0].server_status)==6)
								{
									var l_str:String=l_obj.data[0].ip_white;
									l_whiteArr=l_str.split(",");
									for (var i:int = 0; i < l_whiteArr.length; i++) 
									{
										if(id==l_whiteArr[i])
										{
											useLoginHandler();
											return;
										}
									}
									m_obj=JSON.parse(l_obj.data[0].stop_announcement);
									isKaiFu=true;
									XFacade.instance.openModule(ModuleName.ServerNoticeView,m_obj);
								}
								else
								{
									useLoginHandler();
								}
							}
							else
							{
								useLoginHandler();
							}
						}
						else
						{
							useLoginHandler();
						}
					}
					else
					{
						useLoginHandler();
					}
				}
			}
		}
		
		private function useLoginHandler()
		{	
			var loginArr:Array = [GameSetting.Login_UID,GameSetting.Login_Token,isMobile,m_systemStr,GameSetting.Login_UDID,
				GameSetting.TimeZone,GameSetting.Time,GameSetting.tag,GameSetting.Platform,GameSetting.lang,GameSetting.loginIp];
			if(view.SwtchLogin.visible==false)
			{
				if(GameSetting.isApp && Browser.onIOS)
				{
					trace("nopc-login");
					AndroidPlatform.instance.FGM_GetFCMToken(Handler.create(null,callBack));
				}else
				{
					trace("pc-login");
					GlobalRoleDataManger.instance.userLogin(loginArr,this,loginBack);
				}
			}
			function callBack(str:String):void
			{
				fcmStr = str; 
				if(str)
				{
					loginArr.push(str);
				}
				trace("GetToken is:"+str);
				trace("loginArr:"+JSON.stringify(loginArr));
				GlobalRoleDataManger.instance.userLogin(loginArr,this,loginBack);
			}
		}
		
		
		override public function close():void{
			super.close();
			this._bg.removeSelf();
			PreloadUtil.preloadMain();
			XFacade.instance.disposeView(this);
		}
		
		/**
		 * 点击按钮 
		 */		
		private function onClick(event:Event):void
		{
			var channelId:String='';
			switch(event.target)
			{
				case view.btnLogin:
					connectSrv();
					break;
				case view.switchBtn:
					openSwitchLoginView();
					break;
				case this.view.SwtchLogin.FaceBookBtn:
					if(Browser.onIOS){
						channelId = '3'
					}else{
						channelId = '2'
					}
					AndroidPlatform.instance.FGM_SwitchUser(channelId,Handler.create(this,loginCallBackHandler));
					break;
				case this.view.SwtchLogin.GoogleBtn:
					channelId = '5'
					AndroidPlatform.instance.FGM_SwitchUser(channelId,Handler.create(this,loginCallBackHandler));
					break;
				case this.view.SwtchLogin.GuestBtn:
					AndroidPlatform.instance.FGM_GuestLogin(Handler.create(this,loginCallBackHandler));
					break;
				case this.view.SwtchLogin.MutantBoxBtn:
					if(Browser.onIOS){
						channelId = '4';
					}else{
						channelId = '3';
					}
					AndroidPlatform.instance.FGM_SwitchUser(channelId,Handler.create(this,loginCallBackHandler));
					break;
				case this.view.SwtchLogin.CloseBtn:
					this.view.SwtchLogin.visible=false;
					useLoginHandler();
					break;
				case this.view.SwtchLogin.CheckBoxBtn:
					this.view.SwtchLogin.GouImage.visible=!this.view.SwtchLogin.GouImage.visible;
					this.view.SwtchLogin.CheckBoxBtn.selected=this.view.SwtchLogin.GouImage.visible;
					break;
			}
		}
		
		private function onLanRdy():void{
			Signal.intance.off("lan_rdy", this, onLanRdy);
			_hasLanLoaded = true;
			if(!GameSetting.isApp && _assetLoaded && !GameSetting.IsRelease){
				this.view.btnLogin.visible = true;
			}
			
			if(Browser.onIOS)
			{
				view.SwtchLogin.GoogleBtn.text.text=GameLanguage.getLangByKey("GAMECENTER");
			}else{
				view.SwtchLogin.GoogleBtn.text.text=GameLanguage.getLangByKey("GOOGLE");
			}
			this.view.SwtchLogin.LastLoginText.text=StringUtil.substitute("You're now logged in with {0}",GameSetting.LoginType);
			if(isKaiFu==true){
				XFacade.instance.openModule(ModuleName.ServerNoticeView,m_obj);
			}
			enterMainScene();
		}
		
		private function getDeviceData():void{
			if(Browser.onIOS){
				AndroidPlatform.instance.FGM_GetUDID(Handler.create(this,getDeviceInfo));
			}else{
				AndroidPlatform.instance.FGM_GetDeviceInfo(Handler.create(this,getDeviceInfo));
			}
			AndroidPlatform.instance.FGM_GetTimeZone(Handler.create(this,getTimeZone));
		}
	
		//连接服务器
		private function connectSrv()
		{
			var list:Array = ResourceManager.instance.getResByURL("staticConfig/servList.json");
			var srvInfo:Object;
			//app
			if(GameSetting.isApp){
				//当切换qa,s0服CDN时候，自动选择qa配置
				var str:String = "";
				if(Browser.window['conch'] && Browser.window['conch']['presetUrl']){
					str = Browser.window['conch']['presetUrl']+"";
				}
				var key:String;
				if(str.indexOf("qa") != -1){
					key = "qa"
				}else if(str.indexOf("s0") != -1){
					key = "s0"
				}else if(str.indexOf("10.8") != -1){//连局域网
					key = "test";
				}
				if(key){
					for(var i:int=0; i<list.length; i++){
						if(list[i].indexOf(key) != -1){
							srvInfo = list[i];
							break;
						}
					}
				}
				if(!srvInfo){
					srvInfo = list[0]
				}
			
				view.ipCox.visible = false;
			}else{
				if(GameSetting.IsRelease){//WSS服务，后一位端口
					srvInfo = [];
					srvInfo[0] = WebSocketNetService.instance.SOCKET_HOST;
					for(i=0; i<list.length; i++){
						if(list[i][0] == srvInfo[0]){
							srvInfo[1] = list[i][2];
							break;
						}
					}
					//
					srvInfo[3] = GameSetting.ServerId;
				}else{
					view.ipCox.visible = true;
					srvInfo = list[view.ipCox.selectedIndex];
				}
			}
			WebSocketNetService.instance.SOCKET_HOST = srvInfo[0];
			WebSocketNetService.instance.SOCKET_PORT = srvInfo[1];
			GameSetting.ServerId = srvInfo[3]
			
			if(!WebSocketNetService.instance._isOpen){
				WebSocketNetService.instance.initSocket(); 
			}
			SceneManager.intance.addGmPanelKey();
			m_systemStr="web";
			if(Browser.onAndriod){
				m_systemStr="android";
			}
			else if(Browser.onIOS){
				m_systemStr="ios";
			}
			
			if(GameSetting.isApp){
				AndroidPlatform.instance.FGM_ReportDataEvents("https://s18310001.mutantbox.com/test.html");
				getWedIP();
				
			}else{
				var uid:String = view.idTF.text;
				if(GameSetting.IsRelease){
					uid = GameSetting.Login_UID;
				}
				GlobalRoleDataManger.instance.userLogin([uid,GameSetting.Login_Token,isMobile,m_systemStr,GameSetting.Login_UDID,GameSetting.TimeZone,GameSetting.Time,GameSetting.tag,GameSetting.Platform,GameSetting.lang,GameSetting.loginIp],this,loginBack);
				LocalStorage.setItem("name", uid);
				LocalStorage.setItem("sIpIdx", view.ipCox.selectedIndex);
			}
		}

		private function getDeviceInfo(p_str:String):void
		{
			GameSetting.Login_UDID=p_str;
		}
		
		private function getTimeZone(p_str:String):void
		{
			GameSetting.TimeZone=p_str;
			
		}
	//	
		
		private function loginCallBackHandler(p_str:String):void
		{
			var l_obj:Object=JSON.parse(p_str);
			var l_isSuc:Boolean=l_obj["isSuc"];
			setLoginInfo(l_obj);
			GameSetting.reloadGame();
		}
		
		public function openSwitchLoginView():void
		{
			this.view.SwtchLogin.visible=true;
			if(Browser.onIOS)
			{
				view.SwtchLogin.GoogleBtn.text.text=GameLanguage.getLangByKey("GAMECENTER");
			}else{
				view.SwtchLogin.GoogleBtn.text.text=GameLanguage.getLangByKey("GOOGLE");
			}
		}
		
		
		private function onAssetLoaded():void
		{		
			//预加载配置管理器
			GameConfigManager.intance.init();
			
			_assetLoaded = true;
			if(_hasLanLoaded){
				if(!GameSetting.isApp && !GameSetting.IsRelease){
					view.btnLogin.visible = true;
				}
			}
			
			if(GameSetting.isApp){
				PreloadUtil.preloadAppMain();
				getDeviceData();
				AndroidPlatform.instance.FGM_Login(Handler.create(this,onStarSdk));
			}else if(GameSetting.IsRelease){
				connectSrv();
			}else{
				var list:* = ResourceManager.instance.getResByURL("staticConfig/servList.json");
				var arr:Array = [];
				for(var i:int=0; i<list.length; i++){
					arr.push(list[i][list[i].length-1]);
				}
				
				view.ipCox.labels = arr.join(",")
				readLocalData();
				view.btnLogin.visible=true;
			}
			
			this.enterMainScene();
		}
		
		private function onStarSdk(_str:String):void
		{
			var _obj:Object=JSON.parse(_str);
			trace("回调登录数据:"+_str);
			setLoginInfo(_obj);
		}
		
		private function setLoginInfo(p_obj:Object):void
		{
			var l_suc:Boolean=p_obj["isSuc"];
			if(Browser.onIOS){
				if(!p_obj["errCode"]){
					l_suc = true;
				}else{
					l_suc = false;
				}
			}
			if(l_suc==false){
				m_bLoginSDKBack = false;
				this.view.SwtchLogin.visible=true;
			}else{
				m_bLoginSDKBack = true;
				var l_provider:int=parseInt(p_obj["provider"] || p_obj["currentChannel_num"]);
				switch(l_provider)
				{
					case 2:
						GameSetting.LoginType="facebook";
						break;
					case 5:
						if(Browser.onIOS)
						{
							GameSetting.LoginType="gamecenter";
						}
						else
						{
							GameSetting.LoginType="google";
						}
						break;
					case 3:
						if(Browser.onIOS)
						{
							GameSetting.LoginType="facebook";
						}
						else
						{
							GameSetting.LoginType="mutantbox";
						}
						break;
					case 4:
						if(Browser.onIOS)
						{
							if(p_obj["currentChannel"] == "guest"){
								GameSetting.LoginType="guest";
							}else{
								GameSetting.LoginType="mutantbox";
							}
						}
						else
						{
							GameSetting.LoginType="guest";
						}
						break
				}
				this.view.SwtchLogin.LastLoginText.text=StringUtil.substitute("You're now logged in with {0}",GameSetting.LoginType);
				var strPlatform:*;
				GameSetting.Login_Token=p_obj["token"];
				GameSetting.Login_UID=(p_obj["userId"] || p_obj["uid"]);
				strPlatform=p_obj["platform"] || p_obj["channel"];
				GameSetting.Login_UserName=p_obj["userName"];
				AndroidPlatform.instance.FGM_CustumEvent("platforminfo");
				if(GameSetting.isApp){
					view.btnLogin.visible=false;
					connectSrv();
				}else{
					if(!GameSetting.IsRelease){
						view.btnLogin.visible=true;
					}
				}
				if(strPlatform){
					if(strPlatform is Array){
						GameSetting.UserBanding = strPlatform;
					}else{
						var arrPlatform:Array=JSON.parse(strPlatform);
						GameSetting.UserBanding=arrPlatform;
					}
				}
			}
		}
		
		private function readLocalData():void{
			//错误信息初始化
			ErrorPopManager.instance.initErrData();
			//
			var n:String = LocalStorage.getItem("name");
			var idx:Number = Number(LocalStorage.getItem("sIpIdx"));
			if(idx){
				view.ipCox.selectedIndex = -1;
				view.ipCox.selectedIndex = idx;
			}
			view.idTF.text = n+"";
		}
		
		private function loginBack():void
		{
			trace("login seccess fcm token:"+fcmStr);
			GameSetting.isLogin=true;
			_hasLogin = true;
			this.view.btnLogin.visible = false;
			if(GameSetting.isApp)
			{
				if(User.getInstance().is_new_user==true){
					AndroidPlatform.instance.FGM_EventCompletedRegisterSuccess(GameSetting.LoginType);
				}
			}
			
			GameConfigManager.intance.loaderLang();
			
			enterMainScene();
			AndroidPlatform.instance.FGM_CustumEvent("logingamesuccess");
			Signal.intance.event(RDY);
		}
		
		private var _startTime:Number;

		private var fcmStr:String;
		private function enterMainScene():void{
			if(this._assetLoaded && this._hasLogin && _hasLanLoaded){
				//新手
				if (User.getInstance().guideStep < 999){
					User.getInstance().hasFinishGuide = false;
					if (User.getInstance().guideStep == 0)
					{
						if(GameSetting.IsRelease){
							var arr:Array = PreloadUtil.getPreloadList();
							ResourceManager.instance.setResURLArr(arr, Loader.ATLAS);
							var tmp:Array = [
								"staticConfig/skillControlConfig.json","config/boss_level.json","config/unit_parameter.json"]
							
							ResourceManager.instance.setResURLArr(tmp);
							onLoading("",0)
							_startTime = TimeUtil.now;
							Laya.loader.load(tmp.concat(arr), Handler.create(this, onFightRdy), Handler.create(this, onLoading, [""], false));
						}else{
							onFightRdy();
						}
					}else{
						SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
						XFacade.instance.openModule(ModuleName.NewerGuideView);
						this.close();
					}
				}else{
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
				}
			}
		}
		
		private function onFightRdy():void{
			XFacade.instance.openModule(ModuleName.NewerGuideView);
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SIMULATION);
			AndroidPlatform.instance.FGM_CustumEvent("1_login", _startTime, TimeUtil.now, "chokepoint")
			AndroidPlatform.instance.FGM_CustumEvent("10_1_battle_dia1");
		}
		
		// 加载进度侦听器
		private function onLoading(labelStr:String, progress:Number):void
		{
			var tf:Label = view.infoBox.getChildByName("txtLoad") as Label;
			tf.text = labelStr;
			this.view.mcProcess.value = progress;
			this.view.bar.x = progress* this.view.mcProcess.width-100;
		}
		
		override public function onStageResize():void{
			if(Laya.stage.scaleMode != Stage.SCALE_SHOWALL){
				var delScale:Number = LayerManager.fixScale;
				if(delScale > 1){
					this._bg.scale(delScale,delScale);
					var rect:Rectangle = this._bg.getBounds();
					this._bg.pos(-(rect.width-Laya.stage.width)/2,-(rect.height-Laya.stage.height)/2);
				}
				if(this.view && this.view.infoBox){
					this.view.infoBox.y = Laya.stage.height - this.view.infoBox.height - 40;
				}
				this.view && (this.view.height = Laya.stage.height)
			}
		}
		
		private function onBGLoaded():void{
			if(Browser.window.loadingView){
				Browser.window.loadingView.loading(100);
			}
			onStageResize();
		}
		
		private function get isMobile():Number{
			if(GameSetting.isApp){
				return 1;
			}
			return 2
		}
		
		/**从这里开始*/
		override public function createUI():void
		{
			_bg = new Sprite();
			_bg.loadImage(ResourceManager.instance.setResURL("scene/preload.jpg"), 0,0,0,0, Handler.create(this,this.onBGLoaded));
			
			_view = new PreLoadingViewUI();
			this.addChild(_view);
			
			this.view.switchBtn.visible = false;
			this.view.btnLogin.visible = false;			
		}
		
		override public function addEvent():void{
			this.on(Event.CLICK, this, this.onClick);
			Signal.intance.on("lan_rdy", this, onLanRdy);
		}
		
		override public function removeEvent():void{
			this.off(Event.CLICK, this, this.onClick);
			Signal.intance.off("lan_rdy", this, onLanRdy);
		}
		
		public function get view():PreLoadingViewUI{
			return _view as PreLoadingViewUI;
		}
		
	}
} 