package game.module.gameSet
{
	import MornUI.panels.selLangCellUI;
	
	import game.common.DataLoading;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.LangCigVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class selLangCell extends selLangCellUI
	{
		private var _vo:LangCigVo;
		public function selLangCell()
		{
			super();
			this.btn.on(Event.CLICK,this,thisBtnFun);
		}
		
		public override function set dataSource(value:*):void{
			
			super.dataSource = value;
			if(_vo != value)
			{
				_vo = value;
				
				if(_vo)
				{
					this.btn.skin = _vo == GameConfigManager.thisLangCig ? "common/btn_1.png" : "common/btn_2.png";
					this.btn.label = _vo.des;
					this.btn.mouseEnabled = _vo != GameConfigManager.thisLangCig;
				}
			}
		}
		
		private function thisBtnFun(e:Event):void
		{
			//if(_vo)GameLanguage.langID = _vo.id;
			DataLoading.instance.show();
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.ChangeLan),this,onResult);
			WebSocketNetService.instance.sendData(ServiceConst.ChangeLan, [_vo.muti_language]);
			
		}
		
		private function onResult(...args):void{
			if(args[1] && args[1].lang){
				GameSetting.lang = args[1].lang
			}
			DataLoading.instance.close();
			GameSetting.reloadGame();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy selLangCell");
			_vo = null;
			this.btn.off(Event.CLICK,this,thisBtnFun);
			
			super.destroy(destroyChild);
		}
	}
}