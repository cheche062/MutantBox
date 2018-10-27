package game.module.armyGroup
{
	import MornUI.armyGroup.FightLogListItemBiUI;

	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;

	/**
	 * 战斗记录中个人记录渲染项
	 * @author douchaoyang
	 *
	 */
	public class FightLogListItemBi extends FightLogListItemBiUI
	{
		private const LANG_PACK:Array=[
			// 语言包
			"L_A_20922", // {0}的战斗结束了,防御成功，你击杀了{1}人
			"L_A_20923", // {0}的战斗结束了,防御失败，你击杀了{1}人
			"L_A_20924", // {0}的战斗结束了,进攻成功，你击杀了{1}人
			"L_A_20925" // {0}的战斗结束了,进攻失败，你击杀了{1}人
			];

		private var itemVo:Vector.<ItemContainer>=new Vector.<ItemContainer>();

		public function FightLogListItemBi()
		{
			super();
		}

		override public function set dataSource(value:*):void
		{
			var data:Object=value;
			if (!data)
			{
				return;
			}
			setFlagType(data.type);
			timeTxt.text=data.create_time;
			describeTxt.text=getStringByData(data);
			setReaward(data.reward);
		}

		/**
		 * 设置奖励
		 * @param arr 服务器返回奖励数据
		 *
		 */
		private function setReaward(arr:Array):void
		{
			if (arr.length == 0)
			{
				loseTxt.visible=true;
			}
			else
			{
				loseTxt.visible=false;
				for (var i=0; i < arr.length; i++)
				{
					if (!itemVo[i])
					{
						itemVo[i]=new ItemContainer();
						itemVo[i].y=100;
						itemVo[i].x=310 + 80 * i;
						this.addChild(itemVo[i]);
					}
					itemVo[i].setData(String(arr[i][0]), parseInt(arr[i][1]));
				}
			}
		}

		/**
		 * 返回需要的描述文字
		 * @param type 消息体
		 * @return DOM字符串
		 *
		 */
		private function getStringByData(data:Object):String
		{
			var langId:*=LANG_PACK[data.type - 1];
			var city:String=GameLanguage.getLangByKey(ArmyGroupMapView.open_planet_data[data.city_id].name) || "";
			var str:String=XUtils.getStringByLang(langId, [city, data.kill_number]);
			return str;
		}

		/**
		 * 设置显示什么旗子
		 * @param type 消息类型
		 *
		 */
		private function setFlagType(type:int):void
		{
			if (type == 1 || type == 3)
			{
				winImg.visible=!(loseImg.visible=false);
			}
			else
			{
				winImg.visible=!(loseImg.visible=true);
			}
		}
	}
}
