package game.module.waterLottery 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.HitArea;
	import MornUI.waterLottery.WaterLotteryRuleUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WaterLotteryRuleView extends BaseDialog 
	{
		
		public function WaterLotteryRuleView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			
			super.show();
			AnimationUtil.flowIn(this);
			
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new WaterLotteryRuleUI();
			this.addChild(_view);
			
			var mask:Sprite=new Sprite();
			mask.width = 532;
			mask.height = 304;
			mask.graphics.drawRect(0,0,532,304,'#FF0000');
			view.sheetContainer.mask = mask;
			
			view.ruleSheet.mouseEnabled = true;
			
			var g:Graphics = new Graphics();
			g.drawRect(0, 0, 532, 804, "#ffff00");
			var hitArea:HitArea = new HitArea();
			hitArea.hit = g;
			view.ruleSheet.hitArea = hitArea;
		}
		
		private function starDropHandler(e:Event):void
		{
			view.ruleSheet.startDrag(new Rectangle(0,-500,0,500), true);			
			//view.ruleSheet.startDrag();			
		}
		
		/***/
		private function onScale(e:Event):void
		{
			if (e.delta > 0)
			{
				view.ruleSheet.y += 10;
			}
			else
			{
				view.ruleSheet.y -= 10;
			}
			
			if (view.ruleSheet.y >= 0)
			{
				view.ruleSheet.y = 0;
			}
			
			if (view.ruleSheet.y <= -500)
			{
				view.ruleSheet.y = -500;
			}
		}
		
		
		private function stopDropHandler(e:Event):void
		{
			
			view.ruleSheet.stopDrag();
		}
		
		/**保留*/
		override public function dispose():void{
			
		}
		
		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			view.ruleSheet.on(Event.MOUSE_DOWN, this, this.starDropHandler);
			view.ruleSheet.on(Event.MOUSE_UP, this, this.stopDropHandler);
			
			this.on(Event.MOUSE_WHEEL, this, this.onScale);
			
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			
			view.ruleSheet.off(Event.MOUSE_DOWN, this, this.starDropHandler);
			view.ruleSheet.off(Event.MOUSE_UP, this, this.stopDropHandler);
			
			this.off(Event.MOUSE_WHEEL, this, this.onScale);
			
			super.removeEvent();
		}
		
		
		private function get view():WaterLotteryRuleUI{
			return _view;
		}
	}

}