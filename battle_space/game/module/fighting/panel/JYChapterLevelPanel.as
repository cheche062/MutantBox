package game.module.fighting.panel
{
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.StageLevelVo;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;

	public class JYChapterLevelPanel extends ChapterLevelPanel
	{
		public function JYChapterLevelPanel()
		{
			super();
			buyUrl = "config/elite_buy.json";
			_sType = 1;
		}
		
		protected override function get stageLevelDic():Object{
			return GameConfigManager.stage_level_jy_dic;
		}
		
		protected function fightingFun():void
		{
			var vo:StageLevelVo = stageLevelDic[thisData.id];
			var cId:Number = vo.chapter_id;
			if(!thisData.star)
				cId = 0;
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_JINGYING,vo.id,Handler.create(this,fBackFunction,[vo.chapter_id]));
			
			this.close()
		}
		
		protected override function fBackFunction(cid:Number):void{
			var ar:Array = [2];
			if(cid)
				ar.push(cid - 1);
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,ar);
		}
		
		protected function buyTimerFun():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_MAP_BUY_TIMER_JY,[thisData.id]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_MAP_BUY_TIMER_JY),
				this,buyTimerBack);
		}
		private var url:String = "config/elite_buy.json";
		override protected function ackClick(e:Event):void
		{
			// TODO Auto Generated method stub
			var stage_param_json:Object=ResourceManager.instance.getResByURL(url);
			trace("精英购买参数表:"+JSON.stringify(stage_param_json));
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
			super.ackClick(e);
		}
		
		override protected function addClick(e:Event=null):void
		{
			var stage_param_json:Object=ResourceManager.instance.getResByURL(url);
			trace("精英购买参数表:"+JSON.stringify(stage_param_json));
			var upTimes:Number;
			trace("精英buyTimer:"+buyTimer);
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