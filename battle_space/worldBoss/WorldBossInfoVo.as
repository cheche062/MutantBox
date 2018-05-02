package game.module.worldBoss
{
	import game.global.GameLanguage;
	import game.global.util.TimeUtil;
	import game.global.vo.User;

	/**
	 * 单条数据信息 
	 * @author hejianbo
	 * 
	 */
	public class WorldBossInfoVo
	{
//		const team_info = [
//			'last_fight_time'=>0,//上次战斗时间
//			'last_move_time'=>0,//上次移动时间
//			'power'=>0,//战力
//			'army' => [], //阵型
//			'auto_target_map_pos'=>'',//自动目标地点
//			'type'=>1,//1满血 2残血
//			'fight_times'=>0,//出战次数
//			'refresh_time'=>0,//刷新信息时间
//			'death_num'=>0,//死亡次数,
//			'revive_time'=>0,//复活时间
//		];
		/**我的队伍编号*/
		public var team:String = "";
		/**队伍id*/
		public var team_id:String = "";
		/**boss id*/
		public var boss_id:String = "";
		/**uid*/
		public var uid:int = 0;
		/**name*/
		public var name:String = "";
		/**玩家等级*/
		public var level:String = "";
		/**头像*/
		public var icon:String = "";
		/**皮肤*/
		public var skin:String = "";
		
		/**是否是自己的队伍*/
		public var isMyTeam:Boolean = false;
		/**是否是npc的队伍*/
		public var isNpcTeam:Boolean = false;
		/**队伍所在地图索引index*/
		public var index:String = "";
		/**行动力*/
		public var muscle:int = 0;
		/**是否死亡*/
		public var isDied:Boolean = false;
		/**当前血量*/
		public var hp:Number = 0;
		/**总血量*/
		public var hp_max:Number = 0;
		/**血量比列*/
		public var percent:Number = 0;
		/**复活倒计时时间*/
		public var time = 0;
		/**自动玩*/
		public var auto:Number = 0;
		/**死亡次数*/
		public var death_num:Number = 0;
		
		
		/**该格子的飞机重叠数  默认为1*/
		public var collect:int = 1;
		
		public function WorldBossInfoVo()
		{
		}
		
		/**更新数据*/
		public function updateData(obj):void {
			for (var key in obj) {
				if (this.hasOwnProperty(key)) {
					this[key] = obj[key];
				}
			}
		}
		
		/**进入战场初始化数据转型*/
		public function initDataTransform(obj):void {
			var name = User.getInstance().name;
			var uid = User.getInstance().uid;
			updateData(obj);
			updateData({
				"isMyTeam": (obj.uid == uid),
				"index": obj.map_pos,
				"percent": obj.hp / obj.hp_max,
				"isDied": (obj.status == 2)
			});
			if (isMyTeam && isDied) {
				time = dealWithTime(obj.revive_time);
			}
		}
		
		/**更新血量    num1:本次战斗消耗血量，  num2本次战斗开始前所有的血量*/
		public function updataBlood(num1, num2):void {
			var hp = Number(num2) - Number(num1);
			updateData({
				"hp": hp,
				"percent": hp / Number(this.hp_max)
			});
		}
		
		/**计算倒计时时间*/
		private function dealWithTime(time):Number {
			// 多加 5 秒  
			return Math.floor(Number(time)) - Math.floor(TimeUtil.now / 1000) + 5;
		}
		
		/**npc数据更新*/
		public function updataNpc(index, collect, npcId, name):void {
			updateData({
				"isNpcTeam": true,
//				"name": index + "-" + GameLanguage.getLangByKey(name),
				"name": name,
				"index": index,
				"icon": npcId,
				"percent": 1,
				"collect": Number(collect)
			});
		}
		
		/**
		 * npc战斗后更新
		 * @param hp_cost  血量消耗
		 * @param hp_start  本次战斗开始时的血量
		 * @param hp_max   初始化的总血量
		 * @param collect  还剩多少个npc
		 * 
		 */
		public function updateNpcAfterBattle(hp_cost, hp_start, hp_max, _collect):void {
			var hp = Number(hp_start) - Number(hp_cost);
			var _collect = (_collect === undefined) ? this.collect : Number(_collect);
			updateData({
				"percent": hp / Number(hp_max),
				"collect": _collect
			});
		}

		
		
		
		
		
		
		
		
		
	}
}