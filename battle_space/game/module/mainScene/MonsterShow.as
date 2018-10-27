package game.module.mainScene
{
	import game.common.XUtils;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.fighting.BaseUnit;
	import game.global.vo.BuildingLevelVo;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;

	/**
	 * MonsterShow
	 * author:huhaiming
	 * MonsterShow.as 2017-5-4 下午4:52:27
	 * version 1.0
	 *
	 */
	public class MonsterShow extends BaseArticle
	{
		private var _hpCom:HpCom;
		public function MonsterShow()
		{
			super();
		}
		
		override protected function init():void{
			
		}
		
		/***/
		public function showHP(n:Number):void{
			if(!_hpCom){
				_hpCom = new HpCom();
				_hpCom.pos(-50,-200);
				this.addChild(_hpCom);
			}
			_hpCom.update(n)
		}
		
		//更新外观，数据==
		override public function update(data:ArticleData, skin:String = ""):void{
			this.data = data;
			
			bindSkin(skin);
			
			var info:Object = DBBuilding.getBuildingById(data.buildId);
			creatEffArea("mainUi/bg2.png")
		}
		
		override protected function bindSkin(skin:String):void
		{
			if(_skin == skin || !skin){
				return;
			}else{
				if(skinSprite){
					skinSprite.removeSelf()
				}
			}
			_skin = skin;
			
			//
			var imgHitArea:HitArea = new HitArea();
			var img:Animation = new Animation();
			skinSprite = img;
			Animation(img).interval = BaseUnit.animationInterval;
			Animation(img).autoPlay = true;
			Animation(img).loadAtlas(skin,Handler.create(this, onLoadAni));

			imgHitArea.hit.drawRect(-35,-140,70,140,"#ff0000");
			this.hitArea = imgHitArea;
			
			this.addChild(skinSprite);
		}
		
		private function onLoadAni():void{
			var p:Point = BaseUnit.getAnimationMaxSize(_skin);
			skinSprite.scaleX= skinSprite.scaleY = 0.85;
			p.x *= 0.85;
			p.y *= 0.85;
			skinSprite.x = -p.x/2;
			skinSprite.y = -p.y/2 - HomeData.tileH/2;
			Animation(skinSprite).play(0);
		}
		
		override public function set isSelect(value:Boolean):void
		{
			if(_isSelect != value){
				_isSelect = value;
			}
		}
	}
}