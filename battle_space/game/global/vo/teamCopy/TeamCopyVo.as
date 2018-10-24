package game.global.vo.teamCopy
{
	import MornUI.arena.AreaDRItemUI;
	
	import game.global.GameConfigManager;
	import game.global.vo.User;

	public class TeamCopyVo
	{
		public var stage_id:int;
		public var buy_combat_number:int;
		public var combat_number:int;
		public var refresh_number:int;
		public var refresh_time:int;
		public var room_id:int;
		public var room_list_id:int;
		
		public var roomList:Array;
		
		
		public function TeamCopyVo()
		{
		}
		
		public function getLevelVo():TeamFightLevelVo
		{
			return	GameConfigManager.TeamFightLevelList[stage_id];
		}
		
		public function getRefreshCost(p_num:int):Array
		{
			if(p_num==0)
			{
				p_num=1;
			}
			
			
			var l_arr:Array=null;
			for (var i:String in GameConfigManager.TeamFightRefreshList) 
			{
				var l_vo:TeamFightRefreshVo=GameConfigManager.TeamFightRefreshList[i];
				if(l_vo.down<=p_num&&p_num<=l_vo.up)
				{
					l_arr=l_vo.price.split("=");
					return l_arr;
				}
			}
			return l_arr;
		}
		
		public function getFightCost():Array
		{
			var l_arr:Array=null;
			return l_arr;
		}
		
		public function setRoomList(p_obj:Object):void
		{
			roomList=new Array();
			for each (var i:Object in p_obj) 
			{
				var l_vo:TeamCopyRoomVo=new TeamCopyRoomVo();
				l_vo.stage_id=i.base_info.stage_id;
				l_vo.room_id=i.base_info.room_id;
				l_vo.room_level=i.base_info.room_level;
				l_vo.room_list_id=i.base_info.room_list_id;
				l_vo.user_name=i.base_info.user_name;
				l_vo.level=i.base_info.level;
				var isMaster:Boolean=false;
				for each (var j:Object in i) 
				{
					var l_teamCopyUnitVo:TeamCopyUnitVo=new TeamCopyUnitVo();
					if(j.unit_list!=undefined )
					{
						if(j.master==1)
						{
							isMaster=true;
							l_vo.isMaster=true;
						}
						l_teamCopyUnitVo.master=j.master;
						l_teamCopyUnitVo.state=j.state;
						l_teamCopyUnitVo.level=j.level;
						l_teamCopyUnitVo.uid=parseInt(j.uid);
						l_teamCopyUnitVo.seTeamSoldier(j.unit_list);
						l_teamCopyUnitVo.user_name=j.user_name;
						l_teamCopyUnitVo.userIsMaster=isMaster;
						l_vo.user_name=j.user_name;
						l_vo.level=j.level;
						l_vo.teamList.push(l_teamCopyUnitVo);
					}
				}
				roomList.push(l_vo);
			}
			
		}
		
		
	}
}