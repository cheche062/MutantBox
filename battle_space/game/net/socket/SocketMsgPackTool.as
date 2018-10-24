package game.net.socket
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.alert.XAlert;
	import game.module.fighting.view.FightingChapetrView;
	import game.module.fighting.view.FightingJYChapetrView;
	
	import laya.utils.Browser;
	import laya.utils.Byte;
	import laya.utils.Handler;

	/**
	 * socket进制流解压缩工具 
	 * @author zhangmeng
	 * 
	 */	
	public class SocketMsgPackTool
	{
		//错误提示(白名单)
		private var _errorConstList:Array = [
			ServiceConst.FIGHTING_GETSQUAD_CONST_GENE,
			ServiceConst.EQUIO_SUPPLIES_BUY,
			ServiceConst.FIGHTING_START_CONST_FM,
			ServiceConst.FIGHTING_START_CONST_GENE,
			ServiceConst.FIGHTING_START_CONST_WORLDBOSS,
			ServiceConst.FIGHTING_START_CONST_HOMEMONSTER,
			ServiceConst.FIGHTING_START_CONST_EQUIP,
			ServiceConst.FIGHTING_START_CONST_HOME,
			ServiceConst.FIGHTING_START_CONST_JIEBIAO,
			ServiceConst.FIGHTING_START_CONST_GBOSS,
			ServiceConst.ARENA_START_FIGHT,
			ServiceConst.START_MINE_FIGHT,
			ServiceConst.FIGHTING_SENDSQUAD_FY_SAVE_CONST,
			ServiceConst.TRAN_SAVEFORMATION,
			ServiceConst.ARENA_SAVE_DEFENCE,
			ServiceConst.SAVE_MINE_DEFENCE,
			ServiceConst.ARMY_GROUP_DEPLOY_SVAE,
			ServiceConst.SIMULATION_START,
			ServiceConst.FIGHTING_START_CONST,
			ServiceConst.ERROR_OFFSITE_LANDING,
			ServiceConst.PVP_PIPEI,
			ServiceConst.LUCKY_GET_C,
			ServiceConst.RADER_SWEEP_PROP
		];
		

		//单发协议(白名单) 无响应，不再发
		public static const oneConstList:Array = [
			ServiceConst.FIGHTING_START_CONST,  //开打
			ServiceConst.FIGHTING_START_CONST_FM,  //开打 - 推图
			ServiceConst.FIGHTING_START_CONST_JY,
			ServiceConst.FIGHTING_START_CONST_GENE,
			ServiceConst.FIGHTING_START_CONST_WORLDBOSS,
			ServiceConst.FIGHTING_START_CONST_HOMEMONSTER,
			ServiceConst.FIGHTING_START_CONST_EQUIP,
			ServiceConst.FIGHTING_START_CONST_HOME,
			ServiceConst.FIGHTING_START_CONST_JIEBIAO,
			ServiceConst.FIGHTING_START_CONST_GBOSS,
			ServiceConst.FIGHTING_SENDATTACK_CONST,
			ServiceConst.FIGHTING_JIDI_BUZHEN,
			ServiceConst.FIGHTING_SENDSQUAD_CONST,
			ServiceConst.FIGHTING_SENDSQUAD_EQUIP_CONST,
			ServiceConst.FIGHTING_SENDSQUAD_FY_SAVE_CONST,
			ServiceConst.FIGHTING_SENDATTACK_CONST,
			ServiceConst.BAG_INFO_DATA_CONST,
			ServiceConst.DRAW_CARD,
			ServiceConst.FIGHTING_SENDSQUAD_FY_CONST,
			ServiceConst.FIGHTING_SENDSQUAD_CONST,
			ServiceConst.FIGHTING_SENDSQUAD_EQUIP_CONST,
			ServiceConst.FIGHTING_SENDSQUAD_PVP_CONST,
			ServiceConst.NEW_FIGHTING_MAP_INIT,
			ServiceConst.LUCKY_GET_C
		];
		
		
		
		
		private static var _instance:SocketMsgPackTool;
		public static function get instance():SocketMsgPackTool{
			if(!_instance){
				_instance=new SocketMsgPackTool();
			}
			return _instance;
		}
		
		//缓存二进制数据
		private var _bytDataBuff:Byte;
		
		public function SocketMsgPackTool()
		{
		}
		/**
		 * 添加二进制数据到缓存中 
		 * @param value
		 * 
		 */		
		public function addByte(value:Byte):void{
			//if(!_bytDataBuff){
				_bytDataBuff=value;
			/*}else{
				_bytDataBuff.pos=_bytDataBuff.length;
				_bytDataBuff.writeArrayBuffer(value.buffer,_bytDataBuff.pos,value.buffer.length);
			}*/
		}
		
		/**
		 * 对象写入二进制 
		 * @param value
		 * @return 
		 * 
		 */		
		public function EncodeByt(value:Object):Byte{
			var _data:Uint8Array=new Uint8Array(__JS__("encodeByt(value)"));
			var _byt:Byte=new Byte(_data.buffer);
			return _byt;
		}
		
		/**
		 * 二进制读取对象
		 * @param value
		 * @return 
		 * 
		 */		
		public function DecodeByt(value:Byte):Object{
			var _buff:Uint8Array=new Uint8Array(value.buffer);
			var _obj:Array=__JS__("decodeByt(_buff)");
			return _obj;	
		}
		/**
		 * 解析socket缓存二进制数据 
		 */		
		public function parseNetData():void{
			this._bytDataBuff.pos=0;
			var _decodeByt:Byte=new Byte();
			_decodeByt.writeArrayBuffer(this._bytDataBuff.buffer,this._bytDataBuff.pos,_bytDataBuff.bytesAvailable);
			_decodeByt.pos=0;
			var _obj:Object=DecodeByt(_decodeByt);
			//第一位为协议返回的commandID
//			Signal.intance.event("msg_"+_obj[0],_obj);
			Signal.intance.event(ServiceConst.getServerEventKey(_obj[0]),_obj);
			if(Number(_obj[0]) == ServiceConst.ERROR)
				errorFun(_obj as Array);
			if(Number(_obj[0]) == ServiceConst.NO_MONEY)
			{
				var erConst:uint = Number(_obj[1]);
				WebSocketNetService.instance.serverConstBack(erConst);
				XFacade.instance.openModule(ModuleName.ChargeView);
			}
//			if(Number(_obj[0]) == ServiceConst.FIGHTING_MAP_NEWOPEN)
//			{
//				if(_obj[1] == "stage") FightingChapetrView.newOpenStageLevelID = Number(_obj[2]);
//				else FightingJYChapetrView.newOpenStageLevelID = Number(_obj[2]);
//			}
			WebSocketNetService.instance.serverConstBack(Number(_obj[0]) );
			
			var url:String = "";
			try{
				url  = Browser.window.location.href
			}catch(e){
				
			}
			if(url.indexOf("10.8") != -1 || url.indexOf("qa") != -1 || url.indexOf("file") != -1){
				if (_obj[0] != 10108 && _obj[0] != 36200 && _obj[0] != 35000) {
					trace("data pack......:",JSON.stringify(_obj));
				}
			}
			
//			alert("data pack......: id:"+_obj[0]+" data:"+_obj);
		}
		
		public function errorFun(ar:Array):void
		{
			var erConst:uint = Number(ar[1]);
			WebSocketNetService.instance.serverConstBack(erConst);
			if(_errorConstList.indexOf(erConst) != -1)
			{
				switch(erConst)
				{
					case ServiceConst.ERROR_OFFSITE_LANDING:
					{
//						XAlert.showAlert(ar[2] , Handler.create(this,reloadGame) , null , true,false);
						
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,ar[2],AlertType.YES,function(v:uint):void{
							if(v == AlertType.RETURN_YES)
							{
								reloadGame();
							}
						});
						
						break;
					}
						
					default:
					{
						XTip.showTip(ar[2]);
						break;
					}
				}
				
			}
		}
		
		
		private function reloadGame():void
		{
			GameSetting.reloadGame();
		}
		
	}
}