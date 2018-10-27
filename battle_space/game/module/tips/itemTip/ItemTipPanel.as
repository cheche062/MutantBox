package game.module.tips.itemTip
{
	import game.module.tips.itemTip.base.BaseItemTip;
	import game.module.tips.itemTip.base.BaseItemTipPanel;
	
	import laya.utils.ClassUtils;
	import laya.utils.Pool;
	
	public class ItemTipPanel extends BaseItemTipPanel
	{
		public function ItemTipPanel()
		{
			super();
		}
		
		public override function bindData():void{
			var ar:Array = JSON.parse(data) as Array;
			
			var H:Number = 0;
			var W:Number = 262;
			
			for (var i:int = 0; i < ar.length; i++) 
			{
				var obj:Object = ar[i];
				var cls:Class = ClassUtils.getRegClass(obj.cls);
				var tip:BaseItemTip = getPollByClass(cls);
				tip.data = JSON.stringify(obj.data);
				tipChilds.push(tip);
				addChild(tip);
				tip.pos(0,H);
				H += tip.height;
			}
			H +=50;
			this.size(W,H);
		}
	}
}