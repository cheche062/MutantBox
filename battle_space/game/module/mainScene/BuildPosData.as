package game.module.mainScene
{
	import game.common.ResourceManager;

	/**
	 * BuildPosData 坐标位置微调
	 * author:huhaiming
	 * BuildPosData.as 2017-4-21 下午1:49:16
	 * version 1.0
	 *
	 */
	public class BuildPosData
	{
		/*private static var posDic:Object = 
			{
				1:[0,-2],
				2:[0,-6],
				3:[-17,-5],
				4:[1,-4],
				5:[-24,-4]
			}*/
		private static var _posDic:Object;
		public function BuildPosData()
		{
		}
		
		public static function getOff(bid:String):Array{
			return posDic[bid.replace("B","")]
		}
		
		
		/**获取迷雾位置*/
		public static function getFogPos(fogid:*):Array{
			return posDic.fogs[fogid]
		}
		
		
		/**----------------------------*/
		public static function get offX():Number{
			return posDic["OffsetX"];
		}
		public static function get offY():Number{
			return posDic["OffsetY"];
		}
		
		/**获取建筑声音，设计不合理，将就先用着*/
		public static function getBuildSnd(bid:String):String{
			var arr:Array = getOff(bid);
			if(arr){
				return arr[2];
			}
			return null;
		}
		
		
		
		
		private static function get posDic():Object{
			if(!_posDic){
				_posDic = ResourceManager.instance.getResByURL("staticConfig/pos.json"); 
			}
			return _posDic
		}
	}
}