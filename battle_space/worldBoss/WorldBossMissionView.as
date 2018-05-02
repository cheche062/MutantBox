package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossMissionUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.VoHasTool;
	import game.global.vo.mission.MissionVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class WorldBossMissionView extends BaseDialog
	{
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
//					formatListArray(args[1].list);
					// trace("missionList:", _Array);
					// 重新设置list数据源
					setCurDataByConf();
					setDataStatus(args[1]);
//					trace(JSON.stringify(args[1]));
					break;
				case ServiceConst.BOSS_MISSION_GET_REWARDS:
					// 重新渲染list
					WebSocketNetService.instance.sendData(ServiceConst.BOSS_MISSION_INIT);
				default:
					break;
			}
		}
		
		/**
		 *根据服务器数据，设置数据完成状态 
		 * 
		 */
		private function setDataStatus(args:Object):void
		{
			trace("服务器数据:"+JSON.stringify(args));
			// TODO Auto Generated method stub
			var kill:Number = args["kill"];
			var kill_task:Array = args["kill_task"];//已经领取任务的数组
			for(var i:int=_Array.length-1;i>=0;i--)
			{
				var vo:Object = _Array[i];
				vo["kill"]=args["kill"];
				vo["kill_task"]=args["kill_task"];
				if(kill_task.indexOf(vo.id)!=-1)//判断是否领取
				{
					vo["status"] = 2;//已领取
				}else
				{
					if(kill>=Number(vo.kill_number))
					{
						vo["status"] = 1;//已完成未领取
					}else
					{
						vo["status"] = 0;//未完成
					}
				}
			}
			trace("已经删选的任务数据:"+JSON.stringify(_Array));
			view.missionList.array=_Array;
		}
		// 列表数据源
		private var _Array:Array=[];
//		private function formatListArray(list:Object):void
//		{
//			_Array=[];
//			// format临时容器
//			var tmpArr:Array=[];
//			for (var id:String in list)
//			{
//				if (GameConfigManager.missionInfo[parseInt(id)])
//				{
//					tmpArr=list[id];
//					tmpArr.push(id);
//					_Array.push(tmpArr);
//				}
//				
//			}
//			
//			// 排序 ，没领的、没做的、领过的
//			var undoArr:Array=[];
//			var unClaimArr:Array=[];
//			var claimedArr:Array=[];
//			for (var i=0; i < _Array.length; i++)
//			{
//				switch (_Array[i][0])
//				{
//					case 0:
//						undoArr.push(_Array[i]);
//						break;
//					case 1:
//						unClaimArr.push(_Array[i]);
//						break;
//					case 2:
//						claimedArr.push(_Array[i]);
//						break;
//					default:
//						break;
//				}
//			}
//			// 如果没有没领的，隐藏主界面小红点
//			if (unClaimArr.length == 0)
//			{
//				Signal.intance.event(ArmyGroupEvent.HIDE_RED_DOT, [1]);
//			}
//			_Array=unClaimArr.concat(undoArr, claimedArr);
//		}
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
			trace("未筛选的任务数据:"+JSON.stringify(_Array));
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
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_INIT), this, this.onResultHandler, [ServiceConst.BOSS_MISSION_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_GET_REWARDS), this, this.onResultHandler, [ServiceConst.BOSS_MISSION_GET_REWARDS]);
			super.addEvent();
		}
		
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_INIT), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_MISSION_GET_REWARDS), this, this.onResultHandler);
			super.removeEvent();
		}
		
		private function get view():WorldBossMissionUI
		{
			_view = _view || new WorldBossMissionUI();
			return _view;
		}
	}
}