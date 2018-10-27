package game.common
{
	import game.common.base.BaseDialog;
	
	import laya.ani.swf.MovieClip;
	import laya.events.Event;
	import laya.ui.Image;

	/**
	 * 
	 */	
	public class ModuleLoading extends BaseDialog
	{
		private var _loadingImg:Image;
		
		public function ModuleLoading()
		{
			super();
			this._m_iLayerType = LayerManager.M_TOP;
			this.bg.alpha = 0.01;
			this.name = "ModuleLoading";
		}
		
		//
		override public function show(...args):void{
			showLazyLoading();
			loadingImg.visible = false;
			Laya.timer.once(800,this,showLazyLoading);
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this, this._m_iPositionType);
			super.show();
		}
		
		override public function close():void{
			super.close();
			Laya.timer.clear(this,showLazyLoading);
			Laya.timer.clear(this,this.onLoading);
		}
		
		override public function addEvent():void{
			Laya.stage.on(Event.RESIZE, this, this.onStageResize);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			Laya.stage.off(Event.RESIZE, this, this.onStageResize);
			super.removeEvent();
		}
		
		//显示loading
		private function showLazyLoading():void{
			loadingImg.visible = true;
			Laya.timer.frameLoop(1,this, this.onLoading);
		}
		
		private function onLoading():void{
			_loadingImg.rotation += 6;
		}
		
		private function get loadingImg():Image{
			if(!_loadingImg){
				_loadingImg = new Image("common\/loading.png");
				_loadingImg.pivotX=50;
				_loadingImg.pivotY = 50;
				this.addChild(_loadingImg);
			}
			return _loadingImg;
		}
		
		private static var _instance:ModuleLoading;
		public static function get instance():ModuleLoading{
			if(!_instance){
				_instance=new ModuleLoading();
			}
			return _instance;
		}
	}
}