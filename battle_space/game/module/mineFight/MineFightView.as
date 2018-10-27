package game.module.mineFight 
{
	import MornUI.mineFight.MineFightViewUI;
	
	import game.common.AnimationUtil;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineFightView extends BaseDialog 
	{
		
		private var _mineInfo:Array=[]
		private var _mineStateTF:Vector.<Text> = new Vector.<Text>(5);
		
		private var _remainTime:int = 0;
		private var _seasonOver:Boolean = false;
		
		private var _headPos:Object;
		private var _headIcon:Image;
		private var _circleMask:Sprite;
		
		private var _restTime:int = 0;
		
		public function MineFightView() 
		{
			super();
			_headPos = { };
			_headPos["0"] = [135,390];
			_headPos["1"] = [545,85];
			_headPos["2"] = [194,317];
			_headPos["3"] = [800,200];
			_headPos["4"] = [145,130];
			_headPos["5"] = [430,230];
		}
		
		private function remainTimeCount():void
		{
			_restTime--;
			if (_restTime <= 0 && view.mineCloseArea.visible == true)
			{
				WebSocketNetService.instance.sendData(ServiceConst.MINE_INIT, []);
				_restTime = 0;
			}
			view.restTimeTF.text = TimeUtil.getTimeCountDownStr(_restTime,false);
			
			_remainTime--;
			if (_remainTime <= 0)
			{
				//view.remainTime.text = "--:--:--";
				_seasonOver = true;
				return;
			}
			
			_seasonOver = false;
			//view.remainTime.text = TimeUtil.getTimeCountDownStr(_remainTime,false);
		}
		
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("mineResult: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.MINE_INIT:
					view.battleLogBtn.disabled = false;
					_mineInfo = args[1].mineAreaInfo.mine_stars;
					_remainTime = parseInt(args[1].mineLifeTime) - parseInt(TimeUtil.now / 1000);
					view.mineCloseArea.visible = false;
					len = _mineInfo.length;
					for (i = 0; i < len; i++ )
					{
						_mineStateTF[i].text = _mineInfo[i].user_count + "/" + _mineInfo[i].mine_count;
					}
					view.headContainer.visible = false;
					
					if (args[1].mine_star_id != "")
					{
						var starIndex:String = args[1].mine_star_id.split(":")[5];
						view.headContainer.visible = true;
						view.headContainer.x = _headPos[starIndex][0];
						view.headContainer.y = _headPos[starIndex][1];
						if (args[1].heros.length > 0)
						{
							_headIcon.skin = "appRes/icon/unitPic/" + args[1].heros[0] + "_b.png";
						}
						else
						{
							_headIcon.skin = "appRes/icon/unitPic/0000_b.png";
						}
					}
					break;
				case ServiceConst.MINE_REST_INFO:
					
					_restTime = parseInt(args[1].startTime) - parseInt(TimeUtil.now / 1000);
					view.restTimeTF.text = TimeUtil.getTimeCountDownStr(_restTime,false);
					break;
				default:
					break;
			}
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			
			if (e.target != view.closeBtn && _seasonOver && e.target!=view.battleLogBtn)
			{
				//XTip.showTip("赛季还未开始");
				return;
			}
			
			switch(e.target)
			{
				case view.hBtn:
				case view.bhBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_54016"));
					break;
				case view.battleLogBtn:
					//WebSocketNetService.instance.sendData(ServiceConst.MINE_FIGHT_LOG, [1]);
					XFacade.instance.openModule(ModuleName.MineBattleLogView);
					break;
				case view.oneBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_MINE_FIGHT, true, 1, [_mineInfo,0,_mineStateTF[0].text]);
					break;
				case view.twoBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_MINE_FIGHT, true, 1, [_mineInfo,1,_mineStateTF[1].text]); 
					break;
				case view.threeBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_MINE_FIGHT, true, 1, [_mineInfo,2,_mineStateTF[2].text]);
					break;
				case view.fourBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_MINE_FIGHT, true, 1, [_mineInfo,3,_mineStateTF[3].text]); 
					break;
				case view.fiveBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_MINE_FIGHT, true, 1, [_mineInfo,4,_mineStateTF[4].text]); 
					break;
				case view.mineShopBtn:
					XFacade.instance.openModule(ModuleName.MineShopView);
					break;
				case view.btn_ascending:
					close();
					XFacade.instance.openModule(ModuleName.NewUnitInfoView, [0, 0]);
					break;
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
			
			WebSocketNetService.instance.sendData(ServiceConst.MINE_INIT, []);
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			
			
			if (errStr == "L_A_908003") {
				_seasonOver = true;
				view.battleLogBtn.disabled = true;
				view.mineCloseArea.visible = true;
				WebSocketNetService.instance.sendData(ServiceConst.MINE_REST_INFO, []);
			}
			else
			{
				XTip.showTip( GameLanguage.getLangByKey(errStr));
			}
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			//super.dispose();
			UIRegisteredMgr.DelUi("FiveStarMine");
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new MineFightViewUI();
			this.addChild(_view);
			
			GameConfigManager.intance.initMineData();
			
			_mineStateTF[0] = view.oneTF;
			_mineStateTF[1] = view.twoTF;
			_mineStateTF[2] = view.threeTF;
			_mineStateTF[3] = view.fourTF;
			_mineStateTF[4] = view.fiveTF;
			
			for (var i:int = 0; i < 5; i++ )
			{
				_mineStateTF[i].text = "";
			}
			_headIcon = new Image();
			_headIcon.x = -15;
			_headIcon.y = -15;
			_headIcon.mouseEnabled = false;
			view.headContainer.addChild(_headIcon);
			
			_circleMask = new Sprite();
			_circleMask.x = 15;
			_circleMask.y = 15;
			_circleMask.graphics.drawCircle(35, 35, 26, '#ffffff');
			
			view.mineCloseArea.mouseEnabled = true;
			view.mineCloseArea.mouseThrough = false;
			view.mineCloseArea.visible = false;
			
			_headIcon.mask = _circleMask;
			_headIcon.skin = "appRes/icon/unitPic/1009_b.png";
			view.headContainer.visible = false;
			
			UIRegisteredMgr.AddUI(view.fiveBtn, "FiveStarMine");
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MINE_INIT), this, serviceResultHandler, [ServiceConst.MINE_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MINE_REST_INFO), this, serviceResultHandler, [ServiceConst.MINE_REST_INFO]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Laya.timer.loop(1000, this, this.remainTimeCount);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MINE_INIT), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MINE_REST_INFO), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
			Laya.timer.clear(this, this.remainTimeCount);
			
			super.removeEvent();
		}
		
		
		
		private function get view():MineFightViewUI{
			return _view;
		}
	}

}