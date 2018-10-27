package game.common
{
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.event.GameEvent;
	import game.global.event.Signal;
	import game.module.arenaScence.ArenaScence;
	import game.module.fighting.scene.FightingMapScene;
	import game.module.fighting.scene.PveFightingScane;
	import game.module.fighting.scene.PvpFightingScene;
	import game.module.invasion.InvasionScene;
	import game.module.mainScene.HomeScene;
	import game.module.mainScene.guest.GuestHomeView;
	import game.module.mineFight.MineFightScence;
	
	import laya.events.Event;
	
	

	public class SceneManager
	{
		private static var _instance:SceneManager
		public static function get intance():SceneManager{
			if(_instance)return _instance;
			_instance = new SceneManager();
			
			return _instance;
		}
		
		public var m_sceneCurrent:*;
		
		public var fromScene:String;
		public function SceneManager(){
			
		}
		/**
		 * 
		 * @param sceneType	当前场景
		 * @param showTop		头顶ui,不再有效
		 * @param type			myhome场景类型
		 * @param data			跳转参数
		 * 
		 */		
		public function setCurrentScene(sceneType:String, showTop:Boolean = true, type:int = 1,data:* = null):void
		{
			//console.log("setCurrentScene==>",sceneType);
			ModuleManager.intance.closeAll();
			if(m_sceneCurrent)
			{
				fromScene = m_sceneCurrent.name; 
				trace("fromSceneName: " + fromScene);
				m_sceneCurrent.toScene = sceneType;
				m_sceneCurrent.close()
				m_sceneCurrent = null;
			}
			switch(sceneType)
			{
				case SceneType.M_SCENE_FIGHT:
					m_sceneCurrent = ModuleManager.intance.getModule(PveFightingScane);
					break;
				case SceneType.M_SCENE_FIGHT_PVP:
					m_sceneCurrent = ModuleManager.intance.getModule(PvpFightingScene);
					break;
				case SceneType.M_SCENE_HOME:
					m_sceneCurrent = ModuleManager.intance.getModule(HomeScene);
					break;
				case SceneType.M_SCENE_FIGHT_MAP:
					m_sceneCurrent = ModuleManager.intance.getModule(FightingMapScene);
					break;
				case SceneType.S_INVASION:
					m_sceneCurrent = ModuleManager.intance.getModule(InvasionScene);
					break;
				case SceneType.S_GUEST:
					m_sceneCurrent = ModuleManager.intance.getModule(GuestHomeView);
					break;
				case SceneType.M_SCENE_MINE_FIGHT:
					m_sceneCurrent = ModuleManager.intance.getModule(MineFightScence);
					break;
				case SceneType.M_SCENE_ARENA:
					m_sceneCurrent = ModuleManager.intance.getModule(ArenaScence);
					break;
				//case SceneType.M_SCENE_ARMYGROUP:
					//m_sceneCurrent = ModuleManager.intance.getModule(ArmyGroupMapView);
				//	break;
				default:
					break;
			}
			//Quick.logs("======================  打开Scene: " + sceneType +"  ======================");
			m_sceneCurrent.name = sceneType;//给场景命名
			m_sceneCurrent.fromScene = fromScene;
			LayerManager.instence.addToLayerAndSet(m_sceneCurrent,LayerManager.M_SCENE,LayerManager.LEFTUP);
			LayerManager.instence.setPosition(m_sceneCurrent,LayerManager.LEFTUP)
			m_sceneCurrent.show(data);
		}
		
		public function get currSceneName():String{
			if(m_sceneCurrent)
				return m_sceneCurrent.name;
			return "";
		}
		
		public function addGmPanelKey():void
		{
			Laya.stage.on(Event.KEY_DOWN,this,onStageKeyDown);
		}
		
		public function onStageKeyDown(e:Event):void
		{
			if(e.keyCode == 71)
			{
				if(e.ctrlKey && e.altKey)
					Signal.intance.event(GameEvent.EVENT_OPEN_MODULE, ModuleName.GmToolPanel );
			}
		}
		
		
	}
}