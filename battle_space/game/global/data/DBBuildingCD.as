package game.global.data
{
	import game.common.ResourceManager;
	import game.global.vo.VIPVo;
	import game.module.mainScene.BaseArticle;

	/**
	 * DBBuildingCD
	 * author:huhaiming
	 * DBBuildingCD.as 2017-5-2 下午12:25:30
	 * version 1.0
	 *
	 */
	public class DBBuildingCD
	{
		private static var _data:Object;
		private static var KEYS:Array;
		public function DBBuildingCD()
		{
		}
		
		/**计算cd话费*/
		public static function cost(time:Number):Number{
			//vip
			var vipInfo:VIPVo = VIPVo.getVipInfo();
			time = time - vipInfo.build_speed_up/60;
			
			
			var sum:Number = 0;
			//下面这货【data】不能去掉！！！
			data;
			for(var i:int=1; i<KEYS.length; i++){
				if(time>= KEYS[i]){//计算累计消费
					sum+= getPrice(KEYS[i-1])*(KEYS[i]-KEYS[i-1])
				}else{
					sum+= getPrice(KEYS[i-1])*(time-KEYS[i-1])
					break;
				}
			}
			//trace("cost====================================",time, sum);
			return Math.ceil(sum);
		}
		
		private static function getPrice(key:Number):Number{
			if(data[key]){
				return data[key].stage_price;
			}
			return 0;
		}
		
		//排序算法
		private static function sortFun(n1:Number, n2:Number ):int{
			return n1-n2
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/building_CD.json");
				if(!KEYS){
					KEYS = [];
					for(var i:String in _data){
						KEYS.push(parseInt(i));
					}
					KEYS.sort(sortFun);
				}
			}
			return _data;
		}
	}
}