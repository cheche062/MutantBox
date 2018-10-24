package game.module.fighting.view
{
	import MornUI.fightingViewPvp.msgSelectViewUI;
	
	import game.global.GameConfigManager;
	import game.module.fighting.cell.msgItemCell;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class msgSelectViewControl extends msgSelectViewUI
	{
		public function msgSelectViewControl()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			setType(1);
			
			msgList.itemRender = msgItemCell;
			msgList.array = GameConfigManager.quickMsgList;
			msgList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			msgList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			msgList.scrollBar.visible = false;
			
		}
		
		private function msgBtnClick(e:Event):void
		{
			setType(2,true);
			e.stopPropagation();
		}
		
		//t = 1 收起  2 展开
		private var _t:Number;
		public function setType(t:Number,move:Boolean = false):void
		{
			if(_t != t)
			{
				_t = t;
				var vs:Array = [this.msgBtn,this.listBox];
				if(t == 2)
				{
					vs = [this.listBox,this.msgBtn];
				}
				if(move)
				{
					moverFun(vs);
					return ;
				}
				vs[0].scaleY = 1;
				vs[0].visible = true;
				vs[1].scaleY = .01;
				vs[1].visible = false;
				
			}
		}
		
		private function moverFun(vs:Array ):void
		{
			var sp1:Sprite = vs[0];
			var sp2:Sprite = vs[1];
			sp1.visible = false;
			sp1.scaleY = 0.01;
			sp2.visible = true;
			Tween.clearAll(sp1);
			Tween.clearAll(sp2);
			Tween.to(sp2,{scaleY:.01},100,null,Handler.create(this,moverFun2,[vs]));
		}
		
		private function moverFun2(vs:Array ):void
		{
			var sp1:Sprite = vs[0];
			var sp2:Sprite = vs[1];
			sp1.visible = true;
			sp1.scaleY = 0.01;
			sp2.visible = false;
			Tween.clearAll(sp1);
			Tween.clearAll(sp2);
			Tween.to(sp1,{scaleY:1},100);
			
		}
		
		private function msgListFun(e:Event):void{
			e.stopPropagation();
		}
		
		public function addEvent():void
		{
			this.msgBtn.on(Event.CLICK,this,msgBtnClick);
			Laya.stage.on(Event.CLICK,this,setType,[1,true]);
			msgList.on(Event.CLICK,this,msgListFun);
		}
		
		public function removeEvent():void
		{
			this.msgBtn.off(Event.CLICK,this,msgBtnClick);
			Laya.stage.off(Event.CLICK,this,setType);
			msgList.off(Event.CLICK,this,msgListFun);
		}
		
	}
}