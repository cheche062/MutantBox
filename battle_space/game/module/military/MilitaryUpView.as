package game.module.military
{
	import MornUI.military.MilitaryUpViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.data.DBMilitary;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	
	/**
	 * MilitaryUpView
	 * author:huhaiming
	 * MilitaryUpView.as 2017-6-1 下午4:15:44
	 * version 1.0
	 *
	 */
	public class MilitaryUpView extends BaseDialog
	{
		private var _ani:Animation;
		public function MilitaryUpView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			var curVo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
			view.icon.skin = "appRes\\icon\\military\\"+curVo.icon+".png"
			if(args[0] > 0){
				_ani = new Animation();
				_ani.loadAtlas("appRes\\atlas\\military\\up.json");
				view.winTF.visible = true;
				view.loseTF.visible = false;
				view.bgBox.gray = false;
				this.view.aniBox2.addChild(_ani);
			}else{
				_ani = new Animation();
				_ani.loadAtlas("appRes\\atlas\\military\\down.json");
				view.winTF.visible = false;
				view.loseTF.visible = true;
				view.bgBox.gray = true;
				this.view.aniBox.addChild(_ani);
			}
			_ani.on(Event.COMPLETE, this, this.onComplete);
			_ani.play(1,false);
			AnimationUtil.flowIn(this);			
		}
		
		private function onComplete():void{
			_ani.removeSelf()
			_ani.off(Event.COMPLETE, this, this.onComplete);
		}
		
		override public function close():void{
			_ani.removeSelf();
			_ani.off(Event.COMPLETE, this, this.onComplete);
			_ani.destroy();
			_ani = null;
			AnimationUtil.flowOut(this, this.onClose);	
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.confirmBtn:
					this.close();
					break;
			}
		}
		
		override public function createUI():void{
			this._view = new MilitaryUpViewUI();
			this.addChild(_view);
			this.closeOnBlank = true;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		private function get view():MilitaryUpViewUI{
			return this._view as MilitaryUpViewUI
		}
	}
}