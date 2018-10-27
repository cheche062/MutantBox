package game.module.invasion
{
	import MornUI.mainView.BuildNameComUI;
	
	import game.common.FilterTool;
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.fighting.BaseUnit;
	import game.global.vo.BuildingLevelVo;
	import game.module.mainScene.ArticleData;
	import game.module.mainScene.BuildPosData;
	import game.module.mainScene.HomeData;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.resource.Bitmap;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	
	public class InvasionBuilding extends Sprite
	{
		private var skinSprite:Sprite;
		private var _skin:String;
		private var _data:ArticleData;
		private var _isSelect:Boolean = false;
		//
		//名字组件
		private var _nameCom:BuildNameComUI
		//是否为箭塔
		public var isTower:Boolean = false;
		
		public function InvasionBuilding()
		{
			super();		
			
			this.mouseEnabled = this.mouseThrough = true;
		}
		
		/**显示代币数目*/
		private var _dbTF:Text;
		private var _dbItem:InvasionItem;
		public function showDB(numStr:String):void{
			//9=10
			var arr:Array = numStr.split("=");
			var num:Number = parseInt(arr[1]);
			if(num > 0){
				if(!_dbItem){
					_dbItem = new InvasionItem();
					this.addChild(_dbItem);
					_dbItem.pos(-80,-210);
				}
				_dbItem.showDB(num, numStr);
			}else{
				if(_dbItem){
					_dbItem.visible = false;
				}
			}
		}
		
		/**塔楼问题*/
		private var _dangerIcon:Image;
		private static const TOWERS:Array = [100,101,102,103,104,105,106,107];
		public function showTowerTip():void{
			var k:int = parseInt(data.buildId.replace("B",""));
			if(TOWERS.indexOf(k) != -1){
				if(!_dangerIcon){
					_dangerIcon = new Image("invasion/bg1.png");
				}
				this.addChild(_dangerIcon);
				_dangerIcon.pos(-40,-220);
			}
		}
		
		public function hideTowerTip():void{
			if(_dangerIcon){
				_dangerIcon.removeSelf();
			}
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
			
			var info:Object = DBBuilding.getBuildingById(_data.buildId);
			if(info){
				/*if(!_nameCom){
					_nameCom = new BuildNameComUI();
					this.addChild(_nameCom);
					_nameCom.pos(-_nameCom.width/2, -_nameCom.height);
				}*/
			}
			
			var k:int = parseInt(data.buildId.replace("B",""));
			
			
			
			if(TOWERS.indexOf(k) != -1){
				isTower = true;
				
				var delY:Number = HomeData.tileH * data.model_h * 0.5 * 0.5;
				
				//XUtils.createEllipse(this.graphics,0,-delY,81*tmp.param1,81*tmp.param1/2,30,"#ffffff");
				XUtils.createEllipse(this.hitArea.hit,0,-delY,81*tmp.param1,81*tmp.param1/2,30,"#ffffff");
			}
		}
		
		private static const NONE_STOP_ANI:String = ["18","2","7","11","23","102","105"]
		private function bindSkin(skin:String):void
		{
			if(_skin == skin || !skin){
				return;
			}
			_skin = skin;
			
			//
			var img:Sprite;
			var imgHitArea:HitArea = new HitArea();
			if(skin.indexOf(".json")!= -1){
				img = skinSprite;
				if(!img){
					img = new Animation();
					skinSprite = img;
				}
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
			this.addChildAt(skinSprite, 0);
		}
		
		public function releaseSkin():void{
			if(skinSprite is Animation){
				var ani:Animation = Animation(skinSprite);
				ani.clear();
				Loader.clearRes(_skin);
				_skin = "";
			}
		}
		
		//对齐方法需要重新设定
		private function onLoadPic():void{
			skinSprite.x = -skinSprite.width/2;
			skinSprite.y = -skinSprite.height;
			var posArr = BuildPosData.getOff(data.buildId);
			if(posArr){
				skinSprite.x += posArr[0];
				skinSprite.y += posArr[1]
			}
		}
		
		private function onLoadAni(needEvent:Boolean = false):void{
			var p:Point = BaseUnit.getAnimationMaxSize(_skin);
			var posArr:Array = BuildPosData.getOff(data.buildId);
			if(posArr){
				skinSprite.x += posArr[0];
				skinSprite.y += posArr[1]
			}
			Animation(skinSprite).addLabel("start", 0);
			
			skinSprite.name = skinSprite.x+"_"+skinSprite.y;
			
			if(needEvent){
				Animation(skinSprite).play(0,false);
				Animation(skinSprite).on(Event.COMPLETE, this, this.onComplete);
			}else{
				Animation(skinSprite).play(0);
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
		
		public function get isSelect():Boolean
		{
			return _isSelect;
		}
		
		public function set isSelect(value:Boolean):void
		{
			if(_isSelect != value){
				_isSelect = value;
				if(_isSelect){
					//this.skinSprite.filters = [FilterTool.bigGlowFilter];
					if(_dbItem){
						_dbItem.selected = true;
					}
				}else{
					this.skinSprite.filters = [];
					if(_dbItem){
						_dbItem.selected = false;
					}
				}
			}
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
	}
}

