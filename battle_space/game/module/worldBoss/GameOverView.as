package game.module.worldBoss
{
	import MornUI.worldBoss.GameOverViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	
	/**
	 * 世界boss游戏结束的弹层 
	 * @author mutantbox
	 * 2018-05-07 15:37:44
	 */
	public class GameOverView extends BaseDialog
	{
		private var closeCallback:Function = null;
		public function GameOverView()
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.btn_close:
					onClose();
					
					break;
				
				default:
					break;
			}
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			trace('GameOverView', args);
			//参数
			var param:Array = args[0];
			closeCallback = param[2];
			view.dom_kill.text = param[0] || "0";
			
			var isWin:Boolean = param[1]["is_win"] == 1;
			// 输赢
			view.dom_title.skin = isWin ? "worldBoss/gameover/victory.png" : "worldBoss/gameover/lose.png";
			view.dom_bg.gray = !isWin;
			
			var rankData:Array = param[1]["rank_list"].map(function(item) {
				return {
					"name": item["name"],
					"kill": item["kill"]
				};
			})
			rankData.sort(function(a, b) {
				return b["kill"] - a["kill"];
			});
			
			// 数据结果
			var arrayData:Array = rankData.map(function(item, index){
				return {
					"dom_rank": index + 1,
					"dom_name": item["name"],
					"dom_kill": item["kill"]
				}
			});
			
			view.dom_list.array = arrayData;
			
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
			
			if (closeCallback) {
				closeCallback();
				closeCallback = null;
			}
			
			
			XFacade.instance.disposeView(this);
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
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
		
		private function get view():GameOverViewUI
		{
			_view = _view || new GameOverViewUI();
			return _view;
		}
		
		
		
		
	}
}