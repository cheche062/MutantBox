package game.common
{
	import game.global.ModuleName;
	import game.global.data.bag.ItemData;
	import game.module.bingBook.ItemContainer;
	
	import laya.resource.Texture;
	import laya.utils.Handler;

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
		public static function copyDataSource(source:Object, data:Object):*{
			var obj:Object = source || {};
			for(var key:String in data){
				obj[key] = data[key];
			}
			
			return obj;
		}
		
		/**浅拷贝组合多个数据*/
		public static function copyDataSourceList(...args):Object {
			var obj:Object = {};
			var list:Array = [].slice.call(args);
			list.forEach(function(item) {
				for (var key in item) {
					obj[key] = item[key];
				}
			});
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
		
		/**判断是否是数组*/
		public static function isArray(data:*):Boolean {
			return Object.prototype.toString.call(data) === '[object Array]';
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
		 * 
		 * 处理奖品信息"2=100;3=200"字符，给回调函数传入（id，num）
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
			});
		}
		
		/**创建奖励小图标列表*/
		public static function createRewardsDoms(str:String):Array{
			if (!str) return [];
			var dataArray:Array = str.split(";"); 
			var result:Array = dataArray.map(function(item, index){
				var _index = item.indexOf("=");
				var iid = item.slice(0, _index);
				var inum = item.slice(_index + 1);
				var child:ItemContainer = new ItemContainer();
				child.setData(iid, inum);
				return child;
			});
			
			return result;
		}
		
		/**
		 * 弹层展示奖品信息
		 * @param rewards 奖品字符串   如："1=100;2=200;3=300"
		 * @param isHideConfirmBtn 是否隐藏确认按钮
		 * @return 
		 * 
		 */
		public static function showRewardsHandler(rewards:String, isHideConfirmBtn:Boolean = false):void {
			var arr:Array = rewards.split(";");
			arr = arr.filter(function(item) {return !!item});
			var childList = arr.map(function(item:String, index){
				var child = new ItemData();
				var data = item.split("=");
				child.iid = data[0];
				child.inum = data[1];
				return child;
			});
			
			XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList, isHideConfirmBtn]);
		}
		
		/**
		 * 弹层展示奖品信息
		 * @param rewards [[93202,"20"],[17,"400"]]
		 * 
		 */
		public static function showRewardsHandlerByArray(rewards:Array):void {
			var result:String = "";
			rewards.forEach(function(item:Array, index) {
				result += item.join("=") + ";";
			});
			
			showRewardsHandler(result);
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
		 * 将数字转化成以千为单位 
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
		 * 在某段时间内重复做a事，结束后再做b事（如：限制某按钮的点击频率，然后再恢复按钮） 
		 * @param totalTime 总时间
		 * @param duringCB 期间的回调
		 * @param endCB 结束后的回调
		 * @param isOuterCallEndCB 外部强制清除时，是否需要执行计时结束后的回调  （默认执行）
		 * @return 中途清掉退出的方法（再外部清除）
		 * 
		 */
		public static function limitHandler(totalTime:int, duringCB:Function, endCB:Function, isOuterCallEndCB = true):Function{
			var totalTime = totalTime;
			duringCB(totalTime);
			//计时中的函数
			var func:Function = function ():void{
				totalTime--;
				duringCB(totalTime);
				
				if (totalTime <= 0) {
					Laya.timer.clear(null, func);
					endCB && endCB(0);
				}
				
//				trace('计时中。。。', totalTime);
			}
			
			//清除定时器的函数
			var clear:Function = function ():void{
				Laya.timer.clear(null, func);
				if (isOuterCallEndCB) {
					endCB && endCB();
				}
			}
			
			Laya.timer.loop(1000, null, func);
			
			return clear;
		}
		
		/**
		 * 获取在之间的值
		 * @param curValue 当前值
		 * @param minValue 最小值
		 * @param maxValue 最大值
		 * @return 
		 * 
		 */
		public static function getAmongValue(curValue, minValue, maxValue) {
			if (curValue < minValue) return minValue;
			if (curValue > maxValue) return maxValue;
			return curValue;
		}
		
		/**对象的键组成数组*/
		public static function objectKeys(obj):Array {
			var arr:Array = [];
			for (var key in obj) {
				arr.push(key);
			}
			return arr;
		}
		
		/**对象的成员值组成数组*/
		public static function objectValues(obj):Array {
			var arr:Array = [];
			for (var key in obj) {
				arr.push(obj[key]);
			}
			return arr;
		}
		
		/**过滤对象*/
		public static function filterObj(obj, callback):Object {
			var result:Object = {};
			for (var key in obj) {
				if (callback(obj[key], key)) {
					result[key] = obj[key]
				}
			}
			
			return result
		}
		
		/**
		 *  寻找数组中的子项
		 * @param arr 数组
		 * @param callback 回调
		 * @return 
		 * 
		 */
		public static function find(arr:Array, callback:Function):* {
			for (var i = 0; i < arr.length; i++) {
				if (callback(arr[i], i, arr)) {
					return arr[i];
				}
			}
			return null;
		}
		
		/**
		 *  寻找数组中符合条件子项的索引
		 * @param arr 数组
		 * @param callback 回调
		 * @return 
		 * 
		 */
		public static function findIndex(arr:Array, callback:Function):* {
			for (var i = 0; i < arr.length; i++) {
				if (callback(arr[i], i, arr)) {
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * 将数组转为json对象   
		 * @param key   'id'
		 * @param array  [{id: '111', value: 'aaa'}, {id: '222': value: 'bbb'}]
		 * @return  {'111': {id: '111', value: 'aaa'}, '222': {id: '222': value: 'bbb'}}
		 * 
		 */
		public static function arrayToJson(key:String, array:Array):Object {
			var result = {};
			array.forEach(function(item, index) {
				result[item[key]] = item;
			});
			return result;
		}
		
		/**
		 * 取随机值 
		 * @param n1 最大值
		 * @param n2 起始值
		 * @return 
		 * 
		 */
		public static function getRandomNumber(n1:Number, n2:Number = 0):Number {
			return Math.round(Math.random() * (n1 - n2) + n2);
			
		}
		
		/**字符的长度*/
		public static function getStringLength(str = ''):Number{
			return ("" + str.replace(/[^\x00-\xff]/gi, "ox")).length;
		}
		
		/**截取限制长度的字符   中文算两个字符*/
		public static function getActiveStr(str = '', total = 8):String {
			var realLength = 0;
			str = String(str);
			var len = str.length;
			var result = '';
			if (len === 0) return '';
			for (var i = 0; i < len; i++) {
				if (str.charCodeAt(i) > 128) {
					realLength += 2;
				} else {
					realLength += 1;
				}
				if (realLength > total) {
					return result + "...";
				}
				result = result + str.charAt(i);
			}
			
			return result;
		}
		
		/**
		 * 节流函数
		 * @param fn  回调函数
		 * @param context  this上下文
		 * @param diffTime  最小时间差
		 * @return 
		 * 
		 */
		public static function throttle(fn:Function, context:Object, diffTime = 100):Function {
			var locked = false;
			
			return function() {
				if (locked) return;
				locked = true;
				Laya.timer.once(diffTime, this, function(){
					locked = false;
				});
				
				fn.apply(context, arguments);
			}
		}
		
		/**打乱数组*/
		public static function breakRankArray(arr:Array):Array {
			return arr.map(function(item) {
				return {
					num: Math.random(),
					value: item
				}
			}).sort(function(a, b) {
				return a.num - b.num;
			}).map(function(item) {
				return item.value;
			});
		}
		
		public static function loadImag(url:String, callback:Function):void {
			if (!url) return trace("图片地址为空");
			Laya.loader.load(url, Handler.create(null, function() {
				var t:Texture = Laya.loader.getRes(url);
				callback(t);
			}));
		}
	
		
		
	
		
	}
}