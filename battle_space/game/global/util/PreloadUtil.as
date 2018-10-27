package game.global.util
{
	import game.common.ResourceManager;
	import game.global.GameSetting;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	
	import laya.net.Loader;
	import laya.utils.Handler;

	/**
	 * PreloadUtil
	 * author:huhaiming
	 * PreloadUtil.as 2017-11-14 上午9:53:16
	 * version 1.0
	 *
	 */
	public class PreloadUtil
	{
		private static var _dic:Object = {};
		public function PreloadUtil()
		{
		}
		
		//预加载主场景地图
		public static function preloadAppMain():void{
			var ids:Array = [0,1,2,4,5,6];
			var id:*;
			var url:String;
			for(var i:int=0; i<ids.length; i++){
				id = ids[i];
				if(id < 9){
					url = "0"+(id+1)
				}else{
					url = (id+1) + "";
				}
				url = ResourceManager.instance.setResURL("scene\\main\\mainscene_"+url+".jpg");
				Laya.loader.load(url, null, null, null, 2);
			}
		}
		
		/**loadFirstFight*/
		public static function getPreloadList():Array{
			var arr:Array = [];
			arr.push("scene/fightingScene/3.jpg");
			//My team unit
			arr.push("heroModel/1000/up/daiji.json");
			arr.push("heroModel/1000/up/gongji.json");
			arr.push("heroModel/1000/up/shouji.json");
			arr.push("heroModel/1000/up/siwang.json");
			//My team hero
			arr.push("heroModel/2000/up/shouji.json");
			arr.push("heroModel/2000/up/daiji.json");
			arr.push("heroModel/2000/up/gongji.json");
			
			arr.push("heroModel/2004/up/chuchang.json");
			arr.push("heroModel/2004/up/daiji.json");
			arr.push("heroModel/2004/up/gongji.json");
			
			//Opponent unit
			arr.push("heroModel/1031/down/daiji.json");
			arr.push("heroModel/1031/down/shouji.json");
			arr.push("heroModel/1031/down/siwang.json");
			
			//Opponent hero
			arr.push("heroModel/5003/down/daiji.json");
			arr.push("heroModel/5003/down/gongji.json");
			arr.push("heroModel/5003/down/shouji.json");
			arr.push("heroModel/5003/down/siwang.json");
			
			//skill
			arr.push("skillEffect/skill20000SJ/up.json");
			arr.push("skillEffect/skill70060SJ/up.json");
			arr.push("skillEffect/skill20160SJ/up.json");
			//
			arr.push("atlas/newerGuide.json");
			return arr;
		}
		
		/**主场景预加载*/
		public static function preloadMain():void{
			if(GameSetting.IsRelease && !_dic["preloadMain"]){
				_dic["preloadMain"] = true;
				trace("preloadMain")
				var arr:Array = [];
				arr.push("scene/main/mainscene_01.jpg");
				arr.push("scene/main/mainscene_02.jpg");
				arr.push("scene/main/mainscene_03.jpg");
				arr.push("scene/main/mainscene_04.jpg");
				arr.push("scene/main/mainscene_05.jpg");
				arr.push("scene/main/mainscene_06.jpg");
				
				arr.push("scene/fog/2.png");
				arr.push("scene/fog/3.png");
				arr.push("scene/fog/4.png");
				arr.push("scene/fog/5.png");
				arr.push("scene/fog/6.png");
				arr.push("scene/fog/7.png");
				arr.push("scene/fog/8.png");
				arr.push("scene/fog/9.png");
				
				arr.push("building/base_a.png");
				arr.push("building/quarry_a/daiji/daiji.json");
				arr.push("building/gold_a.png");
				arr.push("building/greenhouse_a.png");
				arr.push("building/training_storage_a.png");
				arr.push("building/quarry_a/daiji/daiji.json");
				arr.push("building/chest_a/daiji/daiji.json");
				arr.push("building/Radar_Station_c/daiji/daiji.json");
				arr.push("atlas/mainUi/effect.json");
				arr.push("atlas/mainUi/buildArrow.json");
				arr.push("atlas/mainUi/buildFrame.json");
				arr.push("atlas/train.json");
				arr.push("unpackUI/train/bg0.png");
				arr.push("fightingMapImg/yh.jpg");
				arr.push("unpackUI/fightingMap/bg1.png");
				ResourceManager.instance.setResURLArr(arr, Loader.ATLAS, 2)
				Laya.loader.load(arr, null, null, null, 2);
			}
		}
		
		/**第一场战斗*/
		public static function preloadFirstBattle():void{
			if(GameSetting.IsRelease && !_dic["preloadFirstBattle"] && !User.getInstance().hasFinishGuide){
				trace("preloadFirstBattle")
				_dic["preloadFirstBattle"] = true;
				var arr:Array = [];
				arr.push("fightingMapImg/11.jpg");
				arr.push("scene/fightingScene/6.jpg");
				arr.push("atlas/fightingMap.json");
				//正向
				arr.push("heroModel/1000/up/chuchang.json");
				arr.push("heroModel/1000/up/daiji.json");
				arr.push("heroModel/1000/up/gongji.json");
				arr.push("heroModel/1000/up/shouji.json");
				arr.push("heroModel/1000/up/yidong.json");
				arr.push("heroModel/1000/up/siwang.json");
				
				arr.push("heroModel/1000/down/daiji.json");
				arr.push("heroModel/1000/down/gongji.json");
				arr.push("heroModel/1000/down/shouji.json");
				arr.push("heroModel/1000/down/yidong.json");
				arr.push("heroModel/1000/down/siwang.json");
				
				arr.push("heroModel/1001/up/chuchang.json");
				arr.push("heroModel/1001/up/daiji.json");
				arr.push("heroModel/1001/up/gongji.json");
				arr.push("heroModel/1001/up/shouji.json");
				arr.push("heroModel/1001/up/yidong.json");
				arr.push("heroModel/1001/up/siwang.json");
				
				//结算
				arr.push("atlas/fightingResult.json");
				arr.push("unpackUI/fightingResult/bg_Battle_Result.png");
				arr.push("effects/jiesuan_star.json");
				
				
				ResourceManager.instance.setResURLArr(arr, Loader.ATLAS, 2)
				Laya.loader.load(arr, null, null, null, 2);
			}
		}
		/**第二场战斗*/
		public static function preloadSecondBattle():void{
			if(GameSetting.IsRelease && !_dic["preloadSecondBattle"] && _dic["preloadFirstBattle"] && !User.getInstance().hasFinishGuide){
				trace("preloadSecondBattle")
				_dic["preloadSecondBattle"] = true;
				var arr:Array = [];
				arr.push("scene/fightingScene/4.jpg");
				//正向
				arr.push("heroModel/2000/up/chuchang.json");
				arr.push("heroModel/2000/up/daiji.json");
				arr.push("heroModel/2000/up/gongji.json");
				arr.push("heroModel/2000/up/shouji.json");
				arr.push("heroModel/2000/up/yidong.json");
				arr.push("heroModel/2000/up/siwang.json");
				arr.push("heroModel/2000/up/gongji02.json");
				
				arr.push("skillEffect/skill20000SJ/up.json");
				arr.push("skillEffect/skill20020SJ/up.json");
				
				//宝箱
				arr.push("effects/chestEffects.json");
				arr.push("atlas/chests.json");
				arr.push("unpackUI/chests/bg0.jpg");
				arr.push("unpackUI/chests/bg6.png");
				arr.push("unpackUI/chests/bg1.png");
				arr.push("unpackUI/chests/bg4.png");
				arr.push("effects/star.json");
				arr.push("effects/dot.json");				
				
				ResourceManager.instance.setResURLArr(arr, Loader.ATLAS, 2)
				Laya.loader.load(arr, null, null, null, 2);
			}
		}
		
		/**第三场战斗*/
		public static function preloadThirdBattle():void{
			if(GameSetting.IsRelease && !_dic["preloadThirdBattle"] && _dic["preloadSecondBattle"] && !User.getInstance().hasFinishGuide){
				trace("preloadThirdBattle")
				_dic["preloadThirdBattle"] = true;
				var arr:Array = [];
				//正向
				arr.push("heroModel/1003/up/chuchang.json");
				arr.push("heroModel/1003/up/daiji.json");
				arr.push("heroModel/1003/up/gongji.json");
				arr.push("heroModel/1003/up/shouji.json");
				arr.push("heroModel/1003/up/yidong.json");
				arr.push("heroModel/1003/up/siwang.json");
				
				arr.push("heroModel/1002/down/daiji.json");
				arr.push("heroModel/1002/down/gongji.json");
				arr.push("heroModel/1002/down/shouji.json");
				arr.push("heroModel/1002/down/yidong.json");
				arr.push("heroModel/1002/down/siwang.json");
				arr.push("skillEffect/skill10060SJ/down.json");
				arr.push("skillEffect/skill10060gj/up.json");
				
				arr.push("buffEffect/60220/up.png");
				ResourceManager.instance.setResURLArr(arr, Loader.ATLAS, 2)
				Laya.loader.load(arr, null, null, null, 2);
			}
		}
	}
}