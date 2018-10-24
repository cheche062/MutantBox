/***
 *作者：罗维
 */
package game.module.bag.alert
{
	import MornUI.baseAlert.BaseAlertViewUI;
	import MornUI.panels.BagSellViewUI;
	
	import game.common.AlertType;
	import game.common.BaseAlertView;
	import game.common.InputSetCommon;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	
	public class BagSellAlert extends BaseAlertView
	{
		
		private var _inputSC:InputSetCommon;
		public function BagSellAlert()
		{
			super();
		}
		
		override public function addEvent():void
		{
			okBtn 		=  _alertView.getChildByName("okBtn") as Button;
			cancleBtn	= _alertView.getChildByName("cancleBtn") as Button;
			_inputSC.addEvent();
			_alertView.on(Event.CLICK,this ,onClickEvent);
		}
		
		public override function onClickEvent(e:Event):void
		{
			var target:Sprite = e.target;
			if(target.name == "okBtn")
			{
				_callBack(AlertType.RETURN_YES , _inputSC.text);
				this.close()
			}else if(target.name == "cancleBtn")
			{
				_callBack(AlertType.RETURN_NO);
				this.close()
			}
			
		}
		
		
		override public function removeEvent():void
		{
			_inputSC.removeEvent();
		}
		
		public override function createAlert():void
		{
			if(!_alertView)_alertView = new BagSellViewUI();
			_inputSC = InputSetCommon.create( (_alertView as BagSellViewUI).numInput ,
				(_alertView as BagSellViewUI).leftBtn,
				(_alertView as BagSellViewUI).rightBtn
			);
			this.addChild(_alertView);
			
			
		}
		
		/**
		 *弹出提示框 
		 * @param message 弹出文字
		 * @param flag	
		 * @param callBack 回掉函数
		 * @param isBackBlack 
		 * 
		 */		
		private var _itemData:ItemData;
		public override function alert( flag:int,callBack:Function, isBackBlack:Boolean = false,data:*=null):void
		{ 
			_callBack = callBack;
			_itemData = data;
			
			if(_itemData)
			{
				_inputSC.minNum = 1;
				_inputSC.maxNum = _itemData.inum;
				_inputSC.text = 1;
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BagSellAlert");
			_inputSC.dispose();
			_inputSC = null;
			super.destroy(destroyChild);
		} 
		
	}
}