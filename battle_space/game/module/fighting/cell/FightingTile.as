/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import game.global.GameConfigManager;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.vo.SkillBuffVo;
	import game.global.vo.skillControlActionVos.effectSkillActionVo;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.scene.FightingScene;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	
	public class FightingTile extends Sprite
	{
		public static const CELLTYPE1:uint = 1;  //常规
		public static const CELLTYPE2:uint = 2;  //可攻击范围
		public static const CELLTYPE3:uint = 3;  //可攻击范围 被阻挡 - 蓝色
		public static const CELLTYPE4:uint = 4;  //最终攻击范围
		public static const CELLTYPE5:uint = 5;  //移动范围
		public static const CELLTYPE6:uint = 6;  //可移动 被阻挡
		public static const CELLTYPE7:uint = 7;  //选中攻击目标
		public static const CELLTYPE8:uint = 8;  //选中移动目标
		public static const CELLTYPE9:uint = 9;  //选中
		public static const CELLTYPE10:uint = 10;  //可攻击范围 被阻挡 - 黄色
		public static const CELLTYPE11:uint = 11;  //遭到攻击
		
		private var typeBg:Image = new Image();
		private var topBg:Image = new Image();
		private var _key:String;
		public var direction:uint;
//		public var pointText:Text = new Text();
		public var scene:FightingScene;
		
		private var buffEctSp:Sprite = new Sprite();
		private var _skillEcts:Array = [];
		private var showBuffs:Array = [];
		private var _cellType:uint;
		public var leftCellType:uint;
		
		
		public function FightingTile()
		{
			super();
			size(FightingScene.tileW , FightingScene.tileH);
			addChild(typeBg);
			
			addChild(topBg);
			
			addChild(buffEctSp);
			
			
//			typeBg.scaleX = typeBg.scaleY = topBg.scaleX = topBg.scaleY = 1.4;
			
//			addChild(pointText);
//			pointText.x = 90;
//			pointText.y = 50;
//			pointText.autoSize = true;
//			pointText.fontSize = 20;
//			pointText.color = "#ffff00";
//			pointText.width = 100;
//			pointText.height = 20;
			
			var tW:Number = FightingScene.tileW / 2;
			var tH:Number = FightingScene.tileH / 2;
//			this.graphics.drawPoly(tW, 0,[0-tW,tH,0,tH*2,tW,tH,0,0],"#fff000","#ffff00");
//			this.cacheAsBitmap = true;
			
			var imgHitArea:HitArea = new HitArea();
			imgHitArea.hit.drawPoly(tW, 0,[0-tW,tH,0,tH*2,tW,tH,0,0],"#f8ffff");
			this.hitArea = imgHitArea;
			this.mouseEnabled = this.mouseThrough =  true;
			
			Signal.intance.on(FightingManager.FIGHT_VELOCITY_CHANGE,this,velocityChange);
		}
		
		private function velocityChange(e:Event):void
		{
			for (var j:int = 0; j < _skillEcts.length; j++) 
			{
				var _animationBuff:Animation = _skillEcts[j];
				_animationBuff.interval = BaseUnit.fight_animationInterval;
			}
		}
		
		
		public function get key():String
		{
			return _key;
		}

		public function set key(value:String):void
		{
			_key = value;
			this.pointT = _key;
		}

		
		
		public function showSkillEffect(vo:effectSkillActionVo):void
		{
			var _skillEct:Animation = new Animation();
			_skillEcts.push(_skillEct);
			_skillEct.interval = BaseUnit.fight_animationInterval;
			_skillEct.mouseEnabled = _skillEct.mouseThrough = false;
			
			var dName:String;
			if(vo.effMirror)
				dName = "/up";
			else
			{
				dName = this.direction == 1 ? "/up" : "/down";
			}
			
			var jsonStr:String = "appRes/skillEffect/"+vo.effName+dName +".json";
			Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,skillEctLoaderOver,[jsonStr,_skillEct,vo]),null,null,1,true,FightingScene.figtingModerGroup);
//			trace("加载特效"+jsonStr);
		}
		
		private function skillEctLoaderOver(jsonStr:String,_skillEct:Animation, vo:effectSkillActionVo):void{
			
			if(!scene) return ;
//			trace("播放特效"+jsonStr);
			_skillEct.loadAtlas(jsonStr,null,FightingScene.pushACacheKey(jsonStr));
			
			
			//			_skillEct.scaleX = 1;
			_skillEct.scaleX = vo.effMirror && direction == 2 ? -1 : 1;
			
			if(scene)
			{
				if(vo.effLayer == 1)
					scene.tSkillLayer.addChild(_skillEct);
				else
					scene.bSkillLayer.addChild(_skillEct);
				var pi:Point = BaseUnit.getAnimationMaxSize(jsonStr);
				var frameWidth:Number = pi.x;
				var frameHeight:Number =  pi.y;
				var addx:Number = _skillEct.scaleX == -1 ? frameWidth : 0;
				
				_skillEct.x = this.x - (frameWidth /2) + FightingScene.tileW / 2 + addx;
				var uitem:BaseUnit = scene.getUnitByPoint(this.key);
				if(vo.effPoint == 1 || !uitem)
				{
					_skillEct.y = this.y - (frameHeight /2)+ FightingScene.tileH / 2;
				}
				else if(vo.effPoint == 2)
				{
					_skillEct.y = this.y - uitem.modelH /2 + FightingScene.tileH / 2 - frameHeight /2;
				}
				else if(vo.effPoint == 4)  //头顶
				{
					_skillEct.y = this.y - uitem.modelH + FightingScene.tileH / 2 - frameHeight /2;
				}
				else if(vo.effPoint == 3)  //脚下
				{
					_skillEct.y = this.y + FightingScene.tileH / 2 - frameHeight /2;
				}
			}
			
			
			_skillEct.gotoAndStop(1);
			_skillEct.play();
			_skillEct.on(Event.COMPLETE,this,skillEctEnd,[_skillEct]);
		}
		
		private function skillEctEnd(_skillEct:Animation):void
		{
			_skillEcts.splice(_skillEcts.indexOf(_skillEct),1);
			_skillEct.off(Event.COMPLETE,this,skillEctEnd);
			_skillEct.stop();
			_skillEct.removeSelf();
			_skillEct.destroy();
		}
		
		
		
		
		
		public function addBuff(buffId:String):void
		{
			if(showBuffs.indexOf(buffId) == -1)
			{
				var vo:SkillBuffVo = GameConfigManager.skill_buff_dic[buffId];
				if(!vo)return ;
				showBuffs.push(buffId);
				var _animationBuff:Animation = new Animation();
				_animationBuff.mouseEnabled = _animationBuff.mouseThrough = false;
				
				var jsonStr:String = "appRes/tileBuff/"+vo.effect2+".json";
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,buffDataLoaderOver,[jsonStr,_animationBuff,buffId]),null,null,1,true,FightingScene.figtingModerGroup);
			}
		}
		
		
		private function buffDataLoaderOver(jsonStr:String,_animationBuff:Animation,buffId:String):void{
			
			_animationBuff.loadAtlas(jsonStr,null,FightingScene.pushACacheKey(jsonStr));
			
			var pi:Point = BaseUnit.getAnimationMaxSize(jsonStr);
			var frameWidth:Number = pi.x;
			var frameHeight:Number =  pi.y;
			_animationBuff.name = buffId;
			buffEctSp.addChild(_animationBuff);
			_animationBuff.x = 0 - (frameWidth /2) + FightingScene.tileW / 2;
			_animationBuff.y = 0 - (frameHeight /2)+ FightingScene.tileH / 2;
			_animationBuff.gotoAndStop(1);
			_animationBuff.play();
			trace("添加BUFF成功,id",buffId);
		}
		
		public function deleteAllBuff():void
		{
			for (var i:int = showBuffs.length - 1; i >= 0 ; i--) 
			{
				deleteBuff(showBuffs[i]);
			}
			
			for (var j:int = 0; j < _skillEcts.length; j++) 
			{
				skillEctEnd(_skillEcts[j]);
			}
			_skillEcts = [];
		}
		
		public function deleteBuff(buffId:String):void
		{
			var idx:int = showBuffs.indexOf(buffId);
			if(idx != -1)
			{
				showBuffs.splice( idx , 1);
				
				var _animationBuff:Animation = buffEctSp.getChildByName(buffId) as Animation;
				if(_animationBuff)
				{
					_animationBuff.removeSelf();
					_animationBuff.destroy();
				}
			}
		}
		
		public function bindBuff(obj:Object):void{
			var ar:Array;
			var i:int;
			ar = obj["getBuff"];
			if(ar && ar.length)
			{
				for (i = 0; i < ar.length; i++) 
				{
					addBuff(ar[i]);
				}
			}
			ar = obj["subBuff"];
			if(ar && ar.length)
			{
				for (i = 0; i < ar.length; i++) 
				{
					deleteBuff(ar[i]);
				}
			}
			
		}
		
		
		public function set pointT(v:String):void
		{
//			pointText.text = v;
		}
		
		
		public function get cellType():uint
		{
			return _cellType;
		}
		
		public function set cellType(value:uint):void
		{
			if(_cellType != value)
			{
				leftCellType = _cellType;
				topBg.visible = false;
				_cellType = value;
				topBg.skin = "fightingUI/grid_4.png";
				var bgName:String = "grid_1";
				switch(_cellType)
				{
					case FightingTile.CELLTYPE1:
					{
						bgName = "grid_1";
						break;
					}
					case FightingTile.CELLTYPE2:
					{
						bgName = "grid_2";
						break;
					}	
					case FightingTile.CELLTYPE3:
					{
						bgName = "grid_2_n";
						break;
					}
					case FightingTile.CELLTYPE10:
					{
						bgName = "grid_5";
						break;
					}	
					case FightingTile.CELLTYPE4:
					{
						bgName = "grid_3";
						break;
					}
					case FightingTile.CELLTYPE5:
					{
						bgName = "grid_2";
						break;
					}
					case FightingTile.CELLTYPE6:
					{
						bgName = "grid_2_n";
						break;
					}
					case FightingTile.CELLTYPE7:
					{
						bgName = "grid_3";
						topBg.visible = true;
						break;
					}
					case FightingTile.CELLTYPE8:
					{
						bgName = "grid_2";
						topBg.visible = true;
						break;
					}
					case FightingTile.CELLTYPE9:
					{
						bgName = "grid_1";
						topBg.visible = true;
						topBg.skin = "fightingUI/grid_6.png";
						break;
					}
					case FightingTile.CELLTYPE11:
					{
						bgName = "grid_3";
						break;
					}	
				}
				typeBg.skin = "fightingUI/"+bgName+".png";
//				trace(typeBg.skin);
				typeBg.x = width - typeBg.width >> 1 ;
				typeBg.y = height - typeBg.height >> 1;
				
				topBg.x = width - topBg.width >> 1;
				topBg.y = height - topBg.height >> 1;
				
			}
		}

		override public function destroy(destroyChild:Boolean = true):void {
			this.scene = null;
			Signal.intance.off(FightingManager.FIGHT_VELOCITY_CHANGE,this,velocityChange);
			typeBg = null;
			topBg = null;
			buffEctSp = null;
			_skillEcts = null;
			showBuffs = null;
			
			
			super.destroy(destroyChild);
		}
	}
}