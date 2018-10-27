package game.module.mainScene
{
	import MornUI.mainView.HarvestComUI;
	import MornUI.mainView.ProtectComUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XUtils;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.fighting.BaseUnit;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Pool;
		
	public class BaseArticle extends Sprite
	{
	
		private var redLayer:Sprite/* = new Sprite();*/  //红色层
		private var greenLayer:Sprite/* = new Sprite()*/;  //绿色层
		private var _isBgDraw:Boolean = false;
		//影响建筑区域
		protected var effSp:Sprite;
		//收获图标
		public var harvestIcon:HarvestComUI;
		
		protected var skinSprite:Sprite;
		protected var _skin:String;
		private var _data:ArticleData;
		//时间组件
		private var _timeCom:TimeBarCom;
		//训练组件
		private var _trainCom:TrainInfoCom;
		//名字组件
		private var _nameCom:BuildingNameCom
		//下降组件
		private var _downAr:Image;
		//是否升级操作中
		public var isUping:Boolean = false;;
		/**是否移动中*/
		private var _moving:Boolean = false;
				
		public function BaseArticle()
		{
			super();
			this.init();
			this.mouseEnabled = this.mouseThrough = true;
		}
		
		protected function init():void{
			redLayer = new Sprite();
			greenLayer = new Sprite();
			addChild(redLayer);
			addChild(greenLayer);
			redLayer.visible = greenLayer.visible = false;		
		}
		
		//更新外观，数据==
		public function update(data:ArticleData, skin:String = ""):void{
			this.data = data;
			if(skin == ""){
				var tmp:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level);
				if(tmp.model.indexOf(".json") != -1){
					var sk:String = tmp.model.replace(".json","");
					skin = "appRes/building/"+sk+"/daiji/daiji.json"
				}else{
					skin = "appRes/building/"+tmp.model+".png";
				}
			}
			
			bindSkin(skin);
			//被怪物印象
			if(!XUtils.isEmpty(data.buff)){
				if(!_downAr){
					_downAr = new Image("mainUi/downArrow.png");
					doScale(_dScale)
				}
				this.addChild(_downAr);
			}else{
				if(_downAr){
					_downAr.removeSelf();
				}
			}
			
			var info:Object = DBBuilding.getBuildingById(_data.buildId);
			if(!_nameCom){
				_nameCom = new BuildingNameCom();
				this.addChild(_nameCom);
				_nameCom.pos(-_nameCom.width/2, -_nameCom.height);
				_nameCom.cacheAsBitmap = true;
				//_nameCom.cacheAs = "bitmap";
			}
			if(lvUpAni){
				lvUpAni.removeSelf();
				lvUpAni = null;
			}
			_nameCom.setInfo(info.name, info.level_limit>1?_data.level:"");
			if(data.buildId == DBBuilding.WALL_1 || data.buildId == DBBuilding.WALL_2){
				_nameCom.visible = false;
			}else{
				_nameCom.visible = true;
			}
			
			if(canHarvest){
				showHarvest(true);
			}else{
				showHarvest(false);
			}
		}
		
		/***/
		public function showEffArea(step:int=3, color='#ff0000',alpha:Number = 0.1):void{
			if(!effSp){
				effSp = new Sprite();
				this.addChildAt(effSp,0);
				//effSp.pos(0,-26);
				//半径需要秀i正
				var delY:Number = HomeData.tileH * data.model_h * 0.5 * 0.5;
				
				XUtils.createEllipse(effSp.graphics,0,-delY,81*step,81*step/2,20,color);
				effSp.alpha = alpha;
			}
			effSp.visible = true;
		}
		
		/***/
		/***/
		private static const INFO:Object = 
			{
				2:{s:0.75,x:-160,y:-130},
				3:{s:1.26,x:-260,y:-160},
				4:{s:1.50,x:-324,y:-212},
				5:{s:1.87,x:-404,y:-252},
				6:{s:2.25,x:-486,y:-292}
			}
		public function creatEffArea(skin:String, step:int=3, color='#ff0000',alpha:Number = 0.1):void{
			if(!effSp){
				effSp = new Image(skin);
				this.addChildAt(effSp,0);
				var info:Object = INFO[step];
				effSp.scale(info.s,info.s);
				var delY:Number = HomeData.tileH * (data.model_h-2) * 0.5;
				effSp.pos(info.x, info.y-delY);
			}
			effSp.visible = true;
			showEffArea(step, color, alpha);
		}
		
		/***/
		public function hideEffect():void{
			if(effSp){
				effSp.visible = false;
			}
		}
		
		/**
		 * @param isFinish 是否已经结束，如果已经结束，不接受其他参数
		 * */
		public function updateTime(time:Number, isFinish:Boolean = false):void{
			if(isFinish){
				timeOver(false);
				hideUpgrade()
				return;
			}
			//条件判断。。
			if(time*1000 < TimeUtil.now){
				return;
			}
			isUping = true;
			if(!_timeCom){
				_timeCom = Pool.getItemByClass("TimeBarCom", TimeBarCom);
			}
			this.addChild(_timeCom);
			_timeCom.pos(-80,-HomeData.tileH*data.model_w-20);
			doScale(this._dScale);
			
			var vo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(this.data.buildId, this.data.level);
			var total:Number = vo.CD*1000
			showUpgrade();
			_timeCom.updateTime(time,total, Handler.create(this,this.timeOver), data.id);
		}
		
		public function showTrainInfo(time:int):void{
			if(!_trainCom){
				_trainCom = new TrainInfoCom();
			}
			this.addChild(_trainCom);
			_trainCom.pos(-50,-HomeData.tileH*data.model_w-90);
			doScale(this._dScale);
			//AnimationUtil.addFlow(harvestIcon)
			_trainCom.show(time);
		}
		
		private var _upImg:Image;
		private var _ani:Animation;
		private function showUpgrade():void{
			if(!this._upImg){
				_upImg = new Image();
			}
			_upImg.skin = "appRes/building/3X3-B"+".png";
			_ani = BuildAniUtil.upAni;
			_ani.autoPlay = true;
			this.addChildAt(_upImg, 0);
			this.addChildAt(_ani,_nameCom.parent.getChildIndex(_nameCom));
			var pos:Array = BuildAniUtil.getPicPos(data.model_w);
			_upImg.scale(pos[4],pos[4]);
			_ani.scale(pos[4],pos[4]);
			_upImg.pos(pos[0],pos[1]);
			_ani.pos(pos[2],pos[3]);
		}
		
		private function hideUpgrade():void{
			if(_upImg){
				_upImg.removeSelf();
			}
			if(_ani){
				_ani.stop();
				_ani.removeSelf();
				_ani = null;
			}
		}
		
		/***/
		private var _upgradeAni:Animation;
		private var _upgradeAni2:Animation;
		public function upgradeDone():void{
			_upgradeAni = BuildAniUtil.upgradeAni;
			_upgradeAni2 = BuildAniUtil.upgradeAni2;
			
			this.addChildAt(_upgradeAni, 0);
			this.addChild(_upgradeAni2);
			_upgradeAni.autoPlay = true;
			_upgradeAni2.autoPlay = true;
			var pos:Array = BuildAniUtil.getDonePos(data.model_w);
			_upgradeAni.scale(pos[4],pos[4]);
			_upgradeAni2.scale(pos[4],pos[4]);
			_upgradeAni.pos(pos[0],pos[1]);
			_upgradeAni2.pos(pos[2],pos[3]);
			XUtils.autoRecyle(_upgradeAni);
			XUtils.autoRecyle(_upgradeAni2);
			SoundMgr.instance.playSound(ResourceManager.getSoundUrl("ui_paid_building_upgrade",'uiSound'));
		}
		
		public function get isFull():Boolean{
			var key:String = data.buildId.replace("B","");
			if(key == DBBuilding.B_STONE_F){
				return (User.getInstance().stone>=User.getInstance().sceneInfo.getResCap(DBItem.STONE));
			}else if(key == DBBuilding.B_STEEL_F){
				return (User.getInstance().steel>=User.getInstance().sceneInfo.getResCap(DBItem.STEEL));
			}else if(key == DBBuilding.B_GOLD_F){
				return (User.getInstance().gold>=User.getInstance().sceneInfo.getResCap(DBItem.GOLD));
			}else if(key == DBBuilding.B_FOOD_F){
				return (User.getInstance().food>=User.getInstance().sceneInfo.getResCap(DBItem.FOOD));
			}else if(key == DBBuilding.B_BREAD_C){
				return (User.getInstance().bread>=User.getInstance().sceneInfo.getResCap(DBItem.BREAD));
			}
			return false
		}
		public function showHarvest(b:Boolean):void{
			if(b){
				var key:String = data.buildId.replace("B","");
				if(!harvestIcon){
					harvestIcon = new HarvestComUI();
					harvestIcon.mouseEnabled = true;
					//harvestIcon.cacheAsBitmap = true;
					if(key == DBBuilding.B_STONE_F){
						harvestIcon.icon.skin = "appRes/icon/itemIcon/jczy2.png"
					}else if(key == DBBuilding.B_STEEL_F){
						harvestIcon.icon.skin = "appRes/icon/itemIcon/jczy3.png"
					}else if(key == DBBuilding.B_GOLD_F){
						harvestIcon.icon.skin = "appRes/icon/itemIcon/jczy4.png"
					}else if(key == DBBuilding.B_FOOD_F){
						harvestIcon.icon.skin = "appRes/icon/itemIcon/jczy5.png"
					}else if(key == DBBuilding.B_BREAD_C)
					{
						harvestIcon.icon.skin = "appRes/icon/itemIcon/jczy20.png"
					}
					this.addChild(harvestIcon);
					harvestIcon.pos(-40, -HomeData.tileH*data.model_w-88)
				}
				if(isFull){
					harvestIcon.bgBtn.skin = "mainUi/btn_2_3.png";
				}else{
					harvestIcon.bgBtn.skin = "mainUi/btn_2_2.png";
				}
				harvestIcon.pos(-40, -HomeData.tileH*data.model_w-88)
				harvestIcon.visible = true;
				AnimationUtil.addFlow(harvestIcon);
				//this.cacheAsBitmap = false;
			}else{
				if(harvestIcon){
					harvestIcon.visible = false;
					AnimationUtil.removeFlow(harvestIcon)
				}
				//this.cacheAs = "normal"
				//_nameCom && (_nameCom.cacheAsBitmap = false);
			}
		}
		
		/**特殊标志-显示矿山*/
		public var isShowMine:Boolean = false;
		/**特殊标志-显示基地互动*/
		public var isShowHD:Boolean = false;
		/**特殊标志-显示运镖*/
		public var isShowTransport:Boolean = false
		//
		public function showAction(b:Boolean, skin:String = "mainUi/3.png"):void{
			if(b){
				var key:String = data.buildId.replace("B","");
				if(!harvestIcon){
					harvestIcon = new HarvestComUI();
					harvestIcon.mouseEnabled = true;
					harvestIcon.cacheAsBitmap = true;
					harvestIcon.bgBtn.skin = "";
					this.addChild(harvestIcon);
				}
				harvestIcon.icon.skin = skin;
				harvestIcon.pos(-40, -HomeData.tileH*data.model_w-88)
				harvestIcon.visible = true;
				AnimationUtil.addFlow(harvestIcon)
				//this.cacheAsBitmap = false;
			}else{
				if(harvestIcon){
					harvestIcon.visible = false;
					AnimationUtil.removeFlow(harvestIcon)
				}
				//this.cacheAs = "normal";
				//_nameCom && (_nameCom.cacheAsBitmap = false);
			}
		}
		
		//
		private function timeOver(cutdown:Boolean=true):void{
			if(this._timeCom){
				this._timeCom.close();
				this._timeCom = null;
			}
			isUping = false;
			hideUpgrade();
			cutdown && this.upgradeDone();
		}
		
		/**显示可升级状态*/
		private var lvUpAni:Animation;
		public function showLvUp(bool:Boolean):void{
			if(bool && !isFull){
				if(this._nameCom){
					if(!lvUpAni){
						lvUpAni = new Animation();
						lvUpAni.loadAtlas("appRes/atlas/camp/effect.json");
						lvUpAni.autoPlay = true;
					}
					this.addChild(lvUpAni);
					doScale(_dScale)
				}
			}else{
				if(lvUpAni){
					lvUpAni.removeSelf();
				}
			}
		}
		
		/**显示保护盾时间*/
		private var _proCom:ProtectComUI
		public function showProtect(timeStr:String):void{
			if(!_proCom){
				_proCom = new ProtectComUI();
				this._proCom.pos(-_proCom.width/2-24,-268);
				this.addChild(_proCom);
			}
			if(timeStr == ""){
				_proCom.visible = false;
			}else{
				_proCom.visible = true;
				_proCom.timeTF.text = timeStr;
			}
		}
		
		public function get canMove():Boolean{
			return !this.data.buff && !this.data.effMonsters
		}
		
		
		public function get showPoint():Point
		{
			return data.showPoint;
		}
		
		public function set showPoint(value:Point):void
		{
			if(data.showPoint != value)
			{
				data.showPoint = value;
				if(data.showPoint)
				{
					var p:Point = HomeData.intance.getPointPos(data.showPoint.x,data.showPoint.y);
					this.x = p.x;
					this.y = p.y;
				}
			}
		}
		
		
		private function setBgLayer():void
		{
			if(_isBgDraw){
				return;
			}
			
			_isBgDraw = true;
			var rColor:Array = ["#f01919","#d43838"];  //线条颜色 填充颜色
			var gColor:Array = ["#10f010","#3b943b"];  //线条颜色 填充颜色
			var w:Number = this.data.model_w
			var h:Number = this.data.model_h
			var p1:Point = new Point(0,0);
			var p2:Point = new Point(-h*HomeData.tileW/2, -h*HomeData.tileH/2);
			var p3:Point = new Point(0, -w*HomeData.tileH/2-h*HomeData.tileH/2);
			var p4:Point = new Point(w*HomeData.tileW/2,-w*HomeData.tileH/2);
			var tmp:Array = [p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y]
			
			redLayer.graphics.drawPoly(p1.x, p1.y,tmp,rColor[1],rColor[0]);
			greenLayer.graphics.drawPoly(p1.x, p1.y,tmp,gColor[1],gColor[0]);
		}
		
		private static const NONE_STOP_ANI:Array = ["18","2","7","11","23","102","105"]
		protected function bindSkin(skin:String):void
		{
			if(_skin == skin || !skin){
				return;
			}else if(_skin){
				if(skinSprite is Image){
					skinSprite.removeSelf();
					skinSprite = null;
				}
			}
			_skin = skin;
			
			//
			var img:Sprite;
			var imgHitArea:HitArea = new HitArea();
			if(skin.indexOf(".json")!= -1){
				if(skinSprite){
					Animation(skinSprite).off(Event.COMPLETE, this, this.onComplete);
					skinSprite.removeSelf();
				}
				img = new Animation();
				skinSprite = img;
				var needEvent:Boolean = false;
				var id:String = data.buildId.replace("B","");
				if(NONE_STOP_ANI.indexOf(id) == -1){
					Animation(img).interval = 150;
					Animation(skinSprite).wrapMode = 2;
					dance();
					needEvent = true;
				}else{
					Animation(img).autoPlay = true;
					if(id == DBBuilding.B_TEAMCOPY){
						Animation(img).interval = 180;
					}else{
						Animation(img).interval = 200;
					}
				}
				Animation(img).autoPlay = true;
				Animation(img).loadAtlas(skin,Handler.create(this, onLoadAni,[needEvent]));
			}else{
				//this.cacheAs = "normal";
				//_nameCom && (_nameCom.cacheAsBitmap = false);
				img = skinSprite;
				if(!img){
					img = new Image();
				}
				skinSprite = img;
				img.loadImage(skin, 0, 0, 0, 0, Handler.create(this, onLoadPic));
			}
			
			var w:Number = this.data.model_w;
			var h:Number = this.data.model_h;
			var p1:Point = new Point(0,0);
			var p2:Point = new Point(-h*HomeData.tileW/2, -h*HomeData.tileH/2);
			var p3:Point = new Point(0, -w*HomeData.tileH/2-h*HomeData.tileH/2-50);
			var p4:Point = new Point(w*HomeData.tileW/2,-w*HomeData.tileH/2);
			var tmp:Array = [p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y]
			imgHitArea.hit.drawPoly(0,0,tmp,"#f8ffff");
			
			this.hitArea = imgHitArea;
			this.addChildAt(skinSprite, this.getChildIndex(greenLayer)+1);
		}
		
		public function releaseSkin():void{
			if(skinSprite is Animation){
				var ani:Animation = Animation(skinSprite);
				ani.clear();
				Loader.clearRes(_skin);
				_skin = "";
			}
		}
		
		
		//对齐方法
		private function onLoadPic():void{
			skinSprite.x = -skinSprite.width/2;
			skinSprite.y = -skinSprite.height;
			var posArr:Array = BuildPosData.getOff(data.buildId);
			if(posArr){
				skinSprite.x += posArr[0];
				skinSprite.y += posArr[1];
			}
			skinSprite.name = skinSprite.x+"_"+skinSprite.y;
		}
		
		private function onLoadAni(needEvent:Boolean = false):void{
			var p:Point = BaseUnit.getAnimationMaxSize(_skin);
			var posArr:Array = BuildPosData.getOff(data.buildId);
			if(posArr){
				skinSprite.x += posArr[0];
				skinSprite.y += posArr[1];
			}

			skinSprite.name = skinSprite.x+"_"+skinSprite.y;
			
			if(needEvent){
				Animation(skinSprite).play(0,false);
				Animation(skinSprite).on(Event.COMPLETE, this, this.onComplete);
			}else{
				Animation(skinSprite).play(0);
			}
		}
		
		/**特殊处理缩放的问题*/
		private var _dScale:Number = 1;
		public function doScale(v:Number):void{
			_dScale = v;
			var scale:Number = 1/v - (1-v)*0.7
			if(_nameCom){
				this._nameCom.scale(scale, scale);
				_nameCom.x = -_nameCom.width/2 - (1/v-1)*80
					
				if(lvUpAni){
					lvUpAni.x = this._nameCom.x + this._nameCom.aniSprit.x*scale;
					lvUpAni.y = this._nameCom.y + this._nameCom.aniSprit.y;
				}
				if(_downAr){
					_downAr.y = -30;
					_downAr.x = this._nameCom.x-_downAr.width;
					//_downAr.pos(-150, -38);
				}
			}
			if(_timeCom){
				this._timeCom.scale(scale, scale);
				_timeCom.x = -80 - (1/v-1)*70
			}
			
			if(_trainCom){
				this._trainCom.scale(scale, scale);
				_trainCom.x = -110 - (1/v-1)*70
			}
		}
		
		private var _danceTime:Number = 0;
		public function dance():void{
			if(_danceTime == 0){
				_danceTime = Math.round(Math.random()*3+2);
			}
		}
		private function onComplete():void{
			Animation(skinSprite).wrapMode = Animation(skinSprite).wrapMode == 0 ? 1:0;
			Laya.timer.once(_danceTime*1000, Animation(skinSprite),Animation(skinSprite).play,[Animation(skinSprite).index,false]);
		}
		
		protected var _isSelect:Boolean = false;
		public function get isSelect():Boolean
		{
			return _isSelect;
		}
		
		public function set isSelect(value:Boolean):void
		{
			if(_isSelect != value){
				_isSelect = value;
				var info:Object = DBBuilding.getBuildingById(_data.buildId);
				if(!_isSelect){
					redLayer.visible = greenLayer.visible = false;
					BuildAniUtil.hideAni();
					if(info.building_type == DBBuilding.TYPE_DEFEND){
						this.hideEffect();
					}
				}else{
					showSelect();
					if(info.building_type == DBBuilding.TYPE_DEFEND){
						var obj:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(data.buildId, data.level);
						this.creatEffArea("mainUi/bg17.png",obj.param1,"#ffffff", 0.2);
					}
				}
			}
		}
		
		private function showSelect():void{
			var arr:Array = BuildAniUtil.getBuildSelectAni(data.model_w, data.model_h);
			BuildAniUtil.setPos(arr[0],data.model_w);
			BuildAniUtil.setPos(arr[1],data.model_w);
			this.addChildAt(arr[0], 0);
			this.addChildAt(arr[1], 0);
		}
		
		public function showDownAni():void{
			var ani:Animation = BuildAniUtil.getBuildDownAni()
			this.addChildAt(ani, 0);
			BuildAniUtil.setDownPos(ani,data.model_w);
			XUtils.autoRecyle(ani, true);
			SoundMgr.instance.playSound(ResourceManager.getSoundUrl("select_drop_building",'uiSound'));
		}
		
		
		public function showBgLayer(canMove:Boolean):void
		{
			redLayer.visible = !canMove;
			greenLayer.visible = canMove;
			setBgLayer();
		}
		
		public function get canHarvest():Boolean{
			if(data.resource){
				var tmp:Array = data.resource.split("=");
				if(parseInt(tmp[1]) > 10){
					return true;
				}
			}
			return false
		}
		
		public function get data():ArticleData{
			return _data;
		}
		
		public function set data(value:ArticleData):void{
			if(_data != value){
				_data = value;
			}
		}
		
		public function set realPoint(value:Point):void
		{
			data.realPoint = value;
		}
		
		public function get realPoint():Point
		{
			return data.realPoint;
		}
		
		public function set moving(v:Boolean):void{
			if(this._moving != v){
				this._moving = v;
				if(this._moving){
					AnimationUtil.showUp(skinSprite,true);
				}else{
					AnimationUtil.showDown(skinSprite, true);
					showDownAni();
					redLayer.visible = greenLayer.visible = false;
				}
			}
		}
		
		public function get moving():Boolean{
			return this._moving;
		}
	}
}