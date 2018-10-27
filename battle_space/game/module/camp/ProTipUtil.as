package game.module.camp
{
	import MornUI.componets.DataComUI;
	
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.FightUnitVo;
	import game.module.tips.ArmorTip;
	import game.module.tips.PropertyTip;
	
	import laya.display.Node;

	/**
	 * ProTipUtil 给soldier/hero属性设置tip 移除tip
	 * author:huhaiming
	 * ProTipUtil.as 2017-4-19 下午5:16:20
	 * version 1.0
	 *
	 */
	public class ProTipUtil
	{
		private static var tipDic:Object = 
		{
			"hp":[733,703],//语言包
			"defense":{1:[718,719],2:[716,717],3:[714,715],4:[712,713]},//防御
			"attack":{1:[706,707],2:[708,709],3:[704,705],4:[710,711]},//攻击
			"speed":[734,720],
			"hit":[721,722],
			"dodge":[723,724],
			"crit":[725,726],
			"critDamage":[727,728],
			"resilience":[729,730],
			"critDamReduct":[731,732]
		}
		private static var iconDic:Object = 
			{
				"hp":"HP_a",
				"attack":"ATK_a",
				"defense":"DEF_a",
				"speed":"SPEED_a",
				"hit":"hit_a",
				"dodge":"dodge_a",
				"crit":"crit_a",
				"critDamage":"CDMG_a",
				"resilience":"RES_a",
				"critDamReduct":"CDMGR_a"
			}
		private static var proArr:Array = ["hp","attack","defense","speed","hit","dodge","critDamage","crit","resilience","critDamReduct"]
		private static const PRO_NUM:int = 10;
		public function ProTipUtil()
		{
			
		}
		
		/**生成一组TIP*/
		public static function addTip(ui:*,data:Object,byName:Boolean = false):void{
			var unitId:* = data.unitId || data.unit_id
			var obj:Object = GameConfigManager.unit_json[unitId];
			var info:Object;
			for(var i:int=0; i<PRO_NUM; i++){
				var target:* = byName ? (ui as Node).getChildByName("icon_"+i) : ui["icon_"+i];
				switch(i){
					case 0:
						info = {};
						info.name = GameLanguage.getLangByKey("L_A_"+tipDic["hp"][0]);
						info.des = GameLanguage.getLangByKey("L_A_"+tipDic["hp"][1]);
						info.icon = iconDic["hp"];
						XTipManager.addTip(target, info,PropertyTip);
						break;
					case 1:
						//XTipManager.addTip(ui["icon_"+i],getTipStr(tipDic[proArr[i]][obj.defense_type],proArr[i], data),PropertyTip);
						info = {};
						info.name = GameLanguage.getLangByKey("L_A_741");
						info.des = GameLanguage.getLangByKey("L_A_742");
						info.icon = iconDic["attack"]
						XTipManager.addTip(target, info,PropertyTip);
						break;
					case 2:
						//XTipManager.addTip(ui["icon_"+i],getTipStr(tipDic[proArr[i]][obj.attack_type],proArr[i], data),PropertyTip);
						info = {};
						info.name = GameLanguage.getLangByKey("L_A_743");
						info.des = GameLanguage.getLangByKey("L_A_744");
						info.icon = iconDic["defense"]
						XTipManager.addTip(target, info,PropertyTip);
						break;
					case 3:
						info = {};
						info.name = GameLanguage.getLangByKey("L_A_"+tipDic["speed"][0]);
						info.des = GameLanguage.getLangByKey("L_A_"+tipDic["speed"][1]);
						info.icon = iconDic["speed"]
						XTipManager.addTip(target, info,PropertyTip);
						break;
					default:
						XTipManager.addTip(target,getTipStr(tipDic[proArr[i]],proArr[i], data),PropertyTip);
						break;
				}
			}
		}
		
		/**显示攻击TIP*/
		public static function showAttTip(uid:String):void{
//			var data:Object = CampData.getUintById(uid);
			var vo:Object = GameConfigManager.unit_dic[uid]
			var attack_type:String = vo.attack_type
//			XTipManager.showTip(getTipStr(tipDic["attack"][attack_type],"attack"), ArmorTip);
			showAoDtip(1,attack_type);
		}
		
		/**显示防御TIP*/
		public static function showDenTip(uid:String):void{
//			var data:Object = CampData.getUintById(uid);
			var vo:Object = GameConfigManager.unit_dic[uid]
			var defense_type:String = vo.defense_type;
//			var info:Object = getTipStr(tipDic["defense"][defense_type],"defense");
//			info.defend = true;
//			XTipManager.showTip(info, ArmorTip);
			showAoDtip(2,defense_type);
		}
		
		
		/**显示TIPS*/
		public static function showAoDtip(type:Number , subType:Number):void
		{
			var typeKey:String = type == 1 ? "attack" : "defense";
			var info:Object = getTipStr(tipDic[typeKey][subType],typeKey);
			info.defend = type == 2;
			XTipManager.showTip(info, ArmorTip);
		}
		
		private static function getTipStr(arr:Array, key:String, data:Object = null):Object{
			var str:String = "";
			var tipInfo:Object = {};
			tipInfo.name = GameLanguage.getLangByKey("L_A_"+arr[0])
			
			for(var i:uint=1; i<arr.length; i++){
				if(str != ""){
					str += "\n"
				}
				str+= GameLanguage.getLangByKey("L_A_"+arr[i])
			}
			str = str.replace(/##/g,"<br>");
			str = str.replace(/_x000\D_/g,"");
			
			tipInfo.des = str
			tipInfo.icon = iconDic[key];
			/*hit_rate	\$param1/(100*\$param2+900)+0.95
			dodge_rate	\$param1/(100*\$param2+950)
			crit_rate	\$param1/(100*\$param2+900)
			resilience_rate	\$param1/(100*\$param2+900)
			critical_damage_rate	\$param1/(100*\$param2+900)+1.5
			critical_damage_reduction_rate	\$param1/(100*\$param2+900)*/
			var rate:Number=0;
			var lv:Number = 1;
			var value:Number = 0;
			if(data)
			{
				if(data.hasOwnProperty(key)){
					value = data[key]
				}else{
					value = data[XUtils.getIconName(key)]
				}
				
				if(data.hasOwnProperty("level"))
				{
					lv = data.level;
				}
				
				switch(key){
					case "hit":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+900)+0.95)*1000))/10
						break;
					case "dodge":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+950)+0)*1000))/10
						break;
					case "crit":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+900)+0)*1000))/10
						break;
					case "resilience":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+900)+0)*1000))/10
						break;
					case "critDamage":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+900)+1.5)*1000))/10
						break;
					case "critDamReduct":
						rate = Math.round((((data[key] || data[XUtils.getIconName(key)])/(100*lv+900)+0)*1000))/10
						break;
				}
			}
			
			
			tipInfo.name = tipInfo.name.replace(/{(\d+)}/,rate);
			tipInfo.des = tipInfo.des.replace(/{(\d+)}/,rate);
			
			return tipInfo;
		}
		
		/***/
		public static function removeTip(ui:*):void{
			for(var i:int=0; i<PRO_NUM; i++){
				XTipManager.removeTip(ui["icon_"+i]);
			}
		}
	}
}