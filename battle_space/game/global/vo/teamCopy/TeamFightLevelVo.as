package game.global.vo.teamCopy
{
	import game.global.data.bag.ItemData;

	public class TeamFightLevelVo
	{
		public var id:int;
		public var level_down:int;
		public var level_up:int;
		public var zxjl:String;
		public var xsdj:int;
		public var zsghjl:String;
		public var rq_second1:String;
		public var rq_text1:String;
		public var double:int;
		
		
		public function TeamFightLevelVo()
		{
		}
		
		public function getRewardList():Array
		{
			var l_arr:Array=zxjl.split(";");
			trace("zxjl:"+zxjl);
			var l_rewardList:Array=new Array();
			
			for (var i:int = 0; i < l_arr.length; i++) 
			{
				var l_str:String=l_arr[i];
				var l_arr1:Array=l_str.split("=");
				var itemdata:ItemData=new ItemData();
				itemdata.iid=l_arr1[0];
				itemdata.inum=l_arr1[1];
				l_rewardList.push(itemdata);
			}
			trace("l_rewardList.length:"+l_rewardList.length);
			return l_rewardList;
		}
		
		
		public function getGuildRewardList():Array
		{
			var l_arr:Array=zsghjl.split(";");
			var l_rewardList:Array=new Array();
			if(l_arr.length>0)
			{
				for (var i:int = 0; i < l_arr.length; i++) 
				{
					var l_str:String=l_arr[i];
					var l_arr1:Array=l_str.split("=");
					var itemdata:ItemData=new ItemData();
					itemdata.iid=l_arr1[0];
					itemdata.inum=l_arr1[1];
					l_rewardList.push(itemdata);
				}
				
			}
			else
			{
				var l_arr:Array=zsghjl.split("=");
				var itemdata:ItemData=new ItemData();
				itemdata.iid=l_arr[0];
				itemdata.inum=l_arr[1];
				l_rewardList.push(itemdata);
			}
			return l_rewardList;
			
		}
	}
}