package game.module.gameSet
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.ModuleName;
	import game.net.socket.WebSocketNetService;
	import MornUI.panels.SetPanelUI;
	
	import game.common.AndroidPlatform;
	import game.common.FilterTool;
	import game.common.SoundMgr;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.StringUtil;
	
	import laya.debug.tools.DTrace;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	public class SetPanel extends BaseDialog
	{
		private static const TIPS:Object = {
			1:"L_A_12000",
			2:"L_A_12001",
			3:"L_A_12002",
			4:"L_A_12003",
			5:"L_A_12004",
			6:"L_A_12005",
			7:"L_A_12006",
			8:"L_A_12007",
			9:"L_A_12008",
			10:"L_A_12009",
			11:"L_A_12010",
			100:"L_A_12011"
		}
		public function SetPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.EXCHANGE_CODE_REWARD:
					
					len = args[1].length;
					var ar:Array = [];
					for (i = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = args[1][i][0];
						itemD.inum = args[1][i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		
		override public function show(...args):void{
			super.show();
			
			var data = args[0];
			
			// 设置
			var btn0:Button=view.tab1.getChildByName("item0");
			// 手游绑定账号
			var btn1:Button=view.tab1.getChildByName("item1");
			// 交换
			var btn2:Button=view.tab1.getChildByName("item2");
			
			for (var i = 0; i<3; i++) {
				var btn:Button=view.tab1.getChildByName("item"+i);
				btn.visible = data[0] == i;
			}
			view.tab1.selectedIndex = data[0];
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			view.tab1.selectedIndex = 0;
			tabSelectFun(0);
			
			view.selLangfBtn.label = GameConfigManager.thisLangCig.des;
			
			view.list01.repeatX = 1;
			view.list01.repeatY = 4;
			view.list01.itemRender = selLangCell;
			view.list01.spaceY = 10;
			var aaa:Array = GameConfigManager.langCigList.concat();
			aaa.shift();
			view.list01.array = aaa;
			view.list01.scrollBar.visible = false;
			view.list01.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.list01.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			if(Browser.onIOS==true)
			{
				view.GameCenterBtn.text.text="GameCenter";
				view.BindGoogleBtn.text.text="GameCenter";
				view.GameImage.skin="setPanel/icon_gamecenter.png";
				view.GoogleImage.skin="setPanel/icon_gamecenter.png";
				
			}
			else
			{
				view.GameCenterBtn.text.text="Google";
				view.BindGoogleBtn.text.text="Google";
				view.GameImage.skin="setPanel/icon_google.png";
				view.GoogleImage.skin="setPanel/icon_google.png";
				
			}
			//AndroidPlatform.instance.FGM_FacebookShare("测试","我就测试一下","https://www.baidu.com/","https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png",Handler.create(this,onShareHandler));
			view.inputTxt.text = "";
			view.ChangeBtn.selected=false;
			view.BindBtn.selected=true;
			view.SwitchBox.visible=false;
			view.BindBox.visible=true;
			view.mkgBg.mouseEnabled = true;
			view.skgBg.mouseEnabled = true;
			//禁止切换语言
			//if(GameSetting.isApp){
				//view.selLangfBtn.disabled = true
			//}
		}
		
		private function checkInputTxt(e:Event):void
		{
			var str:String = StringUtil.removeBlank(view.inputTxt.text).toLowerCase();
			
			view.inputTxt.text = str;
		}
		
		private function onShareHandler(p_str:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get view():SetPanelUI{
			if(!_view){
				_view = new SetPanelUI();
			}
			return _view as SetPanelUI;
		}
		
		private function bindButtonStyle(btn:Button,styleL:Array):void
		{
			btn.skin = styleL[0];
			btn.labelColors = styleL[1] +"," + styleL[1] +"," +  styleL[1];
		}
		
		private function initLoginBtn():void
		{
			var style1:Array = ["setPanel/btn_3.png" , "#3c4c5e"];
			var style2:Array = ["setPanel/btn_4.png" , "#a97e3a"];
			
			bindButtonStyle(view.FaceBookBtn,style1);
			bindButtonStyle(view.MutantboxBtn,style1);
			bindButtonStyle(view.GameCenterBtn,style1);
			bindButtonStyle(view.GuestBtn,style1);
			
//			view.FaceBookBtn.skin="setPanel/btn_3.png";
//			view.MutantboxBtn.skin="setPanel/btn_3.png";
//			view.GameCenterBtn.skin="setPanel/btn_3.png";
//			view.GuestBtn.skin="setPanel/btn_3.png";
			view.FacebookGouImage.visible=false;
			view.GoogleGouImage.visible=false;
			view.MutanBoxGouImage.visible=false;
			var len:int;
			
			if(GameSetting.LoginType!="guest")
			{
				this.view.LastLoginText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_13016"),GameSetting.LoginType);
			}
			else
			{
				this.view.LastLoginText.text=GameLanguage.getLangByKey("L_A_13017");
			}
			
			if(GameSetting.UserBanding){
				len = GameSetting.UserBanding.length
			}else{
				len = 0;
			}
			view.BindGoogleBtn.mouseEnabled=true;
			view.BindMutantboxBtn.mouseEnabled=true;
			view.BindFaceBookBtn.mouseEnabled=true;
			for(var i:int=0;i<len;i++)
			{
				DTrace.dTrace("android调用登录："+GameSetting.UserBanding[i]);	
				switch(GameSetting.UserBanding[i])
				{
					case "facebook":
						view.FacebookGouImage.visible=true;
						view.BindFaceBookBtn.mouseEnabled=false;
						break
					case "google":
						view.GoogleGouImage.visible=true;
						view.BindGoogleBtn.mouseEnabled=false;
						break;
					case "gw":
					case "mutantbox":
						view.MutanBoxGouImage.visible=true;
						view.BindMutantboxBtn.mouseEnabled=false;
						break;
					case "gamecenter":
						view.GoogleGouImage.visible=true;
						view.BindGoogleBtn.mouseEnabled=false;
						break;
				}
			}
			
			switch(GameSetting.LoginType)
			{
				case "google":
				{
//					view.GameCenterBtn.skin="setPanel/btn_4.png";
					bindButtonStyle(view.GameCenterBtn,style2);
					break;
				}
				case "facebook":
				{
//					view.FaceBookBtn.skin="setPanel/btn_4.png";
					bindButtonStyle(view.FaceBookBtn,style2);
					break;
				}
				case "gamecenter":
				{
//					view.GameCenterBtn.skin="setPanel/btn_4.png";
					bindButtonStyle(view.GameCenterBtn,style2);
					break;
				}
				case "mutantbox":
				{
//					view.MutantboxBtn.skin="setPanel/btn_4.png";
					bindButtonStyle(view.MutantboxBtn,style2);
					break;
				}
				case "guest":
				{
//					view.GuestBtn.skin="setPanel/btn_4.png";
					bindButtonStyle(view.GuestBtn,style2);
					break;
				}
			}
		}
		
		
		
		private function bindMutantBoxHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS){
				AndroidPlatform.instance.FGM_BindingAccount("4",Handler.create(this,bindCallBackHandler));
			}else{
				AndroidPlatform.instance.FGM_BindingAccount("3",Handler.create(this,bindCallBackHandler));
			}
		}
		
		private function bindGoogleHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			AndroidPlatform.instance.FGM_BindingAccount("5",Handler.create(this,bindCallBackHandler));
		}
		
		private function bindCallBackHandler(p_str:String):void
		{
			// TODO Auto Generated method stub
			var l_obj:Object=JSON.parse(p_str);
			var l_isSuc:Boolean=l_obj["isSuc"];
			if(Browser.onIOS && !l_obj["errCode"]){
				l_isSuc = true;
			}
			if(l_isSuc==true)
			{
				var strPlatform:*;
				strPlatform=l_obj["platform"];
				if(strPlatform is Array){
					DTrace("-------_obj[platform]-----isArray="+(strPlatform is Array));
					GameSetting.UserBanding = strPlatform;
				}else{
					DTrace("--------_obj[platform]----isString="+(strPlatform is String));
					var arrPlatform:Array=JSON.parse(strPlatform);
					GameSetting.UserBanding=arrPlatform;
				}
				initLoginBtn();
			}
			else
			{
				var errCode:* = l_obj["errCode"];
				if(errCode == undefined){
					errCode = 100;
				}
				//XAlert.showAlert(GameLanguage.getLangByKey(TIPS[errCode]), null,null, true, false);
				XTip.showTip(GameLanguage.getLangByKey(TIPS[errCode]));
			}
		}
		
		private function bindFaceBookHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS){
				AndroidPlatform.instance.FGM_BindingAccount("3",Handler.create(this,bindCallBackHandler));
			}else{
				AndroidPlatform.instance.FGM_BindingAccount("2",Handler.create(this,bindCallBackHandler));
			}
		}
		
		private function changeHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			view.ChangeBtn.selected=true;
			view.BindBtn.selected=false;
			view.SwitchBox.visible=true;
			view.BindBox.visible=false;
		}
		
		private function bindHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			view.ChangeBtn.selected=false;
			view.BindBtn.selected=true;
			view.SwitchBox.visible=false;
			view.BindBox.visible=true;
		}
		
		private function guestHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS)
			{
				AndroidPlatform.instance.FGM_GuestLogin(Handler.create(this,loginCallBackHandler));
			}
			else if(Browser.onAndriod)
			{
				AndroidPlatform.instance.FGM_GuestLogin(Handler.create(this,loginCallBackHandler));
			}
			
		}
		
		private function gameCenterHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS)
			{
				AndroidPlatform.instance.FGM_SwitchLogin("5",Handler.create(this,loginCallBackHandler));
				
			}
			else if(Browser.onAndriod)
			{
				AndroidPlatform.instance.FGM_SwitchUser("5",Handler.create(this,loginCallBackHandler));
			}
		}
		
		private function motantboxHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS)
			{
				AndroidPlatform.instance.FGM_SwitchLogin("4",Handler.create(this,loginCallBackHandler));
			}
			else if(Browser.onAndriod)
			{
				AndroidPlatform.instance.FGM_SwitchUser("3",Handler.create(this,loginCallBackHandler));
			}
			
		}
		
		
		private function faceBookHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(Browser.onIOS)
			{
				AndroidPlatform.instance.FGM_SwitchLogin("3",Handler.create(this,loginCallBackHandler));
			}
			else if(Browser.onAndriod)
			{
				AndroidPlatform.instance.FGM_SwitchUser("2",Handler.create(this,loginCallBackHandler));
			}
			
		}
		
		private function loginCallBackHandler(p_str:String):void
		{
			var l_obj:Object=JSON.parse(p_str);
			var l_isSuc:Boolean=l_obj["isSuc"];
			if(Browser.onIOS && !l_obj["errCode"]){
				l_isSuc = true;
			}
			//alert(p_str);
			if(l_isSuc==true)
			{
				var l_provider:int=parseInt(l_obj["provider"] || l_obj["currentChannel_num"]);
				switch(l_provider)
				{
					case 2:
					{
						GameSetting.LoginType="facebook";
						break;
					}
					case 5:
					{
						if(Browser.onIOS)
						{
							GameSetting.LoginType="gamecenter";
						}
						else
						{
							GameSetting.LoginType="google";
						}
						break;
					}
					case 3:
					{
						if(Browser.onIOS)
						{
							GameSetting.LoginType="facebook";
						}
						else
						{
							GameSetting.LoginType="mutantbox";
						}
						break;
					}
					case 4:
					{
						if(Browser.onIOS)
						{
							if(l_obj["currentChannel"] == "guest"){
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
				}
//				__JS__("window.location.reload();");
				GameSetting.reloadGame();
			}else{
				var errCode:* = l_obj["errCode"];
				if(errCode == undefined){
					errCode = 100;
				}
				//XAlert.showAlert(GameLanguage.getLangByKey(TIPS[errCode]), null,null, true, false);
				XTip.showTip(GameLanguage.getLangByKey("L_A_58009"));
			}
		}
		
		override public function addEvent():void{
//			Browser.onIOS
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.backBtn.on(Event.CLICK,this,backFun);
			view.selLangfBtn.on(Event.CLICK,this,selLangfFun);
			view.tab1.selectHandler = Handler.create(this,tabSelectFun,null,false);
			
			view.skgBg.on(Event.CLICK,this,skgBgFun);
			view.mkgBg.on(Event.CLICK,this,mkgBgFun);
			
			view.FaceBookBtn.on(Event.CLICK,this,faceBookHandler);
			view.MutantboxBtn.on(Event.CLICK,this,motantboxHandler);
			view.GameCenterBtn.on(Event.CLICK,this,gameCenterHandler);
			view.GuestBtn.on(Event.CLICK,this,guestHandler);
			view.ChangeBtn.on(Event.CLICK,this,changeHandler);
			view.BindBtn.on(Event.CLICK,this,bindHandler);
			view.BindFaceBookBtn.on(Event.CLICK,this,bindFaceBookHandler);
			view.BindGoogleBtn.on(Event.CLICK,this,bindGoogleHandler);
			view.BindMutantboxBtn.on(Event.CLICK,this,bindMutantBoxHandler);
			view.helpBtn.on(Event.CLICK, this, helpFun);
			
			view.exchangeBtn.on(Event.CLICK, this, codeExchange);
			view.inputTxt.on(Event.INPUT, this, checkInputTxt);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EXCHANGE_CODE_REWARD), this, serviceResultHandler, [ServiceConst.EXCHANGE_CODE_REWARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			
			bindMusicData();
			initLoginBtn();
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.backBtn.off(Event.CLICK,this,backFun);
			view.selLangfBtn.off(Event.CLICK,this,selLangfFun);
			view.tab1.selectHandler = null;
			
			view.skgBg.off(Event.CLICK,this,skgBgFun);
			view.mkgBg.off(Event.CLICK,this,mkgBgFun);
			
			view.FaceBookBtn.off(Event.CLICK,this,faceBookHandler);
			view.MutantboxBtn.off(Event.CLICK,this,motantboxHandler);
			view.GameCenterBtn.off(Event.CLICK,this,gameCenterHandler);
			view.GuestBtn.off(Event.CLICK,this,guestHandler);
			view.ChangeBtn.off(Event.CLICK,this,changeHandler);
			view.BindBtn.off(Event.CLICK,this,bindHandler);
			view.BindFaceBookBtn.off(Event.CLICK,this,bindFaceBookHandler);
			view.BindGoogleBtn.off(Event.CLICK,this,bindGoogleHandler);
			view.BindMutantboxBtn.off(Event.CLICK,this,bindMutantBoxHandler);
			view.helpBtn.off(Event.CLICK, this, helpFun);
			
			view.exchangeBtn.off(Event.CLICK, this, codeExchange);
			view.inputTxt.off(Event.CHANGE, this, checkInputTxt);
			
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EXCHANGE_CODE_REWARD),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);			
			
		}
		
		private function codeExchange(e:Event):void		
		{
			if (view.inputTxt.text == "" || view.inputTxt.length == 0)
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_80736"),AlertType.YES);
				return;
			}
			WebSocketNetService.instance.sendData(ServiceConst.EXCHANGE_CODE_REWARD,[view.inputTxt.text]);
					
		}
		
		private function helpFun(e:Event):void
		{
			if(GameSetting.isApp){
				AndroidPlatform.instance.FGM_OpenSupport(Handler.create(this,openSupportHandler));
			}else{
				Browser.window.open("https://www.mutantbox.com/support/index?game_id=9")
			}
		}
		
		private function tabSelectFun(idx:Number):void{
			view.box1.visible = idx == 0;
			view.box2.visible = idx == 1;
			view.box3.visible = idx == 2;
			view.box4.visible = idx == 3;
			view.inputTxt.text = "";
//			if(idx==2)
//			{
//				AndroidPlatform.instance.FGM_OpenSupport(Handler.create(this,openSupportHandler));
//			}
			if(idx==1)
			{
				initLoginBtn();
				
			}
		}
		
		private function openSupportHandler(p_str:String):void
		{
			
		}
		
		
		
		private function backFun(e:Event):void
		{
			tabSelectFun(0);
		}
		
		private function selLangfFun(e:Event):void
		{
			tabSelectFun(3);
		}
		
		private function skgBgFun(e:Event):void
		{
			SoundMgr.instance.m_bPlayeSound = ! SoundMgr.instance.m_bPlayeSound;
			bindMusicData();
		}
		
		private function mkgBgFun(e:Event):void
		{
			SoundMgr.instance.m_bPlayMusic = ! SoundMgr.instance.m_bPlayMusic;
			bindMusicData();
		}
		
		private function bindMusicData():void
		{
			trace("SoundMgr.instance.m_bPlayMusic:",SoundMgr.instance.m_bPlayMusic)
			trace("SoundMgr.instance.m_bPlayeSound:",SoundMgr.instance.m_bPlayeSound)
			view.mkgBg.filters = SoundMgr.instance.m_bPlayMusic ? null:[game.common.FilterTool.grayscaleFilter];
			view.mkgImg.x =  SoundMgr.instance.m_bPlayMusic ? 90 : 4;
			
			view.skgBg.filters = SoundMgr.instance.m_bPlayeSound ? null:[game.common.FilterTool.grayscaleFilter];
			view.skgImg.x =  SoundMgr.instance.m_bPlayeSound ? 90 : 4;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy SetPanel");
			
			super.destroy(destroyChild);
		}
	}
}