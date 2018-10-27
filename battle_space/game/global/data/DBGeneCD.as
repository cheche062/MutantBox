package game.global.data
{
	import game.common.ResourceManager;

	/**
	 * DBGeneCD 基因CD
	 * author:huhaiming
	 * DBGeneCD.as 2017-5-19 上午11:57:51
	 * version 1.0
	 *
	 */
	public class DBGeneCD
	{
		private static var _data:Object;
		private static var KEYS:Array;
		public function DBGeneCD()
		{
		}
		
		/**计算cd话费
		 * @param time 时间，单位是分钟
		 * */
		public static function cost(time:Number):Number{
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
			trace("cost====================================",time, sum);
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
				_data = ResourceManager.instance.getResByURL("config/gene_cd.json");
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