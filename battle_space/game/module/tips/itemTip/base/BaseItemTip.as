package game.module.tips.itemTip.base
{
	import game.module.tips.itemTip.ItemTipManager;
	
	import laya.display.Sprite;
	import laya.utils.ClassUtils;
	import laya.utils.Pool;
	
	public class BaseItemTip extends Sprite
	{
		protected var tipChilds:Array = [];
		protected var poolChilds:Array = [];
		
		public function BaseItemTip()
		{
			super();
		}
		
		private var _data:String; 
		
		public function get data():String
		{
			return _data;
		}
		
		public function set data(value:String):void
		{
			if(_data != value)
			{
				_data = value;
				reset();
				bindData();
			}
		}
		
		public function bindData():void{}
		
		
		
		public function reset():void
		{
			for each (var i:BaseItemTip in tipChilds) 
			{
				i.removeSelf();
				addPoll(i);
			}
			tipChilds.splice(0,tipChilds.length);
//			Pool.recover(ItemTipManager.ItemTips_SIGNKEY,this);
		}
		
		protected function getPollByClass(cls:Class):*
		{
			for (var i:int = 0; i < poolChilds.length; i++) 
			{
				var c:* = poolChilds[i];
				if(c is cls)
				{
					poolChilds.splice(i,1);
					return c;
				}
			}
			
			var vClassFun:* = ClassUtils.getClass(cls);
			return new vClassFun();
			
		}
		
		protected function addPoll(c:*):void
		{
			poolChilds.push(c);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BaseItemTip");
			tipChilds = null;
			poolChilds = null;
			super.destroy(destroyChild);
		}
		
	}
}