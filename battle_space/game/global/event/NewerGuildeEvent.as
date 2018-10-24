package game.global.event 
{
	/**
	 * ...
	 * @author ...
	 */
	public class NewerGuildeEvent 
	{
		
		/**
		 * 新手引导通知战斗行为
		 */
		public static const GUIDE_ATTACK_DO:String = "GUIDE_ATTACK_DO";
		
		public static const GUIDE_ATTACK_FIRST_ACT:String = "GUIDE_ATTACK_FIRST_ACT";
		
		public static const GUIDE_HERO_ACT:String = "GUIDE_HERO_ACT";
		
		/**
		 * 新手引导通知战斗行为完毕
		 */
		public static const GUIDE_ATTACK_FINISH:String = "GUIDE_ATTACK_FINISH";
		
		/**
		 * 选中行动条
		 */
		public static const SELECT_ACT_BAR:String = "SELECT_ACT_BAR";
		
		/**
		 * 现金攻击间剪头
		 */
		public static const SHOW_ATTACK_ARROW:String = "SHOW_ATTACK_ARROW";
		
		
		/**
		 * 战斗回合切换
		 */
		public static const FIGHT_CHANGE_ROUND:String = "FIGHT_CHANGE_ROUND";
		
		/**
		 * 进入战斗场景
		 */
		public static const ENTER_BATTLE_SCENCE:String = "ENTER_BATTLE_SCENCE";
		
		/**
		 * 出兵
		 */
		public static const CREATE_SOILDER:String = "CREATE_SOILDER";
		
		
		/**
		 * 开始战斗
		 */
		public static const START_BATTLE:String = "START_BATTLE";
		
		/**
		 * 选中特定士兵
		 */
		public static const SELECT_SOILDER:String = "SELECT_SOILDER";
		
		/**
		 * 选中防御
		 */
		public static const SELECT_DEFENCE:String = "SELECT_DEFENCE";
		
		public static const SELECT_MOVE:String = "SELECT_MOVE";
		
		/**
		 * 开始移动指引
		 */
		public static const START_MOVE_GUIDE:String = "START_MOVE_GUIDE";
		
		/**
		 * 移动完毕
		 */
		public static const MOVE_OVER:String = "MOVE_OVER";
		
		/**
		 * 战斗指引完毕
		 */
		public static const BATTLE_GUILD_FINISH:String = "BATTLE_GUILD_FINISH";
		
		/**
		 * 打开建筑物列表
		 */
		public static const OPEN_CONTRIBUTE_LIST:String = "OPEN_CONTRIBUTE_LIST";
		
		/**
		 * 改变建筑物列表
		 */
		public static const CHANGE_CONTRIBUTE_LIST:String = "CHANGE_CONTRIBUTE_LIST";
		
		/**
		 * 放置建筑物完毕
		 */
		public static const PUT_BUILDING_OK:String = "PUT_BUILDING_OK";
		
		/**
		 * 确定放置
		 */
		public static const CONFIRM_BUILDING:String = "CONFIRM_BUILDING";
		
		/**
		 * 建筑物加速
		 */
		public static const SPEED_UP_BUILDING:String =  "SPEED_UP_BUILDING";
		
		/**
		 * 进入训练营
		 */
		public static const ENTER_TRAIN_VIEW:String = "ENTER_TRAIN_VIEW";
		

		
		/**
		 * 点击训练按钮
		 */
		public static const CLICK_TRAIN_BTN:String = "CLICK_TRAIN_BTN";
		
		/**
		 * 点击加速训练
		 */
		public static const CLICK_SPEED_UP:String = "CLICK_SPEED_UP";
		
		/**
		 * 自动完成训练
		 */
		public static const AUTO_FINISH_TRAIN:String = "AUTO_FINISH_TRAIN";
		
		/**
		 * 点击任务go按钮
		 */
		public static const CLICK_GO_BTN:String = "CLICK_GO_BTN";
		
		/**
		 * 进入战斗地图
		 */
		public static const ENTER_FIGHT_MAP:String = "ENTER_FIGHT_MAP";
		
		/**
		 * 显示关卡面板
		 */
		public static const SHOW_CHAPTER_PANEL:String = "SHOW_CHAPTER_PANEL";
		
		/**
		 * 开始第一场战斗
		 */
		public static const FIGHT_CHAPTER_ONE:String = "FIGHT_CHAPTER_ONE";
		
		/**
		 * 第一场战斗结束;
		 */
		public static const CHAPTER_ONE_OVER:String = "CHAPTER_ONE_OVER";
		
		/**
		 * 开始第二场战斗
		 */
		public static const FIGHT_CHAPTER_TWO:String = "FIGHT_CHAPTER_TWO";
		
		/**
		 * 使用技能1
		 */
		public static const USE_SKILL_ONE:String = "USE_SKILL_ONE";
		
		/**
		 * 使用技能2
		 */
		public static const USE_SKILL_TWO:String = "USE_SKILL_TWO";
		
		/**
		 * 轮到英雄行动
		 */
		public static const HERO_FIGHT:String = "HERO_FIGHT";
		
		/**
		 * 开始兵营建造引导
		 */
		public static const START_LOTTLE_GUIDE:String = "START_LOTTLE_GUIDE";
		
		/**
		 * 盾兵行动
		 */
		public static const SHIELD_SOILDER_ACT:String = "SHIELD_SOILDER_ACT";
		
		
		/**
		 * 进入抽奖界面
		 */
		public static const ENTER_LOTTER_VIEW:String = "ENTER_LOTTER_VIEW";
		
		/**
		 * 选择普通抽奖
		 */
		public static const SELECT_NORMAL_LOTTER:String = "SELECT_NORMAL_LOTTER";
		
		/**
		 * 获取抽奖结果
		 */
		public static const GET_LOTTER_RESULT:String = "GET_LOTTER_RESULT";
		
		/**
		 * 进入兵营
		 */
		public static const ENTER_CAMP_VIEW:String = "ENTER_CAMP_VIEW";
		
		/**
		 * 解锁狙击兵
		 */
		public static const RELEASE_SNAPER:String = "RELEASE_SNAPER";
		
		/**
		 * 选择狙击兵
		 */
		public static const SELECT_SNAPER:String = "SELECT_SNAPER";
		
		/**
		 * 进入第三章
		 */
		public static const FIGHT_CHAPTER_THREE:String = "FIGHT_CHAPTER_THREE";
		
		/**
		 * 设置名字完成
		 */
		public static const SET_NAME_OK:String = "SET_NAME_OK";
		
		/**
		 * 最终步骤
		 */
		public static const LAST_STEP:String = "LAST_STEP";
		
		/**
		 * 阻断点击
		 */
		public static const HANK_CLICK:String = "HANK_CLICK";
		
		/**
		 * 关闭帮助手册
		 */
		public static const OPEN_HELP_NOTE:String = "openHelpNote";
		
		/**
		 * 关闭帮助手册
		 */
		public static const CLOSE_HELP_NOTE:String = "closeHelpNote";
		
		/**
		 * 打开设置面板
		 */
		public static const OPEN_SET_NOTE:String = "OPEN_SET_NOTE";
	}

}