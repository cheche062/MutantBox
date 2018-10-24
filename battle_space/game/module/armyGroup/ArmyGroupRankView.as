package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupRankViewUI;

	import game.common.AnimationUtil;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Button;

	/**
	 * 军团排行榜主界面
	 * @author douchaoyang
	 *
	 */
	public class ArmyGroupRankView extends BaseDialog
	{
		// 当前v点击的按钮
		private var curBtn:Button;
		
		// 设置不同阶段奖励的状态
		private var stateArr:Vector.<Boolean>=new Vector.<Boolean>(3);

		private var rankingTemplete:RankingChildView;
		private var killedTemplete:KilledChildView;
		private var groupTemplete:GroupChildView;

		public function ArmyGroupRankView()
		{
			super();
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
				// 点击关闭按钮
				case view.closeBtn:
					this.close();
					break;
				// 点击上方切换按钮
				case view.rankingBtn:
//				case view.killedBtn:
				case view.groupBtn:
					// 执行切换逻辑
					changeViewHandler(e.target);
					break;
				default:
					break;
			}
		}

		/**
		 * 点击上方的切换按钮 ，执行切换方法
		 * @param target 点击的按钮
		 *
		 */
		private function changeViewHandler(target:Button):void
		{
			// 如果点击的是当前按钮 ，不做操作
			if (curBtn == target)
			{
				return;
			}
			// 将当前按钮置为点击的按钮
			curBtn=target;
			// 高亮当前按钮
			lightCurBtn(target);
			// 清空当前的viewContainer
			view.viewContainer.removeChildren();
			// 实现切换逻辑
			switch (target)
			{
				case view.rankingBtn:
					!rankingTemplete && (rankingTemplete=new RankingChildView());
					view.viewContainer.addChild(rankingTemplete);
					break;
				
				case view.groupBtn:
					!groupTemplete && (groupTemplete=new GroupChildView());
					view.viewContainer.addChild(groupTemplete);
					break;
				default:
					break;
			}
			
		}

		/**
		 * 高亮当前按钮，并将当前按钮的层级提高
		 * @param target 需要高亮的按钮
		 *
		 */
		private function lightCurBtn(target:Button):void
		{
			view.rankingBtn.selected=false;
			view.rankingBtn.zOrder=0;
//			view.killedBtn.selected=false;
//			view.killedBtn.zOrder=0;
			view.groupBtn.selected=false;
			view.groupBtn.zOrder=0;
			target.selected=true;
			target.zOrder=1;
			
		}

		override public function show(... args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			// 初始化界面信息，手动触发ranking按钮，先高亮ranking按钮，显示ranking界面
			changeViewHandler(view.rankingBtn);

			// 为了小红点
//			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_RANK, [4]);
//			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_RANK, [3]);
//			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL);
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, this.onClose);
		}

		private function onClose():void
		{
			super.close();
			// 清空界面信息，清空viewContainer，置空当前按钮、当前view
			curBtn=null;
			view.viewContainer.removeChildren();
			XFacade.instance.disposeView(this);
		}

		override public function createUI():void
		{
			this.addChild(view);
			this.closeOnBlank=true;

			UIRegisteredMgr.AddUI(view.closeBtn, "AG_rCloseBtn");
//			UIRegisteredMgr.AddUI(view.killedBtn, "AG_killTab");
		}

		private function onResultHandler(...args):void
		{
			// cmd
			switch (args[0])
			{
				case ServiceConst.ARMY_GROUP_GET_RANK:
					if (typeof args[3] != "undefined")
						view.redDot1.visible=!!args[3];
					break;
				case ServiceConst.ARMY_GROUP_GET_ROLLKILL:
					setRedState(args[1].kill_number, args[1].get_log);
					break;
				default:
					break;
			}
			if (!view.redDot1.visible /*&& !view.redDot2.visible*/)
			{
				Signal.intance.event(ArmyGroupEvent.HIDE_RED_DOT, [3]);
			}
		}

		private function setRedState(num:int, arr:Array):void
		{
			// 击杀阶段划分
			var killPeriod:Array=[];
			var data=GameConfigManager.ArmyGroupKillReList;
			for (var attr in data)
			{
				killPeriod.push(parseInt(attr));
			}
			for (var i=0; i < killPeriod.length; i++)
			{
				// 奖励是否已经领取
				stateArr[i]=!(arr.indexOf(killPeriod[i]) < 0);
//				
			}
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_RANK), this, this.onResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, this.onResultHandler);
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_RANK), this, this.onResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, this.onResultHandler);
		}

		private function get view():ArmyGroupRankViewUI
		{
			_view = _view || new ArmyGroupRankViewUI();
			return _view;
		}
	}

}
