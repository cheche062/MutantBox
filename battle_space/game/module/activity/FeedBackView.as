package game.module.activity 
{
	import game.common.AndroidPlatform;
	import game.common.base.BaseView;
	import game.common.LayerManager;
	import game.common.XTip;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.vo.activity.ActivityListVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Browser;
	import MornUI.acitivity.FeedBackViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FeedBackView extends BaseView 
	{
		private var actData:ActivityListVo;
		
		private var re1:ItemContainer;
		private var re2:ItemContainer;
		
		public function FeedBackView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.feedBtn:
					if(GameSetting.isApp)
					{
						AndroidPlatform.instance.FGM_OpenWeb(actData.cs1);
						
					}
					else
					{
						Browser.window.open(actData.cs1);
						/*if(GameSetting.Platform==GameSetting.P_FB)
						{
							var height:int=(LayerManager.instence.stageHeight)/2;
							var width:int = (LayerManager.instence.stageWidth + 376) / 2;
							var openUrl:String = "openInnerFrame(" + actData.cs1 +")";
							__JS__(openUrl);
							Browser.window.open(actData.cs1);
						}
						else
						{
							__JS__("addFavorite()");
						}*/
					}
					break;
				default:
					break;
			}
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
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
			
		}
		
		private function removeFromStageEvent():void
		{
			
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
			this._view = new FeedBackViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			
			actData = GameConfigManager.activiey_list_vec['11'];
			var reArr:Array = actData.config.split("|")[1].split(";");
			
			re1 = new ItemContainer();
			re1.setData(reArr[0].split("=")[0], reArr[0].split("=")[1]);
			re1.x = 440;
			re1.y = 110;
			view.addChild(re1);
			
			re2 = new ItemContainer();
			re2.setData(reArr[1].split("=")[0], reArr[1].split("=")[1]);
			re2.x = 560;
			re2.y = 110;
			view.addChild(re2);
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
		
		private function get view():FeedBackViewUI{
			return _view;
		}
		
	}

}