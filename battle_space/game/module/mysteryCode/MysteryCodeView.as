package game.module.mysteryCode 
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.mysteryCode.MysteryCodeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MysteryCodeView extends BaseDialog 
	{
		
		public function MysteryCodeView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case this.view.closeBtn:				
					close();
					break;
				case view.exchangeBtn:
					if (view.inputTxt.text == "" || view.inputTxt.length == 0)
					{
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_80736"),AlertType.YES);
						return;
					}
					WebSocketNetService.instance.sendData(ServiceConst.EXCHANGE_CODE_REWARD,[view.inputTxt.text]);
					break;
				default:
					break;
				
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.EXCHANGE_CODE_REWARD:
					
					len = args[1].length;
					var ar:Array = [];
					for (i = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = args[1][i][0];
						itemD.inum = args[1][i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					break;
				default:
					break;
			}
		}
		
		private function checkInputTxt(e:Event):void
		{
			var str:String = StringUtil.removeBlank(view.inputTxt.text).toLowerCase();
			
			view.inputTxt.text = str;
		}
		
		override public function show(...args):void
		{
			super.show();
			view.inputTxt.text = "";
			AnimationUtil.flowIn(this);
		}	
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new MysteryCodeViewUI();
			this.addChild(_view);
			
			this.closeOnBlank = true;
		}
		
		private function get view():MysteryCodeViewUI{
			return _view;
		}
		
		override public function addEvent():void {
			
			view.inputTxt.on(Event.INPUT, this, checkInputTxt);
			
			this.view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.EXCHANGE_CODE_REWARD), this, serviceResultHandler, [ServiceConst.EXCHANGE_CODE_REWARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void {
			
			view.inputTxt.off(Event.CHANGE, this, checkInputTxt);
			this.view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.EXCHANGE_CODE_REWARD),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);			
			super.removeEvent();
		}
		
	}

}