package game.common
{
	import laya.display.Sprite;
	import laya.filters.GlowFilter;
	import laya.utils.Handler;
	import laya.utils.TimeLine;
	import laya.utils.Tween;

	public class GameUIUtils
	{
		private static var _instance:GameUIUtils;
		
		private var uilist:Array = [];
		public function GameUIUtils()
		{
		}
		
		

		public static function get intance():GameUIUtils
		{
			if(_instance)
				return _instance;
			_instance = new GameUIUtils;
			return _instance;
		}
		
		
		public function addGlitter(ui:Sprite):void{
			if(uilist.indexOf(ui) == -1)
			{
				uilist.push(ui);
				if(uilist.length == 1)
				{
					showGray(0);
				}
			}
		}
		
		public function delGlitter(ui:Sprite):void{
			var idx:Number = uilist.indexOf(ui);
			if(idx != -1)
			{
				uilist.splice(idx,1);
				if(!uilist.length)
				{
					Tween.clearAll(this);
					trace("移除所有缓动");
				}
//				var filters:Array = ui.filters;
//				if(!filters) filters = [];
//				var idx:Number = filters.indexOf(glowFilter);
//				if(idx != -1)
//				{
//					filters.splice(idx,1);
//				}
//				
//				if(!filters.length)filters = null;
//				ui.filters = filters;
				ui.filters = null;
			}
		}
		
		
		
		public function showGray(w:Number):void{
			var t:Number = w == 0 ? 10 : 0;
			Tween.clearAll(this);
			Tween.to(this,{blur:t},500,null,Handler.create(this,showGray,[t]));
			
//			
//			ui.filters = 
		}
		
		private var _b:Number = 0;
		public function get blur():Number{
			return _b;
		}
		
		public function set blur(b:Number):void{
//			trace("blur",b);
			b = Math.floor(b);
			if(_b == b)
				return ;
			_b = b;
//			var glowFilter:GlowFilter=new GlowFilter(0xffff00,_b,0,0);
			var gf:GlowFilter = glowFilter;
			gf.blur = _b;
			for (var i:int = 0; i < uilist.length; i++) 
			{
				var ui:Sprite = uilist[i];
				if(ui)
				{
					if(!ui.displayedInStage)
					{
						delGlitter(ui);
					}
					else
					{
//						var filters:Array = ui.filters;
//						if(!filters) 
						ui.filters = [gf];
//						else
//						{
//							if(filters.indexOf(glowFilter) == -1)
//							{
//								filters.push(filters);
//							}
//						}
//						ui.filters = filters.slice();
					}
				}
			}
			
		}
		
		
		private var _glowFilter:GlowFilter;
		public function get glowFilter():GlowFilter
		{
//			if(!_glowFilter)_glowFilter = new GlowFilter(0xffff00,_b,0,0);
//			return _glowFilter;
			return  new GlowFilter(0xffff00,_b,0,0);
		}
	}
}