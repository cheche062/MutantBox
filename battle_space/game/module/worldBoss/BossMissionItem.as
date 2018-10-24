package game.module.worldBoss
{
	import MornUI.worldBoss.MissionItemUI;
	
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class BossMissionItem extends MissionItemUI
	{
		private var itemTemp:Vector.<ItemContainer>=new Vector.<ItemContainer>();
		public function BossMissionItem()
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
			
			var data:Array=value;
			// 按钮状态设置
			switch (data["status"])
			{
				case 1://未完成
					getBtn.visible=!(alreadyGet.visible=false);
					getBtn.disabled=true;
					break;
				case 0://已完成,未领取
					getBtn.visible=!(alreadyGet.visible=false);
					getBtn.disabled=false;
					break;
				case 2://已领取
					getBtn.visible=!(alreadyGet.visible=true);
					break;
				default:
					break;
			}
			if(Number(data["kill"])>=Number(data.kill_number))
			{
				data["kill"] = Number(data.kill_number);
			}
			
			rewardDiscrible.text="("+data["kill"]+"/"+ data.kill_number+")"+
				GameLanguage.getLangByKey(data.language).replace("{0}", data.kill_number);

			// 设置任务奖励
			setRewardHandler(data.reward);
			// 设置领取按钮
			getBtn.on(Event.CLICK, this, this.onGetHandler, [parseInt(data.id)]);
			
		}
		private function setRewardHandler(str:String):void
		{
			var data:Array=str.split(";");
			for(var j=itemTemp.length-1; j >= 0; j--)
			{
				this.removeChild(itemTemp[j]);
				itemTemp.splice(j,1);
			}
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
				itemTemp[i].setData(info[0], info[1]);
			}
		}
		/**
		 * 当点击领取按钮的时候
		 * @param id 任务id
		 *
		 */
		private function onGetHandler(id:int):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BOSS_MISSION_GET_REWARDS, [id]);
		}
		override public function destroy(destroyChild:Boolean=true):void
		{
			super.destroy(destroyChild);
			getBtn.off(Event.CLICK, this, this.onGetHandler);
		}
	}
}