package game.module.armyGroup.fight 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.armyGroupFight.ArmyFightSetFoodUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyFightSetFood extends BaseDialog 
	{
		
		private var _putFood:int=0
		
		public function ArmyFightSetFood() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					close();
					break;
				case view.confirmBtn:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_SET_FOOD,_putFood);
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
		
		private function serviceResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_SET_FOOD:
					trace('保护粮草', args[1])
					
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

		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			var setFoodNum = args[0] || 0;
			
			view.allFoodTxt.text = User.getInstance().food;
			
			view.foodSlider.value = setFoodNum * 100 / User.getInstance().food;
			view.setFoodTxt.text = String(setFoodNum);
			
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}

		private function onClose():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}

		override public function createUI():void
		{
			this._view=new ArmyFightSetFoodUI();
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			view.foodSlider.showLabel = false;
			view.foodSlider.changeHandler = new Handler(this, sliderChaHandler);
			
		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_FOOD), this, this.serviceResultHandler, [ServiceConst.ARMY_GROUP_SET_FOOD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}


		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_SET_FOOD), this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			super.removeEvent();
		}

		private function get view():ArmyFightSetFoodUI
		{
			return _view;
		}
		
		
	}

}