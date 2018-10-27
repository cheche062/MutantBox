package game.common
{

	/**
	 * 工具函数处理 
	 * @author hejianbo
	 * 
	 */
	public class ToolFunc
	{
		public function ToolFunc()
		{
		}
		
		/**
		 * 获取目标对象集合中的某子对象中的目标键对应的值是否与目标值相等-> 返回该项子对象 否则 返回null 
		 * @param obj 源对象
		 * @param targetKey 键
		 * @param targetValue 值
		 * @param isSingleData 是否返回单个数据
		 * @return 
		 * 
		 */
		public static function getTargetItemData(data:Object, targetKey:String, targetValue:*, isSingleData:Boolean = true):Object{
			var result:Array = [];
			for (var key:String in data) {
				if (data[key][targetKey] == targetValue) {
					result.push(data[key]);
					if (isSingleData) break;
				}
			}
			
			return isSingleData? result[0] : result;
		}
		
		/**
		 * 对象中是否含有某键
		 * @param obj 源对象
		 * @param targetKey
		 * @return 
		 * 
		 */
		public static function hasKey(source:Object, targetKey:String):Boolean{
			return targetKey in source;
		}
		
		/**
		 * 拷贝数据副本(浅拷贝)
		 * @param source 源数据
		 * @param data 扩展数据
		 * @return 
		 */
		public static function copyDataSource(source:Object, data:Object):Object{
			var obj:Object = source || {};
			for(var key:String in data){
				obj[key] = data[key];
			}
			
			return obj;
		}
		
		/**
		 * 深拷贝 
		 * @param parent
		 * @param child
		 * @return 
		 * 
		 */
		public static function extendDeep(parent, child):Object{
			if (typeof parent !== 'object' || parent === null) return parent;
			
			var _tostr = Object.prototype.toString;
			var child = child || ((_tostr.call(parent) === '[object Array]')? [] : {});
			
			for(var key in parent){
				if(parent.hasOwnProperty(key)){
					if(typeof parent[key] === 'object' && parent[key] !== null){
						child[key] = (_tostr.call(parent[key]) === '[object Array]')? [] : {};
						extendDeep(parent[key], child[key]);
					}else{
						child[key] = parent[key];
					}
				}
			}
			return child;
		}
		
		/**
		 * 寻找目标值在数据表的每一子项数据中的上限与下限区域内——>返回该子项数据
		 * @param target 目标值
		 * @param data 源数据
		 * @param downKey 下限字段
		 * @param upKey 上限字段
		 * @param isSingleData 是否返回单个数据
		 * @return 子项数据  array || Object
		 * 
		 */
		public static function getItemDataOfWholeData(target:Number, data:*, downKey:String, upKey:String, isSingleData:Boolean = true):*{
			if (!data) { return trace("【!!!源数据为空】") }
			
			var result:Array = [];
			// 源数据的键集合
			var keyArr:Array = [];
			for (var key:String in data) {
				var itemData:Object = data[key];
				keyArr.push(key);
				if (target >= Number(itemData[downKey]) && target <= Number(itemData[upKey])) {
					result.push(itemData);
					if (isSingleData) break;
				}
			}
			// 没遍历到数据
			if (result.length == 0) {
				// 比最小都要小
				if (target < Number(data[keyArr[0]][downKey])) {
					result.push(data[keyArr[0]]);
					trace("【数据比最小区间都要小】");
				}
				if (target > Number(data[keyArr[keyArr.length - 1]][upKey])) {
					result.push(data[keyArr[keyArr.length - 1]])
					trace("【数据比最大区间都要大】");
				}
			}
			
			return isSingleData ? result[0] : result;
		}
		
		/**
		 * 归纳 数组中相同项
		 * arr [1,2,2,3,3]
		 * @return [[1, 1], [2, 2], [3, 2]]     [子项，出现次数]
		 * 
		 */
		public static function concludeArray(arr:Array):Array{
			var obj:Object = {};
			var result:Array = [];
			arr.forEach(function(item, index){
				var type:* = typeof item;
				var key:String = type + "_" + item;
				if (key in obj) {
					obj[key]++;
				} else {
					obj[key] = 1;
				}
			})
			for	(var key:String in obj) {
				var _index:int = key.indexOf("_");
				var type:String = key.slice(0, _index);
				
				if (type == "number") {
					result.push([Number(key.slice(_index + 1)), obj[key]]);
				} else if (type == "string"){
					result.push([key.slice(_index + 1), obj[key]]);
				}
			}
			
			return result;
		}
		
		/**
		 * 处理"2=100;3=200"字符，给回调函数传入（id，num）
		 * @param str
		 * @param callBack 
		 * 
		 */
		public static function rewardsDataHandler(str:String, callBack:Function):void{
			var dataArray:Array = str.split(";"); 
			dataArray.forEach(function(item, index){
				var _index = item.indexOf("=");
				var iid = item.slice(0, _index);
				var inum = item.slice(_index + 1);
				callBack(iid, inum, index, dataArray);
			})
		}
		
		/**
		 * 是否是第一次函数执行的管家 
		 * @param firstCB 首次执行的回调
		 * @param normalCB 非首次的回调
		 * @return function
		 * 
		 */
		public static function isFirstFuncSteward(firstCB:Function, normalCB:Function):Function{
			var isFirst:Boolean = true;
			return function(){
				if (isFirst) {
					firstCB();
					isFirst = false;
				} else {
					normalCB();
				}
			}
		}
		/**
		 * 类数组的some方法 
		 * @param obj
		 * @param callBack
		 * @return Boolean
		 * 
		 */
		public static function someObjectCheck(obj:Object, callBack:Function):Boolean{
			for (var key:String in obj) {
				var result:Boolean = callBack(obj[key]);
				if (result) return true;
			}
			
			return false;
		}
		
		/**
		 * 类数组的every方法 
		 * @param obj
		 * @param callBack
		 * @return Boolean
		 * 
		 */
		
		public static function everyObjectCheck(obj:Object, callBack:Function):Boolean{
			for (var key:String in obj) {
				var result:Boolean = callBack(obj[key]);
				if (!result) return false;
			}
			
			return true;
		}
		
		/**
		 * 模拟数组reduce方法 
		 * @param arr
		 * @param callBack
		 * @param initValue
		 * @return 
		 * 
		 */
		public static function reduceArrayFn(arr:Array, callBack:Function, initValue:*):* {
			var result:* = initValue;
			
			// 没传初始值
			if (typeof result === 'undefined') {
				// 索引需从1开始
				if (arr.length === 0) throw new Error('Reduce of empty array with no initial value');
				if (arr.length === 1) return arr[0]; 
				
				for (var i:int = 1; i < arr.length; i++) {
					if (i === 1) {
						result = callBack(arr[0], arr[i], i, arr);
					} else {
						result = callBack(result, arr[i], i, arr);
					}
				}
				
				// 传了初始值
			} else {
				for (var j:int = 0; j < arr.length; j++) {
					result = callBack(result, arr[j], j, arr);
				}
			}
			
			return result;
		}
		
		
		/**
		 * 将数字转化成已千为单位 
		 * @param num
		 * @return 
		 * 
		 */
		public static function thousandFormat(num):String{
			num = Number(num);
			if (num / 1000 >= 1) {
				return num / 1000 + "k";
			} else {
				return String(num);
			}
		}
		
		
		/**
		 * 把秒数转化成 *日*时*分*秒 
		 * @param num
		 * @return 
		 * 
		 */
		public static function toDetailTime(num):String{
			var time = Number(num);
			var days = Math.floor(time / 1440 / 60);
			var hours = Math.floor((time - days * 1440 * 60) / 3600);
			var minutes = Math.floor((time - days * 1440 * 60 - hours * 3600) / 60);
			var seconds = (time - days * 1440 * 60 - hours * 3600 - minutes * 60);
			var result = {};
			result["days"] = days;
			result["hours"] = hours;
			result["minutes"] = minutes;
			result["seconds"] = seconds;
			
			return result;
		}
		
			
		
		
	
		
	}
}