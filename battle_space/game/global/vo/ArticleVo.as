/***
 *作者：罗维
 */
package game.global.vo
{
	import laya.maths.Point;

	/**
	 *所有出现在基地上物品的基类 
	 */
	public class ArticleVo
	{
		public var model:String;
		public var model_point:String;
		public var model_w:uint;
		public var model_h:uint;
		public var hitArea_points:String;
		
		private var _mPoint:Point;
		
		public function ArticleVo()
		{
		}
	}
}