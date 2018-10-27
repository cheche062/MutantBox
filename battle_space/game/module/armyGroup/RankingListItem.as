package game.module.armyGroup
{
	import MornUI.armyGroup.RankingListItemUI;

	import game.common.ItemTips;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.module.bingBook.ItemContainer;

	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;

	public class RankingListItem extends BaseView
	{
		private var goodArr:Vector.<ItemContainer>=new Vector.<ItemContainer>(3);
		private var textArr:Vector.<TextArea>=new Vector.<TextArea>(3);

		public function RankingListItem()
		{
			super();
		}

		// 设置渲染的数据项
		public function set renderData(value:*):void
		{
			var data:Object=Object(value);
			// 排行
			view.rank.text=data.rank;
			// 名字
			view.name.text=data.nickname || "-";
			// 公会名
			view.group.text=data.guildname || "-";
			// 击杀数
			view.kill.text=data.killnum || "-";

			if (data.isTotal == false)
			{
				// 奖励
				// trace("rank", data.rank);
				setRewardVisible(true);
				initRewardHandler(data.rank);
				view.name.x=100;
				view.group.x=300;
				view.kill.x=500;
			}
			else if (data.isTotal == true)
			{
				setRewardVisible(false);
				view.name.x=150;
				view.group.x=400;
				view.kill.x=700;
			}
		}

		private function setRewardVisible(flag:Boolean):void
		{
			var i:int;
			if (flag == true)
			{
				for (i=0; i < 3; i++)
				{
					if (!goodArr[i] || !textArr[i])
						continue;
					goodArr[i].visible=true;
					textArr[i].visible=true;
				}
			}
			else if (flag == false)
			{
				for (i=0; i < 3; i++)
				{
					if (!goodArr[i] || !textArr[i])
						continue;
					goodArr[i].visible=false;
					textArr[i].visible=false;
				}
			}
		}

		// 把奖励塞进去
		private function initRewardHandler(index:int):void
		{
			var data:Array=String(GameConfigManager.ArmyGroupRankList[index].JL).split(";");
			var len:int=data.length;
			for (var i=0; i < 3; i++)
			{
				if (!goodArr[i])
				{
					goodArr[i]=new ItemContainer();
					goodArr[i].name=i;
					goodArr[i].scaleX=goodArr[i].scaleY=0.5;
					goodArr[i].y = 0;
					goodArr[i].numTF.visible = false;
					goodArr[i].needBg = false;
					view.addChild(goodArr[i]);
				}
				if (!textArr[i])
				{
					textArr[i]=new TextArea();
					textArr[i].font="Futura";
					textArr[i].fontSize=22;
					textArr[i].color="#ffda80";
					textArr[i].mouseEnabled=false;
					textArr[i].y=13;
					view.addChild(textArr[i]);
				}
				if (data[i])
				{
					goodArr[i].visible=true;
					textArr[i].visible=true;
					var info:Array=String(data[i]).split("=");
					
					goodArr[i].setData(info[0]);
					textArr[i].text="x" + XUtils.formatResWith(info[1]);
				}
				else
				{
					goodArr[i].visible=false;
					textArr[i].visible=false;
				}

				goodArr[i].x=690 + 104 * i;
				textArr[i].x=728 + 104 * i;

				// 居中
//				switch (len)
//				{
//					case 1:
//						goodArr[i].x=824;
//						textArr[i].x=862;
//						break;
//					case 2:
//						goodArr[i].x=740 + 104 * i;
//						textArr[i].x=778 + 104 * i;
//						break;
//					case 3:
//						goodArr[i].x=690 + 104 * i;
//						textArr[i].x=728 + 104 * i;
//						break;
//				}
			}
		}

		override public function createUI():void
		{
			_view=new RankingListItemUI();
			this.addChild(_view);
			view.cacheAsBitmap=true;
		}

		private function get view():RankingListItemUI
		{
			return _view as RankingListItemUI;
		}
	}
}
