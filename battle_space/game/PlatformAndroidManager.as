package game
{
	import laya.runtime.IPlatformClass;

	public class PlatformAndroidManager
	{
		private var m_android:IPlatformClass;
		private static var m_intance:PlatformAndroidManager;
		private var m_isLogin:Boolean;
		public function PlatformAndroidManager()
		{
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
//			m_android=Laya.PlatformClass.createClass();
		}
		
		/**
		 * 登录
		 */
		public function login():void
		{
			m_android.call("login");
		}
		
		public function setData(p_data:String):void
		{
			m_android.call("setData");
		}
		
		/**
		 * 退出角色
		 */
		public function loginOut():void
		{
			m_android.call("loginOut");
		}
		
		/**
		 * 支付
		 */
		public function pay(p_data:String):void
		{
			var obj:Object=JSON.parse(p_data);
			m_android.call("pay",p_data);
			m_android.callWithBack(
		}

		public static function get intance():PlatformAndroidManager
		{
			if(!m_intance)
			{
				m_intance=new PlatformAndroidManager();
			}
			return m_intance;
		}
		
	}
}