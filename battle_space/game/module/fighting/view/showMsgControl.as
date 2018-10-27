package game.module.fighting.view
{
	import MornUI.fightingViewPvp.msgSelectViewUI;
	import MornUI.fightingViewPvp.msgShowView2UI;
	import MornUI.fightingViewPvp.msgShowViewUI;
	
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.ui.Label;
	import laya.ui.View;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class showMsgControl extends Sprite
	{
		private var view:View;
		public function showMsgControl(left:Boolean = true)
		{
			super();
			if(left) view = new msgShowViewUI;
			else view = new msgShowView2UI;
			
			this.addChild(view);
			this.size(view.width ,view.height);
			this.visible = false;
			this.alpha = 0;
			this.mouseEnabled = false;
		}
		
		
		public function show(text:String):void{
			var txt:Label = view.getChildByName("msgLbl");
			if(txt)
			{
				var str:String = GameLanguage.getLangByKey(text);
				str = str.replace(/##/g, "\n");
				txt.text = str;
			}
			this.visible = true;
			Tween.clearAll(this);
			Laya.timer.clear(this,hide);
			
			Tween.to(this,{alpha:1},200,null,Handler.create(this,showOver));
			
		}
		
		public function showOver():void{
			Laya.timer.once(2000,this,hide);
		}
		
		
		private function hide():void
		{
			Tween.to(this,{alpha:0},200,null,Handler.create(this,hideOver));
		}
		
		private function hideOver():void
		{
			this.visible = false;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			//trace(1,"destroy showMsgControl");
			view = null;
			
			super.destroy(destroyChild);
		}
	}
}