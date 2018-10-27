package game.global.vo.equip
{
	import game.global.data.bag.ItemData;

	public class EquipmentListVo
	{
		public var equip:int;
		public var level:int;
		public var suit:int;
		public var quality:int;
		public var location:int;
		public var resolve:String;
		public var attribute:String;
		public var strong_att:String;
		public var streng_id:int;
		public var hero:int;
		public function EquipmentListVo()
		{
		}
		
		public function getAttr():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=attribute.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length==0)
			{
				var l_str:String=attribute;
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
				
			}
			
			
			return l_arr;
		}
		
		public function getStrongAttr():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=strong_att.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length==0)
			{
				var l_str:String=strong_att;
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
				
			}
			return l_arr;
			
			
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