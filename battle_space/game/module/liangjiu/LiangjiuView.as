package game.module.liangjiu
{
	import game.common.UIRegisteredMgr;
	import MornUI.liangjiu.LiangjiuViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.techTree.TechTreeMainView;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 酿酒 
	 * @author hejianbo
	 * 2018-06-25
	 */
	public class LiangjiuView extends BaseDialog
	{
		/**状态管理器*/
		private var state:LiangjiuVo;
		public function LiangjiuView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function createUI():void{
			this.addChild(view);
			state = new LiangjiuVo();
			
			var a = GameLanguage.getLangByKey("L_A_18000");
			var b = GameLanguage.getLangByKey("L_A_18011");
			var c = GameLanguage.getLangByKey("L_A_602");
			view.dom_tab.labels = [a, b, c].join(",").toUpperCase();
			
			var item0:LianshiView = new LianshiView();
			var item1:RonglianView = new RonglianView();
			var item2:TechTreeMainView = new TechTreeMainView();
			
			view.dom_viewStack.setItems([item0, item1, item2]);
			
			UIRegisteredMgr.AddUI(view.dom_tab.getChildAt(1),"ronglianBtn");
			UIRegisteredMgr.AddUI(view.dom_tab.getChildAt(2),"techbtn");
			
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			view.dom_viewStack.items.forEach(function(item) {
				item.show && item.show(state); 
			});
			view.dom_tab.selectedIndex = -1;
			
			sendData(ServiceConst.NIANGJIU_OPEN);
			
			view.visible = false;
			
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					close();
					
					break;
				case view.btn_help:
					var msg:String = GameLanguage.getLangByKey("L_A_18073");
					XTipManager.showTip(msg);
					
					
					break;
			}
		}
		
		private function tabHandler(index:int):void {
			view.dom_viewStack.selectedIndex = index;
			refreshCurrentView();
		}
		
		/**刷新当前页*/
		private function refreshCurrentView():void {
			var child = view.dom_viewStack.selection;
			child && child.update && child.update();
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			var cmd = args[0];
			var result = args[1];
			trace('%c 【酿酒】', 'color: green', cmd, result);
			switch(cmd){
				// 打开
				case ServiceConst.NIANGJIU_OPEN:
					state.init(result);
					
					view.dom_tab.selectedIndex = 0;
					
					view.visible = true;
					break;
				
				// 炼石
				case ServiceConst.NIANGJIU_LIANSHI:
					state.getJingshi(result);
					refreshCurrentView();
					var child = view.dom_viewStack.selection;
					child && child.showFoodText && child.showFoodText();
					
					
					break;
				
				// 合成
				case ServiceConst.NIANGJIU_HECHENG:
					state.hechengUpdate(result);
					refreshCurrentView();
					
//					var text = GameLanguage.getLangByKey("L_A_19004");
//					XTip.showTip(text + result["add_wish"]);
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.dom_tab.selectHandler = Handler.create(this, tabHandler, null, false);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_OPEN), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_LIANSHI), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_HECHENG), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.dom_tab.selectHandler.clear();
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_OPEN), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_LIANSHI), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.NIANGJIU_HECHENG), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
			
			view.dom_viewStack.items.forEach(function(item) {
				item.close && item.close();
			});
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
			var child:LianshiView = view.dom_viewStack.selection;
			child && child.errorHandler && child.errorHandler();
			
			if (cmd == ServiceConst.NIANGJIU_OPEN) {
				onClose();
			}
			
		}
		
		public function get view():LiangjiuViewUI{
			_view = _view || new LiangjiuViewUI();
			return _view;
		}
	}
}