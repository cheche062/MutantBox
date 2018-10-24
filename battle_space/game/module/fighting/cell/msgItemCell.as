package game.module.fighting.cell
{
	import MornUI.fightingViewPvp.msgItemUI;
	
	import game.global.consts.ServiceConst;
	import game.global.vo.quickMsgVo;
	import game.net.socket.WebSocketNetService;
	import game.module.pvp.PvpManager;
	
	import laya.events.Event;
	
	public class msgItemCell extends msgItemUI
	{
		private var _vo:quickMsgVo;
		
		public function msgItemCell()
		{
			super();
		}
		
		
		override protected function createChildren():void {
			super.createChildren();
			btn.on(Event.CLICK,this,btnclick);
		}
		
		private function btnclick(e:Event):void
		{
		
			if(_vo)
			{
				PvpManager.intance.sendMsg(_vo.id);
			}
		}
		
		
		
		override public function set dataSource(value:*):void{
			super.dataSource = _vo =  value;
			if(_vo)
			{
//				btn.label = _vo.name;
				iconImg.skin = _vo.iconPath;
//				trace("icon.skin ",icon.skin);
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy msgItemCell");
			_vo = null;
			btn.off(Event.CLICK,this,btnclick);
			
			super.destroy(destroyChild);
		}
		
	}
}