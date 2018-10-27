package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupChatViewUI;

	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * 军团聊天界面
	 * @author douchaoyang
	 *
	 */
	public class ArmyGroupChatView extends BaseView
	{
		private var chatInstance:GlobalRoleDataManger=GlobalRoleDataManger.instance;

		private var oldTimestamp:Date;
		private var newTimestamp:Date;
		private var chatBg:Image;


		public function ArmyGroupChatView()
		{
			super();
			m_iLayerType=LayerManager.M_POP;
			m_iPositionType=LayerManager.LEFT;
		}

		override public function show(... args):void
		{
			super.show(args);
			onStageResize();
			initChatHandler();
			Tween.from(this, {x: -485}, 200);
			
			view.dom_blue_bg.visible = false;
			
			if (args[0] == "false")
			{
				view.tabCtrl.getChildAt(2).visible=false;
				view.tabCtrl.x=80;
				// 当不是星球了如果选择的是星球的消息
				if (view.tabCtrl.selectedIndex == 2)
				{
					view.tabCtrl.selectedIndex=0;
					initChatHandler();
				}
			}
			else
			{
				view.tabCtrl.getChildAt(2).visible=true;
				view.tabCtrl.x=12;
			}
		}

		override public function createUI():void
		{
			this._view=new ArmyGroupChatViewUI();
			this.addChild(this._view);

			// 手动设置tabCtrl字体
			var btns:*=view.tabCtrl.items;
			for (var i:int=0; i < btns.length; i++)
			{
				Button(btns[i]).labelFont=XFacade.FT_BigNoodleToo;
			}

			//chatBg=new Image("armyGroup/bg10.png");
			chatBg=new Image("appRes/armyGroupMap/bg10.png");
			view.addChildAt(chatBg, 0);

			view.chatContainer.vScrollBar.visible=false;
			view.inputTF.maxChars=200;
			view.inputTF.on(Event.INPUT, this, this.checkInput);

			// 初始化信息
			view.tabCtrl.selectedIndex=0;

		}

		override public function onStageResize():void
		{
			// resize聊天面板
			this.scaleY=1;
			this.scaleX=1;
			this.y=LayerManager.instence.stageHeight - this.height >> 1;

			var scaleNum:Number=LayerManager.instence.stageHeight / this.height;
			if (this.y < 0)
			{
				this.y=0;
				this.scaleY=scaleNum;
				this.scaleX=scaleNum;

			}
		}

		/**
		 * 输入禁止超过200个字符
		 *
		 */
		private function checkInput():void
		{
			view.inputTF.text=view.inputTF.text.substr(0, 200);
		}

		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClickHandler);
			view.tabCtrl.off(Event.CHANGE, this, this.initChatHandler);
			Signal.intance.off(GuildEvent.SPREAD_GUILD_TALK, this, this.guildChatHandler);
			Signal.intance.off(ArmyGroupEvent.SPREAD_WORLD_TALK, this, this.worldChatHandler);
			Signal.intance.off(ArmyGroupEvent.SPREAD_CITY_TALK, this, this.cityChatHandler);
			view.inputTF.off(Event.KEY_UP, this, this.sendMsgHandler);
		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClickHandler);
			view.tabCtrl.on(Event.CHANGE, this, this.initChatHandler);
			// 实时获取公会消息
			Signal.intance.on(GuildEvent.SPREAD_GUILD_TALK, this, this.guildChatHandler);
			// 实时获取世界消息
			Signal.intance.on(ArmyGroupEvent.SPREAD_WORLD_TALK, this, this.worldChatHandler);
			// 实时获取城市消息
			Signal.intance.on(ArmyGroupEvent.SPREAD_CITY_TALK, this, this.cityChatHandler);
			// enter发送消息
			view.inputTF.on(Event.KEY_UP, this, this.sendMsgHandler);
		}

		/**
		 * 处理世界聊天消息
		 * @param args
		 *
		 */
		private function worldChatHandler(... args):void
		{
			// 如果是在世界聊天面板
			if (view.tabCtrl.selectedIndex == 0)
			{
				// 如果是自己发送的消息就清空输入框
				if (args[0])
					view.inputTF.text="";
				// 添加消息
				view.chatContainer.addChild(chatInstance.worldChatVo[chatInstance.worldChatCount]);
				chatInstance.worldChatCount++;
				// 刷新面板消息
				view.chatContainer.refresh();
				view.chatContainer.vScrollBar.value=view.chatContainer.vScrollBar.max;

			}
		}

		/**
		 * 处理城市聊天消息
		 * @param args
		 *
		 */
		private function cityChatHandler(... args):void
		{
			// 如果是在城市聊天面板
			if (view.tabCtrl.selectedIndex == 2)
			{
				// 如果是自己发送的消息就清空输入框
				if (args[0])
					view.inputTF.text="";
				// 添加消息
				view.chatContainer.addChild(chatInstance.cityChatVo[chatInstance.cityChatCount]);
				chatInstance.cityChatCount++;
				// 刷新面板消息
				view.chatContainer.refresh();
				view.chatContainer.vScrollBar.value=view.chatContainer.vScrollBar.max;

			}
		}

		/**
		 * 获取公会聊天信息
		 *
		 */
		private function guildChatHandler(... args):void
		{
			// 如果是在公会聊天面板
			if (view.tabCtrl.selectedIndex == 1)
			{
				// 如果是自己发送的消息就清空输入框
				if (args[0])
					view.inputTF.text="";
				// 添加消息
				view.chatContainer.addChild(chatInstance.armyChatVo[chatInstance.armyChatCount]);
				chatInstance.armyChatCount++;
				// 刷新面板消息
				view.chatContainer.refresh();
				view.chatContainer.vScrollBar.value=view.chatContainer.vScrollBar.max;

			}
		}

		private function sendMsgHandler(... args):void
		{


			// 如果是键盘操作但不是enter键，返回
			if (args[0] && Event(args[0]).keyCode != 13)
				return false;

			if (view.inputTF.text != "")
			{
				// 时间间隔限制
				if (oldTimestamp)
				{
					newTimestamp=new Date().getTime();
					if (newTimestamp - oldTimestamp < 2000)
					{
						// 时间不到
						// trace("您发送消息的时间过快！");
						XTip.showTip(GameLanguage.getLangByKey("L_A_20943"));
						return false;
					}
					else
					{
						oldTimestamp=null;
					}
				}
				else
				{
					oldTimestamp=new Date().getTime();
				}

				// 过滤敏感词汇
				var showStr:String=view.inputTF.text;
				// 发送的是哪个面板的消息
				switch (view.tabCtrl.selectedIndex)
				{
					case 0:
						// 发送世界消息
						WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SEND_WORLD_MSG, [showStr]);
						break;
					case 1:
						// 发送公会消息
						WebSocketNetService.instance.sendData(ServiceConst.SEND_GUILD_TALK, [showStr]);
						break;
					case 2:
						// 发送星球消息
						WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SEND_CITY_MSG, [showStr]);
						break;
					default:
						break;
				}
			}

		}

		/**
		 * 根据选项卡初始化聊天面板信息
		 *
		 */
		private function initChatHandler():void
		{
			trace("initChat");
			// 清空消息面板
			while (view.chatContainer.numChildren)
				view.chatContainer.removeChildAt(0);
			
			view.dom_blue_bg.visible = view.tabCtrl.selectedIndex == 1;
			switch (view.tabCtrl.selectedIndex)
			{
				case 0:
					// 初始化世界消息
					var worldChatLength:int=chatInstance.worldChatVo.length;
					var wChatCount:int=0;
					while (wChatCount < worldChatLength)
					{
						view.chatContainer.addChild(chatInstance.worldChatVo[wChatCount]);
						wChatCount++;
					}
					chatInstance.worldChatCount=worldChatLength;
					break;
				case 1:
					// 初始化公会消息
					var guildChatLength:int=chatInstance.armyChatVo.length;
					var gChatCount:int=0;
					while (gChatCount < guildChatLength)
					{
						view.chatContainer.addChild(chatInstance.armyChatVo[gChatCount]);
						gChatCount++;
					}
					chatInstance.armyChatCount=guildChatLength;
					break;
				case 2:
					// 初始化城市消息
					var cityChatLength:int=chatInstance.cityChatVo.length;
					var cChatCount:int=0;
					while (cChatCount < cityChatLength)
					{
						view.chatContainer.addChild(chatInstance.cityChatVo[cChatCount]);
						cChatCount++;
					}
					chatInstance.cityChatCount=cityChatLength;
					break;
				default:
					break;
			}
			view.chatContainer.refresh();
			view.chatContainer.vScrollBar.value=view.chatContainer.vScrollBar.max;
		}

		override public function close():void
		{
			super.close();
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					Tween.to(this, {x: -485}, 200, Ease.linearNone, new Handler(this, close));
					break;
				case view.sendBtn:
					// 发送消息
					sendMsgHandler();
					view.chatContainer.scrollTo(0, view.chatContainer.vScrollBar.max);
					break;
				default:
					break;
			}
		}

		private function get view():ArmyGroupChatViewUI
		{
			return _view as ArmyGroupChatViewUI;
		}
	}
}
