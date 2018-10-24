package game.global
{
	import game.common.ResourceManager;
	import game.global.data.DBSkill2;
	import game.global.event.Signal;
	import game.global.vo.AwakenSpecialityVo;
	import game.global.vo.AwakenTypeVo;
	import game.global.vo.AwakenVo;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.BuildingVo;
	import game.global.vo.CommonGuideVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.GeneLevelVo;
	import game.global.vo.HomeScenceConfigVo;
	import game.global.vo.ItemVo;
	import game.global.vo.JYStageChapterVo;
	import game.global.vo.LangCigVo;
	import game.global.vo.ObstacleVo;
	import game.global.vo.PvpLevelVo;
	import game.global.vo.PvpMathCostVo;
	import game.global.vo.PvpRewardVo;
	import game.global.vo.SkillBuffVo;
	import game.global.vo.SkillControlVo;
	import game.global.vo.SkillVo;
	import game.global.vo.StageChapterRewardVo;
	import game.global.vo.StageChapterVo;
	import game.global.vo.StageLevelVo;
	import game.global.vo.VIPVo;
	import game.global.vo.VoHasTool;
	import game.global.vo.WorldBossBaseParamVo;
	import game.global.vo.funGuide;
	import game.global.vo.heroUsedVo;
	import game.global.vo.itemSourceVo;
	import game.global.vo.pvpShopItemVo;
	import game.global.vo.quickMsgVo;
	import game.global.vo.reVo;
	import game.global.vo.Card.CardCostVo;
	import game.global.vo.Card.CardFreeItemVo;
	import game.global.vo.Card.CardParamBaseVo;
	import game.global.vo.Card.CardParamVo;
	import game.global.vo.Card.CardPayItemVo;
	import game.global.vo.Card.CardPvwVo;
	import game.global.vo.activity.ActivityListVo;
	import game.global.vo.activity.CheckInVo;
	import game.global.vo.activity.SevenDaysVo;
	import game.global.vo.activity.SignInVo;
	import game.global.vo.advance.AdvanceVo;
	import game.global.vo.arena.ArenaGroupVo;
	import game.global.vo.arena.ArenaNPCVo;
	import game.global.vo.arena.ArenaRankRewardVo;
	import game.global.vo.arena.ArenaRankVo;
	import game.global.vo.arena.ArenaRefeshVo;
	import game.global.vo.arena.ArenaResetVo;
	import game.global.vo.arena.ArenaScoreVo;
	import game.global.vo.arena.ArenaShopVo;
	import game.global.vo.armyGroup.ArmyGroupBaseParamVo;
	import game.global.vo.armyGroup.ArmyGroupCityVo;
	import game.global.vo.armyGroup.ArmyGroupDebuffVo;
	import game.global.vo.armyGroup.ArmyGroupFilterWordsVo;
	import game.global.vo.armyGroup.ArmyGroupJuntuanMilitaryVo;
	import game.global.vo.armyGroup.ArmyGroupKillReVo;
	import game.global.vo.armyGroup.ArmyGroupKillVo;
	import game.global.vo.armyGroup.ArmyGroupMiRankVo;
	import game.global.vo.armyGroup.ArmyGroupMiReVo;
	import game.global.vo.armyGroup.ArmyGroupMilitaryPointVo;
	import game.global.vo.armyGroup.ArmyGroupNpcNumVo;
	import game.global.vo.armyGroup.ArmyGroupNpcVo;
	import game.global.vo.armyGroup.ArmyGroupProtectVo;
	import game.global.vo.armyGroup.ArmyGroupRankVo;
	import game.global.vo.armyGroup.ArmyGroupSeasonVo;
	import game.global.vo.armyGroup.ArmyGroupSpRoomVo;
	import game.global.vo.armyGroup.ArmyGroupStoreVo;
	import game.global.vo.bingBook.BingBookFinishPrice;
	import game.global.vo.bingBook.BingBookParamVo;
	import game.global.vo.bingBook.BingBookRefreshPriceVo;
	import game.global.vo.equip.EquipParamVo;
	import game.global.vo.equip.EquipmentBaptizeVo;
	import game.global.vo.equip.EquipmentIntensifyVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.EquipmentMaxVo;
	import game.global.vo.equip.EquipmentRateVo;
	import game.global.vo.equip.EquipmentSuitVo;
	import game.global.vo.friend.MessageConfigVo;
	import game.global.vo.guild.GuildBossCost;
	import game.global.vo.guild.GuildBossVo;
	import game.global.vo.guild.GuildContributeVo;
	import game.global.vo.guild.GuildInfoVo;
	import game.global.vo.guild.GuildItemVo;
	import game.global.vo.guild.GuildLevelVo;
	import game.global.vo.guild.GuildParamsVo;
	import game.global.vo.guild.GuildWelfareVo;
	import game.global.vo.militaryHouse.MilitartyBlockPrice;
	import game.global.vo.militaryHouse.MilitaryBlockVo;
	import game.global.vo.militaryHouse.MilitaryHeroScore;
	import game.global.vo.militaryHouse.MilitaryScore;
	import game.global.vo.militaryHouse.MilitaryUnitScore;
	import game.global.vo.mine.MineFightTimeVo;
	import game.global.vo.mine.MineFightVo;
	import game.global.vo.mine.MineInfoVo;
	import game.global.vo.mine.MineProtectTimeVo;
	import game.global.vo.mission.DailyScoreVo;
	import game.global.vo.mission.MissionVo;
	import game.global.vo.mission.MissionXishuVo;
	import game.global.vo.relic.TransportBookVo;
	import game.global.vo.relic.TransportParam;
	import game.global.vo.relic.TransportPlanVo;
	import game.global.vo.relic.TransportPlanpriceVo;
	import game.global.vo.relic.TransportPrice1Vo;
	import game.global.vo.relic.TransportPriceVo;
	import game.global.vo.relic.TransportVehicleVo;
	import game.global.vo.starTrek.StarTrekBuffsVo;
	import game.global.vo.starTrek.StarTrekEventsVo;
	import game.global.vo.starTrek.StarTrekGridVo;
	import game.global.vo.starTrek.StarTrekPricesVo;
	import game.global.vo.starTrek.StarTrekShopVo;
	import game.global.vo.teamCopy.TeamFightBuyVo;
	import game.global.vo.teamCopy.TeamFightLevelVo;
	import game.global.vo.teamCopy.TeamFightParamVo;
	import game.global.vo.teamCopy.TeamFightRefreshVo;
	import game.global.vo.tech.TechLevelVo;
	import game.global.vo.tech.TechPointVo;
	import game.global.vo.tech.TechUpdateVo;
	import game.global.vo.unit.UnitParameterVo;
	import game.global.vo.unit.UnitUpgradeExpVo;
	import game.global.vo.worldBoss.BossBuyVo;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.global.vo.worldBoss.BossLevelVo;
	import game.global.vo.worldBoss.BossRankVo;
	import game.global.vo.worldBoss.BossSellItemVo;
	import game.module.equipFight.vo.equipFightChapterVo;
	import game.module.equipFight.vo.equipFightLevelVo;
	import game.module.friendCode.FriendCodeVo;
	import game.module.guild.GuildListItem;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.net.Loader;
	import laya.net.URL;
	import laya.resource.Resource;
	import laya.ui.Image;
	import laya.utils.Browser;
	import laya.utils.Handler;

	public class GameConfigManager
	{

		/***
		 *全局配置表控制器
		 */
		private static var _instance:GameConfigManager;


		public function GameConfigManager()
		{
			if (_instance)
			{
				throw new Error("GameConfigManager,不可new.");
			}
			_instance=this;
		}



		public static function get intance():GameConfigManager
		{
			if (_instance)
				return _instance;
			_instance=new GameConfigManager;
			return _instance;
		}

//		public static var buildingList_json:Object;  //建筑数据的json格式
		public static var buildingList_vos:Array=[]; //建筑数据的list格式

//		public static var buildingUpgrade_json:Object;  //建筑数据(升级)的json格式
		public static var buildingUpgrade_vos:Array=[]; //建筑数据(升级)的list格式
		public static var buildingQueue_vos:Object={};
//		public static var buildingBarrier_json:Object; //障碍物类型的json格式
		public static var buildingBarrier_vos:Array=[]; //障碍物类型的list格式

//		public static var items_json:Object; 		//道具的json格式
		public static var items_vos:Array=[]; //道具的list格式
		public static var items_dic:Object={}; //道具的键值对格式
		private static var _itemSource_dic:Object; //道具获取
		
		/** 
		 * 分享信息
		 */
		public static var ShareInfo:Object = { };

//		public static var unit_skill_json:Object ;  //技能JSON格式
		public static var unit_skill_dic:Object={}; //技能键值对格式

		public static var unit_json:Object; //兵种json格式
		public static var unit_dic:Object={}; //兵种键值对格式

//		public static var skill_buff_json:Object;   //buff json格式
		public static var skill_buff_dic:Object={}; //buff键值对格式

//		public static var stage_chapter_json:Object;   //章节 json格式
		public static var stage_chapter_dic:Object={}; //章节键值对格式
		public static var stage_chapter_arr:Array=[]; //章节数组格式

		public static var stage_chapter_jy_dic:Object={}; //精英章节键值对格式
		public static var stage_chapter_jy_arr:Array=[]; //精英章节数组格式

//		public static var stage_level_json:Object;   //关卡 json格式
		public static var stage_level_dic:Object={}; //关卡键值对格式
		public static var stage_level_arr:Array=[]; //关卡数组格式

		public static var stage_level_jy_dic:Object={}; //精英关卡键值对格式
		public static var stage_level_jy_arr:Array=[]; //精英关卡数组格式

		public static var homeScenceConfig_json:Object;
		public static var homeScenceConfig_vo:HomeScenceConfigVo;

//		public static var card_param_json:Object;	//抽卡配置
		public static var card_param:CardParamVo; //抽卡基础信息

		public static var boss_param:WorldBossBaseParamVo; //世界boss基础配置

		public static var boss_buy_arr:Array=[]; //购买boss挑战次数
		public static var boss_rank_arr:Array=[]; //boss战排名物品奖励
		public static var boss_sell_item_arr:Array=[]; //boss战购买道具
		public static var boss_level_arr:Array=[]; //boss等级信息

		public static var re_list:Array=[];

		private static var _awakenVoDic:Object;
		private static var _awakenTypeVoDic:Object;
		private static var _awakenSpecialityVoArr:Array;

		/**
		 * 遗迹
		 */
		public static var transportParam:TransportParam;

		public static var TransportVehicleList:Array=[];

		public static var TransportPlanList:Array=[];

		public static var TransportPenaltyList:Array=[];
		public static var TransportPriceList:Array=[];

		public static var TransportPlanpriceList:Array=[];
		public static var TransportPrice1List:Array=[];
		public static var TransportBookList:Array=[];
		public static var UnitUpgradeExpList:Array=[];
		/**
		 * 抽卡
		 */
		public static var CardCostList:Array=[];
		public static var CardFreeItemList:Array=[];
		public static var CardPayItemList:Array=[];
		public static var CardPvwList:Array=[];
		/**
		 * 装备
		 */
		public static var equipParamVo:EquipParamVo;
		public static var EquipmentList:Array=[];
		public static var EquipmentSuitList:Array=[];
		public static var EquipmentBaptizeList:Array=[];
		public static var EquipmentIntensifyList:Array=[];
		public static var EquipmentRateList:Array=[];
		public static var EquipmentMaxList:Array=[];
		public static var UnitParameterList:Array=[];

		/**
		 * 工会参数表
		 */
		public static var guild_params:Object={};
		/**
		 * 工会BOSS
		 */
		public static var guild_boss_vec:Vector.<GuildBossVo>=new Vector.<GuildBossVo>();
		/**
		 * 工会捐献
		 */
		public static var guild_contribute_vec:Vector.<GuildContributeVo>=new Vector.<GuildContributeVo>();
		/**
		 * 工会福利
		 */
		public static var guild_welfare_vec:Vector.<GuildWelfareVo>=new Vector.<GuildWelfareVo>();
		/**
		 * 工会物品
		 */
		public static var guild_shop_vec:Vector.<GuildItemVo>=new Vector.<GuildItemVo>();
		/**
		 * 工会信息
		 */
		public static var guild_info_vec:Vector.<GuildInfoVo>=new Vector.<GuildInfoVo>();

		/**
		 * 公会升级信息
		 */
		public static var guild_level_vec:Vector.<GuildLevelVo>=new Vector.<GuildLevelVo>();

		/**
		 * 公会BOSS挑战消耗
		 */
		public static var guild_bossCost_vec:Vector.<GuildBossCost>=new Vector.<GuildBossCost>();


		/**
		 * 科技树升级信息
		 */
		public static var tech_update_vec:Vector.<TechUpdateVo>=new Vector.<TechUpdateVo>();

		/**
		 * 科技树等级信息
		 */
		public static var tech_level_vec:Vector.<TechLevelVo>=new Vector.<TechLevelVo>();

		/**
		 * 科技树升级点信息
		 */
		public static var tech_point_vec:Vector.<TechPointVo>=new Vector.<TechPointVo>();


		/**
		 * 兵书副本默认参数
		 */
		public static var bingBook_param_vec:Vector.<BingBookParamVo>=new Vector.<BingBookParamVo>();

		/**
		 * 兵书副本刷新价格表
		 */
		public static var bingBook_refresPrice_vec:Vector.<BingBookRefreshPriceVo>=new Vector.<BingBookRefreshPriceVo>();

		/**
		 * 兵书副本立刻完成价格
		 */
		public static var bingBook_finishPrice_vec:Vector.<BingBookFinishPrice>=new Vector.<BingBookFinishPrice>();

		/**
		 * 竞技场排行奖励
		 */
		public static var arena_rankRewawrd_vec:Vector.<ArenaRankVo> = new Vector.<ArenaRankVo>();
		
		/**
		 * 竞技场刷新价格
		 */
		public static var arena_refreshPrice:Array = [];

		/**
		 * 竞技场点数奖励
		 */
		public static var arena_point_vec:Vector.<ArenaScoreVo>=new Vector.<ArenaScoreVo>();

		/**
		 * 竞技场商城
		 */
		public static var arena_shop_vec:Vector.<ArenaShopVo>=new Vector.<ArenaShopVo>();

		/**
		 * 竞技场重置价格
		 */
		public static var arena_reset_vec:Vector.<ArenaResetVo>=new Vector.<ArenaResetVo>();

		/**
		 * 竞技场分组
		 */
		public static var arena_group_vec:Vector.<ArenaGroupVo>=new Vector.<ArenaGroupVo>();

		/**
		 * 竞技场NPC分组
		 */
		public static var arena_npc_vec:Object={}

		/**
		 * 矿点信息列表
		 */
		public static var mine_info_vec:Vector.<MineInfoVo>=new Vector.<MineInfoVo>();
		/**
		 * 占矿购买次数价格
		 */
		public static var mine_time_price_vec:Vector.<MineFightTimeVo>=new Vector.<MineFightTimeVo>();
		/**
		 * 占矿保护价格
		 */
		public static var mine_protect_price_vec:Vector.<MineProtectTimeVo>=new Vector.<MineProtectTimeVo>();
		/**
		 * 占矿默认怪物
		 */
		public static var mine_npc_vec:Vector.<MineFightVo>=new Vector.<MineFightVo>();

		/**
		 * 升阶配置表
		 */
		public static var advance_upgrade_vec:Vector.<AdvanceVo>=new Vector.<AdvanceVo>();

		/**
		 * 军府配置表
		 */
		public static var military_block_info:Vector.<MilitaryBlockVo>=new Vector.<MilitaryBlockVo>();
		public static var military_price_info:Vector.<MilitartyBlockPrice>=new Vector.<MilitartyBlockPrice>();
		public static var military_score:Vector.<MilitaryScore>=new Vector.<MilitaryScore>();
		public static var military_unit_score:Vector.<MilitaryUnitScore>=new Vector.<MilitaryUnitScore>();
		public static var military_hero_score:Vector.<MilitaryHeroScore>=new Vector.<MilitaryHeroScore>();


		/**
		 * 功能开启列表
		 */
		public static var fun_open_vec:Vector.<funGuide>=new Vector.<funGuide>();

		/**
		 * 游戏活动列表
		 */
		public static var activiey_list_vec:Vector.<ActivityListVo>=new Vector.<ActivityListVo>();

		public static var seven_days_info:Vector.<SevenDaysVo>=new Vector.<SevenDaysVo>();

		/**
		 * 补签价格
		 */
		public static var signInInfo:Vector.<SignInVo> = new Vector.<SignInVo>();
		
		public static var fundationInfo:Object = { };

		/**
		 * 功能引导
		 */
		public static var common_guide_vec:Object={};

		/**
		 * 任务对象池
		 */
		public static var missionInfo:Object = { };
		
		/**
		 * 日常积分
		 */
		public static var dailiyScore:Vector.<DailyScoreVo>;

		/**
		 * 日常任务系数
		 */
		public static var missionParame_vec:Object = { };
		
		/**
		 * 跑马灯配置
		 */
		public static var boardcastVec:Object = {};

		public static var messageConfig:MessageConfigVo;


		public static var heroUseds:Object;

		public static var langCigList:Array=[];

		/**
		 * VIP相关信息
		 */
		public static var vip_info:Vector.<VIPVo>=new Vector.<VIPVo>();

		/**
		 * 组队战斗
		 */
		public static var teamFightParamVo:TeamFightParamVo;
		public static var TeamFightLevelList:Array=[];
		public static var TeamFightBuyList:Array=[];
		public static var TeamFightRefreshList:Array=[];

		/**
		 * 军团
		 */
		public static var ArmyGroupNpcNumList:Vector.<ArmyGroupNpcNumVo>=new Vector.<ArmyGroupNpcNumVo>();
		public static var ArmyGroupBaseParam:ArmyGroupBaseParamVo;
		public static var ArmyGroupNpcList:Vector.<ArmyGroupNpcVo>=new Vector.<ArmyGroupNpcVo>();
		public static var ArmyGroupDebuffList:Vector.<ArmyGroupCityVo>=new Vector.<ArmyGroupCityVo>();
		public static var ArmyGroupCityList:Vector.<ArmyGroupCityVo>=new Vector.<ArmyGroupCityVo>();
		public static var ArmyGroupSpList:Vector.<ArmyGroupSpRoomVo>=new Vector.<ArmyGroupSpRoomVo>();
		public static var ArmyGroupKillReList:Object={};
		public static var ArmyGroupMiRankList:Vector.<ArmyGroupMiRankVo>=new Vector.<ArmyGroupMiRankVo>();
		public static var ArmyGroupMiReList:Vector.<ArmyGroupMiReVo>=new Vector.<ArmyGroupMiReVo>();
		public static var ArmyGroupRankList:Vector.<ArmyGroupRankVo>=new Vector.<ArmyGroupRankVo>();
		public static var ArmyGroupJuntuanMilitary:Vector.<ArmyGroupJuntuanMilitaryVo>=new Vector.<ArmyGroupJuntuanMilitaryVo>;
		public static var ArmyGroupMilitaryPoint:Vector.<ArmyGroupMilitaryPointVo>=new Vector.<ArmyGroupMilitaryPointVo>;
		public static var ArmyGroupFoodMax:Object={};
		public static var ArmyGroupGuildMoneyMax:Object={};
		public static var ArmyGroupFilterWords:Array = [];
		public static var ArmyGroupFightMap:Object = { };
		public static var ArmyGroupBossBRInfo:Object = { };
		public static var ArmyGroupStoreVec:Vector.<ArmyGroupStoreVo> = new Vector.<ArmyGroupStoreVo>();
		public static var ArmyGroupSeasonVec:Vector.<ArmyGroupSeasonVo> = new Vector.<ArmyGroupSeasonVo>();
		public static var ArmyGroupStoreRePrice:Array = [];
		public static var ArmyGroupFoodCost:Object = { };
		public static var ArmyGroupProtectParam:ArmyGroupProtectVo;
		public static var ArmyGroupSeasonReward:Object = { };
		public static var ArmyGroupDeclarCostInfo:Object = { };
		
		
		/**
		 * 单英雄
		 */
		public static var LoneHeroReward:Object = { };
		public static var LoneHeroResetPrice:Array = [];
		public static var LoneHeroRefreshHero:Array = [];
		public static var LoneHeroRefreshRate:Array = [];
		
		
		// 星际迷航
		/**
		 * 星际迷航事件配置
		 */
		public static var StarTrekEvents:Vector.<StarTrekEventsVo>=new Vector.<StarTrekEventsVo>();

		/**
		 * 星际迷航重置价格
		 */
		public static var StarTrekPrices:Vector.<StarTrekPricesVo>=new Vector.<StarTrekPricesVo>();
		public static var StarTrekShopVec:Vector.<StarTrekShopVo>=new Vector.<StarTrekShopVo>();
		/**
		 * 星际迷航buff
		 */
		public static var StarTrekBuffs:Object={};

		/**
		 * 星际迷航格子
		 */
		public static var StarTrekGrid:Vector.<StarTrekGridVo> = new Vector.<StarTrekGridVo>();
		
		/**
		 * 邀请好友奖励
		 */
		public static var inviteFriendReward:Vector.<FriendCodeVo> = new Vector.<FriendCodeVo>();
		 
		/**
		 * 加载星际迷航配置表
		 *
		 */
		public function loadStarTrekConfig():void
		{
			var vo:*;
			var c:*;
			var maze_event_json:*=ResourceManager.instance.getResByURL("config/maze/maze_event.json");
			if (maze_event_json)
			{
				for each (c in maze_event_json)
				{
					vo=VoHasTool.hasVo(StarTrekEventsVo, c);
					StarTrekEvents[(vo as StarTrekEventsVo).id]=(vo);
				}
			}

			var maze_price_json:*=ResourceManager.instance.getResByURL("config/maze/maze_price.json");
			if (maze_price_json)
			{
				for each (c in maze_price_json)
				{
					vo=VoHasTool.hasVo(StarTrekPricesVo, c);
					StarTrekPrices[(vo as StarTrekPricesVo).id]=(vo);
				}
			}

			var maze_shop_json:*=ResourceManager.instance.getResByURL("config/maze/maze_shop.json");
			if (maze_shop_json)
			{
				for each (c in maze_shop_json)
				{
					vo=VoHasTool.hasVo(StarTrekShopVo, c);
					StarTrekShopVec[(vo as StarTrekShopVo).id]=(vo);
				}
			}

			var maze_grid_json:*=ResourceManager.instance.getResByURL("config/maze/maze_grid.json");
			if (maze_grid_json)
			{
				for each (c in maze_grid_json)
				{
					vo=VoHasTool.hasVo(StarTrekGridVo, c);
					StarTrekGrid[(vo as StarTrekGridVo).id]=(vo);
				}
			}
		}

		public function init():void
		{
			var vo:*;
			var c:*;
			var buildingList_json:*=ResourceManager.instance.getResByURL("config/building_list.json");
			if (buildingList_json)
			{
				for each (c in buildingList_json)
				{
//					vo = new BuildingVo(c);
					vo=VoHasTool.hasVo(BuildingVo, c);
					buildingList_vos.push(vo);
				}
			}
			var buildingQueue_json:* = ResourceManager.instance.getResByURL("config/building_queue.json");
			if (buildingQueue_json)
			{
				for each (c in buildingQueue_json)
				{
					buildingQueue_vos[c.id] = c;
				}
			}
//			trace("建筑队列:"+JSON.stringify(buildingQueue_vos));
			var buildingUpgrade_json:*=ResourceManager.instance.getResByURL("config/building_upgrade.json");
			if (buildingUpgrade_json)
			{
				for each (c in buildingUpgrade_json)
				{
					vo=VoHasTool.hasVo(BuildingLevelVo, c);
					buildingUpgrade_vos.push(vo);
				}
			}
			/**
			homeScenceConfig_json = ResourceManager.instance.getResByURL("staticConfig/HomeSceneConfig.json");
			if(homeScenceConfig_json)
			{
				homeScenceConfig_vo = VoHasTool.hasVo(HomeScenceConfigVo,homeScenceConfig_json["map"]);
			}
			 */

			var items_json:*=ResourceManager.instance.getResByURL("config/item.json");
			if (items_json)
			{
				for each (c in items_json)
				{
					vo=VoHasTool.hasVo(ItemVo, c);
					items_vos.push(vo);
					items_dic[(vo as ItemVo).id]=vo;
				}
			}

			var unit_skill_json:*=ResourceManager.instance.getResByURL("config/unit_skill.json");
			if (unit_skill_json)
			{
				for each (c in unit_skill_json)
				{
					vo=VoHasTool.hasVo(SkillVo, c);
					unit_skill_dic[(vo as SkillVo).skill_id]=vo;
				}
			}

			unit_json=ResourceManager.instance.getResByURL("config/unit.json");
			if (unit_json)
			{
				for each (c in unit_json)
				{
					vo=VoHasTool.hasVo(FightUnitVo, c);
					unit_dic[(vo as FightUnitVo).unit_id]=vo;
//					(vo as FightUnitVo).model = "2000";
				}
			}

			var skill_buff_json:*=ResourceManager.instance.getResByURL("config/unit_skill_buff.json");
			if (skill_buff_json)
			{
				for each (c in skill_buff_json)
				{
					vo=VoHasTool.hasVo(SkillBuffVo, c);
					skill_buff_dic[(vo as SkillBuffVo).buff_id]=vo;
				}
			}


			var hero_used:Object=ResourceManager.instance.getResByURL("config/hero_used.json");
			if (hero_used)
			{
				heroUseds={};
				for each (c in hero_used)
				{
					vo=VoHasTool.hasVo(heroUsedVo, c);
					heroUseds[c.id]=vo;
				}
			}

//			var langjson:Object = ResourceManager.instance.getResByURL("config/language.json");
//			if(langjson)
//			{
//				for each (c in langjson) 
//				{
//					GameLanguage.lang[c.key] = c.en;
//				}
//				Text.langPacks = GameLanguage.lang;
//			}

			/*var langCigjson:Object = ResourceManager.instance.getResByURL("config/langCig.json");
			if(langCigjson)
			{
				for each (c in langCigjson)
				{
					vo = VoHasTool.hasVo(LangCigVo,c);
					langCigList.push(vo);
				}
			}*/


			var equipment_list_json:Object=ResourceManager.instance.getResByURL("config/equipment_list.json");
			if (equipment_list_json)
			{
				for each (c in equipment_list_json)
				{
					vo=VoHasTool.hasVo(EquipmentListVo, c);
					EquipmentList[(vo as EquipmentListVo).equip]=(vo);
				}
			}
//			skill_control_dic;
			var re_list_json:Object=ResourceManager.instance.getResByURL("config/re_list.json");
			if (re_list_json)
			{
				for each (c in re_list_json)
				{
					
					vo = VoHasTool.hasVo(reVo, c);
					
					if (Browser.onAndriod && vo.channel == 1)
					{
						re_list.push(vo);
					}
					else if (Browser.onIOS && vo.channel == 2)
					{
						re_list.push(vo);
					}
					else if (!GameSetting.isApp)
					{
						re_list.push(vo);
					}
				}
			}
			//trace("充值列表：", re_list);

			var vipInfo:Object=ResourceManager.instance.getResByURL("config/vip_action_config.json");
			if (vipInfo)
			{

				for each (c in vipInfo)
				{
					vo=VoHasTool.hasVo(VIPVo, c);
					//vip_info[vo.level] = vo;
					vip_info.push(vo);
				}

			}
			
			var sInfo:Object=ResourceManager.instance.getResByURL("config/facebook_share.json");
			if (sInfo)
			{

				for each (c in sInfo)
				{
					ShareInfo[c.id] = c;
				}

			}
			
			var bcParam:Object = ResourceManager.instance.getResByURL("config/bc_canshu.json");
			
			GlobalRoleDataManger.instance.baseTime = parseInt(bcParam[1]["value"].split(",")[0]);
			GlobalRoleDataManger.instance.addTime = parseInt(bcParam[1]["value"].split(",")[1])-GlobalRoleDataManger.instance.baseTime;
			
			var bcInfo:Object = ResourceManager.instance.getResByURL("config/broadcast.json");
			if (bcInfo)
			{
				for each (c in bcInfo)
				{
					boardcastVec[c.id] = c;
				}
			}
			//trace("boardCarpar",boardcastVec)

			initFunOpenList();
			//loaderLang();
		}

		//初始化语言配置，单独分离。
		public function initLan(auto:Boolean=true):void
		{
			var langCigjson:Object=ResourceManager.instance.getResByURL("config/langCig.json");
			if (langCigjson)
			{
				for each (var c:* in langCigjson)
				{
					var vo:*=VoHasTool.hasVo(LangCigVo, c);
					langCigList.push(vo);
				}
			}
			auto && loaderLang();
		}

		private static var _thisLangCig:LangCigVo;

		public static function get thisLangCig():LangCigVo
		{
			if (!_thisLangCig)
			{
				//var langID:Number = GameLanguage.langID;
				var lan:String=(GameSetting.lang || "en-us");
				for (var i:int=0; i < langCigList.length; i++)
				{
					var vo:LangCigVo=langCigList[i];
					//if(vo.id == langID)
					if (vo.muti_language == lan)
					{
						_thisLangCig=vo;
						break;
					}
				}
				if (!_thisLangCig)
					_thisLangCig=langCigList[1];

			}
			return _thisLangCig;
		}

		private static var _quickMsgList:Array;

		public static function get quickMsgList():Array
		{
			if (_quickMsgList)
				return _quickMsgList;
			_quickMsgList=[];
			var _json:*=ResourceManager.instance.getResByURL("config/quick_msg.json");
			if (_json)
			{
				for each (var c:Object in _json)
				{
					var vo:*=VoHasTool.hasVo(quickMsgVo, c);
					_quickMsgList.push(vo);
				}
			}

			return _quickMsgList;
		}


		private static var _pvpLevelVoList:Array;

		public static function get pvpLevelVoList():Array
		{
			if (_pvpLevelVoList)
				return _pvpLevelVoList;
			_pvpLevelVoList=[];
			var _json:*=ResourceManager.instance.getResByURL("config/pvp_rank.json");
			if (_json)
			{
				for each (var c:Object in _json)
				{
					var vo:*=VoHasTool.hasVo(PvpLevelVo, c);
					_pvpLevelVoList.push(vo);
				}
			}
			return _pvpLevelVoList;
		}
		
		private static var _pvpMathCostVoList:Array;
		
		public static function get pvpMathCostVoList():Array
		{
			if (_pvpMathCostVoList)
				return _pvpMathCostVoList;
			_pvpMathCostVoList=[];
			var _json:*=ResourceManager.instance.getResByURL("config/pvp_cost.json");
			if (_json)
			{
				for each (var c:Object in _json)
				{
					var vo:*=VoHasTool.hasVo(PvpMathCostVo, c);
					_pvpMathCostVoList.push(vo);
				}
			}
			return _pvpMathCostVoList;
		}
		
		
		public function replaceFontFun(value:String):String
		{
			var vo:LangCigVo=langCigList[0];
			if (vo == thisLangCig)
				return value;
			var idx:Number=0;
			for (var i:int=0; i < vo.fontList.length; i++)
			{
				if (vo.fontList[i] == value)
				{
					idx=i;
					break;
				}
			}
			return thisLangCig.fontList[idx];
		}
		
		/**
		 * 单英雄活动初始化
		 */
		public function initLoneHero():void
		{
			var vo:*;
			var c:*;
			var lhRefresh:*=ResourceManager.instance.getResByURL("config/single_hero_refresh.json");
			if (lhRefresh)
			{
				for each (var c in lhRefresh)
				{
					LoneHeroRefreshHero.push(c);
				}
			}
			
			var lhReset:*=ResourceManager.instance.getResByURL("config/single_hero_reset.json");
			if (lhReset)
			{
				for each (var c in lhReset)
				{
					LoneHeroResetPrice.push(c);
				}
			}
			
			var lhRerate:*=ResourceManager.instance.getResByURL("config/single_hero_reprice.json");
			if (lhRerate)
			{
				for each (var c in lhRerate)
				{
					LoneHeroRefreshRate.push(c);
				}
			}
			
			var lhReward:*=ResourceManager.instance.getResByURL("config/single_hero_level.json");
			if (lhReward)
			{
				for each (var c in lhReward)
				{
					LoneHeroReward[c.id] = c;
				}
			}
			
		}
		
		/**
		 * 获取单英雄刷新英雄价格
		 * @param	t
		 * @return
		 */
		public function getLoneHeroResetPrice(t:int):int
		{
			
			var len:int=LoneHeroResetPrice.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= LoneHeroResetPrice[i].up)
				{
					return parseInt(LoneHeroResetPrice[i].price.split("=")[1]);
				}
			}
			return 180;
		}
		
		/**
		 * 获取单英雄重置关卡价格
		 * @param	t
		 * @return
		 */
		public function getLoneHeroRefreshPrice(t:int):int
		{
			var len:int=LoneHeroRefreshHero.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= LoneHeroRefreshHero[i].up)
				{
					return parseInt(LoneHeroRefreshHero[i].price.split("=")[1]);
				}
			}
			return 180;
		}
		
		/**
		 * 获取单英雄刷新倍率价格
		 * @param	t
		 * @return
		 */
		public function getLoneHeroRefreshRate(t:int):int
		{
			
			var len:int=LoneHeroRefreshRate.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= LoneHeroRefreshRate[i].up)
				{
					return parseInt(LoneHeroRefreshRate[i].price.split("=")[1]);
				}
			}
			return 180;
		}
		
		/**
		 * 军团配置表
		 */
		public function loaderArmyGroup():void
		{
			var vo:*;
			var c:*;
			var juntuan_canshu_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
			ArmyGroupBaseParam=new ArmyGroupBaseParamVo();
			if (juntuan_canshu_json)
			{
				for each (var c in juntuan_canshu_json)
				{

					switch (parseInt(c["id"]))
					{
						case 1:
							ArmyGroupBaseParam.maxGuildNum=c["value"];
							break;
						case 2:
							ArmyGroupBaseParam.declareWarTime=c["value"];
							break;
						case 3:
							ArmyGroupBaseParam.OutputTime=c["value"];
							break;
						case 4:
							ArmyGroupBaseParam.maxExploits=c["value"];
							break;
						case 5:
							ArmyGroupBaseParam.changeProtectTime=c["value"];
							break;
						case 6:
							ArmyGroupBaseParam.noChangeProtectTime=c["value"];
							break;
						case 7:
							ArmyGroupBaseParam.outPutNum=c["value"];
							break;
						case 8:
							ArmyGroupBaseParam.bigCityDWNum=c["value"];
							break;
						case 9:
							ArmyGroupBaseParam.cityDWCondition=c["value"];
							break;
						case 10:
							ArmyGroupBaseParam.cityDwNum=c["value"];
							break;
						case 15:
							ArmyGroupBaseParam.declarCityLv=c["value"];
							break;
						case 16:
							ArmyGroupBaseParam.declarPlayerNum=c["value"];
							break;
						case 20:
							ArmyGroupBaseParam.protectPrice=c["value"];
							break;
						case 41:
							ArmyGroupBaseParam.tresurePrice=c["value"];
							break;
						case 44:
							ArmyGroupBaseParam.normalBox=c["value"].split(";");
							break;
						case 45:
							ArmyGroupBaseParam.greenBox=c["value"].split(";");
							break;
						case 46:
							ArmyGroupBaseParam.blueBox=c["value"].split(";");
							break;
						case 47:
							ArmyGroupBaseParam.goldenBox=c["value"].split(";");
							break;
						case 50:
							ArmyGroupBaseParam.APInit = c["value"];
							break;
						case 51:
							ArmyGroupBaseParam.APReborn = c["value"];
							break;
						case 52:
							ArmyGroupBaseParam.moveCost = c["value"];
							break;
						case 55:
							ArmyGroupBaseParam.APMax = c["value"];
							break;
						case 58:
							ArmyGroupBaseParam.fightCost = c["value"];
							break;
						case 67:
							ArmyGroupBaseParam.sFreeTimes=c["value"].split(";");
							break;
						case 69:
							ArmyGroupBaseParam.rebornPrice = c["value"].split("=")[1];
							break;
						case 70:
							ArmyGroupBaseParam.protectReward = c["value"];
							trace("protectReward:", ArmyGroupBaseParam.protectReward);
							break;
						default:
							break;
					}
				}
				
			}

			var juntuan_npc_num_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_npc_num.json");
			if (juntuan_npc_num_json)
			{
				for each (var c in juntuan_npc_num_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupNpcNumVo, c);
					ArmyGroupNpcNumList[(vo as ArmyGroupNpcNumVo).id]=(vo);
				}
			}
			var juntuan_npc_json:*=ResourceManager.instance.getResByURL("config/npc_list.json");
			if (juntuan_npc_json)
			{
				for each (var c in juntuan_npc_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupNpcVo, c);
					ArmyGroupNpcList[(vo as ArmyGroupNpcVo).budui_id]=(vo);
				}
			}
			var juntuan_debuff_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_debuff.json");
			if (juntuan_debuff_json)
			{
				for each (var c in juntuan_debuff_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupDebuffVo, c);
					ArmyGroupDebuffList[(vo as ArmyGroupDebuffVo).num]=(vo);
				}
			}
			var juntuan_kill_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_kill.json");
			if (juntuan_kill_json)
			{
				for each (var c in juntuan_kill_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupKillVo, c);
					ArmyGroupDebuffList[(vo as ArmyGroupKillVo).LX]=(vo);
				}
			}

			ArmyGroupCityList=[];
			var juntuan_city_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
			if (juntuan_city_json)
			{
				for each (var c in juntuan_city_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupCityVo, c);
					//ArmyGroupCityList[(vo as ArmyGroupCityVo).id]=(vo);
					ArmyGroupCityList.push(vo);
				}
			}


			var juntuan_sp_room_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_sp_room.json");
			if (juntuan_sp_room_json)
			{
				for each (var c in juntuan_sp_room_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupSpRoomVo, c);
					ArmyGroupSpList[(vo as ArmyGroupSpRoomVo).XH]=(vo);
				}
			}

			var juntuan_kill_re_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_kill_re.json");
			if (juntuan_kill_re_json)
			{
				for each (var c in juntuan_kill_re_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupKillReVo, c);
					if (ArmyGroupKillReList[(vo as ArmyGroupKillReVo).SL] is Array)
					{
						ArmyGroupKillReList[(vo as ArmyGroupKillReVo).SL].push(vo);
					}
					else
					{
						ArmyGroupKillReList[(vo as ArmyGroupKillReVo).SL]=[];
						ArmyGroupKillReList[(vo as ArmyGroupKillReVo).SL].push(vo);
					}
				}
			}

			var juntuan_mi_rank_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_mi_rank.json");
			if (juntuan_mi_rank_json)
			{
				for each (var c in juntuan_mi_rank_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupMiRankVo, c);
					ArmyGroupMiRankList[(vo as ArmyGroupMiRankVo).PM]=(vo);
				}
			}

			var juntuan_mi_re_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_mi_re.json");
			if (juntuan_mi_re_json)
			{
				for each (var c in juntuan_mi_re_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupMiReVo, c);
					ArmyGroupMiReList[(vo as ArmyGroupMiReVo).id]=(vo);
				}
			}

			var juntuan_rank_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_rank.json");
			if (juntuan_rank_json)
			{
				for each (var c in juntuan_rank_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupRankVo, c);
					ArmyGroupRankList[(vo as ArmyGroupRankVo).PM]=(vo);
				}
			}

			var juntuan_military_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_military.json");
			if (juntuan_military_json)
			{
				for each (var c in juntuan_military_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupJuntuanMilitaryVo, c);
					ArmyGroupJuntuanMilitary[(vo as ArmyGroupJuntuanMilitaryVo).id]=(vo);
				}
			}

			var juntuan_military_point_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_military_point.json");
			if (juntuan_military_point_json)
			{
				for each (var c in juntuan_military_point_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupMilitaryPointVo, c);
					ArmyGroupMilitaryPoint[(vo as ArmyGroupMilitaryPointVo).id]=(vo);
				}
			}

			var juntuan_foodmax:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_food_max.json");
			if (juntuan_foodmax)
			{
				for each (var c in juntuan_foodmax)
				{
					ArmyGroupFoodMax[c.player_level]=c.max_limit;
				}
			}

			var juntuan_GuildMoneymax:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_guild_max.json");
			if (juntuan_GuildMoneymax)
			{
				for each (var c in juntuan_GuildMoneymax)
				{
					ArmyGroupGuildMoneyMax[c.guild_level]=c.max_limit;
				}

			}

			var juntuan_filter_words_json:*=ResourceManager.instance.getResByURL("config/filterWords.json");
			if (juntuan_filter_words_json)
			{
				for each (var c in juntuan_filter_words_json)
				{
					vo=VoHasTool.hasVo(ArmyGroupFilterWordsVo, c);
					ArmyGroupFilterWords.push((vo as ArmyGroupFilterWordsVo).word);
				}
			}
			
			var jt_fight_map:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_fight_map.json");
			if (jt_fight_map)
			{
				for each (var c in jt_fight_map)
				{
					ArmyGroupFightMap[c.H_id] = c;
				}
			}
			
			var jtBossBr:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_boss_br.json");
			if (jtBossBr)
			{
				for each (var c in jtBossBr)
				{
					ArmyGroupBossBRInfo[c.level] = c.br;
				}
			}
			
			var jtStore:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_shop.json");
			if (jtStore)
			{
				for each (var c in jtStore)
				{
					vo=VoHasTool.hasVo(ArmyGroupStoreVo, c);
					ArmyGroupStoreVec[(vo as ArmyGroupStoreVo).id] = vo;
				}
			}
			
			var jtStoreRe:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_shop_refresh.json");
			if (jtStoreRe)
			{
				for each (var c in jtStoreRe)
				{
					//vo=VoHasTool.hasVo(ArmyGroupStoreVo, c);
					ArmyGroupStoreRePrice.push(c);
				}
			}
			
			var fc:* = ResourceManager.instance.getResByURL("config/juntuan/juntuan_cost.json");
			if (fc)
			{
				for each (var c in fc)
				{
					ArmyGroupFoodCost[c.level] = c.cost;
				}
			}
			
			var js:* = ResourceManager.instance.getResByURL("config/juntuan/juntuan_season.json");
			if (js)
			{
				for each (var c in js)
				{
					ArmyGroupSeasonVec.push(c);
				}
			}
			
			var jtd:* = ResourceManager.instance.getResByURL("config/juntuan/juntuan_declare_cost.json");
			if (jtd)
			{
				for each (var c in jtd)
				{
					
					if (!ArmyGroupDeclarCostInfo[c.type])
					{
						ArmyGroupDeclarCostInfo[c.type] = { };
					}
					ArmyGroupDeclarCostInfo[c.type][c.title] = c;
				}
			}
			
			var jp:* = ResourceManager.instance.getResByURL("config/juntuan/juntuan_protect.json");
			if (jp)
			{
				ArmyGroupProtectParam = jp["commander"]
			}
			dealArmyGroupSeasonReward();
		}
		
		private function dealArmyGroupSeasonReward():void
		{
			ArmyGroupSeasonReward = { };
			var len:int = ArmyGroupSeasonVec.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				var tr:Array = [];
				var reArr:Array = ArmyGroupSeasonVec[i].season_reward.split(",");
				var l1:int = reArr.length;
				ArmyGroupSeasonReward[i+1] = { };
				for (var j:int = 0; j < l1; j++) 
				{
					var realRe:String = reArr[j].split(":")[1]
					var randID:Array = reArr[j].split(":")[0].split("|")[1];
					var l2:int = randID.length;
					
					ArmyGroupSeasonReward[i+1][randID] = { rank:randID, reward:realRe };
				}
			}
		}
		
		public function getArmyGroupSeasonReward(sid:int,rid:int):String
		{
			var reList:String = "";
			var sre:Object = ArmyGroupSeasonReward[sid];
			for (var i in sre)
			{
				reList = sre[i].reward;
				if (rid <= sre[i].rank)
				{
					break;
				}
				
			}
			
			return reList
		}
		
		public function loaderLang():void
		{
//			Text._testWord = thisLangCig.testWord;
			//alert("thisLangCig.langName____"+thisLangCig.langName);
			var jsonStr:String="config/" + thisLangCig.langName + ".json";

			Text.replaceFontFun=replaceFontFun;

			jsonStr=ResourceManager.instance.setResURL(jsonStr);

			Laya.loader.load([{url: jsonStr, type: Loader.JSON}], Handler.create(this, loaderLangOver, [jsonStr]));
		}

		private function loaderLangOver(jsonStr:String):void
		{
			var langjson:Object=Loader.getRes(jsonStr);
			if (langjson)
			{
				for each (var c in langjson)
				{
					GameLanguage.lang[c.key]=c.en;
				}
				Text.langPacks=GameLanguage.lang;
			}
			Signal.intance.event("lan_rdy");
		}

		/**
		 * 获取所有uint数据列表
		 * @param type，类型
		 */
		public static function getUnitList(type:int):Array
		{
			var arr:Array=[];
			for (var i:String in unit_json)
			{
				if (unit_json[i].unit_type == type)
				{
					arr.push(unit_json[i]);
				}
			}
			return arr
		}

		public function InitDrawCardParam():void
		{
			var vo:*;
			var c:*;
			var l_arr:Array=new Array();
			CardFreeItemList=[];
			CardPayItemList=[];
			CardPvwList=[];
			var card_param_json:*=ResourceManager.instance.getResByURL("config/card_param.json");
			if (card_param_json)
			{
				for each (c in card_param_json)
				{
					vo=VoHasTool.hasVo(CardParamBaseVo, c);
					l_arr.push(vo);
				}
				card_param=new CardParamVo(l_arr);
			}

			var card_cost_json:*=ResourceManager.instance.getResByURL("config/card_cost.json");
			if (card_cost_json)
			{
				for each (c in card_cost_json)
				{
					vo=VoHasTool.hasVo(CardCostVo, c);
					CardCostList.push(vo);
				}
			}
			var card_free_item_json:*=ResourceManager.instance.getResByURL("config/card_free_item.json");
			if (card_free_item_json)
			{
				for each (c in card_free_item_json)
				{
					vo=VoHasTool.hasVo(CardFreeItemVo, c);
					CardFreeItemList.push(vo);
				}
			}

			var card_pay_item_json:*=ResourceManager.instance.getResByURL("config/card_pay_item.json");
			if (card_pay_item_json)
			{
				for each (c in card_pay_item_json)
				{
					vo=VoHasTool.hasVo(CardPayItemVo, c);
					CardPayItemList.push(vo);
				}
			}
			var card_pvw_json:*=ResourceManager.instance.getResByURL("config/card_pvw.json");
			if (card_pvw_json)
			{
				for each (c in card_pvw_json)
				{
					vo=VoHasTool.hasVo(CardPvwVo, c);
					CardPvwList.push(vo);
				}
			}
		}

		/**
		 * 组队战斗
		 */
		public function InitTeamCopyParam():void
		{
			var vo:*;
			var c:*;
			var l_arr:Array=new Array();
			teamFightParamVo=new TeamFightParamVo();
			var teamfight_param_json:*=ResourceManager.instance.getResByURL("config/teamfight_param.json");
			if (teamfight_param_json)
			{
				for each (c in teamfight_param_json)
				{
					if (c["id"] == 3)
					{
						teamFightParamVo.freeRefreshTime=c["value"];
					}
					else if (c["id"] == 4)
					{
						teamFightParamVo.masterRewardTime=c["value"];
					}
					else if (c["id"] == 8)
					{
						teamFightParamVo.guildRewardTime=c["value"];
					}
					else if (c["id"] == 11)
					{
						teamFightParamVo.chatMax=c["value"];
					}
				}
			}

			var teamfight_level_json:*=ResourceManager.instance.getResByURL("config/teamfight_level.json");
			if (teamfight_level_json)
			{
				for each (c in teamfight_level_json)
				{
					vo=VoHasTool.hasVo(TeamFightLevelVo, c);
					TeamFightLevelList[c.id]=vo;
				}
			}

			var teamfight_buy_json:*=ResourceManager.instance.getResByURL("config/teamfight_buy.json");
			if (teamfight_buy_json)
			{
				for each (c in teamfight_buy_json)
				{
					vo=VoHasTool.hasVo(TeamFightBuyVo, c);
					TeamFightBuyList[c.id]=vo;
				}
			}

			var teamfight_refresh_json:*=ResourceManager.instance.getResByURL("config/teamfight_refresh.json");
			if (teamfight_refresh_json)
			{
				for each (c in teamfight_refresh_json)
				{
					vo=VoHasTool.hasVo(TeamFightRefreshVo, c);
					TeamFightRefreshList[c.id]=vo;
				}
			}
		}



		private static var _convict_level_dic:Object; //基因地图键值对

		/**
		 * 世界boss数据
		 */
		public function InitBossFightParam():void
		{
			var vo:*;
			var c:*;
			var boss_param_json:Object=ResourceManager.instance.getResByURL("config/boss_param.json");
			boss_param=new WorldBossBaseParamVo();
			boss_level_arr=[];
			boss_rank_arr=[];
			boss_sell_item_arr=[];
			boss_level_arr=[];
			if (boss_param_json)
			{
				for each (c in boss_param_json)
				{
					if (c["id"] == 1)
					{
						var l_str:String=c["value"]
						boss_param.openDay=l_str.split("|")[0];
						boss_param.continueDay=l_str.split("|")[1];
					}

					if (c["id"] == 2)
					{
						boss_param.openLevel=c["value"];
					}
					else if (c["id"] == 4)
					{
						boss_param.freeFightTime=c["value"];
					}
				}
			}
			var boss_buy_json:Object=ResourceManager.instance.getResByURL("config/boss_buy.json");
			if (boss_buy_json)
			{
				for each (c in boss_buy_json)
				{
					vo=VoHasTool.hasVo(BossBuyVo, c);
					boss_buy_arr.push(vo);
				}
			}
			var boss_rank_json:Object=ResourceManager.instance.getResByURL("config/boss_rank.json");
			if (boss_rank_json)
			{
				for each (c in boss_rank_json)
				{
					vo=VoHasTool.hasVo(BossRankVo, c);
					boss_rank_arr.push(vo);
				}
			}
			var boss_sell_item_json:Object=ResourceManager.instance.getResByURL("config/boss_sell_item.json");
			if (boss_sell_item_json)
			{
				for each (c in boss_sell_item_json)
				{
					vo=VoHasTool.hasVo(BossSellItemVo, c);
					boss_sell_item_arr.push(vo);
				}
			}
			var boss_level_json:Object=ResourceManager.instance.getResByURL("config/boss_level.json");
			if (boss_level_json)
			{
				for each (c in boss_level_json)
				{
					vo=VoHasTool.hasVo(BossLevelVo, c);
					boss_level_arr.push(vo);
				}
			}

		}

		/**
		 * 好友邮箱配置
		 */
		public function getConfigMessage():void
		{
			var vo:*;
			var c:*;
			var message_canshu_json:Object=ResourceManager.instance.getResByURL("config/message_canshu.json");
			if (message_canshu_json)
			{
				messageConfig=new MessageConfigVo();
				for each (c in message_canshu_json)
				{
					if (c["id"] == 3)
					{
						messageConfig.friendMax=c["value"];
					}
					if (c["id"] == 6)
					{
						messageConfig.mailNum=c["value"];
					}
					if (c["id"] == 7)
					{
						messageConfig.chatMaxNum=c["value"];
					}
				}
			}
		}

		/**
		 * 装备
		 */
		public function getEquipParam():void
		{
			var vo:*;
			var c:*;
			EquipmentList=[];
			EquipmentSuitList=[];
			EquipmentBaptizeList=[];
			EquipmentMaxList=[];
			EquipmentIntensifyList=[];
			equipParamVo=new EquipParamVo();
			var equipment_param_json:Object=ResourceManager.instance.getResByURL("config/equipment_param.json");
			if (equipment_param_json)
			{
				for each (c in equipment_param_json)
				{
					if (c["id"] == 2)
					{
						equipParamVo.openStrongLevel=c["value"];
					}
					else if (c["id"] == 3)
					{
						equipParamVo.openWashLevel=c["value"];
					}
					else if (c["id"] == 4)
					{
						equipParamVo.openResolveLevel=c["value"];
					}
				}
			}
			var equipment_list_json:Object=ResourceManager.instance.getResByURL("config/equipment_list.json");
			if (equipment_list_json)
			{
				for each (c in equipment_list_json)
				{
					vo=VoHasTool.hasVo(EquipmentListVo, c);
					EquipmentList[(vo as EquipmentListVo).equip]=(vo);
				}
			}

			var equipment_baptize_json:Object=ResourceManager.instance.getResByURL("config/equipment_baptize.json");
			if (equipment_baptize_json)
			{
				for each (c in equipment_baptize_json)
				{
					vo=VoHasTool.hasVo(EquipmentBaptizeVo, c);
					EquipmentBaptizeList.push(vo);
				}
			}

			var equipment_suit_json:Object=ResourceManager.instance.getResByURL("config/equipment_suit.json");
			if (equipment_suit_json)
			{
				for each (c in equipment_suit_json)
				{
					vo=VoHasTool.hasVo(EquipmentSuitVo, c);
					EquipmentSuitList.push(vo);
				}
			}

			var equipment_intensify_json:Object=ResourceManager.instance.getResByURL("config/equipment_intensify.json");
			if (equipment_intensify_json)
			{
				for each (c in equipment_intensify_json)
				{
					vo=VoHasTool.hasVo(EquipmentIntensifyVo, c);
					EquipmentIntensifyList.push(vo);
				}
			}



			var equipment_rate_json:Object=ResourceManager.instance.getResByURL("config/equipment_rate.json");
			if (equipment_rate_json)
			{
				for each (c in equipment_rate_json)
				{
					vo=VoHasTool.hasVo(EquipmentRateVo, c);
					EquipmentRateList.push(vo);
				}
			}
			var equipment_max_json:Object=ResourceManager.instance.getResByURL("config/equipment_max.json");
			if (equipment_max_json)
			{
				for each (c in equipment_max_json)
				{
					vo=VoHasTool.hasVo(EquipmentMaxVo, c);
					EquipmentMaxList.push(vo);
				}
			}

			var unit_parameter_json:Object=ResourceManager.instance.getResByURL("config/unit_parameter.json");
			if (unit_parameter_json)
			{
				for each (c in unit_parameter_json)
				{
					vo=VoHasTool.hasVo(UnitParameterVo, c);
					UnitParameterList[(vo as UnitParameterVo).parameter_name]=vo;
				}

			}
		}




		public static function get convict_level_dic():Object
		{
			initConvict_level();
			return _convict_level_dic;
		}

		private static function initConvict_level():void
		{
			if (!_convict_level_dic)
			{
				var convict_level_json:*=ResourceManager.instance.getResByURL("config/convict_level.json");
				if (convict_level_json)
				{
					_convict_level_dic={};
					for each (var c:* in convict_level_json)
					{
						var vo:GeneLevelVo=VoHasTool.hasVo(GeneLevelVo, c);
						_convict_level_dic[vo.id]=vo;
					}
				}
				else
				{
					trace("配置未加载:config/convict_level.json");
				}
			}
		}

		/**
		 * 工会初始化数据获取
		 * @return
		 */
		public function getGuildInitData():Object
		{

			var vo:*;
			var c:*;

			var gp:Object=ResourceManager.instance.getResByURL("config/guild_canshu.json");
			if (gp)
			{
				for each (c in gp)
				{
					vo=VoHasTool.hasVo(GuildParamsVo, c)
					guild_params[vo.id]=vo;
				}
			}
			
			guild_boss_vec = [];
			var guildBossVo:Object=ResourceManager.instance.getResByURL("config/guildboss_level.json");
			if (guildBossVo)
			{
				for each (c in guildBossVo)
				{
					vo=VoHasTool.hasVo(GuildBossVo, c)
					guild_boss_vec.push(vo);
				}
			}
			
			guild_contribute_vec = [];
			var gcVo:Object=ResourceManager.instance.getResByURL("config/guild_contribution.json");
			if (gcVo)
			{
				for each (c in gcVo)
				{
					vo=VoHasTool.hasVo(GuildContributeVo, c)
					guild_contribute_vec.push(vo);
				}
			}
			
			guild_welfare_vec = [];
			var guildWelfareVo:Object=ResourceManager.instance.getResByURL("config/guild_welfare.json");
			if (guildWelfareVo)
			{
				for each (c in guildWelfareVo)
				{
					vo=VoHasTool.hasVo(GuildWelfareVo, c);
					guild_welfare_vec.push(vo)
				}
			}

			guild_shop_vec = [];
			var guildItem:Object=ResourceManager.instance.getResByURL("config/guild_shop.json");
			if (guildItem)
			{
				for each (c in guildItem)
				{
					vo=VoHasTool.hasVo(GuildItemVo, c);
					guild_shop_vec.push(vo)
				}
			}
			
			guild_info_vec = [];
			guild_info_vec.push(new GuildInfoVo());
			var guildInfo:Object=ResourceManager.instance.getResByURL("config/guild_level.json");
			if (guildInfo)
			{
				for each (c in guildInfo)
				{
					vo=VoHasTool.hasVo(GuildInfoVo, c);
					guild_info_vec.push(vo);
				}
			}
			
			guild_bossCost_vec = [];
			var bossCost:Object=ResourceManager.instance.getResByURL("config/guild_bosscs.json");
			if (bossCost)
			{
				for each (c in bossCost)
				{
					vo=VoHasTool.hasVo(GuildBossCost, c);
					guild_bossCost_vec.push(vo)
				}
			}
			
			
			
			return null;
		}

		/**
		 * 获取挑战BOSS所需要的费用
		 * @param	time
		 * @param	type
		 * @return
		 */
		public function getGuildBossCost(times:int, type:String):String
		{
			var len:int=guild_bossCost_vec.length;
			for (var i:int=0; i < len; i++)
			{
				if (times < guild_bossCost_vec[i].up)
				{
					return (type == "free") ? guild_bossCost_vec[i].price : guild_bossCost_vec[i].price2;
				}
			}
			return "1|100";
		}

		/**
		 * 获取公会BOSS信息
		 * @param	id
		 * @return
		 */
		public function getGuildBossInfo(id:String):GuildBossVo
		{
			var len:int=guild_boss_vec.length;
			for (var i:int=0; i < len; i++)
			{
				if (guild_boss_vec[i].id == id)
				{
					return guild_boss_vec[i].clone();
				}
			}
			return null;
		}

		/**
		 * 获取具体工会福利
		 * @param	id
		 * @param	lv
		 * @return
		 */
		public function getGuildWelf(type:String, lv:String):GuildWelfareVo
		{
			var len:int=guild_welfare_vec.length;

			for (var i:int=0; i < len; i++)
			{
				if (guild_welfare_vec[i].type == type && guild_welfare_vec[i].level == lv)
				{
					return guild_welfare_vec[i];
				}
			}
			return null;
		}

		/**
		 * 科技树初始化数据
		 */
		public function getTechInitData():void
		{
			var vo:*;
			var c:*;
			var techUpdateVo:Object=ResourceManager.instance.getResByURL("config/tech/tech_upgrade.json");
			if (techUpdateVo)
			{
				for each (c in techUpdateVo)
				{
					vo=VoHasTool.hasVo(TechUpdateVo, c)
					tech_update_vec.push(vo);
				}
			}

			var techLevelVo:Object=ResourceManager.instance.getResByURL("config/tech/tech_level.json");
			if (techLevelVo)
			{
				for each (c in techLevelVo)
				{
					vo=VoHasTool.hasVo(TechLevelVo, c)
					tech_level_vec.push(vo);
				}
			}

			var techPointVo:Object=ResourceManager.instance.getResByURL("config/tech/tech_point.json");
			if (techPointVo)
			{
				for each (c in techPointVo)
				{
					vo=VoHasTool.hasVo(TechPointVo, c)
					tech_point_vec.push(vo);
				}
			}
		}

		/**
		 * 获取当前捐献信息
		 * @param	times
		 * @param	type
		 * @return
		 */
		public function getContributeInfo(times:int, type:int):GuildContributeVo
		{
			var len:int=guild_contribute_vec.length;
			var maxLv:int=0;
			for (var i:int=0; i < len; i++)
			{
				if (guild_contribute_vec[i].type == type)
				{
					if (times < guild_contribute_vec[i].attempts)
					{
						return guild_contribute_vec[i];
					}
					maxLv=i;
				}
			}

			return guild_contribute_vec[maxLv];
		}

		/**
		 * 运镖
		 */
		public function getTransport():void
		{
			var vo:*;
			var c:*;
			var transport_canshu_json:Object=ResourceManager.instance.getResByURL("config/transport_canshu.json");
			transportParam=new TransportParam();
			TransportVehicleList=[];
			TransportPlanList=[];
			TransportPenaltyList=[];
			TransportPriceList=[];
			TransportPlanpriceList=[];
			TransportPrice1List=[];
			TransportBookList=[];
			UnitUpgradeExpList=[];
			if (transport_canshu_json)
			{
				for each (c in transport_canshu_json)
				{
					if (c["id"] == 2)
					{
						transportParam.lootNum=c["value"];
					}
					if (c["id"] == 3)
					{
						transportParam.maxOpponent=c["value"];
					}
					if (c["id"] == 4)
					{
						transportParam.safeTime=c["value"];
					}
					if (c["id"] == 5)
					{
						transportParam.freeRefresh=c["value"];
					}
					if (c["id"] == 6)
					{
						transportParam.freeTransportNum=c["value"];
					}
					if (c["id"] == 12)
					{
						transportParam.freePlanBuyTime=c["value"];
					}
				}
			}
			var transport_vehicle_json:Object=ResourceManager.instance.getResByURL("config/transport_vehicle.json");
			if (transport_vehicle_json)
			{
				for each (c in transport_vehicle_json)
				{
					vo=VoHasTool.hasVo(TransportVehicleVo, c)
					TransportVehicleList.push(vo);
				}
			}
			var transport_plan_json:Object=ResourceManager.instance.getResByURL("config/transport_plan.json");
			if (transport_plan_json)
			{
				for each (c in transport_plan_json)
				{
					vo=VoHasTool.hasVo(TransportPlanVo, c)
					TransportPlanList.push(vo);
				}
			}

			var transport_price_json:Object=ResourceManager.instance.getResByURL("config/transport_price.json");
			if (transport_price_json)
			{
				for each (c in transport_price_json)
				{
					vo=VoHasTool.hasVo(TransportPriceVo, c)
					TransportPriceList.push(vo);
				}
			}
			var transport_planprice_json:Object=ResourceManager.instance.getResByURL("config/transport_planprice.json");
			if (transport_planprice_json)
			{
				for each (c in transport_planprice_json)
				{
					vo=VoHasTool.hasVo(TransportPlanpriceVo, c)
					TransportPlanpriceList.push(vo);
				}
			}
			var transport_price1_json:Object=ResourceManager.instance.getResByURL("config/transport_price1.json");
			if (transport_price1_json)
			{
				for each (c in transport_price1_json)
				{
					vo=VoHasTool.hasVo(TransportPrice1Vo, c)
					TransportPrice1List.push(vo);
				}
			}

			var transport_book_json:Object=ResourceManager.instance.getResByURL("config/transport_book.json");
			if (transport_book_json) 
			{
				for each (c in transport_book_json)
				{
					vo=VoHasTool.hasVo(TransportBookVo, c)
					TransportBookList.push(vo);
				}
			}

			var unit_upgrade_exp_json:Object=ResourceManager.instance.getResByURL("config/unit_upgrade_exp.json");
			if (unit_upgrade_exp_json)
			{
				for each (c in unit_upgrade_exp_json)
				{
					vo=VoHasTool.hasVo(UnitUpgradeExpVo, c)
					UnitUpgradeExpList[vo.level]=vo;
				}
			}

		}


		/**
		 * 获取科技点购买花费		 * @param	id
		 * @return
		 */
		public function getTechPointCost(point:int):TechPointVo
		{
			var len:int=tech_point_vec.length;

			for (var i:int=0; i < len; i++)
			{
				if (tech_point_vec[i].point == point)
				{
					return tech_point_vec[i];
				}
			}
			return null;
		}
		private static var _skill_control_dic:Object;

		public static function get skill_control_dic():Object
		{
			initSkillControl_dic();
			return _skill_control_dic;
		}

		/**
		 * 获取科技点数据
		 * @param	id
		 * @param	lv
		 * @return
		 */
		public function getTechUpdateInfo(id:String, lv:int):TechUpdateVo
		{

			var len:int=tech_update_vec.length;

			for (var i:int=0; i < len; i++)
			{
				if (tech_update_vec[i].tech_id == id && tech_update_vec[i].level == lv)
				{
					return tech_update_vec[i].clone();
				}
			}
			return null;
		}

		/**
		 * 获取开启此层需要多少技能点
		 * @return
		 */
		public function getLowLayerFinishPoint(layer:int):int
		{
			var len:int=tech_level_vec.length;
			var countPoint:int=0;
			var a1:Array=[];
			for (var i:int=0; i < layer; i++)
			{
				a1=tech_level_vec[i].tech_id.split("|");

				for (var j:int=0; j < a1.length; j++)
				{
					countPoint+=parseInt(a1[j].split(":")[1]);
				}

			}
			return countPoint;
		}

		/**
		 * 初始化兵书副本数据
		 */
		public function initBingBookData():void
		{

			var vo:*;
			var c:*;
			var bbpd:Object=ResourceManager.instance.getResByURL("config/bingBook/book_canshu.json");
			if (bbpd)
			{
				for each (c in bbpd)
				{
					vo=VoHasTool.hasVo(BingBookParamVo, c)
					bingBook_param_vec.push(vo);
				}
			}
			var bbrp:Object=ResourceManager.instance.getResByURL("config/bingBook/book_price.json");
			if (bbrp)
			{
				for each (c in bbrp)
				{
					vo=VoHasTool.hasVo(BingBookRefreshPriceVo, c)
					bingBook_refresPrice_vec.push(vo);
				}
			}

			var bbfp:Object=ResourceManager.instance.getResByURL("config/bingBook/book_cd.json");
			if (bbfp)
			{
				for each (c in bbfp)
				{
					vo=VoHasTool.hasVo(BingBookFinishPrice, c)
					bingBook_finishPrice_vec.push(vo);
				}
			}
		}

		/**
		 * 获取兵书副本基本参数
		 * @param	id
		 * @return
		 */
		public function getBingBoomParam(id:String):BingBookParamVo
		{
			var len:int=bingBook_param_vec.length;
			for (var i:int=0; i < len; i++)
			{
				if (id == bingBook_param_vec[i].id)
				{
					return bingBook_param_vec[i];
				}
			}
			return null;
		}

		/**
		 * 获取兵书副本刷新价格
		 * @param	times
		 * @return
		 */
		public function getBingBookRefreshPrice(times:int):BingBookRefreshPriceVo
		{
			var len:int=bingBook_refresPrice_vec.length;

			for (var i:int=0; i < len; i++)
			{
				if (i == 0)
				{
					if (0 <= times && times <= parseInt(bingBook_refresPrice_vec[i].attempts))
					{
						return bingBook_refresPrice_vec[i];
					}
				}
				else
				{
					if (parseInt(bingBook_refresPrice_vec[i - 1].attempts) < times && times <= parseInt(bingBook_refresPrice_vec[i].attempts))
					{
						return bingBook_refresPrice_vec[i];
					}
				}
			}

			return bingBook_refresPrice_vec[len - 1];
		}


		/**
		 * 计算兵书副本完成解码需要的时间
		 * @param	minute
		 * @return
		 */
		public function checkBingBookFinishPrice(minute:int):int
		{
			var len:int=bingBook_finishPrice_vec.length;
			var price:int=0;
			for (var i:int=1; i < len; i++)
			{
				if (minute < bingBook_finishPrice_vec[i].CD_down)
				{
					price+=(minute - bingBook_finishPrice_vec[i - 1].CD_down) * bingBook_finishPrice_vec[i - 1].stage_price;
					break;
				}
				else
				{
					price+=(bingBook_finishPrice_vec[i].CD_down - bingBook_finishPrice_vec[i - 1].CD_down) * bingBook_finishPrice_vec[i - 1].stage_price;
				}

			}
			return Math.ceil(price);
		}

		/**
		 * 初始化竞技场数据
		 */
		public function initArenaData():void
		{
			var vo:*;
			var c:*;
			arena_rankRewawrd_vec=[];
			var arvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_rank.json");
			if (arvo)
			{
				for each (c in arvo)
				{
					vo=VoHasTool.hasVo(ArenaRankVo, c)
					/*if (!arena_rankRewawrd_vec[vo.group])
					{
						arena_rankRewawrd_vec[vo.group] = { };
					}
					arena_rankRewawrd_vec[vo.group][vo.up] = vo;*/
					arena_rankRewawrd_vec.push(vo);
				}
			}

			arena_refreshPrice=[];
			var apvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_refresh.json");
			if (apvo)
			{
				for each (c in apvo)
				{
					vo=VoHasTool.hasVo(ArenaRefeshVo, c)
					arena_refreshPrice.push(vo);
				}
			}
			
			arena_shop_vec=[];
			var asvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_shop.json");
			if (asvo)
			{
				for each (c in asvo)
				{
					vo=VoHasTool.hasVo(ArenaShopVo, c)
					arena_shop_vec.push(vo);
				}
			}

			arena_reset_vec=[];
			var astvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_buy.json");
			if (astvo)
			{
				for each (c in astvo)
				{
					vo=VoHasTool.hasVo(ArenaResetVo, c)
					arena_reset_vec.push(vo);
				}
			}

			arena_group_vec=[];
			var agvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_group.json");
			if (agvo)
			{
				for each (c in agvo)
				{
					vo=VoHasTool.hasVo(ArenaGroupVo, c)
					arena_group_vec.push(vo);
				}
			}

			arena_npc_vec=[];
			var npcvo:Object=ResourceManager.instance.getResByURL("config/arena/new_arena_level.json");
			if (npcvo)
			{
				for each (c in npcvo)
				{
					vo=VoHasTool.hasVo(ArenaNPCVo, c)
					arena_npc_vec[vo.id]=vo;
				}
			}

		}

		/**
		 * 获取竞技场排行榜
		 * @param	rank
		 * @param	group
		 * @return
		 */
		public function getArenaRankReward(group:int, rank:int):ArenaRankVo
		{
			/*if (are[group][rank])
			{
				return arena_rank_vec[group][rank];
			}*/

			return null;
		}
		
		/**
		 * 获取竞技场重置价格
		 * @param	t
		 * @return
		 */
		public function getArenaRefreshPrice(t:int):int
		{
			var len:int=arena_refreshPrice.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= arena_refreshPrice[i].up)
				{
					return parseInt(arena_refreshPrice[i].price.split("=")[1]);;
				}
			}
			return 300;
		}

		/**
		 * 获取竞技场重置价格
		 * @param	t
		 * @return
		 */
		public function getArenaResetPrice(t:int):String
		{
			var len:int=arena_reset_vec.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= arena_reset_vec[i].up)
				{
					return arena_reset_vec[i].price;
				}
			}
			return "1=5000";
		}
		
		/**
		 * 获取军团商店刷新价格
		 * @param	t
		 * @return
		 */
		public function getAGStoreRefreshPrice(t:int):int
		{
			
			var len:int=ArmyGroupStoreRePrice.length;
			for (var i:int=0; i < len; i++)
			{
				if (t <= ArmyGroupStoreRePrice[i].up)
				{
					return parseInt(ArmyGroupStoreRePrice[i].price.split("=")[1]);
				}
			}
			return 300;
		}

		/**
		 * 初始化矿区数据
		 */
		public function initMineData():void
		{

			var vo:*;
			var c:*;
			var mivo:Object=ResourceManager.instance.getResByURL("config/mine/mine_fight_config.json");
			if (mivo)
			{
				for each (c in mivo)
				{
					vo=VoHasTool.hasVo(MineInfoVo, c);
					mine_info_vec.push(vo);
				}
			}

			var mtvo:Object=ResourceManager.instance.getResByURL("config/mine/mine_fight_times.json");
			if (mtvo)
			{
				for each (c in mtvo)
				{
					vo=VoHasTool.hasVo(MineFightTimeVo, c);
					mine_time_price_vec.push(vo);
				}
			}

			var mpvo:Object=ResourceManager.instance.getResByURL("config/mine/mine_fight_cd.json");
			if (mpvo)
			{
				for each (c in mpvo)
				{
					vo=VoHasTool.hasVo(MineProtectTimeVo, c);
					mine_protect_price_vec.push(vo);
				}
			}

			mine_npc_vec.push(new MineFightVo());
			var mfvo:Object=ResourceManager.instance.getResByURL("config/mine/mine_fight_level.json");
			if (mfvo)
			{
				for each (c in mfvo)
				{
					vo=VoHasTool.hasVo(MineFightVo, c);
					mine_npc_vec.push(vo);
				}
			}
		}

		public function getBuyMineTimesPrice(t:int):String
		{
			var len:int=mine_time_price_vec.length;
			var i:int=0;
			for (i=0; i < len; i++)
			{
				if (t <= mine_time_price_vec[i].up)
				{
					return mine_time_price_vec[i].price;
				}
			}
			return mine_time_price_vec[i].price;
		}

		public function initUpgradeInfo():void
		{

			var vo:*;
			var c:*;
			var advo:Object=ResourceManager.instance.getResByURL("config/degree/degree_config.json");
			if (advo)
			{
				for each (c in advo)
				{
					vo=VoHasTool.hasVo(AdvanceVo, c);
					advance_upgrade_vec.push(vo);
				}
			}
		}

		public function initFunOpenList():void
		{
			var vo:*;
			var c:*;
			var fovo:Object=ResourceManager.instance.getResByURL("config/functionGuide/function_open.json");
			if (fovo)
			{
				for each (c in fovo)
				{
					vo=VoHasTool.hasVo(funGuide, c);
					fun_open_vec[vo.id]=vo;
				}
			}

			var cmvo:Object=ResourceManager.instance.getResByURL("config/functionGuide/function_guide.json");
			if (cmvo)
			{
				for each (c in cmvo)
				{
					vo=VoHasTool.hasVo(CommonGuideVo, c);
					common_guide_vec[vo.id]=vo;
				}
			}
		/*trace("=============")
		trace(fun_open_vec)
		trace(common_guide_vec)
		trace("=============")*/

		}

		/**
		 * 初始化活动
		 */
		public function initActivityList():void
		{

			var vo:*;
			var c:*;
			var mvo:Object=ResourceManager.instance.getResByURL("config/activity/events_template.json");
			if (mvo)
			{
				for each (c in mvo)
				{
					vo=VoHasTool.hasVo(ActivityListVo, c)
					activiey_list_vec[vo.tid]=vo;
					if (vo.tid == 8)
					{
						if (GameSetting.isApp)
						{
							vo.name="L_A_57022";
						}
						else
						{
							if (GameSetting.Platform == GameSetting.P_FB)
							{
								vo.name="L_A_57022";
							}
							else
							{
								vo.name="L_A_57024";
							}
						}
					}

				}
				trace("配表活动列表:"+JSON.stringify(activiey_list_vec));
			}

			var svo:Object = ResourceManager.instance.getResByURL("config/activity/7days_objective_reward.json");
			seven_days_info = [];
			if (svo)
			{
				for each (c in svo)
				{
					vo=VoHasTool.hasVo(SevenDaysVo, c)
					seven_days_info.push(vo);
				}
			}
//			trace("七天奖励配置:"+JSON.stringify(svo));
		}

		/**
		 * 获取7天目标某天数值
		 * @param	days
		 * @return
		 */
		public function getSevenDayInfo(days:int):Array
		{
			var arr:Array=[];
			var len:int=seven_days_info.length;
			for (var i:int=0; i < len; i++)
			{
				if (seven_days_info[i].day == days)
				{
					arr.push(seven_days_info[i]);
				}
			}
			return arr;
		}

		public function initSignInInfo():void
		{
			var vo:*;
			var c:*;
			var sVo:Object = ResourceManager.instance.getResByURL("config/activity/check_in_fill_price.json");
			
			if (sVo)
			{
				for each (c in sVo)
				{
					vo=VoHasTool.hasVo(SignInVo, c)
					signInInfo.push(vo);
				}
			}
		}
		
		public function initFriendCodeReward():void
		{
			var vo:*;
			var c:*;
			var ifVo:Object = ResourceManager.instance.getResByURL("config/activity/code_invite_giveback.json");
			inviteFriendReward = [];
			if (ifVo)
			{
				for each (c in ifVo)
				{
					vo = VoHasTool.hasVo(FriendCodeVo, c)
					inviteFriendReward.push(vo);
				}
			}
		}
		
		public function initFundationInfo():void
		{
			var vo:*;
			var c:*;
			var sVo:Object = ResourceManager.instance.getResByURL("config/activity/grow_fund.json");
			
			if (sVo)
			{
				for each (c in sVo)
				{
					fundationInfo[c.level]=c;
				}
			}
		}

		/**
		 * 初始化军府数据
		 */
		public function initMilitaryData():void
		{
			var vo:*;
			var c:*;
			var blockInfo:Object=ResourceManager.instance.getResByURL("config/militaryHouse/res_place.json");
			if (blockInfo)
			{
				for each (c in blockInfo)
				{
					vo=VoHasTool.hasVo(MilitaryBlockVo, c)
					military_block_info.push(vo);
				}
			}

			var pInfo:Object=ResourceManager.instance.getResByURL("config/militaryHouse/res_placebuy.json");
			if (pInfo)
			{
				for each (c in pInfo)
				{
					vo=VoHasTool.hasVo(MilitartyBlockPrice, c)
					military_price_info.push(vo);
				}
			}

			var ms:Object=ResourceManager.instance.getResByURL("config/militaryHouse/res_inc.json");
			if (ms)
			{
				for each (c in ms)
				{
					vo=VoHasTool.hasVo(MilitaryScore, c)
					military_score.push(vo);
				}
			}

			var us:Object=ResourceManager.instance.getResByURL("config/militaryHouse/res_br.json");
			if (us)
			{
				for each (c in us)
				{
					vo=VoHasTool.hasVo(MilitaryUnitScore, c)
					military_unit_score.push(vo);
				}
			}

			var hs:Object=ResourceManager.instance.getResByURL("config/militaryHouse/res_h_br.json");
			if (hs)
			{
				for each (c in hs)
				{
					vo=VoHasTool.hasVo(MilitaryHeroScore, c)
					military_hero_score.push(vo);
				}
			}
		}


		public function getUnitScoreVo(score:int):MilitaryUnitScore
		{
			var len:int=military_unit_score.length;
			for (var i:int=0; i < len; i++)
			{
				if (score < military_unit_score[i].CD_down)
				{
					return military_unit_score[i - 1];
				}
			}
		}

		public function getHeroScoreVo(score:int):MilitaryHeroScore
		{
			var len:int=military_hero_score.length;
			for (var i:int=0; i < len; i++)
			{
				if (score < military_hero_score[i].CD_down)
				{
					return military_hero_score[i - 1];
				}
			}
		}

		/**
		 * 初始化任务
		 */
		public function initMissionData():void
		{
			var vo:*;
			var c:*;
			var mvo:Object=ResourceManager.instance.getResByURL("config/mission/renwu_chengjiu.json");
			if (mvo)
			{
				for each (c in mvo)
				{
					vo=VoHasTool.hasVo(MissionVo, c)
					missionInfo[vo.id]=vo;
				}
			}
			//trace("初始化任务池:"+JSON.stringify(missionInfo));
			var mpVo:Object=ResourceManager.instance.getResByURL("config/mission/renwu_xishu.json");
			if (mpVo)
			{
				for each (c in mpVo)
				{
					//vo=VoHasTool.hasVo(MissionXishuVo, c);
					missionParame_vec[c.dj]=c;
				}
			}
			
			dailiyScore = new Vector.<DailyScoreVo>();
			var dsVo:Object=ResourceManager.instance.getResByURL("config/mission/task_point_reward.json");
			if (dsVo)
			{
				for each (c in dsVo)
				{
					vo=VoHasTool.hasVo(DailyScoreVo, c)
					dailiyScore.push(vo);
				}
			}
			
		}


		public static function getSkillControl(skillId:*, unitId:*):SkillControlVo
		{
			var obj:Object=skill_control_dic;
			if (!obj)
				return null;

			if (skillId == 0 || skillId == 1)
				return obj[skillId];

			var key:String;
			var f:SkillVo=unit_skill_dic[skillId];

			if (!f)
			{
				f=DBSkill2.getSkillInfo(skillId);
			}

			if (!f)
				return null;

			var skill_node:*=f.skill_node;
			if (unitId)
			{
				key=skillId + "_" + unitId;
				if (obj.hasOwnProperty(key))
					return obj[key];
				key=f.skill_node + "_" + unitId;
				if (obj.hasOwnProperty(key))
					return obj[key];
			}
			key=skillId;
			if (obj.hasOwnProperty(key))
				return obj[key];
			key=skill_node;

			return obj[key];
		}

		private static function initSkillControl_dic():void
		{
			if (!_skill_control_dic)
			{
				var skillControl_json:*=ResourceManager.instance.getResByURL("staticConfig/skillControlConfig.json");
				if (skillControl_json)
				{
					_skill_control_dic={};
					for (var k:* in skillControl_json)
					{
						var c:*=skillControl_json[k];
						var vo:SkillControlVo=new SkillControlVo(c, k);
						_skill_control_dic[vo.key]=vo;
					}
				}
				else
				{
					trace("配置未加载:staticConfig/skillControlConfig.json");
				}
			}
		}



		private static var _equipFightChapters:Array;

		public static function get equipFightChapters():Array
		{
			if (!_equipFightChapters)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/galaxy_chapter.json");
				if (_json)
				{
					_equipFightChapters=[];
					for each (var c:* in _json)
					{
						var vo:equipFightChapterVo=VoHasTool.hasVo(equipFightChapterVo, c);
						_equipFightChapters.push(vo);
					}
				}
				else
				{
					trace("配置未加载:config/galaxy_chapter.json");
				}
			}
			return _equipFightChapters;
		}

		private static var _equipFightLevelVos:Array;

		public static function get equipFightLevelVos():Array
		{
			if (!_equipFightLevelVos)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/galaxy_level.json");
				if (_json)
				{
					_equipFightLevelVos=[];
					for each (var c:* in _json)
					{
						var vo:equipFightLevelVo=VoHasTool.hasVo(equipFightLevelVo, c);
						_equipFightLevelVos.push(vo);
					}
				}
				else
				{
					trace("配置未加载:config/galaxy_level.json");
				}
			}
			return _equipFightLevelVos;
		}


		private static var _pvpShopItemVos:Array;

		public static function get pvpShopItemVos():Array
		{
			if (!_pvpShopItemVos)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/pvp_shop.json");
				if (_json)
				{
					_pvpShopItemVos=[];
					for each (var c:* in _json)
					{
						var vo:pvpShopItemVo=VoHasTool.hasVo(pvpShopItemVo, c);
						_pvpShopItemVos.push(vo);
					}
				}
				else
				{
					trace("配置未加载:config/pvp_shop.json");
				}
			}
			return _pvpShopItemVos;
		}

		private static var _pvpRewardVos:Array;

		public static function get pvpRewardVos():Array
		{
			if (!_pvpRewardVos)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/pvp_reward1.json");
				if (_json)
				{
					_pvpRewardVos=[];
					for each (var c:* in _json)
					{
						var vo:PvpRewardVo=VoHasTool.hasVo(PvpRewardVo, c);
						_pvpRewardVos.push(vo);
					}
				}
				else
				{
					trace("配置未加载:config/pvp_reward1.json");
				}
			}
			return _pvpRewardVos;
		}

		public static function getItemImgPath(id:String, size:String=""):String
		{
			var iPath:String="";
			switch (items_dic[id].type)
			{
				case 14:
				case 15:
					iPath="appRes/icon/unitPic/";
					break;
				default:
					iPath="appRes/icon/itemIcon/";
					break;
			}
			var tmp:String = items_dic[id].icon+"";
			if(tmp.indexOf("_h") != -1){
				iPath="appRes/icon/unitPic/";
			}
			
			iPath=iPath + items_dic[id].icon + size + ".png";
			iPath=URL.formatURL(iPath)
			return iPath;
		}
		
		
		// 降级一下  沿用原来的
		private static var _map = ['2', '3', '4', '5', '6', '7', '1', '1'];
		/**
		 * 
		 * 
		 * 
		 */
		/**
		 * 获取公会logo皮肤    分两部分  背景和图标
		 * @param parent 需要logo设置的元素 需要的一个img元素（兼容以前的设置）
		 * @param param   1_2|3_2
		 * @param scaleNum 倍率
		 * @return 
		 * 
		 */
		public static function setGuildLogoSkin(parent:Image, param:String, scaleNum:Number = 1):Array {
			param = param || "2";
			var parts:Array = String(param).split("|");
			if (parts.length != 2) {
				param = '1_5|' + _map[param] + '_5';
				parts = param.split("|");
			}
			var bg = parts[0].split("_");
			var logo = parts[1].split("_");
			parent.destroyChildren();
			parent.skin = "";
			var sp:Sprite = new Sprite();
			var img1 = new Image("appRes/icon/guildIcon/new/d" + bg[0] + "_" + bg[1] + ".png");
			var img2 = new Image("appRes/icon/guildIcon/new/0" + logo[0] + "_" + logo[1] + ".png");
			sp.addChildren(img1, img2);
			sp.scale(scaleNum, scaleNum);
			
			parent.addChild(sp);
		}

		public static function get awakenVoDic():Object
		{
			if (!_awakenVoDic)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/awaken_nature.json");
				if (_json)
				{
					_awakenVoDic={};
					for each (var c:* in _json)
					{
						var vo:AwakenVo=VoHasTool.hasVo(AwakenVo, c);
						_awakenVoDic[vo.id]=vo;
					}
				}
				else
				{
					trace("配置未加载:config/awaken_nature.json");
				}
			}
			return _awakenVoDic;
		}

		public static function get awakenTypeVoDic():Object
		{
			if (!_awakenTypeVoDic)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/awaken_type.json");
				if (_json)
				{
					_awakenTypeVoDic={};
					for each (var c:* in _json)
					{
						var vo:AwakenTypeVo=VoHasTool.hasVo(AwakenTypeVo, c);
						_awakenTypeVoDic[vo.id]=vo;
					}
				}
				else
				{
					trace("配置未加载:config/awaken_type.json");
				}
			}
			return _awakenTypeVoDic;
		}


		public static function get awakenSpecialityVoArr():Array
		{
			if (!_awakenSpecialityVoArr)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/awaken_speciality.json");
				if (_json)
				{
					_awakenSpecialityVoArr=[];
					for each (var c:* in _json)
					{
						var vo:AwakenSpecialityVo=VoHasTool.hasVo(AwakenSpecialityVo, c);
						_awakenSpecialityVoArr.push(vo);
					}
				}
				else
				{
					trace("配置未加载:config/awaken_speciality.json");
				}
			}
			return _awakenSpecialityVoArr;
		}


		public static function get itemSource_dic():Object
		{
			if (!_itemSource_dic)
			{
				var _json:*=ResourceManager.instance.getResByURL("config/source.json");
				if (_json)
				{
					_itemSource_dic={};
					for each (var c:* in _json)
					{
						var vo:itemSourceVo=VoHasTool.hasVo(itemSourceVo, c);
						_itemSource_dic[vo.id]=vo;
					}
				}
				else
				{
					trace("配置未加载:config/source.json");
				}
			}
			return _itemSource_dic;
		}

		public static function initStageConfig():void
		{
			var c:*;
			var vo:*;
			var stage_chapter_json:*=ResourceManager.instance.getResByURL("config/stage_chapter.json");
			if (stage_chapter_json)
			{
				for each (c in stage_chapter_json)
				{
					vo=VoHasTool.hasVo(StageChapterVo, c);
					stage_chapter_dic[(vo as StageChapterVo).chapter_id]=vo;
					stage_chapter_arr.push(vo);
				}
			}

			var stage_level_json:*=ResourceManager.instance.getResByURL("config/stage_level.json");
			if (stage_level_json)
			{
				for each (c in stage_level_json)
				{
					vo=VoHasTool.hasVo(StageLevelVo, c);
					stage_level_dic[(vo as StageLevelVo).id]=vo;
					stage_level_arr.push(vo);
				}
			}


			var stage_chapter_jy_json:*=ResourceManager.instance.getResByURL("config/elite_chapter.json");
			if (stage_chapter_jy_json)
			{
				for each (c in stage_chapter_jy_json)
				{
					vo=VoHasTool.hasVo(JYStageChapterVo, c);
					stage_chapter_jy_dic[(vo as JYStageChapterVo).chapter_id]=vo;
					stage_chapter_jy_arr.push(vo);

					for (var i:int=0; i < (vo as JYStageChapterVo).chapterRewardList.length; i++)
					{
						var srv:StageChapterRewardVo=(vo as JYStageChapterVo).chapterRewardList[i];
						srv.isJY=true;
					}
				}
			}

			var stage_level_jy_json:*=ResourceManager.instance.getResByURL("config/elite_level.json");
			if (stage_level_jy_json)
			{
				for each (c in stage_level_jy_json)
				{
					vo=VoHasTool.hasVo(StageLevelVo, c);
					stage_level_jy_dic[(vo as StageLevelVo).id]=vo;
					stage_level_jy_arr.push(vo);
				}
			}
		}


	}
}
