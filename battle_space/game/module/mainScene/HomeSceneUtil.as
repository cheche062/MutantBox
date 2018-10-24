package game.module.mainScene
{
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.mainui.SceneVo;

	/**
	 * HomeSceneUtil 主场及辅助工具
	 * author:huhaiming
	 * HomeSceneUtil.as 2017-4-26 下午2:27:52
	 * version 1.0
	 *
	 */
	public class HomeSceneUtil
	{
		private static var _buildList:Array;
		private static const HARVEST_TIME:int = 120000;
		/**生产型建筑*/
		public static const PRODUCE_BUILDS:Array = ["2","3","4","5","24"];
		public function HomeSceneUtil()
		{
			
		}
		
		private static function onShowHarvestIcons():void{
			var build:BaseArticle
			for(var i:int=0; i<_buildList.length; i++){
				build = _buildList[i];
				if(_buildList[i].data.type == ArticleData.TYPE_BUILDING){
					var bid:String = build.data.buildId.replace("B","");
					if(build.data.type == ArticleData.TYPE_BUILDING && PRODUCE_BUILDS.indexOf(bid) != -1 && build.data.id != "-1"){
						//伪造一个收获数据====================================
						build.data.resource = "2=1000"
						build.showHarvest(true);
					}
				}
			}
		}
		
		/**收获图标*/
		public static function registerHarvest(buildList:Array):void{
			_buildList = buildList;
			Laya.timer.once(HARVEST_TIME, null, onShowHarvestIcons);
			showProtect();
		}
		
		/**收获图标*/
		public static function clearHarvest():void{
			Laya.timer.clear(null,onShowHarvestIcons);
			Laya.timer.clear(null,onShowProtect);
		}
		/**收获图标*/
		public static function redo():void{
			clearHarvest();
			Laya.timer.once(HARVEST_TIME, null, onShowHarvestIcons);
		}
		
		/**保护盾时间*/
		public static function showProtect():void{
			Laya.timer.loop(5000, null, onShowProtect);
			onShowProtect();
		}
		
		private static function onShowProtect():void{
			var vo:SceneVo = User.getInstance().sceneInfo;
			if(vo.base_rob_info.shield_last_time){
				var delTime:int = vo.base_rob_info.shield_last_time*1000-TimeUtil.now;
				var b:BaseArticle = getMilitaryBuild();
				if(b && delTime > 0){
					//trace("delTime=-========================================",delTime)
					b.showProtect(formatTime(delTime));
				}else{
					b && b.showProtect("");
				}
			}else{
				Laya.timer.clear(null,onShowProtect);
			}
		}
		
		/**获取军方说建筑*/
		private static function getMilitaryBuild():BaseArticle{
			for(var i:String in _buildList){
				if(_buildList[i].data.type == ArticleData.TYPE_BUILDING){
					var id:String = BaseArticle(_buildList[i]).data.buildId.replace("B","")
					if(id == DBBuilding.B_PROTECT){
						return _buildList[i]
					}
				}
			}
			return null;
		}
		
		/**特殊格式化事件-防御盾，显示时分*/
		public static function formatTime(time:Number):String{
			var str:String = "";
			time = time/1000;//to second;
			var h:int = Math.floor(time/TimeUtil.OneHourSceond);
			var m:int = Math.round((time - h*TimeUtil.OneHourSceond)/60);
			if(h>0){
				str = h+"H";
				if(m>0){
					str+= m+"M";
				}
			}else{
				str = m+"M";
			}
			return str;
		}
		
		/**判定是否可以升级*/
		public static function checkUp():void{
			var sceneInfo:SceneVo = User.getInstance().sceneInfo;
			var needFlag:Boolean = true;
			if(sceneInfo.isQueueFull()){
				needFlag = false;
			}
			if(_buildList){
				var item:BaseArticle;
				for(var i:int=0; i<_buildList.length; i++){
					item = _buildList[i];
					if(item && item.data.type == ArticleData.TYPE_BUILDING){
						item.showLvUp(needFlag && DBBuildingUpgrade.checkCanUp(item.data.buildId, item.data.level+1, true));
						if(item.data.buildId=="B3")
						{
							var checkCanUp:Boolean = DBBuildingUpgrade.checkCanUp(item.data.buildId, item.data.level+1, true)
//							trace("needFlag:"+needFlag+","+"checkCanUp:"+checkCanUp);
						}
					}
				}
			}
		}
	}
}