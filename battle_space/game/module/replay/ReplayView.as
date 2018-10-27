package game.module.replay
{
	import MornUI.replay.ReplayViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	/**
	 * ReplayView
	 * author:huhaiming
	 * ReplayView.as 2017-5-3 下午5:02:07
	 * version 1.0
	 *
	 */
	public class ReplayView extends BaseDialog
	{
		
		private var _selectedBtn:Button;
		private var _selectedItem:*;
		private var _selectedIdx:int;
		private var _dataSrc:Object;
		private var _items:Array = [];
		private var _curData:Array;
		
		public static const T_DEFEND:int = 2;
		public static const T_ATTACK:int = 1;
		public function ReplayView()
		{
			super();
			this._m_iLayerType = LayerManager.M_POP;
			this.bg.alpha = 0.01;
		}
		
		private function onResult(cmd:int, ...args):void{
			switch(cmd){
				case ServiceConst.getEventLog:
					if(!_dataSrc){
						_dataSrc = {};
					}
					_dataSrc[_selectedIdx] = args[1];
					
					format(args[1], _selectedIdx);
					break;
				case ServiceConst.freshFightReport:
					if(_dataSrc){
						delete _dataSrc[ReplayView.T_ATTACK];
						delete _dataSrc[ReplayView.T_DEFEND];
					}
					break;
//				case ServiceConst.getFightReport:
//					this.close();
//					DataLoading.instance.close();
//					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT,false,1,{type:"report",data:args[1]});
//					break;
				case ServiceConst.IN_REVENGE:
					DataLoading.instance.close();
					XFacade.instance.openModule("InvasionView",[false,args[1]]);
					//SceneManager.intance.setCurrentScene(SceneType.S_INVASION, false,1, args[1])
					this.close();
					break;
			}
		}
		
		private function onErr(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			switch(cmd){
				case ServiceConst.getEventLog:
					XTip.showTip(GameLanguage.getLangByKey(errStr));
					this.close();
					break;
				case ServiceConst.IN_REVENGE:
				case ServiceConst.getFightReport:
					XTip.showTip(GameLanguage.getLangByKey(errStr));
					break;
			}
		}
		
		private function onClick(e:Event):void{
			var b:Boolean = false
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				case view.typeBtn_0:
					if(_selectedBtn != view.typeBtn_0){
						b = true
					}
					selectedBtn = view.typeBtn_0
					b && onChange()
					break;
				case view.typeBtn_1:
					if(_selectedBtn != view.typeBtn_1){
						b = true
					}
					selectedBtn = view.typeBtn_1;
					b && onChange()
					break;
				default:
					var item:*;
					if(e.target is ReplayItem || e.target is ReplayItemDefend){
						item = e.target as ReplayItem;
						if(this._selectedItem != item){
							if(this._selectedItem){
								this._selectedItem.selected = false;
							}
							this._selectedItem = item;
							this._selectedItem.selected = true;
						}else{
							this._selectedItem.selected = !this._selectedItem.selected;
						}
						reset();
					}
					break;
			}
		}
		
		private function format(data:Array, index:int=1):void{
			ReplayItemDefend.curModel = index;
			_curData = data;
			clear();
			var item:*;
			var delY:Number = 0;
			for(var i:int=0; i<data.length; i++){
				/*if(_selectedIdx == ReplayView.T_ATTACK){
					item = new ReplayItem();
				}else{
					item = new ReplayItemDefend();
				}*/
				item = new ReplayItemDefend();
				if(i == 0){
					item.selected = true;
					_selectedItem = item;
				}
				item.getFightReportFun = this.getFightReportFun;
				item.dataSource = data[i];
				_items.push(item);
				view.pan.addChild(item);
				item.y = delY;
				delY += item.height;
			}
		}
		
		protected function getFightReportFun(d:*):void
		{
			var opH:Handler = Handler.create(this,this.close);
//			var overH:Handler = Handler.create(this,function():void{
//				alert("打完收工");
//			});
//			var errH:Handler = Handler.create(this,function(e:*):void{
//				XTip.showTip(e);
//			});
			
			FightingManager.intance.getFightReport(d,opH);
		}
		
		private function reset():void{
			var item:*;
			var delY:Number = 0; 
			for(var i:int=0; i<_items.length; i++){
				item = _items[i];
				item.y = delY;
				delY += item.height;
			}
			//强制刷新panel
			item.removeSelf();
			view.pan.addChild(item);
		}
		
		private function clear():void{
			for(var i:int=0; i<_items.length; i++){
				_items[i].removeSelf();
				_items[i].selected = false;
			}
			_items.length = 0;
		}
		
		
		private function onChange():void{
			_selectedIdx = ReplayView.T_DEFEND;
			if(_selectedBtn == view.typeBtn_1){
				_selectedIdx = ReplayView.T_ATTACK;
			}
			if(!_dataSrc || !_dataSrc[_selectedIdx]){
				WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[_selectedIdx,"baserob"]);
			}else{//使用缓存数据
				format(_dataSrc[_selectedIdx],_selectedIdx);
			}
		}
		
		override public function show(...args):void{
			super.show();
			onStageResize();
			AnimationUtil.flowIn(this);
			if(args && args[0] == ReplayView.T_DEFEND){
				selectedBtn = view.typeBtn_0;
			}
			onChange();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		private function onClose():void{
			_dataSrc = null;
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ReplayViewUI();
			this.addChild(_view);
			view.pan.vScrollBarSkin = "";
			selectedBtn = view.typeBtn_1;
			this.closeOnBlank = true;
		}
		
		private function set selectedBtn(btn:Button):void{
			if(_selectedBtn){
				_selectedBtn.selected = false;
			}
			_selectedBtn = btn;
			if(_selectedBtn){
				_selectedBtn.selected = true;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.getEventLog),this,onResult,[ServiceConst.getEventLog]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.freshFightReport),this,onResult,[ServiceConst.freshFightReport]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.getFightReport),this,onResult,[ServiceConst.getFightReport]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_REVENGE),this,onResult,[ServiceConst.IN_REVENGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.getEventLog),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.freshFightReport),this,onResult);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.getFightReport),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_REVENGE),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
		}
		
		private function get view():ReplayViewUI{
			return this._view as ReplayViewUI;
		}
	}
}