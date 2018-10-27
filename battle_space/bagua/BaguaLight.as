package game.module.bagua
{
	import MornUI.bagua.baguaLightUI;
	
	import laya.display.Graphics;
	import laya.events.Event;
	import laya.utils.HitArea;
	
	public class BaguaLight extends baguaLightUI
	{
		public static var changeSelectHandler:Function;
		/**
		 * 索引->坐标 & 角度  映射表 
		 */
		private static const POSITION_MAP:Array = [
			[403, 467, 149],
			[286, 500, 184],
			[167, 458, 221],
			[95, 359, 253],
			[90, 231, 289],
			[161, 126, 325],
			[282, 82, 361],
			[404, 116, 395]
		]
		/**状态*/
		private var _state:BaguaLightStateVo;
		
		public function BaguaLight()
		{
			super();
			
			init();
		}
		
		private function init():void{
			// 初始化
			state = new BaguaLightStateVo();
				
			setHitArea();
		}
		
		public function show():void{
			addEvent();
		}
		
		public function hide():void{
			removeEvent();
		}
		
		/**更新状态*/
		private function updateState(state:BaguaLightStateVo):void{
			// 显示坐标 & 角度
			var arr:Array = POSITION_MAP[state.index];
			this.pos(arr[0], arr[1]);
			this.rotation = arr[2];
			
			var _i:Number = -1;
			if (state.isComplete) {
				_i = 1;
				
			} else if (state.isSelected) {
				_i = 0;
			}
			
			this.dom_clip.index = _i;
			this.dom_num.text = String(state.peopleNum);
			// 只有有人数后才显示
			this.dom_people.visible = (Number(state.peopleNum) != 0);
		}
		
		private function clickHandler():void{
			changeSelectHandler(_state.index);
		}
		
		private function addEvent():void{
			this.on(Event.CLICK, this, clickHandler);
		}
		
		private function removeEvent():void{
			this.offAll(Event.CLICK);
		}
		
		/**设置点击区域*/
		private function setHitArea():void{
			var g:Graphics = new Graphics();
			drawFn(g);
			var hitArea:HitArea = new HitArea();
			hitArea.hit = g;
			this.hitArea = hitArea;
			
			// 方便观察
//			drawFn(this.graphics);
		}
		
		/**
		 * 对graphics绘制多边形 
		 * @param g
		 * 
		 */
		private function drawFn(g:Graphics):void{
			var points:Array = [21, 30, 168, 30, 140, 134, 58, 134];
			g.clear();
			g.drawPoly(0, 0, points, '#000');
		}
		
		public function get state():BaguaLightStateVo{
			return _state;
		}
		
		/**更新状态*/
		public function set state(value:BaguaLightStateVo):void{
			_state = value;
			updateState(_state);
		}
		
		
	}
}