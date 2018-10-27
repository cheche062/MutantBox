package game.global.vo.equip
{
	import game.global.data.bag.ItemData;

	public class EquipmentIntensifyVo
	{
		public var id:int;
		public var node_id:int;
		public var level:int;
		public var cost:String;
		public var resolve:String;
		
		public function EquipmentIntensifyVo()
		{
		}
		
		public function getCost():int
		{
			var l_arr:Array=cost.split("=");
			return l_arr[1];
		}
		
		public function getCostId():int
		{
			var l_arr:Array=cost.split("=");
			return l_arr[0];
		}
		
		public function getResolve():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=resolve.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:ItemData=new ItemData();
				l_vo.iid=l_str.split("=")[0];
				l_vo.inum=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length==0)
			{
				var l_str:String=resolve;
				var l_vo:ItemData=new ItemData();
				l_vo.iid=l_str.split("=")[0];
				l_vo.inum=l_str.split("=")[1];
				l_arr.push(l_vo);
				
			}
			return l_arr;
		}
		
		
	}
}