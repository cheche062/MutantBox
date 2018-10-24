package game.common
{
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.GameInterface.IGameDispose;
	
	import laya.utils.Handler;

	/**
	 * 平台sdk管理器 
	 * @author zhangmeng
	 * 
	 */	
	public class PlatFormManager implements IGameDispose
	{
		public function PlatFormManager()
		{
		}
		
		private static var _instance:PlatFormManager;
		public static function get instance():PlatFormManager{
			if(!_instance){
				_instance=new PlatFormManager();
			}
			return _instance;
		}
		
		public var m_bLoginSDKBack:Boolean=false;
		/**
		 * 登录sdk平台
		 * @param _callBack
		 */		
		public function login(_callBack:Handler):void{
			if(!GameSetting.isApp){
				_callBack.run();
				return;
			}
			var _currentLogin:Handler=new Handler(this,function(_str:String):void{
				var _obj:Object=JSON.parse(_str);
				trace("回调登录数据:"+_str);
				//__JS__("alert(_str)");
				alert(_str)
				if(_obj.hasOwnProperty("type")){
					m_bLoginSDKBack = false;
					_callBack.run();
				}else{
					m_bLoginSDKBack = true;
					//GameSetting.Login_New=parseInt(_obj["is_new"]);
					GameSetting.LoginType=_obj["currentChannel"];
					GameSetting.Login_Token=_obj["token"];
					GameSetting.Login_UID=_obj["uid"];
					//GameSetting.LoginType=_obj["channel"][0];
					GameSetting.UserBanding=_obj["channel"];
					GameSetting.Login_UserName=_obj["username"];
					_callBack.run();
				}
			});
			__JS__("FGM_Login(_currentLogin)");
		}
		
		/**
		 * 获取sdk平台唯一的设备id
		 * @param _callBack
		 */		
		public function getUDID(_callBack:Handler=null):void{
			var _currentLogin:Handler=new Handler(this,function(_str:String):void{
				trace("getUDID Back:"+_str);
				GameSetting.Login_UDID=_str;
				if(_callBack){
					_callBack.runWith(_str);
				}
			});
			__JS__("FGM_GetUDID(_currentLogin)");
		}
		
		/**
		 * 充值接口
		 * @param _callBack 回调函数
		 */		
		public function purchase(productId:String,price:String,para:String="myorder",_callBack:Handler=null):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				//trace("22222222purchase sdk back:"+_str1);
				//__JS__("alert(_str1)");
				var _obj:Object=JSON.parse(_str1);
				_callBack.runWith(_obj);
			});
			var _obj:Object=new Object();
			_obj["ProductID"]=productId;
			_obj["Para"]=productId;
			_obj["price"]=price;
			var _str:String=JSON.stringify(_obj);
			__JS__("FGM_Purchase(_str,_currentLogin)");
		}
		
		/**
		 * 切换登录 
		 * (类型2为gamecenter，类型1为facebook，类型3为mutantBox，类型4为游客登录)
		 */		
		public function switchLogin(_type:String,_callBack:Handler):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					//GameSetting.Login_New=parseInt(_obj["is_new"]);
					GameSetting.LoginType=_obj["currentChannel"];
					GameSetting.Login_Token=_obj["token"];
					GameSetting.Login_UID=_obj["uid"];
					GameSetting.UserBanding=_obj["platform"];
					GameSetting.Login_UserName=_obj["username"];
					_callBack.run();
				}
			});
			if(_type=="4"){
				guestLogin(_callBack);
				//__JS__("FGM_GuestLogin(_currentLogin)");
			}else{
				var _obj:Object=new Object();
				_obj["type"]=_type;
				var str:String=JSON.stringify(_obj);
				__JS__("FGM_SwitchLogin(str,_currentLogin)");
			}
		}
		/**
		 * 游客登录
		 * @param _callBack 回调函数
		 * 
		 */		
		public function guestLogin(_callBack:Handler):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_GuestLogin(_currentLogin)");
		}
		
		/**
		 * 切换账号 
		 * (类型1为gamecenter，类型2为facebook，类型3为mutantBox)
		 */		
		public function switchUser(_type:String,_callBack:Handler):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					GameSetting.LoginType=_obj["currentChannel"];
					GameSetting.Login_Token=_obj["token"];
					GameSetting.Login_UID=_obj["uid"];
					GameSetting.UserBanding=_obj["platform"];
					GameSetting.Login_UserName=_obj["username"];
					_callBack.run();
				}
			});
			var _obj:Object=new Object();
			_obj["type"]=_type;
			var str:String=JSON.stringify(_obj);
			__JS__("FGM_SwitchUser(str,_currentLogin)");
		}
		
		/**
		 *绑定账号 
		 */		
		public function bindingAccount(_type:String,_callBack:Handler):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			var _obj:Object=new Object();
			_obj["type"]=_type;
			var str:String=JSON.stringify(_obj);
			__JS__("FGM_BindingAccount(str,_currentLogin)");
		}
		/**
		 * 人物等级升级 
		 * @param value
		 * 
		 */		
		public function UserLevelUp(value:int):void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				
			});
			var _obj:Object=new Object();
			_obj["FGSDKAppEventParameterNameLevel"]=value;
			var str:String=JSON.stringify(_obj);
			__JS__("FGM_LevelUp(str,_currentLogin)");
		}
		
		/**
		 * 用户取名
		 * @param value
		 * 
		 */		
		public function UserCreatName():void{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				
			});
			__JS__("FGM_CreatName(_currentLogin)");
		}
		
		/**
		 * 分享facebook
		 * @param _callBack
		 * 
		 */		
		public function shareFaceBook(p_title:String,p_des:String,_callBack:Handler):void
		{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_shareFaceBook(_currentLogin)",p_title,p_des);
		}
		
		/**
		 * facebook邀请
		 */
		public function inviteFaceBookFriend(_callBack:Handler):void
		{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_inviteFaceBookFriend(_currentLogin)");
			
		}
		
		public function event(p_str:String,_callBack:Handler):void
		{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_Event(_currentLogin)",p_str);
			
			
		}
		
		public function diagnose(_callBack:Handler):void
		{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_diagnose(_currentLogin)");
			
		}
		
		public function getGameServiceList(_callBack:Handler):void
		{
			var _currentLogin:Handler=new Handler(this,function(_str1:String):void{
				var _obj:Object=JSON.parse(_str1);
				if(_obj.hasOwnProperty("type")){
					
				}else{
					_callBack.run();
				}
			});
			__JS__("FGM_GameServiceList(_currentLogin)");
		}
		
		
		
		//清理
		public function dispose():void{
			
		}
	}
}