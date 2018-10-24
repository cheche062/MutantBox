/***
 *作者：罗维
 */
package game.global.fighting
{
	import game.common.FilterTool;
	import game.common.IHpProgressBar;
	import game.common.ImageFont;
	import game.common.MaskProgressBar;
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.event.Signal;
	import game.global.vo.BuffEffectVo;
	import game.global.vo.HitAreaData;
	import game.global.vo.SkillBuffVo;
	import game.module.fighting.cell.BuffCell;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.scene.FightingScene;
	import game.module.fighting.view.FightingView;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.media.Sound;
	import laya.media.SoundChannel;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.ui.ProgressBar;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Tween;
	
	public class BaseUnit extends Sprite
	{
		public static const animationInterval:Number = 73;

		/**特殊道具*/
		public static const SPECIAL_ITEM:int = 3006;
		public function get holdingPi():Point
		{
			if(!_holdingPi) _holdingPi = new Point();
			return _holdingPi;
		}

		public function set holdingPi(value:Point):void
		{
			_holdingPi = value;
		}

		public static function get fight_animationInterval():Number{
			return Math.ceil(animationInterval / FightingManager.velocity);
		}
		
		public static const ACTION_HOLDING:String = "daiji";   //待机
		public static const ACTION_ATTACK:String = "gongji";   //攻击
		public static const ACTION_DIE:String = "siwang";    //死亡
		public static const ACTION_MOVE:String = "yidong";     //移动
		public static const ACTION_STRIKE:String = "shouji";     //受击
		public static const ACTION_SHOW:String = "chuchang";  //出场
		
		public var bEffLayer:Sprite = new Sprite();  //底部特效层
		public var skinLayer:Sprite = new Sprite(); //皮肤层，显示具体建筑对象
		public var effLayer:Sprite = new Sprite(); //特效层
		private var _selectImg:Image;
		
		public var hpBarBg:Box = new Box();
		public var fyIMG:Image = new Image();
		public var campImg:Image = new Image();
		public var hpBar:MaskProgressBar = new MaskProgressBar();
		private var _buffIconList:List = new List();
		
		public var hpLbl:Label = new Label();
		
		public var iHpBar:IHpProgressBar;
		
		public var scene:FightingScene;
		
		private var _action:String;
		private var _hander:Handler;
		private var _animation:Animation;
		private var imgHitArea:HitArea;
		private var sound:SoundChannel;
		public var modelH:Number = 0;
		private var _holdingPi:Point = new Point();
		private var _data:fightUnitData;
		private var _buffList:Object = {};
		private var _buffIds:Array = [];
		
		public function BaseUnit()
		{
			super();
			
			addChild(bEffLayer);
			addChild(skinLayer);
			addChild(effLayer);
//			effLayer.addChild(hpBar);
//			
			
			this.size(1,1);
			
			effLayer.addChild(hpBarBg);
//			hpBarBg.skin = "fightingUI/hpBarBg.png";
//			hpBarBg.addChild(hpBar);
//			hpBarBg.size(109,8);
			hpBarBg.size(138,27);
			
			fyIMG.skin = "fightingUI/hpbar_defence.png";
			hpBarBg.addChild(fyIMG);
			fyIMG.size(hpBarBg.width,hpBarBg.height);
			fyIMG.x = 15
			
			hpBarBg.addChild(campImg);
			campImg.pos(-14,-10);
			
			var hpBgIMG:Image = new Image("fightingUI/hpBarBg.png");
			hpBarBg.addChild(hpBgIMG);
			hpBgIMG.pos(23,10);
			hpBgIMG.addChild(hpBar);
			hpBar.skin = "fightingUI/hpBar.png";
			hpBar.x = 2;
			hpBar.y = 1;
			
			
			hpLbl.size(hpBgIMG.width + 50 , hpBgIMG.height);
			hpLbl.fontSize = 20;
			hpLbl.font = XFacade.FT_Futura;
			hpLbl.align = "center";
			hpLbl.color = "#ffffff";
			hpLbl.x = -25;
			hpLbl.y = - 20;
//			hpBgIMG.addChild(hpLbl);
			
			
			effLayer.addChild(_buffIconList);
			_buffIconList.itemRender = BuffCell;
			_buffIconList.array = [];
			_buffIconList.repeatX = 3;
			_buffIconList.repeatY = 1;
			
			this.bEffLayer.mouseEnabled = this.bEffLayer.mouseThrough = false;
			this.skinLayer.mouseEnabled = this.skinLayer.mouseThrough = false;
			this.effLayer.mouseEnabled = this.effLayer.mouseThrough = false;
			this.defense = false;
			
			
			Signal.intance.on(FightingManager.FIGHT_VELOCITY_CHANGE,this,velocityChange);
		}
		
		private function velocityChange(e:Event):void
		{
			if(_animation)
			{
				_animation.interval = fight_animationInterval;
			}
			
			if(_buffList)
			{
				for(var k:* in _buffList) 
				{
					var _animationBuff:Animation = _buffList[k];
					_animationBuff.interval = fight_animationInterval;
				}
			}
		}
		
		
		public function set defense(v:Boolean):void
		{
			this.fyIMG.visible = v;
		}
		
		
		private var _enabled:Boolean;
		public function get selectImg():Image
		{
			if(!_selectImg)
			{
				_selectImg = new Image();
				_selectImg.skin = "fightingUI/select_arrow.png";
			}
			
			return _selectImg;
		}


		public function get isDie():Boolean
		{
			return data && !data.hp;
		}
		
		//死亡标记 
		public var dieTag:Boolean = false;
		
		public function set enabled(b:Boolean):void
		{
			if(_enabled != b)
			{
				this.mouseEnabled = this.mouseThrough = b;
				
				if(b)
				{
					this.on(Event.MOUSE_DOWN,this,thisDown);
				}else
				{
					this.off(Event.MOUSE_DOWN,this,thisDown);
				}
			}
		}
		
		private function thisDown(e:Event):void
		{
			if(scene)
				scene.selectUnitFun(this,e);
		}
		
	
		public function set buffIds(value:Array):void
		{
			_buffIds = value;
			
			
			var f:Function = function(v1:Object,v2:Object):Number{
				
				var vo1:SkillBuffVo = GameConfigManager.skill_buff_dic[v1.buffId];
				var vo2:SkillBuffVo = GameConfigManager.skill_buff_dic[v2.buffId];
				
				if(vo1.order == vo2.order)
					return 0;
				return vo1.order > vo2.order ? 1:-1;
			};
			_buffIds.sort(f);
			_buffIconList.array = value;
			
			var cpIds:Array = [];
			for (var i:int = 0; i < _buffIds.length; i++) 
			{
//				cpIds.push(_buffIds[i]["buffId"]);
				var buffvo:SkillBuffVo = GameConfigManager.skill_buff_dic[_buffIds[i]["buffId"]];
				for (var z:int = 0; z < buffvo.buffEffects.length; z++) 
				{
					var bev:BuffEffectVo = buffvo.buffEffects[z];
					var bk:String = getBuffEctKey(buffvo,bev);
					cpIds.push(bk);
				}
			}
			
			
			for (var key:* in _buffList) 
			{
				var key2:String = String(key);
				if(cpIds.indexOf(key2) == -1)
				{
					var _animationBuff:Animation = _buffList[key2];
					_animationBuff.stop();
					_animationBuff.removeSelf();
					delete _buffList[key2];
				}
			}
		}
		
		
		private function getBuffEctKey(buffvo:SkillBuffVo,bev:BuffEffectVo):String{
			return buffvo.buff_id + "_" + bev.special;
		}
		
		public function showBuff(buffvo:SkillBuffVo):void{
			if(buffvo)
			{
//				trace("show buff",buffvo.buff_id);				
				for (var i:int = 0; i < buffvo.buffEffects.length; i++) 
				{
					var bev:BuffEffectVo = buffvo.buffEffects[i];
					
					var bk:String = getBuffEctKey(buffvo,bev);
					
					if(_buffList[bk])
					{
						buffDataLoaderOver( bev,buffvo,_buffList[bk],bev.getEffectByDir(_data.direction));
						continue;
					}
					var _animationBuff:Animation = new Animation();
					_animationBuff.interval = fight_animationInterval;
					_buffList[bk] = _animationBuff;
					_animationBuff.mouseEnabled = _animationBuff.mouseThrough = false;
					var jsonUrl:String = bev.getEffectByDir(_data.direction);
					Laya.loader.load([{url:jsonUrl,type:Loader.ATLAS}],Handler.create(this,buffDataLoaderOver,[bev,buffvo,_animationBuff,jsonUrl]),null,null,1,true,FightingScene.figtingModerGroup);
						
				}	
			}
		}
		
		
		
		
		private function buffDataLoaderOver(bev:BuffEffectVo,buffvo:SkillBuffVo,_animationBuff:Animation,jsonUrl:String):void{
			if(isdestroy)return ;
			_animationBuff.loadAtlas(jsonUrl,null,FightingScene.pushACacheKey(jsonUrl));
		
			
			var pi:Point = getAnimationMaxSize(jsonUrl);
			var frameWidth:Number = pi.x;
			var frameHeight:Number =  pi.y;
			
			if(_data.direction == 1)
			{
				if(!bev.up)
					effLayer.addChild(_animationBuff);
				else
					bEffLayer.addChild(_animationBuff);
			}else
			{
				if(!bev.down)
					effLayer.addChild(_animationBuff);
				else
					bEffLayer.addChild(_animationBuff);
			}
			
			_animationBuff.x = 0 - (frameWidth /2) + FightingScene.tileW / 2;
			
			if(bev.cType == 0 || bev.cType == 1)  //身子中间
			{
//				_animationBuff.y = 0 - (frameHeight /2) + FightingScene.tileH / 2  - modelH / 2; 
				_animationBuff.y = 0 - modelH /2 + FightingScene.tileH / 2 - frameHeight /2;
			}
			if(bev.cType == 2 || bev.cType == 3)  //头顶
			{
				_animationBuff.y = 0 - modelH + FightingScene.tileH / 2 - frameHeight /2;
			}
			if(bev.cType == 4 || bev.cType == 5)  //脚下
			{
				_animationBuff.y = 0 + FightingScene.tileH / 2 - frameHeight /2;
			}
//			_animationBuff.y = 0 - (frameHeight /2)+ FightingScene.tileH / 2 - 100;
			_animationBuff.gotoAndStop(1);
			_animationBuff.play();
			_animationBuff.on(Event.COMPLETE,this,buffframeEnd,[bev,buffvo,_animationBuff]);
		}
		
		private function buffframeEnd(bev:BuffEffectVo,buffvo:SkillBuffVo,_animationBuff:Animation):void
		{
			_animationBuff.off(Event.COMPLETE,this,buffframeEnd);
			if(bev.cType && (bev.cType % 2))
			{
				return ;
			}
			_animationBuff.stop();
			_animationBuff.removeSelf();
			var bk:String = getBuffEctKey(buffvo,bev);
			delete _buffList[bk];
		}
		
		
		
		
		

		public function get data():fightUnitData
		{
			return _data;
		}
		
		public function set data(value:fightUnitData):void
		{
			if(_data != value)
			{
				modelH = 0;
				_data = value;
				if(!_data)return ;
				
				dieTag = false;
				hpBarBg.visible = hpBar.visible = !_data.unitVo.isBuilding;
				
				if(_data.unitVo.isBoss)
				{
					var fightingV:FightingView = ModuleManager.intance.getModule(FightingView);
					if(fightingV)
					{
						iHpBar = fightingV.rightTopView1.showBoss(_data.unitVo);
					}
				}
				if(_data.unitVo.isItem && _data.unitVo.unit_id != SPECIAL_ITEM)
				{
					hpBarBg.visible = hpBar.visible = false;
				}
				
				hpBar.setHpValue(_data.hp , _data.maxHp,false);
				hpLbl.text = _data.hp + "/" + _data.maxHp;
				
				iHpBar && iHpBar.setHpValue(_data.hp , _data.maxHp,false);
//				var jsonStr:String = "appRes/heroModel/"+_data.unitVo.model+(_data.direction == 1 ?"/up/":"/down/") +ACTION_HOLDING+".json";
				var jsonStr:String = _data.unitVo.getModel( _data.direction , ACTION_HOLDING, _data.skin);
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,loaderOver2,[jsonStr]),null,null,1,true,FightingScene.figtingModerGroup);
			
				campImg.skin = "common/icons/camp_"+_data.unitVo.camp+".png";
			}
			trace("set data >>>>>>>>>>>>", _data)
		}
		
		
		private function loaderOver2(jsonStr:String):void
		{
			if(isdestroy)return ;
			
			var pii:Point = getAnimationSize(jsonStr);
			var pii2:Point = getAnimationMaxSize(jsonStr);
			
//			if(!holdingPi)trace("holdingPi is null");
//			if(!pii2)trace("pii2 is null");
//			if(!pii)trace("pii is null");
			
			holdingPi.x = 0 - (pii2.x /2) + FightingScene.tileW / 2;
			holdingPi.y = 0 - (pii2.y /2)+ FightingScene.tileH / 2;
//			hpBarBg.y = 0 - pii2.y / 2 + pii.y - hpBarBg.height + FightingScene.tileH / 2 - 20; 
//			
//			modelH = (0 - hpBarBg.y) - hpBarBg.height - 20 + FightingScene.tileH / 2;
			
			if(this.data.direction == 1 && this.data.unitVo.up)
				modelH =  this.data.unitVo.up;
			if(this.data.direction == 2 && this.data.unitVo.down)
				modelH =  this.data.unitVo.down;
			if(!modelH)
				modelH = pii2.y / 2  - pii.y ;
			bindHpBarPi();
		}
		
		
		public function bindHpBarPi():void
		{
			hpBarBg.x = 0 - hpBarBg.width / 2 + FightingScene.tileW / 2;
			hpBarBg.y = 0 - modelH + FightingScene.tileH / 2 - hpBarBg.height - 20;
			_buffIconList.x = hpBarBg.x;
			_buffIconList.y = hpBarBg.y - 30 - 5;
		}
		
		public function changeHp():void
		{
//			hpBar.visible = true;
			hpBar.setHpValue(_data.hp , _data.maxHp , true);
			hpLbl.text = _data.hp + "/" + _data.maxHp;
			iHpBar && iHpBar.setHpValue(_data.hp , _data.maxHp , true);
			//this.timer.once(300,this,hideHp);
		}
		
//		private function hideHp():void
//		{
//			hpBar.visible = false;
//		}
		
		
		public function rebirth(newUID:Number,newHP:Number ,newMaxHp:Number,skillId:String = "" ,hander:Handler = null , showAct:String = null ):void{
			if(!showAct)showAct = "chuchang001";
			var nD:fightUnitData = new fightUnitData();
			nD.unitId = newUID;
			nD.hp = newHP;
			nD.maxHp = newMaxHp;
			nD.showPointID = _data.showPointID;
			nD.direction = _data.direction;
			if(skillId && skillId.length)
				nD.skillVos = FightingManager.intance.getSkillVos(skillId);
			this._data = nD;
			changeHp();
			this.playAction(showAct,hander);
		}
		
		
		/**
		 *飙血 
		 *hpAr 血量变化数组
		 *type 飙血类型  1 掉血 2加血 .... 
		 *waitFrame 播放帧间隔
		 */
		
		public function floatingHp(hpAr:Array , type:uint = 1 , waitTimer:uint = 500 ):void
		{
			if(!hpAr.length)
			{
				return ;
			}
			
			var hpstr:String = hpAr.shift();
//			this.data.hp -= Number(hpstr);
			
			var goPoint:Point = new Point(this.x,this.y);
//			goPoint = this.localToGlobal(goPoint);
			goPoint.x  += FightingScene.tileW / 2;
			goPoint.y  -= 50;
			
			var fNames:Object = {
				1:"orangeMin",
				2:"redMax",
				3:"greenMin",
				4:"greenMax",
				5:"lanMax"
			};
			
			var toPoint:Point = new Point(goPoint.x ,goPoint.y);
			
		
			var n:Number = Math.floor(1+(30-1+1)*Math.random())
			
			toPoint.x += this.data.direction == 1 ? 0 - n : n;
			toPoint.y -= 100;
//			trace("----",goPoint.x,goPoint.y , toPoint.x , toPoint.y);
//			if(type == 2)
//				hpstr = "c"+hpstr;
			var jj:Number = -7;
			if(type == 2 || type == 4)
				jj = -8;
			ImageFont.intance.floatingHp(hpstr,fNames[type],goPoint,toPoint,jj);
			this.timer.once(waitTimer,this,floatingHp,[hpAr,type,waitTimer]);
			
		}
		
		public function dodged(hander:Handler = null ):void
		{
			var pii:Point = new Point(x,y);
			this.x += this.data.direction == 1 ? -30:30;
			this.y += 5;
			this.timer.once(
				Math.ceil(800 / FightingManager.velocity)
				,this,dodgedOver,[pii,hander]);
		}
		
		private function dodgedOver(pii:Point,hander:Handler = null ):void{
			this.x = pii.x;
			this.y = pii.y;
			if(hander)
				hander.run();
		}
		
		public function get Action():String{
			return _action;
		}
		
		public function get loop():Boolean{
			return _action == ACTION_HOLDING;
		}
		
		
		public function playAction(v:String, hander:Handler  = null):void
		{
			if(!this || !this.skinLayer)
				return ;
			
			_hander = hander;
			if(_action != v)
			{
				if(sound){
					sound.stop();
					sound = null;
				}
				_action = v;
				
				if(data.unitVo.isItem && _action == ACTION_SHOW &&  data.unitVo.unit_id != SPECIAL_ITEM) _action = ACTION_HOLDING;
				
				skinLayer.filters = (_action == BaseUnit.ACTION_STRIKE || _action == BaseUnit.ACTION_DIE) ?[FilterTool.redFilter] : null;
				
				
				var mp3Url:String = ResourceManager.getUnitMp3(data.unitId,_action);
				if(mp3Url)
				{
					mp3Url = ResourceManager.getSoundUrl(mp3Url,"fighting/action");
					if(_action == BaseUnit.ACTION_MOVE)
					{
						sound = SoundMgr.instance.playSound(mp3Url,Number.MAX_VALUE);
					}else
					{
						SoundMgr.instance.playSound(mp3Url);
					}
				}
				
				
				if(!_animation)
				{
					_animation = new Animation();
					skinLayer.addChild(_animation);
					_animation.mouseEnabled = _animation.mouseThrough = false;
					_animation.interval = fight_animationInterval;
					_animation.on(Event.COMPLETE,this,frameEnd);
				}
//				_animation.off(Event.COMPLETE,this,frameEnd);
				
				var jsonStr:String = _data.unitVo.getModel(_data.direction,_action, _data.skin);
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,loaderOver,[jsonStr]),null,null,1,true,FightingScene.figtingModerGroup);
			}else{
				_animation.gotoAndStop(1);
				_animation.play(0,loop);
//				if(hander)
//				{
//					_animation.on(Event.COMPLETE,this,frameEnd);
//				}
			}
		}

		
		private var aaaa:Sprite;
		private function loaderOver(... args):void
		{
			if(isdestroy)return ;
			var jsonStr:String = args[0];
			var jsonStr2:String = _data.unitVo.getModel(_data.direction,_action, _data.skin);
			if(jsonStr != jsonStr2)
				return ;
			if(!args[1])
			{
				trace(1,"模型加载失败",jsonStr);
				if(_hander)
				{
					
					var copyHander:Handler =  _hander;
					_hander = null;
					copyHander.run();
					copyHander.clear();
					copyHander = null;
				}
					
			}
			
			_animation.loadAtlas(jsonStr,null,FightingScene.pushACacheKey(jsonStr));
			_animation.gotoAndStop(1);
			_animation.play(0,loop);
			var jsonData:Object = Loader.getRes(jsonStr);
			if(jsonData)
			{
				
				var pi:Point = getAnimationMaxSize(jsonStr);
				var frameWidth:Number = pi.x;
				var frameHeight:Number =  pi.y;
				_animation.x = 0 - (frameWidth /2) + FightingScene.tileW / 2;
				_animation.y = 0 - (frameHeight /2)+ FightingScene.tileH / 2;
				
				
//				if(!aaaa)
//				{
//					var hitP:HitAreaData = _data.unitVo.hitAreaPoints;
//					aaaa = new Sprite();
//					aaaa.cacheAsBitmap = true;
//					aaaa.graphics.drawPoly(hitP.beginX + holdingPi.x ,
//											hitP.beginY + holdingPi.y ,
//											hitP.pointS,"#f8ffff");
//					aaaa.graphics.drawPoly(FightingScene.tileW / 2, 0,
//						[
//							FightingScene.tileW / 2 , FightingScene.tileH / 2,
//							0,FightingScene.tileH,
//							0 - FightingScene.tileW / 2 , FightingScene.tileH / 2,
//							0 , 0
//						],"#f8ffff");
//					addChild(aaaa);
//				}
				
//				if(!imgHitArea && _data.unitVo.hitAreaPoints && Action == ACTION_HOLDING){
				if(!imgHitArea && _data.unitVo.hitAreaPoints){
					var hitP:HitAreaData = _data.unitVo.hitAreaPoints;
					imgHitArea = new HitArea();
					imgHitArea.hit.drawPoly(
						hitP.beginX + holdingPi.x ,
						hitP.beginY + holdingPi.y ,
						hitP.pointS,"#f8ffff");
					imgHitArea.hit.drawPoly(FightingScene.tileW / 2, 0,
						[
							FightingScene.tileW / 2 , FightingScene.tileH / 2,
							0,FightingScene.tileH,
							0 - FightingScene.tileW / 2 , FightingScene.tileH / 2,
							0 , 0
						],"#f8ffff");
					this.hitArea = imgHitArea;
				}
				
			}
			
//			var pi:Point = _data.unitVo.getOffsetPoint(_action,_data.direction);
			
			_animation.gotoAndStop(1);
			_animation.play(0,loop);
			
			if(modelH < 1){
				loaderOver2()
			}
//			if(_hander)
//			{
//				_animation.on(Event.COMPLETE,this,frameEnd);
//			}
		}
		
		public function frameEnd():void
		{
//			_animation.off(Event.COMPLETE,this,frameEnd);
			if(_hander)
			{
				
				var copyHander:Handler =  _hander;
				_hander = null;
				copyHander.run();
				copyHander.clear();
				copyHander = null;
			}else
			{
				if(Action != ACTION_HOLDING) playAction(ACTION_HOLDING);
			}
		}
		
		
		public function stopFrame():void
		{
//			_animation.off(Event.COMPLETE,this,frameEnd);
			_hander = null;
		}
		
		
		
		public function get showPointID():String
		{
			return data.showPointID;
		}
		
		public function set showPointID(value:String):void
		{
			if(data.showPointID != value)
			{
				data.showPointID = value;
			}
		}
		
		private var _select:Boolean ;
		public function set select(v :Boolean):void{
			if(_select != v)
			{
				_select = v;
				if(_select)
				{
					this.addChild(selectImg);
					selectImg.x = hpBarBg.x + hpBarBg.width / 2 - selectImg.width / 2;
					selectImg.y = hpBarBg.y - hpBarBg.height - selectImg.height ;
					playSelectImg();
				}
				else
					selectImg.removeSelf();
				
				
			}
		}
		
		private function playSelectImg(down:Boolean = true):void{
			if(!this)return ;
			if(!selectImg.displayedInStage) return ;
			
			Tween.to(selectImg,{y: down ? selectImg.y + 20 : selectImg.y - 20},300,null,Handler.create(this,playSelectImg,[!down]));
		}
		
		
		public function get select():Boolean
		{
			return _select;
		}
		
		//沉默
		public function get silence():Boolean
		{
			if(!_buffIds || !_buffIds.length) return false;
			for (var i:int = 0; i < _buffIds.length; i++) 
			{
				var buffId:Number = _buffIds[i].buffId;
				var vo:SkillBuffVo = GameConfigManager.skill_buff_dic[buffId];
				if(vo && vo.buff_type == 34)
					return true;
			}
			return false;
		}
		
		//眩晕
		public function get vertigo():Boolean
		{
			if(!_buffIds || !_buffIds.length) return false;
			for (var i:int = 0; i < _buffIds.length; i++) 
			{
				var buffId:Number = _buffIds[i].buffId;
				var vo:SkillBuffVo = GameConfigManager.skill_buff_dic[buffId];
				if(vo && vo.buff_type == 36)
					return true;
			}
			return false;
		}
		
		
		//禁锢
		public function get imprisoned():Boolean
		{
			if(!_buffIds || !_buffIds.length) return false;
			for (var i:int = 0; i < _buffIds.length; i++) 
			{
				var buffId:Number = _buffIds[i].buffId;
				var vo:SkillBuffVo = GameConfigManager.skill_buff_dic[buffId];
				if(vo && vo.buff_type == 33)
					return true;
			}
			return false;
		}

		public static function getAnimationMaxSize(url:String):Point{
			var rt:Point = new Point();
			var jsonData:Object = Loader.getRes(url);
			//trace("jsonData:", jsonData);
			if(jsonData && jsonData.frames)
			{
				for each (var obj:Object in jsonData.frames) 
				{
					
					if(obj.sourceSize)
					{
						rt.x = obj.sourceSize.w;
						rt.y = obj.sourceSize.h;
						return rt;
					}
				}
				
			}
			return rt;
		}
		
		public static function getAnimationSize(url:String):Point{
			var rt:Point = new Point();
			var jsonData:Object = Loader.getRes(url);
			if(jsonData && jsonData.frames)
			{
				for each (var obj:Object in jsonData.frames) 
				{
					if(obj.spriteSourceSize)
					{
						rt.x = obj.spriteSourceSize.x;
						rt.y = obj.spriteSourceSize.y;
						return rt;
					}
				}
				
			}
			return rt;
		}
		
		
		private var isdestroy:Boolean;
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy baseUnit");
			isdestroy = true;
			this.data = null;
			this.timer.clearAll(this);
			if(_animation){
				_animation.off(Event.COMPLETE,this,frameEnd);
				_animation.stop();
				_animation.removeSelf();
				_animation.destroy();
				_animation = null;
			}
			
			if(_buffList)
			{
				for(var k:* in _buffList) 
				{
					var _animationBuff:Animation = _buffList[k];
					_animationBuff.stop();
					_animationBuff.removeSelf();
					_animationBuff.destroy();
					delete _buffList[k];
				}
				_buffList = null;
			}
			this.off(Event.MOUSE_DOWN,this,thisDown);
			Signal.intance.off(FightingManager.FIGHT_VELOCITY_CHANGE,this,velocityChange);
			
			_hander = null;
			_buffIds = null;
			iHpBar = null;
			scene = null;
			this.hitArea = null;
			holdingPi = null;
			imgHitArea = null;
			
			hpBarBg.removeSelf();
			hpBarBg.destroy(destroyChild);
			hpBarBg = null;
			
			bEffLayer.removeSelf();
			bEffLayer.destroy();
			bEffLayer = null;
			
			skinLayer.removeSelf();
			skinLayer.destroy();
			skinLayer = null;
			
			effLayer.removeSelf();
			effLayer.destroy();
			effLayer = null;
			
			fyIMG.removeSelf();
			fyIMG.destroy();
			fyIMG = null;
			
			if(_selectImg)
			{
				_selectImg.removeSelf();
				_selectImg.destroy();
				_selectImg = null;
			}
			if(aaaa)
			{
				aaaa.removeSelf();
				aaaa.destroy();
				aaaa = null;
			}
			
			
			hpBar.removeSelf();
			hpBar.destroy();
			hpBar = null;
			
			_buffIconList.removeSelf();
			_buffIconList.destroy();
			_buffIconList = null;
			
			hpLbl.removeSelf();
			hpLbl.destroy();
			hpLbl = null;
			
		
			
			if(sound)
			{
				sound.stop();
				sound = null;
			}
			
			super.destroy(destroyChild);
		}
		
	}
}