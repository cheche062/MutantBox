package game.module.gm
{
	import game.common.XFacade;
	import game.global.ModuleName;
	
	import laya.events.Event;
	import laya.ui.Button;
	
	public class helpButton extends Button
	{
		private var _helpMsg:String;
		
		public function helpButton(skin:String=null, label:String="" , msg:String = "")
		{
			super(skin, label);
			helpMsg = msg;
			
			this.on(Event.CLICK,this,clickFun);
		}

		private function clickFun(e:Event):void
		{
			XFacade.instance.openModule(ModuleName.IntroducePanel,helpMsg);
		}
		
		public function get helpMsg():String
		{
			return _helpMsg;
		}

		public function set helpMsg(value:String):void
		{
			_helpMsg = value;
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			this.off(Event.CLICK,this,clickFun);
			super.destroy(destroyChild);
		}

	}
}