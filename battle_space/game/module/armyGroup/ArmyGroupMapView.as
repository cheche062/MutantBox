package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupMainViewUI;
	import MornUI.armyGroup.newArmyGroup.NewArmyGroupViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.starBar;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.bag.BagManager;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.armyGroup.fight.ArmyGroupFightView;
	import game.module.armyGroup.newArmyGroup.StarItem;
	import game.module.armyGroup.newArmyGroup.StarVo;
	import game.module.chatNew.LiaotianView;
	import game.module.tips.ResourceTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * 国战
	 * @author hejianbo
	 * 
	 */
	public class ArmyGroupMapView extends BaseView
	{
		public static var CURRENT_SEASON:int = 0;
		/**当前场景名称*/
		private var currSceneName:String;
		/**整张大地图*/
		private var big_map:Box;
		/**大地图内的包裹元素*/ //用来放_ufoContainer plantCtrlView ...
		private var _bigMapOtherWrap:Box;
		/**迷雾*/ 
		private var _flogWrap:Box;
		
		/**星球上的控件按钮*/
		private var plantCtrlView:ArmyGroupPlantCtrlView;
		
		/**地图基础背景*/
		private const MAP_BASE_BG:int = "armyGroup/newArmy/bg1.png";
		// 整张大地图是由多个星系构成，每个星系是由9张小地图构成
		/**单位小地图的宽度*/
		private const ITEM_MAP_WIDTH:int = 928;
		private const ITEM_MAP_HEIGHT:int = 902;
		/**数据表坐标对应的单位宽度*/		
		private const ITEM_DATA_WIDTH:int = ITEM_MAP_WIDTH * 3 / 2;
		/**数据表坐标对应的单位高度*/		
		private const ITEM_DATA_HEIGHT:int = ITEM_MAP_HEIGHT * 3 / 2;
		
		/**单个星系内的各星球的相对坐标表*/
		private var relative_pos_list:Array;
		/**单个星系的坐标*/
		private var galact_pos_Obj:Object;
		/**移动的间隔时间*/
		private var move_during_time:int;
		/**世界boss入口的所属星系*/
		private var boss_coord:int;
		/**世界boss按钮*/
		private var btn_world_boss:Image;
		/**世界boss按钮特效*/
		private var bossAni:Animation;
		
		/**所有的星球集合  以星球id为字段*/
		private var _plantStarCollection:Object;
		private var _ufoContainer:Box;

		private var _ufoMove:Animation;
		private var _ufoStandby:Animation;

		/**
		 * 星球信息
		 */
		public static var open_planet_data:Object
		
		private var _currentCityId:int=-1;
		private var _lastSelectID:int=-1;

		private var _selectedPlantInfo:StarVo;

		private var _findWay:ArmyGroupFindPath;
		private var _movePath:Array=[];
		private var _isMoving:Boolean = false;
		/**公会资金*/
		public static var _guild_cash:int = 0;
		/**公会职位*/
		public static var _guild_position:int = 0;
		/**玩家已使用的公会资金*/
		public static var _user_guild_cash_used:int = 0;
		/**所有的按钮*/
		private var allButtons:Array;
		
		private var _residue_quit_city_number:int=0;
		private var _residue_protection_number:int = 0;
		
		private var _nowFightState:int = 0;
		/**当前地图的缩放比*/
		private var _scaleNum:Number = 0.5;
		
		private var season_fight_start_time = 0;
		private var season_fight_end_time = 0;
		private var day_fight_start_time = 0;
		private var day_fight_end_time = 0;
		
		/**从外部消息点进来的目标城池id*/
		private var target_city_id = 0;
		/**相关交战城池*/
		private var legionwar_state;
		/**BOSS开启状态*/
		private var boss_state;
		/**相关交战城池当前系数*/
		private var _currStarIndex= 0;
		
		public function ArmyGroupMapView()
		{
			super();
			_m_iLayerType = LayerManager.M_POP;
		}
		
		/**初始化UI*/
		override public function createUI():void {
			GameConfigManager.intance.loaderArmyGroup();
			initRelativePosList();
			
			addChild(view);
			view.graphics.drawRect(0, 0, view.width, view.height, "#000");
			view.mouseThrough = true;
			view.topCenterArea.mouseThrough = true;
			
			_bigMapOtherWrap = new Box();
			_bigMapOtherWrap.zOrder = 2;
			_bigMapOtherWrap.mouseEnabled = _bigMapOtherWrap.mouseThrough = true;
			
			initUI();
			
			var juntuan_canshu = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
			move_during_time = Number(juntuan_canshu["49"].value);
			//			move_during_time = Number(0.5);
			
			view.GoodImage.width=view.GoodImage.height=50;
			view.GoodImage.skin=GameConfigManager.getItemImgPath(5);
			view.GuildImage.skin=GameConfigManager.getItemImgPath(93201);
			
			view.ArmyGroupFood.width=view.ArmyGroupFood.height=50;
			view.ArmyGroupFood.skin=GameConfigManager.getItemImgPath(93200);
			
			view.timeArea.visible = false;
			view.timeArea.mouseEnabled = false;
			view.getRewardArea.visible = false;
			
			allButtons = ([btn_world_boss,  view.btn_boss, view.btn_focus, view.CloseBtn, view.ChargeBtn, view.btn_shop,
				view.CityBtn, view.MissionBtn, view.MilitaryRankBtn, view.RankBtn, view.helpBtn,
				view.chatBtn, view.npcInfoBtn, view.fightLogbtn, view.GuildImage, view.ArmyGroupFood, view.GoodImage,
				view.WaterImage, view.timeDetailBtn, view.getReBtn,view.btn_war]);
			
			// 不要了
			view.chatBtn.visible = false;
		}
		
		override public function show(obj):void
		{
			this.mouseEnabled = false;
			onStageResize();
//			Browser.window.gg = this;
//			Laya["Stat"].show();
//			console.clear();
			trace("=========================================================ok")
			trace("ModuleName:ArmyGroupMapView");
			
			if (obj) {
				target_city_id = obj.cityId;
			}
			if(obj && obj.legionwar_state){
				legionwar_state = obj.legionwar_state;
			}
			if(legionwar_state && legionwar_state.length){
				view.btn_war.visible = true;
			}
			else{
				view.btn_war.visible = false;
			}
			if(obj && obj.boss_state){
				boss_state = obj.boss_state;
			}
			if(boss_state){
				view.btn_boss.skin = 'armyGroup/btn_boss.png';
				bossAni.visible = true;
			}
			else{
				view.btn_boss.skin = 'armyGroup/btn_boss_1.png';
				bossAni.visible = false;
			}
			
			big_map = new Box();
			view.addChildAt(big_map, 0);
			big_map.addChild(_bigMapOtherWrap);
			
			if (SceneManager.intance.m_sceneCurrent) {
				currSceneName = SceneManager.intance.currSceneName;
				SceneManager.intance.m_sceneCurrent.close();
				SceneManager.intance.m_sceneCurrent = null;
			}
			view.rt0.visible=false;
			view.rt1.visible=false;
			view.rt2.visible=false;
			view.rt3.visible = false;
			view.rt4.visible = false;
			
			saveSpaceMapVisible = ToolFunc.throttle(saveSpaceMapVisible, this, 1500);
			scaleHandler = ToolFunc.throttle(scaleHandler, this, 300);
			
			
			// 添加事件放在后面
			super.show();
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_MAP_INIT);
			WebSocketNetService.instance.sendData(ServiceConst.MISSION_INIT_DATA, ["legion"]);
			// 获取NPC攻城数据，判断自己是否被NPC攻击，以显示小红点		
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_NPC_INFO);
			// 聊天
			XFacade.instance.openModule(ModuleName.LiaotianView, {
				tabs: [LiaotianView.WORLD_CHAT, LiaotianView.GUILD_CHAT, LiaotianView.FRIEND_CHAT]
			});
			LiaotianView.current_module_view = this;
		}

		/**读一下每个星系内的星球相对坐标*/ 
		private function initRelativePosList():void {
			relative_pos_list = [];
			var newArmyGroup:NewArmyGroupViewUI = new NewArmyGroupViewUI();
			for (var i = 0; i < newArmyGroup.dom_test_sprite.numChildren; i++) {
				var child:Image = newArmyGroup.dom_test_sprite.getChildAt(i);
				relative_pos_list.push([child.x, child.y]);
			}
			newArmyGroup.destroy();
		}

		/**初始化ui数据*/
		private function initUI():void
		{
			_ufoContainer=new Box();
			_ufoContainer.anchorX = _ufoContainer.anchorY=0.5;
			_ufoContainer.size(200, 100);
//			_ufoContainer.graphics.drawRect(0, 0, 200, 100, "#f00");

			_ufoStandby=createAnimation("appRes/atlas/effects/ufoStandby.json");
			_ufoStandby.play();
			_ufoMove=createAnimation("appRes/atlas/effects/ufoMove.json");
			_ufoMove.visible=false;
			
			_ufoContainer.addChildren(_ufoStandby, _ufoMove);
			_ufoContainer.scale(2,2);
			
			bossAni  = createAni("appRes/effects/boss.json");
			bossAni.visible = false;
			bossAni.width = bossAni.height = 550;
			bossAni.anchorX = 0.5;
			bossAni.anchorY = 0.5;
			bossAni.interval = 70;
			
			btn_world_boss = new Image("armyGroup/newArmy/bg_boss.png");
			btn_world_boss.mouseEnabled = true;
			btn_world_boss.visible = false;
			btn_world_boss.anchorX = 0.5;
			btn_world_boss.anchorY = 0.5;
			
			_flogWrap = new Box();
			
			_bigMapOtherWrap.addChildren(_ufoContainer, bossAni,btn_world_boss);
			
			plantCtrlView=new ArmyGroupPlantCtrlView();
			plantCtrlView.close();
		}
		
		private function createAni(url:String):Animation {
			var roleAni:Animation = new Animation();
			roleAni.loadAtlas(url, Handler.create(this, function(){
				roleAni.play();
			}));
			
			return roleAni;
		}
		
		private function createAnimation(url:String):Animation {
			var ani=new Animation();
			ani.loadAtlas(url);
			ani.x=-100;
			ani.y=-75;
			ani.interval=100;
			ani.loop=true;
			return ani;
		}

		private function refreshUserData(... args):void
		{
			var tf:*
			view.goldText.text=XUtils.formatResWith(User.getInstance().food);
			view.goldText.color = (User.getInstance().food >= User.getInstance().sceneInfo.getResCap(DBItem.FOOD)) ? "#ff6600" : "#ffffff";
			view.GuidMoneyText.text=XUtils.formatResWith(_guild_cash);
			view.GuidMoneyText.color = 
				(_guild_cash >= parseInt(GameConfigManager.ArmyGroupGuildMoneyMax[User.getInstance().guildLv])) ? "#ff6600" : "#ffffff";
			view.armyFood.text = BagManager.instance.getItemNumByID(93200);
			view.WaterText.text = XUtils.formatResWith(User.getInstance().water);
			if (args.length) { //加入动画
				switch (args[0]) {
					case DBItem.WATER:
						tf=view.WaterText;
						break;
					case DBItem.FOOD:
						tf=view.goldText;
						break;
					case DBItem.ARMY_GROUP_FOOD:
						tf=view.armyFood;
						break;
					case 93201:
						tf=view.GuidMoneyText;
						break;
				}
				if (tf) XUtils.showTxtFlash(tf);
			}
		}
		
		/**创建整个大地图*/
		private function createAllBigMap():void {
			// 开放的星球数据数组版
			var _open_planet_data_list:Array = ToolFunc.objectValues(open_planet_data);
			// 所有的开放星系内的左上角那个星球
			var galactPosList:Array = _open_planet_data_list.filter(function(item:StarVo){
				return item.sequence == 1;
			}).map(function(item:StarVo) {
				return { "id": item.id, "block": item.block, "cor": item.cor };
				// 排序  星系层级问题
			}).sort(function(item0, item1) {
				return item0.block - item1.block;
			});
			
			//			trace("【所有的中心太阳星系】", galactPosList);
			
			galactPosList.forEach(function(item:StarVo) {
				var sameKindBlockStars:Array = _open_planet_data_list.filter(function(innerItem:StarVo){
					return item.block == innerItem.block;
				});
				var galactMap:Sprite = createGalactMap(sameKindBlockStars);
				var posArr = item.cor.split(",");
				var _x = posArr[0] * ITEM_DATA_WIDTH;
				var _y = posArr[1] * ITEM_DATA_HEIGHT;
				galactMap.pos(_x, _y);
				galact_pos_Obj[item.block] = [_x, _y];
				galactMap.visible = false;
				big_map.addChildAt(galactMap, 0);
			});
			big_map.size(getMaxPosValue("x", "width"), getMaxPosValue("y", "height"));
			
			// 平铺背景
			ToolFunc.loadImag(MAP_BASE_BG, function(t:Texture) {
				big_map.graphics.clear();
				big_map.graphics.fillTexture(t, 0, 0, big_map.width, big_map.height);
			});
			
			big_map.pivot(big_map.width / 2, big_map.height / 2);
			big_map.pos(stage.width / 2, stage.height / 2);
			big_map.graphics.drawRect(0, 0, big_map.width, big_map.height, "#000");
			_scaleNum = minScaleNum;
			big_map.scale(_scaleNum, _scaleNum);
			returnBtnBossScale(_scaleNum);
			
			big_map.addChildAt(_flogWrap, 0);
			
			cteateFog();
		}
		
		/**创建迷雾*/
		private function cteateFog():void {
			var data_city = ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
			// x y 方向上的个数
			var xNum:int = Math.floor(big_map.width / (ITEM_MAP_WIDTH * 3));
			var yNum:int = Math.floor(big_map.height / (ITEM_MAP_HEIGHT * 3));
			
			_flogWrap.destroyChildren();
			for (var i = 0; i <= xNum * yNum; i++) {
				var img_wrap:Sprite = createSingleFog();
				var x = (i % xNum) * (ITEM_MAP_WIDTH * 3);
				var y = Math.floor(i / xNum) * (ITEM_MAP_HEIGHT * 3);
				img_wrap.pos(x + img_wrap.width / 2, y + img_wrap.height / 2);
				_flogWrap.addChild(img_wrap);
			}
		}
		
		private function createSingleFog():Sprite{
			var img_wrap:Box = new Box();
			img_wrap.size(ITEM_MAP_WIDTH * 3, ITEM_MAP_HEIGHT * 3);
			// 地图
			for (var i = 0; i < 9; i++ ) {
				var img:Image = new Image();
				img.skin = "armyGroup/newArmy/1_0" + ( i + 1) + ".png";
				img.pos(ITEM_MAP_WIDTH * (i % 3), ITEM_MAP_HEIGHT * Math.floor(i / 3));
				img_wrap.addChild(img);
			}
			img_wrap.anchorX = img_wrap.anchorY = 0.5; 
			img_wrap.scale(1.3, 1.3);
			img_wrap.cacheAsBitmap = true;
			return img_wrap;
		}
		
		/**获取某星球相对于整个大地图的坐标*/
		private function getStarPosInWholeMap(id):Array {
			var id1 = open_planet_data[id] ? id : getDefaultId(open_planet_data);
			var id2 = _plantStarCollection[id] ? id : getDefaultId(_plantStarCollection);
			var data:StarVo = open_planet_data[id1];
			var star:StarItem = _plantStarCollection[id2] ;
			trace("getStarPosInWholeMap", id)
			return [star.x + galact_pos_Obj[data.block][0], star.y + galact_pos_Obj[data.block][1]];
		}
		
		/**获取默认的id*/
		private function getDefaultId(data):int {
			for (var i in data) {
				return i;
			}
		}
		
		private function getMaxPosValue(direction, witchSide):int{
			return Math.max.apply(null, big_map._childs.map(function(item:Sprite){
				return item[direction] + item[witchSide];
			}));
		}
		
		/**创建子星系地图*/
		private function createGalactMap(starList:Array):Sprite {
			var item_map:Box = new Box();
			var img_wrap:Sprite = new Sprite();
			var star_wrap:Sprite = new Sprite();
			item_map.size(ITEM_MAP_WIDTH * 3, ITEM_MAP_HEIGHT * 3);
//			item_map.graphics.drawRect(0, 0, ITEM_MAP_WIDTH * 3, ITEM_MAP_HEIGHT * 3, "#333");
			// 地图
			for (var i = 0; i < 9; i++ ) {
				var img:Image = new Image();
				img.skin = "armyGroup/newArmy/map_0" + ( i + 1) + ".png";
				img.pos(ITEM_MAP_WIDTH * (i % 3), ITEM_MAP_HEIGHT * Math.floor(i / 3));
				img_wrap.addChild(img);
			}
			img_wrap.cacheAsBitmap = true;
			
			//星球
			starList.forEach(function(item:StarVo) {
				var star:StarItem = new StarItem();
				star.init(item);
				var pos = relative_pos_list[item.sequence - 1];
				star.pos(pos[0], pos[1]);
				star_wrap.addChild(star);
				_plantStarCollection[item.id] = star;
			});
			
			// 最后的一个子元素  （后面需要取）
			item_map.addChildren(img_wrap, star_wrap);
			
			return item_map;
		}
		
		/**总共的星球初始数据（未从后端更新过）*/
		private function updateOpenPlanetIds(map_fog):void {
			var data_fog = ResourceManager.instance.getResByURL("config/juntuan/juntuan_fog.json");
			var data_city = ResourceManager.instance.getResByURL("config/juntuan/juntuan_city.json");
			data_fog[map_fog]["open_planet"].split(",").forEach(function(item) {
				var starVo:StarVo = new StarVo();
				starVo.init(data_city[item]);
				open_planet_data[item] = starVo;
			});
			boss_coord = data_fog[map_fog]["boss_coord"];
		}

		/**获取服务器消息*/
		private function serviceResultHandler(... args):void {
			trace("【国战数据】", args[0], args[1]);
			var server_data = args[1];
			switch (args[0]) {
				case ServiceConst.ARMY_GROUP_MAP_INIT:
					season_fight_start_time = args[1].season_fight_start_time;
					season_fight_end_time = args[1].season_fight_end_time;
					day_fight_start_time = args[1].day_fight_start_time;
					day_fight_end_time = args[1].day_fight_end_time;
					
					User.getInstance().set_food_protect = Number(args[1].user_data["foodProtection"]);
					
					open_planet_data = {};
					_plantStarCollection = {};
					galact_pos_Obj = {};
					
					updateOpenPlanetIds(server_data["map_fog"]);
					createAllBigMap(open_planet_data);
					
					btn_world_boss.visible = !!boss_coord;
//					bossAni.visible = !!boss_coord;
					if (btn_world_boss) {
						btn_world_boss.pos(galact_pos_Obj[boss_coord][0], galact_pos_Obj[boss_coord][1]);	
						bossAni.pos(btn_world_boss.x-1400, btn_world_boss.y-1400);
					}
					
					User.getInstance().guildLv = args[1].guild_level;
					_currentCityId = args[1].city_id == "1" ? "138118" : args[1].city_id;
					_guild_position = args[1].guild_position;
					_user_guild_cash_used = Number(args[1].user_guild_cash_used);
					
					// ufo的坐标
					var posArr:Array = getStarPosInWholeMap(_currentCityId);
					_ufoContainer.pos(posArr[0], posArr[1]);
					
					_residue_quit_city_number=args[1].residue_quit_city_number;
					_residue_protection_number = args[1].residue_protection_number;
					CURRENT_SEASON = args[1].season_id;
					_nowFightState = args[1].season_state;
					
					checkTimeTxt();
					civilWarTime();
					
					view.timeArea.visible = false;
//					view.getRewardArea.visible = Boolean(parseInt(_nowFightState) == 3);
					
					_guild_cash = Number(args[1].guild_cash);
					refreshUserData();

					if (args[1].role_military_status)
					{
						view.rt2.visible=true;
					}
					
					//这边要加上总赛季排行榜奖励是否可领取
					if (args[1].role_yesterday_get_status || args[1].role_kill_re_status)
					{
						view.rt3.visible=true;
					}
					
					//寻路测试
					_findWay = new ArmyGroupFindPath();
					var filterFn = function(item){
						return !!item && open_planet_data[item];
					}
					ToolFunc.objectValues(open_planet_data).forEach(function(item:StarVo) {
						var links:Array = item.xlcc.split(";").filter(filterFn);
						_findWay.setMapData(item.id, links);
					});
					
					focusPlant(target_city_id || _currentCityId);
					
					this.mouseEnabled = true;
					
					break;
				
				// 部分获取星球信息
				case ServiceConst.ARMY_GROUP_GET_PART_MAP:
					for (var id in server_data["city_info"]) {
						var item:StarVo = open_planet_data[id];
						item.serverDataEnter(server_data["city_info"][id]);
					}
					
					updateAllVisibleStarView();
					
					break;
				
				case ServiceConst.MISSION_INIT_DATA:
					var mData:Object=args[1].list;
					for (var d:String in mData)
					{
						if (parseInt(mData[d][0]) == 1)
						{
							view.rt1.visible=true;
						}
					}
					break;
				case ServiceConst.ARMY_GROUP_CHANGE_CITY:
					if (_isMoving && _selectedPlantInfo.id == _lastSelectID) return;
					
					_lastSelectID = _selectedPlantInfo.id
					// 寻路节点
					_movePath = _findWay.findPath(_currentCityId, _selectedPlantInfo.id);
					
					if (!_isMoving) {
						moveUFO();

						_ufoMove.play();
						_ufoMove.visible=true;

						_ufoStandby.stop();
						_ufoStandby.visible=false;
					}
					
					_currentCityId = _selectedPlantInfo.id;
					break;
				
				case ServiceConst.ARMY_GROUP_GIVE_UP_PLANT:
					_residue_quit_city_number--;
					break;
				
				case ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO:
					var updateID:int = args[1][1];
					var item_data:StarVo = open_planet_data[updateID];
					item_data.serverDataEnter(args[1][2]);
					
					updateSomeoneStarView(updateID);
					
					break;
				
				case ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY:
					_guild_cash = Number(args[2]);
					refreshUserData([93201]);
					break;
				
				case ServiceConst.ARMY_GROUP_DECLARE_WAR:
					
					
					break;
				
				case ServiceConst.ARMY_GROUP_BUY_PROTECTED:
					_selectedPlantInfo.buy_protection_number++;
					_residue_protection_number--;
					_user_guild_cash_used += StarVo.getProtectCostByPosition(_guild_position);
					
					break;
				
				case ServiceConst.ARMY_GROUP_NPC_INFO:
					trace("npcInfo", args);
					var _npcListArr = args[2].npc_info;
					//trace("_npcListArr", _npcListArr);
					if (!_npcListArr || _npcListArr.length == 0)
					{
						view.rt4.visible = false;
					} 
					else {
						var currArr = [];
						for (var i=0; i < _npcListArr.length; i++){
							if(_npcListArr[i].guild_id == User.getInstance().guildID && 
								_npcListArr[i].war_time - TimeUtil.nowServerTime<= 60*4
								&& _npcListArr[i].status != 3){
								currArr.push(_npcListArr[i]);
							}
						}
						view.rt4.visible = currArr.length;
					}
					break;
				default:
					break;
			}
		}
		
		private function joinLabelString(s0, s1, s3, c0, c1):String {
			if (!CURRENT_SEASON || !GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1]) return "";
			return ("<div style='width:520px;font-size:18px;color:"+c0+";align:center'>" +
				GameLanguage.getLangByKey(s0)+ "<span style='color:"+c1+"'>&nbsp;" + 
				GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1][s1] +
				"&nbsp;</span><span style='color:"+c0+"'>" + GameLanguage.getLangByKey("L_A_21015")  + 
				"</span><span style='color:"+c1+"'>&nbsp;" + 
				GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1][s3] + "</span></div>");
		}
		
		private function checkTimeTxt():void
		{
			view.ftTxt.innerHTML = joinLabelString("L_A_21012", "fight_begin", "fight_end", "#4c4c4c", "#4c4c4c");
			view.jsTxt.innerHTML = joinLabelString("L_A_21013", "result_begin", "result_end", "#4c4c4c", "#4c4c4c");
			view.ljTxt.innerHTML = joinLabelString("L_A_21014", "reward_begin", "reward_end", "#4c4c4c", "#4c4c4c");
			view.timeBox.visible = false;
			switch(parseInt(_nowFightState)) {
				case 1:
					view.ftTxt.innerHTML = 
					joinLabelString("L_A_21012", "fight_begin", "fight_end", "#ffd6a4", "#fff");
					break;
				
				case 2:
					view.timeBox.visible = false;
					view.jsTxt.innerHTML = 
					joinLabelString("L_A_21013", "result_begin", "result_end", "#ffd6a4", "#fff");
					view.timeBox.visible = false;
					break;
				case 3:
					view.timeBox.visible = false;
					view.ljTxt.innerHTML = 
					joinLabelString("L_A_21014", "reward_begin", "reward_end", "#ffd6a4", "#fff");
					break;
			}
		}
		
		/**将星系移动到屏幕中间*/
		private function focusPlant(city_id:String, isAni:Boolean = false):void {
			var posArr = getStarPosInWholeMap(city_id);
			setFocuseBigmapPos(posArr, isAni);			 		
			if (_currentCityId != city_id) {
				sendCurrentCityPosId(city_id);
			}
		}
		
		/**发送设置当前飞机的所在星系*/
		private function sendCurrentCityPosId(city_id):void {
			sendData(ServiceConst.ARMY_GROUP_CHANGE_CITY, [city_id]);
		}
		
		/**由于世界BOSS按钮大地图随大地图大小改变而改变，现在要还原世界BOSS按钮大小*/
		private function returnBtnBossScale(scaleNum):void {
			if(!btn_world_boss){
				return;
			}
			btn_world_boss.scale(1/scaleNum, 1/scaleNum);
			bossAni.scale(1/scaleNum, 1/scaleNum);
		}
		
		/**给bigmap定位*/
		private function setFocuseBigmapPos(posArr, isAni:Boolean = false):void {
			_scaleNum = minScaleNum;
			big_map.scale(_scaleNum, _scaleNum);
			returnBtnBossScale(_scaleNum);
			var _x = stage.width / 2 + (big_map.width / 2 - posArr[0]) * big_map.scaleX;
			var _y = stage.height / 2 + (big_map.height / 2 - posArr[1]) * big_map.scaleY;
			var posArr = limitBigMapPos(_x, _y, _scaleNum);
			_x = posArr[0];
			_y = posArr[1];
			
			if (isAni) {
				Tween.to(big_map, {x: _x, y: _y}, 700, Ease.linearNone, Handler.create(this, function() {
					saveSpaceMapVisible();
				}));
			} else {
				big_map.pos(_x, _y);
				saveSpaceMapVisible();
			}
		}

		public function moveUFO():void {
			_movePath.shift();
			if (_movePath.length == 0) {
				_ufoMove.stop();
				_ufoMove.visible = false;
				_ufoStandby.play();
				_ufoStandby.visible = true;
				_isMoving=false;
				return;
			}
			
			_isMoving=true;
			_currentCityId = _movePath[0].nodeID;
			var targetPos:Array = getStarPosInWholeMap(_currentCityId);
			_ufoContainer.scaleX = _ufoContainer.x < targetPos[0] ? -1 * Math.abs(_ufoContainer.scaleX) : 1 * Math.abs(_ufoContainer.scaleX);
			
			Tween.to(_ufoContainer, {x: targetPos[0], y: targetPos[1]}, move_during_time * 1000, Ease.linearNone, 
				new Handler(this, moveUFO));
			
			if (isOutNaviga) focusPlant(_currentCityId, true);
		}
		
		/**是否是外部导航*/
		private var isOutNaviga:Boolean = false;
		public function armyGroupEventHandler(cmd:String, ... args):void
		{
			switch (cmd)
			{
				case ArmyGroupEvent.JUMP_PLANT:
				case ArmyGroupEvent.GO_NPC_PLANT:
					isOutNaviga = true;
					_selectedPlantInfo = open_planet_data[args[0]];
					if (_currentCityId != _selectedPlantInfo.id) {
						sendCurrentCityPosId(_selectedPlantInfo.id);
					}
					
					XFacade.instance.closeModule(ArmyGroupOutPutView);
					XFacade.instance.closeModule(ArmyGroupFightLogView);
					
					break;
				
				case ArmyGroupEvent.SELECT_PLANT:
					isOutNaviga = false;
					updatePlantCtrlViewPos(args[0]);
					
					break;
				
				case ArmyGroupEvent.HIDE_RED_DOT:
					switch (args[0])
					{
						case 0:
							view.rt0.visible=false;
							break;
						case 1:
							view.rt1.visible=false;
							break;
						case 2:
							view.rt2.visible=false;
							break;
						case 3:
							view.rt3.visible=false;
							break;
						case 4:
							view.rt4.visible=false;
							break;
						default:
							break;
					}
					break;
				
				default:
					break;
			}
		}
		
		/**更新星球控件的位置*/
		private function updatePlantCtrlViewPos(city_id):void {
			_selectedPlantInfo = open_planet_data[city_id];
			var posArr:Array = getStarPosInWholeMap(city_id);
			plantCtrlView.pos(posArr[0], posArr[1]);
			_bigMapOtherWrap.addChild(plantCtrlView);
			plantCtrlView.show(_selectedPlantInfo.id == _currentCityId, _selectedPlantInfo.isMyGuilde, _isMoving, _scaleNum);
		}

		private function mapStarDropHandler(e:Event):void {
			var str:String;
			switch (e.target)
			{
				case plantCtrlView.view.defBtn:
					if ((_selectedPlantInfo.attempts - _selectedPlantInfo.buy_protection_number) <= 0) {
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_20956"));
					} else {
						XFacade.instance.openModule(ModuleName.AGBuyProtectView,
							[_selectedPlantInfo,_residue_protection_number,_guild_position])
					}
					
					break;
				case plantCtrlView.view.moveBtn:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_CHANGE_CITY, [_selectedPlantInfo.id]);
					break;
				
				case plantCtrlView.view.fightBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupCityInfoView, 
						[_selectedPlantInfo, false, _guild_position, _user_guild_cash_used]);
					break;
				
				case plantCtrlView.view.justLookBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupCityInfoView, 
						[_selectedPlantInfo, true, _guild_position, _user_guild_cash_used]);
					break;

				default:
					break;
			}
			
			var areaX = stage.width - big_map.displayWidth / 2;
			var areaY = stage.height - big_map.displayHeight / 2;
			var area:Rectangle = new Rectangle(areaX, areaY, big_map.displayWidth / 2 - areaX, big_map.displayHeight / 2 - areaY);
			big_map.startDrag(area);
			
			plantCtrlView.close();
		}
		
		//多点问题
		private var lastDistance:Number = 0;
		private function onMouseUp(e:Event=null):void{
			view.off(Event.MOUSE_MOVE, this, onMouseMove);
			view.on(Event.MOUSE_DOWN, this, onMouseDown);
			saveSpaceMapVisible();
		}
		
		private function onMouseDown(e:Event=null):void {
			var touches:Array = e.touches;
			if(touches && touches.length == 2)
			{
				lastDistance = getDistance(touches);
				view.on(Event.MOUSE_MOVE, this, onMouseMove);
				view.off(Event.MOUSE_DOWN, this, onMouseDown);
			}
		}
		
		private var _lastDel:Number=0;
		private function onMouseMove(e:Event=null):void {
			var distance:Number = getDistance(e.touches);
			//判断当前距离与上次距离变化，确定是放大还是缩小
			const factor:Number = 0.001;
			var del:Number = (distance - lastDistance) * factor;
			// 特殊处理关于拉伸的问题
			if(_lastDel > 0 && del < -0.2){
				//不进行缩放
			}else{
				scaleHandler(del);
			}
			
			if(del != 0){
				_lastDel = del;
			}
			lastDistance = distance;
		}
		
		/**计算两个触摸点之间的距离*/
		private function getDistance(points:Array):Number
		{
			var distance:Number = 0;
			if (points && points.length == 2) {
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}

		private function mapStopDropHandler(e:Event):void {
			// TODO Auto Generated method stub
			big_map.stopDrag();
			saveSpaceMapVisible();
		}

		/**地图缩放功能*/
		private function onScale(e:Event):void {
			var deltaScale:Number = e.delta / 50;
			scaleHandler(deltaScale);
//			trace(e.delta)
		}
		
		private function scaleHandler(deltaScale):void {
			if (_isMoving) return;
			var isAdd:Boolean = deltaScale > 0;			
			var scale:Number = big_map.scaleX;
			
			var MAX = 0.8;
			var MIDDLE = 0.5;
			// 最小允许缩小(已知由宽度的缩放来决定高度的缩放)
			var MIN = minScaleNum;
			var rangeList:Array = [MIN, MIDDLE, MAX];
			var _i = rangeList.indexOf(scale);
			var targetIndex = isAdd ? _i + 1 : _i - 1;
			targetIndex = ToolFunc.getAmongValue(targetIndex, 0, rangeList.length - 1);
			if (rangeList[targetIndex] == scale) return;
			
			scale = rangeList[targetIndex];
			
			// 固定缩放比
			scale = minScaleNum;
			
			var posArr = limitBigMapPos(big_map.x, big_map.y, scale);
			big_map.x = posArr[0];
			big_map.y = posArr[1];
			
			if (GameSetting.isPc()) {
				Tween.to(big_map, {scaleX: scale, scaleY: scale}, 100, Ease.linearOut, null, 0, true);
				returnBtnBossScale(scale);
			} else {
				big_map.scale(scale, scale);
				returnBtnBossScale(scale);
			}
			
			_scaleNum = scale;
			
			timerOnce(500, this, saveSpaceMapVisible);
		}
		
		private function get minScaleNum():Number {
			return  Math.max(stage.width / (ITEM_MAP_WIDTH * 3 * 2), stage.width / big_map.width);
		}
		
		/**限制bigmap的坐标*/
		private function limitBigMapPos(x, y, scale):Array {
			var bigMapWidth = big_map.width * scale;
			var bigMapHeight = big_map.height * scale;
			var _x = ToolFunc.getAmongValue(x, stage.width - bigMapWidth / 2, bigMapWidth / 2);
			var _y = ToolFunc.getAmongValue(y, stage.height - bigMapHeight / 2, bigMapHeight / 2);
			return [_x, _y];
		}
		
		/**更新某单个星球视图*/
		private function updateSomeoneStarView(id):void {
			var starView:StarItem = _plantStarCollection[id];
			if (starView && starView.parent && starView.parent["visible"]) {
				starView.updateView(big_map.scaleX);
			}
		}
		
		/**更新视图区域内星球视图*/
		private function updateAllVisibleStarView():void {
			var starIds:Array = getVisibleRangeStarIds();
			starIds.forEach(function(item:String) {
				updateSomeoneStarView(item);
			});
		}
		
		/**国战地图时间相关*/
		private function civilWarTime():void {
//			var data21 = GameConfigManager.ArmyGroupSeasonVec;
//			var objTime = TimeUtil.toDetailTime();
//			var strTime = TimeUtil.timeToTextLetter();
			if(season_fight_start_time != 0 && season_fight_end_time != 0){
				var nowTime = TimeUtil.nowServerTime;
				var unixTimestamp = new Date(nowTime * 1000);
				var commonTime = unixTimestamp.toLocaleString();
				if(nowTime>=season_fight_start_time && nowTime<= season_fight_end_time){//赛季时间中间
					if(nowTime>=day_fight_start_time && nowTime<= day_fight_end_time){//每天可以战斗的时间
						var overTime = day_fight_end_time - nowTime;
						//var objTime = TimeUtil.toDetailTime(overTime);
						var strTime = TimeUtil.getTimeCountDownStr_New(overTime);
						//						view.seasonTimeTxt.innerHTML = 
						//							getTimeString("L_A_21036", strTime, "#ffd6a4", "#fff");
						getTimeLableString("L_A_21036", strTime);
					}
					else if(nowTime<day_fight_start_time){//每天可以战斗的时间前
						var overTime = day_fight_start_time - nowTime;
						//var objTime = TimeUtil.toDetailTime(overTime);
						var strTime = TimeUtil.getTimeCountDownStr_New(overTime);
						//						view.seasonTimeTxt.innerHTML =  
						//							getTimeString("L_A_21037", strTime, "#ffd6a4", "#fff");
						getTimeLableString("L_A_21037", strTime);
					}
					else {//每天可以战斗的时间后,超过当天结束时间
						day_fight_start_time += 86400;
						day_fight_end_time += 86400;
					}
				}
				else if(nowTime<season_fight_start_time){//时间未到该赛季开始的时间
					var overTime = season_fight_start_time - nowTime;
					var strTime = TimeUtil.getTimeCountDownStr_New(overTime,true);
					getTimeLableString("L_A_21038", strTime);
				}
				else{
					view.lbTimeStr.text = '';
					view.lbTimeNum.text = '';
//					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_MAP_INIT);
				}
			}
		}
		
		/**倒计时字符串Lable*/
		private function getTimeLableString(s0, s1):String {
			if (!CURRENT_SEASON || !GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1]) return "";
			view.lbTimeStr.text = GameLanguage.getLangByKey(s0);
			view.lbTimeNum.text = s1;
		}
		
		/**倒计时字符串*/
		private function getTimeString(s0, s1, c0, c1):String {
			if (!CURRENT_SEASON || !GameConfigManager.ArmyGroupSeasonVec[CURRENT_SEASON - 1]) return "";
			return ("<div style='width:520px;font-size:18px;color:"+c0+";align:center'>" +
				GameLanguage.getLangByKey(s0)+ "<span style='color:"+c1+"'>&nbsp;" + s1 + "&nbsp;</span></div>");
		}
		
		/**优化地图显示*/
		private function saveSpaceMapVisible():void {
			var starIds:Array = getVisibleRangeStarIds().filter(function(id:String) {
				var itemData:StarVo = open_planet_data[id]; 
				return !itemData.isServerUpdated;
			});
			
			updateAllVisibleStarView();
			
			if (starIds.length) {
				trace("请求数据ids", starIds.join(","));
				sendData(ServiceConst.ARMY_GROUP_GET_PART_MAP, [starIds.join(",")]);
			}
		}
		
		/**获取在可视区内的星球ids*/
		private function getVisibleRangeStarIds():Array {
			var result:Array = [];
			// 除去 _flog_wrap    _bigMapOtherWrap,
			var others:Array = [_flogWrap, _bigMapOtherWrap];
			var childs = big_map._childs.filter(function(item) {
				return others.indexOf(item) == -1;
			});
			childs.forEach(function(item:Sprite){
				// x方向更大
				var maxX:Boolean = item.x * big_map.scaleX > stage.width + (big_map.displayWidth / 2  - big_map.x);
				// x方向更小
				var minX:Boolean = (item.x + item.width) * big_map.scaleX < big_map.displayWidth / 2 - big_map.x;
				// y方向更大
				var maxY:Boolean = item.y * big_map.scaleY > stage.height + (big_map.displayHeight / 2  - big_map.y);
				// y方向更小
				var minY:Boolean = (item.y + item.height) * big_map.scaleY < big_map.displayHeight / 2 - big_map.y;
				item.visible = !maxX && !minX && !maxY && !minY;
				
				if (item.visible) {
					// 遍历单个星系的所有星球
					item.getChildAt(item.numChildren - 1)._childs.forEach(function(star:StarItem){
						result.push(star.star_data.id);
					});
				}
			});
			
			return result;
		}
		
		/**点击事件的监听*/
		private function onClickHandler(dom):void {
			var info:Object={};
			switch (dom) {
				// 世界boss
				case btn_world_boss:
					var boss_param_data = ResourceManager.instance.getResByURL("config/p_boss/p_boss_param.json");
					var _lv = Number(boss_param_data["2"].value);
					if (User.getInstance().sceneInfo.getBaseLv() < boss_param_data["2"].value) {
						return XTip.showTip(GameLanguage.getLangByKey("L_A_2757").replace("{0}", _lv));
					}
					
					XFacade.instance.openModule(ModuleName.WorldBossEnterView);
					
					break;
				case view.btn_boss:
					setFocuseBigmapPos(galact_pos_Obj[boss_coord], true);
					
					break;
				case view.btn_focus:
					focusPlant(_currentCityId, true);
					
					break;
				case view.CloseBtn:
					this.close();
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_LEAVE_MAP);
					break;
				case view.ChargeBtn:
					XFacade.instance.openModule(ModuleName.ChargeView);
					break;
				//我方战斗城池
				case view.btn_war:
					focusPlant(legionwar_state[_currStarIndex], true);
					_currStarIndex++;
					if(_currStarIndex>=legionwar_state.length){
						_currStarIndex = 0;
					}
					break;
				//商店
				case view.btn_shop:
					XFacade.instance.openModule(ModuleName.ArmyGroupOutPutView);
					break;
				// 我的所有城池产出
				case view.CityBtn:
					if (!User.getInstance().guildID) {
						XTip.showTip("L_A_3019");
					} else {
						XFacade.instance.openModule(ModuleName.ArmyMyCityOutputView);
					}
					
					break;
				case view.MissionBtn:
					XFacade.instance.openModule(ModuleName.ArmyDailyMissionView);
					break;
				case view.MilitaryRankBtn:
					XFacade.instance.openModule(ModuleName.MilitaryRankView);
					break;
				case view.RankBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupRankView);
					break;
				case view.helpBtn:
					var msg:String = GameLanguage.getLangByKey("L_A_16001");
					XTipManager.showTip(msg.replace(/##/g, '\n'));
					break;
				case view.chatBtn:
//					XFacade.instance.openModule(ModuleName.ArmyGroupChatView, [false]);
					break;
				case view.npcInfoBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupFightLogView,true);
					break;
				case view.fightLogbtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupFightLogView,false);
					break;
				case view.GuildImage:
					info={};
					info.name=GameConfigManager.items_dic[93201].name;
					info.des=GameConfigManager.items_dic[93201].des;
					info.icon=GameConfigManager.items_dic[93201].icon;
					info.max = _guild_cash;
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.ArmyGroupFood:
					ItemTips.showTip("93200");
					
					break;
				case view.GoodImage:
					info={};
					info.name=GameConfigManager.items_dic[5].name;
					info.des=GameConfigManager.items_dic[5].des;
					info.icon=GameConfigManager.items_dic[5].icon;
					info.max=User.getInstance().food + "/" + User.getInstance().sceneInfo.getResCap(DBItem.FOOD);
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.WaterImage:
					info={};
					info.name=GameConfigManager.items_dic[1].name;
					info.des=GameConfigManager.items_dic[1].des;
					info.icon=GameConfigManager.items_dic[1].icon;
					info.max=User.getInstance().water + "";
					XTipManager.showTip(info, ResourceTip);
					break;
				case view.timeDetailBtn:
					if (view.timeArea.visible)
					{
						view.timeArea.visible = false;
//						view.getRewardArea.visible = Boolean(parseInt(_nowFightState) == 3);
						view.getRewardArea.visible = false;
					}
					else
					{
						view.timeArea.visible = true;
						view.getRewardArea.visible = false;
					}
					
					break;
				case view.getReBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupSeasonRewardView);
					break;
				default:
					break;
			}
		}
		
		/**布局*/
		override public function onStageResize():void {
			view.size(stage.width, stage.height);
			view.bottomRightArea.x=LayerManager.instence.stageWidth - view.bottomRightArea.width;
			view.bottomRightArea.y=LayerManager.instence.stageHeight - view.bottomRightArea.height;
			view.topCenterArea.x=(LayerManager.instence.stageWidth - view.topCenterArea.width) / 2;
			view.chatBtn.y = LayerManager.instence.stageHeight - view.chatBtn.height >> 1;
			view.dom_btns_box.y = stage.height - 100;
		}
		
		override public function addEvent():void {
			this.on(Event.MOUSE_WHEEL, this, onScale);
			view.on(Event.MOUSE_UP, this, onMouseUp);
			view.on(Event.MOUSE_OUT, this, onMouseUp);
			view.on(Event.MOUSE_DOWN, this, onMouseDown);
			
			big_map.on(Event.MOUSE_DOWN, this, this.mapStarDropHandler);
			big_map.on(Event.MOUSE_UP, this, this.mapStopDropHandler);
			
			// 分开添加避免拖拽地图造成的误操作触发它
			allButtons.forEach(function(item) {
				item.on(Event.CLICK, this, onClickHandler, [item]);
			}, this);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_MAP_INIT), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHANGE_CITY), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GIVE_UP_PLANT), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_PART_MAP), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_NPC_INFO), this, this.serviceResultHandler, [ServiceConst.ARMY_GROUP_NPC_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(User.PRO_CHANGED, this, refreshUserData);
			
			Signal.intance.on(ArmyGroupEvent.SELECT_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.SELECT_PLANT]);
			Signal.intance.on(ArmyGroupEvent.JUMP_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.JUMP_PLANT]);
			Signal.intance.on(ArmyGroupEvent.HIDE_RED_DOT, this, armyGroupEventHandler, [ArmyGroupEvent.HIDE_RED_DOT]);
			Signal.intance.on(ArmyGroupEvent.GO_NPC_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.GO_NPC_PLANT]);
			
			//国战倒计时相关
			Laya.timer.loop(1000, this,civilWarTime);
		}
		
		override public function removeEvent():void {
			this.off(Event.MOUSE_WHEEL, this, onScale);
			view.off(Event.MOUSE_UP, this, onMouseUp);
			view.off(Event.MOUSE_OUT, this, onMouseUp);
			view.off(Event.MOUSE_DOWN, this, onMouseDown);
			
			big_map.off(Event.MOUSE_DOWN, this, this.mapStarDropHandler);
			big_map.off(Event.MOUSE_UP, this, this.mapStopDropHandler);
			
			allButtons.forEach(function(item) {
				item.offAll(Event.CLICK);
			}, this);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_MAP_INIT), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MISSION_INIT_DATA), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHANGE_CITY), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GIVE_UP_PLANT), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_CITY_INFO), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_UPDATA_GUILD_MONEY), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_PART_MAP), this, this.serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_NPC_INFO), this, this.serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(User.PRO_CHANGED, this, refreshUserData);
			
			Signal.intance.off(ArmyGroupEvent.SELECT_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.SELECT_PLANT]);
			Signal.intance.off(ArmyGroupEvent.JUMP_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.JUMP_PLANT]);
			Signal.intance.off(ArmyGroupEvent.HIDE_RED_DOT, this, armyGroupEventHandler, [ArmyGroupEvent.HIDE_RED_DOT]);
			Signal.intance.off(ArmyGroupEvent.GO_NPC_PLANT, this, armyGroupEventHandler, [ArmyGroupEvent.GO_NPC_PLANT]);
			
			Laya.timer.clear(this, civilWarTime);
		}
		
		override public function close(isOuter:Boolean = false):void
		{
			super.close();
			
			_movePath=[];
			_isMoving=false;
			target_city_id = null;
			XFacade.instance.closeModule(ArmyGroupChatView);
			
			big_map.removeChild(_bigMapOtherWrap);
			big_map.removeChild(_flogWrap);
			big_map.destroy();
			
			// 需把该资源清除才能重新用来平铺   （原因不详）
			Laya.loader.clearRes(MAP_BASE_BG, true);
			
			sendCurrentCityPosId(_currentCityId);
			
			LiaotianView.hide();
			
			if (!isOuter) {
				SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			}
		}
		
		/**通过外部关闭*/
		public function closeByOuter():void {
			close(true)
		}

		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			if (errStr == "L_A_933060" || errStr == "L_A_933057") return;
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}

		public function get view():ArmyGroupMainViewUI{
			_view = _view || new ArmyGroupMainViewUI();
			return _view;
		}
	}
}
