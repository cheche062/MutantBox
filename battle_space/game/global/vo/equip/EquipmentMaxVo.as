package game.global.vo.equip
{
	public class EquipmentMaxVo
	{
		public var id:int;
		public var level:int;
		public var quality:int;
		public var attr:String;
		
		public function EquipmentMaxVo()
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
	}
}