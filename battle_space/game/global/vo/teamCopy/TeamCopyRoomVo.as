package game.global.vo.teamCopy
{
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBUnit;
	import game.global.vo.LangCigVo;
	import game.global.vo.User;

	public class TeamCopyRoomVo
	{
		public var room_id:String;
		public var room_level:int;
		public var room_list_id:int=String;
		public var stage_id:int;
		public var isMaster:Boolean;
		public var master:int;
		public var state:int;
		public var unit_list:Array;
		public var user_name:String;
		public var level:int;
		
		public var teamList:Array;
		
		public function TeamCopyRoomVo()
		{
			teamList=new Array();
		}
		
		public function getLevelVo():TeamFightLevelVo
		{
			return	GameConfigManager.TeamFightLevelList[stage_id];
		}
		
		public function getTeamCopyUnitVo():TeamCopyUnitVo
		{
			for (var i:int = 0; i < teamList.length; i++) 
			{
				var l_vo:TeamCopyUnitVo=teamList[i];
				if(l_vo.uid==User.getInstance().uid)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		
		public function setSort():void
		{
			teamList.sort(sortHandler);
			
			
		}
		private function sortHandler(p_a:TeamCopyUnitVo,p_b:TeamCopyUnitVo):void
		{
			if(p_a.uid==User.getInstance().uid)
			{
				return 0;
				
			}
			if(p_b.uid==User.getInstance().uid)
			{
				return 1;
			}
			if(p_b.uid>p_a.uid)
			{
				return 0;
			}
			else
			{
				return 1;
			}
			return 1;
		}
		
		public function setSoldier(p_index:int,p_data:Object)
		{
			if(!checkCanUp(p_data)){
				XTip.showTip(GameLanguage.getLangByKey("L_A_14052"));
				return;
			}
			for (var i:int = 0; i < teamList.length; i++) 
			{
				var l_vo:TeamCopyUnitVo=teamList[i];
				if(l_vo.uid==User.getInstance().uid)
				{
					l_vo.unit_list[p_index]=p_data;
				}
			}
		}
		
		public function checkCanUp(data:Object):Boolean{
			if(!data){
				return true;
			}
			//{"unitId":"1032","level":7,"starLevel":"10643","isOwn":true}
			var hasNum:int = 0;
			for (var i:int = 0; i < teamList.length; i++) 
			{
				var l_vo:TeamCopyUnitVo=teamList[i];
				if(l_vo.uid==User.getInstance().uid)
				{
					var tmp:Object;
					for(var j:int=0; j<l_vo.unit_list.length; j++){
						tmp = l_vo.unit_list[j];
						if(tmp){
							if(tmp["unitId"] == data["unitId"]){
								hasNum ++
							}
						}
					}
					break;
				}
			}
			//
			if(hasNum > 0){
				var unitInfo:Object = DBUnit.getUnitInfo(data["unitId"]);
				if(unitInfo.num_limit <= hasNum){
					return false;
				}
			}
			return true;
		}
		
		public function updateTeamList(p_data:TeamCopyUnitVo):void
		{
			for (var i:int = 0; i < teamList.length; i++) 
			{
				var l_vo:TeamCopyUnitVo=teamList[i];
				if(l_vo.uid==p_data.uid)
				{
					teamList[i]=p_data;
				}
			}
		}
		
		/**
		 * 
		 */
		public function LeaveTeamList(p_ui:Number):void
		{
			var l_teamList:Array=new Array();
			//teamList=new Array();
			for (var i:int = 0; i < teamList.length; i++) 
			{
				var l_vo:TeamCopyUnitVo=teamList[i];
				if(l_vo.uid!=p_ui)
				{
					l_teamList.push(l_vo);
				}
			}
			teamList=l_teamList;
		}
		
	}
}