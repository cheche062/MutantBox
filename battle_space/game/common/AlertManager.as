package game.common
{
	import laya.ui.Dialog;
	import laya.utils.ClassUtils;

	public class AlertManager
	{
		private static var _instance:AlertManager;
		private var _alert:BaseAlertView;
		
		/**
		 *<code>AlertManager</code> 
		 * 弹出框管理类
		 */		
		public function AlertManager()
		{
		}
		
		public static function instance():AlertManager{
			if(!_instance) 
			{
				_instance = new AlertManager();
			}
			return _instance;
		}
		
		/**
		 *根据类型弹出提示框 
		 * @param type		弹出框类型
		 * @param data		传入数据
		 * 
		 */		
		public function AlertByType(type:String, data:* = null, flag:int = 0,externalCallBack:Function=null):void
		{
			if(flag == 0)
				flag = AlertType.YES|AlertType.NO;
//			var url:String = ResourceManager.intance.m_objModuleReource["BaseAlertView"];
//			Laya.loader.load([{url:url, type: Loader.ATLAS}], Handler.create(this, onLoaded,[type]));
			onLoaded(flag, type, data,externalCallBack);
		}
		
		public function onLoaded(flag:int, type:String, data:*,externalCallBack:Function=null):void
		{
			_alert = ClassUtils.getInstance(type);
			trace("弹出框", _alert);
			
			var back:* = externalCallBack != null ? externalCallBack : callBack;
			_alert.alert(flag, back, false, data);

			//Dialog.manager.popup(_alert);
			Dialog.manager.open(_alert);
//			onResizeChange();
		}
		
		public function closeAlert():void
		{
			if(_alert && _alert.displayedInStage)
				_alert.close();
		}
		
		
		public function onResizeChange():void
		{
			if(_alert)
			{
				_alert.x = (Laya.stage.width - _alert.width) /2;
				_alert.y = (Laya.stage.height - _alert.height)/2;
			}
		}
		
		
		public function callBack(params:*):void
		{
			
		}
	}
}