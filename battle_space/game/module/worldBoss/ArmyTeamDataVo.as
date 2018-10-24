package game.module.worldBoss
{
	/**
	 * 军队的数据
	 * @author mutantbox
	 * 
	 */
	public class ArmyTeamDataVo
	{
		/**team队伍编号*/
		public var team:String = "";
		/**是否是选中状态*/
		public var isSelected:Boolean = false;
		/**是否是起始位置*/
		public var isStartPoint:Boolean = false;
		/**是否有数据*/
		public var hasData:Boolean = false;
		/**头像*/
		public var head:String = "";
		/**行动力*/
		public var muscle:Number = 0;
		/**血量*/
		public var hp:Number = 0;
		/**总血量*/
		public var hp_max:Number = 0;
		/**是否死亡*/
		public var isDied:Boolean = false;
		/**倒计时时间*/
		public var time:Number = 0;
		/**自动玩*/
		public var auto:Number = 0;
		
		/**复活计时器*/
		public var timeCountHandler = null;
		
		private static const SKIN_LIST:Array = ["46001", "46003", "46101", "46103"];
		
		public function ArmyTeamDataVo()
		{
		}
		
		/**更新数据*/
		public function updateDataTeam(obj:WorldBossInfoVo):void {
			for (var key in obj) {
				if (this.hasOwnProperty(key)) {
					this[key] = obj[key];
				}
			}
			
			
			if (SKIN_LIST.indexOf(String(obj.skin)) > -1) {
				head = String(obj.icon) + "_" +String(obj.skin);
			} else {
				head = String(obj.icon);
			}
		}
		
		/**数据重置*/
		public function reset():void {
			isSelected = false;
			isStartPoint = false;
			hasData = false;
			head = "";
			muscle = 0;
			hp = 0;
			isDied = false;
			time = 0;
			clearTimeCountHandler();
		}
		
		/**清除定时器*/
		public function clearTimeCountHandler():void {
			if (timeCountHandler) {
				timeCountHandler();
				timeCountHandler = null;
			}
		}
		
		
		
		
		
	}
}