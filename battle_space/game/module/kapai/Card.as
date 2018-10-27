package game.module.kapai
{
	import MornUI.kapai.CardUI;
	
	import laya.display.Animation;
	import laya.utils.Handler;
	
	public class Card extends CardUI
	{
		/**光圈动画对象池*/
		private static const lightAniPool:Array = [];
		/**闪卡对应背景皮肤id*/
		private static const FLASH_CARD:Object = {
			29: 6,
			30: 13,
			31: 14,
			32: 21,
			33: 28,
			34: 15
		};
		/**动画*/
		private var dom_animation:Animation
		
		public function Card(id:int)
		{
			super();
			init(id);
		}
		
		public function init(id:int) {
			var isFlash:Boolean = !!FLASH_CARD[id];
			recoverLightAni();
			if (isFlash) {
				id = FLASH_CARD[id];
				dom_animation = createLightAni();
				this.addChild(dom_animation);
			}
			
			dom_img.skin = "appRes/card/" + id + ".png";
		}
		
		/**创建卡牌光圈动画*/
		private function createLightAni():Animation {
			var roleAni:Animation = (lightAniPool.length > 0) ? lightAniPool.pop() : new Animation();
			var url = "appRes/effects/lizi.json";
			roleAni.loadAtlas(url, Handler.create(null, function(){
				roleAni.play();
			}));
			roleAni.pos(-32, -35);
			roleAni.interval = 70;
			
			return roleAni;
		}
		
		/**回收*/
		private function recoverLightAni():void {
			if (!dom_animation) return;
			dom_animation.stop();
			lightAniPool.push(dom_animation);
			this.removeChild(dom_animation);
			dom_animation = null;
		}
		
		public static function reset():void {
			lightAniPool.forEach(function(item:Animation) {
				item.destroy();
			});
			lightAniPool.length = 0;
		}
	}
}