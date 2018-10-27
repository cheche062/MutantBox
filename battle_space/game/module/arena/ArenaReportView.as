package game.module.arena 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.arena.ArenaReportViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaReportView extends BaseDialog 
	{	
		private var _reportType:int = 1;
		
		public function ArenaReportView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.attTab:
					view.defTab.selected = false;
					view.attTab.selected = true;
					_reportType = 1;
					getReportData();
					break;
				case view.defTab:
					view.defTab.selected = true;
					view.attTab.selected = false;
					_reportType = 2;
					getReportData();
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		private function getReportData():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.ARENA_REPORT_LIST, [_reportType]);
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("reportService: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.ARENA_REPORT_LIST:
					view.reportList.dataSource = args[1].reports;
					/*switch(_reportType)
					{
						case 1:
							
							break;
						case 2:
							break;
						default:
							break;
					}*/
					
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			
			this.closeOnBlank = true;
			
			AnimationUtil.flowIn(this);
			
			_reportType = 1;
			view.defTab.selected = false;
			view.attTab.selected = true;
			getReportData();
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new ArenaReportViewUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			view.reportList.itemRender = ReportItem;
			view.reportList.vScrollBarSkin = "";
			view.reportList.repeatY = 6;
			
			view.defTab.selected = false;
			view.attTab.selected = true;
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARENA_REPORT_LIST), this, this.serviceResultHandler,[ServiceConst.ARENA_REPORT_LIST]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARENA_REPORT_LIST), this, this,serviceResultHandler);
			
			super.removeEvent();
		}
		
		private function get view():ArenaReportViewUI{
			return _view;
		}
		
	}

}