package game.module.camp.data
{
	import game.common.DataLoading;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.camp.CampData;
	import game.net.socket.WebSocketNetService;

	public class JueXingMange
	{
		/**觉醒数据*/
		private static var _juexingData:Object;
		private static var _instance:JueXingMange;
		
		public static var JUEXING_CHANGE:String = "JUEXING_CHANGE";
		public static var TEXING_CHANGE:String = "TEXING_CHANGE";
		
		public function JueXingMange()
		{
			if(_instance){				
				throw new Error("JueXingMange是单例,不可new.");
			}
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.JUEXING_GETUINT_INFO),
				this,getInfoBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.JUEXING_OPEN_LOCK),
				this,openLockBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.JUEXING_AUTO_OPEN_LOCK),
				this,openLockBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.JUEXING_TUPO),
				this,tupoBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.JUEXING_QIANGHUA),
				this,qianghuaBack);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.ERROR),
				this,onError);
			_instance = this;
			
		}
		
		public static function get intance():JueXingMange
		{
			if(_instance)
				return _instance;
			_instance = new JueXingMange;
			
			return _instance;
		}
		
		public function getInfoFun(uid:uint):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.JUEXING_GETUINT_INFO,[uid]);
		}
		
		private function getInfoBack(... args):void{
			var uid:Number = Number(args[1]);
			if(!_juexingData[uid])
			{
				_juexingData[uid] = new JueXingData(uid);
			}
			var jxd:JueXingData = _juexingData[uid];
			jxd.setData(args[2]);
			jxd.initData = false;
			Signal.intance.event(JUEXING_CHANGE,uid);
		}
		
		public function openLockFun(uid:uint,idx:uint):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.JUEXING_OPEN_LOCK,[uid,idx]);
			DataLoading.instance.show();
		}
		
		/**
		 * 一键自动全部更新
		 * @param uid
		 * 
		 */
		public function autoAllOpenLockFun(uid:uint):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.JUEXING_AUTO_OPEN_LOCK, [uid]);
			DataLoading.instance.show();
		}
		
		private function openLockBack(... args):void{
			var uid:Number = Number(args[1]);
			if(!_juexingData[uid])
			{
				_juexingData[uid] = new JueXingData(uid);
			}
			var jxd:JueXingData = _juexingData[uid];
			
			var list = [].concat(args[2]);
			list.forEach(function(item, index){
				jxd.jihuoAr[item] = 1;
			})
			
			Signal.intance.event(JUEXING_CHANGE, uid);
			DataLoading.instance.close();
		}
		
		private var _leftA:Array = [0,0,0,0];
		
		public function tupoFun(uid:uint):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.JUEXING_TUPO,[uid]);
			var cData:Object = CampData.getUintById(uid);
			if(cData)
			{
				_leftA[0] = Number(cData.hp);  //血量
				_leftA[1] = Number(cData.attack);  //攻击
				_leftA[2] = Number(cData.defense);  //防御
				_leftA[3] = Number(cData.speed);  //速度
			}
			DataLoading.instance.show();
		}
		
		
		private function tupoBack(... args):void{
			var uid:Number = Number(args[1]);
			if(!_juexingData[uid])
			{
				_juexingData[uid] = new JueXingData(uid);
			}
			var jxd:JueXingData = _juexingData[uid];
			jxd.level ++ ;
			jxd.jihuoAr = [0,0,0,0];
			
			var ar:Array = args[2];
			if(ar && ar.length)
			{
				for (var i:int = 0; i < ar.length; i++) 
				{
					jxd.features[ar[i]] = 1;
				}
				
			}
			
			
			XFacade.instance.openModule(ModuleName.NewJuexingTupoView,[uid,jxd.level - 1,_leftA,args[2]]);
			Signal.intance.event(JUEXING_CHANGE,uid);
			DataLoading.instance.close();
		}
		
		public function qiangHuaFun(uid:uint,tid:uint,qNum:uint):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.JUEXING_QIANGHUA,[uid,tid,qNum]);
			
			DataLoading.instance.show();
		}
		
		private function qianghuaBack(... args):void{
			var uid:Number = Number(args[1]);
			if(!_juexingData[uid])
			{
				_juexingData[uid] = new JueXingData(uid);
			}
			var jxd:JueXingData = _juexingData[uid];
			var tid:Number = Number(args[2]);
			var newlv:Number = Number(args[3]);
			jxd.features[tid] = newlv;
			jxd.featuresList; //刷新
			Signal.intance.event(TEXING_CHANGE, args);
			DataLoading.instance.close();
		}
		public function getJueXingDataByUid(uid:uint):JueXingData{
			if(!_juexingData) _juexingData = {};
			if(!_juexingData[uid])
			{
				_juexingData[uid] = new JueXingData(uid);
			}
			var jxd:JueXingData = _juexingData[uid];
			if(jxd.initData)
			{
				if(CampData.getUintById(uid))
					getInfoFun(uid);
			}
			return _juexingData[uid];
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			if(
				cmd == ServiceConst.JUEXING_OPEN_LOCK ||
				cmd == ServiceConst.JUEXING_TUPO ||
				cmd == ServiceConst.JUEXING_QIANGHUA ||
				cmd == ServiceConst.JUEXING_AUTO_OPEN_LOCK
			)
				DataLoading.instance.close();
		}
	}
}