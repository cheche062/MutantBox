package game.module.fighting.panel
{
	import game.common.ResourceManager;
	import game.common.XTip;
	
	import laya.events.Event;

	public class PTChapterLevelPanel extends ChapterLevelPanel
	{

		private var url:String = "config/stage_buy.json";
		public function PTChapterLevelPanel()
		{
			super();
		}
		
		override protected function ackClick(e:Event):void
		{
			var stage_param_json:Object=ResourceManager.instance.getResByURL(url);
			trace("普通购买参数表:"+JSON.stringify(stage_param_json));
			var upTimes:Number;
			for each(var obj:Object in stage_param_json)
			{
				upTimes = obj["up"];
			}
			if(buyTimer>=upTimes)
			{
				XTip.showTip("L_A_1067");
				return;
			}
			// TODO Auto Generated method stub
			super.ackClick(e);
		}
		
		override protected function addClick(e:Event=null):void
		{
			var stage_param_json:Object=ResourceManager.instance.getResByURL(url);
			trace("普通关卡购买参数表:"+JSON.stringify(stage_param_json));
			var upTimes:Number;
			trace("普通_购买次数:"+buyTimer);

			for each(var obj:Object in stage_param_json)
			{
				upTimes = obj["up"];
			}
			if(buyTimer>=upTimes)
			{
				XTip.showTip("L_A_1067");
				return;
			}

			// TODO Auto Generated method stub
			super.addClick(e);
		}
		
	}
}