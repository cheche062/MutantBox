/***
 *作者：罗维
 */
package game.global.consts
{
	public class ServiceConst
	{
		/**错误-通用*/
		public static const ERROR:uint=10000;
		/**提示-貌似是货币不足*/
		public static const NO_MONEY:int=10001;
		/**错误-强行结束战斗*/
		public static const ERROR_FIGHT:uint=10002;
		/**错误-异地登录*/
		public static const ERROR_OFFSITE_LANDING:uint=10003;
		/**推送-通用*/
		public static const PUSH_INFO:uint=10010;
		/**推送-英雄*/
		public static const PUSH_HERO:uint=10012;
		/**推送-士兵*/
		public static const PUSH_SOLDIER:uint=10013;
		/**推送-经验*/
		public static const PUSH_EXP:uint=10015;
		/**推送-占矿上或基地互动*/
		public static const PUSH_INVADE:uint=10023

		public static const LOGIN_CONST:uint=10100; //请求登录
		/**领取加入公会奖励*/
		public static const GET_GUILD_REWARD:uint=10113;

		/**心跳*/
		public static const HEARTBEAT:uint=10108;

		/**切换语言*/
		public static const ChangeLan:int = 10111;
		
		/**
		 * 获取当前活动列表
		 */
		public static const GET_ACT_LIST:int = 10112;

		/**
		 * VIP信息更细
		 */
		public static const VIP_UPDATE:uint=10024;
		public static const STORY_VIEW:uint=10406;

//		public static const FIGHTING_MAP_NEWOPEN:uint = 10021; //新开关卡

		public static const FIGHTING_GETSQUAD_CONST:uint=20111; //请求战斗
		public static const FIGHTING_GETSQUAD_CONST_FM:uint=30003; //请求战斗 - 推图
		public static const FIGHTING_GETSQUAD_CONST_JY:uint=30013; //请求战斗 - 精英
		public static const FIGHTING_GETSQUAD_CONST_GENE:uint=30102; //请求战斗 - 基因
		public static const FIGHTING_GETSQUAD_CONST_WORLDBOSS:uint=30021; //请求战斗 - 世界BOSS
		public static const FIGHTING_GETSQUAD_CONST_HOMEMONSTER:uint=30082; //请求战斗 - 怪物入侵
		public static const FIGHTING_GETSQUAD_CONST_EQUIP:uint=30034; //请求战斗 - 怪物入侵
		public static const FIGHTING_GETSQUAD_CONST_HOME:uint=30705; //请求战斗 - 怪物入侵
		public static const FIGHTING_GETSQUAD_CONST_JIEBIAO:uint=30183; //请求战斗 - 劫镖
		public static const FIGHTING_GETSQUAD_CONST_GBOSS:uint=30226; //请求战斗 - 公会BOSS

		//布阵 基地互动
		public static const FIGHTING_JIDI_BUZHEN:uint=30712;


		//新的推图相关协议
		public static const NEW_FIGHTING_MAP_INIT:uint=30866; //初始协议
		public static const NEW_FIGHTING_MAP_CHAPETR:uint=30867; //单章节协议
		public static const NEW_FIGHTING_MAP_LEVEL_CHANGE:uint=30868; //单个关卡信息变化
		public static const NEW_FIGHTING_MAP_BUYNUM_CHANGE:uint=30869; //购买次数于关卡次数发生改变
		public static const NEW_FIGHTING_MAP_FNUM_CHANGE:uint=30870; //关卡次数发生改变
		public static const NEW_FIGHTING_MAP_CHAPETR_REWARD:uint=30871; //领奖信息变化

		public static const FIGHTING_SENDSQUAD_CONST:uint=20201; //发送布局
		public static const FIGHTING_SENDSQUAD_EQUIP_CONST:uint=30035; //发送布局
		public static const FIGHTING_SENDSQUAD_FY_CONST:uint=20213; //发送布局
		public static const FIGHTING_SENDSQUAD_FY_SAVE_CONST:uint=30703; //保存布局
		public static const FIGHTING_SENDSQUAD_PVP_CONST:uint=30838; //发送布局


		public static const FIGHTING_START_CONST:uint=20202; //开打
		public static const FIGHTING_START_CONST_FM:uint=30005; //开打 - 推图
		public static const FIGHTING_START_CONST_JY:uint=30015; //开打 - 推图
		public static const FIGHTING_START_CONST_GENE:uint=30103; //开打 - 基因
		public static const FIGHTING_START_CONST_WORLDBOSS:uint=30022; //开打 - 世界BOSS
		public static const FIGHTING_START_CONST_HOMEMONSTER:uint=30083; //开打 - 怪物入侵
		public static const FIGHTING_START_CONST_EQUIP:uint=30036; //开打 - 怪物入侵
		public static const FIGHTING_START_CONST_HOME:uint=30706; //开打 - 怪物入侵
		public static const FIGHTING_START_CONST_JIEBIAO:uint=30184; //开打 - 劫镖
		public static const FIGHTING_START_CONST_GBOSS:uint=30227; //开打 - 公会BOSS

		public static const FIGHTING_SENDATTACK_CONST:uint=20203; //出手

		public static const FIGHTING_SUTOATTACK_CONST:uint=20204; //托管

		public static const FIGHTING_BUZHEN_BACK:uint=20217; //布阵时候选退出
		public static const FIGHTING_KAIZHAN_BACK:uint=20218; //布阵时候选退出

		public static const FIGHTING_ESCAPE_CONST:uint=20205; //投降
		public static const FIGHTING_ESCAPE_BACK_CONST:uint=80103; //投降 - 响应协议

		public static const FIGHTING_SINGLESTEP_CONST:uint=80104; //收到单步战斗数据

		public static const FIGHTING_RESULTS_CONST:uint=80105; //战斗结果
		public static const FIGHTING_RESULTS_CONST2:uint=80106; //战斗结果

//		public static const FIGHTINGMAP_INFO_DATA:uint = 30001;  //主线副本 推图信息
//		public static const FIGHTINGJY_INFO_DATA:uint = 30011;  //精英副本 推图信息
		public static const FIGHTINGBOSS_INFO_DATA:uint=30020; //BOSS战 推图信息
		public static const FIGHTINGEQUIP_INFO_DATA:uint=30031; //武器副本 推图信息

//		public static const FIGHTINGMAP_SUB_INFO_DATA:uint = 30002;  //子章节 推图信息
		public static const FIGHTINGMAP_SUBJY_INFO_DATA:uint=30012; //精英子章节 推图信息


		public static const GENENSTAGE_INFO_DATA:uint=30100; //基因 推图信息

		public static const FIGHTING_GENE_LEVEL_REFRESH:uint=30105; //基因副本 刷新


		public static const BAG_INFO_DATA_CONST:uint=10200; //获取背包初始数据
		public static const BAG_SELL_CONST:uint=10202; //道具出售
		public static const BAG_CHANGE_CONST:uint=10011; //道具变化

		public static const BAG_SHOWPACKAGE:uint=10205; //查看礼包
		public static const BAG_USEPACKAGE:uint=10206; //使用礼包
		public static const BAG_USEPACKAGE2:uint=10201; //使用礼包2
//		public static const FIGHTING_MYARMY_CONST:uint = 30059;  //请求己方可派兵力

		public static const FIGHTING_ARMY_CD_CONST:uint=30060; //清除英雄CD

		public static const FIGHTING_MAP_GET_REWARD:uint=30007; //主线推图领奖
		public static const FIGHTING_MAP_GET_REWARD_JY:uint=30017; //主线推图领奖
		public static const FIGHTING_MAP_BUY_TIMER:uint=30006; //主线推图 买次数
		public static const FIGHTING_MAP_BUY_TIMER_JY:uint=30016; //主线推图 买次数
		public static const FIGHTING_MAP_SAODANG:uint=30008; //主线推图，扫荡
		public static const FIGHTING_MAP_SAODANG_JY:uint = 30018; //主线推图，扫荡
		
		/**
		 * 邀请好友接口
		 */
		public static const GET_INVITE_INFO:uint = 36130;
		public static const BIND_FRIEND:uint = 36131;
		public static const GET_INVITE_REWARD:uint = 36132;
		/**
		 * 兑换码礼品
		 */
		public static const EXCHANGE_CODE_REWARD:uint = 36150;


		public static const FIGHTING_GENE_BUY_TIMER:uint=30101; //基因副本 买次数

		//装备副本
		public static const EQUIP_FIGHT_INFO:uint=30030; //打开副本
		public static const EQUIP_FIGHT_HANGXING:uint=30032; //开始航行
		public static const EQUIP_FIGHT_FIGHT:uint=30033; //开始航行
		public static const EQUIP_FIGHT_END:uint=30039; //返航
		public static const EQUIO_SUPPLIES_INFO:uint=30040; //补给站info
		public static const EQUIO_SUPPLIES_BUY:uint=30041; //补给站购买
		public static const EQUIO_SUPPLIES_BUYDB:uint=30042; //补给站购买代币

		/**
		 * 打开VIP界面;
		 */
		public static const OPEN_VIP_VIEW:uint=33200;

		/**
		 * 获取VIP礼包
		 */
		public static const GET_VIP_WELFARE:uint = 33201;
		
		/**
		 * 游戏排行榜信息
		 * 参数：
		 * rankType:
		 *  level--等级排行
			stage_level--推图星数排行
			power--战力排行
			soldier--兵王排行
			hero--英雄排行
		 */
		public static const GAME_RANK:uint = 50000;
		 
		/**获取建筑信息*/
		public static const B_INFO:uint=10101;
		/**新建建筑  参数1 建筑id    参数2 x坐标    参数3 y坐标*/
		public static const B_BUILD:int=20000;
		/**升级建筑   参数1 建筑id*/
		public static const B_LV_UP:int=20001;
		/**移动建筑  参数1 建筑id    参数2 x坐标    参数3 y坐标*/
		public static const B_MOVE:int=20002;
		/**开启新的建筑队列*/
		public static const B_OPEN:int=20003;
		/**秒某个队列   参数1  队列ID*/
		public static const B_ONCE:int=20004;
		/**交换位置*/
		public static const B_SWAP:int=20005;
		/**取消进行中的队列(新建就摧毁  升级就降回)参数:  队列ID*/
		public static const B_RUIN:int=20006
		/**扩展基地，解锁迷雾*/
		public static const B_EXPAND:int=20007
		/**20008   收集建筑产出   参数  建筑唯一ID*/
		public static const B_HARVEST:int=20008;
		/**20009   通知时间跑完   参数  建筑唯一ID*/
		public static const B_TIMEOVER:int=20009;

		/**训练营信息*/
		public static const T_INFO:int=30052;
		/**训练建造士兵*/
		public static const T_TRAIN:int=30056;
		/**一键加速训练*/
		public static const T_SPEED:int=30057;
		/**兵营信息*/
		public static const C_INFO:int=30051;
		/**解散士兵*/
		public static const C_DISMISS:int=30055;
		/**合成新兵种*/
		public static const C_COMPOSE:int=30053
		/**兵种升星*/
		public static const C_Star:int=30054;
		/**取消训练*/
		public static const T_CANCEL:int=30058;

		/**基因室信息*/
		public static const G_INFO:int=30130;
		/**购买基因室训练位*/
		public static const G_BUY:int=30131;
		/**囚犯研究*/
		public static const G_RESEARCH:int=30132;
		/**快速收取秒CD*/
		public static const G_SPEED:int=30134;
		/**收取基因*/
		public static const G_GET:int=30133;
		/**装备兵种界面信息*/
		public static const G_EQ_INFO:int=30136;
		/**基因装配*/
		public static const G_EQ_EQUIP:int=30137;
		/**卸载基因*/
		public static const G_EQ_UNEQ:int=30138;
		/**基因升级*/
		public static const G_ENHANCE:int=30135;

		/**抽卡基本信息*/
		public static const DRAW_CARD_INFO:int=20300;
		/**抽卡请求*/
		public static const DRAW_CARD:int=20301;
		/**连续最大级抽卡*/
		public static const SUPER_DRAW_CARD:int=20306;
		/**连续最大级抽卡的单抽*/
		public static const SUPER_DRAW_CARD_ONE:int=20307;
		public static const DRAW_CARD_CHANGELEVEL:int=20303;
		
		/**boss战*/
//		public static const WORLD_BOSS_FIGHT_ENTRANCE:int=30021;
//		public static const WORLD_BOSS_FIGHT:int=30022;
		public static const WORLD_BOSS_ITEM_BUY:int=30023;
		public static const WORLD_BOSS_BUY_TIME:int=30024;
		public static const WORLD_BOSS_RANK:int=30025;


		public static const JUEXING_GETUINT_INFO:uint=30860; //读取单个兵种的觉醒数据
		public static const JUEXING_OPEN_LOCK:uint=30861; //解锁位置
		public static const JUEXING_TUPO:uint=30862; //突破
		public static const JUEXING_QIANGHUA:uint=30863; //强化
		public static const JUEXING_AUTO_OPEN_LOCK:uint=30864; // 一键觉醒解锁全部
		/**
		 * 公会相关命令
		 */
		/**打开面板**/
		public static const GUILD_BASE_INFO:int=30200;
		/**创建公会**/
		public static const GUILD_CREATE_GUILD:int=30201;
		/**申请加入公会**/
		public static const GUILD_APPLY_JOIN:int=30202;
		/**获取公会所有申请**/
		public static const GUILD_GET_ALL_APPLICATION:int=30203;
		/**同意申请**/
		public static const GUILD_CONFIRM_APPLY:int=30204;
		/**拒绝申请**/
		public static const GUILD_DENY_APPLY:int=30205;
		/**晋升**/
		public static const GUILD_PROMOTE:int=30206;
		/**降级**/
		public static const GUILD_REDUCE:int=30207;
		/**转让会长**/
		public static const GUILD_TRANSFER_LEADER:int=30208;
		/**开除会员**/
		public static const GUILD_KICK_OUT_MEMBER:int=30209;
		/**退出公会**/
		public static const GUILD_QUIT:int=30210;
		/**打开公会商店**/
		public static const GUILD_OPEN_STORE:int=30211;
		/**公会商店购买**/
		public static const GUILD_BUY_GOODS:int=30212;
		/**公会捐献**/
		public static const GUILD_DONATE:int=30213;
		/**公会索取兵种碎片**/
		public static const GUILD_APPLY_SOILDER:int=30214;
		/**公会捐献随便**/
		public static const GUILD_DONATE_PIECE:int=30215;
		/**公会索取列表**/
		public static const GUILD_GET_APPLY_LIST:int=30216;
		/**获取所有公会列表**/
		public static const GUILD_GET_ALL_GUILD_LIST:int=30217;
		
		/**个人技能页面  **/
		public static const GUILD_PERSONAL_SKILL:int = 30222;
		/**学习个人技能**/
		public static const GUILD_PERSONAL_SKILL_UP:int = 30223;
		
		/**
		 * 修改公会参数
		 */
		public static const GUILD_CHANGE_SETTING:int=30218;

		/**
		 * 公会排行列表
		 */
		public static const GUILD_RANK_LIST:int=30220;

		/**
		 * 收到公会聊天
		 */
		public static const GET_GUILD_TALK:int=11010;

		/**
		 * 发送公会聊天
		 */
		public static const SEND_GUILD_TALK:int=30219;
		/**
		 * 收到可以进入公会推送
		 */
		public static const JOIN_GUILD_OK:int=10020;

		/**
		 * 公会BOSS信息
		 */
		public static const GUILD_BOSS_INIT:int=30224;

		/**
		 * 开启公会BOSS
		 */
		public static const OPEN_GUILD_BOSS:int=30225;

		/**
		 * 进入公会BOSS
		 */
		public static const ENTER_GUILD_BOSS:int=30226;

		/**
		 * 进入公会BOSS战斗
		 */
		public static const FIGHT_GUILD_BOSS:int=30227;

		/**
		 * 查询BOSS信息
		 */
		public static const CHECK_GUILD_BOSS:int=30228;

		/**
		 * 购买挑战BOSS次数
		 */
		public static const BUY_BOSS_TIMES:int=30229;


		/**
		 * 科技树初始接口
		 */
		public static const TECH_INIT_DATA:int=30651;

		/**
		 * 科技树购买点数
		 */
		public static const TECH_BUY_POINT:int=30652;

		/**
		 * 科技树升级接口
		 */
		public static const TECH_UPDATE:int=30653;

		/**
		 * 科技树重置接口
		 */
		public static const TECH_RESETE:int=30654;

		/**
		 * 触发条件引导
		 */
		public static const PUSH_NEW_FUN:int=10501;


		/**
		 * 获取任务列表
		 */
		public static const MISSION_INIT_DATA:int=10400;

		/**
		 * 获取任务进度
		 */
		public static const GET_MISSION_PROGRESS:int=10051;

		/**
		 * 领取任务奖励
		 */
		public static const GET_MISSION_REWARD:int=10401;
		public static const GET_DAILY_SCORE_REWARD:int=10402;
		public static const GET_CHAPTER_REWARD:int=10407;
		/**
		 * 设置玩家姓名
		 */
		public static const SET_PLAYER_NAME:int=10102;
		public static const NEW_SET_PLAYER_NAME:int=10110;

		/**
		 * 设置新手引导进度
		 */
		public static const SET_NEWER_GUIDE:int=10103;

		/**
		 * 已点赞
		 */
		public static const HAS_LIKE:int=32004;

		/**
		 * 活动状态监测
		 */
		public static const CHECK_ACT_STATE:int=32005;

		/**
		 * 充值回调
		 */
		public static const GET_WATER:int=10106;

		public static const PAY_SUCCESS:int=35808


		public static const GET_WEBPAY_URL:int=35801

		/**刷新怪物*/
		public static const M_REFRESH:int=30081;
		public static const M_INFO:int=30086;
		/**邮件*/
		public static const FRIEND_GETNAIL:int=30300;
		public static const FRIEND_READMAIL:int=30301;
		public static const FRIEND_GETATTACHMENT:int=30302;
		public static const FRIEND_TAKEALL:int=30305;

		public static const FRIEND_NEWMAIL:int=30306;


		/**获取游戏好友列表*/
		public static const FRIEND_GETFRIENDLIST:int=30500;
		/**推送消息,有人加你好友*/
		public static const FRIEND_GETREQUEST:int=30501;
		/**推送消息,某人通过你的好友请求*/
		public static const FRIEND_GETREQUESTAPPLY:int=30502;
		/**推送消息,A给B发私聊消息*/
		public static const FRIEND_GETCHAT:int=30503;
		
		/**搜索玩家*/
		public static const FRIEND_SEARCHFRIEND:int=30505;
		/**申请加好友*/
		public static const FRIEND_APPLYFRIEND:int=30506;
		/**是否同意好友申请*/
		public static const FRIEND_MANAGEFRIEND:int=30507;
		/**删除好友*/
		public static const FRIEND_DELETEFRIEND:int=30508;
		
		/**好友聊天记录*/
		public static const FRIEND_GATCHATLIST:int=30509;
		/**给好友发消息*/
		public static const FRIEND_SENDCHAT:int=30510;
		/**给好友发消息(多人)*/
		public static const FRIEND_SEND_INVITE:int=30511;
		
		/**刷新一批推荐玩家*/
		public static const FRIEND_RECOMMEND:int = 30512;
		/**查询玩家信息*/
		public static const DEMAND_PLAYER_INFO:int = 30513;
		
		/**装备*/
		public static const EQUIP_EQUIPINFO:int=30600;
		public static const EQUIP_STRONG:int=30601;
		public static const EQUIP_WEAR:int=30602;
		public static const EQUIP_UNWEAR:int=30603;
		public static const EQUIP_WASH:int=30604;
		public static const EQUIP_SAVEWASH:int=30605;
		public static const EQUIP_RESOLVE:int=30606;
		public static const EQUIP_QUICKRESOLVE:int=30607;

		/**加道具*/
		public static const ADD_ITEM:int=19999;
		/**打开商店*/
		public static const S_LIST:int=10300;
		/**购买*/
		public static const S_BUY:int=10301
		/**刷新商店  */
		public static const S_REFRESH:int=10302;

		/**
		 * 运镖
		 */
		public static const TRAN_GETTRANSPORTTYPE:int=30193;
		public static const TRAN_ENTERTHECOPY:int=30170;
		public static const TRAN_BUYVEHICLE:int=30171;
		public static const TRAN_SELECTBUYVEHICLE:int=30172;
		public static const TRAN_BUYPLAN:int=30173;
		public static const TRAN_SELECTBUYPLAN:int=30174;
		public static const TRAN_ENTEREMBATTLE:int=30175;
		public static const TRAN_GROUPHELP:int=30176;
		public static const TRAN_CANNELGROUPHELP:int=30177;
		public static const TRAN_ENYERFRIENDEMBATTLE:int=30178;
		public static const TRAN_SAVEFORMATION:int=30179;
		public static const TRAN_STARTRANSPORT:int=30180;
		public static const TRAN_ENTERTRANMAP:int=30181;
		public static const TRAN_BUYPLUNDERTIME:int=30182;
		public static const TRAN_SELECTPLUNDER:int=30183;
		public static const TRAN_STARPLUNDER:int=30184;
		public static const TRAN_GETREWARD:int=30185;
		public static const TRAN_GETTRAININFO:int=30186;
		public static const TRAN_USETRAINBOOK:int=30187;
		public static const TRAN_ATUOLEVELUP:int=30188;
		public static const TRAN_REFRESHPAN:int=30194;
		public static const TRAN_BUYTRANSTIMES:int=30195;

		public static const LUCKY_START_C:int=20231;
		public static const LUCKY_GET_C:int=20232;
//		'30706' => ['CTL'=>'baseRob',          'ACT'=>'startFight',            'DESC'=>'开始掠夺'],
//		'30709' => ['CTL'=>'baseRob',          'ACT'=>'revenge',               'DESC'=>'复仇'],
		/**信息*/
		public static const IN_INFO:int=30700;
		/**搜索目标IN means invasion*/
		public static const IN_SEARCH:int=30701;
		/**更换对手*/
		public static const IN_C_TARGET:int=30702;
		/**买保护盾*/
		public static const IN_BUY_SHIELD:int=30707;
		/**买buff*/
		public static const IN_BUY_BUFF:int=30708;
		/**复仇*/
		public static const IN_REVENGE:int=30709;
		/**访问基地*/
		public static const IN_getHomeByUid:int=30710;
		/**排行榜信息*/
		public static const IN_getRank:int=30711;
		/**进去战场*/
		public static const IN_FIGHT:int=30705
		//'30716' => ['CTL'=>'baseRob',          'ACT'=>'checkFight',           'DESC'=>'战前检测'],
		public static const checkFight:int=30716;
		/**战斗取消*/
		public static const IN_QUIT:int=30717;
		/**领取奖励*/
		public static const IN_getReward:int=30718;

		/**事件日志*/
		public static const getEventLog:int=20215;
		/***/
		public static const getFightReport:int=20211;
		/**80201 战报列表更新推送*/
		public static const freshFightReport:int=80201;
		/**
		 * 竞技场接口
		 */
		// 初始数据
		public static const ARENA_INIT:int=30800;
		// 刷新
		public static const ARENA_REFRESH_CHALLENGE:int=30801;
		// 重置
		public static const ARENA_RESET_TIME:int=30803;
		
		// 竞技商店兑换记录
		public static const ARENA_SHOP_LOG:int=30806;
		// 竞技场商店兑换
		public static const ARENA_SHOP_CHANGE:int=30807;
		// 竞技场排行榜(1,2,3)
		public static const ARENA_RANK_LIST:int=30808;
		// 竞技场战报(1,2)
		public static const ARENA_REPORT_LIST:int=30809;
		// 竞技场防守
		public static const ARENA_SET_DEFENCE:int=30810;
		// 竞技场防守保存
		public static const ARENA_SAVE_DEFENCE:int=30811;
		// 竞技场进入战斗
		public static const ARENA_ENTER_FIGHT:int=30812;
		// 竞技场开始战斗
		public static const ARENA_START_FIGHT:int=30813;
		// 竞技场战前检查
		public static const ARENA_CHECK_FIGHT:int=30814;

		// 竞技场休整期状态
		public static const ARENA_REST_STATE:int=30817;
		// 竞技场奖励
		public static const ARENA_REWARD_STATE:int=30818;

		/**
		 * 占矿接口
		 */
		// 占矿初始化
		public static const MINE_INIT:int=30900;
		// 进入矿点
		public static const ENTER_MINE:int=30901;
		// 购买开采次数
		public static const BUY_MINE_TIMES:int=30902;
		// 购买CD保护
		public static const BUY_PROTECT_TIMES:int=30903;
		// 进入布阵界面
		public static const SET_MINE_DEFENCE:int=30904;
		// 保存布阵界面
		public static const SAVE_MINE_DEFENCE:int=30905;
		// 进入矿场战斗
		public static const ENTER_MINE_FIGHT:int=30906;
		// 开始矿场战斗
		public static const START_MINE_FIGHT:int=30907;
		// 矿场开战检查
		public static const CHECK_MINE_FIGHT:int=30908;
		// 领取矿区奖励
		public static const GET_MINE_RESULT:int=30910;
		// 离开矿位
		public static const LEAVE_MINE:int=30911;
		// 矿战战报
		public static const MINE_FIGHT_LOG:int=30912;
		/**
		 * 矿场休息中
		 */
		public static const MINE_REST_INFO:int=30913;
		public static const MINE_SHOP_INIT:int=30914;
		public static const MINE_SHOP_BUY:int=30915;

		/**
		 * 升阶
		 */
		/**
		 * 升阶初始化
		 */
		public static const ASCENDING_INIT:int=31000;
		/**
		 * 获得单位信息
		 */
		public static const ASCENDING_GET_INFO:int=31001;
		/**
		 * 单次升阶
		 */
		public static const ASCENDING_ONE_UPGRADE:int=31002;
		/**
		 * 自动升阶
		 */
		public static const ASCENDING_AUTO_UPGRADE:int=31003;

		/**
		 * 活动接口
		 */
		public static const GET_ACTIVITY_LIST:int = 32000;
		/**
		 * 检查首冲活动是否领取过
		 */
		public static const CHECK_HAS_FINISH_FIRST_CHARGE:int=40002;

		/**
		 * 活动通用初始化
		 */
		public static const COMMON_ACT_INIT:int=32001;

		/**
		 * 活动通用领取
		 */
		public static const COMMON_GET_REWARD:int = 32002;
		
		public static const SINGLE_CHARGE_INIT:int = 40010;
		public static const SINGLE_CHARGE_REWARD:int = 40011;
		
		public static const CHARGE_ACT_INIT:int = 40020;
		public static const CHARGE_ACT_REWARD:int = 40021;

		public static const COST_ACT_INIT:int = 40030;
		public static const COST_ACT_REWARD:int = 40031;


		/*** 转盘初始化 */
		public static const TURNTABLE_ONE_INIT:int=40056;
		/*** 转盘一号机抽奖 */
		public static const TURNTABLE_ONE_DO_LOTTLE:int=40057;
		/*** 转盘一号排行榜领奖*/
		public static const TURNTABLE_ONE_RANK_REWARD:int=40059;
		/*** 转盘排行榜*/
		public static const TURNTABLE_ONE_RANK:int=40058;

		/**折扣商店初始**/
		public static const SUPER_SALE_ONE_INIT:int=32009;
		/**刷新全部*/
		public static const SUPER_SALE_ONE_REFRESH_ALL:int=32010;
		/**刷新单个商品*/
		public static const SUPER_SALE_ONE_REFRESH_GOODS:int=32011;
		/**购买商品*/
		public static const SUPER_SALE_ONE_BUY:int = 32012;
		
		public static const FIRST_CHARGE_INIT:int = 40000;
		public static const FIRST_CHARGE_GET_REWARD:int = 40001;
		
		public static const GIFT_PACK_ONE_INIT:int = 40046;
		public static const GIFT_PACK_ONE_BUY:int = 40047;
		/**限时礼包请求*/
		public static const GIFT_TIME_LIMIT:int = 32166;
		/**限时礼包购买请求*/
		public static const GIFT_TIME_LIMIT_BUY:int = 32167;
		
		
		/**
		 * 宝石转盘初始化
		 */
		public static const WATER_LOTTERY_INIT:int = 40060;
		public static const WATER_LOTTERY_START:int = 40061;

		/**
		 * 七日目标初始化
		 */
		public static const SEVEN_DAYS_INIT:int=33100;

		/**
		 * 七日目标领取
		 */
		public static const SEVEN_DAYS_GET:int=33101;

		//新 兵书副本
		public static const BINGBOOK_MAIN:int=30160;
		public static const BINGBOOK_REFRESH:int=30161;
		public static const BINGBOOK_OPENFIGHT:int=30162;
		public static const BINGBOOK_STARTFIGHT:int=30163;
		public static const BINGBOOK_START:int=30164;
		public static const BINGBOOK_RESET:int=30165;
		//PVP
		public static const PVP_PIPEI:uint=30841; //开始匹配
		public static const PVP_USERSTARTE:uint=30842; //玩家选择开始
		public static const PVP_LOADOVER:uint=30843; //资源准备完成
		public static const PVP_USEROK:uint=30844; //用户准备
		public static const PVP_ALLOK:uint=30845; //所有用户准备完毕
		public static const PVP_READY:uint=30846; //对方准备完毕
		public static const PVP_MSG_SEND:uint=30847;
		public static const PVP_MSG_BACK:uint=30848;
		public static const PVP_TIMER_OUT:uint=30839;




		public static const PVP_SHOP_BUY:uint=30832;
		public static const PVP_RANK:uint=30835;
		public static const PVP_GETREWARD:uint=30834; //领取奖励

		public static const PVP_FANGQI:uint=30849; //放弃布阵
		public static const PVP_FANGQI_BACKDATA:uint=30850; //放弃布阵后的结算信息

		public static const PVP_MAININFO:uint=30831; //请求PVP主场景信息
		public static const PVP_CANCEL:uint=30840; //取消匹配
		public static const PVP_ALLF:uint=30837;
		//随机条件刷新条件
		public static const RANDOM_CONDITION_REFRESH:uint=32121;
		//随机条件重置关卡
		public static const RANDOM_CONDITION_RESET:uint=32122;
		//随机条件面板
		public static const RANDOM_CONDITION_PANEL:uint=32120;
		//随机条件进入战场
		public static const RANDOM_CONDITION_ENTER:uint=32123;
		//随机条件开始战斗
		public static const RANDOM_CONDITION_FIGHTING:uint=32124;
		/**
		 * 军府接口
		 */
		public static const MILITARY_HOUSE_INIT:uint=30851;
		public static const MILITARY_HOUSE_CHANGE:uint=30852;
		public static const MILITARY_HOUSE_UPGRADE:uint=30853;
		public static const MILITARY_HOUSE_BUY_BLOCK:uint=30854;
		public static const MILITARY_HOUSE_AUTO_PUT:uint=30855;
		public static const MILITARY_HOUSE_REMOVE_ALL:uint=30856;

		public static const getNotice:int=35000;
		public static const delNotice:int=35001;


		//////////////模拟战斗//////////////////////////
		public static const SIMULATION_SENDF:int=999900001; //请求战斗
		public static const SIMULATION_START:int=999900002; //开始战斗

		/**
		 * 组队战斗
		 */
		public static const TEAMCOPY_INIT:int=35100;
		public static const TEAMCOPY_REFRESH:int=35101;
		public static const TEAMCOPY_CREATEROOM:int=35102;
		public static const TEAMCORY_JOINROOM:int=35103;
		public static const TEAMCORY_SEARCHROOM:int=35104;

		public static const TEAMCOPY_UPDATEROOM:int=35106;
		public static const TEAMCOPY_LEAVE:int=35107;
		public static const TEAMCOPY_ROOMCHAT:int=35108;
		public static const TEAMCOPY_INVITE:int=35109;
		public static const TEAMCOPY_STARTFIGHT:int=35110;
		public static const TEAMCOPY_EXPELPLAYER:int=35111;
		public static const TEAMCOPY_ROOMINFO:int=35113;

		public static const TEAMCOPY_REFRESHROOMLIST:int=35115;


		public static const TEAMCOPY_PLAYERENTERINTO:int=35150;
		public static const TEAMCOPY_PLAYERLEAVE:int=35151;
		public static const TEAMCOPY_PLAYERREADY:int=35152;
		public static const TEAMCOPY_PLAYERCHATINFO:int=35153;
		public static const TEAMCOPY_BATTLEFIELDREPORT:int=35155;
		public static const TEAMCOPY_BATTLEROOMDISSOLVE:int=35157;

		/**
		 * 军团战消息
		 */
		/**进入地图*/
		public static const ARMY_GROUP_MAP_INIT:int=35830;
		/**进入进入城市*/
		public static const ARMY_GROUP_ENTER_CITY:int=35831;
		/**宣战*/
		public static const ARMY_GROUP_DECLARE_WAR:int = 35832;
		/**召集*/
		public static const ARMY_GROUP_ZHAOJI_WAR:int = 35896;
		
		/**
		 * 初始化战斗地图数据
		 */
		public static const ARMY_GROUP_INIT_FIGHT_MAP:int =  35833;
		
		/**
		 * 战斗格子移动
		 */
		public static const ARMY_GROUP_FIGHT_MAP_MOVE:int = 35865;
		
		/**
		 * 战斗格子发生战斗
		 */
		public static const ARMY_GROUP_FIGHT_START:int = 35866;
		
		/**
		 * 设置部队自动战斗
		 */
		public static const ARMY_GROUP_SET_AUTO_FIGHT:int = 35867;
		
		/**
		 * 购买体力点
		 */
		public static const ARMY_GROUP_BUY_AP:int = 35868;
		
		/**
		 * 部队撤退
		 */
		public static const ARMY_GROUP_RETEAT:int = 35869;
		
		/**
		 * 部队取消撤退
		 */
		public static const ARMY_GROUP_GIVEUP_RETEAT:int = 35870;
		
		/**
		 * 军团商店
		 */
		public static const ARMY_GROUP_GET_STORE_INFO:int = 35871;
		public static const ARMY_GROUP_GET_STORE_BUY:int = 35872;
		public static const ARMY_GROUP_GET_STORE_REFRESH:int = 35873;
		
		/**
		 * 复活部队
		 */
		public static const ARMY_GROUP_REBORN_TEAM:int = 35876;
		
		/**
		 * 设置食物
		 */
		public static const ARMY_GROUP_SET_FOOD:int = 35877;
		
		/**
		 * 食物不足
		 */
		public static const ARMY_GROUP_FOOD_EMPTY:int = 35878;
		
		
		/**
		 * 更新场景移动数据
		 */
		public static const ARMY_GROUP_UPDATE_BLOCK:int = 35890;
		
		/**
		 * 部队撤退成功
		 */
		public static const ARMY_GROUP_TEAM_ESCAPE:int = 35891;
		
		/**
		 * 部队阵亡回到原点
		 */
		public static const ARMY_GROUP_TEAM_DIED:int = 35892;

		/**获取城市信息*/
		public static const ARMY_GROUP_GET_CITY_INFO:int=35861;

		public static const ARMY_GROUP_GET_ARMY_FOOD:int=35834;
		public static const ARMY_GROUP_GET_GUILD_MONEY:int=35864;
		public static const ARMY_GROUP_GET_SPECIAL_REWARD:int=35835;
		public static const ARMY_GROUP_GET_MILLITARY_REWARD:int=35836;
		public static const ARMY_GROUP_GET_TREASURE:int=35838;
		/**购买城市保护*/
		public static const ARMY_GROUP_BUY_PROTECTED:int=35839;
		/**npc的具体数据*/
		public static const ARMY_GROUP_CHECK_DEF_LIST:int=35844;
		public static const ARMY_GROUP_SELECT:int=35840;
		public static const ARMY_GROUP_TEAMS:int=35841;
		public static const ARMY_GROUP_DEPLOY:int=35842;
		public static const ARMY_GROUP_DEPLOY_SVAE:int=35843;
		public static const ARMY_GROUP_LEAVE_CITY:int=35846;
		
		/**选择城市*/
		public static const ARMY_GROUP_CHANGE_CITY:int=35852;
		/**推送城市最近状态*/
		public static const ARMY_GROUP_UPDATA_CITY_INFO:int=35887;
		/**推送公会资金更新*/
		public static const ARMY_GROUP_UPDATA_GUILD_MONEY:int=35889;
		/**放弃城市*/
		public static const ARMY_GROUP_GIVE_UP_PLANT:int=35863;
		/**离开地图*/
		public static const ARMY_GROUP_LEAVE_MAP:int=35851;
		/**获取部分地图的信息*/
		public static const ARMY_GROUP_GET_PART_MAP:int=35894;



		// 排行榜信息
		public static const ARMY_GROUP_GET_RANK:int=35845;
		public static const ARMY_GROUP_GET_GUILD_RANK:int=35893;
		
		/**获取昨日奖励*/
		public static const ARMY_GROUP_GET_YSRANK_REWARD:int=35847;
		/**获取赛季总排行奖励*/
		public static const ARMY_GROUP_GET_TOTAL_REWARD:int=35897;
		/**军衔*/ 
		public static const ARMY_GROUP_GET_MILITARY_INFO:int = 35857;
		
		public static const ARMY_GROUP_GET_SEASON_REWARD:int = 35879;
		
		public static const ARMY_GROUP_OUTPUT_INFO:int=35858;
		
		//战斗记录
		public static const ARMY_GROUP_FIGHT_REPORT:int=35882;
		//战斗结果
		public static const ARMY_GROUP_FIGHT_RESULT:int=35883;
		//战斗通知
		public static const ARMY_GROUP_FIGHT_TEAM:int=35854;
		//战斗推送
		public static const ARMY_GROUP_FIGHT_NOTICE:int=35855;
		/**log*/
		public static const ARMY_GROUP_FIGHT_LOG:int=35856;
		//
		public static const ARMY_GROUP_FIGHT_LAMP:int=35884;
		public static const ARMY_GROUP_FIGHT_STATECHANGE:int=35885;
		//
		public static const ARMY_GROUP_FIGHT_TEAM_DOWN:int=35860;
		/** 打开每日杀敌阶段奖励面板 35859*/
		public static const ARMY_GROUP_GET_ROLLKILL:int=35859;
		/** 领取每日杀敌阶段奖励 35848*/
		public static const ARMY_GROUP_GET_ROLLKILL_REWARD:int=35848;
		/**布阵推送*/
		public static const ARMY_GROUP_DEPLOY_UPDATE:int=35886;
		/**布阵变化推送*/
		public static const ARMY_GROUP_ARMY_CHANGE:int=35888;
		/**战利品室*/
		public static const TROPHY_ROOM_ENTER:int=30660;
		public static const TROPHY_ROOM_GET:int = 30661;
		
		/**
		 * 单英雄活动
		 */
		public static const LONEHERO_INIT:int = 32110;
		public static const LONEHERO_REFRESH_HERO:int = 32111;
		public static const LONEHERO_RESET_STAGE:int = 32112;
		public static const LONEHERO_REFRESH_RATE:int = 32113;
		
		public static const LONEHERO_ENTER_FIGHT:int = 32114;
		public static const LONEHERO_ENTER_STAGE_FIGHT:int = 32115;
		
		/**
		 * 基金活动
		 */
		public static const LVFUNDATION_INIT:int = 36110;
		public static const LVFUNDATION_GETREWARD:int = 36111;
		
		/**
		 * 直购礼包
		 */
		public static const THREE_GIFT_INIT:int = 40050;
		public static const THREE_GIFT_GET:int = 40051;
		 
		 
		/**
		 * 军团聊天系统收取世界消息
		 */
		public static const ARMY_GROUP_GET_WORLD_MSG:int=35880;
		/**
		 * 军团聊天系统发送世界消息
		 */
		public static const ARMY_GROUP_SEND_WORLD_MSG:int=35849;
		/**
		 * 军团聊天系统收取城市消息
		 */
		public static const ARMY_GROUP_GET_CITY_MSG:int=35881;
		/**
		 * 军团聊天系统发送城市消息
		 */
		public static const ARMY_GROUP_SEND_CITY_MSG:int=35850;
		/**
		 * 获取城市战斗记录
		 */
		public static const ARMY_GROUP_GET_CITY_REPORT:int = 35862;
		
		/**
		 * NPC军团信息
		 */
		public static const ARMY_GROUP_NPC_INFO:int = 35874;
		
		/**
		 * 军团战刷新单个格子数据
		 */
		public static const ARMY_GROUP_UPDATE_ONE_PIECE:int = 35875;

		/**
		 * 将某人从地图中移除
		 */
		public static const ARMY_GROUP_REMOVE_PERSON:int=35851;

		/**
		 * 登陆游戏面板列表
		 */
		public static const GAME_BOARD_GET_LIST:int = 35901;
		
		/**
		 * 建筑物帮助
		 */
		public static const BUILDING_HELP_INIT:int = 36180;
		public static const BUILDING_HELP_ASK_HELP:int = 36181;
		public static const BUILDING_HELP_DO_HELP:int = 36182;
		public static const BUILDING_HELP_UPDATE:int = 36183;
		
		public static const BUILDING_HELP_BOARD:int = 36186;
		 
		/**战斗跳过*/
		public static const FIGHT_SKIP:int=20219;

		/**
		 * 星际迷航
		 */
		/**
		 * 打开面板时
		 */
		public static const STAR_TREK_INIT_MENU:int=20320;

		/**
		 * 打开盒子
		 */
		public static const STAR_TREK_OPEN_BOX:int=20321;

		/**
		 * 领奖励，开宝箱，得buff
		 */
		public static const STAR_TREK_GET_THINGS:int = 20322;
		
		/**
		 * 分享接口
		 */
		public static const GET_SHARE_INFO:int = 36000;
		public static const ADD_SHARE_TIMES:int = 36001;
		public static const RECORD_AUTH:int = 36002;

		/**
		 * 重置游戏
		 */
		public static const STAR_TREK_RESET_MENU:int=20325;
		public static const STAR_TREK_FINAL_REWARD:int=20326;
		/*** 战斗-布阵*/
		public static const STAR_TREK_FIGHT:int=20323;
		/*** 战斗-开战*/
		public static const STAR_TREK_ONFIGHT:int=20324;
		
		/**打开周卡面板*/
		public static const OPEN_WEEK_CARD:int=36050;
		/**领取周卡奖励*/
		public static const CLAIM_WEEK_CARD:int=36051;
		/**打开升级礼包面板*/
		public static const OPEN_LEVEL_GIFT:int=36080;
		/**
		 *雷达扫荡券 
		 */
		public static const RADER_SWEEP_PROP:int = 30167;
		public static const CLAIM_LEVEL_GIFT:int = 36081;
		
		/**
		 *人数衰减 面板
		 */
		public static const PEOPLE_FALL_OFF_PANNEL:int = 32130;
		/**
		 *人数衰减 重置
		 */
		public static const PEOPLE_FALL_OFF_RESET:int = 32132;
		/**
		 *人数衰减 刷新倍率
		 */
		public static const PEOPLE_FALL_OFF_RATE:int = 32133;
		//人数衰减进入战场
		public static const PEOPLE_FALL_OFF_ENTER:uint=32134;
		//人数衰减开始战斗
		public static const PEOPLE_FALL_OFF_FIGHTING:uint=32135;
		//人数衰减增加位置
		public static const PEOPLE_FALL_OFF_ADDPOS:uint=32131;
		/**
		 *雷达扫荡 
		 */
		public static const RADAR_SWEEP:int=36081;
		/**
		 * 福利活动列表
		 */
		public static const WELFARE_ACT_LIST:int = 36091;
		
		/**打开签到界面*/
		public static const SIGNIN_OPEN:int = 33300;
		/**7日签到领取*/
		public static const SIGNIN_7_GET:int = 33301;
		/**7日补签*/
		public static const SIGNIN_7_REPAIR:int = 33302;
		/**月签到*/
		public static const SIGNIN_30_GET:int = 33303;
		/**月补签*/
		public static const SIGNIN_30_REPAIR:int = 33304;
		/**打开限时任务*/
		public static const TIME_LIMIT_TASK_OPEN:int = 32171;
		/**领取限时任务奖励*/
		public static const TIME_LIMIT_TASK_GET:int = 32172;
		
		/**
		 * 获取跑马灯消息
		 */
		public static const GET_BOARD:int = 36200;
		
		/**
		 * 后端跑马灯推送
		 */
		public static const BOARD_PUSH:int = 36201;
		
		/**
		 *  堡垒活动
		 */
		/**进入堡垒活动*/
		public static const FORTRESS_ENTER:int = 32100;
		/**进入堡垒战斗*/
		public static const FORTRESS_ENTER_CAMP:int = 32101;
		/**开始堡垒战斗*/
		public static const FORTRESS_START_CAMP:int = 32102;
		/**堡垒扫荡*/
		public static const FORTRESS_SWEP:int = 32103;
		/**堡垒  购买攻击次数*/
		public static const FORTRESS_BUY_ATTACK:int = 32104;
		/**堡垒  打开排行榜*/
		public static const FORTRESS_ENTER_RANK:int = 32105;
		/**堡垒  领取*/
		public static const FORTRESS_REWARD:int = 32106;
		/**战斗波数*/
		public static const FIGHT_ROUND:int = 80107;
		/**使用道具减少时间*/
		public static const Build_Item_CD:int = 20010;
		
		/**
		 * 草船借箭
		 * 
		 */	
		/**获得信息*/
		public static const CAOCHUAN_GET_INFO:int = 36100;
		/**购买战斗次数*/
		public static const CAOCHUAN_BUY_TIMES:int = 36101;
		/**购买商店商品*/
		public static const CAOCHUAN_BUY_SHOP_ITEM:int = 36102;
		/**获得历史最高奖励*/
		public static const CAOCHUAN_HISTORY_MAX:int = 36103;
		/**获得当日累计奖励*/
		public static const CAOCHUAN_DAY_REWARD:int = 36104;
		/**进入战场*/
		public static const CAOCHUAN_ENTER_CAMP:int = 36105;
		/**开始战斗*/
		public static const CAOCHUAN_START_FIGHT:int = 36106;
		/**获取排行榜信息*/
		public static const CAOCHUAN_OPEN_RANK:int = 36107;
		
		/**获取VIP商店*/
		public static const GET_VIP_SHOP:uint=33202;
		/**VIP商店购买*/
		public static const VIP_SHOP_BUY:uint=33203;
		
		/**
		 * 奇门八卦
		 */	
		/**进入玩法*/
		public static const BAGUA_ENTER:int = 32140;
		/**刷新战斗组*/
		public static const BAGUA_REFRESH:int = 32141;
		/**重置*/
		public static const BAGUA_RESET:int = 32142;
		/**领取进度奖励*/
		public static const BAGUA_GET_STEPREWARD:int = 32143;
		/**挑战*/
		public static const BAGUA_ENTER_CAMP:int = 32144;
		/**开始战斗*/
		public static const BAGUA_START_FIGHT:int = 32145;

		/**华容道-进入玩法*/
		public static const KLOTSKI_GETINFO:int = 32150;
		/**华容道-进入关卡*/
		public static const KLOTSKI_SELECTSTAGE:int = 32151;
		/**华容道-刷新禁用单位*/
		public static const KLOTSKI_REFRESH:int = 32152;
		/**华容道-禁用单位*/
		public static const KLOTSKI_FORBID:int = 32153;
		/**华容道-双倍*/
		public static const KLOTSKI_DOUBLE:int = 32154;
		/**华容道-领取奖励*/
		public static const KLOTSKI_REWARD:int = 32155;
		/**华容道-重置所有关卡*/
		public static const KLOTSKI_RESET:int = 32156;
		/**华容道-进入战斗*/
		public static const KLOTSKI_ENTERFIGHT:int = 32157;
		/**华容道-开始战斗*/
		public static const KLOTSKI_STARTFIGHT:int = 32158;
		
		/**
		 * 新手帮助
		 */
		/**帮助-打开界面*/
		public static const PLAYER_HELP_OPEN:int = 36120;
		/**帮助-领取奖励*/
		public static const PLAYER_HELP_GET:int = 36121;
		/**帮助-进入战场*/
		public static const PLAYER_FIGHT_ENTER:int = 36122;
		/**帮助-开始战斗*/
		public static const PLAYER_FIGHT_START:int = 36123;
		
		/**
		 *工会科技面板 
		 */
		public static const TECHNOLOGY_PANNEL:int = 30351;
		/**
		 *工会推荐
		 */
		public static const TECHNOLOGY_RECOMMOND:int = 30354;
		/**
		 *工会捐献面板
		 */
		public static const TECHNOLOGY_DONATEVIEW:int = 30352;
		/**
		 *工会捐献
		 */
		public static const TECHNOLOGY_DONATE:int = 30353;
		/**
		 *工会普通捐献重置
		 */
		public static const TECHNOLOGY_DONATERESET:int = 30355;
		
		/***/
		public static const Get_Military_Reward:int = 30719
		
		/***/
		public static const SKIN_COMPOSE:int = 30061;
		/***/
		public static const SKIN_STRENGTH:int = 30062
		/***/
		public static const SKIN_EQUIP:int = 30063
		/***/
		public static const SKIN_STRENGTH_ONCE:int = 30064
		
		/*********世界BOSS*****/
		/**打开boss界面*/
		public static const BOSS_OPEN_VIEW:int = 36300;
		/**进入boss战场*/
		public static const BOSS_ENTER_BATTLE_FIELD:int = 36301;
		/**离开战场*/
		public static const BOSS_LEAVE_BATTLE_FIELD:int = 36302;
		/**获取我方布阵列表*/
		public static const BOSS_GET_MYTEAM:int = 36303;
		/**进入布阵界面*/
		public static const BOSS_ENTER_PRESET:int = 36304;
		/**保存布阵*/
		public static const BOSS_SAVE_PRESET:int = 36305;
		/**撤退布阵*/
		public static const BOSS_EXIT_PRESET:int = 36306;
		/**获取排行榜信息*/
		public static const BOSS_RANK_INFO:int = 36307;
		
		/**地图聊天*/
		public static const BOSS_MAP_CHAT:int = 36310;
		/**移动格子*/
		public static const BOSS_MOVE:int = 36311;
		/**发起战斗*/
		public static const BOSS_FIGHT:int = 36312;
		/**设置队伍自动*/
		public static const BOSS_AUTO:int = 36313;
		/**购买行动力*/
		public static const BOSS_BUY_ACTION:int = 36314;
		/**战斗地图格子信息*/
		public static const BOSS_POS_INFO:int = 36315;
		/**队伍立即复活*/
		public static const BOSS_REVIVE:int = 36316;
		/**设置粮草保护*/
		public static const BOSS_FOOD_PROTECT:int = 36317;
		/**开启预设布阵*/
		public static const BOSS_START_PRESET:int = 36318;
		/**购买buff*/
		public static const BOSS_BUY_BUFF:int = 36319;
		
		/*****后端主动推送****/
		/**世界BOSS地图聊天*/
		public static const BOSS_SERVER_CHAT:int = 36330;
		/**推送——队伍移动*/
		public static const BOSS_SERVER_MOVE:int = 36331;
		/**推送——队伍撤退*/
		public static const BOSS_SERVER_EXIT:int = 36332;
		/**推送——队伍死亡*/
		public static const BOSS_SERVER_DIED:int = 36333;
		/**推送——粮草不足*/
		public static const BOSS_SERVER_FOOD_LESS:int = 36334;
		/**推送——队伍布阵编辑*/
		public static const BOSS_SERVER_EDITOR:int = 36335;
		/**推送——队伍数量变化*/
		public static const BOSS_SERVER_TEAM_CHANGE:int = 36336;
		/**推送——战斗*/
		public static const BOSS_SERVER_FIGHT:int = 36337;
		/**推送——战斗结束*/
		public static const BOSS_SERVER_END:int = 36339;
		
		/**
		 *获取世界boss任务列表 
		 */
		public static const BOSS_MISSION_INIT:int =  36308;
		/**
		 * 获取世界boss任务奖励
		 */
		public static const BOSS_MISSION_GET_REWARDS:int =  36309;
		/**
		 * 翻牌子界面
		 */
		public static const TURN_CARDS_VIEW:int =  40036;
		/**
		 * 翻牌子
		 */
		public static const TURN_CARDS:int =  40037;
		/**
		 * 折扣商店界面
		 */
		public static const DISCOUNT_VIEW:int =  32160;
		/**
		 * 折扣商店购买
		 */
		public static const DISCOUNT_BUY:int =  32161;
		/**
		 * 老虎机界面
		 */
		public static const TIGER_MACHINE_VIEW:int =  40066;
		/**
		 * 老虎机开奖
		 */
		public static const TIGER_MACHINE_START:int =  40067;
		/**
		 * 老虎机排行榜，单页请求
		 */
		public static const TIGER_RANK_PAGE:int =  40068;
		/**
		 * 老虎机领奖
		 */
		public static const TIGER_RANK_GET_REWARD:int =  40069;
		/**
		 * 老虎机广播
		 */
		public static const TIGER_FORCAST:int=  80301;
		/**
		 * 离开老虎机
		 */
		public static const TIGER_MACHINE_LEAVE:int =  40080;
		
		/**
		 * 卡牌大师
		 * 
		 * */
		/**卡牌大师 · 打开界面*/
		public static const KAPAI_OPEN:int = 40070;
		/**卡牌大师 · 抽卡*/
		public static const KAPAI_DRAW_CARD:int = 40071;
		/**卡牌大师 · 卡牌兑换点数*/
		public static const KAPAI_CARD_NUM:int = 40072;
		/**卡牌大师 · 点数兑换卡牌*/
		public static const KAPAI_NUM_CARD:int = 40073;
		/**卡牌大师 · 领取卡牌奖励*/
		public static const KAPAI_CARD_REWARD:int = 40074;
		/**卡牌大师 · 打开排行榜*/
		public static const KAPAI_RANK:int = 40075;
		/**卡牌大师 · 领取排行榜奖励*/
		public static const KAPAI_RANK_REWARD:int = 40076;
		
		/**世界聊天·发送*/
		public static const WORLD_CHAT_SEND:int = 36202;
		/**世界聊天·接受*/
		public static const WORLD_CHAT_RECEIVE:int = 35895;
		
		/**玩家信息名片*/
		public static const PLAYER_INFO:int = 10114;
		
		/**
		 * 酿酒活动
		 * */
		/**打开活动*/
		public static const NIANGJIU_OPEN:int = 50010;
		/**炼石*/
		public static const NIANGJIU_LIANSHI:int = 50011;
		/**合成*/
		public static const NIANGJIU_HECHENG:int = 50012;
		
		/**今日禁止弹出活动提示弹层*/
		public static const TOTAY_FORBID:int = 35902;
		
		
		/**
		 * 爬塔
		 * */
		/**爬塔·进入玩法*/
		public static const PATA_ENTER:int = 50020;
		/**爬塔·进入战场 */
		public static const PATA_ENTER_BATTLE:int = 50021;
		/**爬塔·挑战 */
		public static const PATA_BATTLE:int = 50022;
		/**爬塔·扫荡 */
		public static const PATA_SAODANG:int = 50023;
		/**爬塔·领取章节奖励 */
		public static const PATA_GET_ZHANGJIE:int = 50024;
		/**爬塔·重置 */
		public static const PATA_RESET:int = 50025;
		
		/**兵种升级主动技能*/
		public static const BINGZHONG_UPDATE_SKILL:int = 30066;
		
		public static function getServerEventKey(serviceId:*):String
		{
			return "msg_" + serviceId;
		}
	}
}
