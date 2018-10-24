package game.module.armyGroup.fight
{
	import game.common.LayerManager;
	import game.common.base.BaseView;
	import game.global.vo.User;
	
	import laya.display.Sprite;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * FoodConsumTip 耗粮提示，自定义UI；
	 * author:huhaiming
	 * FoodConsumTip.as 2017-12-12 上午11:03:40
	 * version 1.0
	 *
	 */
	public class FoodConsumTip extends BaseView
	{
		private var _lb:Label;
		private var _container:Sprite;
		private static const POS_X:int = 1030;
		private static const POS_Y:int = 100;
		public function FoodConsumTip(container:Sprite)
		{
			super();
			_container = container;
		}
		
		override public function show(...args):void{
			var data:Array = (args[0]||[]);
			//第六位用户ID,第七位为消耗
			var info:Object
			var consum:int = 0;
			var itemList:Array;
			for(var i:int=0; i<data.length; i++){
				info = data[i];
				if(info && info[0] && info[1]){
					if(info[0][5] == User.getInstance().uid){
						itemList = info[0][6];
						if(itemList){
							consum += Math.round(itemList[0]?itemList[0].num:0)
						}
					}else if(info[1][5] == User.getInstance().uid){
						itemList = info[1][6];
						if(itemList){
							consum += Math.round(itemList[0]?itemList[0].num:0)
						}
					}
				}
			}
			if(consum > 0){
				_lb.text = "-"+consum;
				_container.addChild(this);
			}else{
				return;
			}
			
			pos(POS_X, POS_Y);
			this.cacheAsBitmap = true;
			Tween.to(this, {x:this.x-100, y:this.y-50}, 1200,null, Handler.create(this,close));
		}
		
		override public function createUI():void{
			var image:Image = new Image("common/icons/nlb.png");
			this.addChild(image);
			
			_lb = new Label();
			_lb.font = "Futura";
			_lb.color = "#ff0000";
			_lb.fontSize = 16;
			_lb.pos(38,12);
			this.addChild(_lb);
		}
	}
}