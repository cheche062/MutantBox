/***
 *作者：罗维
 */
package game.module.fighting.adata
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Button;

	public class FightingResultsData
	{
		public var isWin:Boolean;  //胜负 ？
		public var reward:Array ;  //奖励
		public var checkpointData:Object;  //关卡信息
		public var soldierData:Array;  //士兵信息
		public var turnCard:Object ;  //抽奖
		public var type:String; //类型
		
		public var hp:Number = 0; 
		public var hurt:Number = 0;
		public var id:Number = 0;
		public var maxHp:Number = 0;
		public var cup:Number = 0;
		public var old_cup:Number = 0;
		//竞技场数据
		public var newRank:Number = 0;
		public var oldRank:Number = 0;
		public var point:Number; //竞技场积分
		
		//pvp数据
		public var integral:Number = 0;  //当前积分
		public var addIntegral:Number = 0; //增加积分
		public var upgrades:Number = 0 ;  //是否升级
		public var gradesRewards:Array; //段位升级奖励
		public var fightRewards:Number = 0; //积分奖励
		
		//
		public var rate:*;
		
		
		public static var TYPE_STAGE:String = "stage";
		public static var TYPE_ELITE:String = "elite";
		public static var TYPE_ARENA:String = "arena";
		public static var TYPE_GUILD_BOSS:String = "guild_boss";
		public static var TYPE_BASEROB:String = "baseRob";
		public static var TYPE_MINE:String = "mine_fight";
		public static var TYPE_PVP:String = "dfzb";
		public static var TYPE_BAGUA:String = "lunhuan_bagua";
	
		public function FightingResultsData(d:Object)
		{
			if(!d)
				return ;
			
			isWin = Boolean(d.isWin);
			if(d.hasOwnProperty("type"))
				type = d.type;
			if(d.hasOwnProperty("hp"))
				hp = Number(d.hp);
			if(d.hasOwnProperty("hurt"))
				hurt = Number(d.hurt);
			
			if(d.hasOwnProperty("id"))
				id = Number(d.id);
			if(d.hasOwnProperty("maxHp"))
				maxHp = Number(d.maxHp);
			if(d.hasOwnProperty("cup"))
				cup = Number(d.cup);
			if(d.hasOwnProperty("old_cup"))
				old_cup = Number(d.old_cup);
			
			
			//竞技场
			if(d.hasOwnProperty("point"))
				point = Number(d.point);
			if(d.hasOwnProperty("rank"))
			{
				newRank = Number(d.rank.newRank);
				oldRank = Number(d.rank.oldRank);
			}
			
			//pvp
			if(d.hasOwnProperty("integral"))
				integral = Number(d.integral);
			if(d.hasOwnProperty("addIntegral"))
				addIntegral = Number(d.addIntegral);
			if(d.hasOwnProperty("upgrades"))
				upgrades = Number(d.upgrades);
			
			if(d.hasOwnProperty("rate")){
				rate = d.rate
			}
				
			
			gradesRewards = [];
			var i:int = 0;
//			d.gradesRewards = [
//				{
//					id:50024,
//					num:10
//				}
//			];
			if(d.gradesRewards)
			{
				for (i = 0; i < d.gradesRewards.length; i++) 
				{
					var _id:Object = d.gradesRewards[i];
					var ivo:ItemVo = GameConfigManager.items_dic[_id.id];
					if(ivo)
					{
						var idata:ItemData = new ItemData();
						idata.iid = ivo.id;
						idata.inum = Number(_id.num);
						gradesRewards.push(idata);
					}
				}
			}
			
			
			if(d.fightRewards)
			{
				fightRewards = Number(d.fightRewards[0].num);
			}
			
				
			reward = [];
			var i:int = 0;
			if(d.rewards)
			{
				for (i = 0; i < d.rewards.length; i++) 
				{
					var _id:Object = d.rewards[i];
					var ivo:ItemVo = GameConfigManager.items_dic[_id.id];
					if(ivo)
					{
						var idata:ItemData = new ItemData();
						idata.iid = ivo.id;
						idata.inum = Number(_id.num);
						reward.push(idata);
					}
				}
				
			}
			soldierData = [];
			if(d.soldier)
			{
				for (i = 0; i < d.soldier.length; i++) 
				{
					var sdata:Object = d.soldier[i];
					var sod:frSoldierData = new frSoldierData();
					sod.addExp = Number(sdata.addExp);
					sod.uid = Number(sdata.id);
					sod.uExp = Number(sdata.exp);
					sod.uLev = Number(sdata.level);
					sod.uNum = Number(sdata.surplus);
					sod.uMaxNum = Number(sdata.total);	
					soldierData.push(sod);
				}
			}
			if(d.task)
			{
				checkpointData = d.task;
			}
			
			turnCard = d.turnCard;
			
			
			
			
			trace("解析战斗结算");
		}
		
		
		public function get rType():Number{
			if(type && type == TYPE_ARENA)
				return 3;
			if(type && type == TYPE_GUILD_BOSS)
				return 4;
			if(type && type == TYPE_BASEROB)
				return 5;
			if(type && (type == TYPE_STAGE || type == TYPE_ELITE))
				return 1;
			if(type && type == TYPE_PVP)
				return 6;
			return 2;
		}
		
	}
}