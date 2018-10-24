package game.module.startrek
{
	import game.common.UIRegisteredMgr;
	import MornUI.startrek.StarTrekMainViewUI;
	
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBFightEffect;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.StarTrekEvent;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * 星际迷航
	 * @author douchaoyang
	 *
	 */
	public class StarTrekMainView extends BaseDialog
	{
		/**
		 * 怪物+战斗组
		 */
		private const EVENT_1:int=1;
		/**
		 * 奖励
		 */
		private const EVENT_2:int=2;
		/**
		 * buff
		 */
		private const EVENT_3:int=3;
		/**
		 * 商店+商品id
		 */
		private const EVENT_4:int=4;
		/**
		 * boss+战斗组
		 */
		private const EVENT_5:int=5;
		/**
		 * 宝箱+道具id=数量
		 */
		private const EVENT_6:int=6;
		// 定义盒子
		private const _M_:int=6;
		private const _N_:int=9;
		private var iBox:Vector.<StarTrekBox>=new Vector.<StarTrekBox>(_M_);

		// 背包
		private var bagItems:Object={};

		// 购买次数
		private var buyTimes:Object={};

		// 刷新次数
		private var refreshTimes:int=0;

		// 开盒子特效
		private var _boxEffect:Animation;

		// 增加buff特效
		private var _buffEffect:Animation;

		/**
		 * 最终奖励id
		 */
		private var tableId:int=1;

		/**
		 *  是否领过最终奖励
		 */
		private var passReward:Boolean;

		public function StarTrekMainView()
		{
			super();
			m_iPositionType=LayerManager.LEFTUP;
			// 创建vector二维数组
			for (var i=0; i < _M_; i++)
				iBox[i]=new Vector.<StarTrekBox>(_N_);
		}

		override public function show(... args):void
		{
			super.show();
			resizeHandler();
			initBoxHandler();
			WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_INIT_MENU);
			// 刷新用户资源信息
			refreshUserInfo();
			resetAllBuffs();
		}

		override public function close():void
		{
			super.close();
			XFacade.instance.closeModule(StarTrekBagView);
			XFacade.instance.closeModule(StarTrekBuffView);
			XFacade.instance.closeModule(StarTrekShopView);
			/*打开主界面*/
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}

		/**
		 * 重写添加事件方法
		 *
		 */
		override public function addEvent():void
		{
			Laya.stage.on(Event.RESIZE, this, this.resizeHandler);
			view.on(Event.CLICK, this, this.onClickHandler);
			Signal.intance.on(StarTrekEvent.IBOXCLICK, this, this.onIboxClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_INIT_MENU), this, this.onResultHandler, [ServiceConst.STAR_TREK_INIT_MENU]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_RESET_MENU), this, this.onResultHandler, [ServiceConst.STAR_TREK_RESET_MENU]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_OPEN_BOX), this, this.onResultHandler, [ServiceConst.STAR_TREK_OPEN_BOX]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_GET_THINGS), this, this.onResultHandler, [ServiceConst.STAR_TREK_GET_THINGS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_FINAL_REWARD), this, this.onResultHandler, [ServiceConst.STAR_TREK_FINAL_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			// 用户的信息发生变化时
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshUserInfo);
			super.addEvent();
		}

		/**
		 * 重写移除事件方法
		 *
		 */
		override public function removeEvent():void
		{
			Laya.stage.off(Event.RESIZE, this, this.resizeHandler);
			view.off(Event.CLICK, this, this.onClickHandler);
			Signal.intance.off(StarTrekEvent.IBOXCLICK, this, this.onIboxClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_INIT_MENU), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_RESET_MENU), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_OPEN_BOX), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_GET_THINGS), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_FINAL_REWARD), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			Signal.intance.off(User.PRO_CHANGED, this, this.refreshUserInfo);
			super.removeEvent();
		}


		/**
		 * 服务器报错消息处理
		 * @param args
		 *
		 */
		private function onError(... args):void
		{
			var cmd:Number=args[1]; // cmd key
			var errStr:String=args[2]; // language key
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}

		/**
		 * 服务器消息处理
		 * @param cmd
		 * @param args
		 *
		 */
		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.STAR_TREK_INIT_MENU:
					trace("初始面板数据", args);
					// 设置起点
					updateSingleBox(args[1].startPos[0], args[1].startPos[1], StarTrekBox.STATE_0);
					// 更新各点
					updateStateByEvent(args[2]);
					// 设置刷新价格
					setCostInfo(parseInt(args[1].resetTimes) + 1);
					refreshTimes=args[1].resetTimes;
					// 更新背包
					bagItems=args[1].items;
					buyTimes=args[1].buyTimes;
					// 更新buff
					showBuffsHandler(args[1].buffs);
					// 最终奖励相关
					if (String(args[1].tableId) == "null")
					{
						view.finalBtn.disabled=true;
					}
					else
					{
						view.finalBtn.disabled=false;
						tableId=args[1].tableId;
						passReward=!!args[1].passReward;
						view.finalImgClose.visible=!(view.finalImgOpen.visible=passReward);
					}
					break;
				case ServiceConst.STAR_TREK_RESET_MENU:
					trace("重置面板数据", args);
					// 重置游戏
					setCostInfo(parseInt(args[1].resetTimes) + 1);
					refreshTimes=args[1].resetTimes;
					resetAllBox();
					resetAllBuffs();
					updateSingleBox(args[1].startPos[0], args[1].startPos[1], StarTrekBox.STATE_0);
					// 更新背包
					bagItems=args[1].items;
					buyTimes=args[1].buyTimes;

					if (String(args[1].tableId) == "null")
					{
						view.finalBtn.disabled=true;
					}
					else
					{
						view.finalBtn.disabled=false;
						tableId=args[1].tableId;
						passReward=!!args[1].passReward;
						view.finalImgClose.visible=!(view.finalImgOpen.visible=passReward);
					}
					break;
				case ServiceConst.STAR_TREK_OPEN_BOX:
					trace("开盒子数据", args);
					// 开盒子
					if (args[1])
					{
						updateStateByEvent(args[1]);
					}
					break;
				case ServiceConst.STAR_TREK_GET_THINGS:
					trace("开宝箱||开奖励数据", args);
					if (args[2].reward)
					{
						// 显示奖励
						showThingsHandler(args[2].reward);
					}
					if (args[2].items)
					{
						// 更新背包
						bagItems=args[2].items;
					}
					if (args[2].buyTimes)
					{
						buyTimes=args[2].buyTimes;
					}
					if (args[2].buffs)
					{
						// 更新buff
						addBuffHandler(args[2].buffs);
					}
					// 更新盒子状态
					updateStateByEvent(args[1]);
					break;
				case ServiceConst.STAR_TREK_FINAL_REWARD:
					passReward=true;
					view.finalImgClose.visible=!(view.finalImgOpen.visible=true);
					XFacade.instance.openModule(ModuleName.StarTrekFinalView, {"rewardStr": GameConfigManager.StarTrekGrid[tableId].reward, "passReward": passReward});
					break;
				default:
					break;
			}
		}

		/**
		 * 显示buff
		 * @param list
		 *
		 */
		private function showBuffsHandler(list:Array):void
		{
			var i:int;
			var data:Object;
			if (list.length > 5)
			{
				list.length=5;
			}
			// 显示buff
			for (i=0; i < list.length; i++)
			{
				if (DBFightEffect.getEffectInfo(list[i]))
				{
					data=DBFightEffect.getEffectInfo(list[i]);
					view["buff" + i].visible=true;
					view["buff" + i].name=data.des;
					view["buff" + i + "Icon"].skin="appRes/icon/mazeIcon/" + data.icon + ".png";
					view["buff" + i].on(Event.CLICK, view["buff" + i], function():void
					{
						XTipManager.showTip(this.name);
					});
				}
			}
		}

		private function addBuffHandler(list:Array):void
		{
			var i:int;
			var data:Object;
			if (list.length > 5)
			{
				list.length=5;
			}
			// 显示buff
			for (i=0; i < list.length; i++)
			{
				if (DBFightEffect.getEffectInfo(list[i]) && !view["buff" + i].visible)
				{
					data=DBFightEffect.getEffectInfo(list[i]);
					view["buff" + i].name=data.des;
					view["buff" + i + "Icon"].skin="appRes/icon/mazeIcon/" + data.icon + ".png";
					view["buff" + i].on(Event.CLICK, view["buff" + i], function():void
					{
						XTipManager.showTip(this.name);
					});
					Tween.from(view["buff" + i], {scaleX: 1.5, scaleY: 1.5, alpha: 0.5}, 200);
					view["buff" + i].visible=true;
					playBuffAnimation(view["buff" + i]);
				}
			}
		}

		/**
		 * 显示得到的奖励，开启宝箱得到的奖励
		 * @param list
		 *
		 */
		private function showThingsHandler(list:Array):void
		{
			var data:Array=[];
			for (var i=0; i < list.length; i++)
			{
				var item:ItemData=new ItemData();
				item.iid=list[i].id;
				item.inum=list[i].num;
				data.push(item);
			}
			XFacade.instance.openModule(ModuleName.ShowRewardPanel, [data]);
		}

		/**
		 * 刷新用户资源信息
		 *
		 */
		private function refreshUserInfo():void
		{
			// 食物
			view.foodIcon.skin=GameConfigManager.getItemImgPath(DBItem.FOOD);
			view.foodIcon.on(Event.CLICK, this, function():void
			{
				ItemTips.showTip(DBItem.FOOD);
			});
			view.foodTxt.text=XUtils.formatResWith(User.getInstance().food);
			// 水
			view.waterIcon.skin=GameConfigManager.getItemImgPath(DBItem.WATER);
			view.waterIcon.on(Event.CLICK, this, function():void
			{
				ItemTips.showTip(DBItem.WATER);
			});
			view.waterTxt.text=XUtils.formatResWith(User.getInstance().water);
		}

		/**
		 * 设置刷新所费资源信息
		 * @param num
		 *
		 */
		private function setCostInfo(num:int):void
		{
			var data:*=GameConfigManager.StarTrekPrices;
			var id:int=num < data.length ? num : data.length - 1;
			if (num == 1)
			{
				view.freeTxt.visible=!(view.costIcon.visible=view.costTxt.visible=false);
				view.freeTxt.text="FREE:1";
			}
			else
			{
				view.freeTxt.visible=!(view.costIcon.visible=view.costTxt.visible=true);
				view.costIcon.skin=GameConfigManager.getItemImgPath(String(data[id].cost).split("=")[0]);
				view.costIcon.on(Event.CLICK, this, function():void
				{
					ItemTips.showTip(String(data[id].cost).split("=")[0]);
				});
				view.costTxt.text=String(data[id].cost).split("=")[1];
			}
		}

		/**
		 * 根据后端返回的数据(事件id)，更新盒子
		 * @param args
		 *
		 */
		private function updateStateByEvent(args:Object):void
		{
			var x:int;
			var y:int;
			var thisBox:StarTrekBox;
			var data:Object;
			if (!args)
				return false;
			for (var attr:* in args)
			{
				x=parseInt(String(attr).split("_")[0]);
				y=parseInt(String(attr).split("_")[1]);
				thisBox=getBoxBySid(x, y);
				// 如果事件id是0
				if (args[attr] == 0)
				{
					// 不是家，设置已走过
					if (thisBox.iState != StarTrekBox.STATE_0)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_4);
					}
				}
				else
				{
					data=GameConfigManager.StarTrekEvents[args[attr]] || null;
					if (!data)
						return false;
					if (data.type == EVENT_1)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_8, data.icon, args[attr]);
					}
					if (data.type == EVENT_2)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_7, data.icon, args[attr]);
					}
					if (data.type == EVENT_3)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_6, data.icon, args[attr]);
					}
					if (data.type == EVENT_4)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_5, data.icon, args[attr]);
					}
					if (data.type == EVENT_5)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_9, data.icon, args[attr]);
					}
					if (data.type == EVENT_6)
					{
						updateSingleBox(x, y, StarTrekBox.STATE_7, data.icon, args[attr]);
					}
				}
			}
		}

		/**
		 * 当点击某个盒子时
		 * @param args
		 *
		 */
		private function onIboxClickHandler(... args):void
		{
			// 可以播放音效
			// SoundMgr.instance.playSound(ResourceManager.getSoundUrl("ui_common_click",'uiSound'));
			var thisBox:StarTrekBox=getBoxBySid(args[0], args[1]);
			trace("当前的盒子状态：", thisBox.iState);
			switch (thisBox.iState)
			{
				case StarTrekBox.STATE_0:
					//家
					break;
				case StarTrekBox.STATE_1:
					//默认没打开状态
					break;
				case StarTrekBox.STATE_2:
					//默认可打开状态
					// 我的动画，策划不要。animComeIn(thisBox);
					if (!boxEffect.isPlaying)
					{
						playBoxAnimation(thisBox);
					}
					// WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_OPEN_BOX, [thisBox.iX, thisBox.iY]);
					break;
				case StarTrekBox.STATE_3:
					//不能打开，周围有怪物
					XTip.showTip("L_A_76218");
					break;
				case StarTrekBox.STATE_4:
					//已走过
					break;
				case StarTrekBox.STATE_5:
					//商店
					// 打开shop view
					trace("main buytimes", buyTimes);
					XFacade.instance.openModule(ModuleName.StarTrekShopView, {"x": thisBox.iX, "y": thisBox.iY, "id": thisBox.iEvent, "buyTimes": buyTimes});
					break;
				case StarTrekBox.STATE_6:
					//buff
					// 打开buff view
					XFacade.instance.openModule(ModuleName.StarTrekBuffView, {"x": thisBox.iX, "y": thisBox.iY, "id": thisBox.iEvent});
					break;
				case StarTrekBox.STATE_7:
					//奖励
					WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_GET_THINGS, [thisBox.iX, thisBox.iY]);
					break;
				case StarTrekBox.STATE_8:
					//小怪
					this.close();
					FightingManager.intance.getSquad(116, [thisBox.iX, thisBox.iY], Handler.create(this, this.onFightOverHandler, null, false));
					break;
				case StarTrekBox.STATE_9:
					//boss
					this.close();
					FightingManager.intance.getSquad(116, [thisBox.iX, thisBox.iY], Handler.create(this, this.onFightOverHandler, null, false));
					break;
				default:
					break;
			}
		}

		/**
		 * 战斗结束
		 *
		 */
		private function onFightOverHandler():void
		{
			//关闭战斗
			if (SceneManager.intance.m_sceneCurrent)
			{
				SceneManager.intance.m_sceneCurrent.close();
				SceneManager.intance.m_sceneCurrent=null;
			}
			XFacade.instance.openModule(ModuleName.StarTrekMainView);
		}

		/**
		 * 动画入场
		 * @param box
		 * @return
		 *
		 */
		private function animComeIn(box:*)
		{
			Tween.from(box, {alpha: 0.6, y: box.y + 3}, 200);
		}

		private function playBoxAnimation(o:StarTrekBox):void
		{
			boxEffect.x=o.x - 15;
			boxEffect.y=o.y - 15;
			boxEffect.visible=true;
			boxEffect.play(0, false);
			boxEffect.once(Event.COMPLETE, this, this.onPlayBoxAnimationComplete, [o]);
		}

		private function onPlayBoxAnimationComplete(... args):void
		{
			var o:StarTrekBox=(args[0] as StarTrekBox);
			WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_OPEN_BOX, [o.iX, o.iY]);
			boxEffect.visible=false;
		}

		private function playBuffAnimation(o:Box):void
		{
			buffEffect.x=o.x - 50;
			buffEffect.y=o.y - 50;
			buffEffect.visible=true;
			buffEffect.play(0, false);
			buffEffect.once(Event.COMPLETE, this, this.onPlayBuffAnimationComplete);
		}

		private function onPlayBuffAnimationComplete():void
		{
			buffEffect.visible=false;
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					this.close();
					break;
				case view.resetBtn:
					if (refreshTimes == 0)
					{
						WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_RESET_MENU);
					}
					else
					{
						var data:*=GameConfigManager.StarTrekPrices;
						var id:int=refreshTimes + 1 < data.length ? refreshTimes + 1 : data.length - 1;
						XFacade.instance.openModule(ModuleName.ItemAlertView, [GameLanguage.getLangByKey("L_A_39078"), String(data[id].cost).split("=")[0], String(data[id].cost).split("=")[1], function()
						{
							WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_RESET_MENU);
						}]);
					}
					break;
				case view.bagBtn:
					// if (!!String(bagItems))
					// {
					XFacade.instance.openModule(ModuleName.StarTrekBagView, bagItems);
					// }
					break;
				case view.infoBtn:
					showInfoHandler();
					break;
				case view.finalBtn:
					XFacade.instance.openModule(ModuleName.StarTrekFinalView, {"rewardStr": GameConfigManager.StarTrekGrid[tableId].reward || "", "passReward": passReward});
					break;
				case view.btnAwake:
					XFacade.instance.openModule(ModuleName.NewUnitInfoView);
					break;
				default:
					break;
			}
		}

		private function showInfoHandler():void
		{
			var str:String=GameLanguage.getLangByKey("L_A_76201");
			str=str.replace(/(##)/g, "<br />&nbsp;<br />");
			XFacade.instance.openModule(ModuleName.IntroducePanel, str);
		}

		/**
		 * 自适应处理
		 * @param e
		 *
		 */
		protected function resizeHandler(e:Event=null):void
		{
			// 全屏
			var iWidth:Number=Laya.stage.width;
			var iHeigh:Number=Laya.stage.height;
			view.size(iWidth, iHeigh);
			view.mBg.size(iWidth, iHeigh);
			// 缩放比
			var iScaleWidth:Number=iWidth / 1024;
			var iScaleHeigh:Number=iHeigh / 768;

			view.topBarBg.width=view.bottomBar.width=iWidth;
			view.bottomBar.y=iHeigh - view.bottomBar.height;
			view.closeBtn.x=iWidth - view.closeBtn.width;
			view.infoBox.x=(iWidth - view.infoBox.width) / 2;

			view.leftBarBg.height=view.rightBarBg.height=iHeigh;
			view.leftBar.y=view.rightBar.y=(iHeigh - 768) / 2;
			view.rightBar.x=iWidth - view.rightBar.width;

			// 盒子们
			var iBoxScale:Number=Math.min(iScaleWidth, iScaleHeigh, 1);
			view.menuBox.scaleX=view.menuBox.scaleY=iBoxScale;
			view.menuBox.x=(iWidth - view.menuBox.width * iBoxScale) / 2;
			view.menuBox.y=(iHeigh - (view.menuBox.height - 50) * iBoxScale) / 2;
		}

		override public function createUI():void
		{
			// 加载配置表
			GameConfigManager.intance.loadStarTrekConfig();
			this._view=new StarTrekMainViewUI();
			this.addChild(this._view);
		}

		/**
		 * 初始化游戏盒子
		 *
		 */
		private function initBoxHandler():void
		{
			for (var i=0; i < _M_; i++)
			{
				for (var j=0; j < _N_; j++)
				{
					if (!iBox[i][j])
					{
						iBox[i][j]=new StarTrekBox();
						iBox[i][j].y=415 - 83 * i;
						iBox[i][j].iY=1 + i;
						// 偶数行
						if (i % 2 == 0)
						{
							iBox[i][j].x=0 + 96 * j;
							iBox[i][j].iX=2 * j + 1;
						}
						else
						{
							iBox[i][j].x=48 + 96 * j;
							iBox[i][j].iX=2 * j + 2;
						}
						view.menuBox.addChild(iBox[i][j]);
					}
					// 为了好看，一个压一个
					iBox[i][j].zOrder=15 - i;
					// 初始化状态
					iBox[i][j].iState=StarTrekBox.STATE_1;
					iBox[i][j].iIcon=-1;
				}
				// 奇数行最后一个不要了
				if (i % 2 != 0)
				{
					view.menuBox.removeChild(iBox[i][_N_ - 1]);
				}
			}
			
			
			
			UIRegisteredMgr.AddUI(iBox[3][1],"StarBlock44");
			UIRegisteredMgr.AddUI(iBox[4][2],"StarBlock55");
			
			trace("33: ", iBox[3][3]);
			trace("44: ", UIRegisteredMgr.getTargetUI("StarBlock44"));
		}

		/**
		 * 重置所有盒子状态
		 *
		 */
		private function resetAllBox():void
		{
			for (var i=0; i < _M_; i++)
			{
				for (var j=0; j < _N_; j++)
				{
					if (iBox[i][j])
					{
						iBox[i][j].zOrder=15 - i;
						iBox[i][j].iState=StarTrekBox.STATE_1;
						iBox[i][j].iIcon=-1;
					}
				}
			}
		}

		/**
		 * 重置所有buff状态
		 *
		 */
		private function resetAllBuffs():void
		{
			// 隐藏buff
			for (var i=0; i <= 4; i++)
			{
				view["buff" + i].visible=false;
			}
		}

		/**
		 * 根据后端id获取Box
		 * @param x 后端x
		 * @param y 后端y
		 * @return  返回box
		 *
		 */
		private function getBoxBySid(x:int, y:int):StarTrekBox
		{
			for (var i=0; i < _M_; i++)
			{
				for (var j=0; j < _N_; j++)
				{
					if (iBox[i][j].iX == x && iBox[i][j].iY == y)
					{
						return iBox[i][j];
						break;
					}
				}
			}
		}

		/**
		 * 判断两个盒子是不是相邻
		 * @param x1 后端x1
		 * @param y1 后端y1
		 * @param x2 后端x2
		 * @param y2 后端y2
		 * @return 是否相邻
		 *
		 */
		private function isAroundBox(x1:int, y1:int, x2:int, y2:int):Boolean
		{
			return (x1 != x2) && (Math.abs(x1 - x2) + Math.abs(y1 - y2) == 2);
		}

		/**
		 * 根据后端id返回盒子的周围盒子数组
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		private function getAroundBox(x:int, y:int):Vector.<StarTrekBox>
		{
			var boxArr:Vector.<StarTrekBox>=new Vector.<StarTrekBox>();
			for (var i=0; i < _M_; i++)
			{
				for (var j=0; j < _N_; j++)
				{
					if (isAroundBox(x, y, iBox[i][j].iX, iBox[i][j].iY))
					{
						boxArr.push(iBox[i][j]);
					}
				}
			}
			return boxArr;
		}

		/**
		 * 更新周围盒子的状态
		 * @param x
		 * @param y
		 *
		 */
		private function updateAroundBox(x:int, y:int):void
		{
			var thisBox:StarTrekBox=getBoxBySid(x, y);
			var aroundBox:Vector.<StarTrekBox>=getAroundBox(x, y);
			var i:int=0;
			// 如果打开的是怪
			if (thisBox.iState == StarTrekBox.STATE_8 || thisBox.iState == StarTrekBox.STATE_9)
			{
				for (i=0; i < aroundBox.length; i++)
				{
					if (aroundBox[i].iState == StarTrekBox.STATE_1 || aroundBox[i].iState == StarTrekBox.STATE_2)
					{
						aroundBox[i].iState=StarTrekBox.STATE_3;
					}
				}
			}
			else
			{
				for (i=0; i < aroundBox.length; i++)
				{
					if (aroundBox[i].iState == StarTrekBox.STATE_1)
					{
						aroundBox[i].iState=StarTrekBox.STATE_2;
					}
				}
			}
		}

		/**
		 * 更新某个盒子的状态
		 * @param x
		 * @param y
		 * @param s
		 * @param ev
		 * @param icon
		 *
		 */
		private function updateSingleBox(x:int, y:int, s:int, icon:int=-1, ev:int=-1):void
		{
			getBoxBySid(x, y).iState=s;
			getBoxBySid(x, y).iIcon=icon;
			getBoxBySid(x, y).iEvent=ev;
			updateAroundBox(x, y);
		}

		private function get boxEffect():Animation
		{
			if (!_boxEffect)
			{
				_boxEffect=new Animation();
				_boxEffect.interval=30;
				_boxEffect.zOrder=15;
				_boxEffect.visible=false;
				_boxEffect.loadAtlas("appRes/atlas/effects/starTrekBoxOpen.json");
				view.menuBox.addChild(_boxEffect);
			}
			return _boxEffect;
		}

		private function get buffEffect():Animation
		{
			if (!_buffEffect)
			{
				_buffEffect=new Animation();
				_buffEffect.interval=70;
				_buffEffect.zOrder=1;
				_buffEffect.visible=false;
				_buffEffect.loadAtlas("appRes/atlas/effects/starTrekBuffAdd.json");
				view.leftBar.addChild(_buffEffect);
			}
			return _buffEffect;
		}

		private function get view():StarTrekMainViewUI
		{
			return _view as StarTrekMainViewUI;
		}
	}
}
