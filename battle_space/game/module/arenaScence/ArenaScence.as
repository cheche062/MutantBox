package game.module.arenaScence 
{
	import game.common.baseScene.BaseScene;
	import game.global.consts.ServiceConst;
	import laya.events.Event;
	import MornUI.arenaScence.ArenaScenceUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaScence extends BaseScene 
	{
		private var _arenaScence:ArenaScenceUI;
		
		public function ArenaScence(URL:String='', isCanDrag:Boolean=true) 
		{
			super(URL, isCanDrag);
			
		}
		override protected function loadMap():void {
			loadMapCallBack();
			
		}
		
		protected function loadMapCallBack():void
		{
			super.onMapLoaded();
			this.m_SceneResource = "MineFightScence";
			
			_arenaScence = new ArenaScenceUI();
			this.addChild(_arenaScence);
			
			stageSizeChange();
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				
			}
		}
		
		override public function initScence():void
		{
			super.initScence();
		}
		
		public override function show(...args):void{
			
			super.show(args);
			addEvent();
		}
		
		public override function close():void{
			super.close();
			removeEvent();
			
			
		}
		
		protected override function onLoaded():void{
			super.onLoaded();
		}
		
		override public function addEvent():void {
			arenaScence.on(Event.CLICK, this, this.onClick);
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			
			super.addEvent();
		}
		
		override public function removeEvent():void {
			
			arenaScence.off(Event.CLICK, this, this.onClick);
			
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
			Laya.timer.clear(this, this.mineTimeCount);
			
			super.removeEvent();
			
			//Signal.intance.off(MainView.BACK, this, this.onBack);
			
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			/*_scenceView.size(Laya.stage.width , Laya.stage.height);
			var scaleNum:Number =  Laya.stage.width / _scenceView.mineBg.width;
			
			_scenceView.mineBg.scaleX = _scenceView.mineBg.scaleY = scaleNum;
			_scenceView.mineBg.y = ( Laya.stage.height - _scenceView.mineBg.height * scaleNum ) / 2;
			
			_scenceView.remTimeArea.y = Laya.stage.height - 108;
			_scenceView.deployArea.y = Laya.stage.height - 110;
			_scenceView.reciveArea.y = Laya.stage.height - 119;*/
		}
		
		public function get arenaScence():ArenaScenceUI 
		{
			return _arenaScence;
		}
		
	}

}