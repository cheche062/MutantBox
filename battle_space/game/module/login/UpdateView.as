package game.module.login
{
	import MornUI.login.UpdateViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.base.BaseDialog;
	
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	/**
	 * UpdateView
	 * author:huhaiming
	 * UpdateView.as 2017-12-13 下午3:33:23
	 * version 1.0
	 *
	 */
	public class UpdateView extends BaseDialog
	{
		private var _data:Object;
		private var _handle:Handler;
		private var _backGround:Sprite;
		public function UpdateView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			this.parent.addChildAt(_backGround, this.parent.getChildIndex(this));
			var info:Object = (args[0] || {});
			_data = info[0];
			_handle = info[1];
			if(!_data){
				this.close();
				return;
			}
			if(_data["update"]){
				view.btnClose.visible = false;
			}else if(_data["tip"]){
				view.btnClose.visible = true;
			}else{
				this.close();
				return;
			}
			if(view.btnClose.visible){
				view.btnClose.x = 88;
				view.btnUpdate.x = 308;
			}else{
				view.btnUpdate.x = 210
			}
			AnimationUtil.popIn(this.view);
		}
		
		override public function close():void{
			if(_handle){
				_handle.run();
				_handle.recover();
				_handle = null;
			}
			this._data = null;
			this._backGround.removeSelf();
			super.close();
		}
		
		private function onClick(e:Event):void{
			if(e.target == view.btnClose){
				this.close();
			}else if(e.target == view.btnUpdate){
				AndroidPlatform.instance.FGM_OpenURL(_data.url);
			}
		}
		
		override public function onStageResize():void{
			if(Browser.window.loadingView){
				Browser.window.loadingView.loading(100);
			}
			if(Laya.stage.scaleMode != Stage.SCALE_SHOWALL && _backGround){
				var delScale:Number = LayerManager.fixScale;
				if(delScale > 1){
					this._backGround.scale(delScale,delScale);
					var rect:Rectangle = this._backGround.getBounds();
					this._backGround.pos(-(rect.width-Laya.stage.width)/2,-(rect.height-Laya.stage.height)/2);
				}
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			_backGround = new Sprite();
			_backGround.loadImage(ResourceManager.instance.setResURL("scene/preload.jpg"), 0,0,0,0, Handler.create(this,this.onStageResize));
			
			this._view = new UpdateViewUI();
			this.addChild(_view);
		}
		
		private function get view():UpdateViewUI{
			return _view;
		}
	}
}