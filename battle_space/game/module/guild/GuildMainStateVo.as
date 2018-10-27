package game.module.guild
{
	import game.common.ToolFunc;
	import game.global.vo.User;

	public class GuildMainStateVo
	{
		/**公会说明*/
		public var desc:String;
		/**各捐献类型的捐献次数*/
		public var donate_times:Object
		/**公会总贡献值*/
		public var guild_cash:int
		/**公会成员们*/
		public var member_list:Array
		/**经验值*/
		public var exp:int;
		/**公会头像*/
		public var icon:int
		/**公会id*/
		public var id:String;
		/**公会名称*/
		public var name:String;
		/**成员数量*/
		public var members_count:int;
		/**公会等级*/
		public var level:int;
		/**加入公会的类型方式*/
		public var join_type:int;
		/**加入公会的限制条件*/
		public var join_limit:int;
		/**职位*/
		public var job:int;
		/**....*/
		public var intel:int;
		
		
		/**当前玩家的贡献值*/
		public var personal_fund:int;
		/**当前玩家个人科技   的技能等级*/
		public var personal_keji:Object;
		
		
		public function GuildMainStateVo()
		{
		}
		
		public function init(data):void {
			ToolFunc.copyDataSource(this, data);
			countPersonalFund();
		}
		
		public function countPersonalFund():void {
			if (!member_list || member_list.length == 0) return;
			//我的贡献值
			var targetData = ToolFunc.find(member_list, function(item) {
				return item["uid"] == User.getInstance().uid;
			});
			
			personal_fund = targetData["contribution"];
		}
		
		
		
		
		
		
	}
}