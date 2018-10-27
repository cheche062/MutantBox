package game.common
{
	import game.global.GameSetting;
	
	import laya.net.URL;
	import laya.renders.Render;
	import laya.utils.Dictionary;

	public class UnpackMgr
	{
		private static var _instance:UnpackMgr;
		
		/**未压缩图片的原始记录数据*/
		private var _data:Array;
		public static function get instance():UnpackMgr{
			if( !_instance )
				_instance = new UnpackMgr();
			return _instance;
		}
		
		public function UnpackMgr()
		{
		}
		
		
		public var unpackResDic:Dictionary;
		public function initUnpackRes(obj:*):void{
			_data = obj;
			unpackResDic=new Dictionary();
			for each(var a:* in obj){
				unpackResDic[a]= ResourceManager.instance.resRoot + GameSetting.UNPACK_RES_ROOT + a;
			}
			URL.customFormat = UnpackMgr.instance.customFormat;
		}
		
		public function customFormat(url:String, basePath:String):String{
			if(url && url.indexOf(".swf") != -1 && url.indexOf(GameSetting.UNPACK_RES_ROOT) == -1){
				url = ResourceManager.instance.resRoot + GameSetting.UNPACK_RES_ROOT + url;
			}else if(UnpackMgr.instance.unpackResDic && UnpackMgr.instance.unpackResDic[url] != null){
				url = UnpackMgr.instance.unpackResDic[url];
			}
			//版本控制
			var newUrl:String = URL.version[url];
			if (!Render.isConchApp && newUrl) url += "?v=" + newUrl;
			return url;
		}
		
		/**判断一个资源是否属于未压缩资源*/
		public function check(url:String):Boolean{
			return _data.indexOf(url) != -1;
		}
	}
}