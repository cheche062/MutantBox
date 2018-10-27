package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossMissionUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class WorldBossMissionView extends BaseDialog
	{
		/**已领取的*/
		private var alreadyKillTask:Array = []; 
		
		public function WorldBossMissionView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					close();
					break;
				
				default:
					break;
			}
		}
		
		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd) {
				case ServiceConst.BOSS_MISSION_INIT:
					alreadyKillTask = [].concat(args[0]["kill_task"]);
					// 重新设置list数据源
					setCurDataByConf();
					setDataStatus(args[0]);
					
//					trace("alreadyKillTask", alreadyKillTask);
					
					break;
				case ServiceConst.BOSS_MISSION_GET_REWARDS:
					showRewards(alreadyKillTask, args[0]["kill_task"]);
					
					// 重新渲染list
					WebSocketNetService.instance.sendData(ServiceConst.BOSS_MISSION_INIT);
					
				default:
					break;
			}
		}
		
		/**弹出层展示奖品*/
		private function showRewards(oldTask, newTask):void {
			var id = ToolFunc.find(newTask, function(item){
				return oldTask.indexOf(item) == -1;
			});
			var resultData =ResourceManager.instance.getResByURL("config/p_boss/p_boss_mission.json");
			var targetData = ToolFunc.getTargetItemData(resultData, 'id', id);
			var reward:String = targetData["reward"];
			
			ToolFunc.showRewardsHandler(reward);
		}
		
		/**
		 *根据服务器数据，设置数据完成状态 
		 * 
		 */
		private function setDataStatus(args:Object):void
		{
//			trace("服务器数据:"+JSON.stringify(args));
			// TODO Auto Generated method stub
			var kill:Number = args["kill"];
			var kill_task:Array = args["kill_task"];//已经领取任务的数组
//			trace("");
			for(var i:int=_Array.length-1;i>=0;i--)
			{
				var vo:Object = _Array[i];
				vo["kill"]=args["kill"];
				vo["kill_task"]=args["kill_task"];
//				trace("vo.id="+vo.id);
//				trace("已完成数组:"+JSON.stringify(kill_task));
				for(var j:int=0;j<kill_task.length;j++)
				{
					if(kill_task[j]==vo.id)
					{
						vo["status"] = 2;//已领取
						break;
					}
				}
				if(vo["status"]&&vo["status"]==2)
				{
					
				}else
				{
						if(kill>=Number(vo.kill_number))
						{
							vo["status"] = 0;//已完成未领取
						}else
						{
							vo["status"] = 1;//未完成
						}
				}
			}
			_Array.sort(function (a:*,b:*):Number{return a.status-b.status});
//			trace("已经删选的任务数据:"+JSON.stringify(_Array));
			view.missionList.array=_Array;
		}
		// 列表数据源
		private var _Array:Array=[];

		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		public static var killMission:Object={};
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
//			setCurDataByConf();
		
//			trace("kill配置:"+JSON.stringify(killMission));
			WebSocketNetService.instance.sendData(ServiceConst.BOSS_MISSION_INIT);
			// 每次打开之后，将列表位置初始化
			view.missionList.scrollTo(0);
			
		}
		
		/**
		 *根据大本营等级筛选任务数据 
		 * 
		 */
		private function setCurDataByConf():void
		{
			var mvo:Object=ResourceManager.instance.getResByURL("config/p_boss/p_boss_mission.json");
			var curBaseLV:Number = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BASE);
			_Array=[];
			if (mvo)
			{
				for each (var c:* in mvo)
				{
					//					vo=VoHasTool.hasVo(killMission, c)
					killMission[c.id]=c;
//					trace("c"+JSON.stringify(c));
//					trace("配置等级:"+c.level);
//					trace("大本营等级:"+curBaseLV);
					if(Number(c.level)==curBaseLV)
					{
						_Array.push(c);
					}
				}
			}
//			trace("未筛选的任务数据:"+JSON.stringify(_Array));
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
			_Array=[];
		}
		
		private function onClose():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}
		
		override public function createUI():void
		{
			this._view=new WorldBossMissionUI();
			this.addChild(_view);
			
			this._closeOnBlank=true;
			
			// 设置list渲染项
			view.missionList.itemRender=BossMissionItem;
			view.missionList.vScrollBarSkin="";
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_INIT), this, onResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_GET_REWARDS), this, onResultHandler);
			super.addEvent();
		}
		
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_INIT), this, onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_GET_REWARDS), this, onResultHandler);
			super.removeEvent();
		}
		
		private function get view():WorldBossMissionUI
		{
			_view = _view || new WorldBossMissionUI();
			return _view;
		}
	}
}