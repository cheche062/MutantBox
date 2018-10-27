package game.global.vo.equip
{
	public class EquipmentSuitVo
	{
		public var suit:int;
		public var attr2:String;
		public var attr4:String;
		public var attr6:String;
		public var name:String;
		public function EquipmentSuitVo()
		{
		}
		
		public function getAttr2():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=attr2.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length<0)
			{
				var l_str:String=attr2;
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			
			return l_arr;
		}
		
		public function getAttr4():Array
		{
			var l_arr:Array=new Array();
			var l_attArray:Array=attr4.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length<0)
			{
				var l_str:String=attr4;
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			return l_arr;
		}
		
		public function getAttr6():Array
		{
			var l_arr:Array=new Array();
			if(attr6==null)
			{
				return l_arr;
			}
			var l_attArray:Array=attr6.split(";");
			for (var i:int = 0; i < l_attArray.length; i++) 
			{
				var l_str:String=l_attArray[i];
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			if(l_attArray.length<0)
			{
				var l_str:String=attr6;
				var l_vo:AttVo=new AttVo();
				l_vo.name=l_str.split("=")[0];
				l_vo.num=l_str.split("=")[1];
				l_arr.push(l_vo);
			}
			return l_arr;
		}
	}
}