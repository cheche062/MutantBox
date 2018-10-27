package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossEnterUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	
	import laya.events.Event;
	
	/**
	 * 进入BOSS的首个小弹窗 
	 * @author hejianbo
	 * 2018-04-19 17:56:58
	 */
	public class WorldBossEnterView extends BaseDialog
	{
		private var state:int = 0;
		/**是否已经预设过*/
		private var BOSSID:String = "";
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		/**总秒数*/
		private var totalTime:Number = 0;
		/**buff*/
		private var buff:Array;
		/**结束时间*/
		private var endTime:Number;
		/**粮草保护*/
		private var foodProtection:Number;
		
		
		public function WorldBossEnterView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void {
			this.addChild(view);
			visible = false;
		}
		
		override public function show(... args):void {
			super.show();
			
			AnimationUtil.flowIn(this);
			
			sendData(ServiceConst.BOSS_OPEN_VIEW);
			
			var text = GameLanguage.getLangByKey("L_A_85003").replace(/##/g, '\n');
			view.dom_text.text = text;
			
			view.btn_confirm.disabled = true; 
			view.btn_mission.disabled = true;
			view.btn_rank.disabled = true;
			
			view.dom_time.text = "";
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.btn_close:
					close();
					break;
				
				case view.btn_confirm:
//					XFacade.instance.openModule(ModuleName.WorldBossFightView, [state, totalTime, BOSSID, buff, endTime]);
					close();
					
					break;
				
				// 排行
				case view.btn_rank:
					if (BOSSID) {
						XFacade.instance.openModule(ModuleName.WorldBossRankView, [BOSSID]);
					} else {
						XTip.showTip(GameLanguage.getLangByKey("L_A_85045"));
					}
					
					break;
				
				// 任务榜
				case view.btn_mission:
					XFacade.instance.openModule(ModuleName.WorldBossMissionView);
					
					break;
				
			}
		}
		
		/**获取倒计时时间*/
		private function getCountDownTime(time):Number {
			var result = parseInt(time - parseInt(TimeUtil.now / 1000));	
			return result > 0 ? result : 0;
		}
		
		private function onServerResult(... args):void {
			var cmd = args[0];
			var result = args[1];
//			result = {"bossId":"4_1","boss_status":1,"start_time":1524198838,"end_time":1524160800};
			trace('%c boss数据：：', 'color: green', cmd, result);
//			boss_status: //0未开放     1已开放未开始      2已开始       3已结束
			
			state = Number(result["boss_status"]);
			BOSSID = result["bossId"];
			buff = result["buff"];
			endTime = result["end_time"];
			var kill = result["kill"] || "0";
			foodProtection = Number(result["foodProtection"]) || 0;
			
			trace('【结束计时器：】', endTime)
			switch (cmd) {
				//打开界面
				case ServiceConst.BOSS_OPEN_VIEW:
					view.btn_confirm.disabled = false; 
					view.btn_mission.disabled = false;
					view.btn_rank.disabled = false;
					
					switch (state){
						//未开放
						case 0:
							view.dom_time.text = "";
							view.btn_confirm.disabled = true;
							XTip.showTip(GameLanguage.getLangByKey("L_A_20969"));
//							visible = true;
							break;
						//已结束
						case 3:
							view.dom_time.text = "";
							view.btn_confirm.disabled = true;
							view.btn_confirm.label = GameLanguage.getLangByKey("L_A_85054");
							XTip.showTip(GameLanguage.getLangByKey("L_A_85054"));
//							visible = true;
							break;
						
						//已开放未开始
						case 1:
							// 开启倒计时 
							totalTime = getCountDownTime(result["start_time"]);
							
							view.btn_confirm.disabled = false;
							view.btn_confirm.label = GameLanguage.getLangByKey("L_A_85004");
							
							break;
						
						//已开始
						case 2:
							view.dom_time.text = "L_A_21033";
							view.btn_confirm.disabled = false;
							view.btn_confirm.label = GameLanguage.getLangByKey("L_A_85005");
							
							break;
					}
					
					close();
					removeEvent();
					XFacade.instance.openModule(ModuleName.WorldBossFightView, 
						[state, totalTime, BOSSID, buff, endTime, foodProtection, kill]);
					
					break;
			}
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BOSS_OPEN_VIEW), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BOSS_OPEN_VIEW), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.removeEvent();
		}
		
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			close();
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
			
			if (clearTimerHandler) {
				clearTimerHandler();
				clearTimerHandler = null;
			}
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view():WorldBossEnterUI {
			_view = _view || new WorldBossEnterUI();
			return _view;
		}
	}
}