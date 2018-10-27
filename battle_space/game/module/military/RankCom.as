package game.module.military
{
	import MornUI.military.MilitaryRankItemUI;
	import MornUI.military.MilitaryViewUI;
	
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XGroup;
	import game.common.baseScene.SceneType;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.mainScene.guest.GuestHomeView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	import laya.utils.Mouse;

	/**
	 * RankCom
	 * author:huhaiming
	 * RankCom.as 2017-4-28 上午11:26:13
	 * version 1.0
	 *
	 */
	public class RankCom implements IMilitaryCom
	{
		private var _ui:*;
		private var _view:MilitaryViewUI;
		//
		private var _group:XGroup;
		/**类型-本地*/
		public static const T_LOCAL:int = 1;
		/**类型-全球*/
		public static const T_GLOBAL:int = 2
		public function RankCom(ui:*, view:MilitaryViewUI)
		{
			this._ui = ui;
			_view = view;
			_view.localBtn.visible = _view.globalBtn.visible = false;
			init();
		}
		
		private function onResult(cmd:*,...args):void{
			switch(cmd){
				case ServiceConst.IN_getRank:
					var list:Array = args[1];
					for(var i:int=0; i<list.length; i++){
						list[i].order = i+1;
					}
					_view.rankList.array = list;
					break;
			}
		}
		
		private function onSelected(e:Event, index:int):void{
			if(e.type == Event.CLICK){
				var data:Object = _view.rankList.getItem(index);
				var item:MilitaryRankItem = _view.rankList.getCell(index) as MilitaryRankItem;
				if(!item.visitBtn.disabled && item.visitBtn.mouseX > 0 && item.visitBtn.mouseY > 0){
					GuestHomeView.visit(data.base.uid, Handler.create(XFacade.instance, XFacade.instance.closeModule,[MilitaryView]))
				}
			}
		}
		
		public function show(...args):void
		{
			this._ui.visible = true;
			_view.rankList.mouseHandler = new Handler(this, this.onSelected);
			getRank();
			_group.on(Event.CHANGE, this, getRank);
		}
		
		private function getRank():void{
			if(_group.selectedIndex == 0){
				this._view.rankLabel.text = "L_A_49039"
			}else{
				this._view.rankLabel.text = "L_A_49040"
			}
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.IN_getRank), this, this.onResult,[ServiceConst.IN_getRank]);
			WebSocketNetService.instance.sendData(ServiceConst.IN_getRank, [_group.selectedIndex+1]);
		}
		
		public function close():void
		{
			this._ui.visible = false;
			_view.rankList.mouseHandler = null;
			_group.off(Event.CHANGE, this, getRank);
		}
		
		private function init():void{
			_view.rankList.itemRender = MilitaryRankItem;
			_view.rankList.vScrollBarSkin="";
			
			var btns:Array = [_view.localBtn, _view.globalBtn]
			_group = new XGroup(btns);
			_group.selectedIndex = 0;
		}
	}
}