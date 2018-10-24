package game.module.armyGroup.newArmyGroup
{
	import MornUI.armyGroup.newArmyGroup.starItemUI;
	
	import game.common.ToolFunc;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	
	import laya.display.Animation;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.resource.Texture;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	
	/**
	 * 单个星球 
	 * @author hejianbo
	 * 
	 */
	public class StarItem extends starItemUI
	{
		/**星球数据*/
		public var star_data:StarVo;
		/**产出动画*/
		public var ani_output:Animation;
		/**战斗动画*/
		public var ani_fighting:Animation;
		/**产出图片*/
		public var img_output:Image;
		
		/**占领的圆形扩张标记*/
		private var circle_area:Sprite;
		/**绿色*/
		private const COLOR_GREEN:String = "#7aff80";
		/**红色*/
		private const COLOR_RED:String = "#ff7f81";
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		
		public function StarItem()
		{
			super();
		}
		
		public function init(data:StarVo):void {
			star_data = data;
			this.on(Event.CLICK, this, clickHandler);
			setHitArea();
		}
		
		private function clickHandler():void {
			trace(star_data.id);
			Signal.intance.event(ArmyGroupEvent.SELECT_PLANT, [star_data.id]);
		}
		
		/**更新视图*/
		public function updateView(scaleNum):void {
			initRender();
			this.visible = star_data.isServerUpdated;
			if (!star_data.isServerUpdated) return;
			dom_star_bg.skin = star_data.getStarSkinByIcon();
			dom_star_name.text = GameLanguage.getLangByKey(star_data.name) + " LV." + star_data.level;
//			dom_star_name.text = star_data.id;
			
			setStarBelong();
			outputHandler();
			
			if (scaleNum) {
				keepTextClearness(scaleNum);
			}
			
			switch (star_data.getCityState()) {
				// 战斗中(包括未正式开战前的等待)
				case 1:
					fighting();
					break;
				// 保护中
				case 2:
					protecting(star_data.getProtectCountDownTime());
					break;
			}
		}
		
		/**产出标志*/
		private function outputHandler():void {
			if (!star_data.planet_sp) return;
			
			addOutputAni();
			
			if (!img_output) {
				img_output = new Image();
				img_output.anchorX = 0.5;
				img_output.anchorY = 0.5;
				var _url = GameConfigManager.getItemImgPath(star_data.planet_sp.split("=")[0]);
				ToolFunc.loadImag(_url, function(t:Texture){
					img_output.skin = _url;
					img_output.pos((width) / 2, (height) / 2)
//					img_output.pos((width - img_output.width) / 2, (height - img_output.height) / 2)
//					img_output.centerX = 0.5;
//					img_output.centerY = 0.5;
					addChild(img_output);
				});
			}
		}
		
		private function initRender():void {
			dom_title_bg.visible = false;
			dom_protect.visible = false;
			dom_guild_icon.visible = false;
			dom_atk_guild_icon.visible  = false;
			
			if (ani_output) {
				ani_output.stop();
				ani_output.visible = false;
			}
			if (ani_fighting) {
				ani_fighting.stop();
				ani_fighting.visible = false;
			}
		}
		
		/**战斗中*/
		private function fighting():void {
			addFightingAni();
			// 是否在宣战倒计时中
			if (TimeUtil.nowServerTime < star_data.last_fight_time) {
				dom_title.visible = false;
				dom_time.visible = true;
				dom_guide_name.visible = false;
				dom_guide_name.text = star_data.atk_guideName;
				doClearTimerHandler();
				clearTimerHandler = ToolFunc.limitHandler(Math.abs(star_data.last_fight_time - TimeUtil.nowServerTime), function(time) {
					var detailTime = TimeUtil.toDetailTime(time);
					dom_time.text = TimeUtil.timeToText(detailTime);
				}, function() {
					dom_title.visible = true;
					dom_time.visible = false;
					dom_guide_name.visible = false;
					//区分NPC进攻和工会进攻的区别
					if (star_data.isBudui_Atk) {
						dom_title.text = "FIGHTING";
					}else{
						dom_title.text = star_data.atk_guideName;
					}
//					setTitle_bg("2");
					clearTimerHandler = null;
					trace('倒计时结束：：：');
				}, false);
				
			} else  {
//				setTitle_bg("2");
				dom_title.visible = true;
				dom_time.visible = false;
				dom_guide_name.visible = false;
				//区分NPC进攻和工会进攻的区别
				if (star_data.isBudui_Atk) {
					dom_title.text = "FIGHTING";
				}else{
					dom_title.text = star_data.atk_guideName;
				}
			}
			
			//区分NPC进攻和工会进攻的区别
			if (star_data.isBudui_Atk || star_data.isBudui) {
				setTitle_bg("4");
				dom_atk_guild_icon.visible  = false;
//				setTitle_bg("2_2");
			} else{
				if(star_data.isMyGuilde_Atk){
					setTitle_bg("2_2");
				}
				else{
					setTitle_bg("2_1");
				}
				dom_atk_guild_icon.visible  = true;
				GameConfigManager.setGuildLogoSkin(dom_atk_guild_icon, star_data.atk_guideIcon, 0.5);
			}
			
		}
		
		/**保护中*/
		private function protecting(diss_protect_time):void {
			setTitle_bg("3");
			dom_title.visible = true;
			dom_time.visible = false;
			dom_guide_name.visible = false;
			dom_protect.visible = true;
			
			doClearTimerHandler();
			clearTimerHandler = ToolFunc.limitHandler(Math.abs(diss_protect_time), function(time) {
				var detailTime = TimeUtil.toDetailTime(time);
				dom_title.text = TimeUtil.timeToText(detailTime);
			}, function() {
				dom_title_bg.visible = false;
				clearTimerHandler = null;
				trace('倒计时结束：：：');
			}, false);
		}
		
		private function setTitle_bg(skin):void {
			dom_title_bg.visible = true;
			dom_title_bg.skin = "armyGroup/newArmy/bg"+skin+".png";
		}
		
		/**产出动画*/
		public function addOutputAni():void {
			if (ani_output) {
				ani_output.visible = true;
				ani_output.play();
				return;
			}
			var roleAni:Animation = ani_output = createAni("appRes/effects/outputAni.json");
//			roleAni.pos((width - 128) / 2, (height - 128) / 2);
			roleAni.pos(-20, -20);
			addChild(roleAni);
		}
		
		/**战斗动画*/
		public function addFightingAni():void {
			if (ani_fighting) {
				ani_fighting.visible = true;
				ani_fighting.play();
				return;
			}
			var roleAni:Animation = ani_fighting = createAni("appRes/effects/fightingAni.json");
			roleAni.pos((width - 250) / 2, (height - 300) / 2);
			
			addChild(roleAni);
		}
		
		private function createAni(url:String):Animation {
			var roleAni:Animation = new Animation();
			roleAni.loadAtlas(url, Handler.create(this, function(){
				roleAni.play();
			}));
			
			return roleAni;
		}
		
		/**星球被公会所属*/
		private function setStarBelong():void {
			circle_area && circle_area.graphics.clear();
			if (star_data.guild_id == "" || star_data.isBudui) {
				dom_star_name.color = "#fff";
				dom_guild_icon.visible = false;
				return;
			}
			
			dom_guild_icon.visible  = true;
			GameConfigManager.setGuildLogoSkin(dom_guild_icon, star_data.guideIcon, 0.5);
			// 星球名和公会名共用一个Label
			dom_star_name.text = dom_star_name.text + "\n" + star_data.guideName;
			
			circle_area = circle_area || new Sprite();
			circle_area.alpha = 0.2;
			addChildAt(circle_area, 0);
			
			var color:String = star_data.isMyGuilde ? COLOR_GREEN : COLOR_RED;
			dom_star_name.color = color;
			circle_area.graphics.drawCircle(width / 2, height / 2, 324, color);
		}
		
		/**设置可点区域*/
		private function setHitArea():void {
			var g:Graphics = new Graphics();
			g.drawCircle(width / 2, height / 2, width / 2, "#f60");
			var hitArea:HitArea = new HitArea();
			hitArea.hit = g;
			this.hitArea = hitArea;
		}
		
		public function show():void {
			visible = true;
			updateView();
		}
		
		public function hide():void {
			visible = false;
			ani_output && ani_output.stop();
			ani_fighting && ani_fighting.stop();
		}
		
		public function keepTextClearness(scaleNum:Number):void {
			if (scaleNum < 0.4) scaleNum = 0.4;
			dom_title_bg.scale(1 / scaleNum, 1 / scaleNum);
			dom_info_box.scale(1 / scaleNum, 1 / scaleNum);
			if (img_output) {
				img_output.scale(1 / scaleNum, 1 / scaleNum);
			}
			if (ani_output) {
				ani_output.scale(1 / scaleNum, 1 / scaleNum);
			}
			if (ani_fighting) {
				ani_fighting.pos(-250, -250);
				ani_fighting.scale(1 / scaleNum + 1, 1 / scaleNum + 1);
			}
		}
		
		private function doClearTimerHandler():void {
			clearTimerHandler && clearTimerHandler();
			clearTimerHandler = null;
		}
		
		override public function destroy(destroyChild:Boolean=true):void {
			super.destroy();
			doClearTimerHandler();
			star_data = null;
		}
	}
}