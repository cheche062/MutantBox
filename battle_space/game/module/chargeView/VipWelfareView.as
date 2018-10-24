package game.module.chargeView 
{
	import game.global.GameSetting;
	import MornUI.chargeView.VipWelfareViewUI;
	
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Rectangle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class VipWelfareView extends BaseView 
	{
		
		private var nowVipLv:int = 1;
		private var targetVipLv:int = 1;
		
		private var _itemVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var _rewardState:Array = [];
		
		private var prevX:Number = 0;
		private var prevY:Number = 0;
		
		public function VipWelfareView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.prevBtn:
					nowVipLv--;
					if (nowVipLv < 1)
					{
						nowVipLv = 1;
					}
					refreshWelfare();
					refreshVipInfo()
					break;
				case view.nextBtn:
					nowVipLv++;
					if (nowVipLv > GameConfigManager.vip_info.length-1)
					{
						nowVipLv = GameConfigManager.vip_info.length - 1;
					}
					refreshWelfare();
					refreshVipInfo()
					break;
				case view.receiveBtn:
					WebSocketNetService.instance.sendData(ServiceConst.GET_VIP_WELFARE,[nowVipLv]);
					break;
				default:
					
					break;
				
			}
		}
		
		override public function show(...args):void{
			super.show();
			addToStageEvent();
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.OPEN_VIP_VIEW:
					_rewardState = args[0].userVipInfo.reward_status;
					refreshWelfare();
					break;
				case ServiceConst.GET_VIP_WELFARE:
					_rewardState[nowVipLv] = 2;
					refreshWelfare();
					var ar:Array = [];
					//var list:Array = GameConfigManager.vip_info[nowVipLv].reward_pack.split(";");
					var list:Array = (args[0].reward+"").split(";");
					len = list.length;
					for (i = 0; i < len; i++)
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i].split("=")[0];
						itemD.inum = list[i].split("=")[1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					// 领取奖励后刷新下数据 检查是否消失主界面图片上是否还需要小红点
					WebSocketNetService.instance.sendData(ServiceConst.OPEN_VIP_VIEW);
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function refreshWelfare():void
		{
			view.checkVip.text = "VIP" + nowVipLv;
			view.vipIntro.text = GameLanguage.getLangByKey(GameConfigManager.vip_info[nowVipLv].vip_des).replace(/##/g, "\n");
			view.vipIntro.height = view.vipIntro.textField.textHeight;
			view.pane.addChild(view.vipIntro);
			view.vipIntro.pos(0,0);
			
			var giftInfo:Object = VIPVo.getGiftInfo(nowVipLv);
			
			view.tfOld.text = (giftInfo.old_price+"").split("=")[1];
			view.tfNew.text = (giftInfo.new_price+"").split("=")[1];
			var rewardList:Array = giftInfo.reward_pack.split(";");
			
			//rewardList = ["1=10", "2=10", "3=10", "4=10"];
			
			var len:int = Math.max(rewardList.length, _itemVec.length);
			var i:int = 0;
			
			for (i = 0; i < _itemVec.length; i++ )
			{
				_itemVec[i].visible = false;
			}
			
			for (i = 0; i < len; i++) 
			{
				if (!_itemVec[i])
				{
					_itemVec[i] = new ItemContainer();
					_itemVec[i].scaleX = _itemVec[i].scaleY = 0.8;
					view.rewardArea.addChild(_itemVec[i]);
				}
				
				_itemVec[i].x = 25 + parseInt(i % 2) * 70;
				if(len>2)
				{
					_itemVec[i].y = 10 + 65 * parseInt(i / 2);
				}
				else
				{
					_itemVec[i].y = 30;
				}
				
				if (rewardList[i])
				{
					_itemVec[i].setData(rewardList[i].split("=")[0], rewardList[i].split("=")[1]);
					_itemVec[i].visible = true;
				}
				else
				{
					_itemVec[i].visible = false;
				}
			}
			
			view.receiveBtn.visible = true;
			if (!_rewardState[nowVipLv] || _rewardState[nowVipLv] == 0)
			{
				view.receiveBtn.disabled = true;
			}
			else if (_rewardState[nowVipLv] == 1)
			{
				view.receiveBtn.disabled = false;
			}
			else
			{
				view.receiveBtn.visible = false;
			}
		}
		
		private function refreshVipInfo():void
		{
			view.nowVip.text = "VIP" + User.getInstance().VIP_LV;
			var nl:int = nowVipLv;
			if (User.getInstance().VIP_LV >= nowVipLv)
			{
				nl = User.getInstance().VIP_LV + 1;
			}
			if(User.getInstance().VIP_LV < VIPVo.MAX_LV){
				view.nextInfo.visible = true;
				view.nextVIP.text = "VIP" + nl;
				
				view.vipBar.value = User.getInstance().chargeNum / GameConfigManager.vip_info[nl].amount;
				view.chargeInfoTxt.text = User.getInstance().chargeNum + "/" + GameConfigManager.vip_info[nl].amount;
				
				view.needTxt.text = (GameConfigManager.vip_info[nl].amount - User.getInstance().chargeNum) +","+GameLanguage.getLangByKey("L_A_76014");
				
				view.nextVIP.x = view.needTxt.x + view.needTxt.textWidth;
				
				//view.nextInfo.x = (view.width - view.nextInfo.width) / 2;
			}else{
				view.nextInfo.visible = false;
				view.chargeInfoTxt.text = "";
				view.vipBar.value = 1;
			}
		}
		
		override public function close():void{
			
		}
		
		override public function createUI():void{
			this._view = new VipWelfareViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			view.vipIntro.wordWrap = true;
			view.vipIntro.overflow = Text.SCROLL;
			
			/*if (GameSetting.isApp || GameSetting.Platform != GameSetting.P_GW)
			{
				view.bg.skin = "chargeView/m_bg3_3.png";
			}*/
			
		}
		
		/* 开始滚动文本 */
		private function startScrollText(e:Event):void
		{
			prevX = view.vipIntro.mouseX;
			prevY = view.vipIntro.mouseY;
			Laya.stage.on(Event.MOUSE_MOVE, this, scrollText);
			Laya.stage.on(Event.MOUSE_UP, this, finishScrollText);
		}

		/* 停止滚动文本 */
		private function finishScrollText(e:Event):void
		{
			Laya.stage.off(Event.MOUSE_MOVE, this, scrollText);
			Laya.stage.off(Event.MOUSE_UP, this, finishScrollText);
		}

		/* 鼠标滚动文本 */
		private function scrollText(e:Event):void
		{
			var nowX:Number = view.vipIntro.mouseX;
			var nowY:Number = view.vipIntro.mouseY;

			view.vipIntro.scrollX += prevX - nowX;
			view.vipIntro.scrollY += prevY - nowY;

			prevX = nowX;
			prevY = nowY;
		}
		
		private function addToStageEvent():void 
		{
			nowVipLv = User.getInstance().VIP_LV;
			
			if (nowVipLv == 0)
			{
				nowVipLv = 1;
			}
			
			refreshVipInfo();
			refreshWelfare();
			
			WebSocketNetService.instance.sendData(ServiceConst.OPEN_VIP_VIEW);
		}
		
		override public function addEvent():void{
			
			view.on(Event.CLICK, this, onClick);
			
			view.vipIntro.on(Event.MOUSE_DOWN, this, startScrollText);
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_VIP_WELFARE), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void {
			
			view.off(Event.CLICK, this, onClick);
			view.vipIntro.off(Event.MOUSE_DOWN, this, startScrollText);
			
			Signal.intance.off(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_VIP_WELFARE), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		private function get view():VipWelfareViewUI{
			return _view;
		}
		
	}

}