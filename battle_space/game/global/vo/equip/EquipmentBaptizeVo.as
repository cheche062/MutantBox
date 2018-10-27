package game.global.vo.equip
{
	import game.global.data.bag.ItemData;

	public class EquipmentBaptizeVo
	{
		public var id:int;
		public var level:int;
		public var quality:int;
		public var attr:String;
		public var cost:String;
		public var cost1:String;
		public var cost2:String;
		
		public function EquipmentBaptizeVo()
		{
		}
		
		public function getAttr():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=attr.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.max=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			return l_arr;
		}
		
		public function getCost(p_type:int):Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=new Array();
			if(p_type==0)
			{
				l_attArray.push(cost);
				
			}
			else if(p_type==1)
			{
				l_attArray=cost1.split(";");
				
			}
			else if(p_type==2)
			{
				l_attArray=cost2.split(";");
			}
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:ItemData=new ItemData();
				l_vo.iid=l_str.split("=")[0];
				l_vo.inum=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			return l_arr;
		}
	}
}