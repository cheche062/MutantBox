package game.net.socket
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GameInterface.IGameDispose;
	import game.global.consts.ServiceConst;
	
	import laya.events.Event;
	import laya.net.Socket;
	import laya.utils.Browser;
	import laya.utils.Byte;

	/**
	 * websocket长链接 
	 * @author zhangmeng
	 * 
	 */	
	public class WebSocketNetService implements IGameDispose
	{
		
		private var _socket:Socket;
		
		private static var _instance:WebSocketNetService;
		
		private var _messageByt:Byte;
		
		/**
		 * 长链接ip地址 
		 * //CJW
		 * 10.8.189.14
		 * //HH
		 * 10.8.189.9
		 * //WK
		 * 10.8.189.13
		 */		
		//public var SOCKET_HOST:String="10.8.189.13";  //文凯
		public var SOCKET_HOST:String="10.8.189.14";  //褚继伟
		//public var SOCKET_HOST:String="10.8.189.9";  //花花
		/**
		 * 长链接端口 
		 */		
		public var SOCKET_PORT:int=9011;
		
		public static function get instance():WebSocketNetService{
			if(!_instance){
				_instance=new WebSocketNetService();
			}
			return _instance;
		}
		
		public function WebSocketNetService()
		{
			
		}
		/**
		 * 初始化websocket 
		 * 
		 */
		
		public function initSocket():void{
			_messageByt=new Byte();
//			this.initSocket();
			_socket=new Socket();
			_socket.endian=Socket.BIG_ENDIAN;
			if(GameSetting.IsRelease){
				_socket.connect(SOCKET_HOST,SOCKET_PORT,"wss");
			}else{
				_socket.connect(SOCKET_HOST,SOCKET_PORT);
			}
			_socket.on(Event.OPEN,this,socketConnetHandler);
			_socket.on(Event.CLOSE,this,socketCloseHandler);
			_socket.on(Event.MESSAGE,this,socketMsgHandler);
			_socket.on(Event.ERROR,this,socketErrorHandler);
		}
		
		/**
		 * socket链接成功 
		 * @param e
		 * 
		 */		
		public var _isOpen:Boolean = false;
		public var isClose:Boolean = false;
		private function socketConnetHandler(e:*=null):void{
			//trace("socket  connet  succese!");
			//trace("成功连接服务器"+SOCKET_HOST);
//			alert("socket  connet  succese!");
			_isOpen = true;
			while(msgAr.length){
				var m:Array = msgAr.shift();
				sendData(m[0],m[1]);
			}
		}
		/**
		 * socket关闭 
		 * @param e
		 * 
		 */		
		private function socketCloseHandler(e:*=null):void{
			trace("socket  connet  close!");
			_isOpen = false;
			isClose = true;
			
			var str:String = GameLanguage.getLangByKey("L_A_900007");
			if(str == "L_A_900007"){
				str = "Communication interrupted";
			}
			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,AlertType.YES,function(v:uint):void{
				if(v == AlertType.RETURN_YES)
				{
					GameSetting.reloadGame();
				}
			});
		}
		/**
		 * 收到socket数据 
		 * @param msg
		 * 
		 */		
		private function socketMsgHandler(msg:*=null):void{
			//trace("socket message back!");
			_messageByt.clear();
			_messageByt.writeArrayBuffer(msg);
			SocketMsgPackTool.instance.addByte(_messageByt);
			SocketMsgPackTool.instance.parseNetData();
		}
		/**
		 * socket发生错误 
		 * @param e
		 * 
		 */		
		private function socketErrorHandler(e:*=null):void{
			//trace("socket  connet  error!");
		}
		/**
		 * 向后端发送数据 
		 * @param _commandId
		 * @param value
		 */	
		public var msgAr:Array = [];
		public var heartArr:Array = [];
		private var keyCache:Object = {};
		public function sendData(_commandId:uint,value:Array):Boolean{
			if(!_isOpen)  //服务器未正常连接 ，请求数据等连接后再发出
			{
				msgAr.push([_commandId,value]);
				return false;
			}
			
			if(SocketMsgPackTool.oneConstList.indexOf(_commandId) != -1)
			{
				var k:String = hashServerKey(_commandId);
				if( keyCache.hasOwnProperty(k))
				{
					//trace(1,"单发协议，未响应",k);
					return false;
				}
				keyCache[k] = 1;
			}
			
//			Laya.timer.once(500,this,function(k2:String):void{
//				if( keyCache.hasOwnProperty(k))
//				{
//					trace("移除请求缓存",k);
//					delete keyCache[k];
//				}
//			},[k],false);
			
			var _arr:Array=new Array();
			_arr.push(_commandId);
			if(value!=null){
				_arr=_arr.concat(value);
			}
			var _byte:Byte=SocketMsgPackTool.instance.EncodeByt(_arr);
			this._socket.send(_byte.buffer);
			
			var url:String = "";
			try{
				url  = Browser.window.location.href
			}catch(e){
				
			}
			if(url.indexOf("10.8") != -1 || url.indexOf("qa") != -1 || url.indexOf("file") != -1){
				if (_commandId != 10108 && _commandId != 36200 && _commandId != 35000) {
					trace("send data:"+JSON.stringify(_arr));
				}
			}
			
			return true;
		}
		
		public function hashServerKey(_commandId:uint):String{
//			if(value && value.length)
//				return _commandId+":"+value;
			return _commandId+":";
		}
		
		
		public function serverConstBack(_commandId:uint):void
		{
			var k:String = hashServerKey(_commandId);
			if( keyCache.hasOwnProperty(k))
			{
				trace("移除请求缓存",k);
				delete keyCache[k];
			}
		}
		
		/**
		 * 关闭socket 
		 * 
		 */		
		public function closeSocket():void{
			if(this._socket && this._socket.connected){
				this._socket.close();
			}
			this._socket.offAll();
			socketCloseHandler();
		}
		/**
		 *清理 
		 * 
		 */		
		public function dispose():void
		{
			this.closeSocket();
			this._socket=null;
		}
	}
}