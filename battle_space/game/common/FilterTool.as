/***
 *作者：罗维
 */
package game.common
{
	import laya.filters.ColorFilter;
	import laya.filters.GlowFilter;

	public class FilterTool
	{
		public function FilterTool()
		{
		}
		
		private static var _grayscaleFilter:ColorFilter;
		//灰色滤镜

		

		public static function get grayscaleFilter():ColorFilter 
		{
			if(!_grayscaleMat)
			{
				var _grayscaleMat:Array = [0.3086, 0.6094, 0.0820, 0, 0, 0.3086, 0.6094, 0.0820, 0, 0, 0.3086, 0.6094, 0.0820, 0, 0, 0, 0, 0, 1, 0];
				_grayscaleFilter = new ColorFilter(_grayscaleMat);
			}
			return _grayscaleFilter;
		}
		
		//红色滤镜
		private static var _redFilter:ColorFilter;
		public static function get redFilter():ColorFilter{
			if(!_redFilter)
			{
				var redMat:Array =
					[
						1, 0, 0, 0, 0, //R
						0, 0, 0, 0, 0, //G
						0, 0, 0, 0, 0, //B
						0, 0, 0, 1, 0, //A
					];
				
				//创建一个颜色滤镜对象,红色
				_redFilter = new ColorFilter(redMat);
			}
			return _redFilter;
		}
		
		//发光滤镜
		private static var _glowFilter:GlowFilter;
		public static function get glowFilter():GlowFilter
		{
			if(!_glowFilter)
				_glowFilter = new GlowFilter("#ffff00", 2, 0, 0);
			return _glowFilter;
		}
		
		//范围更大的发光滤镜
		private static var _glowFilter2:GlowFilter;
		public static function get bigGlowFilter():GlowFilter
		{
			if(!_glowFilter2)
				_glowFilter2 = new GlowFilter("#ffff00", 5, 0, 0);
			return _glowFilter2;
		}
	}
}