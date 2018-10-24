package game.global
{
	import MornUI.guild.CreateGuildViewUI;
	
	import game.common.AlertType;
	import game.common.BaseAlertView;
	import game.common.ItemTips;
	import game.module.SetPlayerNameView;
	import game.module.newerGuideView;
	import game.module.MilitaryHouse.MilitartHouseView;
	import game.module.MilitaryHouse.MilitaryUpgradeView;
	import game.module.TeamCopy.TeamCopyMainView;
	import game.module.TeamCopy.TeamCopyRoomView;
	import game.module.TeamCopy.TeamCopySearchView;
	import game.module.TeamCopy.TeamCopyTipsView;
	import game.module.activity.ActivityMainView;
	import game.module.activity.CongratulationView;
	import game.module.activity.DailySignInView;
	import game.module.activity.FirstChargeView;
	import game.module.activity.TurntableLottleOneView;
	import game.module.activity.TurntableOneRankView;
	import game.module.activity.WelfareMainView;
	import game.module.advance.AdvanceView;
	import game.module.alert.ItemAlertView;
	import game.module.alert.MutilBtnContainer;
	import game.module.arena.ArenaDailyRewardView;
	import game.module.arena.ArenaFreeWin;
	import game.module.arena.ArenaGetRewardView;
	import game.module.arena.ArenaMainView;
	import game.module.arena.ArenaRankView;
	import game.module.arena.ArenaReportView;
	import game.module.arena.ArenaShopView;
	import game.module.armyGroup.AGBuyProtectView;
	import game.module.armyGroup.ArmyDailyMissionView;
	import game.module.armyGroup.ArmyGroupBounsInfoView;
	import game.module.armyGroup.ArmyGroupChatView;
	import game.module.armyGroup.ArmyGroupCityInfoView;
	import game.module.armyGroup.ArmyGroupDefinderList;
	import game.module.armyGroup.ArmyGroupFightLogView;
	import game.module.armyGroup.ArmyGroupHelp;
	import game.module.armyGroup.ArmyGroupMapView;
	import game.module.armyGroup.ArmyGroupOutPutView;
	import game.module.armyGroup.ArmyGroupRankView;
	import game.module.armyGroup.ArmyGroupSeasonRewardView;
	import game.module.armyGroup.GroupChildView;
	import game.module.armyGroup.KilledChildView;
	import game.module.armyGroup.MilitaryRankListView;
	import game.module.armyGroup.MilitaryRankView;
	import game.module.armyGroup.RankingChildView;
	import game.module.armyGroup.fight.ArmyFightSetFood;
	import game.module.armyGroup.fight.ArmyGroupFightView;
	import game.module.armyGroup.newArmyGroup.ArmyMyCityOutputView;
	import game.module.armyGroup.newArmyGroup.NewArmyGroupView;
	import game.module.bag.BagPanel;
	import game.module.bag.ShowRewardPanel;
	import game.module.bag.alert.BagSellAlert;
	import game.module.bag.alert.BagUsePanl;
	import game.module.bag.alert.ConsumeHelpPanel;
	import game.module.bag.alert.ItemUseSelctView;
	import game.module.bagua.BaguaRewardsDialog;
	import game.module.bagua.BaguaView;
	import game.module.bingBook.BingBookMainView;
	import game.module.bingBook.BingBookShowInfoView;
	import game.module.bingBook.SweepView;
	import game.module.board.GameBoardView;
	import game.module.bossFight.BossFightItemView;
	import game.module.bossFight.BossFightRankView;
	import game.module.bossFight.BossFightRuleView;
	import game.module.bossFight.BossFightTipsView;
	import game.module.bossFight.DemonBandatView;
	import game.module.bossFight.RankingRewardView;
	import game.module.buildHelp.BuildHelpView;
	import game.module.camp.CampTip;
	import game.module.camp.CampView;
	import game.module.camp.NewJuXingXQView;
	import game.module.camp.NewJuexingTupoView;
	import game.module.camp.NewUnitInfoView;
	import game.module.camp.NewUpTeXingView;
	import game.module.camp.SkillInfoView;
	import game.module.camp.SkillSourceView;
	import game.module.camp.UnitInfoView;
	import game.module.chargeView.ActChargeView;
	import game.module.chargeView.ChargeView;
	import game.module.chargeView.FaceBookChargeView;
	import game.module.chatNew.LiaotianView;
	import game.module.chatNew.SearchFriendsView;
	import game.module.chests.ChestsMainView;
	import game.module.commonGuide.CommonGuideView;
	import game.module.commonGuide.FunctionGuideView;
	import game.module.commonGuide.HQUpgradeView;
	import game.module.discountShop.DiscountShopView;
	import game.module.equip.EquipMainView;
	import game.module.equip.EquipTipsView;
	import game.module.equipFight.EquipFightInfoView;
	import game.module.equipFight.panel.EquipSelMyArmyPanel;
	import game.module.equipFight.panel.EquipSuppliesPanel;
	import game.module.equipFight.panel.FightLuckyPanel;
	import game.module.fighting.panel.FightJifenjiangliPanel;
	import game.module.fighting.panel.FightReportOverView;
	import game.module.fighting.panel.FightResultPanel;
	import game.module.fighting.panel.GeneFightingPanel;
	import game.module.fighting.panel.JYChapterLevelPanel;
	import game.module.fighting.panel.PTChapterLevelPanel;
	import game.module.fighting.panel.SaoDangRewardView1;
	import game.module.fighting.panel.SaoDangRewardView2;
	import game.module.fighting.panel.showPvpResultsPanel;
	import game.module.fighting.view.PveFightingView;
	import game.module.fighting.view.PvpFightingView;
	import game.module.format.FormatView;
	import game.module.fortress.ChangleView;
	import game.module.fortress.FortressActivityView;
	import game.module.fortress.FortressRankView;
	import game.module.friend.FriendMainView;
	import game.module.friendCode.FriendCodeView;
	import game.module.gameRankView.GameRankView;
	import game.module.gameSet.SetPanel;
	import game.module.gene.GenEnhanceView;
	import game.module.gene.GeneEquipView;
	import game.module.gm.GmToolPanel;
	import game.module.gm.IntroducePanel;
	import game.module.grassShip.GrassShipRankView;
	import game.module.grassShip.GrassShipView;
	import game.module.guide.GuidePanel;
	import game.module.guild.CreateGuildView;
	import game.module.guild.DonateView;
	import game.module.guild.GuildBossDetailView;
	import game.module.guild.GuildBossReward;
	import game.module.guild.GuildBossView;
	import game.module.guild.GuildChatView;
	import game.module.guild.GuildChatViewNew;
	import game.module.guild.GuildDonationView;
	import game.module.guild.GuildIconView;
	import game.module.guild.GuildIntroChangeView;
	import game.module.guild.GuildJoinView;
	import game.module.guild.GuildMainView;
	import game.module.guild.GuildSetLogoView;
	import game.module.guild.GuildSetLvView;
	import game.module.guild.InputGuildNameView;
	import game.module.guild.StoreListAllView;
	import game.module.invasion.InvasionMenuView;
	import game.module.invasion.InvasionView;
	import game.module.inviteFriend.InviteFriendsView;
	import game.module.inviteFriend.InviteGameFriends;
	import game.module.kapai.CardPointView;
	import game.module.kapai.CardShowView;
	import game.module.kapai.KapaiView;
	import game.module.klotski.KlotskiView;
	import game.module.levelGift.LevelGiftView;
	import game.module.liangjiu.LiangjiuView;
	import game.module.login.LoginSwitchView;
	import game.module.login.PreLoadingView;
	import game.module.login.ServerNoticeView;
	import game.module.loneHero.LoneHeroView;
	import game.module.mainui.BoardCasterView;
	import game.module.mainui.MainMenuView;
	import game.module.mainui.MainView;
	import game.module.mainui.speedView.SpeedView;
	import game.module.military.MilitaryUpView;
	import game.module.military.MilitaryView;
	import game.module.mineFight.MineBattleLogView;
	import game.module.mineFight.MineFightView;
	import game.module.mineFight.MineInfoView;
	import game.module.mineFight.MineShopView;
	import game.module.mission.MissionMainView;
	import game.module.monterRiot.MonsterRiotView;
	import game.module.mysteryCode.MysteryCodeView;
	import game.module.newPata.NewPataPreView;
	import game.module.newPata.NewPataView;
	import game.module.othersInfo.OthersInfoView;
	import game.module.pata.PataView;
	import game.module.peopleFallOff.PeopleFallOffView;
	import game.module.playerHelp.HelpNavView;
	import game.module.playerHelp.PlayerHelpView;
	import game.module.pvp.PvpMainPanel;
	import game.module.pvp.PvpRewardPanel;
	import game.module.pvp.PvpShopPanel;
	import game.module.pvp.pvpLogPanel;
	import game.module.pvp.pvpRankPanel;
	import game.module.randomCondition.RandomConditionView;
	import game.module.relic.EscortMainView;
	import game.module.relic.EscortSelectView;
	import game.module.relic.LevelUpView;
	import game.module.relic.PlunderMainView;
	import game.module.relic.PlunderTipsView;
	import game.module.relic.TrainLoadingView;
	import game.module.relic.TrainLogView;
	import game.module.relic.TransportMainView;
	import game.module.replay.ReplayView;
	import game.module.singleRecharge.SingleRechargeView;
	import game.module.startrek.StarTrekBagView;
	import game.module.startrek.StarTrekBuffView;
	import game.module.startrek.StarTrekFinalView;
	import game.module.startrek.StarTrekMainView;
	import game.module.startrek.StarTrekShopView;
	import game.module.store.StoreView;
	import game.module.story.StoryTaskView;
	import game.module.story.StoryView;
	import game.module.techTree.TechBuyPointView;
	import game.module.techTree.TechTreeMainView;
	import game.module.test.TestView;
	import game.module.threeGift.ThreeGiftView;
	import game.module.tigerMachine.IntroduceView;
	import game.module.tigerMachine.TigerMachine;
	import game.module.tigerMachine.TigerRankView;
	import game.module.tips.itemTip.ItemTipManager;
	import game.module.train.TrainView;
	import game.module.trophyRoom.TrophyRoomView;
	import game.module.turnCards.TurnCardsView;
	import game.module.waterLottery.WaterLotteryRuleView;
	import game.module.weekCardCom.WeekCardView;
	import game.module.worldBoss.GameOverView;
	import game.module.worldBoss.WorldBossChatView;
	import game.module.worldBoss.WorldBossEnterView;
	import game.module.worldBoss.WorldBossFightView;
	import game.module.worldBoss.WorldBossMissionView;
	import game.module.worldBoss.WorldBossRankView;
	import game.module.worldBoss.WorldBossSetFood;
	
	import laya.utils.ClassUtils;

	public class RegistClass
	{
		private static var _instance:RegistClass

		public function RegistClass()
		{
			if (_instance)
			{
				throw new Error("LayerManager是单例,不可new.");
			}
			_instance=this;
		}

		public static function get intance():RegistClass
		{
			if (_instance)
				return _instance;
			_instance=new RegistClass;

			return _instance;
		}

		/**
		 * 初始化
		 *
		 */ 
		public function init():void 
		{  
//			ClassUtils.regClass(ModuleName.TestPanel, TestView);
			ClassUtils.regClass(ModuleName.DonateView, DonateView);
			ClassUtils.regClass(ModuleName.StoryView, StoryView);
			ClassUtils.regClass(ModuleName.StoryTaskView, StoryTaskView);
			ClassUtils.regClass(ModuleName.PeopleFallOffView, PeopleFallOffView);
			ClassUtils.regClass(ModuleName.SweepView, SweepView);
			ClassUtils.regClass(ModuleName.RandomConditionView, RandomConditionView);
			ClassUtils.regClass(ModuleName.FightingView_PVE, PveFightingView);
			ClassUtils.regClass(ModuleName.FightingView_PVP, PvpFightingView);
			ClassUtils.regClass(ModuleName.BagPanel, BagPanel);

			ClassUtils.regClass(ModuleName.ItemAlertView, ItemAlertView);

			ClassUtils.regClass(AlertType.BASEALERTVIEW, BaseAlertView);
			ClassUtils.regClass(AlertType.BAGSELLALERT, BagSellAlert);

			ClassUtils.regClass(ModuleName.PreLoadingView, PreLoadingView);

			ClassUtils.regClass(ModuleName.ItemTips, ItemTips);
			ClassUtils.regClass(ModuleName.OthersInfoView, OthersInfoView);
			ClassUtils.regClass(ModuleName.EquipTips, EquipTipsView);
			ClassUtils.regClass(ModuleName.GuidePanel, GuidePanel);

			ClassUtils.regClass(ModuleName.CommonGuideView, CommonGuideView);
			ClassUtils.regClass(ModuleName.HQUpgradeView, HQUpgradeView);
			ClassUtils.regClass(ModuleName.FunctionGuideView, FunctionGuideView);
			ClassUtils.regClass(ModuleName.ChargeView, ChargeView);
			ClassUtils.regClass(ModuleName.ActChargeView, ActChargeView);
			ClassUtils.regClass(ModuleName.ThreeGiftView, ThreeGiftView);

			//facebook充值

			ClassUtils.regClass(ModuleName.FaceBookChargeView, FaceBookChargeView);

			ClassUtils.regClass(ModuleName.TigerMachine, TigerMachine);
			ClassUtils.regClass(ModuleName.DiscountShop, DiscountShopView);
			ClassUtils.regClass(ModuleName.GmToolPanel, GmToolPanel);
			ClassUtils.regClass("MainMenuView", MainMenuView);
			ClassUtils.regClass(ModuleName.MainView, MainView);
			ClassUtils.regClass("TrainView", TrainView);
			ClassUtils.regClass(ModuleName.CampView, CampView);
			ClassUtils.regClass("GeneEquipView", GeneEquipView);
			ClassUtils.regClass("GenEnhanceView", GenEnhanceView);
			ClassUtils.regClass(ModuleName.IntroducePanel, IntroducePanel);
			//世界boss
			ClassUtils.regClass("DemonBandatView", DemonBandatView);
			ClassUtils.regClass("BossFightTipsView", BossFightTipsView);
			ClassUtils.regClass("BossFightRuleView", BossFightRuleView);
			ClassUtils.regClass("RankingRewardView", RankingRewardView);
			ClassUtils.regClass("BossFightRankView", BossFightRankView);
			ClassUtils.regClass("BossFightItemView", BossFightItemView);
			//抽卡
			ClassUtils.regClass(ModuleName.ChestsMainView, ChestsMainView);
			
			ClassUtils.regClass(ModuleName.TigerIntroduce, IntroduceView);
			//
			ClassUtils.regClass(ModuleName.PTChapterLevelPanel, PTChapterLevelPanel);
			ClassUtils.regClass(ModuleName.GeneFightingPanel, GeneFightingPanel);

			ClassUtils.regClass(ModuleName.JYChapterLevelPanel, JYChapterLevelPanel);
			/**
			 * 好友界面
			 */
			ClassUtils.regClass(ModuleName.FriendMainView, FriendMainView);

			/**
			 * 公会相关面板
			 */
			ClassUtils.regClass(ModuleName.CreateGuildView, CreateGuildView);
			ClassUtils.regClass(ModuleName.GuildMainView, GuildMainView);
			ClassUtils.regClass(ModuleName.GuildDonateView, GuildDonationView);
			ClassUtils.regClass(ModuleName.GuildBossView, GuildBossView);
			ClassUtils.regClass(ModuleName.GuildBossDetail, GuildBossDetailView);
			ClassUtils.regClass(ModuleName.MutilBtnContainer, MutilBtnContainer);
			ClassUtils.regClass(ModuleName.GuildSetLvView, GuildSetLvView);
			ClassUtils.regClass(ModuleName.GuildBossReward, GuildBossReward);
			ClassUtils.regClass(ModuleName.GuildChatView, GuildChatView);
			ClassUtils.regClass(ModuleName.InputGuildNameView, InputGuildNameView);
			ClassUtils.regClass(ModuleName.GuildIntroChangeView, GuildIntroChangeView);
			ClassUtils.regClass(ModuleName.GuildIconView, GuildIconView);
			ClassUtils.regClass(ModuleName.GuildSetLogoView, GuildSetLogoView);
			ClassUtils.regClass(ModuleName.StoreListAllView, StoreListAllView);
			
			/**
			 * 雷达站界面
			 */
			ClassUtils.regClass(ModuleName.TechTreeMainView, TechTreeMainView);
			ClassUtils.regClass(ModuleName.TechBuyPointView, TechBuyPointView);

			ClassUtils.regClass(ModuleName.FightResultPanel, FightResultPanel);
			ClassUtils.regClass(ModuleName.FightReportOverView, FightReportOverView);
			ClassUtils.regClass(ModuleName.TigerRankView, TigerRankView);
			ClassUtils.regClass("MonsterRiotView", MonsterRiotView);

			/**
			 * 遗迹
			 */

			ClassUtils.regClass(ModuleName.EscortMainView, EscortMainView);
			ClassUtils.regClass(ModuleName.PlunderMainView, PlunderMainView);
			ClassUtils.regClass(ModuleName.TrainLogView, TrainLogView);
			ClassUtils.regClass(ModuleName.TrainLoadingView, TrainLoadingView);
			ClassUtils.regClass(ModuleName.EscortSelectView, EscortSelectView);
			ClassUtils.regClass(ModuleName.PlunderTipsView, PlunderTipsView);
			ClassUtils.regClass(ModuleName.TransportMainView, TransportMainView);


			/**
			 *武器副本相关
			 **/
			ClassUtils.regClass(ModuleName.EquipFightInfoView, EquipFightInfoView);
			/**
			 * 装备
			 */
			ClassUtils.regClass(ModuleName.EquipMainView, EquipMainView);

			/**
			 * 兵书副本
			 */
			ClassUtils.regClass(ModuleName.BingBookMainView, BingBookMainView);
			ClassUtils.regClass(ModuleName.BingBookShowInfoView, BingBookShowInfoView);
			/**
			 * 任务系统
			 */
			ClassUtils.regClass(ModuleName.MissionMainView, MissionMainView);

			ClassUtils.regClass("StoreView", StoreView);
			ClassUtils.regClass("InvasionView", InvasionView);
			ClassUtils.regClass("InvasionMenuView", InvasionMenuView);
			ClassUtils.regClass("LevelUpView", LevelUpView);
			ClassUtils.regClass("MilitaryView", MilitaryView);
			ClassUtils.regClass("ReplayView", ReplayView);
			ClassUtils.regClass("UnitInfoView", UnitInfoView);
			ClassUtils.regClass("MilitaryUpView", MilitaryUpView);

			ClassUtils.regClass(ModuleName.NewUnitInfoView, NewUnitInfoView);
			ClassUtils.regClass(ModuleName.NewJuXingXQView, NewJuXingXQView);
			ClassUtils.regClass(ModuleName.NewJuexingTupoView, NewJuexingTupoView);
			ClassUtils.regClass(ModuleName.NewUpTeXingView, NewUpTeXingView);

			/**
			 * 新手引导
			 */
			ClassUtils.regClass(ModuleName.NewerGuideView, newerGuideView);
			ClassUtils.regClass(ModuleName.SetPlayerNameView, SetPlayerNameView);


			/**
			 *武器副本相关
			 **/
			ClassUtils.regClass(ModuleName.EquipFightInfoView, EquipFightInfoView);
			ClassUtils.regClass(ModuleName.EquipSelMyArmyPanel, EquipSelMyArmyPanel);
			ClassUtils.regClass(ModuleName.FightLuckyPanel, FightLuckyPanel);
			ClassUtils.regClass(ModuleName.EquipSuppliesPanel, EquipSuppliesPanel);

			ClassUtils.regClass(ModuleName.ConsumeHelpPanel, ConsumeHelpPanel);
//			ClassUtils.regClass("PurchasePanel", PurchasePanel); 

			/**
			 * 竞技场
			 */
			ClassUtils.regClass(ModuleName.ArenaMainView, ArenaMainView);
			ClassUtils.regClass(ModuleName.ArenaShopView, ArenaShopView);
			ClassUtils.regClass(ModuleName.ArenaDailyRewardView, ArenaDailyRewardView);
			ClassUtils.regClass(ModuleName.ArenaGetRewardView, ArenaGetRewardView);
			ClassUtils.regClass(ModuleName.ArenaFreeWin, ArenaFreeWin);
			ClassUtils.regClass(ModuleName.ArenaRankView, ArenaRankView);
			ClassUtils.regClass(ModuleName.ArenaReportView, ArenaReportView);

			/**
			 * SDK选择界面
			 */
			ClassUtils.regClass(ModuleName.LoginSwitchView, LoginSwitchView);
			/**
			 * 矿战
			 */
			ClassUtils.regClass(ModuleName.MineFightView, MineFightView);
			ClassUtils.regClass(ModuleName.MineInfoView, MineInfoView);
			ClassUtils.regClass(ModuleName.MineBattleLogView, MineBattleLogView);
			ClassUtils.regClass(ModuleName.MineShopView, MineShopView);

			/**
			 * 升阶界面
			 */
			ClassUtils.regClass(ModuleName.AdvanceView, AdvanceView);

			/**
			 * 军府
			 */
			ClassUtils.regClass(ModuleName.MilitartHouseView, MilitartHouseView);
			ClassUtils.regClass(ModuleName.MilitaryUpgradeView, MilitaryUpgradeView);

			/**
			 * 活动主界面
			 */
			ClassUtils.regClass(ModuleName.ActivityMainView, ActivityMainView);
			ClassUtils.regClass(ModuleName.FirstChargeView, FirstChargeView);

			//---------------各类活动界面
			/**
			 * 转盘活动界面
			 */
			ClassUtils.regClass(ModuleName.TurntableLottleOneView, TurntableLottleOneView);
			ClassUtils.regClass(ModuleName.TurntableOneRankView, TurntableOneRankView);

			/**
			 * 签到界面
			 */
			ClassUtils.regClass(ModuleName.DailySignInView, DailySignInView);

			/**
			 * 多人副本
			 */
			ClassUtils.regClass(ModuleName.TeamCopyMainView, TeamCopyMainView);
			ClassUtils.regClass(ModuleName.TeamCopyRoomView, TeamCopyRoomView);
			ClassUtils.regClass(ModuleName.TeamCopySearchView, TeamCopySearchView);
			ClassUtils.regClass(ModuleName.TeamCopyTipsView, TeamCopyTipsView);


			ClassUtils.regClass(ModuleName.SetPanel, SetPanel);

//			ClassUtils.regClass(ModuleName.SaoDangView,SaoDangView);
			ClassUtils.regClass(ModuleName.SaoDangRewardView1, SaoDangRewardView1);
			ClassUtils.regClass(ModuleName.SaoDangRewardView2, SaoDangRewardView2);
			ClassUtils.regClass(ModuleName.ShowRewardPanel, ShowRewardPanel);
			ClassUtils.regClass(ModuleName.FightJifenjiangliPanel, FightJifenjiangliPanel);

			ClassUtils.regClass("BagUsePanl", BagUsePanl);
			ClassUtils.regClass("ItemUseSelctView", ItemUseSelctView);

			ClassUtils.regClass(ModuleName.showPvpResultsPanel, showPvpResultsPanel);
			ClassUtils.regClass(ModuleName.PvpMainPanel, PvpMainPanel);
			ClassUtils.regClass(ModuleName.PvpShopPanel, PvpShopPanel);
			ClassUtils.regClass(ModuleName.pvpRankPanel, pvpRankPanel);
			ClassUtils.regClass(ModuleName.pvpLogPanel, pvpLogPanel);
			ClassUtils.regClass(ModuleName.PvpRewardPanel, PvpRewardPanel);
			/**
			 * 公告
			 */
			ClassUtils.regClass(ModuleName.ServerNoticeView, ServerNoticeView);
			
			/**
			 * 游戏排行
			 */
			ClassUtils.regClass(ModuleName.GameRankView, GameRankView);
			 
			 
			/**
			 * 军团
			 */
			ClassUtils.regClass(ModuleName.ArmyGroupMapView, ArmyGroupMapView);
			ClassUtils.regClass(ModuleName.ArmyGroupRankView, ArmyGroupRankView);
			ClassUtils.regClass(ModuleName.ArmyDailyMissionView, ArmyDailyMissionView);
			ClassUtils.regClass(ModuleName.ArmyGroupCityInfoView, ArmyGroupCityInfoView);
			ClassUtils.regClass(ModuleName.RankingChildView, RankingChildView);
			ClassUtils.regClass(ModuleName.KilledChildView, KilledChildView);
			ClassUtils.regClass(ModuleName.GroupChildView, GroupChildView);
			ClassUtils.regClass(ModuleName.MilitaryRankView, MilitaryRankView);
			ClassUtils.regClass(ModuleName.MilitaryRankListView, MilitaryRankListView);
			ClassUtils.regClass(ModuleName.ArmyGroupDefinderList, ArmyGroupDefinderList);
			ClassUtils.regClass(ModuleName.ArmyGroupOutPutView, ArmyGroupOutPutView);
			ClassUtils.regClass(ModuleName.ArmyMyCityOutputView, ArmyMyCityOutputView);
			ClassUtils.regClass(ModuleName.ArmyGroupChatView, ArmyGroupChatView);
			ClassUtils.regClass(ModuleName.ArmyGroupBounsInfoView, ArmyGroupBounsInfoView);
			ClassUtils.regClass(ModuleName.ArmyGroupSeasonRewardView, ArmyGroupSeasonRewardView);
			ClassUtils.regClass(ModuleName.AGBuyProtectView, AGBuyProtectView);

			ClassUtils.regClass("ArmyGroupFightView", ArmyGroupFightView);
			ClassUtils.regClass(ModuleName.ArmyGroupFightLogView, ArmyGroupFightLogView);
			ClassUtils.regClass(ModuleName.ArmyGroupHelp, ArmyGroupHelp);
			ClassUtils.regClass(ModuleName.ArmyFightSetFood, ArmyFightSetFood);

			/**
			 * 战利品室
			 */
			ClassUtils.regClass(ModuleName.TrophyRoomView, TrophyRoomView);

			/**
			 * 游戏登录进入公告板
			 */
			ClassUtils.regClass(ModuleName.GameBoardView, GameBoardView);
			/**
			 * 星际迷航
			 */
			ClassUtils.regClass(ModuleName.StarTrekMainView, StarTrekMainView);
			ClassUtils.regClass(ModuleName.StarTrekBagView, StarTrekBagView);
			ClassUtils.regClass(ModuleName.StarTrekBuffView, StarTrekBuffView);
			ClassUtils.regClass(ModuleName.StarTrekShopView, StarTrekShopView);
			ClassUtils.regClass(ModuleName.StarTrekFinalView, StarTrekFinalView);
			/**
			 * 周卡
			 */
			ClassUtils.regClass(ModuleName.WeekCardView, WeekCardView);
			
			/**
			 * 邀请码
			 */
			ClassUtils.regClass(ModuleName.FriendCodeView, FriendCodeView);
			
			/**
			 * 码兑换
			 */
			ClassUtils.regClass(ModuleName.MysteryCodeView, MysteryCodeView);
			
			
			ClassUtils.regClass(ModuleName.LevelGiftView, LevelGiftView);
			/**
			 * 邀请好友
			 */
			ClassUtils.regClass(ModuleName.InviteFriendsView, InviteFriendsView);
			/**
			 * 邀请游戏内好友
			 */
			ClassUtils.regClass(ModuleName.InviteGameFriends, InviteGameFriends);
			
			/**
			 * 堡垒活动
			 */
			ClassUtils.regClass(ModuleName.FortressActivityView, FortressActivityView);
			
			/**
			 * 堡垒活动排行榜
			 */
			ClassUtils.regClass(ModuleName.FortressRankView, FortressRankView);
			
			/**
			 * 堡垒扫荡确认弹层
			 */
			ClassUtils.regClass(ModuleName.ChangleView, ChangleView);
			
			/**加速卡*/
			ClassUtils.regClass("SpeedView", SpeedView);
			
			/**
			 * 单英雄
			 */
			ClassUtils.regClass(ModuleName.LoneHeroView, LoneHeroView);
			
			/**
			 * 世界BOSS战斗界面
			 */
			ClassUtils.regClass(ModuleName.WorldBossFightView, WorldBossFightView);
			/**设置粮草*/
			ClassUtils.regClass(ModuleName.WorldBossSetFood, WorldBossSetFood);
			/**入口弹层*/
			ClassUtils.regClass(ModuleName.WorldBossEnterView, WorldBossEnterView);
			/**排行榜*/
			ClassUtils.regClass(ModuleName.WorldBossRankView, WorldBossRankView);
			/**任务*/
			ClassUtils.regClass(ModuleName.WorldBossMissionView, WorldBossMissionView);
			/**世界boss游戏结束的弹层*/
			ClassUtils.regClass(ModuleName.GameOverView, GameOverView);
			ClassUtils.regClass(ModuleName.WorldBossChatView, WorldBossChatView);
			ClassUtils.regClass(ModuleName.GuildChatViewNew, GuildChatViewNew);
			 
			/**
			 * 福利活动整合
			 */
			ClassUtils.regClass(ModuleName.WelfareMainView, WelfareMainView);
			
			/**
			 * 草船借箭
			 */
			ClassUtils.regClass(ModuleName.GrassShipView, GrassShipView);
			/**草船借箭 排行榜*/
			ClassUtils.regClass(ModuleName.GrassShipRankView, GrassShipRankView);
			
			/**
			 * 奇门八卦
			 */
			ClassUtils.regClass(ModuleName.BaguaView, BaguaView);
			/**奇门八卦二级弹框*/
			ClassUtils.regClass(ModuleName.BaguaRewardsDialog, BaguaRewardsDialog);
			
			/**
			 * 新手帮助
			 */
			ClassUtils.regClass(ModuleName.HelpNavView, HelpNavView);
			ClassUtils.regClass(ModuleName.PlayerHelpView, PlayerHelpView);
			
			ClassUtils.regClass("KlotskiView", KlotskiView);
			/**
			 * 建筑物帮助
			 */
			ClassUtils.regClass(ModuleName.BuildHelpView, BuildHelpView);
			
			/**
			 * 跑马灯
			 */
			ClassUtils.regClass(ModuleName.BoardCasterView, BoardCasterView);

			/**加入公会*/
			ClassUtils.regClass(ModuleName.GuildJoinView, GuildJoinView);
			ClassUtils.regClass(ModuleName.SingleRechargeView, SingleRechargeView);
			ClassUtils.regClass(ModuleName.TurnCardsView, TurnCardsView);

			ClassUtils.regClass("CampTip", CampTip);
			
			/**卡牌大师*/
			ClassUtils.regClass(ModuleName.KapaiView, KapaiView);
			/**卡牌大师     兑换的二级弹框*/
			ClassUtils.regClass(ModuleName.CardPointView, CardPointView);
			ClassUtils.regClass(ModuleName.CardShowView, CardShowView);
			
			/**聊天汇总界面*/
			ClassUtils.regClass(ModuleName.LiaotianView, LiaotianView);
			ClassUtils.regClass(ModuleName.SearchFriendsView, SearchFriendsView);
			
			/**酿酒*/
			ClassUtils.regClass(ModuleName.LiangjiuView, LiangjiuView);
			ClassUtils.regClass(ModuleName.CongratulationView, CongratulationView);
			
			ClassUtils.regClass(ModuleName.WaterLotteryRuleView, WaterLotteryRuleView);
			
			//布阵
//			ClassUtils.regClass(ModuleName.FormatView, FormatView);
			
			/**技能提升弹层*/
			ClassUtils.regClass(ModuleName.SkillInfoView, SkillInfoView);
			/**技能所需材料的资源来源*/
			ClassUtils.regClass(ModuleName.SkillSourceView, SkillSourceView);
			
			/**新爬塔*/
			ClassUtils.regClass(ModuleName.NewPataView, NewPataView);
			ClassUtils.regClass(ModuleName.NewPataPreView, NewPataPreView);
			
			
			
			
			ItemTipManager.init();

		}
	}
}
