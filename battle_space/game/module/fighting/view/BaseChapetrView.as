/***
 *作者：罗维
 */
package game.module.fighting.view
{
	
	import game.common.ITabPanel;
	import game.global.GameSetting;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class BaseChapetrView extends Box implements ITabPanel
	{
		protected var bgImg:Image = new Image();
		protected var bgBox:Box = new Box();   //缩放层
		
		protected var contentBox:Box = new Box();  //不缩放层
		
		public function BaseChapetrView()
		{
			super();
			_setUpNoticeType(Node.NOTICE_DISPLAY);
			addChild(bgBox);
			bgBox.addChild(bgImg);
			
			addChild(contentBox);
			contentBox.mouseEnabled = contentBox.mouseThrough = true;
		}
		
	
		public function addEvent():void
		{
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			stageSizeChange();
		}
		public function removeEvent():void
		{
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			this.size(Laya.stage.width , Laya.stage.height);
			var scaleNum:Number =  Laya.stage.width / __bgWidth; 
			
			if(GameSetting.IsRelease){
				var sy:Number = Laya.stage.height / __bgHeight;
				scaleNum = Math.max(scaleNum, sy);
			}
			
			bgBox.scaleX = bgBox.scaleY = scaleNum;
			bgBox.y = ( Laya.stage.height - __bgHeight * scaleNum ) / 2;
			
			//针对页游处理
			if(GameSetting.IsRelease){
				bgBox.x = ( Laya.stage.width - __bgWidth * scaleNum ) / 2;
			}
		}
		
		protected function get __bgWidth():Number{
			return 1024;
		}
		
		protected function get __bgHeight():Number{
			return 768;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BaseChapetrView");
			removeEvent();
			bgImg = null;
			bgBox = null;
			contentBox = null;
			
			super.destroy(destroyChild);
		}
	}
	
}