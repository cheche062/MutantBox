package game.common
{
	import game.global.GameLanguage;
	
	import laya.display.Animation;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.maths.Point;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;

	/**
	 * XUtils
	 * author:huhaiming
	 * XUtils.as 2017-3-8 上午10:34:06
	 * version 1.0
	 *
	 */
	public class XUtils
	{
		/**显示黑色滤镜*/
		public static var blackFilter:ColorFilter=new ColorFilter([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.78, 0]);
		/**显示黑色滤镜2,透明度不一样*/
		public static var blackFilter2:ColorFilter=new ColorFilter([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0]);

		public function XUtils()
		{
		}


		/**
		 * 判定两个点是否相等
		 * @param p1
		 * @param p2
		 * */
		public static function pointEquil(p1:Point, p2:Point):Boolean
		{
			return p1 && p2 && p1.x == p2.x && p1.y == p2.y;
		}

		/**判定一个对象（主要是Object和数组）*/
		public static function isEmpty(obj:Object):Boolean
		{
			for (var i:String in obj)
			{
				return false;
			}
			return true;
		}

		/**
		 * 文字跳动简单效果
		 */
		public static function showTxtEffect(txt:*, num:Number):void
		{
			var cur:Number=parseInt(txt.text);
			var del:Number=Math.floor((num - cur) / 5) //5为显示步长，magic value
			var index:int=0;
			Laya.timer.loop(60, null, onUpdate);

			function onUpdate():void
			{
				index++;
				cur+=del;
				if (index >= 5)
				{
					cur=num;
					Laya.timer.clear(null, onUpdate);
				}
				txt.text=cur + "";
			}
		}

		/**颜色切换*/
		private static const COLORS:Array=["#69ff4c", "#FFFFFF"];

		public static function showTxtFlash(tf:*):void
		{
			var orColor:String=tf.color;
			tf.color=COLORS[0];
			Tween.to(tf, {}, 10, null, Handler.create(null, step1), 50);

			function step1():void
			{
				tf.color=COLORS[1];
				Tween.to(tf, {}, 10, null, Handler.create(null, step2), 50);
			}
			function step2():void
			{
				tf.color=COLORS[0];
				Tween.to(tf, {}, 10, null, Handler.create(null, step3), 50);
			}
			function step3():void
			{
				tf.color=COLORS[1];
				Tween.to(tf, {}, 10, null, Handler.create(null, step4), 50);
			}

			function step4():void
			{
				tf.color=COLORS[0];
				Tween.to(tf, {}, 10, null, Handler.create(null, step5), 50);
			}
			function step5():void
			{
				tf.color=COLORS[1];
				Tween.to(tf, {}, 10, null, Handler.create(null, finish), 50);
			}

			function finish():void
			{
				tf.color=orColor;
			}
		}

		/**转换对应表,特殊的才需要写人DIC*/
		private static var PRO_DIC:Object={"HP": "hp", "ATK": "attack", "DEF": "defense", "SPEED": "speed", "RES": "resilience", "CDMG": "critDamage", "CDMGR": "critDamReduct"}

		/**属性对应转换——静态表里面的数据转换成角色属性*/
		public static function getProKey(key:String):String
		{
			if (PRO_DIC[key])
			{
				return PRO_DIC[key];
			}
			else
			{
				return key;
			}
		}

		/**属性->ICON映射*/
		private static const proList:Object=
			{"hp": "HP", "attack": "ATK", "atk": "ATK","defense": "DEF",
				"def": "DEF","speed": "SPEED", "hit": "hit", "dodge": "dodge", 
				"crit": "crit", "critDamage": "CDMG", "resilience": "RES", "critDamReduct": "CDMGR"}

		/**获取属性对应的icon名字*/
		public static function getIconName(proName:String):String
		{
			return proList[proName.toLowerCase()]
		}

		/**克隆一个点*/
		public static function clonePoint(p:Point):Point
		{
			return new Point(p.x, p.y);
		}

		/**
		 * 克隆一个简单value类型 Object
		 */
		public static function copyObj(targetObj:Object):Object
		{
			var tmp:Object={};
			for (var i:String in targetObj)
			{
				tmp[i]=targetObj[i]
			}
			return tmp;
		}


		/**
		 * 合并两个OBJ(加/减运算), 将valueObj中的值合并到targeObj
		 * @param targeObj 目标对象，会返回该对象
		 * @param valueObj 值对象
		 */
		public static function mergeObj(targeObj:Object, valueObj:Object):Object
		{
			for (var i:String in valueObj)
			{
				if (targeObj[i])
				{
					targeObj[i]=parseFloat(targeObj[i]) + parseFloat(valueObj[i]);
				}
				else
				{
					targeObj[i]=valueObj[i]
				}
			}
			return targeObj;
		}

		/***/
		public static function checkHit(dis:Sprite):Boolean
		{
			return dis.visible && dis.mouseX > 0 && dis.mouseY > 0 && dis.mouseX <= dis.width && dis.mouseY <= dis.height;
		}

		/**
		 * 分离两个OBJ(加/减运算), 将valueObj中的值从targeObj减去
		 * @param targeObj 目标对象，会返回该对象
		 * @param valueObj 值对象
		 */
		public static function separateObj(targeObj:Object, valueObj:Object):Object
		{
			if (valueObj)
			{
				for (var i:String in valueObj)
				{
					if (targeObj[i])
					{
						targeObj[i]=parseFloat(targeObj[i]) - parseFloat(valueObj[i]);
					}
				}
			}
			return targeObj;
		}

		/**
		 * 保留小数位
		 * @param num 需要转换的数字
		 * @param decimalNum 保留小数位
		 * */
		public static function toFixed(num:*, decimalNum:int=1):String
		{
			if ((num + "").indexOf(".") != -1)
			{
				var str:String=parseFloat(num).toFixed(decimalNum);
				if (decimalNum == 1 && str.charAt(str.length - 1) == "0")
				{
					str=parseInt(str) + "";
				}
				return str;
			}
			return num + "";
		}

		/**格式化资源单位*/
		private static const RES_W:Array=["K", "M", "B", "T"]

		public static function formatResWith(num:Number):String
		{
			if (num >= 1000000000000)
			{
				return Math.floor(num / 1000000000000) + RES_W[3]
			}
			else if (num >= 1000000000)
			{
				return Math.floor(num / 1000000000) + RES_W[2]
			}
			else if (num >= 1000000)
			{
				return Math.floor(num / 1000000) + RES_W[1]
			}
			else if (num >= 10000)
			{
				return Math.floor(num / 1000) + RES_W[0]
			}
			return num + "";
		}

		public static function formatNumWithSign(num:Number, sign:String=","):String
		{
			num=Math.floor(num);
			var str:String=num + "";
			var index:int=1;
			var arr:Array=[];
			for (var i:int=str.length - 1; i >= 0; i--)
			{
				arr.push(str.charAt(i));
				if (index > 0 && index % 3 == 0)
				{
					arr.push(sign)
				}
				index++;
			}
			arr.reverse();
			if (arr[0] == sign)
			{
				arr.shift();
			}
			return arr.join("");
		}

		/**动画自动回收*/
		public static function autoRecyle(ani:Animation, recover:Boolean=false):void
		{
			ani.on(Event.COMPLETE, null, onComplete, [ani]);
			if (!ani.isPlaying)
			{
				ani.play(1, false);
			}

			function onComplete(ani:Animation):void
			{
				ani.off(Event.COMPLETE, null, onComplete);
				ani.stop();
				ani.removeSelf();
				if (recover)
				{
					Pool.recover("Animation", ani);
				}
			}
		}

		public static function createEllipse(sp:Graphics, x, y, a, b, stepScale:int=1, color='#ffffff')
		{
			var points:Array=[];
			var step=(a > b) ? stepScale / a : stepScale / b

			//step是等于1除以长轴值a和b中的较大者

			//i每次循环增加1/step，表示度数的增加

			//这样可以使得每次循环所绘制的路径（弧线）接近1像素

			for (var i=0; i < 2 * Math.PI; i+=step)

			{

				//x²/a²+y²/b²=1 (a>b>0)

				//参数方程为x = a * cos(i), y = b * sin(i)，

				//参数为i，表示度数（弧度）

				//var point=new Point(x+a*Math.cos(i),y+b*Math.sin(i));

				//points.push(point);
				points.push(x + a * Math.cos(i) - a / 2, y + b * Math.sin(i));

			}
			if (sp)
			{
				sp.drawPoly(points.shift(), points.shift(), points, color);
			}
			//trace("points---------------->>",points);
			return points;
		}

		/**根据语言ID及参数获取一条描述*/
		public static function getDesBy(lanId:*, arg:*):String
		{
			var str:String=GameLanguage.getLangByKey(lanId);
			str=str.replace(/{(\d+)}/, arg + "");
			return str;
		}

		/**
		 * 根据语言包里的参数替换文字并返回
		 * @param langId 语言包ID
		 * @param arr 下标是语言包中的标记，值为需要替换的文字
		 * @return 格式化好的文字
		 *
		 */
		public static function getStringByLang(langId:*, arr:Array):String
		{
			var str:String=GameLanguage.getLangByKey(langId);
			for (var id:* in arr)
			{
				str=str.replace(new RegExp("{(" + id + ")}", "g"), arr[id]);
			}
			return str;
		}
	}
}
