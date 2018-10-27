package game.module 
{
	import MornUI.newerGuide.SetNameViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SetPlayerNameView extends BaseDialog 
	{
		
		private var userItemID:String = "93001";
		
		public function SetPlayerNameView() 
		{
			super();
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.NEW_SET_PLAYER_NAME:
					//trace("玩家名字设置完成");
					//Signal.intance.event(NewerGuildeEvent.SET_NAME_OK);
					User.getInstance().name = view.inputTxt.text;
					User.getInstance().event();
					close();
					AndroidPlatform.instance.FGM_CustumEvent("480_enter_name");
					
					break;
				default:
					break;
			}
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.confirmBtn:
					//trace("nameTxt:", view.inputTxt.text.length);
					
					AndroidPlatform.instance.FGM_CustumEvent("470_click_confirm_name");
					
					if (view.inputTxt.text == "" || view.inputTxt.text.length == 0)
					{
						view.errTxt.visible = true;
						view.errTxt.text = GameLanguage.getLangByKey("L_A_57016");
						return;
					}
					
					if (view.inputTxt.text.length < 4)
					{
						view.errTxt.visible = true;
						view.errTxt.text = GameLanguage.getLangByKey("L_A_57017");
						return;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.NEW_SET_PLAYER_NAME, [this.view.inputTxt.text, userItemID]);
					break;
				case view.closeBtn:
					close();
					Signal.intance.event(NewerGuildeEvent.SET_NAME_OK);
					break;
				default:
					break;
			}
		}
		
		private function checkInput(e:Event):void 
		{
			var str:String = StringUtil.removeBlank(this.view.inputTxt.text);
			this.view.inputTxt.text = str.substr(0, 14);
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			view.errTxt.text = errStr;
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			this.closeOnBlank = true;
			var ar:Array = args[0]
			if (ar)
			{
				userItemID = ar[0];
			}
			view.inputTxt.text = "";
			view.errTxt.text = GameLanguage.getLangByKey("L_A_75001");
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new SetNameViewUI();
			this.addChild(_view);
			
			view.inputTxt.text = "";
			view.inputTxt.on(Event.INPUT, this, this.checkInput);
			view.errTxt.text = GameLanguage.getLangByKey("L_A_75001");
			
			//view.errTxt.visible = false;
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.NEW_SET_PLAYER_NAME), this, serviceResultHandler, [ServiceConst.NEW_SET_PLAYER_NAME]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.NEW_SET_PLAYER_NAME), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.removeEvent();
		}
		
		
		
		private function get view():SetNameViewUI{
			return _view;
		}
	}

}