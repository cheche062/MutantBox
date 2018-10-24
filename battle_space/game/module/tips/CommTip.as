package game.module.tips
{
	import MornUI.tips.CommTipUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	
	import laya.events.Event;
	import laya.maths.Rectangle;
	
	/**
	 * CommTip 普通文本提示内容
	 * author:huhaiming
	 * CommTip.as 2017-3-28 上午10:49:25
	 * version 1.0
	 *
	 */
	public class CommTip extends BaseView
	{
		public function CommTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
		}
		
		override public function show(...args):void{
			super.show();
			var str:String = args[0];
			str = str.replace(/##/g, "\n");
			this.view.msgTF.text = str+"";
			this.view.bg.height = Math.max(80,this.view.msgTF.y+this.view.msgTF.height+20);
		}
		
		/**
		 * 获取本对象在父容器坐标系的矩形显示区域。
		 * <p><b>注意：</b>计算量较大，尽量少用。</p>
		 * @return 矩形区域。
		 */
		override public function getBounds():Rectangle {
			return new Rectangle(0, 0, this.view.bg.width, this.view.bg.height);
		}
		
		override public function createUI():void{
			this._view = new CommTipUI();
			this.addChild(_view);
		}
		
		override public function addEvent():void{
			super.addEvent();
			Laya.stage.on(Event.MOUSE_DOWN, this, close);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			Laya.stage.off(Event.MOUSE_DOWN, this, close);
		}
		
		private function get view():CommTipUI{
			return this._view as CommTipUI;
		}
	}
}