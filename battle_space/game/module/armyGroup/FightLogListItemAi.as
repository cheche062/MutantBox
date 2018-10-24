package game.module.armyGroup
{
	import MornUI.armyGroup.FightLogListItemAiUI;

	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.vo.armyGroup.ArmyGroupCityVo;

	import laya.events.Event;

	/**
	 * 战斗记录中公会战记录渲染项
	 * @author douchaoyang
	 *
	 */
	public class FightLogListItemAi extends FightLogListItemAiUI
	{
		private const LANG_PACK:Array=[
			// 语言包
			"L_A_20907", // {0}对{1}所占领的{2}发起了宣战
			"L_A_20908", // {0}对中立星球{1}发起了宣战
			"L_A_20909", // {0}的战斗结束了，{1}工会成功攻克了星球
			"L_A_20910", // {0}的战斗结束了，{1}工会成功防守了星球
			"L_A_20911" // {0}的战斗结束了，{1}工会进攻失败
			];

		public function FightLogListItemAi()
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
			describeDom.innerHTML = getStringByData(data);
			timeTxt.text=data.create_time;
			goBtn.on(Event.CLICK, this, this.goCity, [parseInt(data.city_id)]);
			goBtn.visible = ArmyGroupMapView.open_planet_data[data.city_id];
		}

		/**
		 * 去哪座城市
		 * @param id
		 *
		 */
		private function goCity(id:int):void
		{
//			var cityData:ArmyGroupCityVo=GameConfigManager.ArmyGroupCityList[id];
			// 关闭当前界面
			XFacade.instance.closeModule(ArmyGroupFightLogView);
			Signal.intance.event(ArmyGroupEvent.JUMP_PLANT, [id]);
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
			var attack:String=GameLanguage.getLangByKey(data.attack_guild) || "";
			var defend:String=data.defend_guild || "";
			var city:String=GameLanguage.getLangByKey(ArmyGroupMapView.open_planet_data[data.city_id].name) || "";
			var arr:Array=[["<span style='color:#ff8b8b;font-weight:bold'>&nbsp;" + attack + "&nbsp;</span>", "<span style='color:#b4ff8b;font-weight:bold'>&nbsp;" + defend + "&nbsp;</span>", "<span style='font-weight:bold'>&nbsp;" + city + "&nbsp;</span>"], ["<span style='color:#ff8b8b;font-weight:bold'>&nbsp;" + attack + "&nbsp;</span>", "<span style='font-weight:bold'>&nbsp;" + city + "&nbsp;</span>"], ["<span style='font-weight:bold'>&nbsp;" + city + "&nbsp;</span>", "<span style='color:#ff8b8b;font-weight:bold'>&nbsp;" + attack + "&nbsp;</span>"], ["<span style='font-weight:bold'>&nbsp;" + city + "&nbsp;</span>", "<span style='color:#ff8b8b;font-weight:bold'>&nbsp;" + defend + "&nbsp;</span>"], ["<span style='font-weight:bold'>&nbsp;" + city + "&nbsp;</span>", "<span style='color:#ff8b8b;font-weight:bold'>&nbsp;" + attack + "&nbsp;</span>"]];
			var str:String=XUtils.getStringByLang(langId, arr[data.type - 1]);
			return "<div style='width:540px;font-size:24px;color:#ffdd9c'>" + str + "</div>";
			// return "<div style='width:540px;font-size:24px;color:#ffdd9c'><span style='color:#ff8b8b;font-weight:bold'>卡卡罗特</span>对<span style='color:#b4ff8b;font-weight:bold'>比克大魔王</span>所占领的<span style='font-weight:bold'>那美克星</span>发起了宣战</div>";
		}

		/**
		 * 设置显示什么旗子
		 * @param type 消息类型
		 *
		 */
		private function setFlagType(type:int):void
		{
			if (type == 1 || type == 2)
			{
				attackImg.visible=!(overImg.visible=false);
			}
			else
			{
				attackImg.visible=!(overImg.visible=true);
			}
		}
	}
}
