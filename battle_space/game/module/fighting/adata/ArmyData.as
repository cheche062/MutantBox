/***
 *作者：罗维
 */
package game.module.fighting.adata
{
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.vo.FightUnitVo;
	import game.global.vo.heroUsedVo;
	import game.module.camp.CampData;

	public class ArmyData
	{
		public var unitId:uint;  //兵种ID
		public var num:Number;  //可出战数量
		public var maxNum:Number ;  //总数量
		public var save:Number;  //死亡结束时间
		public var state:Number = 0;  //服务器状态
		public var wyid:String = ""; //
		public var hp:Number;
		public var maxHp:Number;
		public var limit:Number;
		//是否需要禁用
		public var disabled:Boolean=false;
		
		
		public var lcState:uint;  //本地状态
		public var state2:Number = 0; //客户端状态
		
		
		public static const STATE_NOT_ADD:Number = 7;  //不可以再上了
		public static const STATE_NOT_NUMBER:Number = 8; //数量0
 		
		public function ArmyData()
		{
		}
		
		public function get unitVo():FightUnitVo{
			return GameConfigManager.unit_dic[unitId];
		}
		
		public function get serverData():Object{
			return CampData.getUintById(unitId);
		}
		
		public static function create(data:Object):ArmyData 
		{
			var rt:ArmyData = new ArmyData();
			rt.unitId = data.id;
			rt.num = rt.maxNum =  data.num;
			rt.save = data.save;
			rt.state = data.state;
			rt.hp = data.hp;
			rt.maxHp = data.maxHp;
			if(!rt.hp)
				rt.hp = 1;
			if(!rt.maxHp)
				rt.maxHp = 1;
			rt.wyid = data.uniqueId ? data.uniqueId:"";
			
			if(data.limit)
				rt.limit = Number(data.limit);
			
			return rt;
		}
		
		public function copy():ArmyData{
			var rt:ArmyData = new ArmyData();
			rt.unitId = unitId
			rt.num =  num;
			rt.maxNum = maxNum;
			rt.save = save;
			rt.state = state;
			rt.hp = hp;
			rt.maxHp = maxHp;
			rt.wyid = wyid;
			rt.limit = limit;
			
			return rt;
		}
		
		
		public static function armySort(a1:ArmyData,a2:ArmyData):Number{
			var uLel1:Object = a1.serverData;
			var uLel2:Object = a2.serverData;
			if(uLel1 || uLel2)
			{
				if(uLel1 && !uLel2) return -1;
				if(!uLel1 && uLel2) return 1;
			}
			
			
			var _isH1:Number = a1.unitVo.isHero ? 1 : 0;
			var _isH2:Number = a2.unitVo.isHero ? 1 : 0;
			if(_isH1 < _isH2) return 1;   //英雄在前面
			if(_isH1 > _isH2) return -1;  
			
			var _state1:Number = a1.state ? a1.state : a1.state2;
			var _state2:Number = a2.state ? a2.state : a2.state2;
			
			var n1:Number = _state1 ? 1 : 0;
			var n2:Number = _state2 ? 1 : 0;
			if(n1 > n2) return 1;   //有状态在前面
			if(n1 < n2) return -1;  
			
			if(n1)  //有状态
			{
				var huv1:heroUsedVo = GameConfigManager.heroUseds[_state1];
				var huv2:heroUsedVo = GameConfigManager.heroUseds[_state2];
				if(huv1.rank < huv2.rank) return 1;   //状态排序小的在前面
				if(huv1.rank > huv2.rank) return -1;
			}else
			{
				var power1:Number = uLel1 ? Number(uLel1.power) : 0;
				var power2:Number = uLel2 ? Number(uLel2.power) : 0;
				if(power1 < power2) return 1;   //力量高的在前面
				if(power1 > power2) return -1;
			}
			return 0;
		}
		
		/**获取先详细信息*/
		public function getInfoObj():Object {
			var starId:String = this.serverData ? this.serverData.starId : this.unitVo.star_id;
			var vo:Object = (DBUnitStar.getStarData(starId) || {});
			
			var attack:Number = this.serverData ? this.serverData.attack : 0;
			attack = Math.ceil(attack || vo.ATK)+"";
			
			var crit:Number = this.serverData ? this.serverData.crit : 0;
			crit = Math.ceil(crit || vo.crit) +"";
			
			var critDamage:Number = this.serverData ? this.serverData.critDamage : 0;
			critDamage = Math.ceil(critDamage || vo.CDMG)+"";
			
			var critDamReduct:Number = this.serverData ? this.serverData.critDamReduct : 0;
			critDamReduct = Math.ceil(critDamReduct|| vo.CDMGR)+"";
			
			var defense:Number = this.serverData ? this.serverData.defense : 0;
			defense = Math.ceil(defense || vo.DEF)+"";
			
			var dodge:Number = this.serverData ? this.serverData.dodge : 0;
			dodge = Math.ceil(dodge || vo.dodge)+"";
			
			var hit:Number = this.serverData ? this.serverData.hit : 0;
			hit = Math.ceil(hit || vo.hit)+"";
			
			var hp:Number = this.serverData ? this.serverData.hp : 0;
			hp = Math.ceil(hp || vo.HP)+"";
			
			var resilience:Number = this.serverData ? this.serverData.resilience : 0;
			resilience = Math.ceil(resilience || vo.RES)+"";
			
			var speed:Number = this.serverData ? this.serverData.speed : 0;
			speed = Math.ceil(speed || vo.SPEED)+"";
			
			var level:Number = this.serverData ? this.serverData.level : 1;
			level = GameLanguage.getLangByKey("L_A_73") + level;
			
			return {
				vo: vo,
				attack: attack,
				crit:crit,
				critDamage: critDamage,
				critDamReduct: critDamReduct,
				defense: defense,
				dodge: dodge,
				hit: hit,
				hp: hp,
				resilience: resilience,
				speed: speed,
				level: level
			}
		}
		
		public function getActNum():int {
			var tmp:Array = (unitVo.condition+"").split("|");
			for(var j:String in tmp){
				if((tmp[j]+"").indexOf("B") == -1){
					tmp = (tmp[j]+"").split("=");
					return tmp[1];
				}
			}
			return 0;
		}
		
		/**获取技能的类型  1：主动技能   2：被动技能*/
		public static function getSkillType(skillId):int{
			if (GameConfigManager.unit_skill_dic[skillId]) return 1;
			if (DBSkill2.getSkillInfo(skillId)) return 2;
			return 0;
		}
		
		/**通过技能id来获取技能等级  1：主动技能   2：被动技能*/
		public static function getLevelBySkillId(skillId):int{
			var _data = GameConfigManager.unit_skill_dic[skillId] || DBSkill2.getSkillInfo(skillId);
			if (_data) return _data["skill_level"];
			return 0;
		}
		
		
		
		
		
		
		
		
		
	}
}