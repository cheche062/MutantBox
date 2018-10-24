package game.module.worldBoss
{
	import MornUI.worldBoss.chessItemUI;
	
	import game.global.fighting.BaseUnit;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 *  有战队的我方或者敌方npc Boss
	 * @author hejianbo
	 * 2018-04-11 14:05:26
	 * 
	 */
	public class ChessItem extends chessItemUI
	{
		/**待机*/
		private static const DAIJI_URL:String = "daiji";
		/**移动飞行*/
		private static const YIDONG_URL:String = "yidong";
		/**攻击*/
		private static const GONGJI_URL:String = "gongji";
		/**死亡*/
		private static const SIWANG_URL:String = "siwang";
		/**加载过的动画名称*/
		private static var loadedAniNameList:Array = [];
		/**已有的皮肤*/
		private static var SKIN_LIST:Array = ["10001", "10002", "10003","20000", "46001", "46003", "21000", "46101", "46103", "23000", "24000", "25000", "26000"];
		
		/**动画容器*/
		private var roleAniContainer:Box;
		/**飞机动画*/
		private var roleAni:Animation;
		/**是否在战斗动画中*/
		private var isBattling:Boolean = false;
		/**皮肤id*/
		private var skinId:String = "0";
		/**是否是npc*/
		private var isNpcTeam:Boolean = false;
		
		
		
		public function ChessItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			var _result:WorldBossInfoVo = value;
			// 队伍编号是否显示
			this.dom_troopsbg.visible = (!!_result.team);
			// 队伍编号
			this.dom_troopsNum.text = _result.team;
			// 名字
			this.dom_name.text = _result.name;
			//血量比
			this.dom_blood.value = _result.percent;
			// 队伍重合数
			this.dom_collecting.text = String(_result.collect);
			
			super.dataSource = _result;
		}
		
		public function init(info:WorldBossInfoVo):void {
			skinId = setSkin(info.skin);
			isNpcTeam = info.isNpcTeam;
			/**加载完成后*/
			function onLoaded() {
				var direction = isNpcTeam ? 1 : -1;
				direction = (skinId != "0" && !isNpcTeam) ? direction * -1 : direction;
				// npc 和 我方是相反方向
				setDirection(DAIJI_URL, direction);
			}
			
			if (!roleAniContainer) {
				/**能同步做的事情就同步，播放动画是异步则归为异步*/
				roleAni = new Animation();
				roleAniContainer = new Box();
				roleAniContainer.anchorX = roleAniContainer.anchorY = 0.5;
				roleAniContainer.addChild(roleAni);
				
				this.addChildAt(roleAniContainer, 0);
				
				playAnimation(DAIJI_URL, onLoaded);
				
			} else {
				// 没在战斗动画则播放待机动画
				if (!isBattling) {
					playAnimation(DAIJI_URL, null);
					onLoaded();
				}
			}
		}
		
		/**设置皮肤*/
		private function setSkin(value:String):String {
			return SKIN_LIST.indexOf(value) == -1 ? "0" : value;
		}
		
		/**获取实际坐标*/
		private function getActualPosition(url, direction):Array{
			var p:Point = BaseUnit.getAnimationMaxSize(url);
			var x = direction === 1 ? (139 * 0.9 - p.x) / 2 : (139 * 0.9 - p.x) / 2 - 125;
			var y = (155 * 1.2 - p.y) / 2;
			
			return [x, y];
		}
		
		/**获取动画资源地址*/
		private function getAniUrl(dongzuo):String {
			// 没有皮肤则使用默认的
			if (skinId == "0") {
				roleAni.interval = 50;
				return "appRes/heroModel/gf_attacker/"+ dongzuo +".json";
			}
			
			roleAni.interval = 70;
			// npc
			if (skinId == "10001" || skinId == "10002" || skinId == "10003") {
				return "appRes/heroModel/" + skinId + "/right/"+ dongzuo +".json";
			}
			
			// 我方
			return "appRes/heroModel/" + skinId + "/left/"+ dongzuo +".json";
		}
		
		/**设置方向 	1:向左  	-1：向右*/
		private function setDirection(dongzuo, direction):void {
			roleAniContainer.scaleX = direction;
			var url = getAniUrl(dongzuo);
			var posArr = getActualPosition(url, direction);
			roleAni.pos(posArr[0], posArr[1]);
		}
		
		/**加载资源后播放该动画*/
		private function playAnimation(dongzuo:String, callback):void {
			var _cb = callback && callback.bind(this);
			var url:String = getAniUrl(dongzuo);
			callback = function() {
				if (dongzuo == SIWANG_URL || dongzuo == GONGJI_URL) {
					// 判断是否是飞机动画
					var isPlane:Boolean = url.indexOf('gf_attacker') > -1;
					var direction = isPlane ? -1 : 1;
					setDirection(dongzuo, direction);
				}
				
				roleAni.play();
				_cb && _cb();
				if (loadedAniNameList.indexOf(url) == -1) {
					loadedAniNameList.push(url);
				}
			};
			
			roleAni.loadAtlas(url, Handler.create(this, callback));
		}
		
		/**
		 * 飞行移动
		 * @param target 移动的目的地属性
		 * @param callback 移动后的回调
		 * 
		 */
		public function yiDong(target:Object, callback:Function):void {
			//隐藏信息元素
			hideInfo()
			
			playAnimation(YIDONG_URL, function() {
				var direction = target.x > 0 ? -1 : 1;
				direction = (skinId != "0" && !isNpcTeam) ? direction * -1 : direction;
				setDirection(YIDONG_URL, direction);
				
				Tween.to(this, target, 600, Ease.linearIn, Handler.create(this, function() {
					callback();
				}));
			});
		}
		
		/**待机*/
		public function daiji():void {
			playAnimation(DAIJI_URL, null);
		}
		
		/**攻击*/
		public function gongji(taskQueue:Array):void {
			playAnimation(GONGJI_URL, function() {
				isBattling = true;
				this.timerOnce(3000, this, gongjiCallback, [taskQueue]);
			});
		}
		
		/**攻击后的延迟回调*/
		private function gongjiCallback(taskQueue):void {
			isBattling = false;
			daiji();
			var callback = taskQueue[0];
			callback && callback();
		}
		
		/**死亡*/
		public function siwang(callback):void {
			playAnimation(SIWANG_URL, function() {
				roleAni.once(Event.COMPLETE, this, function() {
					daiji();
					callback();
				});
			});
		}
		
		/**重置  是否重置方向*/
		public function reset():void {
			var direction = (skinId != "0" && !isNpcTeam) ? 1 : -1;
			setDirection(YIDONG_URL, direction);
			this.pos(0, 0);
			showInfo();
			roleAni.stop();
			clearTimer(this, gongjiCallback);
			Tween.clearAll(this);
		}
		
		/**隐藏信息元素除了飞机*/
		private function hideInfo():void {
			for (var i = 0; i < this.numChildren; i++) {
				var node = this.getChildAt(i);
				node.visible = (node === roleAniContainer);
			}
		}
		
		/**显示信息元素*/
		private function showInfo():void {
			for (var i = 0; i < this.numChildren; i++) {
				var node = this.getChildAt(i);
				node.visible = true;
			}
		}
		
		/**重置清除动画缓存*/
		public static function clearLoadedAni():void {
			trace('清除动画资源', loadedAniNameList);
			loadedAniNameList.forEach(function(item:String) {
//				Animation.clearCache(item);
				// 需要清除资源
				Laya.loader.clearRes(item);				
				
			});
			
			loadedAniNameList.length = 0;
		}
	}
}