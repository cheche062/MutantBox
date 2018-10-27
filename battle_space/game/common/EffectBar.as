/***
 *作者：罗维
 */
package game.common
{
	import game.module.fighting.scene.FightingScene;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.utils.Handler;
	
	public class EffectBar extends Animation
	{
		private var _effectName:String;
		private var _barValue:Number;
		
		public function EffectBar(effectName:String)
		{
			_effectName = effectName;
			super();
		}
		
		public function get barValue():Number
		{
			return _barValue;
		}

		public function set barValue(value:Number):void
		{
			if(_barValue != value)
			{
				_barValue = value;
				bindData();
			}
		}
		
		private function bindData():void
		{
			var jsonStr:String = "appRes/effects/"+_effectName+".json";
			if(Loader.getRes(jsonStr) == null)
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,loaderOver,[jsonStr]),null,null,1,true,FightingScene.figtingModerGroup);
			else
				loaderOver(jsonStr);
		}
		
		private function loaderOver(jsonStr:String):void
		{
			loadAtlas(jsonStr);
			var maxFrame:Number = this.frames.length;
//			trace("frame"+barValue);
			bindValue(maxFrame);
		}
		
		private function bindValue(maxFrame:Number):void
		{
			if(barValue >= maxFrame)
				super.gotoAndStop(maxFrame - 1);
			else
				super.gotoAndStop(barValue);
		}
	}
}