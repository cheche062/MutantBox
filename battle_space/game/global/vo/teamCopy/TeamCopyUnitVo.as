package game.global.vo.teamCopy
{
	import game.global.vo.User;

	public class TeamCopyUnitVo
	{
		public var roomId:int;
		public var type:int;
		public var level:int;
		public var unit_list:Array=new Array();
		public var master:int;
		public var state:int;
		public var user_name:String;
		public var userIsMaster:Boolean;   //我自己是不是队长
		public var uid:Number;
		
		public function TeamCopyUnitVo()
		{
		}
		

		public function seTeamSoldier(p_arr:Array):void
		{
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				var l_vo:TeamCopySoldierVo=new TeamCopySoldierVo();
				l_vo.level=p_arr[i].level;
				l_vo.starLevel=p_arr[i].starId;
				l_vo.unitId=p_arr[i].unitId;
				if(uid==User.getInstance().uid)
				{
					l_vo.isOwn=true;
				}
				else
				{
					l_vo.isOwn=false;
				}
				unit_list.push(l_vo);
			}
		}
		
		
	}
}