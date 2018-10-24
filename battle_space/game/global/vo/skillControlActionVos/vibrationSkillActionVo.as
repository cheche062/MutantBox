package game.global.vo.skillControlActionVos
{
	public class vibrationSkillActionVo extends baseSkillActionVo
	{
		public var vibrationRoute:String;
		public var vibrationSpeed:Number = 0;
		public var vibrationInterval:Number = 0;
		public var vibrationTime:Number = 0;
		
		public function vibrationSkillActionVo()
		{
			super();
		}
		
		private var _vibrationRouteAr:Array;

		public function get vibrationRouteAr():Array
		{
			if(!_vibrationRouteAr)
			{
				_vibrationRouteAr = [];
				var ar:Array = vibrationRoute.split(",");
				for (var i:int = 0; i < ar.length; i++) 
				{
					var ar2:Array = ar[i].split("|");
					var obj:Object = {};
					for (var j:int = 0; j < ar2.length; j++) 
					{
						var ar3:Array = ar2[j].split(":");
						obj[ar3[0]] = Number(ar3[1]);
					}
					_vibrationRouteAr.push(obj);
				}
				
			}
			
			return _vibrationRouteAr;
		}

	}
}