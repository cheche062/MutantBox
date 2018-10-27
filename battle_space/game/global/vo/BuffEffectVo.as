package game.global.vo
{
	public class BuffEffectVo
	{
		public var special:String = "";  //特效名称
		public var cType:Number = 0;   //特效type
		public var turn:Number = 0;   //是否翻转
		public var up:Number = 0;   //向上层次
		public var down:Number = 0; //向下层次
		
		
		public function BuffEffectVo()
		{
		}
		
		
		public function getEffectByDir(direction:Number):String{
			return "appRes/buffEffect/"+special +  ( (direction == 1 || turn == 1) ?"/up":"/down") + ".json";
		}
		
	}
}