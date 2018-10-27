/***
 *作者：罗维
 */
package game.global.vo
{
	import game.global.GameConfigManager;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingSceneManager;
	import game.module.camp.CampData;
	import game.module.camp.avatar.DBSkin;
	import game.module.camp.avatar.SkinVo;
	import game.module.fighting.scene.FightingScene;
	
	import laya.maths.Point;

	public class FightUnitVo
	{
		public var unit_id :uint;  //ID
		public var unit_type:uint;  //type
		public var attack_type:uint; //攻击类型（1爆炸，2穿透，3普通，4近战）
		public var name:String;  //name
		public var defense_type:uint; //护甲类型 （1重甲，2中甲，3轻甲，4无甲）
		public var MOV:uint;   //移动距离
		public var skill_id:String;  //技能ID
		public var skill2_id:String;  //被动技能ID
		public var model:String; //模型
		public var hitArea_points:String;  //
		public var population:uint;  //人口数
		public var num_limit:uint;//上阵人口限制
		public var rarity:uint;  //稀有度
		public var up:Number = 0; 
		public var down:Number = 0;
		public var initial_star:uint=0;
		public var star:uint=0;
		public var num:uint = 0;
		public var condition:String;
		public var unit_son_type:uint;
		public var visible:uint;
		public var br:Number = 0;
		public var star_id:Number = 0;
		public var camp:*;
		/**兵种属性*/
		public var HP:int;
		public var ATK:int;
		public var DEF:int;
		public var SPEED:int;
		public var hit:int;
		public var dodge:int;
		public var crit:int;
		public var RES:int;
		public var CDMG:int;
		public var CDMGR:int;
		
		public var feature:String;
		
							
		//训练时间-分钟
		public var unit_training_time:String;
		private var _hitAreaPoints:HitAreaData;
		
		
		/**常量-类型-英雄*/
		public static const HERO:int = 1;
		/**常量-类型-小兵*/
		public static const SOLDIER:int = 2;
		/**常量-类型-伤害道具*/
		public static const BADITEM:int = 3;
		/**常量-类型-加益道具*/
		public static const GOODITEM:int = 4;
		/**常量-类型-建筑*/
		public static const BUILDING:int = 6;
		
		/**常量-类型-BOSS*/
		public static const BOSS:int = 9;
		
		
		
		
		
		
		public function FightUnitVo()
		{
		}
		
		
		//是否是英雄
		public function get isHero():Boolean{
			return unit_type == HERO;
		}
		//是否是士兵
		public function get isSoldier():Boolean{
			return unit_type == SOLDIER;
		}
		//是否是道具
		public function get isItem():Boolean{
			return unit_type == BADITEM || unit_type == GOODITEM;
		}
		//是否是建筑
		public function get isBuilding():Boolean{
			return unit_type == BUILDING;
		}
		//是否是BOSS
		public function get isBoss():Boolean{
			return unit_type == BOSS;
		}
		
		//是否是伤害道具
		public function get isBadItem():Boolean{
			return unit_type == BADITEM ;
		}
		//是否是加益道具
		public function get isGoodItem():Boolean{
			return unit_type == GOODITEM ;
		}
		
		//映射道具
		public function get itemVo():ItemVo{
			if(!isItem) return null;
			if(!condition) return null;
			GameConfigManager.items_dic[condition];
		}
		
		//能被攻击
		public function get isAttack():Boolean{
			return unit_son_type == 1;
		}
		
		private var _skillVos:Array;
		public function get skillVos():Array{
			if(!_skillVos)
			{
				_skillVos = [];
				var skillids:Array = skill_id.split("|");
				for (var i:int = 0; i < skillids.length; i++) 
				{
					var skill:SkillVo = GameConfigManager.unit_skill_dic[skillids[i]];
					if(skill)
					{
						_skillVos.push(skill);
					}
				}
			}
			return _skillVos;
		}
			
		
		public function get hitAreaPoints():HitAreaData
		{
			if(!_hitAreaPoints)
			{
//				hitArea_points = "968,570,935,557,948,539,960,521,973,496,943,491,938,466,946,444,963,
//				431,979,415,1004,400,1027,407,1041,423,1043,451,1033,472,1019,489,1002,502,1000,530,1015,546,974,558";
				if(!hitArea_points || !hitArea_points.length)
					return null;
				
				_hitAreaPoints = new HitAreaData();
				var ar:Array = hitArea_points.split(",");
				if(ar.length >= 2)
				{
					_hitAreaPoints.beginX = Number(ar.shift());
					_hitAreaPoints.beginY = Number(ar.shift());
					
					
					while(ar.length >= 2)
					{
						_hitAreaPoints.pointS.push( Number(ar.shift()) - _hitAreaPoints.beginX);
						_hitAreaPoints.pointS.push( Number(ar.shift()) - _hitAreaPoints.beginY);
					}
				}
			}
			return _hitAreaPoints;
		}
		
		private var _movePoints:Array;
		public function get movePoints():Array
		{
			if(!_movePoints){
				_movePoints = [];
				for (var i:int = 0; i <= MOV; i++) 
				{
					for (var j:int = 0; j <= MOV; j++) 
					{
						if(i + j <= MOV && (i || j))
						{
							_movePoints.push(new Point(i,j));
							_movePoints.push(new Point(0 - i,j));
							_movePoints.push(new Point(0 - i, 0 - j));
							_movePoints.push(new Point(i, 0 - j));
						}
					}
				}
				
			}
			return _movePoints;
		}
		
		public function getMoveKeys(pstr:String):Array
		{
			var rtAr:Array = [];
			if(!movePoints.length)
				return rtAr;
			var toPstr:String = pstr;
			//point_112
			var n1:Number = Number(toPstr.charAt(toPstr.length - 3));
			var n2:Number = Number(toPstr.charAt(toPstr.length - 2));
			var n3:Number = Number(toPstr.charAt(toPstr.length - 1));
			var toN1:Number = n1;
			var ktok:Object = FightingSceneManager.rowLeftPointKey;
			for (var i:int = 0; i < movePoints.length; i++) 
			{
				var pi:Point = movePoints[i];
				if(pi.x == 0 && pi.y==0)
					continue;
				
				var toN2:Number = n2 + pi.x;
				if(toN2 <= 0 || toN2 >= FightingScene.squareColumn)
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
		
		private var _featureAr:Array;
		public function get featureAr():Array{
			if(_featureAr) return _featureAr;
			_featureAr = [];
			if(feature && feature.length)
			{
				var ar:Array = feature.split("|");
				for (var i:int = 0; i < ar.length; i++) 
				{
					var ar2:Array = ar[i].split("=");
					var ar3:Array = ar2[1].split(",");
					for (var j:int = 0; j < ar3.length; j++) 
					{
						_featureAr.push({
							id:ar3[j],
							lv:ar2[0]
						});
					}
					
				}
				
			}
			return _featureAr;
		}
		
		
		/**获取模型地址*/
		public function getModel(direction:Number, action:String, skinID:String):String{
			if(isItem)
				action = BaseUnit.ACTION_HOLDING;
			
			//皮肤
			if(skinID){
				var skinVo:SkinVo = DBSkin.getSkin(skinID);
				if(skinVo && skinVo.garde > 0){
					return "appRes/heroModel/" + skinID + ( direction == 1 ?"/up/":"/down/") +action+".json";
				}
			}
			/**
			var heroVo:Object = CampData.getUintById(unit_id);
			if(heroVo && heroVo.skin){
				var skinVo:SkinVo = DBSkin.getSkin(heroVo.skin);
				if(skinVo && skinVo.garde > 0){
					return "appRes/heroModel/" + skinVo.ID + ( direction == 1 ?"/up/":"/down/") +action+".json";
				}
			}
			 */
			return "appRes/heroModel/" + model + ( direction == 1 ?"/up/":"/down/") +action+".json";
		}
	}
}