package game.module.story
{
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;

	public class StoryManager
	{
		public static var TASK_PANNEL:String = "TASK_PANNEL";
		public static var STORY_PANNEL:String = "STORY_PANNEL";
		public function StoryManager()
		{
		}
		private static var _instance:StoryManager

		private var storyModule:String;
		public static function get intance():StoryManager
		{
			if (_instance)
				return _instance;
			_instance=new StoryManager;
			
			return _instance;
		}
		public function showStoryModule(module:String):void
		{
			storyModule = module;
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, onResult);
			WebSocketNetService.instance.sendData(ServiceConst.STORY_VIEW,[]);
		}
		private var STORY_STAGE:String = "config/story_stage.json";//重置条件
		public function activeStory():void
		{
			var storyObj:Object = ResourceManager.instance.getResByURL(STORY_STAGE);
			trace("剧情表："+ JSON.stringify(storyObj));
			for each(var con:Object in storyObj) 
			{
				var condition:String = con["condition"];
				trace("condition:"+condition);
				var cid:String = condition.split("=")[0];
				var clv:String =  condition.split("=")[1];
				var _nowLv:Number = User.getInstance().sceneInfo.getBuildingLv(cid);
				trace("当前建筑等级"+_nowLv);
				if(_nowLv == Number(clv))
				{
					showStoryModule(STORY_PANNEL);
				}
			}
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.STORY_VIEW: 
				{
					Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, onResult);
//					trace("章节数据1:"+JSON.stringify(args[1]));
//					trace("章节数据2:"+JSON.stringify(args[2]));
					//					trace("章节数据3:"+JSON.stringify(args[3]));
//					args[2] = "1000";//假数据
					if(args[1] == false)
					{
						trace("所有剧情任务已经完成");
						return;
					}
					if(storyModule == StoryManager.STORY_PANNEL)
					{
						if(args[2]=="")//剧情已经进行过了
						{
							//						onClose();
						}else
						{
							XFacade.instance.openModule(ModuleName.StoryView,args[2]);
						}
					}
					else if(storyModule == StoryManager.TASK_PANNEL)
					{
						XFacade.instance.openModule(ModuleName.StoryTaskView,args[1]);
//						XFacade.instance.openModule(ModuleName.StoryTaskView,args[1]);
					}
					break;
				}
			}
		}
	}
}