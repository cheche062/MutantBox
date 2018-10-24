/***
 *作者：罗维
 */
package game.global.vo
{
	import game.global.fighting.manager.FightingSceneManager;
	import game.module.fighting.scene.FightingScene;
	
	import laya.maths.Point;
	

	public class SkillVo
	{
		public var skill_id:uint ; //技能ID
		public var skill_node:uint; //super技能ID
		public var skill_name:String;  //技能名称
		public var select_range:String; //可选攻击范围
		public var damage_range:String; //伤害范围
		public var damage_type:uint;   //技能释放效果
		public var skill_describe:String;
		public var skill_value:String;
		public var skill_icon:String;
		public var skill_level:String;
		public var skill_source:String;
		/**技能花费材料*/
		public var skill_consume:String;
		/**对应兵等级的限制*/
		public var skill_restrict:String;
		
		
		
		private var _selectRange:Array;
		private var _damageRange:Array;
		
		public function SkillVo()
		{
		}
		
		public function get iconUrl():String{
			return "appRes/icon/skillIcon/"+skill_icon+".png";
		}
		
		public function get damageRange():Array
		{
			if(!_damageRange)
			{
				_damageRange = [];
				if(damage_range)
				{
					var ar:Array = damage_range.split(",");
					for (var i:int = 0; i < ar.length; i++) 
					{
						var ar2:Array = ar[i].split("|");
						_damageRange.push(
							new Point(Number(ar2[0]), Number(ar2[1]))
						);
					}
				}
			}
			return _damageRange;
		}

		public function get selectRange():Array{
			if(!_selectRange)
			{
				_selectRange = [];
				if(select_range)
				{
					var ar:Array = select_range.split(",");
					for (var i:int = 0; i < ar.length; i++) 
					{
						var ar2:Array = ar[i].split("|");
						_selectRange.push(
							new Point(Number(ar2[0]), Number(ar2[1]))
						);
					}
				}
			}
			return _selectRange;
		}
		
		public function getDamageKeys(pstr:String ,selfK:String):Array{
			var rtAr:Array = [];
			if(!damageRange.length)
				return rtAr;
			var toPstr:String = pstr;
			//point_112
			var n1:Number = Number(toPstr.charAt(toPstr.length - 3));
			var n2:Number = Number(toPstr.charAt(toPstr.length - 2));
			var n3:Number = Number(toPstr.charAt(toPstr.length - 1));
			
			var selfn1:Number = Number(selfK.charAt(selfK.length - 3));
			var selfn2:Number = Number(selfK.charAt(selfK.length - 2));
			var selfn3:Number = Number(selfK.charAt(selfK.length - 1)); 
			
			var toN1:Number = n1;
//			var ktok:Object = selfK == 2 ? FightingSceneManager.rowLeftPointKey : FightingSceneManager.rowRightPointKey;
			var ktok:Object = selfn1 == 1 ? FightingSceneManager.rowLeftPointKey : FightingSceneManager.rowRightPointKey;
			
			for (var i:int = 0; i < damageRange.length; i++) 
			{
				var pi:Point = damageRange[i];
				var toN2:Number;
				
				if(!isSelfSkill)
				{
					toN2 = n2 + pi.x;
				}else
				{
					toN2 = n2 - pi.x;
				}
				
				
				if(toN2 >= FightingScene.squareColumn || toN2 <= 0)
					continue;
				
				var k2:*;
				for(var k:* in ktok)
				{
					if(ktok[k] == n3)
					{
						k2 = k;
					}
				}
				k2 = Number(k2);
				k2 += pi.y;
				if(!ktok.hasOwnProperty(k2))
				{
					continue;
				}
				var toN3:Number = ktok[k2];
				rtAr.push(
					"point_"+toN1+""+toN2+""+toN3
				);
			}
			return rtAr;
		}
		
		public function get isSelfSkill():Boolean{
			return [2,16,15].indexOf(damage_type) !=  -1
		}
		
		public function getSelectKeys(pstr:String):Array{
			var rtAr:Array = [];
			if(!selectRange.length)
				return rtAr;
			var toPstr:String = pstr;
			//point_112
			var n1:Number = Number(toPstr.charAt(toPstr.length - 3));
			var n2:Number = Number(toPstr.charAt(toPstr.length - 2));
			var n3:Number = Number(toPstr.charAt(toPstr.length - 1));
			
			var toN1:Number;
//			if(isSelfSkill)
//				toN1 = n1;
//			else
//				toN1 = n1 == 1 ? 2 : 1
			var ktok:Object = n1 == 1 ? FightingSceneManager.rowLeftPointKey : FightingSceneManager.rowRightPointKey;
			
			for (var i:int = 0; i < selectRange.length; i++) 
			{
				var pi:Point = selectRange[i];
				var toN2:Number;
//				if(isSelfSkill)
//					toN2 = (n2 + pi.x);
//				else
//					toN2 = (pi.x - n2) + 1;
//				if(toN2 <= 0 || toN2 > 3){
//					continue;
//				}
				
				toN2 = n2 - pi.x;
				
				if(toN2 > 3)
				{
					continue;
				}
				toN1 = (toN2 <= 0 && n1 == 2) || (toN2 > 0 && n1 == 1) ? 1:2;
				
				if(toN1 == n1 && !isSelfSkill)
				{
					continue;
				}
				
				if(toN2 <= 0)
				{
					toN2 = 0 - toN2 + 1;
				}
				
				if(toN2 > 3)
				{
					continue;
				}
				
				var k2:*;
				for(var k:* in ktok)
				{
					if(ktok[k] == n3)
					{
						k2 = k;
					}
				}
				k2 = Number(k2);
				k2 += pi.y;
				if(!ktok.hasOwnProperty(k2))
				{
					continue;
				}
				var toN3:Number = ktok[k2];
				rtAr.push(
					"point_"+toN1+""+toN2+""+toN3
				);
			}
			return rtAr;
		}
	}
}