package game.module.lvFundation 
{
	import game.common.base.BaseView;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.GameLanguage;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Box;
	import MornUI.LvFundation.LvFunItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LvFunItem extends Box 
	{
		private var itemMC:LvFunItemUI;
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		private var _data:Object = { };
		
		public function LvFunItem() 
		{
			super();
			init();
			
		}
		
		private function init():void
		{
			this.itemMC = new LvFunItemUI();
			this.addChild(itemMC);
			
			for (var i:int = 0; i < 4; i++ )
			{
				_rewardVec[i] = new ItemContainer();
				_rewardVec[i].scaleX = _rewardVec[i].scaleY = 0.75;
				_rewardVec[i].x = 215 + i * 60;
				_rewardVec[i].y = 0;
				itemMC.addChild(_rewardVec[i]);
			}
			
			view.clarmBtn.on(Event.CLICK, this, this.btnEventHandle);
			
		}
		
		private function btnEventHandle():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.LVFUNDATION_GETREWARD,[_data.level]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(!value)
			{
				return;
			}
			_data = value;
			
			itemMC.gray = true;
			itemMC.clarmBtn.disabled = true;
			if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BASE) >= parseInt(_data.level))
			{
				itemMC.gray = false;
				itemMC.clarmBtn.disabled = false;
			}
			
			itemMC.lvTxt.text = GameLanguage.getLangByKey("L_A_80302") + _data.level;
			//trace("value:", value);
			//trace("GameLanguage:", GameLanguage.getLangByKey(dayData.name));
			
			itemMC.clarmBtn.visible = false;
			itemMC.recieveTips.visible = true;
			if (_data.statue == 0)
			{
				itemMC.clarmBtn.visible = true;
				itemMC.recieveTips.visible = false;
			}
			
			var len:int = _rewardVec.length;
			var i:int = 0;
			var reArr:Array = _data.reward.split(";");
			var rl:int = reArr.length;
			
			for (i = 0; i < 4; i++ )
			{
				if (i < rl)
				{
					_rewardVec[i].x = 215 + (4 - rl) * 30 + i * 60;
					_rewardVec[i].setData(reArr[i].split("=")[0], reArr[i].split("=")[1]);
					_rewardVec[i].visible = true;
				}
				else
				{
					_rewardVec[i].visible = false;
				}
			}
			
			if (!User.getInstance().hasBuyFun)
			{
				itemMC.gray = true;
				itemMC.clarmBtn.disabled = true;
			}
			
		}
		
		private function get view():LvFunItemUI{
			return itemMC;
		}
		
	}

}