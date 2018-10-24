package game.module.activity 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.module.activity.ActivityMainView;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.acitivity.GiftPackViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GiftPackOneView extends BaseView 
	{
		private var _currentCharge:int = 0;
		private var _actConfig:Array = [];
		private var _packIndex:int = 0;
		
		private var _itemContainerVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var reSx:Array = [0, 460, 430, 400, 370, 340, 310];
		
		private var rewardList:Array = [];
		private var _actProcess:Array = [];
		private var maxIndex:int = 1;
		
		
		private var hasBuyList:Array = [];
		
		public function GiftPackOneView() 
		{
			super();
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			_packIndex = 0;
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.prevBtn:
					_packIndex--;
					if (_packIndex < 0)
					{
						_packIndex = 0;
					}
					refreshReward();
					break;
				case view.nextBtn:
					_packIndex++;
					if (_packIndex >= maxIndex)
					{
						_packIndex = maxIndex-1;
					}
					refreshReward();
					break;
				case view.buyBtn:
					WebSocketNetService.instance.sendData(ServiceConst.GIFT_PACK_ONE_BUY, [ActivityMainView.CURRENT_ACT_ID,rewardList[_packIndex].id]);
					break;
				default:
					break;
			}
			
		}
		
		private function checkHasBuy(condition:String):Boolean
		{
			var len:int = hasBuyList.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (hasBuyList[i] == condition)
				{
					return true;
				}
			}
			
			return false;
			
		}
		
		private function refreshReward():void
		{
			var list:Array = rewardList[_packIndex].item.split(";")
			var len:int = list.length;
			
			len = Math.max(list.length, _itemContainerVec.length);
			
			for (var i:int = 0; i < len; i++) 
			{
				if (!_itemContainerVec[i])
				{
					_itemContainerVec[i] = new ItemContainer();
					_itemContainerVec[i].y = 235;
					//_itemContainerVec[i].scaleX = _itemContainerVec[i].scaleY = 0.8;
					view.addChild(_itemContainerVec[i]);
				}
				
				_itemContainerVec[i].x = reSx[list.length] + 90 * i;
				
				if (list[i])
				{
					_itemContainerVec[i].setData(list[i].split("=")[0], list[i].split("=")[1]);
					_itemContainerVec[i].visible = true;
				}
				else
				{
					_itemContainerVec[i].visible = false;
				}
				
				
			}
			
			view.oldPrice.text = rewardList[_packIndex].price.split("=")[1];
			view.nowPrice.text = rewardList[_packIndex].discount_price.split("=")[1];
			
			if(_actProcess[_packIndex] &&_actProcess[_packIndex] == 1)
			{
				view.buyBtn.disabled = true;
				view.buyBtn.label = GameLanguage.getLangByKey("L_A_56022");//已购买
			}
			else
			{
				view.buyBtn.disabled = false;
				view.buyBtn.label = GameLanguage.getLangByKey("L_A_56016");//购买
			}
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("礼包一：", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GIFT_PACK_ONE_INIT:
					if (parseInt(args[1].basic.is_new))
					{
						var tstr:String = GameLanguage.getLangByKey("L_A_56096");
						tstr = tstr.replace("{0}", args[1].basic.start_date);
						tstr = tstr.replace("{1}", args[1].basic.end_date);
						view.timeTF.text = tstr;
					}
					else
					{
						view.timeTF.text = args[1].basic.start_date+"——" + args[1].basic.end_date;
					}
					
					
					rewardList = [];
					
					for each(var dd in args[1].config) 
					{
						rewardList.push(dd);
					}
					maxIndex = rewardList.length;
					
					_actProcess = [];
					for each(var pp in args[1].process) 
					{
						_actProcess.push(pp);
					}
					
					hasBuyList = args[1].process
					//trace("hasBuyList:", hasBuyList);
					
					refreshReward();
					break;
				case ServiceConst.GIFT_PACK_ONE_BUY:
					var list:Array = args[1].item;// rewardList[_packIndex].reward.split(";")
					len = list.length;
					var ar:Array = [];
					for (i = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					
					WebSocketNetService.instance.sendData(ServiceConst.GIFT_PACK_ONE_INIT, ActivityMainView.CURRENT_ACT_ID);
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
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.GIFT_PACK_ONE_INIT, ActivityMainView.CURRENT_ACT_ID);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GIFT_PACK_ONE_INIT), this, serviceResultHandler, [ServiceConst.GIFT_PACK_ONE_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GIFT_PACK_ONE_BUY), this, serviceResultHandler, [ServiceConst.GIFT_PACK_ONE_BUY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GIFT_PACK_ONE_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GIFT_PACK_ONE_BUY), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function show(...args):void{
			super.show();
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GiftPackViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		private function get view():GiftPackViewUI{
			return _view;
		}
		
	}

}