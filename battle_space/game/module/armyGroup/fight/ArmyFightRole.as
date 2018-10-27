package game.module.armyGroup.fight
{
	import game.common.ImageFont;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.module.mainScene.HpCom;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.net.Loader;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;

	/**
	 * ArmyFightRole 战斗动画表示组件
	 * author:huhaiming
	 * ArmyFightRole.as 2017-11-28 下午4:20:39
	 * version 1.0
	 *
	 */
	public class ArmyFightRole
	{
		private var _ui:*;
		private var _data:Object;
		private var _per:Number;
		private var _ani:Animation;
		private var _hpCom:HpCom;
		private var _nameTF:Label;
		private var _key:String;
		private var _curAct:String = '';
		private var _curIndex:int = 0;
		private var _times:int;
		/**飙血基础位置*/
		private static const BASE_X:Number = 50;
		private static const BASE_Y:Number = -50;
		public static const IDLE:String = "daiji";
		public static const ATTACK:String = "gongji";
		public static const DIE:String = "siwang"
		public function ArmyFightRole(ui:*, key:String = "gf_attacker")
		{
			this._ui = ui;
			_key = key;
			if(_key == "gf_attacker"){
				_ui.bg.skin = "armGroupFight/bg5_1.png"
			}
			
			_ui.addChild(ani);
			//test
			ani.pos(-860, -520);
			
			_hpCom = new HpCom();
			_ui.addChild(_hpCom);
			_hpCom.pos(40,-30);
			
			_nameTF = new Label();
			this._ui.addChild(_nameTF);
			_nameTF.font = XFacade.FT_Futura;
			_nameTF.fontSize = 18;
			_nameTF.color = "#ffffff";
			_nameTF.pos(40,-46);
		}
		
		/**
		 * 动画表现
		 * @param data,[1,117,16236,16236,"saygoodbye"], 0-失败,1胜利 丢失血量
		 * */
		public function format(data:Object, times:int):void{
			this._data = data;
			_times = times;
			_curIndex = 0;
			if(data){
				_per = (data[1]/times);
				_ani.visible = true;
				this._nameTF.visible = true;
				this._hpCom.visible = true;
				showAction(IDLE)
				ani.play();
				//test
				_hpCom.update(data[2]*100/data[3]);
				this._nameTF.text = (data[4] || GameLanguage.getLangByKey("L_A_20903"))
			}else{
				_ani.stop();
				_ani.visible = false;
				this._nameTF.visible = false;
				this._hpCom.visible = false;
			}
		}
		
		public function showAction(act:String):void{
			if(_curAct != act){
				ani.clear();
				ani.loadAtlas("appRes/heroModel/"+_key+"/"+act+".json");
				ani.play(0,false);
			}
		}
		
		//动画表现
		public function doAction():void{
			if(_data){
				showAction(IDLE);
				var num:Number = _per*(1+Math.random()*0.1);//10%的浮动
				var sp:Sprite = ImageFont.createBitmapFont(Math.round(num)+"","redMax");
				var per:Number = _data[1]/_times;
				_curIndex ++;
				_hpCom.update((_data[2] - per*_curIndex)*100/_data[3]);
				_ui.addChild(sp);
				sp.pos(BASE_X, BASE_Y);
				var targetY:Number = BASE_Y - 100;
				var targetX:Number = Math.round(BASE_X + Math.random()*20-10)
				Tween.to(sp, {x:targetX,y:targetY}, 800, null, Handler.create(this, onHpFloatOver, [sp]));
			}
		}
		
		//退场动画
		public function out():void{
			if(_data){
				if(_data[0] == "0"){
					trace("die-------------------------------------------")
					showAction(DIE)
				}else{
					showAction(IDLE)
				}
			}
		}
		
		public function reset():void{
			this._data = null;
			if(_ani){
				_ani.clear();
				Loader.clearRes("appRes/heroModel/" + _key + "/" + IDLE+".json");
				Loader.clearRes("appRes/heroModel/" + _key + "/" + ATTACK + ".json");
				Loader.clearRes("appRes/heroModel/" + _key + "/" + DIE+".json");
				_ani.visible = false;
			}
			_ani.visible = false;
			this._nameTF.visible = false;
			this._hpCom.visible = false;
		}
		
		private function onHpFloatOver(sp:Sprite):void{
			sp.parent.removeChild(sp);
			Pool.recover(ImageFont.ImageFont_sign,sp);
		}
		
		private function get ani():Animation{
			if(!_ani){
				_ani = new Animation();
			}
			return _ani;
		}
	}
}