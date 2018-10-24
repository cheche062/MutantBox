package game.global.data.formatData
{
	public class AttackFormatTagetData
	{
		
		public var tagetPos:String;
		public var addHp:Array;
		public var delHp:Array;
		
		public var isCritHit:Boolean;  //暴击
		/**
		 * 闪避
		 */
		public var isDodged:Boolean;  //
		/**
		 * 无敌
		 */
		public var isInvincible:Boolean;  //
		/**
		 * 吸收
		 */
		public var isAbsorbed:Boolean;  //
		public var newPos:String;        //新位置
		public var newHp:Array;           //新血量
		public var newBuff:Array;          //新增BUFF
		public var allBuff:Array;        //最新BUFF列表
		public var newUnit:Object;    //变身
		public var skill2:Array;   //触发被动
		public var addUnit:Array;
		
		
		public function AttackFormatTagetData(obj:Object)
		{
			if(obj.hasOwnProperty("originPos"))
				tagetPos = obj.originPos;
			if(obj.hasOwnProperty("addHp"))
				addHp = obj.addHp.concat();
			if(obj.hasOwnProperty("subHp"))
				delHp = obj.subHp.concat();
			if(obj.hasOwnProperty("bj"))
				isCritHit = Number(obj.bj) as Boolean;
			if(obj.hasOwnProperty("sb"))
				isDodged = Number(obj.sb) as Boolean;
			if(obj.hasOwnProperty("wd"))
				isInvincible = Number(obj.wd) as Boolean;
			if(obj.hasOwnProperty("xs"))
				isAbsorbed = Number(obj.xs) as Boolean;
			if(obj.hasOwnProperty("pos"))
				newPos = obj.pos;
			if(obj.hasOwnProperty("newHp"))
				newHp = obj.newHp;
			if(obj.hasOwnProperty("newBuff"))
				newBuff = obj.newBuff;
			if(obj.hasOwnProperty("allBuff"))
				allBuff = obj.allBuff;
			if(obj.hasOwnProperty("varyUnit"))
				newUnit = obj.varyUnit;
			if(obj.hasOwnProperty("skill2"))
				skill2 = obj.skill2;
			if(obj.hasOwnProperty("addUnit"))
				addUnit = obj.addUnit;
		}
	}
}