/***
 *作者：罗维
 */
package game.common
{
	
	import laya.display.Node;
	import laya.maths.Point;
	import laya.ui.Button;
	
	public class ImageButton extends Button
	{
		protected var _childNode:Node;
		
		public function ImageButton(skin:String=null,label:String = "",cNode:Node = null)
		{
			super(skin, label);
			this.childNode = childNode;
		}

		public function get childNode():Node
		{
			return _childNode;
		}

		public function set childNode(value:Node):void
		{
			if(_childNode != value)
			{
				if(_childNode)
					_childNode.removeSelf();
				_childNode = value;
				this.addChild(_childNode);
			}
		}

		public function set childPoint(value:Point):void
		{
			if(childNode && value)
			{
				childNode.x = value.x;
				childNode.y = value.y;
			}
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			_childNode && _childNode.destroy(destroyChild);
			_childNode = null;
		}
		
		
		public static function copyButton(btn:Button,cNode:Node = null):ImageButton{
			var rtBtn:ImageButton = new ImageButton();
			rtBtn.mouseThrough = btn.mouseThrough;
			rtBtn.selected = btn.selected;
			rtBtn.skin = btn.skin;
			rtBtn.label = btn.label;
			rtBtn.labelAlign = btn.labelAlign;
			rtBtn.labelBold = btn.labelBold;
			rtBtn.labelColors = btn.labelColors;
			rtBtn.labelFont = btn.labelFont;
			rtBtn.labelSize = btn.labelSize;
			rtBtn.labelPadding = btn.labelPadding;
			rtBtn.width = btn.width;
			rtBtn.height = btn.height;
			rtBtn.x = btn.x;
			rtBtn.y = btn.y;
//			for(var key:* in btn)
//			{
//				trace("copyP:"+key);
//				rtBtn[key] = btn[key];
//			}
			rtBtn.childNode = cNode;
			return rtBtn;
		}
		
	}
}