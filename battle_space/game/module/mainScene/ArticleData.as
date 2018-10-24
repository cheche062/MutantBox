/***
 *作者：罗维
 */
package game.module.mainScene
{
	
	import laya.maths.Point;

	public class ArticleData
	{
		public var level:uint;
		public var buildId:String;
		public var model_w:Number = 1;
		public var model_h:Number = 1;
		private var _showPoint:Point;    //预设坐标
		public var realPoint:Point;  //实际坐标
		//是否有效区域内
		public var inMap:Boolean = true;
		//资源
		public var resource:String="0";
		//id
		public var id:String = "0";
		//类型，0建筑，1，怪物，2障碍物
		public var type:int = 0;
		/**附加数据,怪物击杀奖励*/
		public var ex:Object;
		//怪物影响BUFF,针对建筑
		public var buff:Object;
		//怪物列表,针对建筑
		public var effMonsters:Array;
		
		/**类型-建筑*/
		public static const TYPE_BUILDING:int = 0;
		/**类型-怪物*/
		public static const TYPE_MONSTER:int = 1;
		/**类型-障碍*/
		public static const TYPE_BLOCK:int = 2;
		
		
		public function ArticleData()
		{
		}
		
		
		public function get showPoint():Point
		{
			return _showPoint;
		}
		
		
		public function set showPoint(value:Point):void
		{
			_showPoint = value;
		}
	}
}