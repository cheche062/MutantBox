/***
 *作者：罗维
 */
package game.module.bag.mgr
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;

	public class ItemManager
	{
		public function ItemManager()
		{
		}
		
		public static function StringToReward(str:String):Array{
			if(!str || !str.length)
				return null;
			var rtAr:Array = [];	
			var ar:Array = str.split(";");
			for (var i:int = 0; i < ar.length; i++) 
			{
				var s:String = ar[i];
				if(s && s.length){
					var ar2:Array = s.split("=");
					if(ar2.length > 0)
					{
						var ivo:ItemVo = GameConfigManager.items_dic[ar2[0]];
						if(ivo)
						{
							var idata:ItemData = new ItemData();
							idata.iid = ivo.id;
							if(ar2.length > 1)
								idata.inum = Number(ar2[1]);
							else
								idata.inum = 1;
							rtAr.push(idata);
						}
					}
				}
			}
			return rtAr;
		}
		
		public static function merge(ar1:Array , ar2:Array):void
		{
			for (var i:int = 0; i < ar2.length; i++) 
			{
				var idata:ItemData = ar2[i];
				var idata2:ItemData = getById(ar1,idata.iid);
				if(idata2)
				{
					idata2.inum += idata.inum;
				}else
				{
					var idata3:ItemData = new ItemData();
					idata3.iid = idata.iid;
					idata3.inum = idata.inum;
					ar1.push(idata3);
				}
			}
			
		}
		
		private static function getById(ar:Array , id:Number):ItemData{
			for (var i:int = 0; i < ar.length; i++) 
			{
				var idata:ItemData = ar[i];
				if(idata.iid == id)
					return idata;
			}
			return null;
		}
	}
}