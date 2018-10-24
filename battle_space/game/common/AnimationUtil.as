package game.common
{
	import game.module.mainScene.BaseArticle;
	
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.ui.Component;
	import laya.utils.Dictionary;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * AnimationUtil 简单动画包装类
	 * author:huhaiming
	 * AnimationUtil.as 2017-3-17 下午12:09:37
	 * version 1.0
	 *
	 */
	public class AnimationUtil
	{
		public function AnimationUtil()
		{
		}
		
		/**
		 * 动画效果-入场，从下到当前位置，alpha从0到1
		 * @param dis 动画对象
		 * @param time 动画时间
		 * @param distance 移动距离
		 */
		public static function flowIn(dis:Component, time:Number = 200, distance:Number = 200):void{
			//dis.alpha = 0;
			var tarY:Number = dis.y
			dis.y = dis.y + distance;
			Tween.clearTween(dis);
			Tween.to(dis, {alpha:1, y:tarY}, time);
		}
		
		/**
		 * 动画效果-出场，从当前位置往上，alpha从0到1
		 * @param dis 动画对象
		 * @param time 动画时间
		 * @param distance 移动距离
		 * @param funTarget 函数回调对象
		 */
		public static function flowOut(target:Component,callback:Function,time:Number = 150, distance:Number = 200,funTarget:*=null):void{
			var tarY:Number = target.y - distance
			Tween.to(target, {alpha:0, y:tarY}, time, null,Handler.create(null, onflowOut,[target,callback, funTarget]));
			
			function onflowOut(target:Component, callback:Function, funTarget:*=null):void{
				target.alpha = 1;
				callback.apply((funTarget || target), null);
			}
		}
		
		/**
		 * 动画效果-出场2，从当前位置往下，alpha从0到1
		 * @param dis 动画对象
		 * @param time 动画时间
		 * @param distance 移动距离
		 * @param funTarget 函数回调对象
		 */
		public static function flowBack(target:Component,callback:Function,time:Number = 150, distance:Number = 200,funTarget:*=null):void{
			var tarY:Number = target.y + distance
			Tween.to(target, {alpha:0, y:tarY}, time, null,Handler.create(null, onflowOut,[target,callback, funTarget]));
			
			function onflowOut(target:Component, callback:Function, funTarget:*=null):void{
				target.alpha = 1;
				callback.apply((funTarget || target), null);
			}
		}
		
		
		private var flowSpeed:int = 500;
		/**
		 * 漂浮效果
		 * @param target 动作对象
		 * @param add 是否是加动画 
		 * */
		private static function doFlow(target:Sprite, add:Boolean=true):void{
			var tarY:Number = target.y;
			if(add){
				step1();
			}else{
				target.y = tarY;
				Tween.clearTween(target);
			}
			function step1():void{
				Tween.to(target, {y:tarY-50}, flowSpeed, Ease.linearInOut, Handler.create(null, step2));
			}
			
			function step2():void{
				Tween.to(target, {y:tarY}, flowSpeed, Ease.linearInOut, Handler.create(null, step1));
			}
			
			
		}
		
		private static var _flowDic:Array= [];
		/**加漂浮效果*/
		public static function addFlow(target:Sprite,speed:int= 500):void{
			if (_flowDic.indexOf(target) == -1) {
				flowSpeed = speed;
				_flowDic.push(target);
				doFlow(target)
			}
		}
		
		/**移除漂浮效果*/
		public static function removeFlow(target:Sprite):void{
			for(var i:String in _flowDic){
				if(_flowDic[i] == target){
					_flowDic.splice(i,1);
					doFlow(target, false)
					break;
				}
			}
		}
		
		/**
		 * 动画效果-入场，弹出一个窗口,注意，只有没设置中心点或者中心点坐标为(0,0)可用
		 * @param dis 动画对象
		 * @param time 动画时间
		 * @param distance 移动距离
		 */
		public static function popIn(dis:Component, time:Number = 200, distance:Number = 200):void{
			Tween.clearTween(dis);
			dis.anchorX = 0.5;
			dis.anchorY = 0.5;
			dis.x += dis.width*0.5;
			dis.y += dis.height*0.5;
			dis.scale(0.5,0.5);
			
			Tween.to(dis,{scaleX:1,scaleY:1,ease:Ease.backOut},300,null,Handler.create(null, onPopIn));
			
			function onPopIn():void{
				dis.anchorX = 0;
				dis.anchorY = 0;
				dis.scaleX = dis.scaleY = 1;
				dis.x -= dis.width*0.5;
				dis.y -= dis.height*0.5;
			}
		}
		
		/**
		 * 动画效果-出场，从当前位置往上，alpha从1到0
		 * @param target 动画对象 && 回调对象，
		 * @param callback 回调函数
		 * @param time 动画时间
		 * @param distance 移动距离
		 * @param funTarget 函数回调对象
		 */
		public static function popOut(target:Component,callback:Function,time:Number = 150, distance:Number = 200,funTarget:*=null):void{
			Tween.clearTween(target);
			target.anchorX = 0.5;
			target.anchorY = 0.5;
			target.x += target.width*0.5;
			target.y += target.height*0.5;
			
			Tween.to(target, {scaleX:0.5, scaleY:0.5}, time, null,Handler.create(null, onPopOut));
			
			function onPopOut():void{
				target.anchorX = 0;
				target.anchorY = 0;
				target.scaleX = target.scaleY = 1;
				target.x -= target.width*0.5;
				target.y -= target.height*0.5;
				callback.apply(funTarget||target, null);
			}
		}
		
		/**基地互动-建筑选中效果*/
		public static function showUp(target:Sprite,hasPosInfo:Boolean = false):void{
			Tween.clearTween(target);
			if(hasPosInfo){
				var arr:Array = target.name.split("_");
				target.y = parseInt(arr[1]);
			}
			var tarY:Number = target.y;
			Tween.to(target, {y:target.y-20}, 50);
			//Tween.to(target, {scaleX:1.1, scaleY:0.9}, 100, null,Handler.create(null, onScale));
			
			function onScale():void{
				Tween.to(target, {scaleX:0.9, scaleY:1.1, y:target.y-40}, 100, null,Handler.create(null, toNormal));
			}
			
			function toNormal():void{
				Tween.to(target, {scaleX:1,scaleY:1}, 100);
			}
		}
		
		/**基地互动-取消选中效果*/
		public static function showDown(target:Sprite, hasPosInfo:Boolean = false):void{
			Tween.clearTween(target);
			if(hasPosInfo){
				var arr:Array = target.name.split("_");
				target.y = parseInt(arr[1]);
			}
			var tarY:Number = target.y;
			
			//Tween.to(target, {scaleY:1.1, y:target.y-40}, 100, null,Handler.create(null, onScale));
			
			function onScale():void{
				Tween.to(target, {scaleX:1.1, scaleY:0.9, y:tarY}, 100, null,Handler.create(null, toNormal));
			}
			
			function toNormal():void{
				Tween.to(target, {scaleX:1,scaleY:1}, 100);
				if(target is BaseArticle){
					BaseArticle(target).showDownAni();
				}
			}
		}
				
		/**建筑-交换动画*/
		public static function showChangeAni(target:Sprite, origin:Point):void{
			var tarP:Point = new Point(target.x, target.y);
			target.x = origin.x;
			target.y = origin.y;
			var delY:Number = 60;
			Tween.clearTween(target);
			Tween.to(target,{scaleX:1.1, scaleY:0.9},50,null,Handler.create(null, up));
			
			function up():void{
				Tween.to(target,{scaleX:0.9, scaleY:1.1, y:target.y-delY},50,null,Handler.create(null, fly));
			}
			
			function fly():void{
				Tween.to(target,{x:tarP.x, y:tarP.y-delY},150,null,Handler.create(null, down));
			}
			
			function down():void{
				Tween.to(target,{scaleX:1.1, scaleY:0.9, y:tarP.y},50,null,Handler.create(null, done));
			}
			
			function done():void{
				Tween.to(target, {scaleX:1,scaleY:1}, 100);
				if(target is BaseArticle){
					BaseArticle(target).showDownAni();
				}
			}
		}
		
		/**基地-建筑选中效果*/
		private static var flashDic:Dictionary = new Dictionary();
		public static function flash(target:Sprite, doFlash:Boolean=true):void{
			flashDic.set(target,doFlash);
			if(doFlash){
				flash(target);
			}else{
				flashDic.remove(target);
			}
			
			function flash(target:Sprite):void{
				target.filters = [];
				if(flashDic.get(target)){
					Laya.timer.once(200, null, flash1,[target]);
				}
			}
			
			function flash1(target:Sprite):void{
				target.filters = [FilterTool.glowFilter];
				if(flashDic.get(target)){
					Laya.timer.once(200, null, flash2,[target]);
				}else{
					target.filters = [];
				}
			}
			
			function flash2(target:Sprite):void{
				target.filters = [FilterTool.bigGlowFilter];
				if(flashDic.get(target)){
					Laya.timer.once(200, null, flash,[target]);
				}else{
					target.filters = [];
				}
			}
		}
	}
}