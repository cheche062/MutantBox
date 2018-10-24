package game.common
{
	import PathFinding.core.Node;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.ui.Box;
	import laya.ui.Label;

	public class UIHelp
	{
		public function UIHelp()
		{
		}
		
		/**
		 *横向排版
		 *sprite 容器
		 *changeWidth 是否改变整体宽度
		 *args 与左侧元件间隔 ,与左侧元件间隔 ,与左侧元件间隔 ...
		 */
		public static function crossLayout(sprite:Sprite,changeWidth:Boolean = true ,... args):void{
			var cNum:Number = sprite.numChildren;
			var maxW:Number = 0;
			for (var i:int = 0; i < cNum; i++) 
			{
				var cs:Sprite = sprite.getChildAt(i) as Sprite;
				if(!cs.visible)  continue;
				var left:Number = args && args.length > i  ? args[i] : 0;
				
				cs.x = maxW + left;
				
				var csW:Number = 0;
				var sX:Number = cs.scaleX;
				if(cs is Label){
					csW = (cs as Label).textField.textWidth;
				}else if(cs is Text){
					csW = (cs as Text).textWidth;
				}else
				{
					csW = cs.width;
				}
				maxW += (csW * sX + left);
			}
			
			if(changeWidth) sprite.width = maxW;
			
		}
	}
}