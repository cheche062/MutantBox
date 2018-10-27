package game.module.mainScene
{
	
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.data.DBMonsterStage;
	import game.global.vo.FightUnitVo;
	
	import laya.maths.Point;

	/**
	 * MonsterLogic
	 * author:huhaiming
	 * MonsterLogic.as 2017-3-31 下午4:25:03
	 * version 1.0
	 *
	 */
	public class MonsterLogic
	{
		public static var monsterData:Object;
		//建筑列表
		public static var buildingList:Array;
		public function MonsterLogic()
		{
		}
		
		//生成一个怪物===
		public static function createMonster(mData:Object):Array{
			var arr:Array = [];
			monsterData = mData;
			var mList:Object = mData.list;
			var mInfo:Object;
			var tmp:Array;
			var data:ArticleData
			for(var i:String in mList){
				//reward:"4=41=1;3=41=1";
				//side:"38-44";
				mInfo = mList[i];
				var a:MonsterShow = new MonsterShow();
				tmp = (mInfo.side+"").split("-");
				data = new ArticleData();
				data.type = ArticleData.TYPE_MONSTER;
				data.ex = mInfo.reward;
				data.id = i;
				
				var minfo:Object = DBMonsterStage.getMonsterInfo(i.split("_")[0]);
				var uvo:FightUnitVo
				var str:String;
				if(minfo){
					data.buildId = minfo.radii;
					uvo = GameConfigManager.unit_dic[minfo.monster_id]
					//trace("uvoxxxxxxxxxxxxxxxxxxxxxxxxxxxx",uvo);
					str = "appRes/heroModel/"+uvo.model+"/down/"+"daiji.json";
				}
				a.update(data, str);
				a.showHP(mInfo.progress)
				
				a.showPoint = new Point(parseInt(tmp[0]),parseInt(tmp[1]));
				a.realPoint = new Point(parseInt(tmp[0]),parseInt(tmp[1]));
				arr.push(a);
			}
			return arr;
		}
		
		/**获取怪物影响的建筑列表*/
		public static function getEffList(monsterId:String):Array{
			var len:Number = buildingList.length;
			var build:BaseArticle;
			var list:Array = [];
			for(var i:int=0; i<len; i++){
				build = buildingList[i];
				if(!XUtils.isEmpty(build.data.buff) && build.data.effMonsters && build.data.effMonsters.indexOf(monsterId) != -1){
					list.push(build.data);
				}
			}
			return list
		}
	}
}