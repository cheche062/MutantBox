package game.common
{
	import laya.events.Event;
	import laya.ui.List;
	
	/**
	 * list加强版 
	 * @author mutantbox
	 * 
	 */
	public class ListSmart extends List
	{
		public function ListSmart()
		{
			super();
		}
		
		public function init():void {
			this.on(Event.CLICK, this, clickHandler);
		}
		
		/**点击事件*/
		private function clickHandler():void {
			
		}
	}
}