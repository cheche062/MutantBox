package game
{
	import game.common.SceneManager;
	import game.common.baseScene.SceneType;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.story.StoryManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.debug.tools.SingleTool;

	public class RedPointManager
	{
		public static var STORY_MISSION_RED_CHANGE:String = "STORY_MISSION_RED_CHANGE";

		public var activeStoryRed:Boolean;
		public function RedPointManager()
		{
		}
		public function init():void
		{
			
		}
		private static var _instance:RedPointManager;
		public static function get intance():RedPointManager
		{
			if (_instance)
				return _instance;
			_instance=new RedPointManager();
			
			return _instance;
		}
		/**
		 *请求剧情任务小红点 
		 * @return 
		 * 
		 */
		public function requestStoryRed():void
		{
//			if(SceneManager.intance.m_sceneCurrent == SceneType.M_SCENE_HOME)
//			{
				Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, serviceResultHandler, [ServiceConst.STORY_VIEW]);
				WebSocketNetService.instance.sendData(ServiceConst.STORY_VIEW,[]);
//			}
		}
		
		private function serviceResultHandler(cmd:int, ...args):void
		{
			switch(cmd)
			{
//				trace("emmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
			
				case ServiceConst.STORY_VIEW:
//					trace("11111111122222222222");
					if(args[1] == false)
					{
						//trace("所有剧情任务已经完成");
						return;
					}
					var allChapterData:Array = [];
					for (var key:String in args[1])
					{
						//				trace("每一章节的数据："+JSON.stringify(args[0][key]));
						allChapterData.push(args[1][key]);
					}
					activeStoryRed = false; 
					//					trace("长度:"+allChapterData.length);
					for(var i:int=0;i<allChapterData.length;i++)
					{
						var curCharacterData:Object = allChapterData[i];
						var curCharacterTask:Object = curCharacterData["task"];
						//						listData = [];
						//									trace("当前章节任务:"+JSON.stringify(curCharacterTask));
						
						for(var key:String in curCharacterTask)
						{
							var state:int = parseInt(curCharacterTask[key][0]);
							if(state==1)
							{
								activeStoryRed = true;
								break;
							}
						}
					}
					//trace("小任务红点:"+activeStoryRed);
					if(!activeStoryRed)
					{
						for(var i:int=0;i<allChapterData.length;i++)
						{
							var curCharacterData:Object = allChapterData[i];
							if(curCharacterData["rewardsGeted"]==0)
							{
								var chapterCan:Boolean = true;
								var curCharacterTask:Object = curCharacterData["task"];
								for(var key:String in curCharacterTask)
								{
									var taskState:int = parseInt(curCharacterTask[key][0]);
									if(taskState==0)
									{
										chapterCan = false;
									}
								}
								if(chapterCan)
								{
									activeStoryRed = true;
									break;
								}
							}
						}
						
					}
					//trace("小红点:"+activeStoryRed);
					Signal.intance.event(RedPointManager.STORY_MISSION_RED_CHANGE,activeStoryRed);
					break;
			}
		}
	}
}