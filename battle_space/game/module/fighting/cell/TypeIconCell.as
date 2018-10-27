package game.module.fighting.cell
{
	import game.module.camp.ProTipUtil;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class TypeIconCell extends Box
	{
		public var img:Image;
		
		public function TypeIconCell()
		{
			super();
			img = new Image();
			addChild(img);
			img.mouseEnabled = img.mouseThrough = true;
			img.on(Event.CLICK,this,imgClick);
			this.size(34,36);
		}
		
		private function imgClick():void
		{
			if(_dataSource)
			{
				var s:String = _dataSource;
				var ar:Array = s.split(":");
				ProTipUtil.showAoDtip(Number(ar[0]),Number(ar[1]));
			}
			
		}
		 
		public override function set dataSource(value:*):void{
			super.dataSource = value;
			if(value)
			{
				 var s:String = value;
				 var ar:Array = s.split(":");
				 var t:String = ar[0] == "1" ? "a":"b";
				 var skinUrl:String = "common/icons/"+t+"_"+ar[1]+".png";
				 img.skin = skinUrl;
				 trace(skinUrl);
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy TypeIconCell");
			img.off(Event.CLICK,this,imgClick);
			img = null;
			
			super.destroy(destroyChild);
		}
	}
}