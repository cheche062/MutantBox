package game.module.mainScene.guest
{
	import MornUI.mainView.GuestMenuUI;
	
	import game.common.LayerManager;
	import game.common.SceneManager;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	
	import laya.events.Event;
	
	/**
	 * GeustMenuView
	 * author:huhaiming
	 * GeustMenuView.as 2017-4-28 下午5:57:38
	 * version 1.0
	 *
	 */
	public class GuestMenuView extends BaseView
	{
		public function GuestMenuView()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case this.view.backBtn:
					this.close();
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
			this.onStageResize();			
			var data:Object = args[0].role_info;
			this.view.nameTF.text = data.base.name+"";
			this.view.lvTF.text = data.level+""
		}
		
		override public function close():void{
			super.close();
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		//布局
		override public function onStageResize():void{
			this.view.rightDownBox.x = LayerManager.instence.stageWidth - this.view.rightDownBox.width;
			this.view.rightDownBox.y = LayerManager.instence.stageHeight - this.view.rightDownBox.height;
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			this._view = new GuestMenuUI();
			this.addChild(this._view);
			this._view.mouseThrough = true;
			this.mouseThrough = true;
			this.cacheAsBitmap = true;
		}
		
		private function get view():GuestMenuUI{
			return this._view as GuestMenuUI;
		}
	}
}