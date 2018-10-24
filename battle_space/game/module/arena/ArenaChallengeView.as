package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.ChallengeEvent;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.arena.ChallengeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaChallengeView extends BaseView 
	{
		
		private var _chaItemVec:Vector.<ChallengeItem> = new Vector.<ChallengeItem>(3);
		
		
		
		
		public function ArenaChallengeView() 
		{
			super();
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
		}
		
		private function addToStageHandler():void 
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_CHECK_FIGHT),this,serviceResultHandler,[ServiceConst.ARENA_CHECK_FIGHT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		private function removeFromStageHandler():void 
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_CHECK_FIGHT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
		}
		
		
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.ARENA_CHECK_FIGHT:
					
					
					break;
				default:
					break;
			}
		}
		
		private function openArenaView():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			var obj:Object = { };
			obj.fun = function() {
				XFacade.instance.openModule(ModuleName.ArenaMainView);
				};
			Laya.timer.once(500, obj, obj.fun );
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			if (errStr == "L_A_907001")
			{
				return;
			}
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				default:
					break;
			}
		}
		
		public function setData(data:Array):void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				if (!_chaItemVec[i])
				{
					_chaItemVec[i] =  new ChallengeItem();
					_chaItemVec[i].x = 20 + 245 * i;
					_chaItemVec[i].y = 0;
					view.addChildren(_chaItemVec[i]);
				}
				
				if (data[i])
				{
					_chaItemVec[i].visible = true;
					_chaItemVec[i].dataSource = data[i];
				}
				else
				{
					_chaItemVec[i].visible = false;
				}
				
			}
		}
		
		override public function createUI():void
		{
			this._view = new ChallengeViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			//UIRegisteredMgr.AddUI(view, "ChallengeArea");
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			
			
			super.removeEvent();
		}
		
		private function get view():ChallengeViewUI{
			return _view;
		}
	}

}