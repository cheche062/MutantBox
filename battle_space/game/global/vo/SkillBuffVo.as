/***
 *作者：罗维
 */
package game.global.vo
{
	public class SkillBuffVo
	{
		public var buff_id:Number;
		public var buff_name:Number;
		public var buff_level:Number;
//		public var effect1:String;
		public var effect2:String;
//		public var cType:Number = 0;
		public var buff_icon:String;
		public var order:Number = 0;
		public var zy:Number = 0;
		public var turn:Number = 1;
		public var up:Number = 0;
		public var down:Number = 0;
		public var buff_type:Number = 0;
		
		private var _buffEffects:Array;
		
		private var maxEffectNum:Number = 2;
		
		public function SkillBuffVo()
		{
			
			for (var i:int = 1; i <= maxEffectNum; i++) 
			{
				this["special"+i] = null;  //
				this["cType"+i] = 0;  //
				this["turn"+i] = 0;  //
				this["up"+i] = 0;  //
				this["down"+i] = 0;  //
			}
		}
		
//		public function get effectUrl1():String
//		{
//			return "appRes/buffEffect/"+effect1+".json";
////			return "appRes/buffEffect/"+"buffEffet01"+".json";
//		}
		
		public function get buffEffects():Array
		{
			if(!_buffEffects)
			{
				_buffEffects = [];
				
				for (var i:int = 1; i <= maxEffectNum; i++) 
				{
					if(this["special"+i])
					{
						var vo:BuffEffectVo = new BuffEffectVo();
						vo.special = this["special"+i];
						vo.cType = this["cType"+i];
						vo.turn = this["turn"+i];
						vo.up = this["up"+i];
						vo.down = this["down"+i];
						_buffEffects.push(vo);
					}
				}
			}
			return _buffEffects;
		}
		
		public function get iconUrl():String{
			return "appRes/buffIcon/"+buff_icon+".png";
		}
	}
}