package game.module.armyGroup
{
	import MornUI.armyGroup.DailyMissionItemUI;

	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;

	/**
	 * 军团每日任务渲染项
	 * @author douchaoyang
	 *
	 */
	public class DailyMissionItem extends DailyMissionItemUI
	{
		private var itemTemp:Vector.<ItemContainer>=new Vector.<ItemContainer>();

		public function DailyMissionItem()
		{
			super();
		}

		/**
		 * 重写每个渲染项数据渲染方法
		 * @param value 数据源
		 *
		 */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				rewardDiscrible.text="";
				return;
			}
			
			var len:int = itemTemp.length;
			for (var i:int = 0; i < len; i++) 
			{
				itemTemp[i].visible = false;
			}
			
			var data:Array=value;
			// 按钮状态设置
			switch (data[0])
			{
				case 0:
					getBtn.visible=!(alreadyGet.visible=false);
					getBtn.disabled=true;
					break;
				case 1:
					getBtn.visible=!(alreadyGet.visible=false);
					getBtn.disabled=false;
					break;
				case 2:
					getBtn.visible=!(alreadyGet.visible=true);
					break;
				default:
					break;
			}

			var missionData:Object=GameConfigManager.missionInfo[parseInt(data[data.length - 1])];

			if (missionData)
			{
				//trace("收到的数据：", data);
				// 设置任务描述
				var _currentNum = (data[1].length != 0) ? data[1][1][0] : "0";
				rewardDiscrible.text = "(" + _currentNum + "/" + missionData.canshu1 + ")" +
					GameLanguage.getLangByKey(missionData.describe).replace("{0}", missionData.canshu1);
				
				// 设置任务奖励
				setRewardHandler(missionData.reward, missionData.fl);
			}


			// 设置领取按钮
			getBtn.on(Event.CLICK, this, this.onGetHandler, [parseInt(data[data.length - 1])]);

		}

		private function setRewardHandler(str:String, fl:int):void
		{
			var data:Array=str.split(";");
			for (var i=0; i < data.length; i++)
			{
				var info:Array=data[i].split("=");
				if (!itemTemp[i])
				{
					itemTemp[i]=new ItemContainer();
					this.addChild(itemTemp[i]);
					itemTemp[i].y=15;
					itemTemp[i].x=380 + 80 * i;
				}
				
				itemTemp[i].visible = true;
				
				if (fl == 1 && GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + info[0]])
				{
					itemTemp[i].setData(info[0], Math.ceil(info[1] * GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + info[0]]));
				}
				else
				{
					itemTemp[i].setData(info[0], info[1]);
				}
			}
		}

		/**
		 * 当点击领取按钮的时候
		 * @param id 任务id
		 *
		 */
		private function onGetHandler(id:int):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD, ['daily', id]);
		}

		override public function destroy(destroyChild:Boolean=true):void
		{
			super.destroy(destroyChild);
			getBtn.off(Event.CLICK, this, this.onGetHandler);
		}
	}
}
