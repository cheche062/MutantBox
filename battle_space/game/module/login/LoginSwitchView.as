package game.module.login
{
	import MornUI.equip.EquipMainViewUI;
	import MornUI.login.LoginSwitchViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameSetting;
	import game.global.ModuleName;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class LoginSwitchView extends BaseDialog
	{
		private var m_bLoginSDKBack:Boolean;
		
		public function LoginSwitchView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new LoginSwitchViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			super.show(args);
			initUI();
		}
		
		private function initUI():void
		{
			this.view.TipsText.underline=true;
			this.view.CheckBoxBtn.selected=true;
			this.view.GouImage.visible=true;
			
			
			
		}
		
		override public function addEvent():void
		{
			this.on(Event.CLICK,this,this.onClickHander);
		}
	
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
		}
		/**
		 * 
		 */
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.FaceBookBtn:
				{
					AndroidPlatform.instance.FGM_SwitchUser("1",Handler.create(this,loginCallBackHandler));
					break;
				}
				case this.view.GoogleBtn:
				{
					AndroidPlatform.instance.FGM_SwitchUser("2",Handler.create(this,loginCallBackHandler));
					break;
				}
				case this.view.GuestBtn:
				{
					AndroidPlatform.instance.FGM_GuestLogin(Handler.create(this,loginCallBackHandler));
					break;
				}
				case this.view.MutantBoxBtn:
				{
					AndroidPlatform.instance.FGM_SwitchUser("3",Handler.create(this,loginCallBackHandler));
					break;
				}
				case this.view.CloseBtn:
				{
					close();
					break;
				}
				case this.view.CheckBoxBtn:
				{
					this.view.CheckBoxBtn.selected=!this.view.CheckBoxBtn.selected;
					break;
				}
				default:
				{
					break;
				}
			}
		}		
		
		private function loginCallBackHandler(p_str:String):void
		{
			var l_obj:Object=JSON.parse(p_str);
			var l_isSuc:Boolean=l_obj["isSuc"];
			if(l_isSuc==true)
			{
				AndroidPlatform.instance.FGM_Login(Handler.create(this,onStarSdk));
			}
			else
			{
				
			}
		}
		
		/**
		 * 
		 */
		private function onStarSdk(_str:String):void
		{
			var _obj:Object=JSON.parse(_str);
			trace("回调登录数据:"+_str);
			//__JS__("alert(_str)");
			alert(_str)
			var l_suc:Boolean=_obj["isSuc"];
			if(l_suc==false){
				m_bLoginSDKBack = false;
			}else{
				m_bLoginSDKBack = true;
				//GameSetting.Login_New=parseInt(_obj["is_new"]);
				//GameSetting.LoginType=_obj["provider"];
				GameSetting.Login_Token=_obj["token"];
				GameSetting.Login_UID=_obj["userId"];
				//GameSetting.LoginType=_obj["channel"][0];
				GameSetting.UserBanding=_obj["provider"];
				GameSetting.Login_UserName=_obj["userName"];
				close();
				//loginHandler();
			}
		}
		
		
		private function get view():LoginSwitchViewUI
		{
			return _view as LoginSwitchViewUI;
		}
	}
}