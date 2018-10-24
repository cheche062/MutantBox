package game.module.activity 
{
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.event.ActivityEvent;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.vo.activity.SevenDaysVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Box;
	import MornUI.acitivity.SevenDaysItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SevenDaysItem extends Box 
	{
		
		private var itemMC:SevenDaysItemUI;
		
		private var dayData:SevenDaysVo;
		
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		public function SevenDaysItem() 
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new SevenDaysItemUI();
			this.addChild(itemMC);
			
			view.getBtn.on(Event.CLICK, this, this.btnEventHandle);
			
		}
		
		private function btnEventHandle():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.SEVEN_DAYS_GET,[dayData.id]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(!value)
			{
				return;
			}
			
			//trace("value:", value);
			dayData = value as SevenDaysVo;
			/*trace("dayData:", dayData);
			trace("GameLanguage:", GameLanguage.getLangByKey(dayData.name));*/
			
			if (dayData.value.split(",").length > 1)
			{
				view.tarDesTF.text = GameLanguage.getLangByKey(dayData.name) + "(" + dayData.process + "/" + dayData.value.split(",")[1]+")";
			}
			else
			{
				view.tarDesTF.text = GameLanguage.getLangByKey(dayData.name) + "(" + dayData.process + "/" + dayData.value+")";
			}
			
			//trace("名字:"+GameLanguage.getLangByKey(dayData.name));
			var len:int = _rewardVec.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				_rewardVec[i].visible = false;
			}
			
			var reArr:Array = dayData.reward.split(";");
			
			len = reArr.length;
			for (i = 0; i < len; i++ )
			{
				if (!_rewardVec[i])
				{
					_rewardVec[i] = new ItemContainer();
					_rewardVec[i].x = 110 + i * 90;
					_rewardVec[i].y = 40;
					itemMC.addChild(_rewardVec[i]);
				}
				_rewardVec[i].visible = true;
				_rewardVec[i].setData(reArr[i].split("=")[0], reArr[i].split("=")[1]);
			}
			
			view.getBtn.disabled = false;
			view.getBtn.visible = true;
			switch(dayData.status)
			{
				case 0:
					view.getBtn.disabled = true;
					break;
				case 1:
					break;
				case 2:
					view.getBtn.visible = false;
					break;
				default:
					break;
			}
			
			
		}
		
		private function get view():SevenDaysItemUI{
			return itemMC;
		}
		
	}

}