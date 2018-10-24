package game.global.data
{
	import game.common.ResourceManager;
	
	import laya.debug.tools.MathTools;

	/**
	 * DBUintUpgradeExp 升级经验配置
	 * author:huhaiming
	 * DBUintUpgradeExp.as 2017-3-17 下午5:03:43
	 * version 1.0
	 *
	 */
	public class DBUintUpgradeExp
	{
		private static var _data:Object;
		/**类型-士兵*/
		public static const TYPE_SOLDIER:int = 0
		/**类型-英雄*/
		public static const TYPE_HERO:int = 1;
		public function DBUintUpgradeExp()
		{
		}
		
		/**
		 * 获取升级经验
		 * @param lv 等级
		 * @param type 类型，常量定义在DBUintUpgradeExp中
		 * @param rarity 稀有度
		 */
		public static function getLvExp(lv:int, type:Number,rarity:int):Number{
			var info:Object = data[lv];
			if(info){
				if(type == TYPE_SOLDIER){
					return Number(info["soldier_exp"+rarity]);
				}else if(type == TYPE_HERO){
					return Number(info["hero_exp"+rarity]);
				}
			}
			return 0;
		}
		
		
		/**
		 *获取配置表总级别 
		 */
		private static var _maxLevel:Number;
		public static function get maxLevel():Number{
			
			if(!_maxLevel)
			{
				var lvs:Array = [];
				for(var k:String in data)
				{
					lvs.push(Number(k));
				}
				lvs.sort(MathTools.sortSmallFirst);
				_maxLevel = lvs.pop();
			}
			return _maxLevel;
		}
		
		
		/**
		 *根据总经验获取当前级别当前经验
		 * allExp  总的经验值
		 * 返回值：Object  level 当前级别  exp 当前经验 lexp 当前级别需要经验
		 */
		public static function getLevelAndExpByAllExp(allExp:Number,type:Number,rarity:Number):Object
		{
			var rt:Object = {
				level:1,
				exp:0,
				lexp:getLvExp(1,type,rarity)
			};
			for (var i:int = 1; i <= maxLevel; i++) 
			{
				var exp2:Number = getLvExp(i,type,rarity);
				if(exp2 > allExp)
				{
					rt.exp = allExp;
					rt.lexp = exp2;
					return rt;
				}else if(i == maxLevel)
				{
					rt.exp = rt.lexp = exp2;
					return rt;
				}
				else{
					rt.level++;
					allExp -= exp2;
				}
			}
			
			return rt;
		}
		
		/**
		 *根据当前级别当前经验获取总经验
		 * level  当前级别 exp当前经验
		 * 返回值：总经验
		 */
		public static function getAllExpByLevelAndExp(level:Number,exp:Number,type:Number,rarity:Number):Number
		{
			var allexp:Number = 0;
			level = level > maxLevel ? maxLevel : level;
			for (var i:int = 1; i <= level; i++) 
			{
				if(i == level)
					allexp += exp;
				else	
			 		allexp += getLvExp(i,type,rarity);
			}
			return allexp;
		}
		
		
		private static function get data():Object{
			if(!_data){
				_data = ResourceManager.instance.getResByURL("config/unit_upgrade_exp.json"); 
			}
			return _data;
		}
	}
}