package game.module.fighting.view
{
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameLanguage;
	import game.module.fighting.scene.FightingScene;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * RoundAniCom 战斗波数动画
	 * author:huhaiming
	 * RoundAniCom.as 2018-1-19 下午3:32:21
	 * version 1.0
	 *
	 */
	public class RoundAniCom extends Sprite
	{
		private var _ani:Animation;
		private var _tf:Text;
		private var _target:*;
		private var _callback:Function;
		private static const W:int = 477;
		private static const H:int = 120;
		private static var _instance:RoundAniCom;
		public function RoundAniCom()
		{
			init();
		}
		
		private function init():void{
			_ani = new Animation();
			this.addChild(_ani);
			
			_tf = new Text();
			this.addChild(_tf);
			_tf.color = "#ffffff"
			_tf.font = XFacade.FT_BigNoodleToo;
			_tf.fontSize = 36;			
		}
		
		public function showR(round:int, target:*, callback:Function):void{
			_target = target;
			_callback = callback;
			var str:String = GameLanguage.getLangByKey("L_A_79010")
			_tf.text = str.replace(/{(\d+)}/,round);
			_tf.visible = false;
			var jsonStr:String = "appRes/atlas/effects/fightWave.json";
			_ani.loadAtlas(jsonStr, Handler.create(this,loaderOver,[jsonStr]));
			_tf.x = (W - _tf.textWidth)/2;
			_tf.y = (H - _tf.textHeight)/2;
		}
		
		private function loaderOver():void{
			_tf.visible = true;
			_ani.on(Event.COMPLETE, this, onComplete);
			_ani.play(1, false);
			this.scaleX = 0.3;
			this.alpha = 0;
			Tween.to(this, {alpha:1, scaleX:1},200);
		}
		
		private function onComplete():void{
			Tween.to(this, {alpha:0},200, null, Handler.create(this,done), 1000);
		}
		
		private function done():void{
			if(_callback != null){
				_callback.apply(_target);
				_callback = null;
				_target = null;
			}
			this.removeSelf();
		}
	
		
		public static function showRound(round:int, target:*, callback:Function):void{
			if(!_instance){
				_instance = new RoundAniCom();
			}
			Laya.stage.addChild(_instance);
			_instance.scaleX = 1;
			_instance.x = (Laya.stage.width - W)/2;
			_instance.y = (Laya.stage.height - H)/2
			_instance.showR(round,target, callback);
		}
	}
}