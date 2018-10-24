package game.module.guild
{
	import game.global.GameConfigManager;
	import game.global.vo.guild.GuildWelfareVo;
	import MornUI.guild.GuildWelfareViewUI;
	
	import game.common.base.BaseView;
	
	import laya.events.Event;
	
	public class GuildWelfareView extends BaseView
	{
		public function GuildWelfareView()
		{
			super();
			this.on(Event.ADDED, this, this.addToStage);
		}
		
		private function addToStage(e:Event):void 
		{
			
			
			var welVec:Vector.<GuildWelfareVo> = new Vector.<GuildWelfareVo>()
			for (var i:int = 0; i < 3; i++ )
			{
				welVec[i] = GameConfigManager.intance.getGuildWelf((i+1).toString(), "1");
			}
			//trace("welfare: ", GameConfigManager.guild_welfare_vec);
			//trace("welfare: ", welVec);
			view.welfareList.array = welVec;
		}
		
		private function onClick(e:Event):void
		{
			
			switch (e.target)
			{
			
			}
		}
		
		override public function show(... args):void
		{
			super.show();
			
		}
		
		override public function close():void
		{
		
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function createUI():void
		{
			this._view = new GuildWelfareViewUI();
			this.addChild(_view);
			_view.x = 5;
			_view.y = 45;
			
			var testData:Array = [{wName: "ATTACK ENHANCED", wlv: "1", enhancedNum: "10", time: "0.5", price: "1234"}, {wName: "ATTACK ENHANCED", wlv: "1", enhancedNum: "15", time: "1", price: "1234"}, {wName: "ATTACK ENHANCED", wlv: "1", enhancedNum: "20", time: "1.5", price: "1234"}, {wName: "ATTACK ENHANCED", wlv: "1", enhancedNum: "25", time: "2", price: "1234"}];
			//init scrollbar
			
			view.welfareList.itemRender = WelfareItem;
			view.welfareList.selectEnable = true;
			//view.welfareList.array = testData;
		
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():GuildWelfareViewUI
		{
			return _view;
		}
	}
}