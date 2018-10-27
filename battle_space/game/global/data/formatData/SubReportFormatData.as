/***
 *作者：罗维
 */
package game.global.data.formatData
{
	public class SubReportFormatData
	{
		public var reportkey:*;   //大回合键值
		public var before:Object; //回合开始移动
		public var after:Object;  //回合结束移动
		
		public var beforeStart:Object; //出场全体移动
		public var afterHHKS:Object; //下回合开始后全体移动
		
		public var fighter:Object;  //回合主攻方
		public var damagePos:Array;  //被打响应范围
//		public var attacks:Array;
//		public var surrenal:Array;  //回合主攻方
//		public var targets:Array;  //被打的对象
		
		public var unitList:Array; //回合结束位移数据
		
		public var posHurt:Object;
		public var posEvent:Object;
		public var buffUpdate:Object;
		public var startBuffUpdate:Object;
		public var addUnit:Array;
		
		public var hhks:Array;  //回合开始
		public var hhjs:Array;  //回合结束
		
		public var start:Array; //战斗开始数据 
		
		public var csq:Array;  //出手前
		public var csh:Array;  //出手后
		public var replenish:Array; //补兵
		
		public var nextRound:Number = 0;
		
		public var disposeUid:String = "";
		
		
		public function SubReportFormatData(obj:Object)
		{
			if(!obj)
				return ;
			if(obj.hasOwnProperty("allForward"))
			{
				var allForwardObj:Object = obj["allForward"];
				if(allForwardObj.hasOwnProperty("before"))
				{
					before = allForwardObj["before"];
				}
				if(allForwardObj.hasOwnProperty("after"))
				{
					after = allForwardObj["after"];
				}
				if(allForwardObj.hasOwnProperty("beforeStart"))
				{
					beforeStart = allForwardObj["beforeStart"];
				}
				if(allForwardObj.hasOwnProperty("afterHHKS"))
				{
					afterHHKS = allForwardObj["afterHHKS"];
				}
			}
			if(obj.hasOwnProperty("unitList"))
			{
				unitList =  obj["unitList"];
				
				for (var i:int = 0; i < unitList.length; i++) 
				{
					var u:* = unitList[i];
					if(u is String)
					{
						unitList[i] = formatUnit(u);
					}
				}
			}
			if(obj.hasOwnProperty("damagePos"))
			{
				damagePos = obj["damagePos"];
			}
			if(obj.hasOwnProperty("fighter"))
			{
				fighter = obj["fighter"];
			}
			
			if(obj.hasOwnProperty("hhks"))
			{
				hhks = obj["hhks"];
			}
			
			if(obj.hasOwnProperty("hhjs"))
			{
				hhjs = obj["hhjs"];
			}
			if(obj.hasOwnProperty("start"))
			{
				start = obj["start"];
			}
			
			
			
			if(obj.hasOwnProperty("csq"))
			{
				csq = obj["csq"];
			}
			
			if(obj.hasOwnProperty("csh"))
			{
				csh = obj["csh"];
			}
			
			if(obj.hasOwnProperty("replenish")){
				replenish = obj["replenish"]
			}
			
//			if(obj.hasOwnProperty("surrenal")){
//				surrenal = obj["surrenal"];
//			}
			if(obj.hasOwnProperty("posHurt")){
				posHurt = obj["posHurt"];
			}
			if(obj.hasOwnProperty("posEvent")){
				posEvent = obj["posEvent"];
			}
			if(obj.hasOwnProperty("buffUpdate")){
				buffUpdate = obj["buffUpdate"];
			}
			if(obj.hasOwnProperty("startBuffUpdate")){
				startBuffUpdate = obj["startBuffUpdate"];
			}
			
			if(obj.hasOwnProperty("addUnit")){
				addUnit = obj["addUnit"];
			}
			if(obj.hasOwnProperty("nextRound")){
				nextRound = Number(obj.nextRound);
			}
			if(obj.hasOwnProperty("disposeUid")){
				disposeUid = String(obj.disposeUid);
			}
			
			
		}
		
		public static function formatUnit(s:String):Object
		{
			var obj:Object = {};
			var ar:Array  = s.split("|");
			obj.unitType = ar[0];
			obj.unitId = ar[1];
			obj.pos = ar[2];
			var skillCD:Array = [];
			obj.skillCD = skillCD;
			var ar2:Array = ar[3].split(",");
			for (var i:int = 0; i < ar2.length; i++) 
			{
				var ar3:Array = ar2[i].split("*");
				var skill:Object = {};
				skill.sId = ar3[0];
				skill.cd = [Number(ar3[1]),Number(ar3[2])];
				skillCD.push(skill);
			}
			
			return obj;
		}
	
		public function copy():SubReportFormatData
		{
			var rt:SubReportFormatData = new SubReportFormatData(null);
			rt.before = this.before;
			rt.after = this.after;
			rt.damagePos = this.damagePos;
			rt.unitList = this.unitList;
//			rt.surrenal = this.surrenal;
			rt.posHurt = this.posHurt;
			rt.fighter = this.fighter;
			rt.posEvent = this.posEvent;
			rt.buffUpdate = this.buffUpdate;
			rt.startBuffUpdate = this.startBuffUpdate;
			rt.addUnit = this.addUnit;
			rt.hhjs = this.hhjs;
			rt.hhks = this.hhks;
			rt.csq = this.csq;
			rt.csh = this.csh;
			rt.beforeStart = this.beforeStart;
			rt.nextRound = this.nextRound;
			rt.afterHHKS = this.afterHHKS;
			rt.start = this.start;
			rt.disposeUid = this.disposeUid;
			rt.replenish = this.replenish;
			return rt;
		}
	}
}