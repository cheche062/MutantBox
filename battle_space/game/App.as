package game
{
	import game.common.AndroidPlatform;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.base.IApp;
	import game.global.GameConfigManager;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBItem;
	import game.global.data.DBMilitary;
	import game.global.event.GameEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.camp.CampData;
	import game.module.login.PreLoadingView;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.utils.Browser;
	import laya.utils.Handler;

	/**
	 * App 系统管理层,只要负责逻辑协调
	 * author:huhaiming
	 * App.as 2017-4-13 下午12:08:13
	 * version 1.0
	 *
	 */
	public class App implements IApp
	{
		public function App()
		{
		}

		//
		public function start():void
		{
			initEvent();
			ResourceManager.instance.init(Handler.create(this, onConfigLoaded));
		}

		/**配置加载成功，加载显示loading界面,进入正式流程*/
		private function onConfigLoaded():void
		{
			XFacade.instance.showModule(PreLoadingView);
		}

		//更新用户
		private function onUpdate(... args):void
		{
			var itemId:*=args[1];
			var user:User=User.getInstance();
			switch (itemId)
			{
				case DBItem.WATER:
				case DBItem.STEEL:
				case DBItem.STONE:
				case DBItem.GOLD:
				case DBItem.FOOD:
				case DBItem.CONTRIBUTE:
				case DBItem.DB:
				case DBItem.BREAD:
//					trace("itemId");
					user.setResNumByItem(itemId, args[2]);
					user.event(itemId);
					break;
				case DBItem.MEDAL:
					DBMilitary.checkState(user.cup, args[2]);
					user.cup=args[2];
					user.event();
					break;
				case DBItem.MINE_POINT:
					user.minePoint=args[2];
					user.event();
					break;
				case DBItem.PURPLE_CRYSTAL:
					user.purpleCrystal=args[2];
					user.event();
					break;
				case DBItem.ARMY_GROUP_FOOD:
					//user.armyGroupFood=args[2];
					//user.event();
					break;
				default:
					break;
			}
		}

		private function onUpdateVipInfo(... args):void
		{
			User.getInstance().VIP_LV=args[1].vip_info.vip_level;
			User.getInstance().chargeNum=args[1].vip_info.amount;
			User.getInstance().event();
		}

		private function onUpdateLv(... args):void
		{
			if (parseInt(args[1]) == 17 && User.getInstance().level != 17)
			{
				AndroidPlatform.instance.FGM_CustumEvent("Level 17");
			}
			if (parseInt(args[1]) == 12 && User.getInstance().level != 12)
			{
				AndroidPlatform.instance.FGM_EventAchievedLevel(12);
			}

			User.getInstance().level=parseInt(args[1]);
			User.getInstance().exp=parseInt(args[2]);
			User.getInstance().event();
		}

		private function onUpdateUnit(... args):void
		{
			var unitInfo:Object=args[2]
			CampData.updateUnit(unitInfo.unitId, unitInfo);

			Signal.intance.event(GameEvent.UPDATE_UNIT_INFO);
		}

		private function onNewFunOpen(... args):void
		{
			trace("功能推送: ", args);
			User.getInstance().curGuideArr.push(args[1][0]);

			/**
			 * 特殊处理不进行任何判断直接开始引导
			 * 470 第一次进入公会触发引导
			 */
			if (GameConfigManager.fun_open_vec[args[1][0]].g_id == 470 || 
				GameConfigManager.fun_open_vec[args[1][0]].g_id == 1100 || 
				GameConfigManager.fun_open_vec[args[1][0]].g_id == 1250
			)
			{
				XFacade.instance.openModule(ModuleName.FunctionGuideView, GameConfigManager.fun_open_vec[args[1][0]].g_id);
				return
			}

			//trace("isInMainView:", User.getInstance().isInMainView);

			if (User.getInstance().curGuideArr.length == 1 && LayerManager.instence.isOnlyMain && User.getInstance().isInMainView)
			{
				if (GameConfigManager.fun_open_vec[args[1][0]].lx == 2)
				{
					//trace("aaadasd: ",GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[args[1][0]].g_id].delayTime);
					if (GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[args[1][0]].g_id].special && GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[args[1][0]].g_id].special == "waitFight")
					{
						return;
					}
					else if (GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[args[1][0]].g_id].delayTime)
					{
						//trace("yanchishufa");
						Laya.timer.once(parseInt(GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[args[1][0]].g_id].delayTime), this, function()
						{
							XFacade.instance.openModule(ModuleName.FunctionGuideView, GameConfigManager.fun_open_vec[args[1][0]].g_id);
						})
					}
					else
					{
						XFacade.instance.openModule(ModuleName.FunctionGuideView, GameConfigManager.fun_open_vec[args[1][0]].g_id);
					}
				}
				else if (GameConfigManager.fun_open_vec[args[1][0]].lx == 4)
				{
					XFacade.instance.openModule(ModuleName.HQUpgradeView, args[1][0]);
				}
				else
				{
					XFacade.instance.openModule(ModuleName.CommonGuideView, args[1][0]);
				}
			}

		}

		public function closeViewHandler():void
		{
			//trace("页面关闭，监测是否已关闭所有页面：", LayerManager.instence.isOnlyMain);
			if (LayerManager.instence.isOnlyMain && !User.getInstance().isInGuilding && User.getInstance().isInMainView)
			{
				/*trace("关闭页面开启引导OnlyMain：", LayerManager.instence.isOnlyMain);
				trace("关闭页面开启引导InGuilding：", User.getInstance().isInGuilding);
				trace("关闭页面开启引导InMainView：", User.getInstance().isInMainView);*/
				User.getInstance().checkHasNextGuide();
			}
		}

		//需要处理同步问题...
		private function onActive(type:String):void
		{
			switch (type)
			{
				case Event.BLUR:
					break;
				case Event.FOCUS:
					if (WebSocketNetService.instance.isClose && GameSetting.isApp)
					{
						GameSetting.reloadGame();
					}
					break;
			}
		}

		private function onRdy():void
		{
			CampData.update();
			//心跳
			heartbreak();
			Laya.timer.loop(30 * 1000, this, heartbreak);
		}

		private function heartbreak():void
		{
			Laya.timer.once(8000, this, onClose);
			WebSocketNetService.instance.sendData(ServiceConst.HEARTBEAT);
		}

		private function onClose():void
		{
			WebSocketNetService.instance.closeSocket();
			Laya.timer.clear(this, heartbreak);
		}

		private function onHB(... args):void
		{
			Laya.timer.clear(this, onClose);
			var info:Object=args[1];
			TimeUtil.syncSrvTime(info[0]);
			TimeUtil.timeStr=info[1]
			XFacade.instance.getView(MainView).updateTime();
		}

		private function initEvent():void
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PUSH_INFO), this, this.onUpdate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.JOIN_GUILD_OK), this, this.joinGuildOK);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PUSH_EXP), this, this.onUpdateLv);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.VIP_UPDATE), this, this.onUpdateVipInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PUSH_SOLDIER), this, this.onUpdateUnit);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PUSH_HERO), this, this.onUpdateUnit);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PUSH_NEW_FUN), this, this.onNewFunOpen);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.HEARTBEAT), this, this.onHB);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_PROGRESS), this, this.refreshRed);
			Signal.intance.on(Event.CLOSE, this, this.closeViewHandler);

			Signal.intance.once(PreLoadingView.RDY, this, this.onRdy);
			Laya.stage.on(Event.BLUR, this, this.onActive, [Event.BLUR]);
			Laya.stage.on(Event.FOCUS, this, this.onActive, [Event.FOCUS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GAME_BOARD_GET_LIST), this, this.onGetBoardList);
		}
		
		private function refreshRed(... args):void
		{
			RedPointManager.intance.requestStoryRed();
		}
		
		/**
		 * 接收登录面板消息
		 * @param args 服务器返回消息
		 * @author douchaoyang
		 *
		 */
		private function onGetBoardList(... args):void
		{
			// 如果正在新手引导中，或者没有完成新手引导，不弹出
			if (User.getInstance().isInGuilding || !User.getInstance().hasFinishGuide)
			{
				return;
			}

			XFacade.instance.openModule(ModuleName.GameBoardView, args[1]);
			trace("GameBoardView数据:"+JSON.stringify(args));
		/*var testArr = [ { "id":"3", "UI_type":"1", "order":"300", "select":"", "url":"1", "title":"", "des":"", "icon":"", "param1":"", "param2":"", "param3":"", "param4":"" },
		 { "id":"3", "UI_type":"1", "order":"300", "select":"", "url":"2", "title":"", "des":"", "icon":"", "param1":"", "param2":"", "param3":"", "param4":"" } ,
		  { "id":"3", "UI_type":"1", "order":"300", "select":"", "url":"3", "title":"", "des":"", "icon":"", "param1":"", "param2":"", "param3":"", "param4":"" } ];
		XFacade.instance.openModule(ModuleName.GameBoardView, testArr);*/
		}

		private function joinGuildOK(... args):void
		{
			var guildData = args[2];
			
			User.getInstance().guildID = ToolFunc.isArray(guildData)? guildData[0] : guildData;
			
			trace("getJoinGuildOK: ", User.getInstance().guildID);
			
		}
	}
}
