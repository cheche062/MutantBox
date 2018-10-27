package game.module.armyGroup.newArmyGroup
{
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.util.TimeUtil;
	import game.global.vo.User;

	/**
	 * 星球数据
	 * @author hejianbo
	 * 
	 */
	public class StarVo
	{
		/**id*/
		public var id:String;
		/**是否从后端更新过*/
		public var isServerUpdated:Boolean = false;
		/**是否是我的公会下的城池*/
		public var isMyGuilde:Boolean = false;
		/**是否是我的公会进攻的城池*/
		public var isMyGuilde_Atk:Boolean = false;
		/**城池名称*/
		public var name:String;
		/**星系内顺序编号*/
		public var sequence:String;
		/**星球icon*/
		public var icon:String;
		/**所属星系ID*/
		public var block:String;
		/**所属星系的单位坐标*/
		public var cor:String;
		/**星球的状态 0正常 1战斗*/
		public var state:int;
		/**星球的等级*/
		public var city_level:int;
		/**相邻城池*/
		public var xlcc:String;
		/**可购买保护次数（天）*/
		public var attempts:String;
		/**城池类型（4小城，3中城，2大城，1巨型城市）*/
		public var type:String;
		/**npc初始等级*/
		public var level:String;
		/**星球npc*/
		public var npc_num:String;
		/**宣战消耗*/
		public var cost:String;
		/**战胜积分*/
		public var integral:String;
		/**发奖时间*/
		public var access_time:String;
		/**产出*/
		public var planet_sp:String;
		/**奖励*/
		public var award:String;
		/**是否是npc部队进攻*/
		public var isBudui_Atk:Boolean;
		/**是否是npc部队*/
		public var isBudui:Boolean;
		/**结束战斗的时间*/
		public var end_war_time:int;
		/**正式开战时间*/
		public var last_fight_time:int;
		
		/**是否易主*/
		public var is_change:int;
		
		public var guild_id:String;
		public var guideName:String;
		public var guideIcon:String;
		
		/**进攻方的公会信息*/
		public var atk_guild_id:String;
		public var atk_guideName:String;
		public var atk_guideIcon:String;
		
		/**仅表示购买的保护时间*/
		public var protection_time:String;
		public var add_level:String;
		public var buy_protection_number:String;
		
		public function StarVo()
		{
			
		}
		
		public function init(data):void {
			for (var key in data) {
				if (this.hasOwnProperty(key)) {
					this[key] = data[key];
				}
			}
		}
		
		/**进入地图·服务端数据合并处理*/
		public function serverDataEnter(data):void {
			isServerUpdated = true;
			
			init(data);
			
			isMyGuilde = (guild_id == User.getInstance().guildID && !!guild_id);
			isMyGuilde_Atk = (!!data.declare_war_guild &&data.declare_war_guild == User.getInstance().guildID );
			isBudui = data.guild_id.split("_")[0] == "budui";
			if(data.declare_war_guild){
				isBudui_Atk = data.declare_war_guild.split("_")[0] == "budui";
			}
			else{
				isBudui_Atk = false;
			}
			
			var info = getGuildNameAndIconByGuildId(data.guild_id, data.guild_info);
			guideName = info[0];
			guideIcon = info[1];
			if(data.atk_guild_info && data.declare_war_guild){
				atk_guideName = data.atk_guild_info.name;
				atk_guideIcon = data.atk_guild_info.icon;
			}
		}
		
		/**获取城池信息的数据更新*/
		public function getCityInfoUpdate(data):void {
			level = data.cityLevel;
			protection_time = data.protection_time;
			state = data.cityState;
			end_war_time = data.end_war_time;
		}
		
		/**获取城池状态 0正常 1战斗 2保护*/
		public function getCityState():int {
			if(state == 1) return 1;
			if (TimeUtil.nowServerTime - Number(protection_time) < 0) return 2;
			if (TimeUtil.nowServerTime - (end_war_time + getAutoProtect() * 60) < 0) return 2;
			return 0;
		}
		
		private function getAutoProtect():int {
			var juntuan_canshu = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
			return is_change ? Number(juntuan_canshu['5'].value) : Number(juntuan_canshu['6'].value); 
		}
		
		/**获取保护倒计时的时间*/
		public function getProtectCountDownTime():int {
			var t1 = Number(protection_time) - TimeUtil.nowServerTime;
			if (t1 > 0) return t1;
			var t2 = (end_war_time + getAutoProtect() * 60) - TimeUtil.nowServerTime;
			if (t2 > 0) return t2;
			return 0;
		}
		
		/**通过公会id来获取公会的名字及图标*/
		public static function getGuildNameAndIconByGuildId(guild_id, guild_info):Array {
			var guideName;
			var guideIcon;
			if (guild_id.split("_")[0] == "budui") {
				var ngID:int = parseInt(guild_id.split("_")[1]);
				guideName = GameLanguage.getLangByKey(GameConfigManager.ArmyGroupNpcList[ngID].npc_name);
				guideIcon = GameConfigManager.ArmyGroupNpcList[ngID].planet_apper;
			} else {
				guideName = guild_info.name;
				guideIcon = guild_info.icon;
			}
			return [guideName, guideIcon];
		}
		
		/**通过星球icon来获取皮肤*/
		public function getStarSkinByIcon():String {
			return "appRes/icon/stageIcon/" + icon + ".png"
		}
		
		/**获取玩家每日可使用的资金*/
		public static function getPlayerCanUseMoney(position):int {
			var guild_position_data = ResourceManager.instance.getResByURL("config/guild_position.json");
			var targetData = ToolFunc.getTargetItemData(guild_position_data, "name", position);
			if (targetData) return Number(targetData["control_money"]);
			return 0;
		}
		
		/**通过职位求保护城池的花费*/
		public static function getProtectCostByPosition(position):int {
			var juntuan_protect_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_protect.json");
			var targetData = ToolFunc.getTargetItemData(juntuan_protect_data, "title", position);
			return targetData && Number(targetData["price_fund"]);
		}
		
		/**召集花费*/
		public static function getZhaojiCost():int {
			var juntuan_canshu_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
			return juntuan_canshu_data && Number(juntuan_canshu_data["76"].value);
		}
	}
}