package game.module.story
{
	import MornUI.Story.StoryViewUI;
	import MornUI.StoryTask.RewardItemUI;
	import MornUI.StoryTask.StoryTaskViewUI;
	
	import game.RedPointManager;
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.mission.MissionStateVo;
	import game.global.vo.mission.MissionVo;
	import game.module.bag.cell.ItemCell4;
	import game.module.bingBook.ItemContainer;
	import game.module.camp.CampView;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.MainMenuView;
	import game.module.mission.MissionMainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Component;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class StoryTaskView extends BaseDialog
	{

		private var allChapterData:Array;

		private var allChapterTask:Array;

		private var listData:Array;

		private var cIndex:int;
		private var STORY_STAGE:String = "config/story_stage.json";//重置条件

		private var _timeCount:int;

		private var curCharacterData:Object;
		public function StoryTaskView()
		{ 
			super(); 
		}
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			this.alpha=1;
			this.scaleX=1;
			this.scaleY=1;
			super.show(args);
//			trace("章节数据:"+JSON.stringify(args[0]));
			allChapterData = [];
			for (var key:String in args[0])
			{
//				trace("每一章节的数据："+JSON.stringify(args[0][key]));
				allChapterData.push(args[0][key]);
			}
			
			cIndex = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BASE)-1;
			if(cIndex>=4)
			{
				cIndex=4;
			}
			setBtnStatus();
			setCurCharacter(cIndex);
			AnimationUtil.flowIn(this);
//			trace("view.x:"+view.x);
//			trace("this宽："+this.width);
//			trace("this高："+this.height);
//			trace("this显示宽："+this.displayWidth);
//			trace("view显示高："+this.displayHeight);
			
		}
		
		private function setBtnStatus():void
		{

			trace("按钮状态："+cIndex);
			if(cIndex==0&&cIndex==allChapterData.length-1)
			{
				view.btn_left.visible = false;
				view.btn_left.disabled = true;
				view.btn_right.disabled = true;
				view.btn_right.visible = false;
			}else if(cIndex==0)
			{
				view.btn_right.disabled = false;
				view.btn_right.visible = true;
				view.btn_left.disabled = true;
				view.btn_left.visible = false;
			}
			else if(cIndex==allChapterData.length-1)
			{
				view.btn_right.disabled = true;
				view.btn_right.visible = false;
				view.btn_left.disabled = false;
				view.btn_left.visible = true;
			}else 
			{
				view.btn_right.disabled = false;
				view.btn_right.visible = true;
				view.btn_left.disabled = false;
				view.btn_left.visible = true;
			}
			trace("view.btn_left.visible:"+view.btn_left.visible);
		}
		
		private function setCurCharacter(cIndex:int):void
		{
			if(allChapterData.length==0)//没有章节数据
			{
				view.list.disabled = true;
				view.btn_left.disabled = true;
				view.btn_right.disabled = true;
				return;
			}
			curCharacterData = allChapterData[cIndex];
			var curCharacterTask:Object = curCharacterData["task"];
			listData = [];
//			trace("当前章节任务:"+JSON.stringify(curCharacterTask));
			var allFinish:Boolean = true;
			var totalTask:int;
			var finishTask:int;
			for(var key:String in curCharacterTask) 
			{
				totalTask++;
				var stateData:MissionStateVo = new MissionStateVo();
				stateData.id = key;
				stateData.state = parseInt(curCharacterTask[key][0]);
				stateData.currentInfo = curCharacterTask[key][1][1]?curCharacterTask[key][1][1]:[];
				listData.push(stateData);
				if(stateData.state==0)
				{
					allFinish = false;//只要有一个任务未完成，就不能领
				}else
				{
					finishTask++;
				}
			}
			if(allFinish)
			{
				if(curCharacterData["rewardsGeted"]==0)
				{
					view.btn_receive.disabled = false;
					view.btn_receive.label = GameLanguage.getLangByKey("L_A_83007");
				}else
				{
					view.btn_receive.disabled = true;
					view.btn_receive.label = GameLanguage.getLangByKey("L_A_83008");
				}
			
			}else
			{  
				view.btn_receive.label = GameLanguage.getLangByKey("L_A_83007");
				view.btn_receive.disabled = true;
			}
			
//			trace("allFinish:"+allFinish);
			var characterId:int = cIndex+1;
			var la:String = "L_A_8300"+characterId;//L_A_83001-L_A_83005(章节1到章节5)
			var characterName:String = GameLanguage.getLangByKey(la);
			view.title.text = characterName;
			var storyObj:Object = ResourceManager.instance.getResByURL(STORY_STAGE);
//			trace("剧情任务表:"+JSON.stringify(storyObj)); 
			view.process.text = GameLanguage.getLangByKey("L_A_83014")+ finishTask +"/"+totalTask;
			var box:Box = view.tipBox.getChildByName("ItemBox");
			if(box)
			{
				box.removeChildren();
			}else
			{
				box = new Box();
				view.tipBox.addChild(box);
				box.name = "ItemBox";
			}
			
			for each(var con:Object in storyObj)
			{
				if(con["id"] == characterId)
				{
					var desLa:String = con["describe"];
					view.context.text = GameLanguage.getLangByKey(desLa);
					var rewardStr:String = con["reward"]; 
					var rewardArr:Array = rewardStr.split(";");
					
					for(var i:int=0;i<rewardArr.length;i++)
					{
						var iid:int = parseInt(rewardArr[i].split("=")[0]); 
						var num:int = parseInt(rewardArr[i].split("=")[1]); 
						var rewardItem:ItemCell3 = new ItemCell3();
						box.addChild(rewardItem);
						rewardItem.x = i*(rewardItem.width);//相对于box的坐标
						var itemData:ItemData = new ItemData();
						itemData.iid = iid;
						itemData.inum = num;
						rewardItem.data = itemData;
					}
				}
			}
			box.x =view.cankao.x+(view.cankao.width/2-box.width/2);//让box相对于参考图片居中
			box.y = 400;
			view.cankao.skin = "appRes/icon/story/storyTask/"+characterId+".jpg";
//			trace("容器一半宽度:"+box.width/2);
//			trace("参考一半宽度:"+view.cankao.width/2);
			setRed();
			var expiresTime:Number = parseInt(curCharacterData["expiresTime"])*1000;
			_timeCount = (expiresTime-TimeUtil.now)/1000;
			if(_timeCount<=0)
			{
//				_timeCount = 0;
				view.leftTime.text = GameLanguage.getLangByKey("L_A_83083");
				
			}else
			{
				var leftStr:String = TimeUtil.getTimeCountDownStr(_timeCount,false);
				Laya.timer.clear(this, timeCountHandler);	
				Laya.timer.loop(1000, this, timeCountHandler);
				view.leftTime.text =  GameLanguage.getLangByKey("L_A_83082")+leftStr;
			}
			if(curCharacterData["isUnlocked"]==0)
			{
				view.leftTime.visible = false;
			}else
			{
				view.leftTime.visible = true;
			}
			view.list.array = listData;
			if(curCharacterData["isUnlocked"]==0) 
			{
				view.tipBox.disabled = true;
				view.tip.visible = true;
				view.tiptext.text = GameLanguage.getLangByKey("L_A_83015").replace("{0}",characterId);
				//				var l:List = new List();
//				for(var i:int=0;i<view.list.numChildren;i++)
//				{
//					var cell:Box = view.list.getChildAt(i) as Box;
//					cell.disabled = true;
//				}
			}else
			{
				view.tipBox.disabled = false;
				view.tip.visible = false;
//				for(var i:int=0;i<view.list.numChildren;i++)
//				{
//					var cell:Box = view.list.getChildAt(i) as Box;
//					cell.disabled = true;
//				}
			}
		}
		
		private function timeCountHandler():void
		{
			if(_timeCount<=0)
			{
//				_timeCount = 0;
				Laya.timer.clear(this, timeCountHandler);
				view.leftTime.text = GameLanguage.getLangByKey("L_A_83083");
			}else
			{
				_timeCount--;
				var leftStr:String = TimeUtil.getTimeCountDownStr(_timeCount,false);
				view.leftTime.text = GameLanguage.getLangByKey("L_A_83082")+leftStr;
			}
			
		}
		/**
		 *设置内部，左右按钮的小红点 
		 * 
		 */
		public function setRed():void
		{
			//设置左右红点
			var leftRed:Boolean = false;
			//					trace("长度:"+allChapterData.length);
			for(var i:int=0;i<cIndex;i++)
			{
				var curCharacterData:Object = allChapterData[i];
				var curCharacterTask:Object = curCharacterData["task"];
				//						listData = [];
				//									trace("当前章节任务:"+JSON.stringify(curCharacterTask));
				
				for(var key:String in curCharacterTask)
				{
					var state:int = parseInt(curCharacterTask[key][0]);
					if(state==1)
					{
						leftRed = true;
						break;
					}
				}
			}
			trace("左边红点:"+leftRed);
			if(!leftRed)
			{
				for(var i:int=0;i<cIndex;i++)
				{
					var curCharacterData:Object = allChapterData[i];
					if(curCharacterData["rewardsGeted"]==0)
					{
						var chapterCan:Boolean = true;
						var curCharacterTask:Object = curCharacterData["task"];
						for(var key:String in curCharacterTask)
						{
							var taskState:int = parseInt(curCharacterTask[key][0]);
							if(taskState==0)
							{
								chapterCan = false;
							}
						}
						if(chapterCan)
						{
							leftRed = true;
							break;
						}
					}
				}
			}
			view.red1.visible = leftRed;
			trace("左边红点:"+leftRed);
			
			//设置左右红点
			var rightRed:Boolean = false;
			//					trace("长度:"+allChapterData.length);
			for(var i:int=cIndex+1;i<allChapterData.length;i++)
			{
				var curCharacterData:Object = allChapterData[i];
				var curCharacterTask:Object = curCharacterData["task"];
				//						listData = [];
				//									trace("当前章节任务:"+JSON.stringify(curCharacterTask));
				
				for(var key:String in curCharacterTask)
				{
					var state:int = parseInt(curCharacterTask[key][0]);
					if(state==1)
					{
						rightRed = true;
						break;
					}
				}
			}
			trace("右边红点:"+rightRed);
			if(!rightRed)
			{
				for(var i:int=cIndex+1;i<allChapterData.length;i++)
				{
					var curCharacterData:Object = allChapterData[i];
					if(curCharacterData["rewardsGeted"]==0)
					{
						var chapterCan:Boolean = true;
						var curCharacterTask:Object = curCharacterData["task"];
						for(var key:String in curCharacterTask)
						{
							var taskState:int = parseInt(curCharacterTask[key][0]);
							if(taskState==0)
							{
								chapterCan = false;
							}
						}
						if(chapterCan)
						{
							rightRed = true;
							break;
						}
					}
				}
			}
			view.red2.visible = rightRed;
			trace("右边红点:"+rightRed);
		}
		public function get view():StoryTaskViewUI{
			if(!_view)
			{ 
				_view ||= new StoryTaskViewUI;  
			} 
			return _view;
		}
		override public function createUI():void 
		{
			// TODO Auto Generated method stub 
			super.createUI();
			this.addChild(view);
			closeOnBlank = true;
			view.list.renderHandler = Handler.create(this, onRender, null, false);
			
		}
		public  function functionLink(gongneng:String, requirement:String,canshu1:String=""):void
		{
			trace("gongneng:"+gongneng);
			var sp:Sprite;
			switch(gongneng)
				//switch("3")
			{
				case "1"://建造
					close();
					XFacade.instance.openModule("MainMenuView", [MainMenuView.MENU_BUILD]);
					break;
				case "2"://主线副本
					close();
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP); 
					break;
				case "3"://训练兵种
					close();
					
					if (requirement == "1" || 
						requirement == "2" || 
						requirement == "5" || 
						requirement == "6" ||
						requirement == "13")
					{		
						if(requirement == "13")
						{
							if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) < 2)
							{
								XTip.showTip(GameLanguage.getLangByKey("L_A_73124"));
								return;
							}
						}
						
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
					/*XFacade.instance.closeModule(MissionMainView);
					XFacade.instance.openModule(ModuleName.ChestsView);*/
					close();
					XFacade.instance.openModule("ChestsMainView");
					break;
				case "6"://基地互动
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PROTECT) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57009"));
						return;
					}
					close();
					sp = HomeScene(ModuleManager.intance.getModule(HomeScene)).focus(DBBuilding.B_PROTECT);
					HomeScene(ModuleManager.intance.getModule(HomeScene)).showMenu(sp);
					break;
				case "7"://训练营
					close();
					XFacade.instance.openModule("TrainView");
					break;
				case "8"://资源建筑
					break;
				case "9"://怪物入侵
					if (HomeScene(ModuleManager.intance.getModule(HomeScene)).focus())
					{
						close();
					}
					break;
				case "10"://击杀BOSS
					break;
				case "11"://好友
					break;
				case "12"://基因副本
					close();
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,1]);
					break;
				case "13"://基因系统
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GENE) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57010"));
						return;
					}
					close();
					XFacade.instance.openModule("GeneView");
					break;
				case "14"://武器副本
					close();
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
					close();
					XFacade.instance.openModule(ModuleName.EquipMainView);
					break;
				case "17"://公会
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57012"));
						return;
					}
					close();
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
					close();
//					XFacade.instance.openModule("StoreView");
					XFacade.instance.openModule("StoreView",[0,0]);
					break;
				case "19"://兵书副本
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					close();
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					break;
				case "20"://雷达站
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_RADIO) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57014"));
						return;
					}
					close();
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					break;
				case "21"://运镖
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TRANSPORT) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_914039"));
						return;
					}
					close();
					//XFacade.instance.openModule(ModuleName.EscortMainView);
					XFacade.instance.openModule(ModuleName.TrainLoadingView);
					break;
				case "22"://遗迹
					close();
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
					close();
					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				case "29":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					close();
					XFacade.instance.openModule(ModuleName.MilitartHouseView);
					break;
				case "30":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TEAMCOPY) == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_15038"));
						return;
					}
					close();
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					break;
				case "31":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_PVP) == 0)
					{
						XTip.showTip("no pvp building");
						return;
					}
					close();
					XFacade.instance.openModule(ModuleName.PvpMainPanel);
					break;
				case "32":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GUILD) > 0)
					{
						XFacade.instance.openModule("ArmyGroupMapView");
						XFacade.instance.closeModule(MainMenuView);
						close();
					}else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_57012"));
					}
					break;
				case "33":
					if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) > 1)
					{
						XFacade.instance.openModule(ModuleName.StarTrekMainView);
						XFacade.instance.closeModule(MainMenuView);
						close();
					}
					break;
				default:
					break;
			}
		}
		private function btnEventHandle(state:String,gongneng:String,requirement:String,canshu1:String,type:String):void 
		{
			if (state == "0")
			{
				//trace("gongneng:", _missionData.gongneng);
				functionLink(gongneng, requirement,canshu1);
				return;
			}
			if(type == '1')
			{
				
			}
			else
			{
//				WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD,['daily',data.id]);
				//领取奖励
			}
		}
		private function onRender(cell:Box,index:int):void
		{
			var data:Object = view.list.array[index];
//			trace("渲染数据:"+JSON.stringify(data));
			if(!data)
			{
				return;
			} 
			if(curCharacterData["isUnlocked"]==1)
			{
				if(_timeCount<=0&&data.state==0)
				{
					cell.disabled = true;
				}else
				{
					cell.disabled = false;
				}
			}else
			{
				cell.disabled = true;
			}
			
			var btn:Button = cell.getChildByName("btn_task") as Button;
			var fTf:Text = cell.getChildByName("finishTf") as Text;
//			btn['clickSound'] = ResourceManager.getSoundUrl("ui_common_click",'uiSound');
			var tname:Label = cell.getChildByName("nameTF") as Label;
//			view.goBtn['clickSound'] = ResourceManager.getSoundUrl("ui_common_click",'uiSound')
//			this._data = value as MissionStateVo;
			
//			if(!data)
//			{ 
//				view.visible = false;
//				return;
//			}
//			view.visible = true;
//			trace("任务池:"+JSON.stringify(GameConfigManager.missionInfo));
			var _missionData:MissionVo = GameConfigManager.missionInfo[data.id];
			trace("_missionData:"+JSON.stringify(_missionData));
			trace("data.id:"+data.id);
			//trace("id:", _missionData.id + " name:", view.nameTF.text, " state: ", data.state)
			//state:String,gongneng:String,requirement:String,canshu1:String,type:String
			btn.on(Event.CLICK, this, this.btnEventHandle,[data.state,_missionData.gongneng,_missionData.requirement,_missionData.canshu1,_missionData.type]);
//			view.mainBg.visible = true;
//			view.normailBg.visible = true;
			if (!_missionData)
			{
				trace("任务ID查询失败:", data.id);
//				view.visible = false;
				return;
			}
			
			//trace("data.id:", data.id);
			//trace("_missionData:", _missionData);
			
			if (_missionData.type == 2)
			{
				tname.color = "#9fd5ff";
//				view.mainBg.visible = false;
			}
			
			if (_missionData.type == 1)
			{
				tname.color = "#ffd630";
//				view.normailBg.visible = false;
			}
			
			
			btn.visible = true;
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
					btn.visible = false;
					break;
				default:
					break;
			}
			
			if (_missionData.gongneng == '6' && _missionData.requirement == '2')
			{
				btn.visible = true;
			}
			
			if (_missionData.gongneng == '3' && parseInt(_missionData.requirement) >= 3)
			{
				btn.visible = true;
			}
			
			//trace("id:",_missionData.id+" name:",view.nameTF.text," state: ",data.state)
			btn.off(Event.CLICK,this,confirmReward);
			switch(data.state)
			{
				case 1:
					btn.label = GameLanguage.getLangByKey("L_A_32004");
					btn.visible = true;
					btn.disabled = false;
					var chapterId:int = cIndex+1;
					var storyId:String = "story_"+chapterId;
					btn.on(Event.CLICK,this,confirmReward,[storyId,data.id]);
					fTf.visible = false;
//					btn['clickSound'] = ResourceManager.getSoundUrl("ui_collect_resource",'uiSound')
					break;
				case 2:
					btn.label = GameLanguage.getLangByKey("L_A_32005");
					btn.visible = false;
					btn.disabled = true;
					fTf.visible = true;
					fTf.text = GameLanguage.getLangByKey("L_A_32005");
					break;
				default:
					btn.label = GameLanguage.getLangByKey("L_A_32003");
					btn.disabled = false;
					fTf.visible = false;
					break;
			}
			
			//view.goBtn.label = GameLanguage.getLangByKey("L_A_32003");
			/*if (data.state == 1)
			{
			view.goBtn.label = GameLanguage.getLangByKey("L_A_32004");
			view.goBtn.visible = true;
			}*/
			trace("currentInfo[0]"+data.currentInfo[0]);
			if (data.currentInfo[0])
			{
				tname.text = "("+data.currentInfo[0]+"/"+_missionData.story_canshu+")"+GameLanguage.getLangByKey(_missionData.name);
			}
			else
			{
				tname.text = "(0/"+_missionData.story_canshu+")"+GameLanguage.getLangByKey(_missionData.name);
			}
			if(_missionData.gongneng==2&&_missionData.requirement==1)//特殊处理
			{
				if(data.state==1)
				{
					tname.text = "("+1+"/"+_missionData.story_canshu+")"+GameLanguage.getLangByKey(_missionData.name);
				}else
				{
					tname.text = "("+0+"/"+_missionData.story_canshu+")"+GameLanguage.getLangByKey(_missionData.name);
				}
			}
//			view.desTF.wordWrap = true;
//			view.desTF.text = translateMissionDes();
			var box:Box = cell.getChildByName("ItemBox");
			if(box)
			{
				box.removeChildren();
			}else
			{
				box = new Box();
				cell.addChild(box);
				box.name = "ItemBox";
			}
			var rewardArr:Array = _missionData.reward.split(";");
			
			for(var i:int=0;i<rewardArr.length;i++)
			{
				var iid:int = parseInt(rewardArr[i].split("=")[0]); 
				var num:int = parseInt(rewardArr[i].split("=")[1]); 
				var rewardItem:RewardItemUI = new RewardItemUI();
				box.addChild(rewardItem);
				rewardItem.x = 30+i*(rewardItem.width-25);
				rewardItem.y = 40;
				rewardItem.icon.on(Event.CLICK, this, showIconTips,[iid+""]);
				rewardItem.icon.width = rewardItem.icon.height = 50;
				rewardItem.icon.skin=GameConfigManager.getItemImgPath(iid+"");
				rewardItem.num.text = num + "";
			}
			
			//trace("rewardArr:", rewardArr);
			
//			for (var i:int = 0; i < 3; i++) 
//			{
//				if (i >= len)
//				{
//					if (_itemVec[i])
//					{
//						_itemVec[i].visible = false;
//						_itemVec[i].mouseEnabled = false;
//					}
//					return;					 
//				}
//				
//				if (!_itemVec[i])
//				{
//					_itemVec[i] = new ItemContainer();
//					_itemVec[i].x = _startPos[len] + 100 * i;
//					_itemVec[i].y = 29;
//					_itemVec[i].needOtherNum = false;
//					_itemVec[i].numTF.width = 70;
//					this.view.addChild(_itemVec[i]);
//				}
//				
//				_itemVec[i].x = _startPos[len] + 100 * i;
//				if (data.state == 2)
//				{
//					_itemVec[i].visible = false;
//					_itemVec[i].mouseEnabled = false;
//				}
//				else
//				{
//					_itemVec[i].visible = true;
//					_itemVec[i].mouseEnabled = true;
//				}
//				
//				if(_missionData.fl == 1)
//				{
//					
//					var iid:int = parseInt(rewardArr[i].split("=")[0]);
//					
//					if (GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + iid])
//					{
//						_itemVec[i].setData(rewardArr[i].split("=")[0], Math.ceil(parseInt(rewardArr[i].split("=")[1])*GameConfigManager.missionParame_vec[User.getInstance().level]["xs_" + iid]));
//					}
//					else
//					{
//						_itemVec[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
//					}
					
					
//				}
//				else
//				{
//					_itemVec[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
//				}
				
//			}
		}
		
		private function confirmReward(storyId:String,taskId:String):void
		{
			trace("storyId"+storyId);
			trace("taskId"+taskId);
			WebSocketNetService.instance.sendData(ServiceConst.GET_MISSION_REWARD,[storyId,taskId]);
		}
		override public function removeEvent():void{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, serviceResultHandler);
			super.removeEvent();
		}
		
		private function showIconTips(id:String):void
		{
			ItemTips.showTip(id);
			
		}
		override public function addEvent():void{
			view.btn_close.on(Event.CLICK,this,onClose);
			view.btn_left.on(Event.CLICK,this,upChapter);
			view.btn_right.on(Event.CLICK,this,downChapter);
			view.btn_receive.on(Event.CLICK,this,receiveReward);

			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_MISSION_REWARD),this,serviceResultHandler,[ServiceConst.GET_MISSION_REWARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STORY_VIEW), this, serviceResultHandler,[ServiceConst.STORY_VIEW]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_CHAPTER_REWARD), this, serviceResultHandler,[ServiceConst.GET_CHAPTER_REWARD]);
		}
		
		private function receiveReward():void
		{
			var chapterId:int = cIndex+1;
			WebSocketNetService.instance.sendData(ServiceConst.GET_CHAPTER_REWARD,[chapterId]);
		}
		
		private function serviceResultHandler(cmd:int, ...args):void
		{
			switch(cmd)
			{
				case ServiceConst.GET_MISSION_REWARD:
					var len:int = 0;
					var i:int=0;
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
					WebSocketNetService.instance.sendData(ServiceConst.STORY_VIEW,[]);
					break;
				case ServiceConst.STORY_VIEW:
//					trace("11111111112222222222222");
//					trace("章节数据:"+JSON.stringify(args[1]));
					allChapterData = [];
					for (var key:String in args[1])
					{
						//				trace("每一章节的数据："+JSON.stringify(args[0][key]));
						allChapterData.push(args[1][key]);
					}
//					cIndex = allChapterData.length-1;
					setBtnStatus();
					setCurCharacter(cIndex);
					break;
				case ServiceConst.GET_CHAPTER_REWARD:
					trace("章节奖励放回:"+JSON.stringify(args[1]));
					var len:int = 0;
					var i:int=0;
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
					WebSocketNetService.instance.sendData(ServiceConst.STORY_VIEW,[]);
					break;
				default:
					break;
					
			}
		}
		
		/**
		 *后一关卡 
		 * 
		 */
		private function downChapter():void
		{
			++cIndex;
			if(cIndex>=allChapterData.length-1)
			{
				cIndex=allChapterData.length-1;
				view.btn_right.disabled = true;
				view.btn_right.visible = false;
			}else
			{
				view.btn_right.disabled = true;
				view.btn_right.visible = true;
			}
			setCurCharacter(cIndex);
			setBtnStatus();
		}
		
		/**
		 *前一关卡 
		 * 
		 */
		private function upChapter():void
		{
			// TODO Auto Generated method stub
			--cIndex;
			if(cIndex<=0)
			{
				cIndex=0;
				view.btn_left.disabled = true;
				view.btn_left.visible = false;
			}else
			{
				view.btn_left.disabled = false;
				view.btn_left.visible = true;
			}
			setCurCharacter(cIndex);
			setBtnStatus();
		}
//		override public function close():void{
////			AnimationUtil.flowOut(this, this.onClose);
//			closeAni();
//		}
		public function  closeAni():void
		{
			Tween.clearTween(this);
//			view.alpha = 0
			this.bg.removeSelf();
			Tween.to(this, {alpha:0,scaleX:0,scaleY:0,x:230,y:120,ease:Ease.circInOut}, 500, null,Handler.create(null, onflowOut));
			
			function onflowOut():void{
				super.close();
			}
		}
		private function onClose():void{
//			super.close();
			closeAni();
		}
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
	}
}