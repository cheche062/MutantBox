package game.common
{
	import game.common.base.BaseDialog;
	
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.maths.Rectangle;
	
	public class BufferView extends BaseDialog
	{
		private var _loadingImg:Sprite;
		public function BufferView()
		{
			super();
			this._m_iLayerType = LayerManager.M_TOP;
			this._m_iPositionType = LayerManager.LEFTUP;
			this.bg.alpha = 0.01
		}
		
		//
		override public function show(...args):void{
			loadingImg.visible = true;
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			super.show();
			this.parent.addChildAt(loadingImg, this.parent.getChildIndex(this));
			onStageResize();
		}
		
		override public function onStageResize():void{
			if(Laya.stage.scaleMode != Stage.SCALE_SHOWALL){
				var delScale:Number = LayerManager.fixScale;
				if(delScale > 1){
					_loadingImg.scale(delScale,delScale);
					var rect:Rectangle = _loadingImg.getBounds();
					_loadingImg.pos(-(rect.width-Laya.stage.width)/2,-(rect.height-Laya.stage.height)/2);
				}
			}
		}
		
		private function get loadingImg():Sprite{
			if(!_loadingImg){
				_loadingImg = new Sprite();
				_loadingImg.loadImage(ResourceManager.instance.setResURL("scene/preload.jpg"));
			}
			return _loadingImg;
		}
		
		override public function close():void{
			loadingImg.removeSelf();
			super.close();
		}
		
		private static var _instance:BufferView;
		public static function get instance():BufferView{
			if(!_instance){
				_instance=new BufferView();
			}
			return _instance;
		}
	}
}