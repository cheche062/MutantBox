package game.module.armyGroup
{
	import MornUI.armyGroup.KilledChildViewUI;

	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.UIUtils;

	/**
	 * 军团个人击杀进度
	 * @author douchaoyang
	 *
	 */
	public class KilledChildView extends BaseView
	{
		// 奖励临时存储容器
		private var itemBox:Vector.<ItemContainer>=new Vector.<ItemContainer>(9);
		// 设置不同阶段奖励的状态
		private var stateArr:Vector.<Boolean>=new Vector.<Boolean>(3);

		// 击杀阶段
		private var killPeriod:Array=[];
		// 奖励容器
		private var killReward:Array=[];

		public function KilledChildView()
		{
			super();
		}

		/**
		 * 写入数据表数据
		 *
		 */
		private function getExcelHandler():void
		{
			// 置空数据
			killPeriod=[];
			killReward=[];
			var data=GameConfigManager.ArmyGroupKillReList;
			var level:int=parseInt(User.getInstance().level);
			// trace("数据表数据：", data);
			for (var attr in data)
			{
				killPeriod.push(parseInt(attr)); // 塞击杀阶段

				for (var i=0; i < data[attr].length; i++)
				{
					if (level >= data[attr][i].DJ1 && level <= data[attr][i].DJ2)
					{
						killReward.push(data[attr][i].JL); // 塞奖励
						break;
					}
				}
			}
		}

		/**
		 * 设置三个面板以及奖励是否可领取的状态
		 * @param num 击杀数
		 * @param arr 已经领取过的阶段
		 *
		 */
		private function setRewardState(num:int, arr:Array):void
		{
			// 首先将面板上的击杀数设置好
			view.killedNum.text=num;
			for (var i=0; i < killPeriod.length; i++)
			{
				view["step" + i + "Txt"].text=("KILL: " + killPeriod[i]);
				// 面板是否灰色
				view["step" + i + "Box"].gray=!(num >= killPeriod[i]);

				// 奖励是否已经领取
				stateArr[i]=!(arr.indexOf(killPeriod[i]) < 0);

				if (num < killPeriod[0])
				{
					view.claimBtn.disabled=true;
				}

				if (num >= killPeriod[i])
				{
					view.claimBtn.disabled=stateArr[i];
				}
			}
		}

		/**
		 * 显示奖励
		 *
		 */
		private function showLevelReward():void
		{
			for (var i=0; i < killReward.length; i++)
			{
				setRewardPos(i, killReward[i], view["step" + i + "Box"], stateArr[i]);
			}
		}

		/**
		 * 设置奖励的位置
		 * @param sid 属于哪一个盒子
		 * @param reward 奖励
		 * @param box 要添加奖励的盒子
		 * @param isget 奖励是否已经获得
		 *
		 */
		private function setRewardPos(id:int, reward:String, box:Box, isget:Boolean):void
		{
			if (reward)
			{
				var data:Array=reward.split(";");
				var len:int=data.length;
				for (var i=0; i < len; i++)
				{
					var info:Array=String(data[i]).split("=");
					var sid:int=id * 3 + i;
					if (!itemBox[sid])
					{
						itemBox[sid]=new ItemContainer();
						box.addChild(itemBox[sid]);
					}
					itemBox[sid].setData(info[0], info[1]);
					UIUtils.clearFilter(itemBox[sid], ColorFilter);
					UIUtils.gray(itemBox[sid], isget);
					if (isget && !itemBox[sid].getChildByName("okImage"))
						itemBox[sid].addChild(okIcon);
					// 设置位置
					switch (i)
					{
						case 0:
							itemBox[sid].x=77;
							itemBox[sid].y=94;
							break;
						case 1:
							itemBox[sid].x=(len == 2 ? 77 : 34);
							itemBox[sid].y=180;
							break;
						case 2:
							itemBox[sid].x=120;
							itemBox[sid].y=180;
							break;
						default:
							break;
					}
				}

			}
			else
			{
			}
		}

		override public function createUI():void
		{
			_view=new KilledChildViewUI();
			this.addChild(_view);
			addEvent();
		}

		override public function show(... args):void
		{
			super.show(args);
		}

		override public function close():void
		{

		}

		private function addToStageEvent():void
		{
			// 请求面板数据
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, this.onResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD), this, this.onResultHandler);


		}

		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD), this, this.onResultHandler);
		}

		override public function removeEvent():void
		{
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			view.claimBtn.off(Event.CLICK, this, this.onClaimClick);
		}

		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);

			view.claimBtn.on(Event.CLICK, this, this.onClaimClick);
		}

		private function onClaimClick():void
		{
			// 领取奖励
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD);
		}

		private function onResultHandler(...args):void
		{
			switch (args[0])
			{
				case ServiceConst.ARMY_GROUP_GET_ROLLKILL:
					// 拿数据表数据
					getExcelHandler();
					// 首先设置好状态
					setRewardState(args[1].kill_number, args[1].get_log);
					// 然后设置添加奖励
					showLevelReward();
					break;
				
				case ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD:
					var arr:Array=[];
					var list:Array=args[2];
					for (var i=0; i < list.length; i++)
					{
						var item:ItemData=new ItemData();
						item.iid=list[i].id;
						item.inum=list[i].num;
						arr.push(item);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [arr]);
					// 更新面板状态
					// setRewardState(args[1], args[3]);
					// showLevelReward(getLevelId());
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL);
					break;
				default:
					break;
			}
		}

		private function get view():KilledChildViewUI
		{
			return _view as KilledChildViewUI;
		}

		/**
		 * 添加一个完成的图标
		 * @return 返回图片
		 *
		 */
		private function get okIcon():Image
		{
			var img:Image=new Image("appRes/icon/failureIcon/icon_finish.png");
			img.name="okImage";
			return img;
		}
	}
}
