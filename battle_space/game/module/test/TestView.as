package game.module.test
{
	import MornUI.testView.TestViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.List;
	
	public class TestView extends BaseView
	{
		private var m_list:List;

		private var sp:Sprite;
		public function TestView()
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
		}
		public function get view():TestViewUI{
			if(!_view){
				_view = new TestViewUI();
			}
			return _view as TestViewUI;
		}
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			
		}
		override public function createUI():void
		{
			
			super.createUI();
			this.addChild(view);
			this.sp  = new Sprite();
			/*trace("bg:", this._bg);
			trace("bg:", this._bg.graphics);*/
			//this._bg.graphics.alpha(0.5);
			this.sp.graphics.drawRect(0, 0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight,"#ffffff");
			this.sp.alpha = 0.5;
			this.sp.mouseEnabled = true;
			this.addChild(sp);
			sp.on(Event.CLICK,this,onClick);
			sp.alpha = 0.5
			
			sp.mouseThrough = false;
			this.mouseEnabled = true;
//			this.closeOnBlank = true;
//			_view.mouseThrough = true;
//			this.mouseThrough = true;
		}
		
		private function onClick(e:Event=null):void
		{
			trace("箭头点击");
		}
		private function onClose():void{
			super.close();
		}
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
	}
}