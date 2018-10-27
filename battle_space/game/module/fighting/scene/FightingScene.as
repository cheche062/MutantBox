package game.module.fighting.scene
{
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.BaseScene;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.data.formatData.AttackFormatData;
	import game.global.data.formatData.AttackFormatTagetData;
	import game.global.data.formatData.FightingFormatData;
	import game.global.data.formatData.SubReportFormatData;
	import game.global.event.GameEvent;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingSceneManager;
	import game.global.fighting.manager.FightingShowFormatData;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.global.vo.skillControlActionVos.vibrationSkillActionVo;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.cell.FightingTile;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.mgr.SkillManager;
	import game.module.fighting.view.FightingGridSprite;
	import game.module.fighting.view.FightingView;
	import game.module.fighting.view.PveFightingView;
	import game.module.fighting.view.PvpFightingView;
	import game.module.fighting.view.RoundAniCom;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class FightingScene extends BaseScene
	{
		public static const tileW:Number = Math.floor(204 * 1.6);  //网格宽度
		public static const tileH:Number = Math.floor(102 * 1.6); //网格高度
		public static const squareColumn:uint = 4; //方阵横向数量
		public static const squareRow:uint = 7;  //方阵纵向数量
		public static const beginY:int = 0 + (Math.floor(102 * 1.6) / 2);   //方阵排列Y起点
		
		public static var figtingModerGroup:String = "__figtingModerGroup__";
		public static var animationCacheKeys:Array = [];
		
		public function get ftData():*
		{
			return _ftData;
		}

		public function set ftData(value:*):void
		{
			_ftData = value;
		}

		public static function pushACacheKey(key:String):String{
			if(animationCacheKeys.indexOf(key) == -1)
			{
				animationCacheKeys.push(key);
			}
			return key;
		}
		
		public static var fightIsPlay:Boolean;
		
		
		///网格展示，用于调试，项目发布时要注销
		public var gridSp:FightingGridSprite;
		
		///瓦片层
		public var tileLayer:Sprite;
		
		///人物层
		public var unitLayer:Sprite;
		
		///技能层
		public var bSkillLayer:Sprite;  //底层
		///技能层
		public var tSkillLayer:Sprite;  //顶层
		
		protected var _ftData:*;
		protected var _sencenType:int = 0;   //0 选人 1 常规 2 战报
		public var fightingView:FightingView;
		
		protected var _loadedAllOver:Boolean;
		private var _mBgImgUrl:String;
		private var _tileMapData:Object = null;
		public var tileList:Object = {};
		public var completeHandler:Handler;
		private var _virtualFdata:Object;
		private var _squadData:Object;
		
		public var mySelectUnitIds:Array = [];
		public var selfSelectUnitIdx:Array = [];
		protected var _unitList:Array = [];
		private var _handler:Handler;
		private var _copyfData:SubReportFormatData;
		private var _leftReportkey:Number = 1;
		
		private var _useFightingUnit:BaseUnit;  
		private var skillPointKeys:Array = [];
		private var skillNotPointKeys:Array = [];
		private var movePointKeys:Array = [];
		private var _utype:int;
		private var _selectTile:FightingTile;
		private var _mouseStageX:Number = 0;
		private var _mouseStageY:Number = 0;
		private var _selectUnit:BaseUnit;
		private var _jiaohuanU:BaseUnit;
		private var _mapScale1:Number = 1;
		private var _mapScale2:Number = 1;
		private var _needFood:Number;
		//消耗类型
		private var _foodType:Number;
		private var _spotlightSp:Sprite ;
		private var _unitFood:String;
		private var sprMapPoint = new Point();
		
		/**波数*/
		public static var waveNum:*; 
		private var playVibration:Boolean;
		
		public function FightingScene(URL:String = "", isCanDrag:Boolean=true)
		{
			isResDispose = false;
			super(URL, isCanDrag);
		}

		public override function show(...args):void{
			super.show(args);
			ftData = args[0];
			trace("调用show时候传递的回调ftData.complete:"+ftData.complete);
			if(_loadedAllOver)
			{
				XFacade.instance.openModule(fightingViewMName);
			}
			
			stageSizeChange();
			
			detectLoade();
		}
		
		public function detectLoade():void
		{
			if(!fightingView)
			{
				timer.once(50,this,detectLoade);
				return ;
			}
			
			var bgId:Number = 1;
			if(ftData is FightingShowFormatData)
			{
				bgId = (ftData as FightingShowFormatData).bgType;
			}else
			{
				if(ftData && ftData.data && ftData.data.bgsrc)
					bgId = Number(ftData.data.bgsrc);
			}
			
			setBg(bgId);
		}
		
		//设置背景类型
		private function setBg(id:Number):void
		{
			var res_battle_json:Object = ResourceManager.instance.getResByURL("config/res_battle.json");
			if(!res_battle_json)
			{
				var jsonUrl:String = ResourceManager.instance.setResURL("config/res_battle.json");
				Laya.loader.load(jsonUrl,Handler.create(this,setBg,[id]) ,null,Loader.JSON );
				return ;
			}
			
			var sceneInfo:Object;
			for each(var c:Object in res_battle_json)
			{
				if(id == Number(c.id))
				{
					sceneInfo = c;
					break;
				}
			}
			if(sceneInfo)
			{
				mBgImgUrl = "appRes/scene/fightingScene/"+sceneInfo.back_pic;
				SoundMgr.instance.playMusicByURL(ResourceManager.instance.getSoundURL(sceneInfo.back_snd));
			}
		}
		
		/**
		 * 资源都加载完成 
		 */
		public function get tileMapData():Object
		{
			if(!_tileMapData)
			{
				_tileMapData = FightingSceneManager.intance.copyTileMapData();
			}
			return _tileMapData;
		}

		protected function initGrid():FightingGridSprite{
			return new FightingGridSprite();
		}
		
		
		override protected function loadMap():void{
			loadMapCallBack();
		}
		 
		public function set mBgImgUrl(value:String):void
		{
			_mBgImgUrl = value;
			m_sprMap.graphics.clear();
//			bgImgLoderOver();
			m_sprMap.loadImage(_mBgImgUrl+".jpg",0,0,0,0,Handler.create(this,bgImgLoderOver));
		}
		
		protected function bgImgLoderOver():void{
			//仅预加载出场音效
			var isFightingShowFormatData:Boolean = ftData is FightingShowFormatData ;
			if(!isFightingShowFormatData)  //非战斗战斗部分hao 
				
			{
				trace("isFightingShowFormatData调用loadOver");
				loaderOver();
				return;
			}
			
			var mList:Array = [];
			var armys:Array;
			
			if(ftData.data["1"] && ftData.data["1"]["army"])
			{
				armys = ftData.data["1"]["army"];
				hasSoundUrls(armys,1 , mList);
			}
			if(ftData.data["2"] && ftData.data["2"]["army"])
			{
				armys = ftData.data["2"]["army"];
				hasSoundUrls(armys,2 , mList);
			}
			hasSoundUrls2(FightingManager.intance.heroList, mList);
			hasSoundUrls2(FightingManager.intance.soldierList, mList);
			hasSoundUrls2(FightingManager.intance.itemList, mList);
			
			var mList2:Array = [];
			for (var i:int = 0; i < mList.length; i++) 
			{
				mList2.push({url:mList[i],type:Loader.SOUND});
			}
			
			if(!mList2.length)  //
			{
				loaderOver();
				return;
			}
			
			//trace(1,"预载出场音效",mList);
			Laya.loader.load(mList2,Handler.create(this,loaderOver),null,null,1,true,FightingScene.figtingModerGroup);
			
		}
		
		private function loaderOver():void
		{
			timer.once(100,this,begingFighting,null);
			super.hideBufferView();
		}
		
		//格式化阵上兵员
		protected function hasSoundUrls(armys:Array,direction:uint,mList:Array):void{
			var aList:Array = [
				BaseUnit.ACTION_SHOW,
			];
			var jsonStr:String;
			for (var i:int = 0; i < armys.length; i++) 
			{
				var unitId:String = armys[i]["unitId"];
				for (var j:int = 0; j < aList.length; j++) 
				{
					jsonStr = ResourceManager.getUnitMp3(unitId,aList[j]);
					if(jsonStr)
					{
						jsonStr = ResourceManager.getSoundUrl(jsonStr,"fighting/action");
						if(mList.indexOf(jsonStr) == -1)
							mList.push(jsonStr);
					}
				}
			}
		}
		
		
		//格式化未上阵兵员
		protected function hasSoundUrls2(armys:Array,mList:Array):void{
			if(!armys) return ;
			var aList:Array = [
				BaseUnit.ACTION_SHOW,
			];
			for (var i:int = 0; i < armys.length; i++) 
			{
				var armyD:ArmyData = armys[i];
				
				if(armyD.unitVo.isHero && (armyD.state || armyD.state2) )
					continue;
				if(!armyD.maxNum || !armyD.num)
					continue;
				var jsonStr:String;
				for (var j:int = 0; j < aList.length; j++) 
				{
					jsonStr = ResourceManager.getUnitMp3(armyD.unitId,aList[j]);
					if(jsonStr)
					{
						jsonStr = ResourceManager.getSoundUrl(jsonStr,"fighting/action");
						if(mList.indexOf(jsonStr) == -1)
						{
							mList.push(jsonStr);
//							trace("未上阵");
						}
						
					}
				}
			}
		}
		
		
		protected function loadMapCallBack():void{
			m_sprMap.width=2688;
			m_sprMap.height=1512;
			super.onMapLoaded();
			showGrid();
			m_sprMap.y = -10;
			if(GameSetting.isIPhoneX){
				m_sprMap.y = -70;
			}
			m_sprMap.x =  Laya.stage.width - m_sprMap.width * mapScaleX >> 1;
			
			sprMapPoint.x = this.m_sprMap.x;
			sprMapPoint.y = this.m_sprMap.y;
		}
		
		public function changeTileType(tile:FightingTile = null ,udata:fightUnitData = null , showSKill:Boolean = false):void
		{
			var tPi:String;
			for(var pstr:String in tileList)
			{
				var t:FightingTile = tileList[pstr];
				t.cellType = FightingTile.CELLTYPE1;
				if(t == tile)
				{
					tPi = pstr;
				}
			}
			
			if(tile && udata)
			{
				if(!showSKill)
					tile.cellType = tileMapData[tPi] == 0 && tile.direction == udata.direction? FightingTile.CELLTYPE5 : FightingTile.CELLTYPE6;
				
				if(tile.cellType == FightingTile.CELLTYPE5 || showSKill)
				{
					var skill:SkillVo = udata.selectSkill;
					if(skill){
						var keys:Array = skill.getSelectKeys(tile.key);
						var fK:String = getFightinPstr(keys,tile.key,skill);
						var skillShowKeys:Array = getTrageAllKeys(udata);
						var sFks:Array = [];
						var notSfks:Array = [];
						if(!skill.isSelfSkill)
							notSfks = getNotAtkKeys(keys,udata.unitVo.attack_type);
						if(fK)
						{
							sFks = skill.getDamageKeys(fK,tile.key);
						}
						changeTileCellType(skillShowKeys,keys,sFks,notSfks,fK);
					}
				}
			}
		}
		
		
		private function changeTileCellType(allKeys:Array , showKeys:Array , atkKeys:Array ,  notKey:Array = null , selKey:String = null ):void{
			for (var i:int = 0; i < allKeys.length; i++) 
			{
				var ttt:FightingTile = tileList[allKeys[i]];
				if(ttt)
				{
					if(ttt.key == selKey)
						ttt.cellType = FightingTile.CELLTYPE7;
					else if(notKey.indexOf(ttt.key) != -1 && atkKeys.indexOf(ttt.key) != -1)
						ttt.cellType = FightingTile.CELLTYPE10;
					else if(notKey.indexOf(ttt.key) != -1 && showKeys.indexOf(ttt.key) != -1)
						ttt.cellType = FightingTile.CELLTYPE3;
					else if(atkKeys.indexOf(ttt.key) != -1)
						ttt.cellType = FightingTile.CELLTYPE4;
					else if(showKeys.indexOf(ttt.key) != -1)
						ttt.cellType = FightingTile.CELLTYPE2;
					else
						ttt.cellType = FightingTile.CELLTYPE1;
				}
			}
		}
		
		
		private function getFightinPstr(keys:Array , pstr:String,skill:SkillVo):String{
			
			var toPstr:String = pstr;
			var n1:Number = Number(toPstr.charAt(toPstr.length - 3));
			var n2:Number = Number(toPstr.charAt(toPstr.length - 2));
			var n3:Number = Number(toPstr.charAt(toPstr.length - 1));
			var toN1:Number = (n1 == 1 && !skill.isSelfSkill) ? 2 : 1;
			var toN3:Number = n3;
			for (var i:int = 1; i < FightingScene.squareColumn; i++) 
			{
				var toN2:Number = i;
				var newK:String = "point_"+toN1+""+toN2+""+toN3;
				if(keys.indexOf(newK) != -1)
				{
					return newK;
				}
			}
			
			return null;
		}
		
		//场景加载完成，初始化UI;
		protected override function onLoaded():void{
			super.onLoaded();
			FightingSceneManager.intance.init();
			
			for (var key:String in tileMapData) 
			{
				if(tileMapData[key] == 0)
				{
					var tile:FightingTile = new FightingTile();
					tile.cellType = FightingTile.CELLTYPE1;
					var pi:Point = FightingSceneManager.intance.tilePointList[key];
					tile.x = pi.x + beginX;
					tile.y = pi.y + beginY;
					
					tileLayer.addChild(tile);
					
					tileList[key] = tile;
					tile.key = key;
					tile.direction = key.indexOf("point_1") != -1 ? 1 : 2;
				}
			
			}
			
			XFacade.instance.openModule(fightingViewMName);
		}
		
		protected function get fightingViewMName():String{
			 return ModuleName.FightingView_PVE;
		}
		
		public function onAdded(data:*):void
		{
			if(data is FightingView)
			{
				fightingView = data;
				fightingView.scence = this;
				_loadedAllOver = true;
				fightingView.bindNeedFood(_foodType,_needFood, _unitFood);
				fightingView.rightTopView1.showBoss(null);
				
				for(var pstr:String in tileList)
				{
					var t:FightingTile = tileList[pstr];
					t.scene = this;
				}
			}
		}
		
		
		private function begingFighting():void
		{
			fightingView.selectUnitView.unitTypeTab.labels = FightingManager.intance.getUnitTypeList();
			timer.clear(this,begingFighting);
			trace("开始战斗:11111111111111111111");
			trace("ftData:"+ftData);
			trace("ftData.complete:"+ftData.complete);
			
			if(ftData)
			{  
				completeHandler = ftData.complete;
				if(ftData.type == FightingShowFormatData.TYPE_REPORT)
				{ 
					//数据托管
					FightingManager.intance.hostingFighting(ftData.data,this);
					_sencenType = 2;
					fightingView.setType(FightingView.SHOWTYPE_2);
				}
				if(ftData.type == FightingShowFormatData.TYPE_SQUAD ||
					ftData.type == FightingShowFormatData.TYPE_PRESET ||
					ftData.type == FightingShowFormatData.TYPE_SIMULATION ||
					ftData.type == FightingShowFormatData.TYPE_PVP_BUZHEN ||
					ftData.type == FightingShowFormatData.TYPE_GUILD_FIGHT ||
					ftData.type == FightingShowFormatData.TYPE_RADAR ||
					ftData.type == FightingShowFormatData.TYPE_FORTRESS ||
					ftData.type == FightingShowFormatData.RANDOM_CONDITION ||
					ftData.type == FightingShowFormatData.PEOPLE_FALL_OFF ||
					ftData.type == FightingShowFormatData.CLIMB_TOWER
				){
					var obj:Object = ftData.data;
					var fT:String = ftData.type;
					ftData = {};
					ftData.armySet = obj;
					
					fightingView.bindNeedFood(_foodType,_needFood, _unitFood);
					
					if(obj.hasOwnProperty("1"))
						FightingManager.intance.addArmy(obj[1].army,true);
					if(obj.hasOwnProperty("2")){
						var kpi:int = FightingManager.intance.addArmy(obj[2].army,false);
						fightingView.bindOtherKpi(kpi);
					}else{
						fightingView.bindOtherKpi(0);
					}
					
					this.selfSelectUnitIdx = this.mySelectUnitIds.concat();
					fightingView.rightBottomView.btnContainer.visible = true;
					var sTp:Number =  FightingView.SHOWTYPE_3;
					if(fT == FightingShowFormatData.TYPE_PRESET)
						sTp = FightingView.SHOWTYPE_5;
					else if(fT == FightingShowFormatData.TYPE_SIMULATION)
					{
						sTp = FightingView.SHOWTYPE_6; 
						fightingView.rightBottomView.btnContainer.visible = false;
					}
					else if(fT == FightingShowFormatData.TYPE_PVP_BUZHEN)
					{
						sTp = FightingView.SHOWTYPE_7;
					}else if(fT == FightingShowFormatData.TYPE_GUILD_FIGHT){
						sTp = FightingView.SHOWTYPE_8;
					}else if(fT == FightingShowFormatData.TYPE_RADAR){
						sTp = FightingView.SHOWTYPE_9;
					}else if(fT==FightingShowFormatData.TYPE_FORTRESS){
						sTp = FightingView.SHOWTYPE_10;
					}else if(fT==FightingShowFormatData.RANDOM_CONDITION){
						sTp = FightingView.SHOWTYPE_11;
					}else if(fT==FightingShowFormatData.PEOPLE_FALL_OFF)
					{
						sTp = FightingView.SHOWTYPE_12;
					}else if(fT==FightingShowFormatData.CLIMB_TOWER)
						sTp = FightingView.SHOWTYPE_13;

					fightingView.setType(sTp);
					fightingView.bindSelectUnitViewData();
					
					if(fT == FightingShowFormatData.TYPE_SIMULATION)
					{
						FightingManager.intance.sendStart();
					}
				}
			}
		}
		
		
		public function get virtualFdata():Object{
			if(!_virtualFdata)
			{
				_virtualFdata = {};
			}
			return _virtualFdata;
		}
		
		
		public function get isChange():Boolean{
			var ids1:Array = mySelectUnitIds ? mySelectUnitIds.concat() : [];
			var ids2:Array = selfSelectUnitIdx ? selfSelectUnitIdx.concat() : [];
			
			for (var i:int = ids1.length - 1; i >= 0 ; i--) 
			{
				var iii:String = ids1[i];
				var i2:Number = ids2.indexOf(iii);
				if(i2 != -1)
				{
					ids2.splice(i2,1);
					ids1.splice(i,1);
				}
			}
			return ids2.length || ids1.length;
		}
		
		//回放
		public function playback(d:Object):void
		{
			var k:*;
			while(_unitList.length){
				var uitem:BaseUnit = _unitList.shift();
				_tileMapData[uitem.showPointID] = 0;
				if(uitem.parent)
					uitem.parent.removeChild(uitem);
				uitem.scene = null;
				uitem.destroy();
			}
			for(var k:* in tileList) 
			{
				var tile:FightingTile = tileList[k];
				tile.cellType = FightingTile.CELLTYPE1;
				tile.leftCellType = 0;
				tileMapData[tile.key] =  0;
				tile.deleteAllBuff();
			}
			
			
			fightingView.setType(FightingView.SHOWTYPE_2);
			FightingManager.intance.hostingFighting(d,this);
		}
		
		
		public function get tileColumn():int{
			return ( FightingScene.squareColumn * 2 + 1 + FightingScene.squareRow ) / 2;
		}
		
		public function get tileRow():int{
			return FightingScene.squareColumn * 2 + FightingScene.squareRow;
		}
		
		public function get beginX():int{
			return (m_sprMap.width - tileColumn * FightingScene.tileW) / 2;
		}
		
		public function get beginY():int{
			return FightingScene.beginY;
		}
		
		protected function showGrid():void
		{
			gridSp.width = m_sprMap.width;
			gridSp.height = m_sprMap.height;
			
			FightingSceneManager.intance.mapWidth = tileColumn;
			FightingSceneManager.intance.mapHeight = tileRow;
			FightingSceneManager.intance.tilePixelWidth = FightingScene.tileW;
			FightingSceneManager.intance.tilePixelHeight = FightingScene.tileH;
		}
		 
		
		override public function initScence():void
		{
			Signal.intance.on(GameEvent.EVENT_MODULE_ADDED,this,onAdded);
			super.initScence();
			this._loadSceneResCom=false;
			this.m_SceneResource="FightingScene";
			gridSp = initGrid();
			this.m_sprMap.addChild(gridSp);
			gridSp.cacheAsBitmap = true;
			gridSp.visible = true;
			
			
			tileLayer = new Sprite();
			tileLayer.mouseEnabled = tileLayer.mouseThrough = true;
			this.m_sprMap.addChild(tileLayer);
			
			bSkillLayer = new Sprite();
			bSkillLayer.mouseEnabled = bSkillLayer.mouseThrough = true;
			this.m_sprMap.addChild(bSkillLayer);
			
			
			unitLayer = new Sprite();
			unitLayer.mouseEnabled = unitLayer.mouseThrough = true;
			this.m_sprMap.addChild(unitLayer);
			
			tSkillLayer = new Sprite();
			tSkillLayer.mouseEnabled = tSkillLayer.mouseThrough = true;
			this.m_sprMap.addChild(tSkillLayer);
		}
		
		
		public override function get isDrag():Boolean{
			return false;
		}
		
		protected override function initMapPosition():void{
			
		}
		
		
		
		public function addUnit(uData:fightUnitData , isUser:Boolean=true , pstr:String = null , isShowAction:Boolean = false):BaseUnit
		{
			if(!pstr)
				pstr  = FightingSceneManager.intance.getNewUnitPoint(uData,this.tileMapData);
			var uitem:BaseUnit;
			if(pstr)
			{
				uitem = new BaseUnit();
				uitem.data = uData;
				unitLayer.addChild(uitem);
				uitem.showPointID = pstr;
				uitem.x = beginX + FightingSceneManager.intance.tilePointList[pstr].x;
				uitem.y = beginY + FightingSceneManager.intance.tilePointList[pstr].y;
				
				
				this.tileMapData[pstr] = 1;
				_unitList.push(uitem);
				
				if(isUser)
				{
					mySelectUnitIds.push(uData.unitId + "*"+uData.wyid);
					uitem.scene = this;			
				}
				if(isShowAction)
				{
					/*var f:Function = function(uit:BaseUnit):void{
						uit.playAction(BaseUnit.ACTION_HOLDING);
					};
					uitem.playAction(BaseUnit.ACTION_SHOW,Handler.create(this,f,[uitem]));*/
					uitem.playAction(BaseUnit.ACTION_SHOW,Handler.create(uitem,uitem.playAction,[BaseUnit.ACTION_HOLDING]));
				}
				else
				{
					uitem.playAction(BaseUnit.ACTION_HOLDING);
				}
				uitem.enabled = isUser;
				
			}else
			{
				trace("没有可以建造的位置");
				return null;
			}
			SortingFun();
			return uitem;
		}
		
		public function getUnitByPoint(pintObj:* , passDie:Boolean = false):BaseUnit{
			var pintStr:String = "";
			var uid:Number = 0;
			
			if(pintObj is Object)
			{
				for (var i:int = 0; i < _unitList.length; i++) 
				{
					var uitem:BaseUnit = _unitList[i];
					if(uitem.data.wyid == pintObj.key)
						return uitem;
				}
				return null;
			}
			
			if(pintObj is Array)
			{
				pintStr = pintObj[0];
				uid = Number(pintObj[1]);
			}
			else
			{
				pintStr = pintObj;
			}
			
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var uitem:BaseUnit = _unitList[i];
				if(uitem.showPointID == pintStr && (!uid || uid == uitem.data.unitId)  && (!uitem.dieTag || !passDie))
					return uitem;
			}
			return null;
		}
		
		
		public function removerUnit(u:BaseUnit):void{
			this.unitLayer.removeChild(u);
			var idx:int;
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var uitem:BaseUnit = _unitList[i];
				if(uitem == u){
					_unitList.splice(i,1);
					uitem.removeSelf();
					break;
				}
			}
			var u2:BaseUnit = this.getUnitByPoint(uitem.showPointID);
			if(!u2)
				tileMapData[uitem.showPointID] = 0;
			u.destroy();
		}
		
		
		public function removerAllUnit():void
		{
			while(_unitList.length){
				var uitem:BaseUnit = _unitList.shift();
				if(uitem.parent)
					uitem.parent.removeChild(uitem);
				uitem.scene = null;
				uitem.destroy();
			}
		}
		
		
		
		public function fightingFun(fData:SubReportFormatData , trneKey:String , caller:*, method:Function, args:Array ):void
		{
			var reportkey:Number =  Number(fData.reportkey);
			if(!reportkey) reportkey = 1;
			if(_leftReportkey != reportkey)  //大回合不一致
			{
				
				_leftReportkey = reportkey;
				var myUid:String = String(GlobalRoleDataManger.instance.userid);
				if(myUid != fData.disposeUid && fightingView && fightingView.showType != FightingView.SHOWTYPE_2) //
				{
					trace("回合停顿",reportkey);
					Laya.timer.once(
						Math.ceil(1000/FightingManager.velocity)
						,this,fightingFun,[fData,trneKey,caller,method,args]);
					return ;
				}
			}
			
			fightingView.turn = reportkey == 0 ? 1 : fData.reportkey;
			_handler = Handler.create(caller,method,args);
//			_copyfData = JSON.parse(JSON.stringify(fData));
			_copyfData = fData.copy();
//			for(var key:* in fData)
//			{
//				_copyfData[key] = fData[key];
//			}
			fightingPlay(trneKey);
		}
		
		public function autoFighting():void{
			if(useFightingUnit)
			{
				FightingManager.intance.autoFighting();
//				Laya.stage.off(Event.CLICK,this,attackDown);
				off(Event.CLICK,this,attackDown);
				useFightingUnit = null;
				skillPointKeys = [];
				skillNotPointKeys = [];
				movePointKeys = [];
				changeTileType();
			}
		}
		
		
		/**停止自动战斗*/
		public function stopAutoFight():void{
			fightingView.auboBtnSelect = false;
		}
		
		
		public function set useFightingUnit(v:BaseUnit):void{
			_useFightingUnit = v;
			trace("出手单位",_useFightingUnit);
			fightingView.rightBottomView.visible = useFightingUnit != null && fightingView.showType != FightingView.SHOWTYPE_6;
			if(useFightingUnit)
			{
//				fightingView.rightBottomView.mouseEnabled = true;
				fightingView.refreshAtk();
				fightingView.selectRightBottomBtn(0);
				fightingView.countdown(getCountDown(),Handler.create(this,function():void{
					this.autoFighting();
					fightingView.rightTopView1.auboBtn.selected = true;
				}));
			}
		}
		
		private function getCountDown():Number
		{
			if(!User.getInstance().hasFinishGuide) //新手引导没有过
			{
				return Number.MAX_VALUE;
			}
			if(!FightingView.showAutoBtn)
			{
				return Number.MAX_VALUE;
			}
//			if(true)
//				return Number.MAX_VALUE;
			return 20;
		}
		
		
		public function get useFightingUnit():BaseUnit{
			return _useFightingUnit;
		}
		
		public function useUnit(pistr:String):void
		{
			for (var i:int = 0; i < _unitList.length; i++) 
			{
//				if((_unitList[i] as BaseUnit).showPointID == pistr
//				 && (_unitList[i] as BaseUnit).data.unitId == unitId	
//				)
				if((_unitList[i] as BaseUnit).showPointID == pistr)
				{
					useFightingUnit = _unitList[i];
					break;
				}
			}
			
			if(!useFightingUnit)
			{
				//alert("没有可控对象"+pistr);
				return;
			}
			if(!User.getInstance().hasFinishGuide && 
				(useFightingUnit.data.unitId == 1001 || useFightingUnit.data.unitId == 1000))
			{
				if(useFightingUnit.data.unitId == 1001)
					Signal.intance.event(NewerGuildeEvent.SHIELD_SOILDER_ACT);
				if(useFightingUnit.data.unitId == 1000)
					Signal.intance.event(NewerGuildeEvent.START_MOVE_GUIDE);
			}
			
			if (!User.getInstance().hasFinishGuide && useFightingUnit.data.unitVo.isHero)
			{
				Signal.intance.event(NewerGuildeEvent.HERO_FIGHT);
			}
			
		}
		
		public function selectUnit(upos:String):void{
			var un:BaseUnit;
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var un2:BaseUnit = _unitList[i];
				if(un2.showPointID == upos){
					un = un2;
					break;
				}
			}
			if(un == null || un.select)
			{
				trace(un == null ? "un is null":"nu is select");
				return ;
			}
			
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.SELECT_ACT_BAR);
			}
			un.select = true;
			trace("选中",un.data.unitId);
			var f:Function = function(u:BaseUnit):void{
				if(u && u.displayedInStage)
				{
					u.select = false;
				}
			};
			this.timer.once(2000,this,f,[un]);
		}
		
		
		private function getNotAtkKeys(keys:Array , attacktype:Number):Array{
			var rtAr:Array = [];
			var keyLisDic:Object = {};
			var ar:Array;
			var k:String;
			for (var i:int = 0; i < keys.length; i++) 
			{
				k = keys[i];
				var n1:Number = Number(k.charAt(k.length - 3));
				var n2:Number = Number(k.charAt(k.length - 2));
				var n3:Number = Number(k.charAt(k.length - 1));
				
				if(!keyLisDic[n3])
					keyLisDic[n3] = ar = [];
				else
					ar = keyLisDic[n3];
				ar.push([n1,n2,n3]);
				ar.sort(sortFun2)
			}
			
			for each (ar in keyLisDic) 
			{
				var b :Boolean = false;
				for (var j:int = 0; j < ar.length; j++) 
				{
					var ar2:Array = ar[j];
					k = "point_" + ar2[0] + ""+ ar2[1] + "" + ar2[2];
					if(b)
					{
						rtAr.push(k);
					}else
					{
						var uit:BaseUnit = getUnitByPoint(k);
						if(uit && uit.data.unitVo.defense_type == 1 && attacktype != 2)  //重甲
							b = true;
					}
				}
			}
			return rtAr;
		}
		
		
		public function sortFun2(v1:Array,v2:Array):int{
			if(v1[1] > v2[1])
				return 1;
			if(v2[1] > v1[1])
				return -1;
			return 0;
			
		}
		
		
		public function useType(uType:int):void{
			fightingView.rightBottomView.bgRange.visible = false;
			changeTileType();
			(tileList[useFightingUnit.showPointID] as FightingTile).cellType = FightingTile.CELLTYPE9;
			if(!useFightingUnit)
			{
//				alert("没有可控对象");
				return;
			}
			var tile:FightingTile  = tileList[useFightingUnit.showPointID];
			_utype = uType;
			if(uType == 3)
			{
				var skill:SkillVo = useFightingUnit.data.selectSkill;
				
				if(skill){
					skillPointKeys = skill.getSelectKeys(tile.key);
					if(!skillPointKeys.length)
					{
//						trace(1,"可选目标",skillPointKeys.join(","));
						//XTip.showTip("L_A_4404");
						fightingView.rightBottomView.bgRange.visible = true;
					}
					var skillShowKeys:Array = getTrageAllKeys(useFightingUnit.data);
					var fK:String = getFightinPstr(skillPointKeys,tile.key,skill);
					var sFks:Array = [];
					skillNotPointKeys = [];
					if(!skill.isSelfSkill)
						skillNotPointKeys = getNotAtkKeys(skillPointKeys,useFightingUnit.data.unitVo.attack_type);
					if(fK)
					{
						sFks = skill.getDamageKeys(fK,useFightingUnit.showPointID);
					}
					changeTileCellType(skillShowKeys , skillPointKeys,sFks,skillNotPointKeys,fK);
					for (var i:int = 0; i < skillShowKeys.length; i++) 
					{
						var ttt:FightingTile = tileList[skillShowKeys[i]];
						if(ttt && ttt.key == fK)
						{
							_selectTile = ttt;
							break;
						}
					}
				}
//				Laya.stage.on(Event.CLICK,this,attackDown);
				on(Event.CLICK,this,attackDown);
			}else if(uType == 1)
			{
				var f:Function = function():void
				{
					useFightingUnit = null;
				}
				FightingManager.intance.sendAttack([
					FightingManager.intance.fightingServerID,
					3,
					useFightingUnit.showPointID,
					"",
					""
				] , Handler.create(this,f));
//				useFightingUnit = null;
			}else if(uType == 2)
			{
				movePointKeys = useFightingUnit.data.unitVo.getMoveKeys(tile.key);
				for (var i:int = 0; i < movePointKeys.length; i++) 
				{
					var ttt:FightingTile = tileList[movePointKeys[i]];
					if(ttt)
					{
						ttt.cellType = tileMapData[ttt.key] == 0 ? FightingTile.CELLTYPE5 : FightingTile.CELLTYPE6;
					}
				}
//				Laya.stage.on(Event.CLICK,this,attackDown);
				on(Event.CLICK,this,attackDown);
			}
		}
		
		
		public function getTrageAllKeys(udata:fightUnitData):Array
		{
			var rtAr:Array = [];
			var isSelfSkill:Boolean = udata.selectSkill.isSelfSkill;
			for each (var tile:FightingTile in tileList) 
			{
				var isSelfTile:Boolean = tile.direction == udata.direction;
				if((isSelfSkill && isSelfTile) || (!isSelfSkill && !isSelfTile) )
					rtAr.push(tile.key);
			}
			return rtAr;
			
		}
		
		
		public function get mapScaleX():Number{
			return this.m_sprMap.scaleX;
		}
		
		public function get mapScaleY():Number{
			return this.m_sprMap.scaleY;
		}
		
//		public function stopAllUnitAction():void{
//			for each (var u:BaseUnit in this._unitList) 
//			{
//				u.stopAction();
//			}
//			
//		}
		
		
		private function attackDown(e:Event):void{
			
			var pii:Point = new Point(e.stageX,e.stageY);
			pii = unitLayer.globalToLocal(pii);
			pii.x -= FightingScene.tileW /2;
			pii.y -= FightingScene.tileH /2;
			
			var tile2:FightingTile = getTileByPoint(pii.x,pii.y);
			
//			var deleteData:Boolean;
			var deleteFun:Function = function():void{
//				Laya.stage.off(Event.CLICK,this,attackDown);
				off(Event.CLICK,this,attackDown);
				useFightingUnit = null;
				skillPointKeys = [];
				skillNotPointKeys = [];
				movePointKeys = [];
				changeTileType();
			}
			
			if(tile2 && _utype == 2 && movePointKeys.indexOf(tile2.key) != -1  && tileMapData[tile2.key] == 0)
			{
				FightingManager.intance.sendAttack([
					FightingManager.intance.fightingServerID,
					1,
					useFightingUnit.showPointID,
					tile2.key,
					""
				],Handler.create(this,deleteFun));
//				Laya.stage.off(Event.CLICK,this,attackDown);
//				deleteData = true;
			}
			if(tile2 && _utype == 3 && skillPointKeys.indexOf(tile2.key) != -1 && skillNotPointKeys.indexOf(tile2.key) == -1)
			{
//				alert("有效进攻");
				var fK:String =  tile2.key;
				var sFks:Array = [];
				sFks = useFightingUnit.data.selectSkill.getDamageKeys(fK,useFightingUnit.showPointID);
				if(_selectTile != tile2)
				{
					_selectTile = tile2;
					
					var skillShowKeys:Array = getTrageAllKeys(useFightingUnit.data);
					
					changeTileCellType(skillShowKeys , skillPointKeys,sFks,skillNotPointKeys,fK);
//					alert("重选目标");
					return ;
				}else{
					var noTarget:Boolean = true;
					for (var j:int = 0; j < sFks.length; j++) 
					{
						var uitem:BaseUnit = getUnitByPoint(sFks[j]);
//						if(_tileMapData[sFks[j]] == 1)
						if(uitem && uitem.data.unitVo.isAttack)
						{
							noTarget = false;
							break;
						}
					}
					if(noTarget)
					{
//						alert("打这里没目标");
						XTip.showTip("L_A_64");
						return ;
					}
					FightingManager.intance.sendAttack([
						FightingManager.intance.fightingServerID,
						2,
						useFightingUnit.showPointID,
						tile2.key,
						useFightingUnit.data.selectSkill.skill_id
					],Handler.create(this,deleteFun));
//					deleteData = true;
				}
//				deleteData = true;
			}
//			if(deleteData)
//			{
////				alert("操控结束清理对象");
//				Laya.stage.off(Event.CLICK,this,attackDown);
//				useFightingUnit = null;
//				skillPointKeys = [];
//				skillNotPointKeys = [];
//				movePointKeys = [];
//				changeTileType();
//			}
			
		}
		
		
		private function playAFTData(dataAr:Array):Array{
			var arr:Array = [];
			for (var k:int = 0; k < dataAr.length; k++) 
			{
				arr.push( new AttackFormatTagetData(dataAr[k]));
			}
			return arr;
		}
		
	
		private function fightingPlay(trneKey:String):void
		{
			for(var pstr:String in tileList)
			{
				var t:FightingTile = tileList[pstr];
				t.cellType = FightingTile.CELLTYPE1;
			}
			
			if(!_copyfData)return ;
			var _fightHandler:Handler = Handler.create(this,fightingPlay,[trneKey]);
			
			var allForwardObj:Object;
			var playData:Object;
			fightIsPlay = true;
			//出场全体移动
			if(_copyfData.beforeStart)
			{
				playMover(_copyfData.beforeStart,_fightHandler);
				_copyfData.beforeStart = null;
				return ;
			}
			//战斗开始数据 
			if(_copyfData.start)
			{
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.start),_fightHandler);
				_copyfData.start = null;
				return ;
			}
			//出手前全体移动
			if(_copyfData.before)
			{
				playMover(_copyfData.before,_fightHandler);
				_copyfData.before = null;
				return ;
			}
			
			//出手前数据
			if(_copyfData.csq)
			{
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.csq),_fightHandler);
				_copyfData.csq = null;
				return ;
			}
			
			//出手数据  
			if(_copyfData.fighter){
				var disposeType:uint= _copyfData.fighter["disposeType"];
				var bu:BaseUnit = this.getUnitByPoint(_copyfData.fighter["originPos"]);
				if(bu)bu.defense = false;
				
				if(disposeType == 0){
					_copyfData.fighter = null;
					//					_copyfData.attacks = null;
					_fightHandler.run();
				}else if(disposeType == 1){
					var originPos:String = _copyfData.fighter["originPos"];
					var pos:String = _copyfData.fighter["pos"];
					//					var bu:BaseUnit = getUnitByPoint(originPos);
					unitMover(bu,getPoints(originPos,pos),_fightHandler);
				}else if(disposeType == 2){
					var fdata:AttackFormatData = new AttackFormatData(_copyfData.fighter);
					SkillManager.intance.useSkill(this,fdata,_fightHandler);
				}else{
					_copyfData.fighter = null;
					//					_copyfData.attacks = null;
					if(bu)bu.defense = true;
					_fightHandler.run();
					return ;
				}
				
				_copyfData.fighter = null;
				//				_copyfData.attacks = null;
				return ;
			}
			
			//出手后数据 
			if(_copyfData.csh)
			{
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.csh),_fightHandler);
				_copyfData.csh = null;
				return ;
			}
			
			//回合结束数据 
			if(_copyfData.hhjs)
			{
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.hhjs),_fightHandler);
				_copyfData.hhjs = null;
				return ;
			}
			
			//位置造成伤害数据 
			if(_copyfData.posHurt){
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.posHurt),_fightHandler);
				_copyfData.posHurt = null;
				return ;
			}
			
			//位置事件
			if(_copyfData.posEvent){
				for(var pk:String in _copyfData.posEvent)
				{
					var tile:FightingTile = this.tileList[pk];
					if(tile)
						tile.bindBuff(_copyfData.posEvent[pk]);
				}
				_copyfData.posEvent = null;
				_fightHandler.run();
				return ;
			}
			
			//出手后全体移动
			if(_copyfData.after)
			{
				playMover(_copyfData.after,_fightHandler);
				_copyfData.after = null;
				return ;
			}
			
			//更新显示回合数
			if(_copyfData.nextRound){
				fightingView.turn = _copyfData.nextRound;
				_copyfData.nextRound = 0;
				_fightHandler.run();
				return ;
			}
			
			if(_copyfData.replenish)
			{
				//插播一个动画================================
				RoundAniCom.showRound(waveNum, this, onNewRound);
				return;
				function onNewRound():void{
					SkillManager.intance.useBeidong(this,playAFTData(_copyfData.replenish),_fightHandler);
					_copyfData.replenish = null;
				}
			}
			
			//下回合开始数据
			if(_copyfData.hhks)
			{
				SkillManager.intance.useBeidong(this,playAFTData(_copyfData.hhks),_fightHandler);
				_copyfData.hhks = null;
				return ;
			}
			
			//下回合开始后全体移动
			if(_copyfData.afterHHKS)
			{
				playMover(_copyfData.afterHHKS,_fightHandler);
				_copyfData.afterHHKS = null;
				return ;
			}
			
			if(_copyfData.startBuffUpdate){
				for(var pk:String in _copyfData.startBuffUpdate)
				{
					var bu:BaseUnit = this.getUnitByPoint(pk);
					if(bu)
						bu.buffIds = _copyfData.startBuffUpdate[pk];
				}
				_copyfData.startBuffUpdate = null;
				_fightHandler.run();
				return ;
			}
			
			
			if(_copyfData.addUnit && _copyfData.addUnit.length)
			{
				for (var j:int = 0; j < _copyfData.addUnit.length; j++) 
				{
					var d:Object  = _copyfData.addUnit[j];
					var ud:fightUnitData = new fightUnitData();
					ud.unitId = Number(d.id);
					ud.hp = Number(d.restHp);
					ud.maxHp = Number(d.hp);
					ud.wyid = Math.random();
					if(d.skillId && d.skillId.length)
						ud.skillVos = FightingManager.intance.getSkillVos(d.skillId);
					ud.direction = d.pos.indexOf("point_1") == 0 ? 1: 2;	
					addUnit(ud,false,d.pos,true);
				}
				_copyfData.addUnit = null;
				_fightHandler.run();
				return ;
			}
			
			if(_copyfData.unitList)
			{
				fightingView.rankData(_copyfData.unitList,true,_fightHandler);
				_copyfData.unitList = null;
				return ;
			}
			
			if(_copyfData.buffUpdate){
				for(var pk:String in _copyfData.buffUpdate)
				{
					var bu:BaseUnit = this.getUnitByPoint(pk);
					if(bu)
						bu.buffIds = _copyfData.buffUpdate[pk];
				}
				_copyfData.buffUpdate = null;
				_fightHandler.run();
				return ;
			}
			fightIsPlay = false;
			FightingManager.velocity = 0;
			if(_handler){
				var copyHander:Handler =  _handler;
				_handler = null;
				copyHander.run();
				copyHander.clear();
				copyHander = null;
			}
			
		}
		
		private function playMover(mdata:Object,fightHandler:Handler):void{
			var ar:Array = [];
			var i:int;
			for(var key:String in mdata) 
			{
				var val:String = mdata[key];
				var bu:BaseUnit = getUnitByPoint(key);
				if(!bu)
				{
					var a="这里在测试";
				}
				var moveAr:Array = getPoints(key,val);
				ar.push(
					{
						bu:bu,
						moveAr:moveAr,
						moveArLen:moveAr.length
					}
				);
			}
			
			ar.sort(function(o1:Object,o2:Object):int{
				if(o1.moveArLen > o2.moveArLen)
					return 1;
				if(o1.moveArLen < o2.moveArLen)
					return -1;
				return 0;
			});
			
			
			for (var j:int = 0; j < ar.length; j++) 
			{
				bu = ar[j]["bu"];
				moveAr = ar[j]["moveAr"];
				if(j == ar.length - 1)
					unitMover(bu,moveAr,fightHandler);
				else
					unitMover(bu,moveAr);
			}
			
		}
		
		/**
		 *isCross 是否优先横向移动
		 */
		private function getPoints(goP:String,toP:String,isCross:Boolean = false):Array{
//			goP = "point_111";
//			toP = "point_114";
			
			var pInts1:Array = goP.replace("point_","").split("");
			var pInts2:Array = toP.replace("point_","").split("");
			var toAr:Array = [];
//			var pintAr:Array = [];
			
			var pL1:Array;
			var pL2:Array;
			if(isCross)
			{
				pL1 = getHengPoints(pInts1,pInts2,pInts1[1]);	
				pL2 = getZongPoints(pInts1,pInts2,pInts2[2]);	
			}else
			{
				pL1 = getZongPoints(pInts1,pInts2,pInts1[2]);	
				pL2 = getHengPoints(pInts1,pInts2,pInts2[1]);
				if(!pL1 || !pL2)
					return getPoints(goP,toP,true);
			}
			
			toAr = toAr.concat(pL1);
			toAr = toAr.concat(pL2);
			
			
			return toAr;
		}
		
		private function getHengPoints(pInts1:Array , pInts2:Array , n3:Number):Array{
			var ktok:Object = Number(pInts1[0]) == 1 ?  FightingSceneManager.rowLeftPointKey : FightingSceneManager.rowRightPointKey;
			var bNum:Number;
			var eNum:Number;
			var addNum:Number;
			var toAr:Array = [];
			for(var k:* in ktok)
			{
				if(Number(ktok[k]) == Number(pInts1[2]))
				{
					bNum = Number(k);
				}
				if(Number(ktok[k]) == Number(pInts2[2]))
				{
					eNum = Number(k);
				}
			}
			addNum = eNum > bNum ? 1 : -1;
			while(bNum != eNum){
				bNum += addNum;
				
				var pointKey:String = "point_"+pInts1[0]+""+n3+""+ktok[bNum];
				
				if(tileList.hasOwnProperty(pointKey))
					toAr.push(pointKey);
				else
					return null;
			}
			return toAr;
		}
		
		private function getZongPoints(pInts1:Array , pInts2:Array , n3:Number):Array{
			var bNum:Number = Number(pInts1[1]);
			var eNum:Number = Number(pInts2[1]) ;
			var addNum:Number = eNum > bNum ? 1 : -1;
			var adPoint:String;
			var toAr:Array = [];
			while(bNum != eNum){
				bNum += addNum;
				var pointKey:String = "point_"+pInts1[0]+""+bNum+""+n3;
				if(tileList.hasOwnProperty(pointKey))
					toAr.push(pointKey);
				else
					return null;
			}
			return toAr;
		}
		
		
		private function unitMoverOver(fightHandler:Handler):void
		{
			var key:*;
			for(key in _tileMapData){
				if(_tileMapData[key] != 2)
					_tileMapData[key] = 0;		
			}
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				_tileMapData[_unitList[i].showPointID] = 1;
			}
			fightHandler.run();
		}
		
		
		private function unitMover(unit:BaseUnit,movers:Array,fightHandler:Handler = null , newPstr:String = null):void
		{
			if(newPstr != null)
			{
				unit.showPointID = newPstr;
				SortingFun();
			}
			
			if(!movers.length)
			{
				if(fightHandler)
				{
					timer.once(50,this,unitMoverOver,[fightHandler]);
					
					if(!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.MOVE_OVER);
					}
					
				}
//					fightHandler.run();
				unit.playAction(BaseUnit.ACTION_HOLDING);
				return ;
			}
//			
			var jsonStr:String = unit.data.unitVo.getModel(unit.data.direction,BaseUnit.ACTION_MOVE, unit.data.skin);
			var jsonData:Object = Loader.getRes(jsonStr);
			if(!jsonData)
			{
				var loderAr:Array = [{url:jsonStr,type:Loader.ATLAS}];
				var mp3Url:String = ResourceManager.getUnitMp3(unit.data.unitId,BaseUnit.ACTION_MOVE);
				mp3Url = ResourceManager.getSoundUrl(mp3Url,"fighting/action");
				loderAr.push({url:mp3Url,type:Loader.SOUND});
				
				trace(1,"移动预加载",loderAr);
				
				Laya.loader.load(loderAr,Handler.create(this,moveLoaderOver,[jsonStr,unit,movers,fightHandler,newPstr]),null,null,1,true,FightingScene.figtingModerGroup);
				return ;
			}
			unit.playAction(BaseUnit.ACTION_MOVE);
			var piStr:String = movers.shift();
			var pi:Point = FightingSceneManager.intance.tilePointList[piStr];
			Tween.to(unit,{x:beginX+pi.x, y:beginY+pi.y},
				Math.ceil(500/FightingManager.velocity)
				,null,Handler.create(this,unitMover,[unit,movers,fightHandler,piStr]));
		}
		
		
		private function moveLoaderOver(... args):void
		{
			var jsonStr:String = args[0];
			var jsonData:Object = Loader.getRes(jsonStr);
			
			var unit:BaseUnit = args[1];
			var movers:Array = args[2];
			var fightHandler:Handler = args[3];
			var newPstr:String = args[4];
			
			if(!jsonData)
			{
				XTip.showTip("not file:"+jsonStr);
				var piStr:String = movers.pop();
				var pi:Point = FightingSceneManager.intance.tilePointList[piStr];
				unit.pos(beginX+pi.x,beginY+pi.y);
				movers = [];
			}
			unitMover(unit,movers,fightHandler,newPstr);
		}
		
		
		public function selectUnitFun(unit:BaseUnit,e:Event):void{
			var pii:Point = new Point();
			pii = unitLayer.localToGlobal(pii);
			unit.y -= 30;
			unit.playAction(BaseUnit.ACTION_HOLDING);
			_mouseStageX = e.stageX - pii.x - unit.x * this.m_sprMap.scaleX;
			_mouseStageY = e.stageY - pii.y - unit.y * this.m_sprMap.scaleY;
			_selectUnit = unit;
			tileMapData[unit.showPointID] = 0;
//			Laya.stage.on(Event.MOUSE_MOVE,this,stageMove);
//			Laya.stage.on(Event.MOUSE_UP,this,stageUp);
			fightingView.mouseEnabled = false;
			on(Event.MOUSE_MOVE,this,stageMove);
			on(Event.MOUSE_UP,this,stageUp);
			on(Event.MOUSE_OUT,this,stageUp);
//			stageMove(e);
		}
		
		//移除选中英雄
		private function deleteUnit():void{
			
			if(!_selectUnit)
				return ;
			//成功后处理
			var wF:Function = function():void{
				tileMapData[_selectUnit.showPointID] = 0;
				if(_selectUnit.parent)
					_selectUnit.parent.removeChild(_selectUnit);
				var idx:int = mySelectUnitIds.indexOf(_selectUnit.data.unitId +"*" + _selectUnit.data.wyid);
				if(idx != -1)
					mySelectUnitIds.splice(idx,1);
				idx = _unitList.indexOf(_selectUnit);
				if(idx != -1)
					_unitList.splice(idx,1);
				_selectUnit.destroy();
				
				_selectUnit = null;
				SortingFun();
				fightingView.selectUnitViewRefresh();
			};
			//失败后处理
			var fF:Function = function():void{
				_selectUnit.x = beginX + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].x;
				_selectUnit.y = beginY + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].y;
				_selectUnit = null;
				SortingFun();
				fightingView.selectUnitViewRefresh();
			};
			FightingManager.intance.unitOperation(2,_selectUnit.data.unitId,_selectUnit.showPointID,"",_selectUnit.data.wyid,Handler.create(this,wF),Handler.create(this,fF));
		}
		
		//移动选中英雄
		private function changPointUnit(toKey:String):void{
			
			if(!_selectUnit)
				return ;
			//成功后处理
			var wF:Function = function():void{
				if(_jiaohuanU)  //有交换对象
				{
					_jiaohuanU.showPointID = _selectUnit.showPointID;
					tileMapData[_jiaohuanU.showPointID] = 1;
				}
				
				_selectUnit.showPointID = toKey;	
				var f:Function = function(u:BaseUnit):void{
					u.playAction(BaseUnit.ACTION_HOLDING)
				};
				_selectUnit.playAction(BaseUnit.ACTION_SHOW,Handler.create(this,f,[_selectUnit]));
				
				tileMapData[_selectUnit.showPointID] = 1;
				if(tileList[_selectUnit.showPointID].cellType == FightingTile.CELLTYPE5)
					tileList[_selectUnit.showPointID].cellType = FightingTile.CELLTYPE1;
				_selectUnit.x = beginX + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].x;
				_selectUnit.y = beginY + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].y;
				_selectUnit = _jiaohuanU = null;
				SortingFun();
				fightingView.selectUnitViewRefresh();
			};
			
			
			FightingManager.intance.unitOperation(2,_selectUnit.data.unitId,_selectUnit.showPointID,toKey,_selectUnit.data.wyid,Handler.create(this,wF),Handler.create(this,unitChangeFFun,[toKey]));	
		}
		//失败后处理
		private function unitChangeFFun(toKey:String):void{
			_selectUnit.x = beginX + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].x;
			_selectUnit.y = beginY + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].y;
			if(_jiaohuanU)
			{
				_jiaohuanU.x = beginX + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].x;
				_jiaohuanU.y = beginY + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].y;
			}
			_selectUnit = _jiaohuanU = null;
			SortingFun();
			fightingView.selectUnitViewRefresh();
			
			var t:FightingTile = tileList[toKey];
			if(t)
				t.cellType = FightingTile.CELLTYPE1;
		}
		
		public function isDownByUnitData(udata:fightUnitData,pstr:String):Boolean{
			var tile:FightingTile = tileList[pstr];
			if(!tile)
				return false;
			if(tile.direction != udata.direction)
				return false;
			if(_tileMapData[pstr] != 0)
				return false;
			return true;
		}
		
		private function stageUp(e:Event):void{
//			Laya.stage.off(Event.MOUSE_MOVE,this,stageMove);
//			Laya.stage.off(Event.MOUSE_UP,this,stageUp);
			off(Event.MOUSE_MOVE,this,stageMove);
			off(Event.MOUSE_UP,this,stageUp);
			off(Event.MOUSE_OUT,this,stageUp);
			fightingView.mouseEnabled = true;
			var tile:FightingTile = getThisTile(e);
			if(!tile)
			{
				deleteUnit();
			}else
			{
				if(isDownByUnitData(_selectUnit.data,tile.key)){
					changPointUnit(tile.key);
				}else
				{
					unitChangeFFun(tile.key);
				}
			}
		}
		
		private function getThisTile(e:Event):FightingTile
		{
			if(!_selectUnit)
				return null;
			
			var pii:Point = new Point(e.stageX,e.stageY);
			
			pii = unitLayer.globalToLocal(pii);
			pii.x -= FightingScene.tileW/2;
			pii.y -= FightingScene.tileH/2;
			
			_selectUnit.x = pii.x;
			_selectUnit.y = pii.y;
			
			return getTileByPoint(pii.x,pii.y);
		}
		
		
		private function getTileByPoint(px:Number ,py:Number):FightingTile
		{
			
//			var tilePixelWidth:Number = FightingScene.tileW * this.m_sprMap.scaleX ;
//			var tilePixelHeight:Number = FightingScene.tileH * this.m_sprMap.scaleY;
			var tilePixelWidth:Number = FightingScene.tileW ;
			var tilePixelHeight:Number = FightingScene.tileH ;
			
			var tilePoint:Point = FightingSceneManager.intance.getTilePoint(tilePixelWidth, tilePixelHeight, 
				px - beginX + tilePixelWidth / 2, py - beginY + tilePixelHeight /2 );
			
			var key:String = tilePoint.x +"_"+tilePoint.y;
			
			if(FightingSceneManager.intance.tilePointKeyV3.hasOwnProperty(key))
			{
				var pi:String = FightingSceneManager.intance.tilePointKeyV3[key];
				var tile:FightingTile = tileList[pi];
				if(tile)
				{
					return tile;
				}
			}
			return null;
		}
		
		
		
		public function SortingFun():void
		{
			this._unitList.sort(sortCompare);
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				this.unitLayer.addChild(_unitList[i]);
			}
			
		}
		
		private function sortCompare( target:BaseUnit , item:BaseUnit ):int
		{
			var p1:Point = FightingSceneManager.intance.tilePointKeyV1[target.showPointID];
			var p2:Point = FightingSceneManager.intance.tilePointKeyV1[item.showPointID];
			
			var targetX:Number = p1.x;
			var targetY:Number = p1.y;
			
			var itemX:Number = p2.x;
			var itemY:Number = p2.y;
			
			if (itemY < targetY) {
				return 1;
			}
			if (itemY > targetY) {
				return -1;
			}
			if (itemX > targetX) {
				return 1;
			}
			if (itemX < targetX) {
				return -1;
			}
			
			return 0;
		}
		
		public function squadMsg():String{
			var msg:String = "";
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var u:BaseUnit = _unitList[i];
				if(u.scene == this){
					var s:String = u.data.unitId + "*" + u.showPointID;
					
					var fg:String = msg.length ? ":":"";
					msg += fg + s;
				}
			}
			return msg;
		}
		
		public function getSquadMsgByDic(dic:uint):Array{
			var ar:Array  = [];
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var u:BaseUnit = _unitList[i];
				if(u.data.direction == dic){
//					var s:String = u.data.unitId + "*" + u.showPointID;
//					var fg:String = msg.length ? ":":"";
//					msg += fg + s;
					var obj:Object = {};
					obj.unitId = u.data.unitId;
					obj.hp = u.data.maxHp;
					obj.restHp = u.data.hp;
					var sar:Array = u.data.skillVos;
					var aaar:Array = [];
					for (var j:int = 0; j < sar.length; j++) 
					{
						aaar.push((sar[j] as SkillVo).skill_id);
					}
					obj.skillId = aaar.join("|");
				}
			}
			return ar;
		}
		
		
		public function beginFighting(ffd:FightingFormatData):void{
			mySelectUnitIds = [];
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var u:BaseUnit = _unitList[i];
				u.scene = null;
				u.enabled = false;
			}
			ffd.leftArmy = getSquadMsgByDic(1);
			ffd.rightArmy = getSquadMsgByDic(2);
			
			changeTileType();
		}
		
		
		public function fightingTiles(tPoints:Array , isback:Boolean = false):void
		{
			for (var i:int = 0; i < tPoints.length; i++) 
			{
				var tile:FightingTile = tileList[tPoints[i]];
				if(tile)
				{
					if(isback && tile.leftCellType)
					{
						tile.cellType = tile.leftCellType;
						tile.leftCellType = 0;
					}else
					{
						tile.cellType = FightingTile.CELLTYPE11;
					}
//					tile.filters = isback ? null : [FilterTool.redFilter];
				}
			}
			
		}
		
		
		private function stageMove(e:Event):void{
			
			var tile:FightingTile = getThisTile(e);
			if(tile)
			{
				var uitem:BaseUnit;
				for (var i:int = 0; i < _unitList.length; i++) 
				{
					var u:BaseUnit = _unitList[i];
					if(u.showPointID == tile.key && mySelectUnitIds.indexOf(u.data.unitId +"*"+u.data.wyid) != -1)
					{
						uitem = u;
						break;
					}
				}
				
				if(uitem && uitem != _jiaohuanU )
				{
					if(_jiaohuanU)
					{
						_jiaohuanU.x = beginX + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].x;
						_jiaohuanU.y = beginY + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].y;
						tileMapData[_jiaohuanU.showPointID] = 1;
//						trace("AAA3"+_jiaohuanU.showPointID);
						_jiaohuanU = null;
					}
					if(uitem != _selectUnit && uitem.data.direction == _selectUnit.data.direction)
					{
						_jiaohuanU = uitem;
						_jiaohuanU.x = beginX + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].x;
						_jiaohuanU.y = beginY + FightingSceneManager.intance.tilePointList[_selectUnit.showPointID].y;
						tileMapData[_jiaohuanU.showPointID] = 0;
					}
				}else if(!uitem)
				{
					if(_jiaohuanU)
					{
						_jiaohuanU.x = beginX + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].x;
						_jiaohuanU.y = beginY + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].y;
						tileMapData[_jiaohuanU.showPointID] = 1;
//						trace("AAA4"+_jiaohuanU.showPointID);
						_jiaohuanU = null;
					}
				}
				changeTileType(tile,_selectUnit.data);
			}else
			{
				if(_jiaohuanU)
				{
					_jiaohuanU.x = beginX + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].x;
					_jiaohuanU.y = beginY + FightingSceneManager.intance.tilePointList[_jiaohuanU.showPointID].y;
					tileMapData[_jiaohuanU.showPointID] = 1;
//					trace("AAA5"+_jiaohuanU.showPointID);
					_jiaohuanU = null;
				}
				changeTileType();
			}			
		}
		
		private function onGetWave(...args):void{
			waveNum = args[2];
		}
	
		
		public override function addEvent():void
		{
			super.addEvent();
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			Signal.intance.off(GameEvent.EVENT_MODULE_ADDED,this,onAdded);
			Signal.intance.on(GameEvent.EVENT_MODULE_ADDED,this,onAdded);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIGHT_ROUND),this, this.onGetWave);
		}
		public override function removeEvent():void
		{
			super.removeEvent();
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
			Signal.intance.off(GameEvent.EVENT_MODULE_ADDED,this,onAdded);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FIGHT_ROUND),this, this.onGetWave);
		}
		
		
		private function stageSizeChange(e:Event = null):void
		{
//			if(Laya.stage.scaleMode == Stage.SCALE_FULL)
//			{
				var scaleNum:Number =  Laya.stage.width / 1920; 
				this.mapScale2 = scaleNum;
//			}
		}
		
		
		public function set mapScale1(sV:Number):void{
			if(_mapScale1 != sV)
			{
				_mapScale1 = sV;
				bindMapScale();
			}
			
		}
		
		public function get mapScale1():Number{
			return _mapScale1;
		}
		
		
		public function set mapScale2(sV:Number):void{
			if(_mapScale2 != sV)
			{
				_mapScale2 = sV;
				bindMapScale();
			}
		}
		
		public function get mapScale2():Number{
			return _mapScale2;
		}
		
		public function bindMapScale():void{
			this.m_sprMap.scaleX = this.m_sprMap.scaleY = mapScale1 * mapScale2;
			m_sprMap.y = -10;
			if(GameSetting.isIPhoneX){
				m_sprMap.y = -70;
			}
			m_sprMap.x =  Laya.stage.width - m_sprMap.width * m_sprMap.scaleX >> 1;
//			m_sprMap.x = 0;
			sprMapPoint.x = this.m_sprMap.x;
			sprMapPoint.y = this.m_sprMap.y;
		}
		
		
		public function bindNeedFood(nfn:String, unitFood:*):void
		{
			var arr:Array = nfn.split("=")
			_foodType = arr[0];
			_needFood = arr[1];
			_unitFood = unitFood
			fightingView && fightingView.bindNeedFood(_foodType,_needFood, unitFood);
		}
		
		
		public function get spotlightSp():Sprite{
			if(!_spotlightSp)
			{
				_spotlightSp = new Sprite();
				_spotlightSp.graphics.drawRect(0,0,m_sprMap.width,m_sprMap.height,"#000000");
				_spotlightSp.alpha = .4;
			}
			return _spotlightSp;
		}
		
		public function Spotlight(poss:Array , stimer:Number):void{
			unitLayer.addChild(spotlightSp);
			for (var i:int = 0; i < poss.length; i++) 
			{
				var uitem:BaseUnit = getUnitByPoint(poss[i]);
				if(uitem)
					unitLayer.addChild(uitem);
			}
			timer.once(stimer,this,function():void{
				spotlightSp.removeSelf();
				SortingFun();
			});
		}
		
		
		public function Vibration(vo:vibrationSkillActionVo):void
		{
			if(playVibration)
				return ;
			playVibration = true;
			goVibration(vo,0,true);
			timer.once(vo.vibrationTime,this,function():void{
				playVibration = false;
			});
		}
		
		public function generateKey():void
		{
			for (var i:int = 0; i < _unitList.length; i++) 
			{
				var uitem:BaseUnit = _unitList[i];
				uitem.data.wyid = Math.random();
				trace("生成唯一ID",uitem.data.wyid);
			}
			
		}
		
		
		private function goVibration(vo:vibrationSkillActionVo,idx:Number , isOpen:Boolean = false):void
		{
			if(!playVibration)
			{
				this.m_sprMap.x = sprMapPoint.x;
				this.m_sprMap.y = sprMapPoint.y;
				return ;
			}
			trace("++++++++++goVibration+++++++++++++");
			if(idx >= vo.vibrationRouteAr.length)
				idx = 0;
			
			var obj:Object = vo.vibrationRouteAr[idx];
			var toObj:Object = {};
			for (var key:String in obj) 
			{
				var v:Number = obj[key];
				switch(key)
				{
					case "x":
					{
						toObj[key] = v + sprMapPoint.x;
						break;
					}
					case "y":
					{
						toObj[key] = v + sprMapPoint.y;
						break;
					}
					case "alpha":
					{
						toObj[key] = v + sprMapPoint.alpha;
						break;
					}
				}
			}
			
			var interval:Number = isOpen ? 0 : vo.vibrationInterval;
			Tween.to(this.m_sprMap,toObj,vo.vibrationSpeed,null,Handler.create(this,goVibration,[vo,idx + 1]),interval);
		}
		
		
		
		override public function close():void{
			trace("战斗场景close被调用");
			unitLayer.mouseEnabled = true;
			_handler = null;
			_copyfData = null;
			_leftReportkey = 1;
			
			_selectUnit = null;
			_jiaohuanU = null;
			completeHandler = null;
			
			if(fightingView){
				fightingView.selectUnitView.m_list.mouseEnabled = true;
				mySelectUnitIds = [];
				selfSelectUnitIdx = [];
				fightingView.bindSelectUnitViewData();
				fightingView.stopTimerChange();
				fightingView.scence = null;
				XFacade.instance.closeModule(PveFightingView);
				XFacade.instance.closeModule(PvpFightingView);
				fightingView = null;
			}
			
			
			for(var k:* in tileList) 
			{
				var tile:FightingTile = tileList[k];
				tile.cellType = FightingTile.CELLTYPE1;
				tile.leftCellType = 0;
				tileMapData[tile.key] =  0;
				tile.deleteAllBuff();
				tile.scene = null;
			}
			
			while(_unitList.length){
				var uitem:BaseUnit = _unitList.shift();
				uitem.removeSelf();
				uitem.scene = null;
				uitem.destroy();
			}
			
			off(Event.MOUSE_MOVE,this,stageMove);
			off(Event.MOUSE_UP,this,stageUp);
			off(Event.MOUSE_OUT,this,stageUp);
			off(Event.CLICK,this,attackDown);
			
			FightingManager.intance.removeData();
			SkillManager.intance.removeData();
			
			SoundManager.stopSound(ResourceManager.instance.getSoundURL("mainscene"));
			
			ResourceManager.instance.clearResByGroup(figtingModerGroup);
			while(animationCacheKeys.length){
				var key:String = animationCacheKeys.shift();
				Animation.clearCache(key);
				trace("清除动画缓存",key);
			};
			_useFightingUnit = null;
			Laya.loader.clearRes(_mBgImgUrl+".jpg");
			ftData = null;
//			_copyFData = null;
			super.close();
			
			XFacade.instance.disposeView(this);
		}
		
		
		//覆盖关闭加载方法
		protected override function hideBufferView():void{
			
		}
		
		
		public override function dispose():void{
			
			trace(1,"dispose FightingScene");
			
			if(fightingView){
				fightingView.scence = null;
				fightingView = null;
			}
			for(var k:* in tileList) 
			{
				var tile:FightingTile = tileList[k];
				delete tileList[k];
				tile.destroy();
			}
			
			removerAllUnit();
			
			off(Event.MOUSE_MOVE,this,stageMove);
			off(Event.MOUSE_UP,this,stageUp);
			off(Event.MOUSE_OUT,this,stageUp);
			
			
			gridSp = null;
			tileLayer = null;
			unitLayer = null;
			bSkillLayer = null;
			tSkillLayer = null;
			ftData = null;
//			_copyFData = null;
			_tileMapData = null;
			tileList = null;
			completeHandler = null;
			_virtualFdata = null;
			_squadData = null;
			mySelectUnitIds = null;
			selfSelectUnitIdx = null;
			_unitList = null;
			_handler = null;
			_copyfData = null;
			_useFightingUnit = null;
			skillPointKeys = null;
			skillNotPointKeys = null;
			movePointKeys = null;
			_selectUnit = null;
			_jiaohuanU = null;
			_spotlightSp = null;
			sprMapPoint = null;
			
			super.dispose();
		}
	}
}