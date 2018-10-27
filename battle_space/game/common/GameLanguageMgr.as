package game.common
{
	import game.global.GameInterface.IGameDispose;
	
	import laya.utils.Dictionary;

	/**
	 * 多语言管理器 
	 * @author zhangmeng
	 * 
	 */	
	public class GameLanguageMgr implements IGameDispose
	{
		public function GameLanguageMgr()
		{
			_configData=new Dictionary();
		}
		
		private var _configData:Dictionary;
		
		private var _UIData:Object;
		
		private static var _instance:GameLanguageMgr;
		public static function get instance():GameLanguageMgr{
			if(!_instance){
				_instance=new GameLanguageMgr();
			}
			return _instance;
		}
		
		//初始化语言配置
		public function initConfigLan(value:Object):void{
			_configData=new Dictionary();
			for(var a:* in value){
				_configData.set(value[a].ID,value[a].value);
				//_configData[value[a].ID]=value[a].value;
			}
		}
		//初始化UI语言配置
		public function initUILan(value:Object):void{
			_UIData=value;
		}
		/**
		 * 获取多语言文字 
		 * @param id
		 * @return 
		 * 
		 */		
		public function getConfigLan(id:*):String{
			if(this._configData && this._configData.get(id)){
				return this._configData.get(id);
			}
			return id+"";
		}
		
		/**
		 * 把字符串中的占位符{0}、{1}用数组元素替换
		 * @param    source    源字符串
		 * @param    args    待替换字符串数组
		 * @return    替换后的字符串
		 */
		public function replacePlaceholder(source:String, args:Array):String {
			if (source == "") {
				return "";
			}
			var pattern:RegExp = /{(\d+)}/g;
			
			if (args.length > 0) {
				source = source.replace(pattern, function ():String {
					return args[arguments[1]];
				});
			}
			
			return this.replaceLanByBR(source);
		}
		
		/**
		 * 获取新的修正语言
		 * @param value
		 * @param arg
		 *
		 */
		public function replaceLanByBR(value:String):String {
			var _str:String = value + "";
			while (_str.indexOf("/n") != -1) {
				_str = _str.replace("/n", "<br>");
			}
			return _str;
		}
		
		/**
		 * 获取语言
		 * @param value 语言id
		 * @param arg 待替换字符串中所需要的参数
		 * @return  替换后的字符串
		 */
		public function getLanguage(value:Object, ...arg):String {
			if (this._configData) {
				var _str:String = this._configData.get(value) as String;
				if (_str && _str != "") {
					var str:String =  replacePlaceholder(_str, arg);
					str = str.replace(/^"*/g, "");
					str = str.replace(/"*$/g, "");
					return str;
				}
			}
			return replacePlaceholder(value + "", arg);
		}
		
		/**
		 * 清理 
		 */		
		public function dispose():void
		{
		}
	}
}