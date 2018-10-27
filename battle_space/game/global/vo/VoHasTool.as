package game.global.vo
{
	import laya.utils.ClassUtils;
	
	/**
	 *对类型的反射处理 
	 */

	public class VoHasTool
	{
		public function VoHasTool()
		{
		}
		
		//反射对象
		public static var pListDick:Object = {};
		public static function hasVo(vCalss:Class,vObj:Object):*
		{
//			var vClassName:String = ClassUtils.getClass
			var vClassFun:* = ClassUtils.getClass(vCalss);
			var retObj:* = new vClassFun(); 
			var arr:Array = pListDick[vCalss];
			if(arr == null)
			{
				arr = [];
				for(var key:* in retObj)
				{
					arr.push(key);
				}
				pListDick[vCalss] = arr;
			}
			
			for (var i:int = 0; i < arr.length; i++) 
			{
				var vK:* = arr[i];
				if(vObj.hasOwnProperty(vK))
				{
					var vV:* = retObj[vK];
				
					if(isNaN(parseFloat(vV)))
					{
						if(vObj[vK] != "0" && vObj[vK] != ""){
							retObj[vK] = vObj[vK];
						}
					}else
					{
						retObj[vK] = Number(vObj[vK]);
					}
				}
			}
			
			
			return retObj;
		}
	}
}