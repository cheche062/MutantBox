package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossSetFoodUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 设置粮草 
	 * @author hejianbo
	 * 2018-04-19 17:56:58
	 */
	public class WorldBossSetFood extends BaseDialog
	{
		private var _putFood:int=0;
		
		// 确认的回调
		private var confirmCallBack:Function = null;
			
		public function WorldBossSetFood()
		{
			super();
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			confirmCallBack = args[0];
			
			view.allFoodTxt.text = User.getInstance().food;
			view.setFoodTxt.text = Math.floor(User.getInstance().food * view.foodSlider.value / 100);
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					close();
					break;
				case view.confirmBtn:
					confirmCallBack && confirmCallBack(_putFood);
					close();
					break;
				case view.addBtn:
					view.foodSlider.value+= 1;
					break;
				case view.minBtn:
					view.foodSlider.value-= 1;
					break;
				default:
					break;
			}
		}
		
		private function serviceResultHandler(... args):void {
			var cmd = args[0];
			var result = args[1];
			switch (cmd) {
				case ServiceConst.ARMY_GROUP_SET_FOOD:
					close();
					
					break;
				default:
					break;
			}
		}
		
		private function sliderChaHandler(value:Number):void
		{
			_putFood = parseInt(User.getInstance().food * value/100);
			view.setFoodTxt.text = _putFood;
		}
		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void
		{
			confirmCallBack = null;
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
			this._closeOnBlank = true;
			
			view.foodSlider.showLabel = false;
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			view.foodSlider.changeHandler = new Handler(this, sliderChaHandler);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			view.foodSlider.changeHandler = null;
				
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			super.removeEvent();
		}
		
		private function get view():WorldBossSetFoodUI
		{
			_view = _view || new WorldBossSetFoodUI();
			return _view;
		}
	}
}