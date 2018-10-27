package game.module.playerHelp
{
	import game.global.event.NewerGuildeEvent;
	import game.global.vo.User;
	import MornUI.playerHelp.HelpNavUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.events.Event;
	
	public class HelpNavView extends BaseDialog
	{
		public function HelpNavView()
		{
			super();
//			closeOnBlank = true;
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			console.clear();
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_item0:
					XFacade.instance.openModule(ModuleName.PlayerHelpView, "20");
					close();
					
					break;
				case view.btn_item1:
					XFacade.instance.openModule(ModuleName.PlayerHelpView, "300");
					
					close();
					
					break;
				case view.btn_item2:
					
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.CLOSE_HELP_NOTE)
					}
					
					close();
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():HelpNavUI{
			_view = _view || new HelpNavUI();
			return _view;
		}
		
	}
}