package game.global.data.formatData
{
	import laya.ui.Image;
	import laya.ui.Tab;

	public class AttackFormatData
	{
		public var skillId:Number;   //技能ID
		public var fightUnitId:Number;  //出手对象ID
		public var tagetPos:String;    //主目标
		public var secondaryPos:Array;   //次要目标
		public var sputteringPos:Array;   //溅射目标
		
		//出手者
		public var fightUnitData:Object;   
		//影响者
		public var impactArray:Array;
		//自身影响
		public var mainImpact:AttackFormatTagetData;
		
		//被动buff额外数据
//		public var passiveBuffData:Array;
		
		public function get allPos():Array{
			var arr:Array = [];
			if(tagetPos)
				arr.push(tagetPos);
			if(secondaryPos)
				arr = arr.concat(secondaryPos);
			if(sputteringPos)
				arr = arr.concat(sputteringPos);
			return arr;
		}
		
		public  static function  getPassiveAttackFormatData(obj:Object):AttackFormatData{
			var afd:AttackFormatData = new AttackFormatData();
			afd.skillId = obj.skillId;
//			afd.tagetPos = obj.tagetPos;
			
			afd.fightUnitData = {
				originPos:obj.tagetPos
			};
			
			afd.impactArray = [];
			var ar:Array = obj.impactArray;
			var pos:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
				var ar2:Array = ar[i];
				var ar3:Array = [];
				afd.impactArray.push(ar3);
				
				for (var j:int = 0; j < ar2.length; j++) 
				{
					var aftd:AttackFormatTagetData = new AttackFormatTagetData(ar2[j]);
					ar3.push(aftd);
					if(pos.indexOf(aftd.tagetPos) == -1)
						pos.push(aftd.tagetPos);
				}
			} 
			afd.tagetPos = pos.shift();
			afd.secondaryPos = pos;
			return afd;
		}
		
		//被动技能的
		public static function createBD(obj:Object = null):AttackFormatData
		{
			if(!obj)return null;
			
			var rt:AttackFormatData = new AttackFormatData();
			rt.skillId = Number(obj.sid);
			//出手者
			rt.fightUnitData = {
				originPos:obj.p
			};
//			rt.secondaryPos 
//			rt.tagetPos;
			if(obj.te)
			{
				var ar:Array = [];
				rt.impactArray = [ar];
				for (var j:int = 0; j < obj.te.length; j++) 
				{
					var atd:AttackFormatTagetData = new AttackFormatTagetData(obj.te[j]);
					ar.push(atd);
					if(!j)
					{
						rt.tagetPos = atd.tagetPos;
					}else
					{
						rt.secondaryPos	||= [];
						rt.secondaryPos.push(atd.tagetPos);
					}
				}
			}
			return rt;
		}
		
		
		public function AttackFormatData(obj:Object = null)
		{
			
			if(!obj)return ;
			
			skillId = Number(obj.skillId);
			fightUnitId = Number(obj.unitId);
			tagetPos = obj.targetPos;
			secondaryPos = obj.damagePos;
			sputteringPos = obj.spurtingPos;
			
			//出手者
			fightUnitData = {
				originPos:obj.originPos
			};
			
			if(!obj.attack)
			{
			trace("错误断点");
			}
			if(obj.attack && obj.attack.te)
			{
				impactArray = [];
				var ar:Array = obj.attack.te;
				for (var i:int = 0; i < ar.length; i++) 
				{
					var ar2:Array = ar[i];
					var ar3:Array = [];
					impactArray.push(ar3);
					
					for (var j:int = 0; j < ar2.length; j++) 
					{
						ar3.push( new AttackFormatTagetData(ar2[j]));
					}
				}
				
			}
			if(obj.attack && obj.attack.fe)
			{
				mainImpact = new AttackFormatTagetData(obj.attack.fe);
			}
			
			
		}
	}
}