/***
 *作者：罗维
 */
package game.common
{
	import PathFinding.core.Node;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Tab;
	
	public class ImageTab extends Tab
	{
		public function ImageTab()
		{
			super();
		}
		
		override protected function createItem(skin:String, label:String):Sprite {
			return new Button(label, "");
		}
		
		public override function set selectedIndex(value:int):void {
			super.selectedIndex = value;
			for (var i:int = 0; i < items.length; i++) 
			{
				if(i != _selectedIndex)
				{
					addChild(items[i] as Node);
				}
			}
			if(_selectedIndex >= 0)
				addChild(items[_selectedIndex] as Node);
			
		}
	}
}