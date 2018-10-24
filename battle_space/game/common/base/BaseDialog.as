package game.common.base
{
	
	import game.common.LayerManager;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Browser;

	public class BaseDialog extends BaseView
	{
		//蒙板
		protected var _bg:Box;
		//蒙板颜色
		protected var _bgColor:String = "#000000";
		//蒙板透明都
		protected var _bgAlpha:Number = 0.3;
		//是否模式窗口状态,默认模式窗口，不可穿透
		protected var _isModel:Boolean = true;
		//是否可以点空白区域关闭，只有在模式窗窗口下有效,
		protected var _closeOnBlank:Boolean = false;
	
		
		
		
		public function BaseDialog()
		{
			super();	
			this._m_iLayerType = LayerManager.M_POP;
			this._m_iPositionType = LayerManager.CENTER;
			this.bg.alpha = this._bgAlpha;
		}
		
		override public function onStageResize():void{
//			trace("浏览器宽度:"+Browser.clientWidth);
//			trace("舞台宽度:"+Laya.stage.width);
			this.bg.size(Math.max(Laya.stage.width,Browser.clientWidth), Math.max(Laya.stage.height,Browser.clientHeight));
			LayerManager.instence.setPosition(this, _m_iPositionType);
		}
		
		/**
		 * 显示
		 * @param align 对齐方式，常量定义在LayerManager
		 */
		override public function show(...args):void{
			super.show();
			if(!this.bg.displayedInStage){
				this.parent.addChildAt(this.bg, this.parent.getChildIndex(this));
				this.bg.size(Laya.stage.width, Laya.stage.height);
				this.bg.graphics.clear();
				this.bg.graphics.drawRect(0,0,Laya.stage.width, Laya.stage.height, _bgColor);
			}
		}
		
		/**关闭*/
		override public function close():void{
			super.close();
			this.bg.removeSelf();
		}
		
		
		/**是否模式窗口状态*/
		public function set isModel(v:Boolean):void{
			this._isModel = v;
			this.bg.visible = this._isModel;
		}
		
		/**是否模式窗口状态*/
		public function get isModel():Boolean{
			return this._isModel;
		}
		
		public function set closeOnBlank(v:Boolean):void{
			this._closeOnBlank = v;
		}
		
		public function get closeOnBlank():Boolean{
			return this._closeOnBlank;
		}
		
		
		/**取得蒙板对象*/
		public function get bg():Box{
			if(!this._bg){
				this._bg  = new Box();
				this._bg.mouseEnabled = true;
			}
			return this._bg;
		}
		
		protected function _onClick():void{
			if(this._closeOnBlank){
				this.close();
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			this.bg.on(Event.CLICK, this, this._onClick);
		}
		
		override public function removeEvent():void{
			super.removeSelf();
			this.bg.off(Event.CLICK, this, this._onClick);
		}
	}
}