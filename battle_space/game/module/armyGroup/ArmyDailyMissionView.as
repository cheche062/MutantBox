package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyDailyMissionViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;

	/**
	 * 军团每日任务
	 * @author douchaoyang
	 *
	 */
	public class ArmyDailyMissionView extends BaseDialog
	{
		// 列表数据源
		private var _Array:Array=[];

		public function ArmyDailyMissionView()
		{
			super();
		}

		/**
		 * 数据请求回调函数
		 * @param cmd 请求参数
		 * @param args 服务器返回参数
		 *
		 */
		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.MISSION_INIT_DATA:
					formatListArray(args[1].list);
					// trace("missionList:", _Array);
					// 重新设置list数据源
					view.missionList.array=_Array;
					break;
				case ServiceConst.GET_MISSION_REWARD:
					// 重新渲染list
					WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["legion"]);
					
					var rewards = ToolFunc.reduceArrayFn(args[1], function(a, b){
						return a + b.join("=") + ";";
					}, "");
					
					ToolFunc.showRewardsHandler(rewards);
					
					break;
				default:
					break;
			}
		}

		/**
		 * 将返回的数据格式化为数组，并将任务id压到每个数组最后一位传给渲染项
		 * @param list 需要格式化的数据
		 *
		 */
		private function formatListArray(list:Object):void
		{
			_Array=[];
			// format临时容器
			var tmpArr:Array=[];
			for (var id:String in list)
			{
				if (GameConfigManager.missionInfo[parseInt(id)])
				{
					tmpArr=list[id];
					tmpArr.push(id);
					_Array.push(tmpArr);
				}

			}

			// 排序 ，没领的、没做的、领过的
			var undoArr:Array=[];
			var unClaimArr:Array=[];
			var claimedArr:Array=[];
			for (var i=0; i < _Array.length; i++)
			{
				switch (_Array[i][0])
				{
					case 0:
						undoArr.push(_Array[i]);
						break;
					case 1:
						unClaimArr.push(_Array[i]);
						break;
					case 2:
						claimedArr.push(_Array[i]);
						break;
					default:
						break;
				}
			}
			// 如果没有没领的，隐藏主界面小红点
			if (unClaimArr.length == 0)
			{
				Signal.intance.event(ArmyGroupEvent.HIDE_RED_DOT, [1]);
			}
			_Array=unClaimArr.concat(undoArr, claimedArr);
		}

		/**
		 * 处理点击逻辑
		 * @param e 点击源
		 *
		 */
		private function onClickHandler(e:Event):void
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

		override public function show(... args):void
		{
			super.show();
			// 动画进入
			AnimationUtil.flowIn(this);
			// 请求每日奖励列表数据
			WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["legion"]);
			// 每次打开之后，将列表位置初始化
			view.missionList.scrollTo(0);
		}

		override public function close():void
		{
			// 动画飞出
			AnimationUtil.flowOut(this, this.onCloseHandler);
			// 清空list
			_Array=[];
		}

		/**
		 * 动画飞出回调
		 *
		 */
		private function onCloseHandler():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}

		override public function createUI():void
		{
			this._view=new ArmyDailyMissionViewUI();
			this.addChild(_view);

			this._closeOnBlank=true;

			// 设置list渲染项
			view.missionList.itemRender=DailyMissionItem;
			view.missionList.vScrollBarSkin="";
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.onResultHandler, [ServiceConst.MISSION_INIT_DATA]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD), this, this.onResultHandler, [ServiceConst.GET_MISSION_REWARD]);

		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD), this, this.onResultHandler);
		}

		private function get view():ArmyDailyMissionViewUI
		{
			return _view as ArmyDailyMissionViewUI;
		}

	}

}
