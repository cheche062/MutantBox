package game.global.vo.equip
{
	import laya.ani.bone.Bone;

	public class EquipParamVo
	{
		public var openStrongLevel:String;
		public var openWashLevel:String;
		public var openResolveLevel:String;
		
		public function EquipParamVo()
		{
		}
		
		public function getOpenStrongLevel():Array
		{
			var l_arr:Array=openStrongLevel.split("=");
			return l_arr;
		}
		
		public function getOpenWashLevel():Array
		{
			var l_arr:Array=new Array();
			l_arr.push(100);
			l_arr.push(parseInt(openWashLevel));
			return l_arr;
		}
		
		public function getOpenResolveLevel():Array
		{
			var l_arr:Array=new Array();
			l_arr.push(100);
			l_arr.push(parseInt(openResolveLevel));
			return l_arr;
			
		}
	}
}