package game.global.data
{
	import game.common.ResourceManager;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.military.MilitaryVo;

	/**
	 * DBMilitory
	 * author:huhaiming
	 * DBMilitory.as 2017-4-28 下午12:08:30
	 * version 1.0
	 *
	 */
	public class DBMilitary
	{
		private static var _data:Object
		//九个军衔阶段
		public static var list:Array = [1,2,3,4,5,6,7,8,9];
		/**所有军衔信息*/
		private static var _all:Array;
		/***/
		public static var state:Number = 0;
		/**事件-军衔变化*/
		public static const MILITARY_CHANGE:String = "change";
		public function DBMilitary()
		{
		}
		
		/**获取同一个军衔阶段对应的军衔信息*/
		public static function getInfoByLv(lv:int):Array{
			var arr:Array = [];
			var vo:MilitaryVo
			for(var i:String in data){
				vo = data[i];
				if(parseInt(vo.level) == lv){
					arr.push(vo);
					User
				}
			}
			return arr;
		}
		
		/**根据杯数获取信息*/
		public static function getInfoByCup(cupNum:int):MilitaryVo{
			for(var i:String in data){
				if(cupNum >= data[i].down  && cupNum <= data[i].up){
					return data[i]
				}
			}
			return null;
		}
		
		/***/
		public static function checkState(pastCup:Number, curCup:Number):void{
			var pVo:MilitaryVo;
			var curVo:MilitaryVo;
			if(data){
				pVo = getInfoByCup(pastCup);
				curVo = getInfoByCup(curCup);
				if(pastCup > curCup){
					if(pVo != curVo){
						//降级===================================
						state = -1;
						Signal.intance.event(MILITARY_CHANGE, state);
					}
				}else if(pastCup < curCup){
					if(pVo != curVo){
						//升级===================================
						state = 1;
						Signal.intance.event(MILITARY_CHANGE, state);
					}
				}
			}
		}
		
		/**获取所有军衔*/
		public static function getAll():Array{
			if(!_all){
				_all = [];
				for(var i:int=0; i<999; i++){
					if(data[i+1]){
						_all.push(data[i+1]);
					}else{
						break;
					}
				}
			}
			return _all;
		}
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/base_military.json"); 
			}
			return _data;
		}
	}
}