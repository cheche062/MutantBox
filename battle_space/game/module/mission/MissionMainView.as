package game.module.mission 
{
	import game.common.XFacade;
	import game.global.data.bag.ItemData;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.mission.DailyScoreVo;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.User;
	import MornUI.mission.MissionMainViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.mission.MissionStateVo;
	import game.global.vo.mission.MissionVo;
	import game.module.guild.GuildListItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MissionMainView extends BaseDialog 
	{
		
		private var _missionDataVec:Vector.<MissionStateVo> = new Vector.<MissionStateVo>();
		private var _dailyDataVec:Vector.<MissionStateVo> = new Vector.<MissionStateVo>();
		
		private var _achieveDataVec:Vector.<MissionStateVo> = new Vector.<MissionStateVo>();
		private var _dailyScoreVec:Vector.<DailyScoreVo> = new Vector.<DailyScoreVo>();
		
		private var _curName:String;
		
		private var _isNewerEnter:Boolean = false;
		
		public function MissionMainView() 
		{
			super();
			
			
			
		}
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					/*if (_isNewerEnter)
					{
						XFacade.instance.openModule(ModuleName.ActivityMainView);
					}*/
					break;
				case this.view.missionBtn:
				case this.view.achieveBtn:
				case this.view.challengeBtn:
					clearTabSelectState();
					(e.target as Button).selected = true;
					changeTabView(e.target.name);
					break;
				default:
					break;
				
			}
		}
		
		private function changeTabView(btnName:String):void
		{
			if(_curName == btnName)
			{
				return;
			}
			_curName = btnName;
			switch(_curName)
			{
				case "mission":
					this.view.mTip.visible = false;
					this.view.missionList.visible = true;
					this.view.achieveList.visible = false;
					break;
				case "achieve":
					this.view.aTip.visible = false;
					this.view.missionList.visible = false;
					this.view.achieveList.visible = true;
					break;
				case "challenge":
					this.view.missionList.visible = false;
					this.view.achieveList.visible = false;
					break;
				default:
					break;
			}
		}
		
		private function clearTabSelectState():void
		{
			
			this.view.missionBtn.selected = false;
			this.view.challengeBtn.selected = false;
			this.view.achieveBtn.selected = false;
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("mission: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
				case ServiceConst.MISSION_INIT_DATA:
					var mData:Object = args[1].list;
					switch(args[1].type)
					{
						//case "main":
						case "daily":
							for (var md:String in mData)//"221":[0,[],1519718560,0,0,0]
							{
								var stateData:MissionStateVo = new MissionStateVo();
								stateData.id = md;
								stateData.state = parseInt(mData[md][0]);
								stateData.currentInfo = mData[md][1][1]?mData[md][1][1]:[];
								
								if (!GameConfigManager.missionInfo[md])
								{
									trace("更新任务失败:", md);
									continue;
								}
								
								if (args[1].type == "daily")
								{
									updateMissionArray(_dailyDataVec, stateData);
								}
								
								/*if (stateData.state != 2)
								{
									if (args[1].type == "main")
									{
										//updateMissionArray(_missionDataVec, stateData);
									}
									else
									{
										updateMissionArray(_dailyDataVec, stateData);
									}
								}*/
							}
							
							_dailyDataVec.sort(sortByID);
							updataFinishState("m");
							orderByState();
							this.view.missionList.dataSource = _dailyDataVec;
							
							User.getInstance().dailyScore = args[1].point_info.total_point;
							updataDailyScore(args[1].point_info.get_log);
							this.view.achieveList.dataSource = _dailyScoreVec;
							
							break;
						case "archive":
							this.view.achieveList.array = [];
							for (var ad:String in mData)
							{
								var achieveData:MissionStateVo = new MissionStateVo();
								achieveData.id = ad;
								achieveData.state = parseInt(mData[ad][0]);
								achieveData.currentInfo = mData[ad][1][1]?mData[ad][1][1]:[];
								
								updateMissionArray(_achieveDataVec, achieveData);
							}
							updataFinishState("a");
							this.view.achieveList.array = _achieveDataVec;
							break;
						default:
							break;
					}
					break;
				case ServiceConst.GET_MISSION_PROGRESS:
					var updataArr:Array = args[1];
					var len:int = updataArr.length;
					for (i = 0; i < len; i++)
					{
						var upDataInfo:MissionStateVo = new MissionStateVo();
						upDataInfo.id = updataArr[i].task_id;
						upDataInfo.state = parseInt(updataArr[i].task_info[0]);
						upDataInfo.currentInfo = updataArr[i].task_info[1][1]?updataArr[i].task_info[1][1]:[];
						if (!GameConfigManager.missionInfo[upDataInfo.id])
						{
							//trace("任务:" + upDataInfo.id + "更新失败");
							return;
						}
						switch(GameConfigManager.missionInfo[upDataInfo.id].type)
						{
							/*case "1":
								updateMissionArray(_missionDataVec, upDataInfo);
								combinaDataVec();						
								updataFinishState("m")
								view.missionList.array = _comboDataVec;
								break;*/
							case "2":
								updateMissionArray(_dailyDataVec, upDataInfo);
								_dailyDataVec.sort(sortByID);
								updataFinishState("m")
								view.missionList.dataSource = _dailyDataVec;
								break;
							case "3":
								
								updateMissionArray(_achieveDataVec, upDataInfo);
								updataFinishState("a");
								view.achieveList.refresh();
								break;
							default:
								break;
						}
					}
					break;
				case ServiceConst.GET_MISSION_REWARD:
				case ServiceConst.GET_DAILY_SCORE_REWARD:
					var ar:Array = [];
					var list:Array = args[1];
					len = list.length;
					for (i = 0; i < len; i++)
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["daily"]);
					//WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["archive"]);
					break;
				default:
					break;
			}
		}
		
		/*private function combinaDataVec():Vector.<MissionVo>
		{
			_missionDataVec.sort(sortByID);
			_dailyDataVec.sort(sortByID);
			
			_comboDataVec = _missionDataVec.concat(_dailyDataVec);
			
			return _comboDataVec;
		}*/
		
		private function checkHasMission(vec:Vector.<MissionStateVo>,id:String):int
		{
			var len:int = vec.length;
			
			for (var i:int = 0; i < len; i++) 
			{
				if (vec[i].id == id)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		private function updateMissionArray(vec:Vector.<MissionStateVo>,mData:MissionStateVo):void
		{
			var index:int = checkHasMission(vec, mData.id);
			
			//trace("mData: ", mData);
			if (vec[index])
			{
				vec[index] = mData;
				/*if (GameConfigManager.missionInfo[vec[index].id].type != "3" && vec[index].state == 2)
				{
					vec.splice(index, 1);
				}*/
			}
			else
			{
				vec.push(mData);
			}
		}
		
		private function updataDailyScore(log:Object):void
		{
			for (var c in log)
			{
				setDailyScoreState(c);
			}
			
			var len:int = _dailyScoreVec.length;
			var finishVec:Vector.<DailyScoreVo> = new Vector.<DailyScoreVo>();
			for (var i:int = 0; i < len; i++) 
			{
				if (_dailyScoreVec[i].state == 1)
				{
					finishVec.push(_dailyScoreVec.splice(i, 1)[0]);
					i--;
					len--;
				}
			}
			_dailyScoreVec = _dailyScoreVec.concat(finishVec);
		}
		
		private function setDailyScoreState(id:int):void
		{
			var len:int = _dailyScoreVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (_dailyScoreVec[i].id == id)
				{
					_dailyScoreVec[i].state = 1;
					return;
				}
			}
		}
		
		private function updataFinishState(type:String):void
		{
			var num:int = 0;
			if (type == "m")
			{
				num = checkFinishNum(_dailyDataVec);
				view.mNumTF.text = num;
				view.mTip.visible = Boolean(num);
				
			}
			else
			{
				num = checkFinishNum(_achieveDataVec);
				view.aNumTF.text = num;
				view.aTip.visible = Boolean(num);
			}
		}
		
		private function orderByState():void 
		{
			var len:int = _dailyDataVec.length;
			var finishArr:Vector.<MissionStateVo> = new Vector.<MissionStateVo>();
			var claimArr:Vector.<MissionStateVo> = new Vector.<MissionStateVo>();
			
			for (var i:int = 0; i < len; i++) 
			{
				if (_dailyDataVec[i].state == 1)
				{
					claimArr.push(_dailyDataVec.splice(i, 1)[0]);
					i--;
					len--;
					continue;
				}
				
				if (_dailyDataVec[i].state == 2)
				{
					finishArr.push(_dailyDataVec.splice(i, 1)[0]);
					i--;
					len--;
				}
			}
			_dailyDataVec = claimArr.concat(_dailyDataVec);
			_dailyDataVec = _dailyDataVec.concat(finishArr);
			//trace("finish: ", _dailyDataVec.length);
		}
		
		private function checkFinishNum(vec:Vector.<MissionStateVo>):int
		{
			var len:int = vec.length;
			var fNum:int = 0;
			var i:int = 0;
			
			for (i = 0; i < len; i++) 
			{
				if (vec[i].state == 1)
				{
					fNum++;
					
				}
			}
			
			return fNum;
		}
		
		
		override public function show(...args):void{
			super.show();
			
			_isNewerEnter = false;
			if (args[0])
			{
				_isNewerEnter = true;
			}
			AnimationUtil.flowIn(this);
			
			_dailyScoreVec = GameConfigManager.dailiyScore.concat();
			
			//WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["main"]);
			WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["daily"]);
			//WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["archive"]);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function createUI():void{
			this._view = new MissionMainViewUI();
			this.addChild(_view);
			
			this.view.missionBtn.selected = true;
			
			_curName = "mission";
			
			this.view.missionList.itemRender = MissionItem;
			this.view.missionList.array = [];
			this.view.missionList.scrollBar.sizeGrid = "6,0,6,0";
			
			
			this.view.achieveList.itemRender = AchieveItem;
			this.view.achieveList.visible = false;
			this.view.achieveList.scrollBar.sizeGrid = "6,0,6,0";
			
			this.view.mTip.visible = false;
			this.view.aTip.visible = false;
			
			this.view.challengeBtn.visible = false;
			this.view.achieveBtn.visible = true;
			
			
			this.closeOnBlank = true;
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA),this,serviceResultHandler,[ServiceConst.MISSION_INIT_DATA]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD),this,serviceResultHandler,[ServiceConst.GET_MISSION_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_DAILY_SCORE_REWARD),this,serviceResultHandler,[ServiceConst.GET_DAILY_SCORE_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_PROGRESS), this, serviceResultHandler, [ServiceConst.GET_MISSION_PROGRESS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_DAILY_SCORE_REWARD),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_PROGRESS),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);			
			
			super.removeEvent();
		}
		
		
		
		private function get view():MissionMainViewUI{
			return _view;
		}
		
		protected function sortByID(a:MissionStateVo,b:MissionStateVo):int
		{
			if (parseInt(a.id) < parseInt(b.id))
			{
				return -1;
			}
			return 1;
		}
	}

}