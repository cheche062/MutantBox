package game.module.tips.itemTip
{
	import game.global.GameConfigManager;
	import game.module.tips.itemTip.base.BaseItemTip;
	
	import laya.utils.ClassUtils;
	import laya.utils.Pool;
	
	public class ItemTipComponent extends BaseItemTip
	{	
		public function ItemTipComponent()
		{
			super();
		}
		
		
		public override function bindData():void{
			var ar:Array = JSON.parse(data) as Array;
			var H:Number = 0;
			var W:Number = 600;
			var l_w:Number=600;
			var l_y:Number=50;
			for (var i:int = 0; i < ar.length; i++) 
			{
				var obj:Object = ar[i];
				var cls:Class = ClassUtils.getRegClass(obj.cls);
				var tip:BaseItemTip = getPollByClass(cls);
				tip.data = JSON.stringify(obj.data);
				tipChilds.push(tip);
				addChild(tip);
				H = Math.max(H,tip.height);
				if(l_w)
				{
					l_w -= 295;  //单个小TIP间隔
				}
				
				l_y=50+460-tip.height;
				tip.pos(l_w,l_y)
				W += tip.width;
			}
			this.mouseThrough=true;
			this.size(W,H+150);
			
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy ItemTipComponent");
			ItemTipManager.itemTipCom = null;
			super.destroy(destroyChild);
		}
	}
}