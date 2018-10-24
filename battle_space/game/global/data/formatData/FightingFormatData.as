/***
 *作者：罗维
 */
package game.global.data.formatData
{
	import laya.debug.tools.MathTools;
	
	//格式化后的战斗数据
	public class FightingFormatData
	{
		public var leftArmy:Array;  //左侧布阵
		public var rightArmy:Array; //右侧布阵
		public var reports:Object = {};  //战斗步骤
		public var reportKeys:Array = []; //步骤keys
		private var _unitList:Array;  //初始数据
		
		public function FightingFormatData(obj:Object)
		{
			if(!obj)
				return ;
			leftArmy = obj["initFightArmy"]["1"]["army"];
			rightArmy = obj["initFightArmy"]["2"]["army"];
			
			for (var key:* in obj.report) 
			{
				reportKeys.push(Number(key));
				var rd:ReportFormatData =  new ReportFormatData(obj.report[key],key);
				reports[key] = rd;
//				rd.reportkey = key;
				if(Number(key) == 0)
				{
					var subRd:SubReportFormatData = rd.subReport[rd.subKeys[0]];
					unitList = subRd.unitList;
					subRd.unitList = null;
				}
				reportKeys.sort(MathTools.sortSmallFirst);
			}	
		}
		
//		public function sortFun(v1:int,v2:int):int{
//			if(v1 > v2)
//				return 1;
//			if(v2 > v1)
//				return -1;
//			return 0;
//			
//		}

		public function get unitList():Array
		{
			if(_unitList)
			{
				for (var i:int = 0; i < _unitList.length; i++) 
				{
					var u:* = _unitList[i];
					if(u is String)
					{
						_unitList[i] = SubReportFormatData.formatUnit(u);
					}
				}
			}
			return _unitList;
		}

		public function set unitList(value:Array):void
		{
			_unitList = value;
		}

	}
}