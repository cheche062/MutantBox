package game.module.mission 
{
	import MornUI.mission.MissionItemUI;
	
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.mission.MissionStateVo;
	import game.global.vo.mission.MissionVo;
	import game.module.bingBook.ItemContainer;
	import game.module.camp.CampView;
	import game.module.fighting.view.FightingChapetrView;
	import game.module.gene.GeneView;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainMenuView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;

	/**
	 * ...
	 * @author ...
	 */
	public class MissionItem extends Box
	{
		
		private var itemMC:MissionItemUI;
		private var _data:MissionStateVo;
		private var _missionData:MissionVo;
		
		private var _itemVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var _startPos:Array = [0, 450, 400, 350];
		
		public function MissionItem() 
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new MissionItemUI();
			this.addChild(itemMC);
			  
			itemMC.goBtn.on(Event.CLICK, this, this.btnEventHandle);
			
		}
		
		public static function functionLink(gongneng:String, requirement:String,canshu1:String=""):void
		{
			var sp:Sprite;
			switch(gongneng)
			//switch("3")
			{
				case "1"://建造
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD]);
					break;
				case "2"://主线副本
					XFacade.instance.closeModule(MissionMainView);
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP); 
					break;
				case "3"://训练兵种
					XFacade.instance.closeModule(MissionMainView);
					
					if (requirement == "1" || 
						requirement == "2" || 
						requirement == "5" || 
						requirement == "6" )
					{							
						XFacade.instance.openModule("CampView", CampView);
						//XFacade.instance.openModule("UnitInfoView", [{id:canshu1}]);
						XFacade.instance.openModule(ModuleName.NewUnitInfoView, [canshu1]);
					}
					else
					{
						XFacade.instance.openModule("LevelUpView");
					}
					
					//XFacade.instance.openModule("UnitInfoView", [item.id, getIds(item.id)]);
					break;
				case "4"://人物等级
					//无跳转
					break;
				case "5"://宝箱
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule("ChestsMainView");
					break;
				case "6"://基地互动
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57009"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					sp = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_PROTECT);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(sp);
					break;
				case "7"://训练营
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule("TrainView");
					break;
				case "8"://资源建筑
					break;
				case "9"://怪物入侵
					if (HomeScene(ModuleManager.intance.getModule(HomeScene)).focus())
					{
						XFacade.instance.closeModule(MissionMainView);
					}
					break;
				case "10"://击杀BOSS
					break;
				case "11"://好友
					break;
				case "12"://基因副本
					XFacade.instance.closeModule(MissionMainView);
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,1]);
					break;
				case "13"://基因系统
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GENE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57010"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule("GeneView");
					break;
				case "14"://武器副本
					XFacade.instance.closeModule(MissionMainView);
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1]);
					/*SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);
					XFacade.instance.openModule(ModuleName.EquipFightInfoView,0);*/
					break;
				case "15"://酒馆洗练
				case "16"://酒馆强化
					//无跳转
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_HOTRL) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57011"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.EquipMainView);
					break;
				case "17"://公会
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57012"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					if (User.getInstance().guildID=="")
					{
						XFacade.instance.openModule(ModuleName.CreateGuildView);
					}
					else 
					{
						XFacade.instance.openModule(ModuleName.GuildMainView);
					}
					break;
				case "18"://超市
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_STORE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57013"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
//					XFacade.instance.openModule("StoreView");
					XFacade.instance.openModule("StoreView",[0,0]);
					break;
				case "19"://兵书副本
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					break;
				case "20"://雷达站
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					break;
				case "21"://运镖
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TRANSPORT) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_914039"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					//XFacade.instance.openModule(ModuleName.EscortMainView);
					XFacade.instance.openModule(ModuleName.TrainLoadingView);
					break;
				case "22"://遗迹
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule("LevelUpView");
					break;
				case "23":
					break;
				case "24":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_ARENA) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57015"));
						return;
					}
					XFacade.instance.openModule(ModuleName.ArenaMainView);
					break;
				case "25":
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[2]);
					break;
				case "28":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_MINE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57021"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				case "29":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.MilitartHouseView);
					break;
				case "30":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				case "31":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PVP) == 0)
					{
						XTip.showTip("no pvp building");
						return;
					}
					XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.PvpMainPanel);
					break;
				case "32":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) > 0)
					{
						XFacade.instance.openModule("ArmyGroupMapView");
						XFacade.instance.closeModule(MainMenuView);
						XFacade.instance.closeModule(MissionMainView);
					}
					else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57012"));
					}
					break;
				case "33":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) > 1)
					{
						XFacade.instance.openModule(ModuleName.StarTrekMainView);
						XFacade.instance.closeModule(MainMenuView);
						XFacade.instance.closeModule(MissionMainView);
					}
					break;
				default:
					break;
			}
		}
		
		private function btnEventHandle():void 
		{
			if (data.state == "0")
			{
				//trace("gongneng:", _missionData.gongneng);
				functionLink(_missionData.gongneng, _missionData.requirement,_missionData.canshu1);
				return;
			}
			if(_missionData.type == '1')
			{
				//WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD,['main',data.id]);
			}
			else
			{
				WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD,['daily',data.id]);
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			view.goBtn['clickSound'] = ResourceManager.getSoundUrl("ui_common_click",'uiSound')
			this._data = value as MissionStateVo;
			
			if(!data)
			{
				view.visible = false;
				return;
			}
			view.visible = true;
			_missionData = GameConfigManager.missionInfo[data.id];
			//trace("id:", _missionData.id + " name:", view.nameTF.text, " state: ", data.state)
			
			view.mainBg.visible = true;
			view.normailBg.visible = true;
			if (!_missionData)
			{
				trace("任务ID查询失败:", data.id);
				view.visible = false;
				return;
			}
			
			//trace("data.id:", data.id);
			//trace("_missionData:", _missionData);
			
			if (_missionData.type == 2)
			{
				view.nameTF.color = "#9fd5ff";
				view.mainBg.visible = false;
			}
			
			if (_missionData.type == 1)
			{
				view.nameTF.color = "#ffd630";
				view.normailBg.visible = false;
			}
			
			
			view.goBtn.visible = true;
			switch(_missionData.gongneng)
			{
				
				case "4"://人物等级
				//case "6"://基地互动
				//case "7"://训练营
				case "8"://资源建筑
				//case "9"://怪物入侵
				case "10"://击杀BOSS
				case "11"://好友
				case "23":
					view.goBtn.visible = false;
					break;
				default:
					break;
			}
			
			if (_missionData.gongneng == '6' && _missionData.requirement == '2')
			{
				view.goBtn.visible = true;
			}
			
			if (_missionData.gongneng == '3' && parseInt(_missionData.requirement) >= 3)
			{
				view.goBtn.visible = false;
			}
			
			//trace("id:",_missionData.id+" name:",view.nameTF.text," state: ",data.state)
			
			// 
			view.dom_claimed.visible = false;
			switch(data.state)
			{
				case 1:
					view.goBtn.label = GameLanguage.getLangByKey("L_A_32004");
					view.goBtn.visible = true;
					view.goBtn.disabled = false;
					view.goBtn['clickSound'] = ResourceManager.getSoundUrl("ui_collect_resource",'uiSound')
					break;
				case 2:
					view.goBtn.label = "FINISH";// GameLanguage.getLangByKey("L_A_32003");
					view.goBtn.disabled = true;
					
					view.dom_claimed.visible = true;
					view.goBtn.visible = false;
					
					break;
				default:
					view.goBtn.label = GameLanguage.getLangByKey("L_A_32003");
					view.goBtn.disabled = false;
					break;
			}
			
			//view.goBtn.label = GameLanguage.getLangByKey("L_A_32003");
			/*if (data.state == 1)
			{
				view.goBtn.label = GameLanguage.getLangByKey("L_A_32004");
				view.goBtn.visible = true;
			}*/
			
			if (data.currentInfo[0])
			{
				view.nameTF.text = "("+data.currentInfo[0]+"/"+_missionData.canshu1+")"+
					GameLanguage.getLangByKey(_missionData.name).replace("{0}", _missionData.canshu1);
			}
			else
			{
				view.nameTF.text = "(0/"+_missionData.canshu1+")"+
					GameLanguage.getLangByKey(_missionData.name).replace("{0}", _missionData.canshu1);
			}
			
			view.desTF.wordWrap = true;
			view.desTF.text = translateMissionDes();
			
			var rewardArr:Array = _missionData.reward.split(";");
			var len:int = rewardArr.length;
			
			//trace("rewardArr:", rewardArr);
			
			for (var i:int = 0; i < 3; i++) 
			{
				if (i >= len)
				{
					if (_itemVec[i])
					{
						_itemVec[i].visible = false;
						_itemVec[i].mouseEnabled = false;
					}
					continue;					
				}
				
				if (!_itemVec[i])
				{
					_itemVec[i] = new ItemContainer();
					_itemVec[i].x = _startPos[len] + 100 * i;
					_itemVec[i].y = 29;
					_itemVec[i].needOtherNum = false;
					_itemVec[i].numTF.width = 70;
					this.view.addChild(_itemVec[i]);
				}
				
				_itemVec[i].x = _startPos[len] + 100 * i;
				if (data.state == 2)
				{
					_itemVec[i].visible = false;
					_itemVec[i].mouseEnabled = false;
				}
				else
				{
					_itemVec[i].visible = true;
					_itemVec[i].mouseEnabled = true;
				}
				
				if(_missionData.fl == 1)
				{
					
					var iid:int = parseInt(rewardArr[i].split("=")[0]);
					
					if (GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + iid])
					{
						_itemVec[i].setData(rewardArr[i].split("=")[0], Math.ceil(parseInt(rewardArr[i].split("=")[1])*GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + iid]));
					}
					else
					{
						_itemVec[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
					}
					
				}
				else
				{
					_itemVec[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
				}
				
			}
		}
		
		private function translateMissionDes():String
		{
			if (!_missionData.describe) return ""; 
			var orignDes:String = GameLanguage.getLangByKey(_missionData.describe);
			
			/*if (!_missionData.canshu1)
			{
				trace("middDatas:", _missionData);
				return;
			}*/
			var params:Array = [_missionData.canshu1, _missionData.canshu2, _missionData.canshu3, _missionData.canshu4, _missionData.canshu5];
			var paramsType:Array = _missionData.canshu_type.split("|");
			
			for (var i:int = 0; i < paramsType.length; i++) 
			{
				var replaceStr:String = "";
				switch(parseInt(paramsType[i]))
				{
					case 1:
						replaceStr = params[i];
						break;
					case 2:
						replaceStr = GameLanguage.getLangByKey(DBBuilding.getBuildingById(params[i]).name);
						break;
					case 3:
						replaceStr = GameLanguage.getLangByKey(GameConfigManager.unit_dic[params[i]].name);
						break;
					case 4:
						replaceStr = GameLanguage.getLangByKey(GameConfigManager.items_dic[params[i]].name);
						break;
					case 5:
						break;
					default:
						break;
				}
				orignDes = orignDes.replace("{" + i + "}", replaceStr);
			}
			
			orignDes = orignDes.replace("{100}", _missionData.point);
			
			return orignDes;
		}
		
		
		public function get data():MissionStateVo{
			return this._data;
		}
		
		private function get view():MissionItemUI{
			return itemMC;
		}
		
	}

}