package game.global.cond
{
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.DBBuilding;
	import game.global.vo.User;

	public class conditionVo
	{
		public var type:Number;
		public var value:Number;
		public function conditionVo()
		{
		}
		
		public function cond():Boolean{
			var v:Number = 0;
			if( type == 0)
			{
				v = User.getInstance().level;
			}else
			{
				v = User.getInstance().sceneInfo.getBuildingLv((type).toString())
			}
			
			return v >= value;
		}
		
		public function toString():String{
			if(type == 0)
			{
				return "L_A_62";
			}
			var vo:Object = DBBuilding.getBuildingById(type);
			if(vo)
			{
				var s:String = GameLanguage.getLangByKey("L_A_63");
				var bName:String = GameLanguage.getLangByKey(vo.name);
				return StringUtil.substitute(s,bName);
			}
			return "cond type error:"+type;
		}
	}
}