package game.global.vo.friend
{
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;

	public class MailInfoVo
	{
		public var title:String;
		public var content:String;
		public var send_time:Number;
		public var attachment:String="";
		public var state:int;
		public var type:int;
		public var key:String;
		public function MailInfoVo()
		{
		}
		
		public function getItemList():Array
		{
			var l_arr:Array=new Array();
			if(attachment!=null &&attachment!="")
			{
				var l_attArr:Array=attachment.split(";");
				for(var i:int=0;i<l_attArr.length;i++)
				{
					var l_itemArr:Array=l_attArr[i].split("=")
					var l_itemData:ItemData=new ItemData();
					l_itemData.iid=l_itemArr[0];
					l_itemData.inum=l_itemArr[1];
					l_arr.push(l_itemData);
				}
			}
			
			return l_arr;
		}
		
	}
}