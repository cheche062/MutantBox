package game.module.invasion
{
	import game.global.vo.User;
	import MornUI.invasion.InvasionSearchUI;
	
	import game.common.SceneManager;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.alert.XAlert;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * InvasionView
	 * author:huhaiming
	 * InvasionView.as 2017-4-24 上午10:31:58
	 * version 1.0
	 *
	 */
	public class InvasionView extends BaseDialog
	{
		private var _aniIndex:int=0;
		public function InvasionView()
		{
			super();
		}
		
		//搜索
		public function search():void {
			
			//trace("时候引导中:", User.getInstance().isInGuilding);
			if(User.getInstance().isInGuilding)
			{
				//trace("111111111111111111111");
				WebSocketNetService.instance.sendData(ServiceConst.IN_SEARCH, [1]);
			}
			else
			{
				WebSocketNetService.instance.sendData(ServiceConst.IN_SEARCH, null);
			}
		}
		
		override public function show(...args):void{
			super.show();
			if(args[0]){
				if(args[0][1]){
					SceneManager.intance.setCurrentScene(SceneType.S_INVASION, false,1, args[0][1]);
					return;
				}else{
					//只作为加载使用
				}
			}else{
				search();
				doSearch();
			}
			showAni();
			autoClose();
		}
		
		private function doSearch():void{
			Laya.timer.loop(15000,this, search);
		}
		
		private function autoClose():void{
			Laya.timer.once(120000,this, this.onAutoClose);
		}
		
		override public function close():void{
			Laya.timer.clear(this, this.onShowAni);
			Laya.timer.clear(this, search);
			Laya.timer.clear(this, this.onAutoClose);
			super.close();
		}
		
		private function onAutoClose():void{
			Laya.timer.clear(this, this.onAutoClose);
			Laya.timer.clear(this, search);
			XAlert.showAlert(GameLanguage.getLangByKey("L_A_49010"),Handler.create(this, this.redo),Handler.create(this, this.close));
		}
		
		private function redo():void{
			doSearch();
			Laya.timer.once(120000,this, this.onAutoClose);
		}
		
		private function onClick(e:Event):void{
			if(e.target == view.cancelBtn){
				this.close();
			}
		}
		
		private function onResult(cmd:String, ...args):void{
			trace("Invasion onResult====>", args);
			switch(cmd){
				case ServiceConst.IN_SEARCH:
					if(args[1] == false){
						
					}else{
						this.close();
						SceneManager.intance.setCurrentScene(SceneType.S_INVASION, false,1, args[1])
					}
					break;
			}
		}
		
		//错误处理
		private function onErr(...args):void{
			trace("onErr==============================",args);
			var cmd:Number = args[1];
			var errStr:String = args[2]
			switch(cmd){
				case ServiceConst.IN_SEARCH:
					this.close();
					break;
			}
		}
		
		
		
		
		private function showAni():void{
			_aniIndex = 0;
			Laya.timer.loop(100,this, onShowAni);
		}
		private function onShowAni():void{
			view.tipTF.text=GameLanguage.getLangByKey("L_A_49008");
			var n:Number = _aniIndex%5;
			for(var i:int=0; i<n; i++){
				view.tipTF.text += "."
			}
			_aniIndex ++;
		}
		
		
		
		override public function createUI():void{
			this._view = new InvasionSearchUI();
			this.addChild(_view);
		}
		
		override public function dispose():void{
			
		}
		
		override public function addEvent():void{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_SEARCH), this, this.onResult, [ServiceConst.IN_SEARCH]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onErr);
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_SEARCH), this, this.onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onErr);
			view.off(Event.CLICK, this, this.onClick);
		}
		
		private function get view():InvasionSearchUI{
			return this._view as InvasionSearchUI;
		}
	}
}