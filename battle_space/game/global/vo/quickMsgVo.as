package game.global.vo
{
	public class quickMsgVo
	{
		public var id:Number = 0;
		public var icon:String;
		public var name:String;
		public var content:String;
		
		public function quickMsgVo()
		{
		}
		
		public function get iconPath():String{
			return "appRes/icon/msgIcon/"+icon+".png";
		}
	}
}