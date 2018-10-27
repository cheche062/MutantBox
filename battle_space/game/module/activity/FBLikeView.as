package game.module.activity 
{
	import MornUI.acitivity.FBLikeViewUI;
	
	import game.App;
	import game.common.AndroidPlatform;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.activity.ActivityListVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FBLikeView extends BaseView 
	{
		private var _currentCharge:int = 0;
		private var _actConfig:Array = [];
		private var _curSelect:int = 0;
		private var _itemContainerVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var actData:ActivityListVo;
		
		public function FBLikeView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.getBtn:
					if (view.getBtn.label == GameLanguage.getLangByKey("L_A_32003"))
					{
						WebSocketNetService.instance.sendData(ServiceConst.HAS_LIKE, [ActivityMainView.CURRENT_ACT_ID,_actConfig[0].condition]);
						if(GameSetting.isApp)
						{
							AndroidPlatform.instance.FGM_OpenWeb(actData.cs1);
							
						}
						else
						{
							if(GameSetting.Platform==GameSetting.P_FB)
							{
								var height:int=(LayerManager.instence.stageHeight)/2;
								var width:int=(LayerManager.instence.stageWidth+376)/2;
								__JS__("openInnerFrame('https://testplay.movemama.com/index/like?game_id=9',376, 333,height,width)");
							}
							else
							{
								__JS__("addFavorite()");
							}
						}	
					}
					else
					{
						
//						SkyExternalUtil.call("openInnerFrame", "https://game.mutantbox.com/index.php?s=Index/like/",  347, 276,(GameSetting.s.stageHeight-276)/2,(App.stage.stageWidth-337)/2);
						
						
						WebSocketNetService.instance.sendData(ServiceConst.COMMON_GET_REWARD, [ActivityMainView.CURRENT_ACT_ID,_actConfig[0].condition]);
					}
					break;
				default:
					break;
			}
			
		}
		
		private function refreshState(index:int):void
		{
			view.getBtn.disabled = false;
			switch(_actConfig[index].status)
			{
				case 0:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_32003");//立刻充值
					break;
				case 1:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_56018");//领取
					break;
				case 2:
					view.getBtn.label = GameLanguage.getLangByKey("L_A_32005");//已领
					view.getBtn.disabled = true;
					break;
				default:
					break;
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
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.COMMON_ACT_INIT:
					_actConfig = args[1].config;
					refreshReward();
					refreshState(0);
					break;
				case ServiceConst.HAS_LIKE:
					WebSocketNetService.instance.sendData(ServiceConst.COMMON_ACT_INIT, ActivityMainView.CURRENT_ACT_ID);
					return;
				case ServiceConst.COMMON_GET_REWARD:
					WebSocketNetService.instance.sendData(ServiceConst.COMMON_ACT_INIT, ActivityMainView.CURRENT_ACT_ID);
					displayReward(0);
					break;
				default:
					break;
			}
		}
		
		private function refreshReward():void
		{
			var list:Array = _actConfig[0].reward.split(";");
			var len:int = list.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (!_itemContainerVec[i])
				{
					_itemContainerVec[i] = new ItemContainer();
					_itemContainerVec[i].x = 240+parseInt(i%3)*90;
					_itemContainerVec[i].y = 200;// +parseInt(i / 3) * 90;
					//_itemContainerVec[i].scaleX = _itemContainerVec[i].scaleY = 0.8;
					view.addChild(_itemContainerVec[i]);
				}
				
				_itemContainerVec[i].setData(list[i].split("=")[0], list[i].split("=")[1]);
				_itemContainerVec[i].visible = true;
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
			WebSocketNetService.instance.sendData(ServiceConst.COMMON_ACT_INIT, ActivityMainView.CURRENT_ACT_ID);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.COMMON_ACT_INIT), this, serviceResultHandler, [ServiceConst.COMMON_ACT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.COMMON_GET_REWARD), this, serviceResultHandler, [ServiceConst.COMMON_GET_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.HAS_LIKE), this, serviceResultHandler, [ServiceConst.HAS_LIKE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			if(GameSetting.isApp)
			{
				view.TitleText.text=GameLanguage.getLangByKey("L_A_57023");
			}
			else
			{
				if(GameSetting.Platform==GameSetting.P_FB)
				{
					view.TitleText.text=GameLanguage.getLangByKey("L_A_57023");
					view.FacebookImage.visible=true;
				}
				else
				{
					view.TitleText.text=GameLanguage.getLangByKey("L_A_57025");
					view.FacebookImage.visible=false;
				}
			}
			view.getBtn.label = GameLanguage.getLangByKey("L_A_32003");
			
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.COMMON_ACT_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.COMMON_GET_REWARD), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.HAS_LIKE), this, serviceResultHandler);
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
			this._view = new FBLikeViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			view.getBtn.label = GameLanguage.getLangByKey("L_A_32003");
			
			actData = GameConfigManager.activiey_list_vec['8'];
			
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
		
		private function get view():FBLikeViewUI{
			return _view;
		}
		
	}

}