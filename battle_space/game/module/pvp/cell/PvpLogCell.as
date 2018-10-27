package game.module.pvp.cell
{
	import MornUI.pvpFight.PvpLogCellUI;
	
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class PvpLogCell extends PvpLogCellUI
	{
		
		protected var _data:Object;
		
		public function PvpLogCell()
		{
			super();
		}
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			if(_data)
			{
				this.isWinImg.skin = _data.isWin ? "pvpLog/icon_win.png":"pvpLog/icon_lose.png";
				this.levelLbl.text = _data.level;
				this.nameLbl.text= _data.name;
				this.sChangeLbl.text = _data.isWin ? "+"+ _data.addIntegral : "+0";
				this.sChangeLbl.color = _data.isWin ? "#82ff88" :"#ff9f9f";
				this.rbtn.disabled = _data.reportId == "";
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this.rbtn.on(Event.CLICK,this,onReplayHandler);
		}
		
		
		private function onReplayHandler(e:Event):void
		{
			FightingManager.intance.getFightReport([_data.reportId],null,Handler.create(this,completeReplayHandler),null,ServiceConst.getFightReport);
		}
		
		private function completeReplayHandler():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			var obj:Object = {};
			obj.fun = function() {
				XFacade.instance.openModule(ModuleName.PvpMainPanel);
				XFacade.instance.openModule(ModuleName.pvpLogPanel);
			};
			timer.once(500,obj,obj.fun);
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy PvpLogCell");
			
			_data = null;
			this.rbtn.off(Event.CLICK,this,onReplayHandler);
			super.destroy(destroyChild);
		}
	}
}