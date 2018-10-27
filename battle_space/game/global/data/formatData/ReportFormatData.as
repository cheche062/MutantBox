/***
 *作者：罗维
 */
package game.global.data.formatData
{
	//大回合
	public class ReportFormatData
	{
		public var reportkey:*;   //大回合键值
		public var subKeys:Array = [];  //子回合键值
		public var subReport:Object = {};
		
		public function ReportFormatData(obj:Object , _reportkey:* = null)
		{
			if(!obj)
				return ;
			if(_reportkey)
				reportkey = _reportkey;			
			for (var key:* in obj) 
			{
				var subRd:SubReportFormatData = new SubReportFormatData(obj[key]);
				subKeys.push(Number(key));
				subReport[key] = subRd;
				subRd.reportkey = reportkey;
			}
			subKeys.sort(sortFun);
		}
		
		public function sortFun(v1:int,v2:int):int{
			if(v1 > v2)
				return 1;
			if(v2 > v1)
				return -1;
			return 0;
			
		}
	}
}