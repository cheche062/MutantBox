package game.module.startrek
{
	import MornUI.startrek.StarTrekShopViewUI;

	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.starTrek.StarTrekShopVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Button;

	/**
	 * ...
	 * @author ...
	 */
	public class StarTrekShopView extends BaseDialog
	{
		private var _goodVo0:StarTrekShopVo;
		private var _goodVo1:StarTrekShopVo;
		private var _eventData:Object;

		private var _goodContainer0:ItemContainer;
		private var _goodContainer1:ItemContainer;

		private var _buyTime0:int;
		private var _buyTime1:int;

		private var _curBtn:Button;

		public function StarTrekShopView()
		{
			super();

		}

		override public function show(... args):void
		{
			super.show();

			_eventData=args[0];		
			
			var sid0:int = parseInt(GameConfigManager.StarTrekEvents[_eventData.id].param1.split(";")[0]);
			var sid1:int = parseInt(GameConfigManager.StarTrekEvents[_eventData.id].param1.split(";")[1]);
			
			_goodVo0 = GameConfigManager.StarTrekShopVec[sid0];
			_goodVo1 = GameConfigManager.StarTrekShopVec[sid1];
			
			_buyTime0 = _buyTime1 = 0;
			if (_eventData.buyTimes[_eventData.x + "_" + _eventData.y])
			{
				_buyTime0 = _eventData.buyTimes[_eventData.x + "_" + _eventData.y][sid0];
				_buyTime1 = _eventData.buyTimes[_eventData.x + "_" + _eventData.y][sid1];
			}
			
			_goodContainer0.setData(_goodVo0.item.split("=")[0], _goodVo0.item.split("=")[1]);
			_goodContainer1.setData(_goodVo1.item.split("=")[0], _goodVo1.item.split("=")[1]);

			view.buy0.disabled=Boolean(_buyTime0 >= _goodVo0.limit);
			view.buy1.disabled=Boolean(_buyTime1 >= _goodVo1.limit);

			view.now0.text=_goodVo0.cost2.split("=")[1];
			view.now1.text=_goodVo1.cost2.split("=")[1];

			view.old0.text=_goodVo0.cost1.split("=")[1];
			view.old1.text=_goodVo1.cost1.split("=")[1];

			view.sale0.text=_goodVo0.percent * 100 + "%";
			view.sale1.text=_goodVo1.percent * 100 + "%";

			AnimationUtil.popIn(this);
		}

		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.STAR_TREK_GET_THINGS:
					_curBtn.disabled=true;
					break;
				default:
					break;
			}
		}

		override public function close():void
		{
			AnimationUtil.popOut(this, this.onCloseHandler);
		}

		private function onCloseHandler():void
		{
			super.close();
		}

		override public function addEvent():void
		{
			super.addEvent();
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_GET_THINGS), this, this.onResultHandler, [ServiceConst.STAR_TREK_GET_THINGS]);
			view.on(Event.CLICK, this, this.onClickHandler);

		}

		override public function removeEvent():void
		{
			super.removeEvent();
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.STAR_TREK_GET_THINGS), this, this.onResultHandler);
			view.off(Event.CLICK, this, this.onClickHandler);

		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.buy0:
					WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_GET_THINGS, [_eventData.x, _eventData.y, _goodVo0.id]);
					_curBtn=view.buy0;
					break;
				case view.buy1:
					WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_GET_THINGS, [_eventData.x, _eventData.y, _goodVo1.id]);
					_curBtn=view.buy1;
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}

		override public function createUI():void
		{
			this._view=new StarTrekShopViewUI();
			this.addChild(this._view);

			this.closeOnBlank=true;

			_goodContainer0=new ItemContainer();
			_goodContainer0.x=165;
			_goodContainer0.y=170;
			view.addChild(_goodContainer0);

			_goodContainer1=new ItemContainer();
			_goodContainer1.x=550;
			_goodContainer1.y=170;
			view.addChild(_goodContainer1);

		}

		private function get view():StarTrekShopViewUI
		{
			return _view as StarTrekShopViewUI;
		}

	}

}
