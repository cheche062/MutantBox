package game.module.mainScene
{
	import MornUI.mainView.HarvestComUI;
	
	import game.common.ResourceManager;
	
	import laya.display.Animation;
	import laya.net.Loader;
	import laya.utils.Pool;
	import laya.utils.Tween;

	/**
	 * BuildAniUtil 建筑特效工具
	 * author:huhaiming
	 * BuildAniUtil.as 2017-5-10 下午4:54:09
	 * version 1.0
	 *
	 */
	public class BuildAniUtil
	{
		private static var _aAni:Animation
		private static var _fAni:Animation
		private static var _curA:Animation;
		private static var _curF:Animation;
		
		private static const aPics:int = 16;
		private static const fPics:int = 32;
		
		/**升级效果*/
		private static var _upAni:Animation;
		/**升级完成效果*/
		private static var _upgradeAni:Animation;
		private static var _upgradeAni2:Animation;
		public function BuildAniUtil()
		{
		}
		
		/**根据模型选择特效组*/
		public static function getBuildSelectAni(w:int, h:int):Array{
			//只使用3*3的特效
			w = h = 3;
			var key:String = w+"X"+h;
			var arr:Array = [];
			var aAni:Animation = BuildAniUtil._aAni;
			if(!aAni){
				aAni = new Animation();
				aAni.loadAtlas("appRes/atlas/mainUi/buildArrow.json")
				BuildAniUtil._aAni = aAni;
			}
			
			
			var fAni:Animation = BuildAniUtil._fAni;
			if(!fAni){
				fAni  = new Animation();
				fAni.loadAtlas("appRes/atlas/mainUi/buildFrame.json");
				BuildAniUtil._fAni = fAni
			}
			
			
			aAni.play();
			fAni.play();
			_curA = aAni;
			_curF = fAni;
			return [aAni, fAni];
		}
		
		/**销毁动画*/
		public static function dispose():void{
			BuildAniUtil._aAni = null;
			BuildAniUtil._fAni = null;
			BuildAniUtil._upAni = null;
			Loader.clearRes("appRes/atlas/mainUi/buildFrame.json");
			Loader.clearRes("appRes/atlas/mainUi/buildArrow.json");
			Loader.clearRes("appRes/effects/3X3.json");
		}
		
		
		/**根据模型选择特效组*/
		public static function getBuildDownAni(w:int, h:int):Animation{
			var ani:Animation = Pool.getItem("Animation");
			if(!ani){
				ani = new Animation();
			}else{
				ani.clear()
			}
			ani.loadAtlas("appRes/atlas/mainUi/down.json")
			
			return ani;
		}
		
		public static function get upAni():Animation{
			if(!_upAni){
				_upAni = new Animation();
				_upAni.loadAtlas("appRes/effects/3X3.json");
				_upAni.interval = 120;
			}
			return _upAni;
		}
		
		public static function get upgradeAni():Animation{
			if(!_upgradeAni){
				_upgradeAni = new Animation();
				_upgradeAni.loadAtlas("appRes/atlas/mainUi/lvUp.json");
			}
			return _upgradeAni;
		}
		
		public static function get upgradeAni2():Animation{
			if(!_upgradeAni2){
				_upgradeAni2 = new Animation();
				_upgradeAni2.loadAtlas("appRes/atlas/mainUi/lvUp2.json");
			}
			return _upgradeAni2;
		}
		
		
		public static function hideAni():void{
			if(_curA){
				_curA.removeSelf();
				_curF.stop();
				_curA = null;
			}
			
			if(_curF){
				_curF.removeSelf();
				_curF.stop();
				_curF = null;
			}
		}
		
		/**切换收获动画*/
		public static function flashHarvest(ui:HarvestComUI):void{
			Laya.timer.once(100, null, step1);
			
			function step1():void{
				ui.bgBtn.visible = false;
				Laya.timer.once(100, null, step2);
			}
			function step2():void{
				ui.bgBtn.visible = true;
				Laya.timer.once(100, null, step3);
			}
			function step3():void{
				ui.bgBtn.visible = false;
				Laya.timer.once(100, null, step4);
			}
			function step4():void{
				ui.bgBtn.visible = true;
			}
		}
		
		public static function setPos(ani:Animation, type:int):void{
			var arr:Array = posDic[type];
			ani.scaleX = ani.scaleY = arr[2];
			ani.pos(arr[0],arr[1]);
		}
		
		//建筑落下的效果
		public static function setDownPos(ani:Animation, type:int):void{
			var arr:Array = posDic["d"+type];
			ani.scaleX = ani.scaleY = arr[2];
			ani.pos(arr[0],arr[1]);
		}
		
		/**动画位置*/
		private static var _posDic:Object 
		private static function get posDic():Object{
			if(!_posDic){
				_posDic = ResourceManager.instance.getResByURL("staticConfig/buildAniPos.json"); 
				trace("_posDic::::::::::",_posDic)
				/*_posDic =  {
					"2":[-250,-190,0.72],
					"3":[-346,-266,1],
					"4":[-420,-336,1.23],
					"5":[-520,-414,1.49]
				}*/
					
				/*_posDic =  {
					"2":[-346,-246],
					"3":[-346,-266],
					"4":[-346,-296],
					"5":[-350,-324]
				}*/
			}
			return _posDic
		}
		
		public static function getPicPos(w:int):Array{
			return upPicPos[w];
		}
		
		/**升级图片位置*/
		private static var _upPicPos:Object;
		private static function get upPicPos():Object{
			if(!_upPicPos){
				//_upPicPos = ResourceManager.instance.getResByURL("config/buildPicPos.json"); 
				_upPicPos = {
				"1":[-50,-104,-290,-271,0.4],
				"2":[-90,-152,-465,-431,0.62],
				"3":[-142,-230,-746,-679,1],
				"4":[-204,-336,-1048,-964,1.4],
				"5":[-246,-404,-1249,-1151,1.66]
				}
			}
			return _upPicPos;
		}
		
		public static function getDonePos(w:int):Array{
			return donePos[w];
		}
		
		/**升级完成动画位置*/
		private static var _donePos:Object;
		private static function get donePos():Object{
			if(!_donePos){
				//_upPicPos = ResourceManager.instance.getResByURL("config/buildPicPos.json"); 
				_donePos = {
					"1":[-80,-102,-80,-122,0.4],
					"2":[-130,-162,-130,-162,0.62],
					"3":[-182,-240,-182,-240,1],
					"4":[-230,-326,-230,-326,1.3],
					"5":[-276,-404,-276,-414,1.6]
				}
			}
			return _donePos;
		}
	}
}