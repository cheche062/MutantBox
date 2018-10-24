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
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.acitivity.CostActOneUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CostActOne extends BaseView 
	{
		private var _currentCharge:int = 0;
		private var _actConfig:Array = [];
		private var _actProcess:Array = [];
		private var _curSelect:int = 0;
		
		private var _itemContainerVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var sx:Array = [0, 273, 227, 181, 135];
		private var reSx:Array = [0, 323, 277, 231, 185];
		
		public function CostActOne() 
		{
			super();
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
		}
		private function onClick(e:Event):void
		{
			var index:int = 0;
			if (e.target.name.split("_").length > 1)
			{
				index = e.target.name.split("_")[1];
				var len:int = _itemContainerVec.length;
				for (var j:int = 0; j < len; j++) 
				{
					_itemContainerVec[j].visible = false;
				}
				_curSelect = index;
				refreshState(index);
				
			}
			
			switch(e.target)
			{
				case view.getBtn:
					if (view.getBtn.label == GameLanguage.getLangByKey("L_A_56021"))
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.COST_ACT_REWARD, [ActivityMainView.CURRENT_ACT_ID,_actConfig[_curSelect].id]);
					}
					break;
				default:
					break;
			}
			
		}
		
		private function refreshState(index:int):void
		{
			refreshReward(_actConfig[index].reward.split(";"));
			view.getBtn.disabled = false;
			if (_actConfig[index].amount.split("=")[1] - _currentCharge > 0)
			{
				view.numTF.text = _actConfig[index].amount.split("=")[1] - _currentCharge;
				view.getBtn.label = GameLanguage.getLangByKey("L_A_56018");//立刻充值
				view.getBtn.disabled = true;
			}
			else
			{
				view.numTF.text = 0;
				view.getBtn.label = GameLanguage.getLangByKey("L_A_56018");//领取
			}
			
			if (_actProcess[index] && _actProcess[index].used_times == 1)
			{
				view.getBtn.label = GameLanguage.getLangByKey("L_A_32005");//已领
				view.getBtn.disabled = true;
			}
		}
		
		private function refreshReward(list:Array):void
		{
			//trace("list:", list);
			var len:int = list.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (!_itemContainerVec[i])
				{
					_itemContainerVec[i] = new ItemContainer();
					_itemContainerVec[i].y = 230;
					view.addChild(_itemContainerVec[i]);
				}
				
				_itemContainerVec[i].x = reSx[len]+30 + 100 * i;
				_itemContainerVec[i].setData(list[i].split("=")[0], list[i].split("=")[1]);
				_itemContainerVec[i].visible = true;
			}
			
			
		}
		
		
		private function displayReward(index:int):void
		{
			var list:Array = _actConfig[index].reward.split(";")
			var len:int = list.length;
			var ar:Array = [];
			for (var i:int = 0; i < len; i++) 
			{
				var itemD:ItemData = new ItemData();
				itemD.iid = list[i].split("=")[0];
				itemD.inum = list[i].split("=")[1];
				ar.push(itemD);
			}
			XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("cost:", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.COST_ACT_INIT:
					
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
					
					if (args[1].amount == "")
					{
						_currentCharge = 0;
					}
					else
					{
						_currentCharge = parseInt(args[1].amount);
					}
					view.nowCharge.text = _currentCharge;
					
					_actConfig = [];
					for each(var dd in args[1].config) 
					{
						_actConfig.push(dd);
					}
					
					_actProcess = [];
					for each(var pp in args[1].process) 
					{
						_actProcess.push(pp);
					}
					
					len = _actConfig.length;
					for (i = 0; i < len; i++) 
					{
						view["charge_" + i].visible = true;
						//view["charge_" + i].x = sx[len] + i * 91;
						
						view["price_" + i].text = _actConfig[i].amount.split("=")[1];
					}
					refreshState(_curSelect);
					break;
				case ServiceConst.COST_ACT_REWARD:
					WebSocketNetService.instance.sendData(ServiceConst.COST_ACT_INIT, ActivityMainView.CURRENT_ACT_ID);
					displayReward(_curSelect);
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
			WebSocketNetService.instance.sendData(ServiceConst.COST_ACT_INIT, ActivityMainView.CURRENT_ACT_ID);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.COST_ACT_INIT), this, serviceResultHandler, [ServiceConst.COST_ACT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.COST_ACT_REWARD), this, serviceResultHandler, [ServiceConst.COST_ACT_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			var len:int = _itemContainerVec.length;
			for (var j:int = 0; j < len; j++) 
			{
				_itemContainerVec[j].visible = false;
			}
			for (var i:int = 0; i < 4; i++ )
			{
				view["charge_" + i].visible = false;
			}
			_curSelect = 0;
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.COST_ACT_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.COST_ACT_REWARD), this, serviceResultHandler);
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
			this._view = new CostActOneUI();
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
		
		private function get view():CostActOneUI{
			return _view;
		}
		
	}

}