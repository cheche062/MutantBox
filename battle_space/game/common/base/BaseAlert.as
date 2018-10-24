package game.common.base
{
	
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Dialog;
	import laya.ui.View;

	public class BaseAlert extends Dialog
	{
		/**
		 * 主显示view 
		 */
		protected var _view:View;
		/**  * UI名称  */		
		public var m_strName:String;
		
		//蒙板
		protected var _bg:Box;
		//蒙板颜色
		protected var _bgColor:String = "#000000";
		//蒙板透明都
		protected var _bgAlpha:Number = 0.3;
		
		/**
		 * 是否能点击背景层 来 关闭窗口
		 */
		public var canClickMask:Boolean = true;
		public function BaseAlert()
		{
			
			super();
			addChildAt(bg,0);
			this.bg.alpha = this._bgAlpha;
		}
		
		/**取得蒙板对象*/
		public function get bg():Box{
			if(!this._bg){
				this._bg  = new Box();
				this._bg.mouseEnabled = true;
			}
			return this._bg;
		}
		
		
		/**
		 * @private (protected)
		 * 对象的 <code>Event.CLICK</code> 点击事件侦听处理函数。
		 */
		protected function _onClick(e:Event):void {
			var btn:Button = e.target as Button;
			if (btn) {
				switch (btn.name) {
					case CLOSE: 
					case CANCEL: 
					case SURE: 
					case NO: 
					case OK: 
					case YES: 
						destroy();
						break;
				}
			}
		}
		/**
		 * <p>预初始化。</p>
		 * @internal 子类可在此函数内设置、修改属性默认值
		 * （因为ui还没有加载好，不要在这个方法中处理界面元素之类的操作）
		 */
		override protected function preinitialize():void {
			super.preinitialize();
			init();
		}
		/**
		 * 初始化 （因为ui还没有加载好，不要在这个方法中处理界面元素之类的操作）
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function init():void
		{	
		}
		/**
		 * <p>创建并添加控件子节点。</p>
		 * @internal 子类可在此函数内创建并添加子节点。
		 */
		override protected function createChildren():void {
			super.createChildren();
			createUI();
		}
		/**
		 * <p>创建并添加控件子节点。</p>
		 * @internal 子类可在此函数内创建并添加子节点。
		 * (子类可重写方法，子类不需要调用 super)
		 */
		public function createUI():void {
		}
		/**
		 * <p>控件初始化。</p>
		 * @internal 在此子对象已被创建，可以对子对象进行修改。
		 */
		override protected function initialize():void {
			super.initialize();
			addEvent();
			initData();
		}
		/**
		 * 添加事件要用BaseView 的 addMapEvent方法添加,
		 * 添加事件的对象会在释放游戏的时候自动释放，
		 * 也可手动调用removeAllMapEvent移除UI上所有事件
		 * 所有的事件要 在这个方法内添加，方便统一管理 
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function addEvent():void
		{
			
		}
		/**
		 * 初始化数据 (用于界面加载完成后 对界面元素的操作及数据赋值之类)
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function initData():void
		{
			
		}
		/**
		 *  移除事件
		 * (子类可重写方法，子类不需要调用 super)
		 */		
		public function removeEvent():void
		{
			
		}
		public function disposeDialog():void
		{
			Dialog.manager.close(this);
		}
		
		override public function destroy(destroyChild:Boolean = true):void
		{
			removeEvent();
			if(_view){
				_view.destroy();
				_view = null;
			}
//			disposeDialog();
			super.destroy();
		}
		protected function sendData(cmdId:int, data:Array = null):void{
			if(data == null)
				data = [];
			WebSocketNetService.instance.sendData(cmdId, data);//发消息
		}
	}
}