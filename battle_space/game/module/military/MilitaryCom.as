package game.module.military
{
	import MornUI.military.MilitaryViewUI;
	
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.data.DBMilitary;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.utils.Handler;

	/**
	 * MilitaryCom
	 * author:huhaiming
	 * MilitaryCom.as 2017-4-28 上午11:23:16
	 * version 1.0
	 *
	 */
	public class MilitaryCom implements IMilitaryCom
	{
		private var _ui:*;
		private var _view:MilitaryViewUI
		public function MilitaryCom(ui:*, view:MilitaryViewUI)
		{
			this._ui = ui;
			_view = view;
			init();
		}
		
		private function format():void{
			_view.list.array = DBMilitary.list;
			
			var vo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
			_view.list.scrollTo(parseInt(vo.level)-1);
			_view.nameTF.text = GameLanguage.getLangByKey(vo.name);
		}
		
		private function onSelected(e:Event, index:int):void{
			if(e.type == Event.CLICK){
				//this.close();
				var item:MilitaryItem = _view.list.getCell(index) as MilitaryItem;
				XFacade.instance.showModule(MilitaryBuffView);
			}
		}
		
		public function show(...args):void
		{
			this._ui.visible = true;
			format();
			_view.list.mouseHandler = new Handler(this, this.onSelected);
			_view.tfCup.text = XUtils.formatNumWithSign(User.getInstance().cup);
		}
		
		public function close():void
		{
			this._ui.visible = false;
			_view.list.mouseHandler = null;
		}
		
		private function init():void{
			_view.list.itemRender = MilitaryItem;
			_view.list.hScrollBarSkin = "";
			//_view.list.size(805,282);
		}
	}
}