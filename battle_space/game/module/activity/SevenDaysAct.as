package game.module.activity 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.acitivity.SevenDaysActUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SevenDaysAct extends BaseView 
	{	
		private var itemIconVec:Vector.<Image> = new Vector.<Image>();
		private var iconID:Array = [4,2,3,13,11001,11003,11004];
		
		private var btnArr:Array = [];
		
		private var nowDay:int = -1;
		
		public function SevenDaysAct() 
		{
			super();
			init();
			
		}
		
		private function init():void
		{
			view.targetList.itemRender = SevenDaysItem;
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.SEVEN_DAYS_INIT:
					//trace("七日初始化数据:",args);
					if (nowDay == -1)
					{
						nowDay = parseInt(args[1]["dayNum"]);
						for (i = 0; i < 7; i++) 
						{
							if(i<(nowDay))
							{
								itemIconVec[i].gray = false;
								btnArr[i].disabled = false;
							}
							else
							{
								itemIconVec[i].gray = true;
								btnArr[i].disabled = true;
							}
						}
					}
					
					for (i = 0; i < 7; i++) 
					{
						btnArr[i].selected = false;
					}
					btnArr[parseInt(args[1]["dayNum"])-1].selected = true;
					
					var dayInfo:Array = GameConfigManager.intance.getSevenDayInfo(args[1]["dayNum"])
					
					len = dayInfo.length
					for (i = 0; i < len; i++) 
					{
						dayInfo[i].process = parseInt(args[1]["objectiveStatus"][i].process);
						dayInfo[i].status = parseInt(args[1]["objectiveStatus"][i].status);
					}
					//trace("dayInfo:", dayInfo);
					view.targetList.array = dayInfo;
					break;
				case ServiceConst.SEVEN_DAYS_GET:
					var ar:Array = [];
					var list:Array = args[1].reward.split(";");
					len = list.length;
					for (i = 0; i < len; i++)
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i].split("=")[0];
						itemD.inum = list[i].split("=")[1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					
					WebSocketNetService.instance.sendData(ServiceConst.SEVEN_DAYS_INIT);
					//displayReward(_curSelect);
					break;
				default:
					break;
			}
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var id:int = parseInt(e.target.name.split("_")[1]);
			
			switch(e.target)
			{
				case view.btn_0:
				case view.btn_1:
				case view.btn_2:
				case view.btn_3:
				case view.btn_4:
				case view.btn_5:
				case view.btn_6:
					WebSocketNetService.instance.sendData(ServiceConst.SEVEN_DAYS_INIT,[id+1]);
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
			WebSocketNetService.instance.sendData(ServiceConst.SEVEN_DAYS_INIT);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SEVEN_DAYS_INIT), this, serviceResultHandler, [ServiceConst.SEVEN_DAYS_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SEVEN_DAYS_GET), this, serviceResultHandler, [ServiceConst.SEVEN_DAYS_GET]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SEVEN_DAYS_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SEVEN_DAYS_GET), this, serviceResultHandler);
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
			this._view = new SevenDaysActUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			for (var i:int = 0; i < 7; i++) 
			{
				btnArr[i] = view["btn_" + i];
				
				itemIconVec[i] = new Image();
				itemIconVec[i].width = itemIconVec[i].height = 65;
				itemIconVec[i].skin = GameConfigManager.getItemImgPath(iconID[i]);
				itemIconVec[i].x = btnArr[i].x;
				itemIconVec[i].y = btnArr[i].y;
				view.btnArea.addChild(itemIconVec[i]);
				
			}
			
			addEvent();
		}
		
		override public function addEvent():void{
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
		
		private function get view():SevenDaysActUI{
			return _view;
		}
		
	}

}