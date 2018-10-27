/***
 *作者：罗维
 */
package game.global.cond
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;

	public class ConditionsManger
	{
//		public function 
		
		public function ConditionsManger()
		{
		}
		
		public static function cond(v:*):Array
		{
			if(!v)
			{
				return null;
			}
			
			var cList:Array;
			if(v is Array)
			{
				cList = null;
			}else if(v is String)
			{
				cList = StringToArray(v);
			}
			
			if(!cList)
			{
				return null;
			}
			var errorList:Array = [];
			for (var i:int = 0; i < cList.length; i++) 
			{
				var vo:conditionVo = cList[i];
				if(!vo.cond())
				{
					errorList.push(vo);
				}
			}
			
			return errorList.length ? errorList : null;
			
		}
		
		
		public static function StringToArray(str:String):Array{
			if(!str || !str.length)
				return null;
			var rtAr:Array = [];	
			var ar:Array = str.split(";");
			for (var i:int = 0; i < ar.length; i++) 
			{
				var s:String = ar[i];
				if(s && s.length){
					var ar2:Array = s.split("=");
					if(ar2.length >= 2)
					{
						var cVo:conditionVo = new conditionVo();
						cVo.type = Number(ar2[0]);
						cVo.value = Number(ar2[1]);
						rtAr.push(cVo);
					}
				}
			}
			return rtAr;
		}
	}
}