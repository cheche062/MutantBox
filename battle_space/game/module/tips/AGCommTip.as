package game.module.tips 
{
	import game.common.base.BaseView;
	import game.common.LayerManager;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import MornUI.tips.AGCommTipUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AGCommTip extends BaseView 
	{
		
		public function AGCommTip() 
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
			this._view = new AGCommTipUI();
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
		
		private function get view():AGCommTipUI{
			return this._view as AGCommTipUI;
		}
		
	}

}