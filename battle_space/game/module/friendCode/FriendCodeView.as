package game.module.friendCode 
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.base.BaseView;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import MornUI.friendCode.FriendCodeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FriendCodeView extends BaseView 
	{
		
		public static var INVITE_NUM:int = 0;
		public static var FRIEDN_CHARGE:int = 0;
		
		private var hasBinded:Boolean = false;
		
		public function FriendCodeView() 
		{
			super();
			ResourceManager.instance.load(ModuleName.FriendCodeView,Handler.create(this, resLoader));
			
		}
		
		public function resLoader():void
		{
			this._view = new FriendCodeViewUI();
			this.addChild(_view);
			
			view.codeInput.restrict = "a-z,0-9,A-Z";
			view.rewardList.itemRender = FriendCodeItem;
			
			GameConfigManager.intance.initFriendCodeReward();
			
			view.rewardList.array = GameConfigManager.inviteFriendReward;
			
			addEvent();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var id:int = parseInt(e.target.name.split("_")[1]);
			switch(e.target)
			{
				case view.myCodeBtn:
					hideInputArea();
					break;
				case view.shareBtn:
					GlobalRoleDataManger.instance.shareGame(GameConfigManager.ShareInfo[2]);
					break;
				case view.enterCodeBtn:
					hideCodeArea();
					break;
				case view.confirmBtn:
					if (hasBinded)
					{
						return;
					}
					
					if (view.codeInput.text == "" || view.codeInput.length == 0)
					{
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_80735"),AlertType.YES);
						return;
					}
					WebSocketNetService.instance.sendData(ServiceConst.BIND_FRIEND,[view.codeInput.text]);
					break;
				case view.codeInput:
					view.enterTips.visible = false;
					break;
				default:
					break;
			}
		}
		
		private function showCodeArea():void
		{
			if (hasBinded)
			{
				view.enterCodeBtn.visible = false;
				view.shareBtn.x = 188;
			}
			Tween.to(view.codeArea, { scaleY:1 }, 250, Ease.linearNone);
		}
		
		private function hideCodeArea():void
		{
			Tween.to(view.codeArea, { scaleY:0 }, 250, Ease.linearNone, new Handler(this, showInputArea));
		}
		
		private function showInputArea():void
		{
			Tween.to(view.inputArea, { scaleY:1 }, 250, Ease.linearNone);
		}
		
		private function hideInputArea():void
		{
			Tween.to(view.inputArea, { scaleY:0 }, 250, Ease.linearNone, new Handler(this, showCodeArea));
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("friendCode: ", args);
			var len:int = 0;
			var i:int = 0;
			var ar:Array;
			switch(cmd)
			{
				case ServiceConst.GET_INVITE_INFO:
					INVITE_NUM = args[1].invite;
					FRIEDN_CHARGE = args[1].total_coin;
					
					view.enterCodeBtn.visible = true;
					view.shareBtn.x = 287;
					if (args[1].parent_uid)
					{
						view.enterCodeBtn.visible = false;
						view.shareBtn.x = 188;
						hasBinded = true;
					}
					
					var getLog:Object = args[1].get_log;
					for (var index in getLog)
					{
						GameConfigManager.inviteFriendReward[index - 1].getState = 1;
					}
					
					sortList();
					
					
					break;
				case ServiceConst.GET_INVITE_REWARD:
					
					len = args[1].length;
					ar = [];
					for (i = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = args[1][i][0];
						itemD.inum = args[1][i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					WebSocketNetService.instance.sendData(ServiceConst.GET_INVITE_INFO);
					break;
				case ServiceConst.BIND_FRIEND:
					len = args[1].length;
					ar = [];
					for (i = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = args[1][i][0];
						itemD.inum = args[1][i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					hasBinded = true;
					hideInputArea();
					break;
				default:
					break;
			}
		}
		
		private function sortList():void
		{
			var tmp:Array = GameConfigManager.inviteFriendReward.concat();
			var arr:Array = [];
			var i:int = 0;
			var len:int = tmp.length;
			for (i = 0; i < len; i++ )
			{
				var targetNum:int = 0;
				if (tmp[i].mission_type == 1)
				{
					targetNum = FriendCodeView.INVITE_NUM;
				}
				else
				{
					targetNum = FriendCodeView.FRIEDN_CHARGE;
				}
				
				if (tmp[i].getState != 1 && targetNum >= tmp[i].amount)
				{
					arr.push(tmp.splice(i, 1)[0]);
					i--;
					len--;
				}
			}
			
			view.rewardList.array = arr.concat(tmp);
			view.rewardList.refresh();
		}
		
		private function checkInputTxt(e:Event):void
		{
			view.enterTips.visible = false;
			var str:String = StringUtil.removeBlank(view.codeInput.text).toLowerCase();
			
			view.codeInput.text = str;
		}
		
		override public function show(...args):void
		{
			super.show();
			
			
		}
		
		override public function close():void
		{
			
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.GET_INVITE_INFO);
			
			view.codeArea.scaleY = 1;
			view.inputArea.scaleY = 0;
			
			view.enterTips.visible = true;
			view.codeInput.text = "";
			
			view.myCode.text = User.getInstance().inviteCode;
			
			GameConfigManager.ShareInfo[2].content = GameLanguage.getLangByKey(GameConfigManager.ShareInfo[2].content).replace("{0}", User.getInstance().inviteCode);
			
			view.codeInput.on(Event.INPUT, this, checkInputTxt);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_INVITE_INFO), this, serviceResultHandler, [ServiceConst.GET_INVITE_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_INVITE_REWARD), this, serviceResultHandler, [ServiceConst.GET_INVITE_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BIND_FRIEND), this, serviceResultHandler, [ServiceConst.BIND_FRIEND]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			
		}
		
		private function removeFromStageEvent():void
		{
			view.codeInput.off(Event.CHANGE, this, checkInputTxt);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_INVITE_INFO),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_INVITE_REWARD),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BIND_FRIEND),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		
		
		private function get view():FriendCodeViewUI{
			return _view;
		}
		
	}

}