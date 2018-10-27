package game.module.worldBoss 
{
	
	import game.common.ImageFont;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.global.event.Signal;
	
	import laya.display.Animation;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Tween;
	
	/**
	 * 世界BOSS 单位棋子
	 * @author hejianbo
	 * 2018-04-10 14:05:26
	 */
	public class WorldBossChess extends Sprite 
	{
		/**可点区域*/
		private static const HIT_AREA:Array = [11, 45, 70, 10, 130, 45, 130, 113, 70, 146, 11, 113];
		/**格子索引*/
		private var _pieceIndex:String = "";
		/**格子是否处于激活状态     可移动    可攻击*/
		private var _isActivate:Boolean = false;
		
		/**格子类型   '1':空白格子线，'2' 可移动点, '3':当前站立点  'NPC': npc, 'BOSS':boss, 'CS':起始位置     */
		private var _pieceType:String;
		
		/**人机对象池*/
		private static const peoplePlanePool:Array = [];
		/**人机*/
		private var _peoplePlane:ChessItem = null;
		/**黑烟元素*/
		private var _dom_smog:Animation = null;
		/**保护罩元素*/
		private var _dom_protect:Animation = null;
		
		/**格子类型的背景对应表*/
		private static const typeMap = {
			'1': '1', // 空白格子线
			'2': '2', //可移动点
			'3': '3', //当前站立点
			'NPC': '4',
			'BOSS': '4',
			'CS': '6' //出生点
		}
		
		/**格子背景*/
		private var _pieceBg:Image = null;
		/**战斗动画后的回调任务    仅存一个任务   后续再有则覆盖*/
		private var taskQueue:Array = [];
		/**是否在战斗中*/
		public var isFighting:Boolean = false;
		
		public function WorldBossChess(index:String) 
		{
			super();
			_pieceIndex = index;
			this.size(139, 155);
			
			setHitArea();
			
			this.on(Event.CLICK, this, onClickHandler);
		}
		
		/**初始化  '1', 'NPC=....', 'BOSS'=....*/
		public function init(text):void {
			pieceType = text.split('=')[0];
			
			//测试便于查看
//			addPosText();
		}
		
		private function addPosText():void {
			var label:Label = new Label(_pieceIndex);
			label.color = "#fff";
			label.fontSize = 16;
			label.pos(this.width / 2, this.height / 2);
			this.addChild(label);
		}
		
		/**
		 * 更新视图 
		 * @param data
		 * @param isOperateChess 是否是操作中的棋子
		 * 
		 */
		public function updateView(data:WorldBossInfoVo, isOperateChess):void {
			peoplePlane.dataSource = data;
			
			peoplePlane.init(data);
			this.addChildAt(peoplePlane, 1);
			this.zOrder = isOperateChess ? 2 : 1;
			
			if (data.isNpcTeam) {
				this.zOrder = 5;
				_pieceType = 'NPC';
				setBgSkin(_pieceType);
				
				if (data.collect <= data.init_collect / 2) {
					addSmogEffect();
				}
			}
			
			// 我的队伍
			if (data.isMyTeam) {
				// 是操作中的
				if (isOperateChess) {
					pieceType = '3';
					// 非激活中的
				} else if(!isActivate) {
					pieceType = '1';
				}
				// 别人队伍
			} else {
				// 非激活的格子需要重置为'1'
				if (!isActivate) {
					pieceType = '1';
				}
			}
		}
		
		/**移除人机元素*/
		public function removePeoplePlane():void {
			var node = _peoplePlane;
			if (!node) return;
			_peoplePlane = null;
			this.zOrder = 0;
			
			// 只有非激活的格子渲染时才需要改变背景
			if (!isActivate) pieceType = '1';
			
			recoverPlane(node);
		}
		
		/**npc强制移除飞机*/
		public function npcForceRemovePeoplePlane():void {
			removePeoplePlane();
			if (isActivate) {
				setBgSkin('2');
			} else {
				setBgSkin('1');
			}
			
			_pieceType = '1';
			
			// 销毁黑烟
			if (_dom_smog) {
				_dom_smog.destroy();
				_dom_smog = null;
			}
			
			removeProtectEffect();
		}
		
		/**设置格子属性*/
		private function set pieceType(value:String):void {
			//第一次来直接设置
			if (!_pieceType) {
				_pieceType = value;
				setBgSkin(_pieceType);
				
			} else {
				//后期要变
				if (pieceType == '1' || pieceType == '2' || pieceType == '3') {
					_pieceType = value;
					setBgSkin(_pieceType);
				}
			}
		}
		private function get pieceType():String {
			return _pieceType;
		}
		
		/**设置格子背景色*/
		private function setBgSkin(type):void {
			var _url = 'worldBoss/grid_' + typeMap[type] + '.png';
			if (!_pieceBg) {
				_pieceBg = new Image()
				this.addChildAt(_pieceBg, 0);
			}
			// 背景皮肤
			_pieceBg.skin = _url;
		}
		
		/**设置激活状态*/
		public function set isActivate(value:Boolean):void {
			if (_isActivate === value) return;
			_isActivate = value;
			
			var type = value ? '2' : '1';
			pieceType = type;
		}
		public function get isActivate():Boolean {
			return _isActivate;
		}
		
		private function get peoplePlane():ChessItem {
			if (_peoplePlane) return _peoplePlane;
			_peoplePlane = createPeoplePlane();
			
			return _peoplePlane;
		}
		
		/**创建人机元素*/
		private function createPeoplePlane():ChessItem {
			return (peoplePlanePool.length > 0) ? peoplePlanePool.pop() : new ChessItem();
		}
		
		/**点击事件*/
		private function onClickHandler():void {
			if (isActivate) {
				/**是否是敌人领地*/
				var isEnemy:Boolean = (pieceType === 'NPC' || pieceType === 'BOSS');
				Signal.intance.event(WorldBossFightView.CHANGE_INDEX, [_pieceIndex, isEnemy]);
				
				trace("WorldBossChess 飞机池", peoplePlanePool.length);
			}
		}
		
		/**设置可点区域*/
		private function setHitArea():void {
			var g:Graphics = new Graphics();
			g.drawPoly(0, 0, HIT_AREA, "#f60");
			var hitArea:HitArea = new HitArea();
			hitArea.hit = g;
			this.hitArea = hitArea;
		}
		
		/**飞行*/
		public function fly(info:WorldBossInfoVo, targetPos, callback):void {
			//零时创建另一个人机 等动画结束后再扔到对象池
			var temporaryPlane:ChessItem = createPeoplePlane();
			temporaryPlane.init(info);
			this.addChild(temporaryPlane);
			var zOrder = this.zOrder;
			this.zOrder = 3;
			
			var _cb = callback;
			callback = function() {
				recoverPlane(temporaryPlane);
				this.zOrder = zOrder;
				_cb();
			}
			
			temporaryPlane.yiDong(targetPos, callback.bind(this));
		}
		
		/**战斗*/
		public function fight(callback, synchFunc, bloodNum, renderBlood):void {
			var hasTask:Boolean = taskQueue.length > 0;
			var _cb = function() {
				callback();
				// 执行完任务后清空
				taskQueue.length = 0;
				isFighting = false;
			};
			
			// 还有未完成的任务
			if (hasTask) {
				synchFunc();
				
			} else {
				isFighting = true;
				taskQueue[0] = _cb;
				taskQueue[1] = synchFunc;
				_peoplePlane.gongji(taskQueue);
				
				flutterText(Number(bloodNum), renderBlood);
			}
		}
		
		/**减血飘字*/
		private function flutterText(num, renderBlood):void {
			var jsonStr:String = ResourceManager.instance.setResURL("imageFont/orangeMin.json");
			var numArr:Array = splitNum(num);
			
			Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}], Handler.create(this, function() {
				for (var i = 0; i < 3; i++) {
					var label:Sprite = createText(numArr[i]);
					timerOnce(i * 800, this, (function(i, label) {
						return function() {
							renderBlood && renderBlood(numArr[i]);
							label.visible = true;
							Tween.to(label, {y: label.y - 70}, 800, Ease.linearIn, Handler.create(this, function() {
								label.destroy(true);
							}));
						}
					})(i, label));
				}
			}));
		}
		
		/**随机切值*/
		private function splitNum(num:Number):Array {
			var result:Array = [];
			var n1 = ToolFunc.getRandomNumber(num);
			var n2 = ToolFunc.getRandomNumber(num - n1);
			var n3 = num - n1 - n2;
			return [parseInt(n1), parseInt(n2), parseInt(n3)];
		}
		
		/**创建飘字*/
		private function createText(txt:String):Sprite {
			var label:Sprite = ImageFont.createBitmapFont(String(txt), "orangeMin");
			label.pos(this.x, this.y);
			label.zOrder = 10;
			label.visible = false;
			this.parent.addChild(label);
			
			return label;
		}
		
		/**死亡*/
		public function die(callback):void {
			_peoplePlane.siwang(callback);
		}
		
		/**添加黑烟效果动画*/
		public function addSmogEffect():void {
			if (_dom_smog) return;
			var roleAni:Animation = _dom_smog = new Animation();
			var url = "appRes/effects/heiyan.json";
			roleAni.loadAtlas(url, Handler.create(this, function(){
				roleAni.play();
			}));
			roleAni.scale(1.3, 1.3);
			roleAni.pos(-20, -220);
			roleAni.zOrder = 1;
			this.addChild(roleAni);
		}
		
		/**添加保护罩效果*/
		public function addProtectEffect():void {
			if (_dom_protect) return;
			var roleAni:Animation = _dom_protect = new Animation();
			var url = "appRes/atlas/effects/plant_protect.json";
			roleAni.loadAtlas(url, Handler.create(this, function(){
				roleAni.play();
			}));
			roleAni.interval = 100;
			roleAni.scale(1.4, 1.4);
			roleAni.pos(-100, -100);
			roleAni.zOrder = 2;
			this.addChild(roleAni);
		}
		
		/**移除保护罩*/
		public function removeProtectEffect():void {
			if (_dom_protect) {
				_dom_protect.destroy();
				_dom_protect = null;
			}
		}
		
		/**回收飞机和信息元素*/
		private function recoverPlane(node:ChessItem):void {
			this.removeChild(node);
			peoplePlanePool.push(node);
			node.reset();
		}
		
		/**重置*/
		public function reset():void {
			if (_peoplePlane) {
				removePeoplePlane();
			}
			if (_isActivate) {
				isActivate = false;
			}
		}
		
		/**清空飞机对象池*/
		public static function recoverPool():void {
			peoplePlanePool.forEach(function(item:ChessItem){
				item.reset();
				item.destroy();
			});
			peoplePlanePool.length = 0;
			
			ChessItem.clearLoadedAni();
		}
	}

}