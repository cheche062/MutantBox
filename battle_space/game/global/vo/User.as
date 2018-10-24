package game.global.vo
{
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.data.bag.BagManager;
	import game.global.event.Signal;
	import game.global.vo.tech.UserTechInfoVo;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.module.mainui.SceneVo;

	/**
	 * UserVo 角色数据VO
	 * author:huhaiming
	 * UserVo.as 2017-3-13 下午2:18:53
	 * version 1.0
	 *
	 */
	public class User
	{
		
		public var exp:Number;
		private var _food:Number;
		private var _gold:Number;
		public var headimg:String;
		public var level:Number;
		public var lv:Number;
		public var oid:Number;
		public var platform:Number;
		private var _steel:Number;
		private var _stone:Number;
		public var uid:Number;
		public var name:String;
		/**设置食物保护(国战的)*/
		public var set_food_protect:Number = 0;
		private var _water:Number;
		private var _bread:Number;
		//基地活动-杯数
		public var cup:Number;
		//基地互动-代币数
		public var substitute:Number;
		
		//PVP代币
		private var _token:Number = 0;
		
		/**
		 * 是否新注册用户
		 */
		public var is_new_user:Boolean=false;
		
		
		/**
		 * 公会ID
		 */
		public var guildID:String="";
		/**
		 * 公会职位
		 */
		public var guildJob:int = 0;
		
		/**
		 * 公会基金
		 */
		public var guildFundation:int = 0;
		
		/**
		 * 公会等级
		 */
		public var guildLv:int = 0;
		
		/**
		 * 公会当前经验
		 */
		public var guildExp:int = 0;
		
		/**
		 * 公会BOSS排行
		 */
		public var guildBossRank:int = -1;
		
		/**
		 * 新手引导步骤
		 */
		public var guideStep:int = 0;
		
		/**
		 * 是否有新公会消息
		 */
		public var hasNewChat:Boolean = false;
		
		/**
		 * 个人公会贡献值
		 */
		public var contribution:int = 0;
		
		/**
		 * 普通捐献次数
		 */
		public var silverContribute:int = 0;
		
		/**
		 * 高级捐献次数
		 */
		public var goldContribute:int = 0;
		
		/**
		 * 竞技场点数
		 */
		public var areanPoint:int = 0;
		
		/**
		 * 竞技场排名
		 */
		public var arenaRank:int = 0;
		
		/**
		 * 竞技场货币
		 */
		public var areanCoin:int = 0;
		
		/**
		 * 竞技场分组
		 */
		public var arenaGroup:int = 0;
		
		/**
		 * 矿场点数
		 */
		public var minePoint:int = 0;
		
		/**
		 * 紫水晶
		 */
		public var purpleCrystal:int = 0;
		
		/**
		 * 军团战 军粮
		 */
		public var armyGroupFood:int = 0;
		
		/**
		 * 日常任务积分
		 */
		public var dailyScore:int = 0;
		
		/**
		 * 矿点时候处于保护
		 */
		public var mineIsProtect:Boolean = false;
		
		/**
		 * 当前引导序列
		 */
		public var curGuideArr:Array = [];
		
		/**
		 * 是否完成了新手引导
		 */
		public var hasFinishGuide:Boolean = true;
		
		/**
		 * 是否在引导中
		 */
		public var isInGuilding:Boolean = false;
		
		/**
		 * 时候在主场景
		 */
		public var isInMainView:Boolean = true
		
		/**
		 * 是否可以自由控制战斗
		 */
		public var canAutoFight:Boolean = true;
		
		/**
		 * 锁定移动
		 */
		public var lockMove:Boolean = false;
		
		/**
		 * 禁止点击空白关闭
		 */
		public var forbidBlankClose:Boolean = false;
		
		
		/**
		 * VIP等级
		 */
		public var VIP_LV:int = 0;
		
		/**
		 * 充值金额
		 */
		public var chargeNum:int = 0;
		
		/**
		 * 是否有周卡
		 */
		public var hasWeekCard:Boolean = false;
		
		/**
		 * 是否买过基金
		 */
		public var hasBuyFun:Boolean = false;
		
		/**
		 * 我的邀请码
		 */
		public var inviteCode:String = "";
		
		/**
		 * VIP礼包领取情况
		 */
		public var vipRewardInfo:Array = [];
		
		/**关联对象-建筑信息*/
		public var sceneInfo:SceneVo = new SceneVo();
		/**事件-属性更新*/
		public static const PRO_CHANGED:String = "pro_changed";
		/**
		 * 科技数据更新
		 */
		public static const TECH_UPDATE:String = "pro_changed";
		/**世界boss数据*/
		public var bossFightInfo:BossFightInfoVo = new BossFightInfoVo();
		
		/**
		 * 已研究科技树技能
		 */
		public var userTechVec:Vector.<UserTechInfoVo> = new Vector.<UserTechInfoVo>();
		
		/**
		 * 当前可用科技点数
		 */
		public var currentTechPoint:int = 0;
		
		/**战斗力*/
		public var KPI:int = 0;
		
		/**是否领取加入公会奖励  0没有加入公会 1可领取 2已领取 3已领取但是又退公会了*/
		public var has_add_guild_reward:*;
		
		public var shareInfo:Object = { };
		
		//基地互动奖励
		public var day_box_reward:Boolean = false;
		
		/**道具ID=>属性映射,需要人肉维护*/
		private var itemToPro:Object=
		{
			"1":"water","2":"stone","3":"steel","4":"gold","5":"food","6":"contribution", "9":"substitute","14":"token","16":"armyGroupFood","20":"bread"
		}
		 
		/**单例*/
		private static var _instance:User;
		
		public function User()
		{
			
		}
		
		public function get token():Number
		{
			return _token;
		}

		public function set token(value:Number):void
		{
			if(_token != value)
			{
				_token = value;
				this.event();
			}
		}

		public function updateVo(info:Object):void{
			for(var i:String in info){
				if(this.hasOwnProperty(i)){
					this[i] = info[i];
				}
			}
			event();
		}
		
		public function event(data:* = null):void{
			Signal.intance.event(PRO_CHANGED, data);
		}
		
		/**
		 * 更新用户科技点
		 * @param	id
		 * @param	lv
		 */
		public function updateUserTech(id:String,lv:int):void
		{
			var len:int = userTechVec.length;
			var isNew:Boolean = true;
			for (var i:int = 0; i < len; i++) 
			{
				if (userTechVec[i].id == id)
				{
					isNew = false;
					if (lv >= GameConfigManager.intance.getTechUpdateInfo(id, 1).max)
					{
						
						userTechVec[i].lv = parseInt(GameConfigManager.intance.getTechUpdateInfo(id, 1).max);
					}
					else
					{
						
						userTechVec[i].lv = lv;
					}
				}
			}
			if (isNew)
			{
				var tvo:UserTechInfoVo = new UserTechInfoVo;
				tvo.id = id;
				tvo.lv = lv;
				userTechVec.push(tvo);
				
			}
		}
		
		/**
		 * 获取用户单个科技信息
		 * @param	id
		 * @return
		 */
		public function getUserTech(id:String):UserTechInfoVo
		{
			var len:int = userTechVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (userTechVec[i].id == id)
				{
					return userTechVec[i];
				}
			}
			return null;
		}
		
		public function resetUserTechPoint():void
		{
			userTechVec = null;
			userTechVec = new Vector.<UserTechInfoVo>();
		}
		
		/**
		 * 获取用户当前消耗的总点数
		 * @return
		 */
		public function getUserAllTechPoint():int
		{
			var len:int = userTechVec.length;
			var all:int = 0;
			for (var i:int = 0; i < len; i++) 
			{
				all += userTechVec[i].lv;
			}
			return all;
		}
		
		public function checkHasNextGuide():void
		{
			
			if (curGuideArr.length >= 1)
			{
				isInGuilding = true;
				if (GameConfigManager.fun_open_vec[curGuideArr[0]].lx == 2 )
				{
					XFacade.instance.openModule(ModuleName.FunctionGuideView,GameConfigManager.fun_open_vec[curGuideArr[0]].g_id);
				}
				else if (GameConfigManager.fun_open_vec[curGuideArr[0]].lx == 4)
				{
					XFacade.instance.openModule(ModuleName.HQUpgradeView,curGuideArr[0]);
				}
				else
				{
					XFacade.instance.openModule(ModuleName.CommonGuideView,curGuideArr[0]);
				}
			}
		}
		
		
		public function updateTechEvent(data:* = null):void {
			Signal.intance.event(TECH_UPDATE, data);
		}
		
		/**根据道具ID获取资源数量*/
		public function getResNumByItem(itemId:String):Number{
			var key:String = itemToPro[itemId];
			if(key){
				return this[key];
			}else{
				return BagManager.instance.getItemNumByID(parseInt(itemId));
			}
			return 0;
		}
		/**根据道具ID修改数值*/
		public function setResNumByItem(itemId:*, value:Number):void{
			var key:String = itemToPro[itemId];
			//trace("setResNumByItem::",key,value);
			if(key){
				this[key] = value;
			}
		}
		
		
		public function set food(v:Number):void{
			this._food = v;
		}
		public function get food():Number{
			return this._food;
		}
		
		public function set gold(v:Number):void{
			this._gold = v;
		}
		public function get gold():Number{
			return this._gold;
		}
		public function set bread(v:Number):void{
			this._bread = v;
		}
		public function get bread():Number{
			return this._bread;
		}
		public function set steel(v:Number):void{
			this._steel = v;
		}
		public function get steel():Number{
			return this._steel;
		}
		
		public function set stone(v:Number):void{
			this._stone = v;
		}
		public function get stone():Number{
			return this._stone;
		}
		
		public function set water(v:Number):void{
			this._water = v;
		}
		public function get water():Number{
			return this._water;
		}
		
		public static function getInstance():User{
			if(!_instance){
				_instance = new User();
			}
			return _instance;
		}
	}
}
