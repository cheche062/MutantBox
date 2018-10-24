//package game.module.armyGroup.newArmyGroup
//{
//	
//	import MornUI.armyGroup.ArmyGroupMainViewUI;
//	import MornUI.armyGroup.newArmyGroup.NewArmyGroupViewUI;
//	
//	import game.common.AnimationUtil;
//	import game.common.ItemTips;
//	import game.common.LayerManager;
//	import game.common.ResourceManager;
//	import game.common.SceneManager;
//	import game.common.ToolFunc;
//	import game.common.XFacade;
//	import game.common.XTip;
//	import game.common.XTipManager;
//	import game.common.XUtils;
//	import game.common.base.BaseView;
//	import game.global.GameConfigManager;
//	import game.global.GameLanguage;
//	import game.global.ModuleName;
//	import game.global.consts.ServiceConst;
//	import game.global.data.DBItem;
//	import game.global.data.bag.BagManager;
//	import game.global.event.ArmyGroupEvent;
//	import game.global.event.Signal;
//	import game.global.util.TimeUtil;
//	import game.global.vo.User;
//	import game.global.vo.armyGroup.ArmyGroupCityVo;
//	import game.module.armyGroup.ArmyGroupChatView;
//	import game.module.armyGroup.ArmyGroupFightLogView;
//	import game.module.armyGroup.ArmyGroupOutPutView;
//	import game.module.armyGroup.ArmyGroupPlantCtrlView;
//	import game.module.tips.ResourceTip;
//	import game.net.socket.WebSocketNetService;
//	
//	import laya.display.Sprite;
//	import laya.events.Event;
//	import laya.maths.Rectangle;
//	import laya.ui.Box;
//	import laya.ui.Image;
//	import laya.utils.Ease;
//	import laya.utils.Tween;
//	
//	/**
//	 * 国战新地图
//	 * @author hejianbo
//	 * 
//	 */
//	public class NewArmyGroupView extends BaseView
//	{
//		/**当前场景名称*/
//		private var currSceneName:String;
//		/**整张大地图*/
//		private var big_map:Box;
//		/**星球上的控件按钮*/
//		private var plantCtrlView:ArmyGroupPlantCtrlView;
//		
//		private var _selectedPlantInfo:StarVo;
//
//		// 整张大地图是由单位的星系构成，一个星系是由9张小地图构成
//		/**单位小地图的宽度*/
//		private const ITEM_MAP_WIDTH:int = 928;
//		private const ITEM_MAP_HEIGHT:int = 902;
//		/**数据表坐标对应的单位宽度*/		
//		private const ITEM_DATA_WIDTH:int = ITEM_MAP_WIDTH * 3 / 2;
//		/**数据表坐标对应的单位高度*/		
//		private const ITEM_DATA_HEIGHT:int = ITEM_MAP_HEIGHT * 3 / 2;
//		
//		/**单个星系内的各星球的相对坐标表*/
//		private var relative_pos_list:Array = [];
//		/**开放的星球数据*/
//		private var open_planet_data:Object;
//		//多点问题
//		private var lastDistance:Number = 0;
//		
//		public static var CURRENT_SEASON:int = 0;
//		private var _guildMoney:int = 0;
//		private var _nowFightState:int = 0;
//		private var _fightCountDown:int = 0;
//		
//		public function NewArmyGroupView()
//		{
//			super();
//			_m_iLayerType = LayerManager.M_POP;
//		}
//		
//		override public function createUI():void {
//			this.addChild(view);
//			window.gg = this;
//			GameConfigManager.intance.loaderArmyGroup();
//			
//			initRelativePosList();
//			
//			big_map = new Box();
//			
//			view.mouseEnabled = true;
//			view.mouseThrough = true;
//			view.topCenterArea.mouseThrough = true;
//			
//			view.addChildAt(big_map, 0);
//			
//			view.GoodImage.width=view.GoodImage.height=50;
//			view.GoodImage.skin=GameConfigManager.getItemImgPath(5);
//			view.GuildImage.skin=GameConfigManager.getItemImgPath(93201);
//			
//			view.ArmyGroupFood.width=view.ArmyGroupFood.height=50;
//			view.ArmyGroupFood.skin=GameConfigManager.getItemImgPath(93200);
//			onStageResize();
//			
//			view.timeArea.visible = false;
//			view.timeArea.mouseEnabled = false;
//			view.getRewardArea.visible = false;
//			
//			plantCtrlView = new ArmyGroupPlantCtrlView();
//			plantCtrlView.close();
//		}
//		
//		private function initRelativePosList():void {
//			relative_pos_list.length = 0;
//			// 读一下坐标即销毁
//			var newArmyGroup:NewArmyGroupViewUI = new NewArmyGroupViewUI();
//			for (var i = 0; i < newArmyGroup.dom_test_sprite.numChildren; i++) {
//				var child:Image = newArmyGroup.dom_test_sprite.getChildAt(i);
//				relative_pos_list.push([child.x, child.y]);
//			}
//			newArmyGroup.destroy();
//		}
//		
//		private function refreshUserData(... args):void
//		{
//			var tf:*
//			view.goldText.text=XUtils.formatResWith(User.getInstance().food);
//			view.goldText.color = (User.getInstance().food >= User.getInstance().sceneInfo.getResCap(DBItem.FOOD)) ? "#ff6600" : "#ffffff";
//			
//			view.GuidMoneyText.text=XUtils.formatResWith(_guildMoney);
//			view.GuidMoneyText.color = (_guildMoney >= parseInt(GameConfigManager.ArmyGroupGuildMoneyMax[User.getInstance().guildLv])) ? 
//				"#ff6600" : "#ffffff";
//			view.armyFood.text = BagManager.instance.getItemNumByID(93200);
//			view.WaterText.text = XUtils.formatResWith(User.getInstance().water);
//			if (args.length) { //加入动画
//				switch (args[0]) {
//					case DBItem.WATER:
//						tf=view.WaterText;
//						break;
//					case DBItem.FOOD:
//						tf=view.goldText;
//						break;
//					case DBItem.ARMY_GROUP_FOOD:
//						tf=view.armyFood;
//						break;
//					case 93201:
//						tf=view.GuidMoneyText;
//						break;
//				}
//				if (tf) XUtils.showTxtFlash(tf);
//			}
//		}
//		
//		override public function show(...args):void{
//			super.show();
//			Laya["Stat"].show();
//			console.clear();
//			
//			if (SceneManager.intance.m_sceneCurrent) {
//				currSceneName = SceneManager.intance.currSceneName;
//				SceneManager.intance.m_sceneCurrent.close();
//				SceneManager.intance.m_sceneCurrent = null;
//			}
//			
//			view.rt0.visible=false;
//			view.rt1.visible=false;
//			view.rt2.visible=false;
//			view.rt3.visible = false;
//			
//			sendData(ServiceConst.ARMY_GROUP_MAP_INIT);
//			sendData(ServiceConst.ARMY_GROUP_OUTPUT_INFO);
//			sendData(ServiceConst.MISSION_INIT_DATA, ["legion"]);
//		}
//		
//		/**创建整个大地图*/
//		private function createAllBigMap(city_info:Object):void {
//			var data_city = ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
//			open_planet_data = {};
//			var starIds = ToolFunc.objectKeys(city_info);
//			starIds.forEach(function(item) {
//				var starVo:StarVo = new StarVo();
//				starVo.init(data_city[item]);
//				starVo.serverDataEnter(city_info[item]);
//				open_planet_data[item] = starVo;
//			});
//			
//			// 所有的中心太阳星系
//			var galactPosList:Array = ToolFunc.objectValues(open_planet_data).filter(function(item:StarVo){
//				return item.sequence == 1;
//			}).map(function(item:StarVo) {
//				return { "block": item.block, "cor": item.cor };
//			}).sort(function(item0, item1) {
//				return item0.block - item1.block;
//			})
//			
////			trace("【所有的中心太阳星系】", galactPosList);
//			
//			galactPosList.forEach(function(item:StarVo) {
//				var sameKindBlockStars:Array = ToolFunc.objectValues(open_planet_data).filter(function(innerItem:StarVo){
//					return item.block == innerItem.block;
//				});
//				var galactMap:Sprite = createGalactMap(sameKindBlockStars);
//				var posArr = item.cor.split(",");
//				galactMap.pos(posArr[0] * ITEM_DATA_WIDTH, posArr[1] * ITEM_DATA_HEIGHT);
//				galactMap.visible = false;
//				big_map.addChildAt(galactMap, 0);
//			});
//			
//			big_map.size(getMaxPosValue("x", "width"), getMaxPosValue("y", "height"));
//			big_map.pivot(big_map.width / 2, big_map.height / 2);
//			big_map.pos(stage.width / 2, stage.height / 2);
//			
//			big_map.graphics.drawRect(0, 0, big_map.width, big_map.height, "#000");
//			big_map.scale(0.5, 0.5);
//			saveSpaceMapVisible();
//		}
//		
//		private function getMaxPosValue(direction, witchSide):int{
//			return Math.max.apply(null, big_map._childs.map(function(item:Sprite){
//				return item[direction] + item[witchSide];
//			}));
//		}
//		
//		/**创建子星系地图*/
//		private function createGalactMap(starList:Array):Sprite {
//			var item_map:Box = new Box();
//			var star_wrap:Sprite = new Sprite();
//			item_map.size(ITEM_MAP_WIDTH * 3, ITEM_MAP_HEIGHT * 3);
//			item_map.graphics.drawRect(0, 0, ITEM_MAP_WIDTH * 3, ITEM_MAP_HEIGHT * 3, "#333");
//			// 地图
//			for (var i = 0; i < 9; i++ ) {
//				var img:Image = new Image();
//				img.skin = "armyGroup/newArmy/map_0" + ( i + 1) + ".png";
//				img.pos(ITEM_MAP_WIDTH * (i % 3), ITEM_MAP_HEIGHT * Math.floor(i / 3));
//				item_map.addChild(img);
//			}
//			//星球
//			starList.forEach(function(item:StarVo) {
//				var star:StarItem = new StarItem();
//				star.init(item);
//				var pos = relative_pos_list[item.sequence - 1];
//				star.pos(pos[0], pos[1]);
//				star_wrap.addChild(star);
//			});
//			// 最后的一个子元素  （后面需要取）
//			item_map.addChild(star_wrap);
//			
//			return item_map;
//		}
//		
//		/**地图缩放功能*/
//		private function onScale(e:Event):void {
//			var deltaScale:Number = e.delta / 50;
//			scaleHandler(deltaScale);
//		}
//		
//		private function scaleHandler(deltaScale):void {
//			var scale:Number = big_map.scaleX;
//			scale += deltaScale;
//			scale = Math.min(scale, 1);
//			// 最小允许缩小(已知由宽度的缩放来决定高度的缩放)
//			var minScale = Math.max(stage.width / (ITEM_MAP_WIDTH * 3 * 2), stage.width / big_map.width); 
//			scale = Math.max(scale, minScale);
//			
//			big_map.x = ToolFunc.getAmongValue(big_map.x, stage.width - big_map.displayWidth / 2, big_map.displayWidth / 2);
//			big_map.y = ToolFunc.getAmongValue(big_map.y, stage.height - big_map.displayHeight / 2, big_map.displayHeight / 2);
//			big_map.scale(scale, scale);
//			saveSpaceMapVisible();
//		}
//		
//		private function startDragHandler():void {
//			var areaX = stage.width - big_map.displayWidth / 2;
//			var areaY = stage.height - big_map.displayHeight / 2;
//			var area:Rectangle = new Rectangle(areaX, areaY, big_map.displayWidth / 2 - areaX, big_map.displayHeight / 2 - areaY);
//			big_map.startDrag(area);
//		}
//		
//		private function stopDragHandler():void {
//			big_map.stopDrag();
//			saveSpaceMapVisible();
//		}
//		
//		/**优化地图显示*/
//		private function saveSpaceMapVisible():void {
//			big_map._childs.forEach(function(item:Sprite){
//				// x方向更大
//				var maxX:Boolean = item.x * big_map.scaleX > stage.width + (big_map.displayWidth / 2  - big_map.x);
//				// x方向更小
//				var minX:Boolean = (item.x + item.width) * big_map.scaleX < big_map.displayWidth / 2 - big_map.x;
//				// y方向更大
//				var maxY:Boolean = item.y * big_map.scaleY > stage.height + (big_map.displayHeight / 2  - big_map.y);
//				// y方向更小
//				var minY:Boolean = (item.y + item.height) * big_map.scaleY < big_map.displayHeight / 2 - big_map.y;
//				item.visible = !maxX && !minX && !maxY && !minY;
//				
//				// 遍历单个星系的所有星球
//				item.getChildAt(item.numChildren - 1)._childs.forEach(function(star:StarItem){
//					if (item.visible) {
//						star.show();
//						star.keepTextClearness(big_map.scaleX);
//					} else {
//						star.hide();
//					}
//				});
//			});
//		}
//		
//		/**-**************************************************************************************************-------------*/
//		/**布局*/
//		override public function onStageResize():void
//		{
//			view.size(Laya.stage.width, Laya.stage.height);
//			view.bottomRightArea.x=LayerManager.instence.stageWidth - view.bottomRightArea.width;
//			view.bottomRightArea.y=LayerManager.instence.stageHeight - view.bottomRightArea.height;
//			view.topCenterArea.x=(LayerManager.instence.stageWidth - view.topCenterArea.width) / 2;
//			
//			view.chatBtn.y = LayerManager.instence.stageHeight - view.chatBtn.height >> 1;
//			view.fightLogbtn.y = Laya.stage.height - 100;
//		}
//		
//		private var _currentCityId:int=-1;
//		
//		/**获取服务器消息*/
//		private function serviceResultHandler(... args):void {
//			trace("【国战数据】", args[0], args[1]);
//			var server_data = args[1];
//			switch (args[0]) {
//				case ServiceConst.ARMY_GROUP_MAP_INIT:
//					createAllBigMap(server_data.city_info);
//					
//					_guildMoney=args[1].guild_cash;
//					_nowFightState = args[1].season_state;
//					_fightCountDown = parseInt(args[1].season_fight_end_time) - parseInt(TimeUtil.now / 1000);
//					CURRENT_SEASON = args[1].season_id;
//					refreshUserData();
//					checkTimeTxt();
//					
//					view.timeArea.visible = false;
//					view.getRewardArea.visible = Boolean(parseInt(_nowFightState) == 3);
//					_currentCityId = args[1].city_id;
//					
//					if (args[1].role_military_status)
//					{
//						view.rt2.visible=true;
//					}
//					if (args[1].role_yesterday_get_status || args[1].role_kill_re_status)
//					{
//						view.rt3.visible=true;
//					}
//					
//					break;
//				
//				case ServiceConst.ARMY_GROUP_OUTPUT_INFO:
//					if (args[1].role_get.length > 0)
//					{
//						view.rt0.visible=true;
//					}
//					
//					if (args[1].can_get_special && parseInt(args[1].role_special_get_time) < 0)
//					{
//						view.rt0.visible=true;
//					}
//					
//					break;
//				
//				case ServiceConst.MISSION_INIT_DATA:
//					var mData:Object=args[1].list;
//					for (var d:String in mData)
//					{
//						if (parseInt(mData[d][0]) == 1)
//						{
//							view.rt1.visible=true;
//						}
//					}
//					break;
//				
//				case ServiceConst.ARMY_GROUP_CHANGE_CITY:
//					
//					break;
//				case ServiceConst.ARMY_GROUP_GIVE_UP_PLANT:
//					
//					break;
//				
//				case ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO:
//					
//					
//					break;
//				case ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY:
//					_guildMoney=args[2];
//					refreshUserData([93201]);
//					break;
//				case ServiceConst.ARMY_GROUP_DECLARE_WAR:
//					
//					
//					break;
//				case ServiceConst.ARMY_GROUP_BUY_PROTECTED:
//					break;
//			}
//		}
//		private var _isMoving:Boolean = false;
//		public function armyGroupEventHandler(cmd:String, ... args):void {
//			switch (cmd)
//			{
//				case ArmyGroupEvent.JUMP_PLANT:
//					_selectedPlantInfo=args[0];
////					focusPlant(_plantVec[args[0].id - 1]);
////					XFacade.instance.closeModule(ArmyGroupOutPutView);
//					break;
//				case ArmyGroupEvent.SELECT_PLANT:
//					_selectedPlantInfo = args[0];
//					
////					plantCtrlView.x = parseInt(_selectedPlantInfo.cor.split(",")[0]) + (pw[_selectedPlantInfo.type-1]-176) / 2;
////					plantCtrlView.y = parseInt(_selectedPlantInfo.cor.split(",")[1]) + (pw[_selectedPlantInfo.type-1] - 39) / 2;
////					plantCtrlView.show(Boolean(_selectedPlantInfo.id == _currentCityId), 
////						Boolean(_selectedPlantInfo.guildeID == User.getInstance().guildID), _isMoving);
//					
//					break;
//				case ArmyGroupEvent.HIDE_RED_DOT:
//					switch (args[0])
//					{
//						case 0:
//							view.rt0.visible=false;
//							break;
//						case 1:
//							view.rt1.visible=false;
//							break;
//						case 2:
//							view.rt2.visible=false;
//							break;
//						case 3:
//							view.rt3.visible=false;
//							break;
//						default:
//							break;
//					}
//					break;
//				
//				case ArmyGroupEvent.GO_NPC_PLANT:
////					_selectedPlantInfo = _plantVec[args[0]-1]._plantData;
////					focusPlant(_plantVec[args[0]-1]);
////					XFacade.instance.closeModule(ArmyGroupFightLogView);
////					plantCtrlView.x = parseInt(_selectedPlantInfo.cor.split(",")[0]) + (pw[_selectedPlantInfo.type-1]-176) / 2;
////					plantCtrlView.y = parseInt(_selectedPlantInfo.cor.split(",")[1]) + (pw[_selectedPlantInfo.type-1] - 39) / 2;
////					plantCtrlView.show(Boolean(_selectedPlantInfo.id == _currentCityId), 
////						Boolean(_selectedPlantInfo.guildeID == User.getInstance().guildID), _isMoving);
//					
//					break;
//			}
//		}
//		
//		private function joinLabelString(s0, s1, s3, c0, c1):String {
//			if (!CURRENT_SEASON) return "";
//			return ("<div style='width:520px;font-size:18px;color:"+c0+";align:center'>" +
//				GameLanguage.getLangByKey(s0)+ "<span style='color:"+c1+"'>&nbsp;" + 
//				GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1][s1] +
//				"&nbsp;</span><span style='color:"+c0+"'>" + GameLanguage.getLangByKey("L_A_21015")  + 
//				"</span><span style='color:"+c1+"'>&nbsp;" + 
//				GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1][s3] + "</span></div>");
//		}
//		
//		private function checkTimeTxt():void
//		{
//			view.ftTxt.innerHTML = joinLabelString("L_A_21012", "fight_begin", "fight_end", "#4c4c4c", "#4c4c4c");
//			view.jsTxt.innerHTML = joinLabelString("L_A_21013", "result_begin", "result_end", "#4c4c4c", "#4c4c4c");
//			view.ljTxt.innerHTML = joinLabelString("L_A_21014", "reward_begin", "reward_end", "#4c4c4c", "#4c4c4c");
//			view.timeBox.visible = false;
//			switch(parseInt(_nowFightState)) {
//				case 1:
//					view.seasonTimeTxt.innerHTML = view.ftTxt.innerHTML = 
//					joinLabelString("L_A_21012", "fight_begin", "fight_end", "#ffd6a4", "#fff");
//					break;
//				
//				case 2:
//					view.timeBox.visible = false;
//					view.seasonTimeTxt.innerHTML = view.jsTxt.innerHTML = 
//					joinLabelString("L_A_21013", "result_begin", "result_end", "#ffd6a4", "#fff");
//					view.timeBox.visible = false;
//					break;
//				case 3:
//					view.timeBox.visible = false;
//					view.seasonTimeTxt.innerHTML = view.ljTxt.innerHTML = 
//					joinLabelString("L_A_21014", "reward_begin", "reward_end", "#ffd6a4", "#fff");
//					break;
//			}
//		}
//		
//		private function fightTimeCount():void
//		{
//			_fightCountDown--;
//			if (_fightCountDown <= 0)
//			{
//				_fightCountDown = 0;
//				view.lastTimeTxt.text = "--:--:--"
//			}
//			else
//			{
//				view.lastTimeTxt.text = TimeUtil.getTimeCountDownStr(_fightCountDown, false);
//			}
//		}
//		
//		/**点击事件的监听*/
//		private function onClickHandler(e:Event):void
//		{
//			var info:Object={};
//			switch (e.target)
//			{
//				case view.CloseBtn:
//					this.close();
//					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_LEAVE_MAP);
//					break;
//				case view.ChargeBtn:
//					XFacade.instance.openModule(ModuleName.ChargeView);
//					break;
//				case view.CityBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupOutPutView);
//					break;
//				case view.MissionBtn:
//					XFacade.instance.openModule(ModuleName.ArmyDailyMissionView);
//					break;
//				case view.MilitaryRankBtn:
//					XFacade.instance.openModule(ModuleName.MilitaryRankView);
//					break;
//				case view.RankBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupRankView);
//					break;
//				case view.helpBtn:
//					//XFacade.instance.openModule(ModuleName.ArmyGroupHelp);
//					var msg:String = GameLanguage.getLangByKey("L_A_16001");
//					
//					XTipManager.showTip(msg.replace(/##/g, '\n'));
//					break;
//				case view.chatBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupChatView, [false]);
//					break;
//				case view.npcInfoBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupFightLogView,true);
//					break;
//				case view.fightLogbtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupFightLogView,false);
//					break;
//				case view.GuildImage:
//					info={};
//					info.name=GameConfigManager.items_dic[93201].name;
//					info.des=GameConfigManager.items_dic[93201].des;
//					info.icon=GameConfigManager.items_dic[93201].icon;
//					info.max = _guildMoney;// + "/" + GameConfigManager.ArmyGroupGuildMoneyMax[User.getInstance().guildLv];
//					//info.output = User.getInstance().sceneInfo.getOutPut(DBItem.STONE);
//					XTipManager.showTip(info, ResourceTip);
//					break;
//				case view.ArmyGroupFood:
//					ItemTips.showTip("93200");
//					
//					break;
//				case view.GoodImage:
//					info={};
//					info.name=GameConfigManager.items_dic[5].name;
//					info.des=GameConfigManager.items_dic[5].des;
//					info.icon=GameConfigManager.items_dic[5].icon;
//					info.max=User.getInstance().food + "/" + User.getInstance().sceneInfo.getResCap(DBItem.FOOD);
//					//info.output = User.getInstance().sceneInfo.getOutPut(DBItem.STONE);
//					XTipManager.showTip(info, ResourceTip);
//					break;
//				case view.WaterImage:
//					info={};
//					info.name=GameConfigManager.items_dic[1].name;
//					info.des=GameConfigManager.items_dic[1].des;
//					info.icon=GameConfigManager.items_dic[1].icon;
//					info.max=User.getInstance().water + "";
//					//info.output = User.getInstance().sceneInfo.getOutPut(DBItem.STONE);
//					XTipManager.showTip(info, ResourceTip);
//					break;
//				case view.timeDetailBtn:
//					if (view.timeArea.visible)
//					{
//						view.timeArea.visible = false;
//						view.getRewardArea.visible = Boolean(parseInt(_nowFightState) == 3);
//					}
//					else
//					{
//						view.timeArea.visible = true;
//						view.getRewardArea.visible = false;
//					}
//					
//					break;
//				case view.getReBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupSeasonRewardView);
//					break;
//				default:
//					break;
//			}
//		}
//		
//		private function onMouseDown(e:Event=null):void {
//			var touches:Array = e.touches;
//			if(touches && touches.length == 2) {
//				lastDistance = getDistance(touches);
//				Laya.stage.on(Event.MOUSE_MOVE, this, onMouseMove);
//				Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
//			}
//		}
//		
//		private function onMouseUp(e:Event=null):void {
//			Laya.stage.off(Event.MOUSE_MOVE, this, onMouseMove);
//			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
//			saveSpaceMapVisible();
//		}
//		
//		private var _lastDel:Number=0;
//		private function onMouseMove(e:Event=null):void {
//			var distance:Number = getDistance(e.touches);
//			//判断当前距离与上次距离变化，确定是放大还是缩小
//			const factor:Number = 0.001;
//			var del:Number = (distance - lastDistance) * factor;
//			// 特殊处理关于拉伸的问题
//			if(_lastDel > 0 && del < -0.2){
//				//不进行缩放
//			}else{
//				scaleHandler(del);
//			}
//			
//			if(del != 0){
//				_lastDel = del;
//			}
//			lastDistance = distance;
//		}
//		
//		/**计算两个触摸点之间的距离*/
//		private function getDistance(points:Array):Number
//		{
//			var distance:Number = 0;
//			if (points && points.length == 2)
//			{
//				var dx:Number = points[0].stageX - points[1].stageX;
//				var dy:Number = points[0].stageY - points[1].stageY;
//				
//				distance = Math.sqrt(dx * dx + dy * dy);
//			}
//			return distance;
//		}
//		
//		override public function addEvent():void{
//			super.addEvent();
//			this.on(Event.MOUSE_WHEEL, this, onScale);
//			view.on(Event.CLICK, this, onClickHandler);
//			
//			big_map.on(Event.MOUSE_DOWN, this, startDragHandler);
//			big_map.on(Event.MOUSE_UP, this, stopDragHandler);
//			Laya.stage.on(Event.MOUSE_DOWN, this, onMouseDown);
//			Laya.stage.on(Event.MOUSE_UP, this, onMouseUp);
//			Laya.stage.on(Event.MOUSE_OUT, this, onMouseUp);
//			
//			Signal.intance.on(User.PRO_CHANGED, this, refreshUserData);
//			
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_MAP_INIT), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_OUTPUT_INFO), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHANGE_CITY), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GIVE_UP_PLANT), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this, this.serviceResultHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
//			Signal.intance.on(ArmyGroupEvent.SELECT_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.SELECT_PLANT]);
//			Signal.intance.on(ArmyGroupEvent.JUMP_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.JUMP_PLANT]);
//			Signal.intance.on(ArmyGroupEvent.HIDE_RED_DOT, this, armyGroupEventHandler, [ArmyGroupEvent.HIDE_RED_DOT]);
//			Signal.intance.on(ArmyGroupEvent.GO_NPC_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.GO_NPC_PLANT]);
//		}
//		
//		override public function removeEvent():void{
//			super.removeEvent();
//			this.off(Event.MOUSE_WHEEL, this, onScale);
//			view.off(Event.CLICK, this, onClickHandler);
//			
//			big_map.off(Event.MOUSE_DOWN, this, startDragHandler);
//			big_map.off(Event.MOUSE_UP, this, stopDragHandler);
//			
//			Laya.stage.off(Event.MOUSE_UP, this, onMouseUp);
//			Laya.stage.off(Event.MOUSE_OUT, this, onMouseUp);
//			Laya.stage.off(Event.MOUSE_DOWN, this, onMouseDown);
//			
//			Signal.intance.off(User.PRO_CHANGED, this, refreshUserData);
//			
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_MAP_INIT), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_OUTPUT_INFO), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHANGE_CITY), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GIVE_UP_PLANT), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this, this.serviceResultHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
//			Signal.intance.off(ArmyGroupEvent.SELECT_PLANT, this, armyGroupEventHandler);
//			Signal.intance.off(ArmyGroupEvent.JUMP_PLANT, this, armyGroupEventHandler);
//			Signal.intance.off(ArmyGroupEvent.HIDE_RED_DOT, this, armyGroupEventHandler);
//			Signal.intance.off(ArmyGroupEvent.GO_NPC_PLANT, this, armyGroupEventHandler);
//		}
//		
//		/**服务器报错*/
//		private function onError(... args):void {
//			var cmd:Number=args[1];
//			var errStr:String = args[2];
//			if (errStr == "L_A_933060" || errStr == "L_A_933057") return;
//			XTip.showTip(GameLanguage.getLangByKey(errStr));
//		}
//		
//		override public function close():void{
//			AnimationUtil.flowOut(this, onClose);
//			XFacade.instance.closeModule(ArmyGroupChatView);
//			timerOnce(100, this, function() {
//				big_map.destroyChildren();
//			});
//			
//			open_planet_data = {};
//		}
//		
//		private function onClose():void{
//			super.close();
//			
//			currSceneName && SceneManager.intance.setCurrentScene(currSceneName);
//		}
//		
//		public function get view():ArmyGroupMainViewUI{
//			_view = _view || new ArmyGroupMainViewUI();
//			return _view;
//		}
//	}
//}