package game.module.mineFight 
{
	import MornUI.mineFight.MineFightViewUI;
	import MornUI.mineFight.MineScenceUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.ItemTips;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.common.baseScene.BaseScene;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineFightScence extends BaseScene 
	{
		
		private var _scenceView:MineScenceUI;
		
		private var _mineContainer:MineContainer;
		private var _mineData:Array = [];
		private var _mineIndex:int = 0;
		
		private var _fightTimes:int = 0;
		private var _buyTimes:int = 0;
		private var _protectTimes:int = 0;
		
		private var _mTime:int = 0;
		private var _pTime:int = 0;
		
		private var needCount:Boolean = false;
		
		private var i1:Image;
		private var i2:Image;
		private var i3:Image;
		private var i4:Image;
		
		private var _starArr:Array = [];
		private var _starPos:Array = [495, 480, 465, 450, 435];
		
		public function MineFightScence(URL:String = "", isCanDrag:Boolean=true) 
		{
			super(URL, isCanDrag);
		}
		
		override protected function loadMap():void {
			loadMapCallBack();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case i1:
					ItemTips.showTip(1);
					break;
				case i4:
					ItemTips.showTip(5);
					break;
				case i2:
				case i3:
					ItemTips.showTip(13);
					break;
				case this.scenceView.buyDefenceBtn:
					
					if (!GameConfigManager.mine_protect_price_vec[_protectTimes])
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57006"));
						return;
					}
					cost = GameConfigManager.mine_protect_price_vec[_protectTimes].price;
					//str = "本次购买防护盾需要花费" + GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name) + cost.split("=")[1] +"";
					str = GameLanguage.getLangByKey("L_A_57007");
					str = str.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name));
					str = str.replace("{1}", cost.split("=")[1]);
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_57007"),
																			cost.split("=")[0],
																			cost.split("=")[1],
																			function() {
																				if (User.getInstance().water < parseInt(cost.split("=")[1]))
																				{
//																					if(GameSetting.IsRelease)
//																					{
//																						XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//																					}
//																					else
//																					{
																						XFacade.instance.openModule(ModuleName.ChargeView);
//																					}
																				}
																				else
																				{
																					WebSocketNetService.instance.sendData(ServiceConst.BUY_PROTECT_TIMES, []);
																				}
																			}]);
					
					/*AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
									if (v == AlertType.RETURN_YES)
									{
										WebSocketNetService.instance.sendData(ServiceConst.BUY_PROTECT_TIMES, []);
									}
								});*/
					break;	
				case this.scenceView.addTimesBtn:
					if (_fightTimes >= 10)
					{
						return;
					}
					//trace("购买次数", GameConfigManager.intance.getBuyMineTimesPrice(_buyTimes));
					
					cost = GameConfigManager.intance.getBuyMineTimesPrice(_buyTimes);
					
					//str = "购买当前次数需要花费" + GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name) + cost.split("=")[1] +"";
					str = GameLanguage.getLangByKey("L_A_57008");
					str = str.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name));
					str = str.replace("{1}", cost.split("=")[1]);
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_57008"),
																			cost.split("=")[0],
																			cost.split("=")[1],
																			function() {
																				if (User.getInstance().water < parseInt(cost.split("=")[1]))
																				{
//																					if(GameSetting.IsRelease)
//																					{
//																						XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//																					}
//																					else
//																					{
																						XFacade.instance.openModule(ModuleName.ChargeView);
//																					}
																				}
																				else
																				{
																					WebSocketNetService.instance.sendData(ServiceConst.BUY_MINE_TIMES);
																				}
																			}]);
									
					
					
					/*AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
									if (v == AlertType.RETURN_YES)
									{
										WebSocketNetService.instance.sendData(ServiceConst.BUY_MINE_TIMES, []);
									}
								});*/
					break;
				case this.scenceView.recieveBtn:
					WebSocketNetService.instance.sendData(ServiceConst.GET_MINE_RESULT);
					break;
				case this.scenceView.deployBtn:
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SET_KUANGCHANG);
					break;
				case this.scenceView.backBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				case this.scenceView.closeBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
					break;
				default:
					break;
				
			}
		}
		
		protected function loadMapCallBack():void
		{
			super.onMapLoaded();
			this.m_SceneResource = "MineFightScence";
			
			_scenceView = new MineScenceUI();
			this.addChild(_scenceView);
			
			_scenceView.dunBg.disabled = true;
			_scenceView.dunImg.disabled = true;
			
			_mineContainer = new MineContainer();
			this.addChild(_mineContainer);
			
			i1 = new Image();
			i1.skin = GameConfigManager.getItemImgPath(1);
			i1.x = 500;
			i1.y = 45;
			i1.width = i1.height = 50;
			i1.mouseEnabled = true;
			scenceView.addChild(i1);
			
			i2 = new Image();
			i2.skin = GameConfigManager.getItemImgPath(13);
			i2.x = 635;
			i2.y = 45;
			i2.width = i2.height = 50;
			i2.mouseEnabled = true;
			scenceView.addChild(i2);
			
			i4 = new Image();
			i4.skin = GameConfigManager.getItemImgPath(5);
			i4.x = 365;
			i4.y = 45;
			i4.width = i4.height = 50;
			i4.mouseEnabled = true;
			scenceView.addChild(i4);
			
			i3 = new Image();
			i3.skin = GameConfigManager.getItemImgPath(13);
			i3.x = 105;
			i3.y = 8;
			i3.width = i3.height = 50;
			i3.mouseEnabled = true;
			scenceView.reciveArea.addChild(i3);
			
			for (var i:int = 0; i < 5; i++) 
			{
				_starArr[i] = _scenceView["s" + i];
			}
			
			_scenceView.remTimeArea.mouseEnabled = true;
			_scenceView.deployArea.mouseEnabled = true;
			_scenceView.reciveArea.mouseEnabled = true;
			
			
			stageSizeChange();
		}
		
		private function refreshInfo():void
		{
			scenceView.num0TF.text = User.getInstance().water;
			scenceView.num1TF.text = User.getInstance().minePoint;
			scenceView.num2TF.text = User.getInstance().food;
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("矿场消息", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.BUY_MINE_TIMES:
					//_pTime = args[1].cdTime;
					_protectTimes = args[1].mineUserStatus.cd_num;
					_fightTimes = parseInt(args[1].mineUserStatus.challenge_num);
					scenceView.attTF.text = _fightTimes;
					
					break;
				case ServiceConst.BUY_PROTECT_TIMES:
					_pTime = args[1].cdTime;
					_protectTimes = args[1].mineUserStatus.cd_num;
					break;
				case ServiceConst.GET_MINE_RESULT:
					var rData:ItemData=new ItemData();
					rData.iid = 13;
					rData.inum=parseInt(_scenceView.cumTF.text);
					
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[[rData]]);
					WebSocketNetService.instance.sendData(ServiceConst.ENTER_MINE, [_mineData[_mineIndex].mine_star_id]);
					break;
				case ServiceConst.MINE_INIT:
					_mineData = args[1].mineAreaInfo.mine_stars;
					User.getInstance().minePoint = args[1].minePoint;
					_mineContainer.dataSource = _mineData[_mineIndex];
					WebSocketNetService.instance.sendData(ServiceConst.ENTER_MINE, [_mineData[_mineIndex].mine_star_id]);
					break;
				case ServiceConst.ENTER_MINE:
					_mineContainer.setMineDetail(args[1].minePointInfos);
					if (args[1].mineUserReward.length)
					{
						_scenceView.cumTF.text = args[1].mineUserReward[0].num;
					}
					else
					{
						_scenceView.cumTF.text = "0";
					}
					_protectTimes = args[1].mineUserStatus.cd_num;
					_buyTimes = args[1].mineUserStatus.buy_challenge_num_count;
					_fightTimes = parseInt(args[1].mineUserStatus.challenge_num);
					scenceView.attTF.text = _fightTimes+"";
					_scenceView.dPowerTF.text = args[1].power;
					
					_mTime = args[1].mineTime;
					needCount = true;
					
					if (parseInt(args[1].isInMinePoint) == 0)
					{
						needCount = false;
					}
					
					_pTime = args[1].cdTime;
					mineTimeCount();
					
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function mineTimeCount():void
		{
			if(needCount)
			{
				_mTime--;
			}
			scenceView.rtTF.text = (_mTime <= 0)?"00:00:00":TimeUtil.getTimeCountDownStr(_mTime, false);
			
			if (_mTime <= 0)
			{
				_fightTimes = 0;
				scenceView.attTF.text = _fightTimes+"";
				this.scenceView.addTimesBtn.disabled = true;
			}
			else
			{
				this.scenceView.addTimesBtn.disabled = false;
			}
			
			if (_mTime >0 && _mTime % 60 == 0 && needCount)
			{
				WebSocketNetService.instance.sendData(ServiceConst.ENTER_MINE, [_mineData[_mineIndex].mine_star_id]);
			}
			
			_pTime--;
			//trace("_pTime: ", _pTime);
			scenceView.defenTimeTF.text = (_pTime <= 0)?"00:00:00": TimeUtil.getTimeCountDownStr(_pTime, false);
			if (_pTime <= 0)
			{
				User.getInstance().mineIsProtect = false;
				_scenceView.dunBg.disabled = true;
				_scenceView.dunImg.disabled = true;
			}
			else
			{
				User.getInstance().mineIsProtect = true;
				_scenceView.dunBg.disabled = false;
				_scenceView.dunImg.disabled = false;
			}
			
		}
		
		override public function initScence():void
		{
			super.initScence();
		}
		
		public override function show(...args):void{
			
			super.show(args);
			addEvent();
			
			_mineIndex = args[0][1];
			_mineData = args[0][0];
			_scenceView.titleTF.text = args[0][2];
			_mineContainer.dataSource = _mineData[_mineIndex];
			
			_scenceView.attTF.text = "";
			_scenceView.dPowerTF.text = 0;
			for (var i:int = 0; i < 5; i++) 
			{
				_starArr[i].x = _starPos[_mineIndex] + i * 37;
				_starArr[i].visible = true;
				if (i > _mineIndex)
				{
					_starArr[i].visible = false;
				}
			}
			
			scenceView.num0TF.text = User.getInstance().water;
			scenceView.num1TF.text = BagManager.instance.getItemNumByID(13);
			
			if (BagManager.instance.getItemNumByID(13) == 0)
			{
				BagManager.instance.initBagData();
			}
						
			WebSocketNetService.instance.sendData(ServiceConst.ENTER_MINE, [_mineData[_mineIndex].mine_star_id]);
			
			UIRegisteredMgr.AddUI(_scenceView.closeBtn, "$MineFightCloseBtn");
			
		}
		
		override public function dispose():void{
			UIRegisteredMgr.DelUi("$MineFightCloseBtn");
		}
		
		public override function close():void{
			super.close();
			removeEvent();
			_mineContainer.clear();
			
		}
		
		protected override function onLoaded():void{
			super.onLoaded();
		}
		
		override public function addEvent():void {
			scenceView.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ENTER_MINE), this, serviceResultHandler, [ServiceConst.ENTER_MINE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MINE_INIT),this,serviceResultHandler,[ServiceConst.MINE_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MINE_RESULT),this,serviceResultHandler,[ServiceConst.GET_MINE_RESULT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUY_PROTECT_TIMES),this,serviceResultHandler,[ServiceConst.BUY_PROTECT_TIMES]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUY_MINE_TIMES),this,serviceResultHandler,[ServiceConst.BUY_MINE_TIMES]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshInfo);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,refreshInfo);
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			Laya.timer.loop(1000, this, this.mineTimeCount);
			
			super.addEvent();
		}
		
		override public function removeEvent():void {
			
			scenceView.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ENTER_MINE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MINE_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MINE_RESULT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUY_PROTECT_TIMES),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUY_MINE_TIMES),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			Signal.intance.off(User.PRO_CHANGED, this, this.refreshInfo);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, refreshInfo);
			
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
			Laya.timer.clear(this, this.mineTimeCount);
			
			super.removeEvent();
			
			//Signal.intance.off(MainView.BACK, this, this.onBack);
			
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			_scenceView.size(Laya.stage.width , Laya.stage.height);
			var scaleNum:Number =  Laya.stage.width / _scenceView.mineBg.width;
			
			_scenceView.mineBg.scaleX = _scenceView.mineBg.scaleY = scaleNum;
			_scenceView.mineBg.y = ( Laya.stage.height - _scenceView.mineBg.height * scaleNum ) / 2;
			
			_scenceView.remTimeArea.y = Laya.stage.height - 108;
			_scenceView.deployArea.y = Laya.stage.height - 110;
			_scenceView.reciveArea.y = Laya.stage.height - 119;
			
			_mineContainer.y = (Laya.stage.height - 430)/2;
		}
		
		public function get scenceView():MineScenceUI 
		{
			return _scenceView;
		}
		
	}

}