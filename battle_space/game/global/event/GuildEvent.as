package game.global.event
{
	// 这波骚操作。。。。
	public class GuildEvent
	{
		/**
		 * 申请公会
		 */
		public static const APPLY_GUILD:String = "applyGuild";
		
		/**
		 * 删除申请名单
		 */
		public static const DELECT_APPLY_MEMBER:String = "delApplyMember";
		
		/**
		 * 改变公会加入类型
		 */
		public static const CHANGE_JOIN_TYPE:String = "changeJoinType";
		
		/**
		 * 改变公会加入等级
		 */
		public static const CHANGE_JOIN_LV:String = "changeJoinLv";
		
		public static const CHANGE_GUILD_DESC:String = "changeGuildDesc";
		
		public static const CHANGE_GUILD_ICON:String = "changeGuildIcon";
		
		/**
		 * 调整职位
		 */
		public static const ADJUSE_MEMBER_JOB:String = "adjustMembeJob";
		
		/**
		 * 收到公会聊天消息
		 */
		public static const SPREAD_GUILD_TALK:String = "getGuildtalk";
		
		/**
		 * 选择公会ICON
		 */
		public static const SELECT_GUILD_ICON:String = "selectGuildIcon";
		
		public static const REFRESH_GUILD_BOSS:String = "refreshGuildBoss";
		
//		public static const GOTO_CHAPTER_ONE:String = "gotoChapterOne";
		
		
		//-------------功能引导事件
		public static const HIDE_MILITARYHOUSE_UNIT_LIST:String = "closeMilitaryHouseUnitList";
		
		public static const FORBID_BLANK_CLOSE:String = "forbidBlackClose";
	}
}